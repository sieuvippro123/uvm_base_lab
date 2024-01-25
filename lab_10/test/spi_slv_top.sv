import uvm_pkg::*;
import spi_slv_pkg::*;

`include "spi_slv_sva.sv"

module spi_slv_top;
    //-------------------------------------------------------------------------
    //  Interface
    //-------------------------------------------------------------------------
    vip_clkrst_intf     _vip_clkrst_intf();
    vip_sig_mnt_intf    _vip_int_intf();
    vip_sig_mnt_intf    _vip_txreq_intf();
    vip_sig_mnt_intf    _vip_rxbusy_intf();
    vip_spi_intf        _vip_spi_intf();
    vip_apb_intf#(3, 8) _vip_apb_intf(
        _vip_clkrst_intf.clk    ,
        _vip_clkrst_intf.resetn
    );

    intf_apb            _rtl_apb_intf(
        _vip_clkrst_intf.clk    ,
        _vip_clkrst_intf.resetn
    );
    intf_spi            _rtl_spi_intf();

    spi_slv             _spi_slv(
        ._intf_apb  ( _rtl_apb_intf                 ),
        .INT        ( _vip_int_intf     .mnt_sig    ),
        ._intf_spi  ( _rtl_spi_intf                 ),
        .RX_BUSY    ( _vip_rxbusy_intf  .mnt_sig    ),
        .TX_REQ     ( _vip_txreq_intf   .mnt_sig    )
    );

    spi_slv_sva#(3,8,1,15,5)    _spi_slv_sva(
        ._clkrst_intf   (_spi_slv._intf_clkrst  ),
        ._apb_intf      (_spi_slv._intf_apb     ),
        ._spictrl_intf  (_spi_slv._intf_spictrl ),
        ._spi_intf      (_spi_slv._intf_spi     ),
        ._int_intf      (_spi_slv._intf_int     ),
        ._tx_bufw_intf  (_spi_slv._intf_tx_bufw ),
        ._rx_bufw_intf  (_spi_slv._intf_rx_bufw ),
        ._tx_bufr_intf  (_spi_slv._intf_tx_bufr ),
        ._rx_bufr_intf  (_spi_slv._intf_rx_bufr ),
        .INT            (_spi_slv.INT           ),
        .cmpl_pls       (_spi_slv.cmpl_pls      ),

        .r_paddr        (_spi_slv.apbctrl.r_paddr   ),
        .r_pwrite       (_spi_slv.apbctrl.r_pwrite  ),
        .r_pwdata       (_spi_slv.apbctrl.r_pwdata  ),
        .r_pstrb        (_spi_slv.apbctrl.r_pstrb   ),
        .r_psel         (_spi_slv.apbctrl.r_psel    ),
        
        .s_en_srstn     (_spi_slv.apbctrl.s_en_srstn),
        .s_en_ctrl      (_spi_slv.apbctrl.s_en_ctrl),
        .s_en_txctrl    (_spi_slv.apbctrl.s_en_txctrl),
        .s_en_sts       (_spi_slv.apbctrl.s_en_sts),
        .s_en_intctrl   (_spi_slv.apbctrl.s_en_intctrl),
        .s_en_intsts    (_spi_slv.apbctrl.s_en_intsts),
        .s_en_txbuf     (_spi_slv.apbctrl.s_en_txbuf),
        .s_en_rxbuf     (_spi_slv.apbctrl.s_en_rxbuf),

        .txbuf_buffer   (_spi_slv.txbuf.buffer),
        .txbuf_widx     (_spi_slv.txbuf.widx),
        .txbuf_ridx     (_spi_slv.txbuf.ridx),

        .rxbuf_buffer   (_spi_slv.rxbuf.buffer),
        .rxbuf_widx     (_spi_slv.rxbuf.widx),
        .rxbuf_ridx     (_spi_slv.rxbuf.ridx),

        .r_rst_sync     (_spi_slv.spictrl.r_rst_sync),
        .r_scsn         (_spi_slv.spictrl.r_scsn),
        .r_sclk         (_spi_slv.spictrl.r_sclk),
        .r_sdi          (_spi_slv.spictrl.r_sdi),
        .w_scsn_rise    (_spi_slv.spictrl.w_scsn_rise),
        .w_scsn_fall    (_spi_slv.spictrl.w_scsn_fall),
        .w_sclk_rise    (_spi_slv.spictrl.w_sclk_rise),
        .w_sclk_fall    (_spi_slv.spictrl.w_sclk_fall),

        .TX_REQ         (_vip_txreq_intf.mnt_sig),
        .r_tx_latch     (_spi_slv.spictrl.r_tx_latch),
        .w_bit_cnt      (_spi_slv.spictrl.w_bit_cnt),
        .w_byte_cnt     (_spi_slv.spictrl.w_byte_cnt),
        .r_frm_cnt      (_spi_slv.spictrl.r_frm_cnt),

        .r_rx_crc       (_spi_slv.spictrl.r_rx_crc),
        .w_rx_crc_nxt   (_spi_slv.spictrl.w_rx_crc_nxt),
        .r_tx_crc       (_spi_slv.spictrl.r_tx_crc),
        .w_tx_crc_nxt   (_spi_slv.spictrl.w_tx_crc_nxt),

        .r_rx_data      (_spi_slv.spictrl.r_rx_data),
        .r_tx_data      (_spi_slv.spictrl.r_tx_data),
        .s_rdata        (_spi_slv.apbctrl.s_rdata)
    );

    assign  _rtl_apb_intf.PSEL      = _vip_apb_intf.PSEL    ;
    assign  _rtl_apb_intf.PENABLE   = _vip_apb_intf.PENABLE ;
    assign  _rtl_apb_intf.PWRITE    = _vip_apb_intf.PWRITE  ;
    assign  _rtl_apb_intf.PADDR     = _vip_apb_intf.PADDR   ;
    assign  _rtl_apb_intf.PWDATA    = _vip_apb_intf.PWDATA  ;
    assign  _rtl_apb_intf.PSTRB     = _vip_apb_intf.PSTRB   ;
    assign  _vip_apb_intf.PRDATA    = _rtl_apb_intf.PRDATA  ;
    assign  _vip_apb_intf.PREADY    = _rtl_apb_intf.PREADY  ;
    assign  _vip_apb_intf.PSLVERR   = _rtl_apb_intf.PSLVERR ;
    assign  _rtl_spi_intf.SCLK      = _vip_spi_intf.SCLK    ;
    assign  _rtl_spi_intf.SCSn      = _vip_spi_intf.SCSn    ;
    assign  _rtl_spi_intf.MOSI      = _vip_spi_intf.MOSI    ;
    assign  _vip_spi_intf.MISO      = _rtl_spi_intf.MISO    ;

    //-------------------------------------------------------------------------
    //  Start UVM test
    //-------------------------------------------------------------------------
    initial begin
        uvm_config_db #(virtual vip_clkrst_intf)    ::set(null, "uvm_test_top", "_intf_clkrst"  , _vip_clkrst_intf  );
        uvm_config_db #(virtual vip_sig_mnt_intf)   ::set(null, "uvm_test_top", "_intf_int"     , _vip_int_intf     );
        uvm_config_db #(virtual vip_sig_mnt_intf)   ::set(null, "uvm_test_top", "_intf_txreq"   , _vip_txreq_intf   );
        uvm_config_db #(virtual vip_sig_mnt_intf)   ::set(null, "uvm_test_top", "_intf_rxbusy"  , _vip_rxbusy_intf  );
        uvm_config_db #(virtual vip_spi_intf)       ::set(null, "uvm_test_top", "_intf_spi"     , _vip_spi_intf     );
        uvm_config_db #(virtual vip_apb_intf#(3, 8))::set(null, "uvm_test_top", "_intf_apb"     , _vip_apb_intf     );
        run_test();
    end

endmodule
