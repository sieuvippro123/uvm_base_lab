`ifndef __SPI_SLV_ENV__
`define __SPI_SLV_ENV__

class spi_slv_env extends uvm_env;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    vip_clkrst_agent                                    _clkrst_agent       ;
    vip_sig_mnt_agent                                   _int_mnt_agent      ;
    vip_sig_mnt_agent                                   _txreq_mnt_agent    ;
    vip_sig_mnt_agent                                   _rxbusy_mnt_agent   ;
    vip_spi_mstr_agent                                  _spi_mstr_agent     ;
    spi_slv_mstr::AGENT                                 _apb_mstr_agent     ;
    spi_slv_scrb#(vip_spi_mstr_req)                     _spi_send_scrb      ;
    spi_slv_scrb#(vip_spi_mstr_resp)                    _spi_recv_scrb      ;
    spi_slv_sb                                          _spi_slv_sb         ;
    spi_slv_reg_blk                                     _reg_model          ;
    spi_slv_reg_adapter                                 _adapter            ;
    uvm_reg_predictor#(vip_apb_mstr_trans#(3, 8))       _predictor          ;
    spi_slv_seqr                                        _vseqr              ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_utils(spi_slv_env)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "spi_slv_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //  Build phase
    //  Arguments
    //      phase   : UVM phasing object
    function void build_phase(uvm_phase phase);
        virtual vip_clkrst_intf     _intf_clkrst;
        virtual vip_sig_mnt_intf    _intf_int   ;
        virtual vip_sig_mnt_intf    _intf_txreq ;
        virtual vip_sig_mnt_intf    _intf_rxbusy;
        virtual vip_spi_intf        _intf_spi   ;
        virtual vip_apb_intf#(3, 8) _intf_apb   ;
        super.build_phase(phase);

        //  Type override
        spi_slv_mstr::AGENT::type_id::set_type_override(spi_slv_apb_mstr_agent::get_type());

        //  Create sub-blocks
        _clkrst_agent       = vip_clkrst_agent                          ::type_id::create("_clkrst_agent"       , this  );
        _int_mnt_agent      = vip_sig_mnt_agent                         ::type_id::create("_int_mnt_agent"      , this  );
        _txreq_mnt_agent    = vip_sig_mnt_agent                         ::type_id::create("_txreq_mnt_agent"    , this  );
        _rxbusy_mnt_agent   = vip_sig_mnt_agent                         ::type_id::create("_rxbusy_mnt_agent"   , this  );
        _spi_mstr_agent     = vip_spi_mstr_agent                        ::type_id::create("_spi_mstr_agent"     , this  );
        _apb_mstr_agent     = spi_slv_mstr::AGENT                       ::type_id::create("_apb_mstr_agent"     , this  );
        _spi_send_scrb      = spi_slv_scrb#(vip_spi_mstr_req)           ::type_id::create("_spi_send_scrb"      , this  );
        _spi_recv_scrb      = spi_slv_scrb#(vip_spi_mstr_resp)          ::type_id::create("_spi_recv_scrb"      , this  );
        _spi_slv_sb         = spi_slv_sb                                ::type_id::create("_spi_slv_sb"         , this  );
        _reg_model          = spi_slv_reg_blk                           ::type_id::create("_reg_model"                  );
        _adapter            = spi_slv_reg_adapter                       ::type_id::create("_adapter"                    );
        _predictor          = uvm_reg_predictor#(spi_slv_mstr::TRANS)   ::type_id::create("_predictor"          , this  );
        _vseqr              = spi_slv_seqr                              ::type_id::create("_vseqr"              , this  );

        _reg_model.build();
        _reg_model.lock_model();
        _reg_model.set_hdl_path_root("$root.spi_slv_top._spi_slv.apbctrl");

        //  Configuration
        uvm_config_db#(string)::set(_spi_send_scrb, "", "_report_file", "./spi_send.log");
        uvm_config_db#(string)::set(_spi_recv_scrb, "", "_report_file", "./spi_recv.log");

        //  Virtual interface mapping: _vip_clkrst_intf
        if(!uvm_config_db#(virtual vip_clkrst_intf)     ::get(null, "uvm_test_top", "_intf_clkrst", _intf_clkrst))
            `uvm_fatal (get_full_name(), "Clock/Reset interface is not set")
        uvm_config_db#(virtual vip_clkrst_intf)         ::set(_clkrst_agent, "", "_intf", _intf_clkrst);

        //  Virtual interface mapping: _intf_int
        if(!uvm_config_db#(virtual vip_sig_mnt_intf)    ::get(null, "uvm_test_top", "_intf_int", _intf_int))
            `uvm_fatal (get_full_name(), "INT monitor interface is not set")
        uvm_config_db#(virtual vip_sig_mnt_intf)        ::set(_int_mnt_agent, "", "_intf", _intf_int);

        //  Virtual interface mapping: _intf_txreq
        if(!uvm_config_db#(virtual vip_sig_mnt_intf)    ::get(null, "uvm_test_top", "_intf_txreq", _intf_txreq))
            `uvm_fatal (get_full_name(), "TX_REQ monitor interface is not set")
        uvm_config_db#(virtual vip_sig_mnt_intf)        ::set(_txreq_mnt_agent, "", "_intf", _intf_txreq);

        //  Virtual interface mapping: _intf_rxbusy
        if(!uvm_config_db#(virtual vip_sig_mnt_intf)    ::get(null, "uvm_test_top", "_intf_rxbusy", _intf_rxbusy))
            `uvm_fatal (get_full_name(), "RX_BUSY monitor interface is not set")
        uvm_config_db#(virtual vip_sig_mnt_intf)        ::set(_rxbusy_mnt_agent, "", "_intf", _intf_rxbusy);

        //  Virtual interface mapping: _intf_spi
        if(!uvm_config_db#(virtual vip_spi_intf)        ::get(null, "uvm_test_top", "_intf_spi", _intf_spi))
            `uvm_fatal (get_full_name(), "TX_REQ monitor interface is not set")
        uvm_config_db#(virtual vip_spi_intf)            ::set(_spi_mstr_agent, "", "_intf", _intf_spi);

        //  Virtual interface mapping: _intf_apb
        if(!uvm_config_db#(virtual vip_apb_intf#(3, 8)) ::get(null, "uvm_test_top", "_intf_apb", _intf_apb))
            `uvm_fatal (get_full_name(), "APB interface is not set")
        uvm_config_db#(virtual vip_apb_intf#(3, 8))     ::set(_apb_mstr_agent, "", "_intf", _intf_apb);
        uvm_config_db#(virtual vip_spi_intf)            ::set(_apb_mstr_agent, "", "_intf_spi"  , _intf_spi);
        uvm_config_db#(virtual vip_sig_mnt_intf)        ::set(_apb_mstr_agent, "", "_intf_int"  , _intf_int);

    endfunction

    //  Connect phase
    //  Arguments
    //      phase   : UVM phasing object
    function void connect_phase(uvm_phase phase);
        spi_slv_apb_mstr_agent  _agent  ;

        super.connect_phase(phase);
        _spi_mstr_agent._drv._sent_port.connect(_spi_send_scrb.analysis_export);
        _spi_mstr_agent._drv._recv_port.connect(_spi_recv_scrb.analysis_export);
        _spi_mstr_agent._drv._sent_port.connect(_spi_slv_sb._spi_sent);
        _spi_mstr_agent._drv._recv_port.connect(_spi_slv_sb._spi_recv);
        if ($cast(_agent, _apb_mstr_agent)) begin
            _agent._mon._sent_port.connect(_spi_slv_sb._apb_sent);
            _agent._mon._recv_port.connect(_spi_slv_sb._apb_recv);
        end

        _reg_model.default_map.set_sequencer(_apb_mstr_agent._seqr, _adapter);
        _reg_model.default_map.set_auto_predict(0);
        _predictor.map      = _reg_model.default_map;
        _predictor.adapter  = _adapter;
        _agent._trans_ap.connect(_predictor.bus_in);

        // Virtual sequencer connect
        _vseqr._clkrst_seqr     = _clkrst_agent    ._seqr       ;
        _vseqr._apb_seqr        = _apb_mstr_agent  ._seqr       ;
        _vseqr._spi_seqr        = _spi_mstr_agent  ._seqr       ;
        _vseqr._int_seqr        = _int_mnt_agent   ._seqr       ;
        _vseqr._txreq_seqr      = _txreq_mnt_agent ._seqr       ;
        _vseqr._rxbusy_seqr     = _rxbusy_mnt_agent._seqr       ;
        _vseqr._reg_model       = _reg_model                   ;

    endfunction

    //  UVM run phase
    //  Arguments
    //      phase   : UVM phasing object
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        print();
        phase.drop_objection(this);
    endtask

endclass

`endif
