//File name  : base_reg_access_seq.sv
//Description: Common register sequence for access test

//----------------------------------------
/* There are four kinds of test.
        REG_HW_RESET: reset test.
        REG_ACCESS_0: write 0 to all bits, and read.
        REG_ACCESS_1: write 1 to all bits, and read.
        REG_ACCESS_RANDOM: write random value, and read
        REG_WRITE_RANDOM: write random value.
        REG_READ: read
*/
// `include "uvm_macros.svh"
// import uvm_pkg::*;

`ifndef SEC_REG_ACCESS_KIND
`define SEC_REG_ACCESS_KIND
typedef enum { REG_HW_RESET,
               REG_ACCESS_0,
               REG_ACCESS_1,
               REG_ACCESS_RANDOM,
               REG_WRITE_RANDOM,
               REG_READ
} sec_reg_access_kind_t;

`endif // SEC_REG_ACCESS_KIND

`ifndef SEC_REG_ACCESS_ORDER_KIND
`define SEC_REG_ACCESS_ORDER_KIND
typedef enum { RANDOM, INCREASE, DECREASE} sec_order_kind_t;
`endif // SEC_REG_ACCESS_ORDER_KIND

//-----------------------------------------------------------
// Class: reg_single_hw_reset_seq_c
/*
   Verify the hardware reset value of a register
   After reset, read it via the frontdoor
   making sure that resulting value matches the mirrored value.

   If bit-type resource named
   "NO_REG_TESTS" or "NO_REG_HW_RESET_TESTS"
   in the "REG::" namespace
   matches the full name of the register,
   the register is not tested.
   uvm_resource_db#(bit)::set({"REG::", regmodel.blk.r0.get_full_name()}, "NO_REG_TESTS", 1, this);
   According to access policies,
   Some registers cannot be tested.
   The DUT should be idle and not modify any register during this test.


*/
`ifndef SUV_REG_SINGLE_HW_RESET_SEQ_C
`define SUV_REG_SINGLE_HW_RESET_SEQ_C

class reg_single_hw_reset_seq_c extends uvm_reg_sequence#(uvm_sequence #(uvm_reg_item));
    //Register handle to be tested
    uvm_reg rg;
    `uvm_object_utils(reg_single_hw_reset_seq_c)

    function new(string name="reg_single_hw_reset_seq_c");
        super.new(name);
    endfunction:new

    virtual task body();
        uvm_reg_map maps[$];
        uvm_reg_field fields[$];
        bit           is_field_check_restore[];

        if(rg == null) begin
            `uvm_error(get_full_name(), "No register specified to run sequence on")
            return;
        end

        //Registers with some attributes are not to be tested
        if(uvm_resource_db#(bit)::get_by_name({"REG::", rg.get_full_name()},
                                              "NO_REG_TESTS", 0) !=null ||
           uvm_resource_db#(bit)::get_by_name({"REG::", rg.get_full_name()},
                                              "NO_REG_HW_RESET_TESTS", 0) !=null)
        return;

        //Registers may be accessible from multiple physical interfaces(maps)
        rg.get_maps(maps);

        rg.get_fields(fields);
        is_field_check_restore = new[fields.size()];
        foreach(fields[j])begin
            foreach(maps[k])begin
                `uvm_info(get_full_name(), $psprintf("field: %s, map: %s, access: %s", fields[j].get_name(), maps[k].get_name(), fields[j].get_access(maps[k])),UVM_FULL)
                if(!fields[j].is_known_access(maps[k]))begin
                    `uvm_warning(get_full_name(),{"Register '", rg.get_full_name(),
                    "' has field with unknown access type'",
                    fields[j].get_access(maps[k]), "'"})
                    return;
                end
                is_field_check_restore[j] = 1'b0;
                //if field doesn't have reset value, do not compare
                //current compater mode will be restore at the end of this register's transaction
                if(!fields[j].has_reset)begin
                    if(fields[j].get_compare == UVM_CHECK)begin
                        fields[j].set_compare(UVM_NO_CHECK);
                        is_field_check_restore[j] = 1'b1;
                    end
                end
            end
        end
        // Access each register
        // Read via front door and compare against mirror
        foreach(maps[j]) begin
            uvm_status_e        status;
            uvm_reg_map_info    info = maps[j].get_reg_map_info(rg);
            //uvm_reg_data_t value;
            `uvm_info(get_full_name(), $psprintf("verify reset value (reg: %s, map: %s)", rg.get_full_name(), maps[j].get_full_name()), UVM_LOW)
            rg.mirror(status, UVM_CHECK, UVM_FRONTDOOR, maps[j], this);

            if((info.rights != "WO") &&(status != UVM_IS_OK)) begin
                `uvm_error(get_full_name(), {"status was '",status.name(),
                                    "' when reading reset value of register '",
                                    rg.get_full_name(), "(", info.rights, ")' through frontdoor"})
            end
        end
        foreach(is_field_check_restore[j])begin
            if(is_field_check_restore[j])
                fields[j].set_compare(UVM_CHECK);
        end
    endtask: body
endclass: reg_single_hw_reset_seq_c
`endif // SUV_REG_SINGLE_HW_RESET_SEQ_C

`ifndef SUV_REG_SINGLE_ACCESS_SEQ_C
`define SUV_REG_SINGLE_ACCESS_SEQ_C
//-----------------------------------------------------
/* Class: reg_single_access_seq_c
   Verify the accessibility of a register
   by writing through its defaule address map
   then reading it via the frontdoor
   making sure that resulting value matches the mirrored value.

   If bit-type resource named
   "NO_REG_TESTS" or "NO_REG_HW_RESET_TESTS"
   in the "REG::" namespace
   matches the full name of the register,
   the register is not tested.

   uvm_resource_db#(bit)::set({"REG::", regmodel.blk.r0.get_full_name()},
                                "NO_REG_TESTS", 1, this);

   Registers without an available backdoor or
   that contain read-only fields only
   or fields with unknown access policies
   cannot be tested.
   The DUT should be idle and not modify any register during this test.
*/
//-----------------------------------------------------
typedef enum {READ_ONLY, WRITE_ONLY, READ_WRITE} reg_seq_mode_t;

class reg_single_access_seq_c extends uvm_reg_sequence#(uvm_sequence #(uvm_reg_item));
    //Register handle to be tested
    uvm_reg rg;
    rand uvm_reg_data_t value;
    reg_seq_mode_t mode = READ_WRITE;

    `uvm_object_utils(reg_single_access_seq_c)

    function new(string name = "reg_single_access_seq_c");
        super.new(name);
    endfunction:new

    virtual task body();
        uvm_reg_map maps[$];

        if(rg == null) begin
            `uvm_error(get_full_name(), "No register specified to run sequence on")
            return;
        end
        // Registers with some attributes are not to be tested
        if(uvm_resource_db#(bit)::get_by_name({"REG::", rg.get_full_name()},
                                              "NO_REG_TESTS", 0) !=null ||
           uvm_resource_db#(bit)::get_by_name({"REG::", rg.get_full_name()},
                                              "NO_REG_RESET_TESTS", 0) !=null)
        return;
        // Registers may be accessible from multiple physical interfaces (maps)
        rg.get_maps(maps);
        begin
            uvm_reg_field fields[$];
            rg.get_fields(fields);
            foreach(fields[j])begin
                foreach(maps[k])begin
                    `uvm_info(get_full_name(), $psprintf("field: %s, map: %s, access: %s", fields[j].get_name(), maps[k].get_name(), fields[j].get_access(maps[k])),UVM_FULL)
                    if(!fields[j].is_known_access(maps[k]))begin
                        `uvm_warning(get_full_name(),{"Register '", rg.get_full_name(),
                        "' has field with unknown access type'",
                        fields[j].get_access(maps[k]), "'"})
                        return;
                    end
                end
            end
        end
        // Access each register
        // Write value via frontdoor
        // Read value via frontdoor and compare against mirror
        foreach(maps[j])begin
            uvm_status_e        status;
            uvm_reg_map_info    info = maps[j].get_reg_map_info(rg);

            if(mode != READ_ONLY)begin
                //Write value
                rg.write(status, value, UVM_FRONTDOOR, maps[j], this);

                if((info.rights!= "RO") && (status != UVM_IS_OK)) begin
                    `uvm_error(get_full_name(), {"status was '", status.name(),
                                        "' when writing '", rg.get_full_name(),
                                        "' through map '", maps[j].get_full_name(),"'"})
                end
                #1;
            end
            if(mode != WRITE_ONLY)begin
                //Read value
                rg.mirror(status, UVM_CHECK, UVM_FRONTDOOR, maps[j], this);

                //if(status != UVM_IS_OK) begin
                if((info.rights != "WO") && (status != UVM_IS_OK)) begin
                    `uvm_error(get_full_name(), {"status was '", status.name(),
                                        "' when reading value of register '",
                                        rg.get_full_name(),"' through frontdoor"})
                end
                #1;
            end
        end
    endtask: body
endclass: reg_single_access_seq_c
`endif // SUV_REG_SINGLE_ACCESS_SEQ_C


