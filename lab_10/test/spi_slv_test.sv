`ifndef __SPI_SLV_TEST__
`define __SPI_SLV_TEST__

class spi_slv_test extends uvm_test;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    spi_slv_env     _env    ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_utils(spi_slv_test)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "spi_slv_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //  Build phase
    //  Arguments
    //      phase   : UVM phasing object
    function void build_phase(uvm_phase phase);
        _env    = spi_slv_env::type_id::create("_env", this);

        //  Change clock duty cycles to 30%
        uvm_config_db#(uvm_bitstream_t)::set(this, "_env._clkrst_agent._drv", "_high_time", 3ns);
        uvm_config_db#(uvm_bitstream_t)::set(this, "_env._clkrst_agent._drv", "_low_time" , 7ns);

    endfunction

    //  UVM run phase
    //  Arguments
    //      phase   : UVM phasing object
    task run_phase(uvm_phase phase);
        vip_clkrst_bseq                 _seq        ;
        vip_sig_mnt_wait_rise           _int_rise   ;
        vip_spi_mstr_send               _spi_send   ;
        vip_apb_mstr_write#(3, 8)       _apb_write  ;
        uvm_status_e                    _reg_status ;
        uvm_reg_data_t                  _read_data  ;


        phase.raise_objection(this);
        _seq        = vip_clkrst_bseq::type_id              ::create("_seq"         );
        _int_rise   = vip_sig_mnt_wait_rise::type_id        ::create("_int_rise"    );
        _spi_send   = vip_spi_mstr_send::type_id            ::create("_spi_send"    );
        _apb_write  = vip_apb_mstr_write#(3, 8)::type_id    ::create("_apb_write"   );
        fork
            begin
                _seq.start(_env._clkrst_agent._seqr);
                _env._reg_model.reset();
            end
            begin
                _int_rise.start(_env._int_mnt_agent._seqr);
            end
            begin
                #600ns;
                void'(_apb_write.randomize());
                _apb_write.start(_env._apb_mstr_agent._seqr);
            end
            begin
                #350ns;
                void'(_spi_send.randomize());
                _spi_send.start(_env._spi_mstr_agent._seqr);
            end
        join
        #100ns;

        phase.drop_objection(this);

    endtask

endclass

`endif
