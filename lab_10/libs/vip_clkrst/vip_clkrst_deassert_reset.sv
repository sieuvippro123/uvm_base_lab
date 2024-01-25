`ifndef __VIP_CLKRST_DEASSERT_RESET__
`define __VIP_CLKRST_DEASSERT_RESET__

class vip_clkrst_deassert_reset extends uvm_sequence#(vip_clkrst_action);
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(vip_clkrst_deassert_reset)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_clkrst_deassert_reset");
        super.new(name);
    endfunction

    //  Body
    //  Arguments   : None
    virtual task body();
        vip_clkrst_action   _item   ;

        `uvm_do_with(_item, { _action == RST_DEASSERT; } )

    endtask

endclass

`endif
