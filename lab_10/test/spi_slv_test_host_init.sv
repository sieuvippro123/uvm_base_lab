`ifndef __SPI_SLV_TEST_HOST_INIT__
`define __SPI_SLV_TEST_HOST_INIT__

class spi_slv_test_host_init extends spi_slv_test;
    //--------------------------------------------------------
    //  Properties
    //--------------------------------------------------------
    
    //--------------------------------------------------------
    //  Factory registration
    //--------------------------------------------------------
    `uvm_component_utils(spi_slv_test_host_init)

    //--------------------------------------------------------
    //Methods
    //--------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parent of the object
    function new(string name = "spi_slv_test_host_init", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    //  UVM run phase
    //  Arguments 
    //      phase   : UVM phasing object
    task run_phase(uvm_phase phase);
        uvm_sequence_base   _seq;

        phase.raise_objection(this);        
        //  Start clock and control reset
        _seq    = spi_slv_seq_por::type_id::create("_seq_por");
        _seq.start(_env._vseqr);
        #500ns;

        //  Start SPI transfer
        _seq    = spi_slv_seq_host_init::type_id::create("_seq_host_init");
        _seq.start(_env._vseqr);

        #100ns;
        phase.drop_objection(this);
    endtask

endclass


`endif
