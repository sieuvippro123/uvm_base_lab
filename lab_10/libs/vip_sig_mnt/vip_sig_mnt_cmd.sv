`ifndef __VIP_SIG_MNT_CMD__
`define __VIP_SIG_MNT_CMD__

class vip_sig_mnt_cmd extends uvm_sequence_item;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    rand    ENU_SIG_MNT_CMD     _command;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils_begin(vip_sig_mnt_cmd)
        `uvm_field_enum ( ENU_SIG_MNT_CMD, _command , UVM_ALL_ON    )
    `uvm_object_utils_end

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_sig_mnt_cmd");
        super.new(name);
    endfunction

endclass

`endif
