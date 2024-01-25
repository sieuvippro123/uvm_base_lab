`ifndef __SPI_SLV_APB_MSTR_AGENT__
`define __SPI_SLV_APB_MSTR_AGENT__

class spi_slv_apb_mstr_agent extends spi_slv_mstr_AGENT;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    spi_slv_apb_mnt _mon    ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_utils(spi_slv_apb_mstr_agent)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "spi_slv_apb_mstr_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //  Build phase
    //  Arguments
    //      phase   : UVM phasing object
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        _mon = spi_slv_apb_mnt::type_id::create("_mon", this);
    endfunction

    //  Connect phase
    //  Arguments
    //      phase   : UVM phasing object
    function void connect_phase(uvm_phase phase);
        virtual vip_apb_intf#(3, 8)     _intf_apb   ;
        virtual vip_spi_intf            _intf_spi   ;
        virtual vip_sig_mnt_intf        _intf_int   ; 

        super.connect_phase(phase);

        if(!uvm_config_db#(virtual vip_apb_intf#(3, 8))::get(this, "", "_intf", _intf_apb))
            `uvm_fatal (get_full_name(), "APB interface is not set")
        else
            _mon._intf_apb  = _intf_apb;

        if(!uvm_config_db#(virtual vip_spi_intf)::get(this, "", "_intf_spi", _intf_spi))
            `uvm_fatal (get_full_name(), "SPI interface is not set")
        else
            _mon._intf_spi  = _intf_spi;

        if(!uvm_config_db#(virtual vip_sig_mnt_intf)::get(this, "", "_intf_int", _intf_int))
            `uvm_fatal (get_full_name(), "Interrupt interface is not set")
        else
            _mon._intf_int  = _intf_int;

    endfunction

endclass

`endif
