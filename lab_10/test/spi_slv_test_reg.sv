`ifndef __SPI_SLV_TEST_REG__
`define __SPI_SLV_TEST_REG__

class spi_slv_test_reg extends spi_slv_test;
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_utils(spi_slv_test_reg)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "spi_slv_test_reg", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //  UVM run phase
    //  Arguments
    //      phase   : UVM phasing object
    task run_phase(uvm_phase phase);
        vip_clkrst_bseq                 _clk_seq    ;
        uvm_status_e                    _reg_status ;
        uvm_reg_data_t                  _read_data  ;
        spi_slv_msg_demoter             _demoter    ;

        phase.raise_objection(this);
        _clk_seq    = vip_clkrst_bseq::type_id::create("_clk_seq");

        _clk_seq.start(_env._clkrst_agent._seqr);
        _env._reg_model.reset();
        #100ns;

        _demoter    = spi_slv_msg_demoter::type_id::create("_demoter");
        uvm_report_cb::add(null, _demoter);
        _env._reg_model._sreset.write(_reg_status, 1);
        uvm_report_info("_sreset", $psprintf("Front-door write data = %0x", 1), UVM_NONE);
        #10ns;
        _env._reg_model._sreset.read(_reg_status, _read_data);
        uvm_report_info("_sreset", $psprintf("Front-door read data = %0x", _read_data), UVM_NONE);
        #10ns;
        _env._reg_model._sreset.write(_reg_status, 0, UVM_BACKDOOR);
        uvm_report_info("_sreset", $psprintf("Back-door write data = %0x", 0), UVM_NONE);
        #10ns;
        uvm_report_cb::delete(null, _demoter);
        _env._reg_model._sreset.read(_reg_status, _read_data);
        uvm_report_info("_sreset", $psprintf("Front-door read data = %0x", _read_data), UVM_NONE);
        #10ns;
        _env._reg_model._sreset.read(_reg_status, _read_data, UVM_BACKDOOR);
        uvm_report_info("_sreset", $psprintf("Back-door read data = %0x", _read_data), UVM_NONE);
        #10ns;
        _env._reg_model._sreset.write(_reg_status, 1);
        uvm_report_info("_sreset", $psprintf("Front-door write data = %0x", 1), UVM_NONE);
        #10ns;
        _env._reg_model._sreset.read(_reg_status, _read_data);
        uvm_report_info("_sreset", $psprintf("Front-door read data = %0x", _read_data), UVM_NONE);
        #10ns;
        _env._reg_model._intctrl.write(_reg_status, 8'h11, UVM_BACKDOOR);
        uvm_report_info("_intctrl", $psprintf("Back-door write data = %0x", 8'h11), UVM_NONE);
        #10ns;
        _env._reg_model._intctrl.read(_reg_status, _read_data);
        uvm_report_info("_intctrl", $psprintf("Front-door read data = %0x", _read_data), UVM_NONE);
        #10ns;
        _env._reg_model._status.write(_reg_status, 8'hFF, UVM_BACKDOOR);
        uvm_report_info("_status", $psprintf("Back-door write data = %0x", 8'hFF), UVM_NONE);
        #10ns;
        _env._reg_model._status.read(_reg_status, _read_data);
        uvm_report_info("_status", $psprintf("Front-door read data = %0x", _read_data), UVM_NONE);
        #10ns;
        _env._reg_model._status.read(_reg_status, _read_data, UVM_BACKDOOR);
        uvm_report_info("_status", $psprintf("Back-door read data = %0x", _read_data), UVM_NONE);
        #10ns;
        _env._reg_model._txstart.write(_reg_status, 8'hFF);
        uvm_report_info("_txstart", $psprintf("Front-door write data = %0x", 8'hFF), UVM_NONE);
        #10ns;
        _env._reg_model._txstart.mirror(_reg_status, UVM_CHECK, UVM_FRONTDOOR);
        #11ns;
        _env._reg_model._txstart.write(_reg_status, 8'hFF, UVM_BACKDOOR);
        uvm_report_info("_txstart", $psprintf("Back-door write data = %0x", 8'hFF), UVM_NONE);
        #10ns;
        _env._reg_model._txstart.mirror(_reg_status, UVM_CHECK, UVM_FRONTDOOR);
        #10ns;

        #100ns;
        phase.drop_objection(this);

    endtask

endclass

`endif
