`ifndef __VIP_APB_MSTR_AGENT__
`define __VIP_APB_MSTR_AGENT__

class vip_apb_mstr_agent #(
    parameter   P_ADDR_WIDTH    = 8,
    parameter   P_DATA_WIDTH    = 32
) extends uvm_agent;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    vip_apb_mstr_drv    #(P_ADDR_WIDTH, P_DATA_WIDTH)                       _drv        ;
    vip_apb_mstr_seqr   #(P_ADDR_WIDTH, P_DATA_WIDTH)                       _seqr       ;
    uvm_analysis_port   #(vip_apb_mstr_trans#(P_ADDR_WIDTH, P_DATA_WIDTH))  _trans_ap   ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_param_utils(vip_apb_mstr_agent#(P_ADDR_WIDTH, P_DATA_WIDTH))

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "vip_apb_mstr_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //  Build phase
    //  Arguments
    //      phase   : UVM phasing object
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        _drv        = vip_apb_mstr_drv #(P_ADDR_WIDTH, P_DATA_WIDTH)::type_id::create("_drv"   , this);
        _seqr       = vip_apb_mstr_seqr#(P_ADDR_WIDTH, P_DATA_WIDTH)::type_id::create("_seqr"  , this);
        _trans_ap   = new("_trans_ap"   , this  );
    endfunction

    //  Connect phase
    //  Arguments
    //      phase   : UVM phasing object
    function void connect_phase(uvm_phase phase);
        virtual vip_apb_intf#(P_ADDR_WIDTH, P_DATA_WIDTH)   _intf   ;

        super.connect_phase(phase);
        _drv.seq_item_port  .connect(_seqr.seq_item_export);
        _drv._trans_ap      .connect(_trans_ap);

        if(!uvm_config_db#(virtual vip_apb_intf#(P_ADDR_WIDTH, P_DATA_WIDTH))::get(this, "", "_intf", _intf))
            `uvm_fatal ("APB_INTF_UNSET", "APB interface is not set")
        else
            _drv._intf = _intf;

    endfunction

endclass

`endif
