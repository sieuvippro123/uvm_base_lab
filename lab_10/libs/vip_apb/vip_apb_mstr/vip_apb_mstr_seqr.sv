`ifndef __VIP_APB_MSTR_SEQR__
`define __VIP_APB_MSTR_SEQR__

class vip_apb_mstr_seqr #(
    parameter   P_ADDR_WIDTH    = 8,
    parameter   P_DATA_WIDTH    = 32
) extends uvm_sequencer #(
    vip_apb_mstr_trans#(P_ADDR_WIDTH, P_DATA_WIDTH   )
);
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_param_utils(vip_apb_mstr_seqr#(P_ADDR_WIDTH, P_DATA_WIDTH))

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "vip_apb_mstr_seqr", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass

`endif
