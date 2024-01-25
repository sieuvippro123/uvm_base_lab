`ifndef __VIP_CLKRST_ASSERT_RESET__
`define __VIP_CLKRST_ASSERT_RESET__

class vip_clkrst_assert_reset extends uvm_sequence#(vip_clkrst_action);
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(vip_clkrst_assert_reset)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_clkrst_assert_reset");
        super.new(name);
    endfunction

    //  Body
    //  Arguments   : None
    virtual task body();
        vip_clkrst_action   _item   ;

        `uvm_do_with(_item, { _action == RST_ASSERT; } )

    endtask

endclass

`endif
