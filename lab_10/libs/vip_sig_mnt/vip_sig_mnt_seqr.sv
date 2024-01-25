`ifndef __VIP_SIG_MNT_SEQR__
`define __VIP_SIG_MNT_SEQR__

class vip_sig_mnt_seqr extends uvm_sequencer #(vip_sig_mnt_cmd, vip_sig_mnt_resp);
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_utils(vip_sig_mnt_seqr)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "vip_sig_mnt_seqr", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
endclass

`endif
