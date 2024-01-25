`ifndef __VIP_SIG_MNT_WAIT_FALL__
`define __VIP_SIG_MNT_WAIT_FALL__

class vip_sig_mnt_wait_fall extends vip_sig_mnt_get_level;
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(vip_sig_mnt_wait_fall)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_sig_mnt_wait_fall");
        super.new(name);
        _cmd    = WAIT_FALL;
    endfunction

endclass

`endif
