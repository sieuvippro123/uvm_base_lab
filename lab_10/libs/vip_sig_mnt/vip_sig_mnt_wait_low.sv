`ifndef __VIP_SIG_MNT_WAIT_LOW__
`define __VIP_SIG_MNT_WAIT_LOW__

class vip_sig_mnt_wait_low extends vip_sig_mnt_get_level;
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(vip_sig_mnt_wait_low)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_sig_mnt_wait_low");
        super.new(name);
        _cmd    = WAIT_LOW;
    endfunction

endclass

`endif
