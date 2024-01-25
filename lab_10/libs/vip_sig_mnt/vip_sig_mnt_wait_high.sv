`ifndef __VIP_SIG_MNT_WAIT_HIGH__
`define __VIP_SIG_MNT_WAIT_HIGH__

class vip_sig_mnt_wait_high extends vip_sig_mnt_get_level;
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(vip_sig_mnt_wait_high)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_sig_mnt_wait_high");
        super.new(name);
        _cmd    = WAIT_HIGH;
    endfunction

endclass

`endif
