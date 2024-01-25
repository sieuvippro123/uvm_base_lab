`ifndef __SPI_SLV_SEQ_DEVICE_INIT__
`define __SPI_SLV_SEQ_DEVICE_INIT__

class spi_slv_seq_device_init extends spi_slv_seq_base;
    //--------------------------------------------------------
    //  Properties
    //--------------------------------------------------------
    rand     bit [7:0]   _spi_data[];
    rand     bit [7:0]   intctrl;
    rand     bit [7:0]   intsts;
	rand	 bit [7:0]	 ctrl;
    randc    bit [4:0]   msk_en;
    rand     bit         bit_rand;
    rand     bit [7:0]   status;
	bit					 tmp;
    randc    bit  [3:0]   val;


    //--------------------------------------------------------
    //	Constraints
    //--------------------------------------------------------
    constraint DATA_LEN {soft _spi_data.size() == 15; }
    constraint DATA_INTCTRL {intctrl[7:5] == 3'b0;
        intctrl[3:1] == 3'b0;
    }
    constraint DATA_INTSTS {intctrl[7:1] == 7'b0;}    
	constraint DATA_CTRL {ctrl[7:2] == 0;}
    constraint DATA_MSK_EN { msk_en[3:1] == 3'b0;}

    //--------------------------------------------------------
    //  Factory registration
    //--------------------------------------------------------
    `uvm_object_utils(spi_slv_seq_device_init)

    //--------------------------------------------------------
    //Methods
    //--------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parent of the object
    function new(string name = "spi_slv_seq_device_init");
        super.new(name);
    endfunction
    
    //  Body task
        //  Arguments : none
    virtual task body();
        uvm_sequence_base   _seq    ;
        uvm_status_e        _status ;
    repeat(20) begin

        
        // Disable SPI soft-reset
        p_sequencer._reg_model._sreset  .write(_status, 8'h01);
        p_sequencer._reg_model._sreset  .read(_status, tmp);
        
        //  Enable SPI transmission logic
        ctrl = $random;
        p_sequencer._reg_model._ctrl    .write(_status, ctrl);
        p_sequencer._reg_model._ctrl    .read(_status, tmp);

        _seq	= vip_spi_mstr_send::type_id::create("spi_send");
		void'(_seq.randomize());
	    _seq.start(p_sequencer._spi_seqr);

        //  Write data to TX buffer
        for (int idx = 0; idx < _spi_data.size(); idx++) begin
            p_sequencer._reg_model._txrxbuf .write(_status, _spi_data[idx]);
        end

        // Device to host
        // write data to RX buffer and full at any widx value 
        fork
            begin
                _seq	= vip_spi_mstr_send::type_id::create("spi_send");
		        void'(_seq.randomize());
		        _seq.start(p_sequencer._spi_seqr);
            end
            begin
                val = $random;
                for (int idx = 0; idx < val; idx++) begin
                    #10000;
                    p_sequencer._reg_model._txrxbuf .read(_status, tmp);
                end
                
            end
        join
        
		_seq	= vip_spi_mstr_send::type_id::create("spi_send");
		void'(_seq.randomize());
		_seq.start(p_sequencer._spi_seqr);
        
        
        
        //  Read data from buffer
        for (int idx = 0; idx < _spi_data.size(); idx++) begin
            p_sequencer._reg_model._txrxbuf .read(_status, tmp);
        end
        
        // Interrupt intsts
        p_sequencer._reg_model._intsts  .write(_status, intsts);     
        p_sequencer._reg_model._intsts  .read(_status, tmp);     

        
        fork
            begin
                //  Start send request
                p_sequencer._reg_model._txstart .write(_status, 8'h01);
                p_sequencer._reg_model._txstart .read(_status, tmp);
            end 
            begin
                #100;
                p_sequencer._reg_model._txstart .write(_status, 8'h01);
            end
            begin
                #25790;
                p_sequencer._reg_model._txstart .write(_status, 8'h01);
            end
        join_any

        msk_en = $random;
        p_sequencer._reg_model._intctrl    .write(_status, msk_en);
        p_sequencer._reg_model._intctrl    .read(_status, tmp);
        
        //  Wait for TX_REQ
        _seq    = vip_sig_mnt_wait_high::type_id::create("wait_high");
        _seq.start(p_sequencer._txreq_seqr);
        
        
        //  Start SPI frame
        _seq    = vip_spi_mstr_recv::type_id::create("spi_recv");
        _seq.start(p_sequencer._spi_seqr);
        
        
        
        //	txstart assert when SPI master send data 
        //  tx_latch assert until SPI frame complite
        fork 
            begin
                #800;
                bit_rand = $random;
                if (bit_rand) p_sequencer._reg_model._txstart .write(_status, 8'h01);
            end
            
            begin
                _seq	= vip_spi_mstr_send_err::type_id::create("spi_send");
                _seq.randomize();
                _seq.start(p_sequencer._spi_seqr);
            end 
        join
        
        // p_sequencer._reg_model._txstart .write(_status, 8'h01);
        // Interrupt cover msk
        p_sequencer._reg_model._intsts  .write(_status, intsts);
           
       
        p_sequencer._reg_model._status      .write(_status, status);
        p_sequencer._reg_model._status      .read(_status, tmp);
        
        
        // Host to device
        // write data to TX buffer and full at any widx value 
        val = $random;
        for (int idx = 0; idx < _spi_data.size() - val; idx++) begin
            p_sequencer._reg_model._txrxbuf .write(_status, _spi_data[idx]);
        end

        _seq    = vip_spi_mstr_recv::type_id::create("spi_recv");
        _seq.start(p_sequencer._spi_seqr);
        
        for (int idx = 0; idx < _spi_data.size(); idx++) begin
            p_sequencer._reg_model._txrxbuf .write(_status, _spi_data[idx]);
        end

        // rx_wen and rx_ren assert at the same time
         p_sequencer._reg_model._ctrl    .write(_status, 8'h03);

        fork
            begin
                _seq	= vip_spi_mstr_send::type_id::create("spi_send");
		        void'(_seq.randomize());
		        _seq.start(p_sequencer._spi_seqr);
            end
            begin
                val = $random;
                for (int idx = 0; idx < val; idx++) begin
                    #(10000-400);
                    p_sequencer._reg_model._txrxbuf .read(_status, tmp);
                end
                
            end
        join

        // tx_wen and tx_ren assert at the same time
        fork
            begin
                _seq	= vip_spi_mstr_recv::type_id::create("spi_send");
		        void'(_seq.randomize());
		        _seq.start(p_sequencer._spi_seqr);
            end
            begin
                val = $random;
                for (int idx = 0; idx < val; idx++) begin
                    #(10000-500);
                    p_sequencer._reg_model._txrxbuf .write(_status, tmp);
                end
                
            end
        join
        
    end
    
    
endtask

endclass



`endif


