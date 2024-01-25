`ifndef __VIP_SIG_MNT_GET_LEVEL__
`define __VIP_SIG_MNT_GET_LEVEL__

class vip_sig_mnt_get_level extends uvm_sequence#(vip_sig_mnt_cmd, vip_sig_mnt_resp);
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    logic               _value  ;
    ENU_SIG_MNT_CMD     _cmd    ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(vip_sig_mnt_get_level)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_sig_mnt_get_level");
        super.new(name);
        _cmd    = GET_LEVEL;
        _value  = 0;
    endfunction

    //  Body
    //  Arguments   : None
    virtual task body();
        vip_sig_mnt_cmd     _trans_cmd  ;
        vip_sig_mnt_resp    _trans_resp ;

        `uvm_do_with(_trans_cmd, { _command == _cmd; } )
        get_response(_trans_resp);
        _value  = _trans_resp._sig_val;

    endtask

endclass

`endif
