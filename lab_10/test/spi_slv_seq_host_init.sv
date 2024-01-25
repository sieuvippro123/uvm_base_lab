`ifndef __SPI_SLV_SEQ_HOST_INIT__
`define __SPI_SLV_SEQ_HOST_INIT__

class spi_slv_seq_host_init extends spi_slv_seq_base;
    //--------------------------------------------------------
    //  Properties
    //--------------------------------------------------------
        
    //--------------------------------------------------------
    //  Factory registration
    //--------------------------------------------------------
    `uvm_object_utils(spi_slv_seq_host_init)

    //--------------------------------------------------------
    //Methods
    //--------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parent of the object
    function new(string name = "spi_slv_seq_host_init");
        super.new(name);
    endfunction
    
    // Body task
    // Arguments    : none
    virtual task body();
        vip_spi_mstr_send   _seq   ;
        uvm_status_e        _status ;

        // Disable soft reset
        p_sequencer._reg_model._sreset  .write(_status, 8'h01);

        // Enable SPI receiving logic
        p_sequencer._reg_model._ctrl    .write(_status, 8'h02);

        // Start SPI frame
        _seq    = vip_spi_mstr_send::type_id::create("spi_send");
        void'(_seq.randomize()with {_payload.size() == 15; });
        _seq.start(p_sequencer._spi_seqr);
    endtask 
endclass


`endif
