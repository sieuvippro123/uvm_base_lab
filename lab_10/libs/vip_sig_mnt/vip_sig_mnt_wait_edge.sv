`ifndef __VIP_SIG_MNT_WAIT_EDGE__
`define __VIP_SIG_MNT_WAIT_EDGE__

class vip_sig_mnt_wait_edge extends vip_sig_mnt_get_level;
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(vip_sig_mnt_wait_edge)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_sig_mnt_wait_edge");
        super.new(name);
        _cmd    = WAIT_EDGE;
    endfunction

endclass

`endif
