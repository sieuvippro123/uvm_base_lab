`ifndef __VIP_APB_MSTR_WRITE__
`define __VIP_APB_MSTR_WRITE__

class vip_apb_mstr_write #(
    parameter   P_ADDR_WIDTH    = 8,
    parameter   P_DATA_WIDTH    = 32
) extends uvm_sequence #(
    vip_apb_mstr_trans#(P_ADDR_WIDTH, P_DATA_WIDTH   )
);
    //-------------------------------------------------------------------------
    //  Local parameter
    //-------------------------------------------------------------------------
    localparam  P_STRB_WIDTH    = P_DATA_WIDTH / 8;
    localparam  P_PROT_WIDTH    = 2;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    rand    bit [ P_ADDR_WIDTH  - 1 : 0 ]   _addr   ;
    rand    bit [ P_PROT_WIDTH  - 1 : 0 ]   _prot   ;
    rand    bit [ P_DATA_WIDTH  - 1 : 0 ]   _data   ;
    rand    bit [ P_STRB_WIDTH  - 1 : 0 ]   _strb   ;
    logic                                   _resp   ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_param_utils(vip_apb_mstr_write#(P_ADDR_WIDTH, P_DATA_WIDTH))

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_apb_mstr_write");
        super.new(name);
        _addr   = '0;
        _prot   = '0;
        _data   = '0;
        _strb   = '1;
    endfunction

    //  Body
    //  Arguments   : None
    virtual task body();
        vip_apb_mstr_trans#(P_ADDR_WIDTH, P_DATA_WIDTH) _item   ;

        `uvm_do_with(_item, {
            _trans          == APB_WRITE;
            _trans_addr     == _addr    ;
            _trans_prot     == _prot    ;
            _trans_wdata    == _data    ;
            _trans_strb     == _strb    ;
        } )
        _resp   = _item._trans_resp ;

    endtask

endclass

`endif
