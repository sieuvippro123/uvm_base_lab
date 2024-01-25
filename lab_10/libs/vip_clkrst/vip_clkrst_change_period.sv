`ifndef __VIP_CLKRST_CHANGE_PERIOD__
`define __VIP_CLKRST_CHANGE_PERIOD__

class vip_clkrst_change_period extends uvm_sequence#(vip_clkrst_action);
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    rand    time        _period;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(vip_clkrst_change_period)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_clkrst_change_period");
        super.new(name);
    endfunction

    //  Body
    //  Arguments   : None
    virtual task body();
        vip_clkrst_action   _item   ;

        `uvm_do_with(_item, { _action == CHG_PERIOD; _value == _period; } )

    endtask

endclass

`endif
