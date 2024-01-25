`ifndef __VIP_CLKRST_START_CLK__
`define __VIP_CLKRST_START_CLK__

class vip_clkrst_start_clk extends uvm_sequence#(vip_clkrst_action);
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(vip_clkrst_start_clk)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_clkrst_start_clk");
        super.new(name);
    endfunction

    //  Body
    //  Arguments   : None
    virtual task body();
        vip_clkrst_action   _item   ;

        `uvm_do_with(_item, { _action == CLK_START; } )

    endtask

endclass

`endif
