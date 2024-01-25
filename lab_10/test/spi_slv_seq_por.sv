`ifndef __SPI_SLV_SEQ_POR__
`define __SPI_SLV_SEQ_POR__

class spi_slv_seq_por extends spi_slv_seq_base;
    //--------------------------------------------------------
    //  Properties
    //--------------------------------------------------------
        
    //--------------------------------------------------------
    //  Factory registration
    //--------------------------------------------------------
    `uvm_object_utils(spi_slv_seq_por)

    //--------------------------------------------------------
    //Methods
    //--------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parent of the object
    function new(string name = "spi_slv_seq_por");
        super.new(name);
    endfunction
    
    // Body task
    // Arguments    : none
    virtual task body();
        uvm_sequence_base   _seq;

        #100ns;
        _seq    = vip_clkrst_start_clk::type_id::create("start_clk");
        _seq.start(p_sequencer._clkrst_seqr);
        #100ns;
        _seq    = vip_clkrst_assert_reset::type_id::create("assert_rst");
        _seq.start(p_sequencer._clkrst_seqr);
        #100ns;
        _seq    = vip_clkrst_deassert_reset::type_id::create("deassert_rst");
        _seq.start(p_sequencer._clkrst_seqr);
    endtask
endclass


`endif




