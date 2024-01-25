`ifndef __SPI_SLV_SEQ_DEVICE_TO_HOST_ERR__
`define __SPI_SLV_SEQ_DEVICE_TO_HOST_ERR__

class spi_slv_seq_device_to_host_err extends uvm_sequence;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    rand bit [7:0]  _spi_data[];
    rand bit [7:0]  _msk_en;

    //-------------------------------------------------------------------------
    //  Constraints
    //-------------------------------------------------------------------------
    constraint DATA_LEN { soft _spi_data.size() == 15; }

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(spi_slv_seq_device_init)
    
    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parent of the object
    function new(string name = "spi_slv_seq_device_init");
        super.new(name);
    endfunction
    
    //  Body
    //  Argument    : none
    virtual task body();
        uvm_sequence_base   _seq    ;
        uvm_status_e        _status ;
        
        vip_spi_mstr_send   _send_seq    ;
        uvm_status_e        _status ;
        uvm_reg_data_t      _read_data   ;
        
        // Disable soft-reset
        p_sequencer._reg_model._sreset  .write(_status, 8'h01);
        
        // Enable SPI transmission logic
        p_sequencer._reg_model._ctrl    .write(_status, 8'h03);
        
        
        // Enabla INT 
        p_sequencer._reg_model._intctrl    .write(_status, _msk_en );
        
        //--------------------------------------------------------
        //	RX 
        //--------------------------------------------------------
        
        // Write to RX buffer to full
        _send_seq = vip_spi_mstr_send::type_id::create("spi_send");
        void'( _send_seq.randomize() );
        _send_seq.start(p_sequencer._spi_seqr);
        
        // Read data from RX buffer to APB
        
        for(int idx = 0; idx < 15; idx++) begin
            //  Read data from RX buffer
            p_sequencer._reg_model._txrxbuf .read(_status, _read_data);
        end
        
        //--------------------------------------------------------
        //	TX
        //--------------------------------------------------------
        
        
        // Write data to buffer
        for ( int idx = 0; idx < _spi_data.size(); idx++ ) begin
            p_sequencer._reg_model._txrxbuf .write(_status, _spi_data[idx]);
        end

        
        
        // Start send sequence
            p_sequencer._reg_model._txstart .write(_status, 8'h01);
            
            p_sequencer._reg_model._intsts .write(_status, 8'h01);

            // Wait for TX_REQ
            _seq    = vip_sig_mnt_wait_high::type_id::create("wait_high");
            _seq.start(p_sequencer._txreq_seqr);
            
            // Wait for SPI frame
            _seq    = vip_spi_mstr_recv::type_id::create("spi_recv");
            _seq.start(p_sequencer._spi_seqr);
            
            
            
            // Disable soft-reset
            p_sequencer._reg_model._sreset  .write(_status, 8'h01);
            
            // Enable SPI receiving logic
            p_sequencer._reg_model._ctrl    .write(_status, 8'h02);
            
            
            //--------------------------------------------------------
            //	Clear INT flag
            //--------------------------------------------------------
            
            
            
            
            
            
        endtask
    
endclass


`endif



