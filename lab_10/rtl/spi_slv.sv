/*
 *-----------------------------------------------------------------------------
 *  Module      :   spi_slv
 *  Project     :   SPI slave peripheral
 *  Author      :   Truong.Nguyen
 *  Created     :   06/25/2020
 *  Description :
 *                  SPI slave top
 *
 *  History     :
 *  Date        By              Base Rev.   Change Description
 *  06-25-2020  Truong.Nguyen   NA          Initial create
 *-----------------------------------------------------------------------------
 */
module spi_slv(
    intf_apb.SLAVE  _intf_apb   ,
    output          INT         ,
    intf_spi.SLAVE  _intf_spi   ,
    output          RX_BUSY     ,
    output          TX_REQ
);
    //-------------------------------------------------------------------------
    //  Parameter Declaration
    //-------------------------------------------------------------------------

    //-------------------------------------------------------------------------
    //  Internal signal declaration
    //-------------------------------------------------------------------------
    logic                   cmpl_pls        ;
    logic                   srstn           ;

    intf_clkrst             _intf_clkrst(
        _intf_apb.PCLK,
        _intf_apb.PRESETn,
        srstn
    );
    intf_spictrl            _intf_spictrl() ;
    intf_int                _intf_int    () ;
    intf_bufw               _intf_tx_bufw() ;
    intf_bufw               _intf_rx_bufw() ;
    intf_bufr               _intf_tx_bufr() ;
    intf_bufr               _intf_rx_bufr() ;

    //-------------------------------------------------------------------------
    //  Sub-module instance
    //-------------------------------------------------------------------------
    spi_slv_apb         apbctrl(
        ._intf_apb      ( _intf_apb             ),
        ._intf_spictrl  ( _intf_spictrl         ),
        ._intf_int      ( _intf_int             ),
        ._intf_bufw     ( _intf_tx_bufw         ),
        ._intf_bufr     ( _intf_rx_bufr         ),
        .srstn          ( srstn                 ),
        .rxbuf_full     ( _intf_rx_bufw.wfull   ),
        .txbuf_empty    ( _intf_tx_bufr.rempty  )
    );

    std_sync_fifo       txbuf(
        ._intf_clkrst   ( _intf_clkrst          ),
        ._intf_bufw     ( _intf_tx_bufw         ),
        ._intf_bufr     ( _intf_tx_bufr         )
    );

    std_sync_fifo       rxbuf(
        ._intf_clkrst   ( _intf_clkrst          ),
        ._intf_bufw     ( _intf_rx_bufw         ),
        ._intf_bufr     ( _intf_rx_bufr         )
    );

    spi_slv_ctrl        spictrl(
        ._intf_clkrst   ( _intf_clkrst          ),
        ._intf_spi      ( _intf_spi             ),
        ._intf_spictrl  ( _intf_spictrl         ),
        ._intf_bufw     ( _intf_rx_bufw         ),
        ._intf_bufr     ( _intf_tx_bufr         ),
        .TX_REQ         ( TX_REQ                ),
        .RX_BUSY        ( RX_BUSY               ),
        .cmpl_pls       ( cmpl_pls              )
    );

    spi_slv_int         intctrl(
        ._intf_clkrst   ( _intf_clkrst          ),
        ._intf_int      ( _intf_int             ),
        .cmpl_pls       ( cmpl_pls              ),
        .INT            ( INT                   )
    );

endmodule
