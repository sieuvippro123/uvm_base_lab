`ifndef __VIP_SIG_MNT_AGENT__
`define __VIP_SIG_MNT_AGENT__

class vip_sig_mnt_agent extends uvm_agent;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    vip_sig_mnt_drv     _drv    ;
    vip_sig_mnt_seqr    _seqr   ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_utils(vip_sig_mnt_agent)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "vip_sig_mnt_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //  Build phase
    //  Arguments
    //      phase   : UVM phasing object
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        _drv    = vip_sig_mnt_drv   ::type_id::create("_drv"    , this);
        _seqr   = vip_sig_mnt_seqr  ::type_id::create("_seqr"   , this);
    endfunction

    //  Connect phase
    //  Arguments
    //      phase   : UVM phasing object
    function void connect_phase(uvm_phase phase);
        virtual vip_sig_mnt_intf    _intf   ;

        super.connect_phase(phase);
        _drv.seq_item_port.connect(_seqr.seq_item_export);

        if(!uvm_config_db#(virtual vip_sig_mnt_intf)::get(this, "", "_intf", _intf))
            `uvm_fatal (get_full_name(), "Signal monitor interface is not set")
        else
            _drv._intf  = _intf;

    endfunction

endclass

`endif
