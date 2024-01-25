`ifndef __VIP_SIG_MNT_WAIT_RISE__
`define __VIP_SIG_MNT_WAIT_RISE__

class vip_sig_mnt_wait_rise extends vip_sig_mnt_get_level;
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(vip_sig_mnt_wait_rise)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_sig_mnt_wait_rise");
        super.new(name);
        _cmd    = WAIT_RISE;
    endfunction

endclass

`endif
