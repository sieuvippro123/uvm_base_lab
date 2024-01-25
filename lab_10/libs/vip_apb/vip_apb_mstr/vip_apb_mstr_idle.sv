`ifndef __VIP_APB_MSTR_IDLE__
`define __VIP_APB_MSTR_IDLE__

class vip_apb_mstr_idle #(
    parameter   P_ADDR_WIDTH    = 8,
    parameter   P_DATA_WIDTH    = 32
) extends uvm_sequence #(
    vip_apb_mstr_trans#(P_ADDR_WIDTH, P_DATA_WIDTH   )
);
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    rand    int     _cycle  ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_param_utils(vip_apb_mstr_idle#(P_ADDR_WIDTH, P_DATA_WIDTH))

    //-------------------------------------------------------------------------
    //  Constraints
    //-------------------------------------------------------------------------
    constraint  MIN_CYCLE   { _cycle > 0; }

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_apb_mstr_idle");
        super.new(name);
        _cycle = 1;
    endfunction

    //  Body
    //  Arguments   : None
    virtual task body();
        vip_apb_mstr_trans#(P_ADDR_WIDTH, P_DATA_WIDTH)  _item   ;

        `uvm_do_with(_item, { _trans == APB_IDLE; _trans_wdata == _cycle; } )

    endtask

endclass

`endif
