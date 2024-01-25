`ifndef __SPI_SLV_SEQ_BASE__
`define __SPI_SLV_SEQ_BASE__

class spi_slv_seq_base extends uvm_sequence;
    //--------------------------------------------------------
    //  Factory registration
    //--------------------------------------------------------
    `uvm_object_utils(spi_slv_seq_base)
    `uvm_declare_p_sequencer(spi_slv_seqr)

    //--------------------------------------------------------
    //Methods
    //--------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parent of the object
    function new(string name = "spi_slv_seq_base");
        super.new(name);
    endfunction

    //  Body task
    //  Arguments	: none
    virtual task body();
    endtask

    
endclass

`endif

