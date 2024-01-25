`ifndef __SPI_SLV_SEQR__
`define __SPI_SLV_SEQR__

class spi_slv_seqr extends uvm_sequencer;
    //--------------------------------------------------------
    //  Properties
    //--------------------------------------------------------
    vip_clkrst_seqr     _clkrst_seqr;
    spi_slv_mstr::SEQR  _apb_seqr   ;
    vip_spi_mstr_seqr    _spi_seqr   ;
    vip_sig_mnt_seqr    _int_seqr   ;
    vip_sig_mnt_seqr    _txreq_seqr ;
    vip_sig_mnt_seqr    _rxbusy_seqr;
    spi_slv_reg_blk     _reg_model  ;
    //--------------------------------------------------------
    //  Factory registration
    //--------------------------------------------------------
    `uvm_component_utils(spi_slv_seqr)

    //--------------------------------------------------------
    //Methods
    //--------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parent of the object
    function new(string name = "spi_slv_seqr", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
endclass


`endif
