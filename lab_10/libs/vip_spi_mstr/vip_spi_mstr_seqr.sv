`ifndef __VIP_SPI_MSTR_SEQR__
`define __VIP_SPI_MSTR_SEQR__

class vip_spi_mstr_seqr extends uvm_sequencer #(vip_spi_mstr_req, vip_spi_mstr_resp);
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_param_utils(vip_spi_mstr_seqr)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "vip_spi_mstr_seqr", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass

`endif
