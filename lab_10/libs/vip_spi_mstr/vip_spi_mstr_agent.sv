`ifndef __VIP_SPI_MSTR_AGENT__
`define __VIP_SPI_MSTR_AGENT__

class vip_spi_mstr_agent extends uvm_agent;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    vip_spi_mstr_drv    _drv    ;
    vip_spi_mstr_seqr   _seqr   ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_param_utils(vip_spi_mstr_agent)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "vip_spi_mstr_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //  Build phase
    //  Arguments
    //      phase   : UVM phasing object
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        _drv    =  vip_spi_mstr_drv::type_id::create("_drv"   , this);
        _seqr   = vip_spi_mstr_seqr::type_id::create("_seqr"  , this);
    endfunction

    //  Connect phase
    //  Arguments
    //      phase   : UVM phasing object
    function void connect_phase(uvm_phase phase);
        virtual vip_spi_intf    _intf   ;

        super.connect_phase(phase);
        _drv.seq_item_port.connect(_seqr.seq_item_export);

        if(!uvm_config_db#(virtual vip_spi_intf)::get(this, "", "_intf", _intf))
            `uvm_fatal (get_full_name(), "SPI interface is not set")
        else
            _drv._intf  = _intf;

    endfunction

endclass

`endif