// `ifndef SUV_REG_ACCESS_SEQ_C
// `define SUV_REG_ACCESS_SEQ_C
//----------------------------------------------------------------------
/*
    Class: reg_access_seq_c
    Verify the accessibility of all registers in a block
    by executing the <reg_single_access_seq> sequence on
    every register within it.
    If bit-type resource named
    "NO_REG_TESTS" or "NO_REG_ACCESS_TESTS"
    in the "REG::" namespace
    matches the full name of the block
    the block is not tested
    uvm_resource_db#(bit)::set({"REG::", regmodel.blk.r0.get_full_name(),".*"},
                                "NO_REG_TESTS", 1, this);
*/
//----------------------------------------------------------------------
// class reg_access_seq_c extends uvm_reg_sequence#(uvm_sequence #(uvm_reg_item));
//     rand sec_reg_access_kind_t kind;
//     uvm_reg user_defined_regs[$];

//     reg_single_hw_reset_seq_c single_hw_reset_seq;
//     reg_single_access_seq_c   single_access_seq;
//     uvm_reg_map map;

//     `uvm_object_utils_begin(reg_access_seq_c)
//     `uvm_object_utils_end

//     function new(string name="reg_access_seq_c");
//         super.new(name);
//     endfunction:new

//     // task: body
//     // Executes the Register Access sequence.
//     // Do not call directly. Use seq.start() instead.

//     virtual task body();

//         if(model == null) begin
//             `uvm_error(get_full_name(), "No register model specified to run sequence on")
//             return;
//         end

//         if(kind == REG_HW_RESET) begin
//             single_hw_reset_seq = reg_single_hw_reset_seq_c::type_id::create("single_hw_reset_seq");
//             `uvm_info(get_full_name(),{"\n\n======================================\nstart reset test \n=======================\n"}, UVM_LOW)
//         end else if(kind == REG_ACCESS_0) begin
//             single_access_seq = reg_single_access_seq_c::type_id::create("single_access_seq");
//             `uvm_info(get_full_name(),{"\n\n======================================\nstart access test with 'h0 \n=======================\n"}, UVM_LOW)
//         end else if(kind == REG_ACCESS_1) begin
//             single_access_seq = reg_single_access_seq_c::type_id::create("single_access_seq");
//             //`uvm_info(get_full_name(),{"\n\n======================================\nstart access test with 'h%h \n=======================\n"}, {`UVM_REG_DATA_WIDTH{1'b1}}, UVM_LOW)
//         end else if(kind == REG_ACCESS_RANDOM) begin
//             single_access_seq = reg_single_access_seq_c::type_id::create("single_access_seq");
//             `uvm_info(get_full_name(),{"\n\n======================================\nstart access test with random value \n=======================\n"}, UVM_LOW)
//         end else if(kind == REG_WRITE_RANDOM) begin
//             single_access_seq = reg_single_access_seq_c::type_id::create("single_access_seq");
//             `uvm_info(get_full_name(),{"\n\n======================================\nstart write test with random value \n=======================\n"}, UVM_LOW)
//         end else if(kind == REG_READ) begin
//             single_access_seq = reg_single_access_seq_c::type_id::create("single_access_seq");
//             `uvm_info(get_full_name(),{"\n\n======================================\nstart read test with random value \n=======================\n"}, UVM_LOW)
//         end else begin
//             `uvm_fatal(get_full_name(), "UNKNOWN REG ACCESS KIND!")
//         end

//         this.reset_blk(model);
//         if(map != null) begin
//             do_map(map);
//         end else begin
//             do_block(model);
//         end
//     endtask: body

//     //Test all of the registers in a block
//     virtual task do_block(uvm_reg_block blk);
//         uvm_reg regs[$];

//         if (uvm_resource_db#(bit)::get_by_name({"REG::", blk.get_full_name()},
//                                               "NO_REG_TESTS", 0) !=null ||
//             uvm_resource_db#(bit)::get_by_name({"REG::", blk.get_full_name()},
//                                               "NO_REG_ACCESS_TESTS", 0) !=null) begin
//             return;
//         end
//         // Iterate over all registers, checking accesses with 'h0 value
//         // below part is modified due to backward compatibility
//         if(user_defined_regs.size() !=0) begin
//             regs = user_defined_regs;
//         end
//         else begin
//             blk.get_registers(regs, UVM_NO_HIER);
//         end

