`ifndef __VIP_CLKRST_AGENT__
`define __VIP_CLKRST_AGENT__

class vip_clkrst_agent extends uvm_agent;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    vip_clkrst_drv  _drv    ;
    vip_clkrst_seqr _seqr   ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_utils(vip_clkrst_agent)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "vip_clkrst_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //  Build phase
    //  Arguments
    //      phase   : UVM phasing object
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        _drv    = vip_clkrst_drv    ::type_id::create("_drv"    , this);
        _seqr   = vip_clkrst_seqr   ::type_id::create("_seqr"   , this);
    endfunction

    //  Connect phase
    //  Arguments
    //      phase   : UVM phasing object
    function void connect_phase(uvm_phase phase);
        virtual vip_clkrst_intf _intf   ;
        super.connect_phase(phase);

        if(!uvm_config_db#(virtual vip_clkrst_intf)::get(this, "", "_intf", _intf))
            `uvm_fatal (get_full_name(), "Clock/Reset interface is not set");

        _drv._intf  = _intf;
        _drv.seq_item_port.connect(_seqr.seq_item_export);

    endfunction

    //  UVM run phase
    //  Arguments
    //      phase   : UVM phasing object
    task run_phase(uvm_phase phase);
        uvm_report_info(get_full_name(), $psprintf("I am %s", get_name()), UVM_NONE);
    endtask

endclass

`endif
