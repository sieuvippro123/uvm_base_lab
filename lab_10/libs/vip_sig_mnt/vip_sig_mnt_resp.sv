`ifndef __VIP_SIG_MNT_RESP__
`define __VIP_SIG_MNT_RESP__

class vip_sig_mnt_resp extends uvm_sequence_item;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    logic   _sig_val;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils_begin(vip_sig_mnt_resp)
        `uvm_field_int  (   _sig_val    ,   UVM_ALL_ON  )
    `uvm_object_utils_end

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_sig_mnt_resp");
        super.new(name);
    endfunction

endclass

`endif