//         foreach (regs[i]) begin
//             int F = 1;
//             bit is_field_rand_mode_restore[];
//             uvm_reg_field fields[$];
//             regs[i].get_fields(fields);
//             is_field_rand_mode_restore = new[fields.size()];
//             //----------------------------------------------------
//             //Registers with some attributes are not to be tested
//             //----------------------------------------------------
//             if(kind == REG_HW_RESET) begin
//                 if (uvm_resource_db#(bit)::get_by_name({"REG::", regs[i].get_full_name()},
//                                               "NO_REG_TESTS", 0) !=null ||
//                     uvm_resource_db#(bit)::get_by_name({"REG::", regs[i].get_full_name()},
//                                               "NO_REG_HW_RESET_TESTS", 0) !=null) begin
//                     continue;
//                 end
//                 single_hw_reset_seq.rg = regs[i];
//                 single_hw_reset_seq.start(null, this);
//             end
//             else if (kind == REG_ACCESS_0 || kind == REG_ACCESS_1 || kind == REG_ACCESS_RANDOM || kind == REG_WRITE_RANDOM || kind == REG_READ) begin
//                 if (uvm_resource_db#(bit)::get_by_name({"REG::", regs[i].get_full_name()},
//                                               "NO_REG_TESTS", 0) !=null ||
//                     uvm_resource_db#(bit)::get_by_name({"REG::", regs[i].get_full_name()},
//                                               "NO_REG_ACCESS_TESTS", 0) !=null) begin
//                     continue;
//                 end
//                 foreach (fields[j]) begin
//                     //as default 'RO' fields are not randomized so randomized all kind of filds using rand_mode(1)
//                     //current rand mode will be restore at the end of this register's transaction.
//                     if(!fields[j].value.rand_mode())begin
//                         is_field_rand_mode_restore[j] = 1'b1;
//                         fields[j].value.rand_mode(1);
//                     end
//                     if(kind == REG_ACCESS_0)begin
//                         F &= fields[j].randomize() with {soft value == 1'b0;};
//                     end
//                     else if(kind == REG_ACCESS_1) begin
//                         F &= fields[j].randomize() with {soft value == ((1<<fields[j].get_n_bits())-1);};
//                     end
//                 end
//                 if (kind == REG_ACCESS_RANDOM || kind == REG_WRITE_RANDOM || kind == REG_READ) begin
//                     if(kind != REG_READ) begin
//                         F = regs[i].randomize();
//                         if(!F) begin
//                             `uvm_fatal(get_full_name(), $psprintf("Fail to randomize %s!", regs[i].get_name()))
//                         end
//                         if(kind == REG_WRITE_RANDOM) begin
//                             single_access_seq.mode = WRITE_ONLY;
//                         end
//                     end
//                     else begin
//                         single_access_seq.mode = READ_ONLY;
//                     end
//                 end
//                 single_access_seq.rg    = regs[i];
//                 single_access_seq.value = regs[i].get;
//                 single_access_seq.start(null, this);

//                 foreach(is_field_rand_mode_restore[j]) begin
//                     if(is_field_rand_mode_restore[j])begin
//                         fields[j].value.rand_mode();
//                     end
//                 end
//             end
//             else begin
//                 `uvm_fatal(get_full_name(), "UNKNOWN REG ACCESS KIND!")
//             end
//         end
//         begin
//             uvm_reg_block blks[$];
//             blk.get_blocks(blks);

//             foreach (blks[i])begin
//                 do_block(blks[i]);
//             end
//         end

//     endtask: do_block

//     // Test all of the register in a map
//     virtual task do_map(uvm_reg_map map);

//         uvm_reg regs[$];
//         uvm_reg_block blk = map.get_parent();
//         if (uvm_resource_db#(bit)::get_by_name({"REG::", blk.get_full_name()},
//                                               "NO_REG_TESTS", 0) !=null ||
//             uvm_resource_db#(bit)::get_by_name({"REG::", blk.get_full_name()},
//                                               "NO_REG_ACCESS_TESTS", 0) !=null) begin
//             return;
//         end
//         // Iterate over all registers, checking accesses with 'h0 value
//         map.get_registers(regs);
//         foreach (regs[i]) begin
//             int F = 1;
//             bit is_field_rand_mode_restore[];
//             uvm_reg_field fields[$];
//             regs[i].get_fields(fields);
//             is_field_rand_mode_restore = new[fields.size()];

//             //Registers with some attributes are not to be tested
//             if (kind == REG_HW_RESET) begin
//                 if (uvm_resource_db#(bit)::get_by_name({"REG::", regs[i].get_full_name()},
//                                               "NO_REG_TESTS", 0) !=null ||
//                     uvm_resource_db#(bit)::get_by_name({"REG::", regs[i].get_full_name()},
//                                               "NO_REG_HW_RESET_TESTS", 0) !=null) begin
//                     continue;
//                 end
//                 single_hw_reset_seq.rg = regs[i];
//                 single_hw_reset_seq.start(null, this);
//             end
//             else if (kind == REG_ACCESS_0 || kind == REG_ACCESS_1 || kind == REG_ACCESS_RANDOM || kind == REG_WRITE_RANDOM || kind == REG_READ) begin
//                 if (uvm_resource_db#(bit)::get_by_name({"REG::", regs[i].get_full_name()},
//                                               "NO_REG_TESTS", 0) !=null ||
//                     uvm_resource_db#(bit)::get_by_name({"REG::", regs[i].get_full_name()},
//                                               "NO_REG_ACCESS_TESTS", 0) !=null) begin
//                     continue;
//                 end
//                 foreach (fields[j]) begin
//                     //as default 'RO' fields are not randomized so randomized all kind of filds using rand_mode(1)
//                     //current rand mode will be restore at the end of this register's transaction.
//                     if(!fields[j].value.rand_mode())begin
//                         is_field_rand_mode_restore[j] = 1'b1;
//                         fields[j].value.rand_mode(1);
//                     end
//                     if(kind == REG_ACCESS_0)begin
//                         F &= fields[j].randomize() with {soft value == 1'b0;};
//                     end
//                     else if(kind == REG_ACCESS_1) begin
//                         F &= fields[j].randomize() with {soft value == ((1<<fields[j].get_n_bits())-1);};
//                     end
//                 end
//                 if (kind == REG_ACCESS_RANDOM || kind == REG_WRITE_RANDOM || kind == REG_READ) begin
//                     if(kind != REG_READ) begin
//                         F = regs[i].randomize();
//                         if(!F) begin
//                             `uvm_fatal(get_full_name(), $psprintf("Fail to randomize %s!", regs[i].get_name()))
//                         end
//                         if(kind == REG_WRITE_RANDOM) begin
//                             single_access_seq.mode = WRITE_ONLY;
//                         end
//                     end
//                     else begin
//                         single_access_seq.mode = READ_ONLY;
//                     end
//                 end
//                 single_access_seq.rg    = regs[i];
//                 single_access_seq.value = regs[i].get;
//                 single_access_seq.start(null, this);

//                 foreach(is_field_rand_mode_restore[j]) begin
//                     if(is_field_rand_mode_restore[j])begin
//                         fields[j].rand_mode();
//                     end
//                 end
//             end
//             else begin
//                 `uvm_fatal(get_full_name(), "UNKNOWN REG ACCESS KIND!")
//             end
//         end
//     endtask: do_map
// //         //  task: reset_blk
//         /*
//             Reset the DUT that corresponds to the specified block abstraction class.
//             Currently empty
//             Will rollback the enviroment's phase to the reset
//             phase once the new phasing is available
//             in the meantime, the DUT should be reset before executing this
//             test sequence or this method should be implemented
//             in an extension to reset the DUT
//         */
//     virtual task reset_blk(uvm_reg_block blk);
//     endtask: reset_blk
// endclass: reg_access_seq_c
// `endif // SUV_REG_ACCESS_SEQ_C

`ifndef REG_MASK_SET_C
`define REG_MASK_SET_C

