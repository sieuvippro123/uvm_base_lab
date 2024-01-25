`ifndef __VIP_APB_MSTR_TRANS__
`define __VIP_APB_MSTR_TRANS__

class vip_apb_mstr_trans #(
    parameter   P_ADDR_WIDTH    = 8,
    parameter   P_DATA_WIDTH    = 32
) extends uvm_sequence_item;
    //-------------------------------------------------------------------------
    //  Local parameters
    //-------------------------------------------------------------------------
    localparam  P_PROT_WIDTH    = 3;
    localparam  P_STRB_WIDTH    = P_DATA_WIDTH / 8;

    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    rand    ENU_APB_TRANS                   _trans      ;
    rand    bit [ P_ADDR_WIDTH  - 1 : 0 ]   _trans_addr ;
    rand    bit [ P_PROT_WIDTH  - 1 : 0 ]   _trans_prot ;
    rand    bit [ P_DATA_WIDTH  - 1 : 0 ]   _trans_wdata;
    rand    bit [ P_STRB_WIDTH  - 1 : 0 ]   _trans_strb ;
    logic                                   _trans_resp ;
    logic       [ P_DATA_WIDTH  - 1 : 0 ]   _trans_rdata;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_param_utils_begin(vip_apb_mstr_trans#(P_ADDR_WIDTH, P_DATA_WIDTH))
        `uvm_field_enum ( ENU_APB_TRANS ,   _trans      , UVM_ALL_ON    )
        `uvm_field_int  (                   _trans_addr , UVM_ALL_ON    )
        `uvm_field_int  (                   _trans_prot , UVM_ALL_ON    )
        `uvm_field_int  (                   _trans_wdata, UVM_ALL_ON    )
        `uvm_field_int  (                   _trans_strb , UVM_ALL_ON    )
        `uvm_field_int  (                   _trans_resp , UVM_ALL_ON    )
        `uvm_field_int  (                   _trans_rdata, UVM_ALL_ON    )
    `uvm_object_utils_end

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_apb_mstr_trans");
        super.new(name);
    endfunction

endclass

`endif
