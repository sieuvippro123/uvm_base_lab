`ifndef __VIP_CLKRST_ACTION__
`define __VIP_CLKRST_ACTION__

class vip_clkrst_action extends uvm_sequence_item;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    rand    ENU_CLKRST_ACTION   _action     ;
    rand    time                _value      ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils_begin(vip_clkrst_action)
        `uvm_field_enum ( ENU_CLKRST_ACTION, _action, UVM_ALL_ON    )
        `uvm_field_int  (                    _value , UVM_ALL_ON    )
    `uvm_object_utils_end

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_clkrst_action");
        super.new(name);
    endfunction

endclass

`endif