class reg_mask_set_c extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));

        virtual function bit [31:0] set_compare_mask(uvm_reg register);
        endfunction
        virtual function void constraint_randomize(uvm_reg regs[], bit[31:0] compare_mask[]);
        endfunction
        virtual function void set_fixed_value (uvm_reg regs[], bit[31:0] compare_mask[], bit[31:0] fixed_value);
        endfunction
        virtual function void constraint_for_ip_reg_fields(uvm_reg regs[]);
        endfunction
        virtual function bit [31:0] set_bitbash_mask(uvm_reg register);
        endfunction
        virtual function bit [31:0] set_reset_mask(uvm_reg register);
        endfunction

        `uvm_object_utils(reg_mask_set_c)
        //`uvm_declare_p_sequencer(vseqr_c)

        function new(string name= "reg_mask_set_c");
            super.new(name);
        endfunction

        function bit [31:0] make_compare_mask(uvm_reg register);
            uvm_reg_field fields[$];
            bit [31:0]    compare_mask;
            int           k;
            int  temp;
            compare_mask = 'hffff_ffff;
            `uvm_info(get_type_name(), "-------------------------------------------", UVM_LOW)
            `uvm_info(get_type_name(), "make_compare_mask", UVM_LOW)
            `uvm_info(get_type_name(), $psprintf("\"%s\"", register.get_full_name()), UVM_LOW)
            register.get_fields(fields);
            foreach (fields[j]) begin
                if(fields[j].get_access()!="RW") begin
                    for(k=0; k<fields[j].get_n_bits(); k = k+1)begin
                        temp = fields[j].get_lsb_pos();
                        compare_mask = compare_mask &~('h00000001 << (k+temp));
                    end
                    `uvm_info(get_type_name(), $psprintf(" %30s [%d:%d] is not RW field", fields[j].get_name(), fields[j].get_lsb_pos()+fields[j].get_n_bits()-1, fields[j].get_lsb_pos()), UVM_LOW)
                end
            end
            `uvm_info(get_type_name(), $psprintf("(compare_mask = %h)", compare_mask), UVM_LOW)
            `uvm_info(get_type_name(), "-----------------------------------------------", UVM_LOW)

            return compare_mask;
        endfunction

        function bit [31:0] make_compare_mask_wo(uvm_reg register);
            uvm_reg_field fields[$];
            bit [31:0]    compare_mask;
            int           k;
            int           temp;
            compare_mask = 'hffff_ffff;
            `uvm_info(get_type_name(), "--------------------------------------------------------", UVM_LOW)
            `uvm_info(get_type_name(), $psprintf("\"%s\"", register.get_full_name()), UVM_LOW)
            register.get_fields(fields);
            foreach (fields[j]) begin
                if(fields[j].get_access()=="WO") begin
                    for(k=0; k<fields[j].get_n_bits(); k = k+1)begin
                        temp = fields[j].get_lsb_pos();
                        compare_mask = compare_mask &~('h00000001 << (k+temp));
                    end
                    `uvm_info(get_type_name(), $psprintf(" %30s [%d:%d] is WO field", fields[j].get_name(), fields[j].get_lsb_pos()+fields[j].get_n_bits()-1, fields[j].get_lsb_pos()), UVM_LOW)
                end
            end
            `uvm_info(get_type_name(), $psprintf("(compare_mask = %h)", compare_mask), UVM_LOW)
            `uvm_info(get_type_name(), "-----------------------------------------------", UVM_LOW)
            return compare_mask;
        endfunction

        virtual task body();
            if(model == null) begin
                `uvm_error(get_type_name(),"No register model specified to run sequence on")
                return;
            end
        endtask: body
    endclass
`endif //REG_MASK_SET_C

`ifndef SFR_RW_TEST_BASE_C
`define SFR_RW_TEST_BASE_C
class sfr_rw_test_base_c extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));

    //---------------------------------------------------------
    //Register handle to be tested
    //---------------------------------------------------------
    uvm_reg regs[$];
    uvm_reg user_defined_regs[$];
    rand uvm_reg_data_t value;

    int i;
    int index_queue[$];
    int id;
    rand int rand_idx;
    int no_err_slave_response_err = 0; //added to support security extension
    bit [`UVM_REG_DATA_WIDTH-1:0]  read_val;
    bit [`UVM_REG_DATA_WIDTH-1:0]  write_val;
    bit [`UVM_REG_DATA_WIDTH-1:0]  bkdoor_read_val;
    int test_reg_num;
    int is_test_reg_num_given; // to reduce test_reg_num
    int tzpc_check_even_for_ro_reg = 0;

    `ifdef SUV_CDN_PS_AXI
        denaliCdn_axiResponseT arm_rd_resp;
        denaliCdn_axiResponseT arm_rd_resp;
    `endif//SUV_CDN_PS_AXI
    `ifdef SUV_SEC_AXI
        sec_axi_response_t arm_rd_resp;
        sec_axi_response_t arm_wr_resp;
    `endif//SUV_SEC_AXI

    uvm_status_e status;

    `uvm_object_utils_begin(sfr_rw_test_base_c)
        `ifdef SUV_CDN_PS_AXI
            `uvm_field_enum(denaliCdn_axiResponseT, arm_rd_resp, UVM_DEFAULT)
            `uvm_field_enum(denaliCdn_axiResponseT, arm_Wd_resp, UVM_DEFAULT)
        `endif

        `ifdef SUV_SEC_AXI
            `uvm_field_enum(denaliCdn_axiResponseT, arm_rd_resp, UVM_DEFAULT)
            `uvm_field_enum(denaliCdn_axiResponseT, arm_Wd_resp, UVM_DEFAULT)
        `endif
    `uvm_object_utils_end

    function new(string name = "sfr_rw_test_base_c");
        super.new(name);
        this.test_reg_num = regs.size();
        this.is_test_reg_num_given = 0;
    endfunction

    //for single register access
    function bit [`UVM_REG_DATA_WIDTH -1:0] get_compare_mask(uvm_reg register, input bit [`UVM_REG_DATA_WIDTH -1 :0] compare_mask[]);
        foreach(regs[i]) begin
            if(register.get_offset() == regs[i].get_offset())begin
                get_compare_mask = compare_mask[i];
                return get_compare_mask;
            end
        end
    endfunction // get_compare_mask

    virtual task write_one_reg(string uvm_reg_name, output bit[`UVM_REG_DATA_WIDTH-1:0] wvalue, input bit[`UVM_REG_DATA_WIDTH-1:0] compare_mask[], int expecting_err_resp = 0, input bit[`UVM_REG_DATA_WIDTH-1:0] gen_mask = 32'hffff_ffff);
        uvm_reg register;
        bit [`UVM_REG_DATA_WIDTH-1:0] reg_compare_mask;
        register = model.get_reg_by_name(uvm_reg_name);
        if(register == null) begin
            `uvm_fatal(get_type_name(), $psprintf("Please check the register name given : %s", uvm_reg_name))
        end
        else begin
            reg_compare_mask = get_compare_mask(register, compare_mask);
            if((reg_compare_mask !=0) || (gen_mask != 32'hffff_ffff) || ((reg_compare_mask !=0) && (uvm_reg_name == "hex1ctrl")))begin
                `uvm_info(get_type_name(), $psprintf("KDJ DEBUG, gen_mask = %h", gen_mask), UVM_LOW)
                register.write(status, (reg_compare_mask & gen_mask));
                `uvm_info(get_type_name(), $psprintf(" DEBUG, status = %s", status.name()), UVM_LOW)
                `ifdef SUV_CDN_PS_AXI
                    #1ps;
                    if(!uvm_config_db#(denaliCdn_axiResponseT)::get(null, get_full_name(), "arm_wr_resp", arm_wr_resp))
                        `uvm_fatal(get_type_name(), {"arm_wr_resp must be set for", get_type_name()})
                    if(arm_wr_resp != DenaliSvCdn_axi::DENALI_CDN_AXI_RESPONSE_OKAY) begin
                        if(expecting_err_resp == 1)
                            `uvm_info(get_type_name(), $psprintf(" arm_wr_resp=%s expecting_err_resp = %x: when writing to register \"%s\"", arm_wr_resp.name(), expecting_err_resp, register.get_full_name()), UVM_LOW)
                        else
                            `uvm_error(get_type_name(), $psprintf(" arm_wr_resp=%s expecting_err_resp = %x: when writing to register \"%s\"", arm_wr_resp.name(), expecting_err_resp, register.get_full_name()))
                    end
                    else begin
                        if(expecting_err_resp == 1)
                            `uvm_error(get_type_name(), $psprintf(" arm_wr_resp=%s expecting_err_resp = %x: when writing to register \"%s\"", arm_wr_resp.name(), expecting_err_resp, register.get_full_name()))
                    end
                `endif // SUV_CDN_PS_AXI

                `ifdef SUV_SEC_AXI
                    // need to implement
                `endif // SUV_SEC_AXI
                wvalue = register.get();
                `uvm_info(get_type_name(), $psprintf("\"%s\": Writing 'h%h", register.get_full_name(), wvalue), UVM_LOW)
            end
            else begin
                `uvm_info(get_type_name(), $psprintf("register name: %0s, reg_compare_mask: %0d", uvm_reg_name, reg_compare_mask), UVM_LOW)
                `uvm_fatal(get_type_name(), "Please select register with RW attribute for TZPC")
            end
        end
    endtask // write_one_reg

    virtual task read_one_reg(string uvm_reg_name, output bit[`UVM_REG_DATA_WIDTH-1:0] wvalue, input bit[`UVM_REG_DATA_WIDTH-1:0] compare_mask[], int expecting_err_resp = 0);
        uvm_reg register;
        bit [`UVM_REG_DATA_WIDTH-1:0] reg_compare_mask, rd_val, wr_val;
        register = model.get_reg_by_name(uvm_reg_name);
        if(register == null) begin
            `uvm_fatal(get_type_name(), $psprintf("Please check the register name given : %s", uvm_reg_name))
        end
        else begin
            reg_compare_mask = get_compare_mask(register, compare_mask);
            if(reg_compare_mask !=0)begin
                register.read(status, rd_val);
                `uvm_info(get_type_name(), $psprintf(" DEBUG, status = %s", status.name()), UVM_LOW)
                `ifdef SUV_CDN_PS_AXI
                    #1ps;
                    if(!uvm_config_db#(denaliCdn_axiResponseT)::get(null, get_full_name(), "arm_rd_resp", arm_rd_resp))
                        `uvm_fatal(get_type_name(), {"arm_rd_resp must be set for", get_type_name()})
                    if(arm_rd_resp != DenaliSvCdn_axi::DENALI_CDN_AXI_RESPONSE_OKAY) begin
                        if(expecting_err_resp == 1)
                            `uvm_info(get_type_name(), $psprintf(" arm_rd_resp=%s expecting_err_resp = %x: when reading from register \"%s\"", arm_rd_resp.name(), expecting_err_resp, register.get_full_name()), UVM_LOW)
                        else
                            `uvm_error(get_type_name(), $psprintf(" arm_rd_resp=%s expecting_err_resp = %x: when reading from register \"%s\" and expecting non-error response", arm_rd_resp.name(), expecting_err_resp, register.get_full_name()))
                    end
                    else begin
                        if(expecting_err_resp == 1)
                            `uvm_error(get_type_name(), $psprintf(" arm_rd_resp=%s expecting_err_resp = %x: when reading from register \"%s\"", arm_rd_resp.name(), expecting_err_resp, register.get_full_name()))
                        else begin
                            rd_val = rd_val & reg_compare_mask;
                            wr_val = wvalue & reg_compare_mask;
                            if(rd_val == wr_val)
                                `uvm_info(get_type_name(), $psprintf("Match : data = %h (compare_mask = %h)", rd_val, reg_compare_mask), UVM_LOW)
                            else
                                `uvm_error(get_type_name(), $psprintf("Mismatch : write_val = %h, read_val = %h (compare_mask = %h)", wr_val,rd_val, reg_compare_mask))
                        end

                    end
                `endif // SUV_CDN_PS_AXI

                `ifdef SUV_SEC_AXI
                    // need to implement
                `endif // SUV_SEC_AXI
                `uvm_info(get_type_name(), $psprintf("\"%s\": Writing 'h%h", register.get_full_name(), wvalue), UVM_LOW)
            end
        end
    endtask // read_one_reg

    virtual task check_status(int direction, int idx);
        if(direction == 1) begin
            if(status != UVM_IS_OK) begin
                if(no_err_slave_response_err == 0)
                    `uvm_error(get_type_name(), $psprintf(" Status=%s : when writing to register \"%s\"", status.name(), regs[idx].get_full_name()))
                else
                    `uvm_info(get_type_name(), $psprintf(" Status=%s : when writing to register \"%s\"", status.name(), regs[idx].get_full_name()), UVM_LOW)
            end
        end
        else begin
            if(status != UVM_IS_OK) begin
                if(no_err_slave_response_err == 0)
                    `uvm_error(get_type_name(), $psprintf(" Status=%s : when reading to register \"%s\"", status.name(), regs[idx].get_full_name()))
                else
                    `uvm_info(get_type_name(), $psprintf(" Status=%s : when reading to register \"%s\"", status.name(), regs[idx].get_full_name()), UVM_LOW)
            end
        end
    endtask

    virtual task check_read_data(bit [`UVM_REG_DATA_WIDTH-1:0] compare_mask, int idx);
        if(read_val == write_val)
            `uvm_info(get_type_name(), $psprintf(" Match : data = %h (compare_mask = %h)", read_val, compare_mask), UVM_LOW)
        else
            `uvm_error(get_type_name(), $psprintf(" Mismatch : wdata = %h, rdata =%h (compare_mask = %h)", write_val, read_val, compare_mask))
    endtask

    virtual task write(output bit [`UVM_REG_DATA_WIDTH-1:0] wvalue[], input bit [`UVM_REG_DATA_WIDTH-1:0] compare_mask[], sec_order_kind_t order_type);
        bit use_write = 0;
        wvalue = new[regs.size()];
        `uvm_info(get_type_name(), $psprintf("register number is %d", regs.size()), UVM_FULL)


        if($test$plusargs("BASE_REG_ACCESS_USE_WRITE"))begin
            use_write = 1;
            `uvm_info(get_type_name(), "NOTE!!!: agrs BASE_REG_ACCESS_USE_WRITE is in-used", UVM_LOW)
        end

        case (order_type)
            INCREASE : begin
                `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)
                `uvm_info(get_type_name(), ("   INCREASE_ORDER_WRITE"), UVM_LOW)
                `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)
                foreach (regs[i]) begin: next_reg
                    `uvm_info(get_type_name(), $psprintf("compare_mask[%d] = %h", i, compare_mask[i]), UVM_LOW)
                    `uvm_info(get_type_name(), $psprintf("Checking at: %s", regs[i].get_name), UVM_LOW)
                    if(compare_mask[i] != 'h0000_0000) begin
                        if(use_write) begin
							if (regs[i].get_name == "scr") begin //FIX_ME (sontd) clock source input no provide enough -> base case ccu can't generate sysclk
                    			`uvm_info(get_type_name(), $psprintf("[DEBUG] checking at scr register"), UVM_LOW)
                            	regs[i].write(status, regs[i].get()&compare_mask[i]);
							end
							else begin 
                            	regs[i].write(status, regs[i].get());
							end
                        end else begin
							if (regs[i].get_name == "scr") begin //FIX_ME (sontd) clock source input no provide enough -> base case ccu can't generate sysclk
								`uvm_info(get_type_name(), $psprintf("[DEBUG] checking at scr register"), UVM_LOW)
                            	regs[i].write(status, regs[i].get()&compare_mask[i]);
							end
							else begin
                            	regs[i].update(status);
							end
                        end
                        check_status(1,i);

                        wvalue[i] = regs[i].get();
                        `uvm_info(get_type_name(), $psprintf("\"%s\" : Writing 'h%h", regs[i].get_full_name(), wvalue[i]), UVM_LOW)
                    end
                end
            end
            DECREASE : begin
                `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)
                `uvm_info(get_type_name(), ("   DECREASE_ORDER_WRITE"), UVM_LOW)
                `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)
                for(i = regs.size() -1; i>=0; i--) begin: next1_reg
                    if(compare_mask[i] != 'h0000_0000) begin
                        if(use_write) begin
                            regs[i].write(status, regs[i].get());
                        end else begin
                            regs[i].update(status);
                        end
                        check_status(1,i);

                        wvalue[i] = regs[i].get();
                        `uvm_info(get_type_name(), $psprintf("\"%s\" : Writing 'h%h", regs[i].get_full_name(), wvalue[i]), UVM_LOW)
                    end
                end
            end

            RANDOM : begin
                `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)
                `uvm_info(get_type_name(), ("   RANDOM_ORDER_WRITE"), UVM_LOW)
                `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)

                //---------------------------------------------------------------
                // push index to the index_queue
                //---------------------------------------------------------------
                for(i=0; i<regs.size(); i++) begin
                    index_queue.push_back(i);
                end

                //---------------------------------------------------------------
                // random order write
                //---------------------------------------------------------------
                for(i=0; i<regs.size(); i++) begin : next2_reg
                    //get random id
                    `uvm_info(get_type_name(), $psprintf("index_queue.size()= %d", index_queue.size()), UVM_FULL)
                    rand_idx = $urandom_range(index_queue.size()-1, 0);
                    id = index_queue[rand_idx];

                    if(compare_mask[id] != 'h0000_0000) begin
                        if(use_write) begin
                            regs[i].write(status, regs[i].get());
                        end else begin
                            regs[i].update(status);
                        end
                        check_status(1,id);

                        wvalue[i] = regs[i].get();
                        `uvm_info(get_type_name(), $psprintf("\"%s\" : Writing 'h%h", regs[i].get_full_name(), wvalue[i]), UVM_LOW)
                    end
                    `uvm_info(get_type_name(), $psprintf("index_queue[%d] = %d", rand_idx, index_queue[rand_idx]), UVM_FULL)
                    index_queue.delete(rand_idx);
                end
            end
        endcase
    endtask


    virtual task read(ref bit [`UVM_REG_DATA_WIDTH-1:0] wvalue[], input bit [`UVM_REG_DATA_WIDTH-1:0] compare_mask[], sec_order_kind_t order_type);
        case (order_type)
            INCREASE : begin
                `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)
                `uvm_info(get_type_name(), ("   INCREASE_ORDER_WRITE"), UVM_LOW)
                `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)
                `uvm_info(get_type_name(), $psprintf("register number is %d", regs.size()), UVM_FULL)
                foreach (regs[i]) begin: next_reg
                    if(compare_mask[i] != 'h0000_0000) begin
                        regs[i].read(status, read_val);
                        read_val = regs[i].get();
                        check_status(0,i);

                        `uvm_info(get_type_name(), $psprintf("\"%s\"", regs[i].get_full_name()), UVM_LOW )
                        //compare read value to write value
                        read_val  = read_val & compare_mask[i];
                        write_val = wvalue[i] & compare_mask[i];
                        check_read_data(compare_mask[i], i);

                        `uvm_info(get_type_name(),"---------------------------------",  UVM_LOW)
                    end
                end
            end
            DECREASE : begin
                `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)
                `uvm_info(get_type_name(), ("   DECREASE_ORDER_WRITE"), UVM_LOW)
                `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)
                `uvm_info(get_type_name(), $psprintf("register number is %d", regs.size()), UVM_LOW)
                for(i = regs.size() -1; i>=0; i--) begin: next1_reg
                    `uvm_info(get_type_name(), $psprintf("compare_mask[%d] = %h", i, compare_mask[i]), UVM_LOW)

                    if(compare_mask[i] != 'h0000_0000) begin
                        `uvm_info(get_type_name(),"---------------------------------",  UVM_LOW)
                        regs[i].read(status, read_val);
                        read_val = regs[i].get();
                        `uvm_info(get_type_name(),"=================================",  UVM_LOW)
                        check_status(0,i);
                        `uvm_info(get_type_name(), $psprintf("\"%s\"", regs[i].get_full_name()), UVM_LOW )
                        //compare read value to write value
                        read_val  = read_val & compare_mask[i];
                        write_val = wvalue[i] & compare_mask[i];
                        check_read_data(compare_mask[i], i);
                        `uvm_info(get_type_name(), $psprintf("----------------------------------------"), UVM_LOW)
                    end
                end
            end

            RANDOM : begin
                `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)
                `uvm_info(get_type_name(), ("   RANDOM_ORDER_WRITE"), UVM_LOW)
                `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)

                //---------------------------------------------------------------
                // push index to the index_queue
                //---------------------------------------------------------------
                for(i=0; i<regs.size(); i++) begin
                    index_queue.push_back(i);
                end

                //---------------------------------------------------------------
                // random order write
                //---------------------------------------------------------------
                for(i=0; i<regs.size(); i++) begin : next2_reg
                    //get random id
                    if(index_queue.size()>0)
                        rand_idx = $urandom_range(index_queue.size()-1,0);
                    else
                        rand_idx = 0;

                    id = index_queue[rand_idx];

                    if(compare_mask[id] != 'h0000_0000) begin
                        `uvm_info(get_type_name(),"---------------------------------",  UVM_LOW)
                        regs[id].read(status, read_val);
                        read_val = regs[id].get();
                        check_status(0,id);

                        `uvm_info(get_type_name(), $psprintf("\"%s\"", regs[i].get_full_name()), UVM_LOW)
                        if(no_err_slave_response_err == 0)begin
                            //compare read value to write value
                            read_val  = read_val & compare_mask[i];
                            write_val = wvalue[i] & compare_mask[i];
                            check_read_data(compare_mask[id], id);
                            `uvm_info(get_type_name(),"---------------------------------",  UVM_LOW)
                        end
                        else
                            `uvm_info(get_full_name(), $psprintf("no_err_slave_response_err = 1 : data checking is skipped ..."), UVM_LOW)
                    end
                    `uvm_info(get_type_name(), $psprintf("index_queue[%d] = %d", rand_idx, index_queue[rand_idx]), UVM_FULL)
                    `uvm_info(get_type_name(), $psprintf("index_queue = %d", index_queue.size()), UVM_FULL)
                    index_queue.delete(rand_idx);
                end
                `uvm_info(get_type_name(), $psprintf("index_queue---------------> empty"), UVM_FULL)
            end
        endcase

    endtask

    // virtual task read_with_bkdoor(ref bit [`UVM_REG_DATA_WIDTH-1:0] wvalue[], input bit [`UVM_REG_DATA_WIDTH-1:0] compare_mask[], sec_order_kind_t order_type);
    //     case (order_type)
    //         INCREASE : begin
    //             `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)
    //             `uvm_info(get_type_name(), ("   INCREASE_ORDER_WRITE"), UVM_LOW)
    //             `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)

    //             `uvm_info(get_type_name(), $psprintf("register number is %d", regs.size()), UVM_FULL)
    //             foreach (regs[i]) begin: next_reg
    //                 if(compare_mask[i] != 'h0000_0000) begin
    //                     regs[i].read(status, read_val);
    //                     read_val = regs[i].get();
    //                     if(status != UVM_IS_OK)
    //                         `uvm_error(get_type_name(), $psprintf(" Status=%n when reading from register \"%s\"", status, regs[i].get_full_name()))

    //                     `uvm_info(get_type_name(), $psprintf("\"%s\"", regs[i].get_full_name()), UVM_LOW)
    //                     //DOING A BACKDOOR READ
    //                     `uvm_info(get_type_name(), $psprintf("DOING BACKDOOR READ ON REGISTER :: %s", regs[i].get_full_name()), UVM_LOW)
    //                     regs[i].read(status, bkdoor_read_val, .path(UVM_BACKDOOR));
    //                     if(status != UVM_IS_OK)
    //                         `uvm_error(get_type_name(), $psprintf(" Status=%n when reading from register through Backdoor\"%s\"", status, regs[i].get_full_name()))
    //                     `uvm_info(get_type_name(), $psprintf("\"%s\"", regs[i].get_full_name()), UVM_LOW)

    //                     //compare read value to write value
    //                     read_val         =   read_val & compare_mask[i];
    //                     write_val        =   wvalue[i] & compare_mask[i];
    //                     bkdoor_read_val  =   bkdoor_read_val & compare_mask[i];

    //                     if(read_val == write_val)
    //                         `uvm_info(get_type_name(), $psprintf(" Match : data = %h (compare_mask = %h)", read_val, compare_mask[i]), UVM_LOW)
    //                     else
    //                         `uvm_error(get_type_name(), $psprintf(" Mismatch : wdata = %h, rdata =%h (compare_mask = %h)", write_val, read_val, compare_mask[i]))

    //                     if(read_val == bkdoor_read_val)
    //                         `uvm_info(get_type_name(), $psprintf(" Match : Frontdoor data = %h Backdoor rdata =%h (compare_mask = %h)", read_val, bkdoor_read_val,compare_mask[i]), UVM_LOW)
    //                     else
    //                         `uvm_error(get_type_name(), $psprintf(" Mismatch : Frontdoor data = %h Backdoor rdata =%h (compare_mask = %h)", read_val, bkdoor_read_val,compare_mask[i]))

    //                     if(read_val == bkdoor_read_val)
    //                         `uvm_info(get_type_name(), $psprintf(" Match : Write Data = %h Backdoor rdata =%h (compare_mask = %h)", write_val, bkdoor_read_val,compare_mask[i]), UVM_LOW)
    //                     else
    //                         `uvm_error(get_type_name(), $psprintf(" Mismatch : Write data = %h, Backdoor rdata =%h (compare_mask = %h)", write_val, bkdoor_read_val,compare_mask[i]))
    //                     `uvm_info(get_type_name(), $psprintf("----------------------------------------"), UVM_LOW)
    //                 end
    //             end
    //         end
    //         DECREASE : begin
    //             `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)
    //             `uvm_info(get_type_name(), ("   DECREASE_ORDER_WRITE"), UVM_LOW)
    //             `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)
    //             `uvm_info(get_type_name(), $psprintf("register number is %d", regs.size()), UVM_LOW)
    //             for(i = regs.size() -1; i>=0; i--) begin: next1_reg
    //                 `uvm_info(get_type_name(), $psprintf("compare_mask[%d] = %h", i, compare_mask[i]), UVM_LOW)

    //                 if(compare_mask[i] != 'h0000_0000) begin
    //                     `uvm_info(get_type_name(),"---------------------------------",  UVM_LOW)
    //                     regs[i].read(status, read_val);
    //                     read_val = regs[i].get();
    //                     `uvm_info(get_type_name(),"=================================",  UVM_LOW)

    //                     if(status != UVM_IS_OK)
    //                         `uvm_error(get_type_name(), $psprintf(" Status=%n :when reading from register \"%s\"", status, regs[i].get_full_name()));
    //                     `uvm_info(get_type_name(), $psprintf("\"%s\"", regs[i].get_full_name()), UVM_LOW)

    //                     // DOING A BACKDOOR READ
    //                     `uvm_info(get_type_name(), $psprint("DOING BACKDOOR READ ON REGISTER :: %s", regs[i].get_full_name()), UVM_LOW)
    //                     regs[i].read(status, bkdoor_read_val, .path(UVM_BACKDOOR));

    //                     if(status != UVM_IS_OK)
    //                         `uvm_error(get_type_name(), $psprintf(" Status=%n :when reading from register through Backdoor \"%s\"", status, regs[i].get_full_name()));
    //                     `uvm_info(get_type_name(), $psprintf("\"%s\"", regs[i].get_full_name()), UVM_LOW)

    //                     //------------------------------------------------------------------------------------
    //                     // compare read value to write value
    //                     //------------------------------------------------------------------------------------
    //                     read_val         =   read_val & compare_mask[i];
    //                     write_val        =   wvalue[i] & compare_mask[i];
    //                     bkdoor_read_val  =   bkdoor_read_val & compare_mask[i];

    //                     if(read_val == write_val)
    //                         `uvm_info(get_type_name(), $psprintf(" Match : data = %h (compare_mask = %h)", read_val, compare_mask[i]), UVM_LOW)
    //                     else
    //                         `uvm_error(get_type_name(), $psprintf(" Mismatch : wdata = %h, rdata =%h (compare_mask = %h)", write_val, read_val, compare_mask[i]))

    //                     if(read_val == bkdoor_read_val)
    //                         `uvm_info(get_type_name(), $psprintf(" Match : Frontdoor data = %h Backdoor rdata =%h (compare_mask = %h)", read_val, bkdoor_read_val,compare_mask[i]), UVM_LOW)
    //                     else
    //                         `uvm_error(get_type_name(), $psprintf(" Mismatch : Frontdoor data = %h Backdoor rdata =%h (compare_mask = %h)", read_val, bkdoor_read_val,compare_mask[i]))

    //                     if(read_val == bkdoor_read_val)
    //                         `uvm_info(get_type_name(), $psprintf(" Match : Write Data = %h Backdoor rdata =%h (compare_mask = %h)", write_val, bkdoor_read_val,compare_mask[i]), UVM_LOW)
    //                     else
    //                         `uvm_error(get_type_name(), $psprintf(" Mismatch : Write data = %h, Backdoor rdata =%h (compare_mask = %h)", write_val, bkdoor_read_val,compare_mask[i]))

    //                     `uvm_info(get_type_name(), $psprintf("----------------------------------------"), UVM_LOW)

    //                     `uvm_info(get_type_name(), $psprintf("----------------------------------------"), UVM_LOW)
    //                 end
    //             end
    //         end

    //         RANDOM : begin
    //             `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)
    //             `uvm_info(get_type_name(), ("   RANDOM_ORDER_WRITE"), UVM_LOW)
    //             `uvm_info(get_type_name(), ("*******************************"), UVM_LOW)

    //             //---------------------------------------------------------------
    //             // push index to the index_queue
    //             //---------------------------------------------------------------
    //             for(i=0; i<regs.size(); i++) begin
    //                 index_queue.push_back(i);
    //             end

    //             //---------------------------------------------------------------
    //             // random order write
    //             //---------------------------------------------------------------
    //             for(i=0; i<regs.size(); i++) begin : next2_reg
    //                 //get random id
    //                 if(index_queue.size()>0)
    //                     rand_idx = $urandom_range(index_queue.size()-1,0);
    //                 else
    //                     rand_idx = 0;

    //                 id = index_queue[rand_idx];

    //                 if(compare_mask[id] != 'h0000_0000) begin
    //                     `uvm_info(get_type_name(),"---------------------------------",  UVM_LOW)
    //                     regs[id].read(status, read_val);
    //                     read_val = regs[id].get();
    //                     if(status != UVM_IS_OK) begin
    //                         if(no_err_slave_response_err == 0)
    //                             `uvm_error(get_type_name(), $psprintf(" Status=%n : when reading from register \"%s\"", status, regs[id].get_full_name()))
    //                         else
    //                             `uvm_info(get_type_name(), $psprintf(" Status=%n : when reading from register \"%s\"", status, regs[id].get_full_name()), UVM_LOW)
    //                     end

    //                     `uvm_info(get_type_name(), $psprintf("\"%s\"", regs[i].get_full_name()), UVM_LOW)
    //                     if(no_err_slave_response_err == 0)begin
    //                         //DOING A BACKDOOR READ
    //                         `uvm_info(get_type_name(), $psprintf("DOING BACKDOOR READ ON REGISTER :: $s", regs[id].get_full_name()), UVM_LOW)
    //                         regs[id].read(status, bkdoor_read_val, .path(UVM_BACKDOOR));

    //                         if(status != UVM_IS_OK)
    //                         `uvm_error(get_type_name(), $psprintf(" Status=%n :when reading from register through Backdoor \"%s\"", status, regs[i].get_full_name()));
    //                         `uvm_info(get_type_name(), $psprintf("\"%s\"", regs[i].get_full_name()), UVM_LOW)

    //                         //------------------------------------------------------------------------------------
    //                         // compare read value to write value
    //                         //------------------------------------------------------------------------------------
    //                         read_val         =   read_val & compare_mask[i];
    //                         write_val        =   wvalue[i] & compare_mask[i];
    //                         bkdoor_read_val  =   bkdoor_read_val & compare_mask[i];

    //                         if(read_val == write_val)
    //                             `uvm_info(get_type_name(), $psprintf(" Match : data = %h (compare_mask = %h)", read_val, compare_mask[i]), UVM_LOW)
    //                         else
    //                             `uvm_error(get_type_name(), $psprintf(" Mismatch : wdata = %h, rdata =%h (compare_mask = %h)", write_val, read_val, compare_mask[i]))

    //                         if(read_val == bkdoor_read_val)
    //                             `uvm_info(get_type_name(), $psprintf(" Match : Frontdoor data = %h Backdoor rdata =%h (compare_mask = %h)", read_val, bkdoor_read_val,compare_mask[i]), UVM_LOW)
    //                         else
    //                             `uvm_error(get_type_name(), $psprintf(" Mismatch : Frontdoor data = %h Backdoor rdata =%h (compare_mask = %h)", read_val, bkdoor_read_val,compare_mask[i]))

    //                         if(read_val == bkdoor_read_val)
    //                             `uvm_info(get_type_name(), $psprintf(" Match : Write Data = %h Backdoor rdata =%h (compare_mask = %h)", write_val, bkdoor_read_val,compare_mask[i]), UVM_LOW)
    //                         else
    //                             `uvm_error(get_type_name(), $psprintf(" Mismatch : Write data = %h, Backdoor rdata =%h (compare_mask = %h)", write_val, bkdoor_read_val,compare_mask[i]))
    //                         `uvm_info(get_type_name(), $psprintf("----------------------------------------"), UVM_LOW)

    //                     end
    //                     else
    //                         `uvm_info(get_type_name(), $psprintf("no_err_slave_response_err = 1 : data checking is skipped ..."), UVM_LOW)
    //                 end
    //                 `uvm_info(get_type_name(), $psprintf("index_queue[%d] = %d", rand_idx, index_queue[rand_idx]), UVM_FULL)
    //                 `uvm_info(get_type_name(), $psprintf("index_queue = %d", index_queue.size()), UVM_FULL)
    //                 index_queue.delete(rand_idx);
    //             end
    //             `uvm_info(get_type_name(), $psprintf("index_queue---------------> empty"), UVM_FULL)
    //         end
    //     endcase
    // endtask

    function set_test_reg_num(int _test_reg_num); // to reduce test_reg_num
        if(regs.size()<_test_reg_num)begin
            this.test_reg_num = regs.size();
        end
        else begin
            this.test_reg_num = _test_reg_num;
            this.is_test_reg_num_given = 1;
        end
    endfunction

    virtual task body();
        if(model == null) begin
            `uvm_error(get_type_name(), "No register model specified to run sequence on")
            return;
        end

        model.reset();
        if(user_defined_regs.size() != 0) begin
            regs = user_defined_regs;
        end
        else begin
            model.get_registers(regs, UVM_NO_HIER);
        end
    endtask: body

endclass
`endif // SFR_RW_TEST_BASE_C

`ifndef HW_RESET_TEST_C
`define HW_RESET_TEST_C
class hw_reset_test_c extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));
    uvm_reg regs[$];

    bit [`UVM_REG_DATA_WIDTH-1:0] reset_mask[];
    bit [`UVM_REG_DATA_WIDTH-1:0] read_val;
    bit [`UVM_REG_DATA_WIDTH-1:0] mirror_val;

    uvm_status_e status;
    int i;

    `uvm_object_utils_begin(hw_reset_test_c)
    `uvm_object_utils_end

    function new(string name ="hw_reset_test_c");
        super.new(name);
    endfunction

    virtual task run();
        `uvm_info(get_type_name(), ("**************************************"), UVM_LOW);
        `uvm_info(get_type_name(), ("       HW_RESET_TEST"), UVM_LOW);
        `uvm_info(get_type_name(), ("**************************************"), UVM_LOW);
        for(i=0; i<regs.size(); i++) begin
            mirror_val = regs[i].get();
            // if($test$plusargs("WDT0_IMEM") && (regs[i].get_name()=="wtdat" || regs[i].get_name()=="wtcnt"))begin
            //     mirror_val = 32'h0005_9000;
            // end
            if(reset_mask[i] != 'h0000_0000)begin
                `uvm_info(get_type_name(), $psprintf("\"%s\" : ...Reset testing", regs[i].get_full_name()), UVM_LOW);
                regs[i].read(status, read_val);
                if(status != UVM_IS_OK)
                    `uvm_error(get_type_name(), $psprintf(" Status=%n : when reading from register \"%s\"", status, regs[i].get_full_name()));

                if((mirror_val&reset_mask[i]) !=(read_val&reset_mask[i]))
                    `uvm_error(get_type_name(), $psprintf(" Mismatch : reset_v(DUT) = %h, reset_v(Mirror)= %h (reset_mask = %h)", read_val, mirror_val, reset_mask[i]));
            end
            else
                `uvm_info(get_type_name(), $psprintf("\"%s\": Reset test is skipped", regs[i].get_full_name()), UVM_LOW);
        end
        `uvm_info(get_type_name(), ("**************************************"), UVM_LOW);
        `uvm_info(get_type_name(), (" HW_RESET_TEST is successfully done !!"), UVM_LOW);
        `uvm_info(get_type_name(), ("**************************************"), UVM_LOW);
    endtask

endclass
`endif //HW_RESET_TEST_C
