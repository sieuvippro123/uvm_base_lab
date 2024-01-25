`ifndef __VIP_CLKRST_CHANGE_DUTY__
`define __VIP_CLKRST_CHANGE_DUTY__

class vip_clkrst_change_duty extends uvm_sequence#(vip_clkrst_action);
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    rand    int     _duty   ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(vip_clkrst_change_duty)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_clkrst_change_duty");
        super.new(name);
    endfunction

    //  Body
    //  Arguments   : None
    virtual task body();
        vip_clkrst_action   _item   ;

        `uvm_do_with(_item, { _action == CHG_DUTY; _value == _duty; } )

    endtask

endclass

`endif
