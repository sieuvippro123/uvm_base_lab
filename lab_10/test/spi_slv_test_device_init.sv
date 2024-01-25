`ifndef __SPI_SLV_TEST_DEVICE_INIT__
`define __SPI_SLV_TEST_DEVICE_INIT__

class spi_slv_test_device_init extends spi_slv_test;
    //--------------------------------------------------------
    //  Factory registration
    //--------------------------------------------------------
    `uvm_component_utils(spi_slv_test_device_init)

    //--------------------------------------------------------
    //Methods
    //--------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parent of the object
    function new(string name = "spi_slv_test_device_init", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    //  UVM run phase
    //  Arguments
    //      phase   : UVM phasing object
    task run_phase(uvm_phase phase);
        uvm_sequence_base   _seq;

        phase.raise_objection(this);

repeat(5) begin
    _seq    = spi_slv_seq_por::type_id::create("_seq_por");
    _seq.start(_env._vseqr);
    #500ns;

    _seq    = spi_slv_seq_device_init::type_id::create("_seq_device_init");
    _seq.randomize();
    _seq.start(_env._vseqr);
    #100ns;

end
    phase.drop_objection(this);
    endtask

endclass


`endif

