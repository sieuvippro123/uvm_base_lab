`ifndef __VIP_APB_MSTR_READ__
`define __VIP_APB_MSTR_READ__

class vip_apb_mstr_read #(
    parameter   P_ADDR_WIDTH    = 8,
    parameter   P_DATA_WIDTH    = 32
) extends uvm_sequence #(
    vip_apb_mstr_trans#(P_ADDR_WIDTH, P_DATA_WIDTH   )
);
    //-------------------------------------------------------------------------
    //  Local parameter
    //-------------------------------------------------------------------------
    localparam  P_PROT_WIDTH    = 2;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    rand    bit [ P_ADDR_WIDTH  - 1 : 0 ]   _addr   ;
    rand    bit [ P_PROT_WIDTH  - 1 : 0 ]   _prot   ;
    logic                                   _resp   ;
    logic                                   _data   ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_param_utils(vip_apb_mstr_read#(P_ADDR_WIDTH, P_DATA_WIDTH))

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_apb_mstr_read");
        super.new(name);
    endfunction

    //  Body
    //  Arguments   : None
    virtual task body();
        vip_apb_mstr_trans#(P_ADDR_WIDTH, P_DATA_WIDTH) _item   ;

        `uvm_do_with(_item, {
            _trans      == APB_READ ;
            _trans_addr == _addr    ;
            _trans_prot == _prot    ;
        } )
        _resp   = _item._trans_resp ;
        _data   = _item._trans_rdata;

    endtask

endclass

`endif
