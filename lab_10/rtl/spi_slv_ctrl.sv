/*
 *-----------------------------------------------------------------------------
 *  Module      :   spi_slv_apb
 *  Project     :   SPI slave peripheral
 *  Author      :   Truong.Nguyen
 *  Created     :   06/25/2020
 *  Description :
 *                  Register access
 *
 *  History     :
 *  Date        By              Base Rev.   Change Description
 *  06-25-2020  Truong.Nguyen   NA          Initial create
 *-----------------------------------------------------------------------------
 */
module spi_slv_ctrl(
    intf_clkrst     .SYNCASYNC  _intf_clkrst    ,
    intf_spi        .SLAVE      _intf_spi       ,
    intf_spictrl    .SPI        _intf_spictrl   ,
    intf_bufw       .DRIVER     _intf_bufw      ,
    intf_bufr       .DRIVER     _intf_bufr      ,
    output  logic               TX_REQ          ,
    output  logic               RX_BUSY         ,
    output  logic               cmpl_pls
);
    //-------------------------------------------------------------------------
    //  Parameter Declaration
    //-------------------------------------------------------------------------
    localparam      P_AWIDTH    = 3 ;                       //  APB address bus width
    localparam      P_DWIDTH    = 8 ;                       //  APB data bus width
    localparam      P_SWIDTH    = P_DWIDTH / 8;             //  APB strobe width

    //-------------------------------------------------------------------------
    //  Internal signal declaration
    //-------------------------------------------------------------------------
    logic   [             1 : 0 ]   r_rst_sync  ;
    logic   [             2 : 0 ]   r_scsn      ;
    logic   [             2 : 0 ]   r_sclk      ;
    logic   [             1 : 0 ]   r_sdi       ;
    logic                           w_scsn_rise ;
    logic                           w_scsn_fall ;
    logic                           w_sclk_rise ;
    logic                           w_sclk_fall ;
    logic                           r_txen      ;
    logic                           r_rxen      ;
    logic                           r_tx_latch  ;
    logic   [ P_DWIDTH  - 1 : 0 ]   r_rx_crc    ;
    logic   [ P_DWIDTH  - 1 : 0 ]   r_tx_crc    ;
    logic   [ P_DWIDTH  - 1 : 0 ]   w_rx_crc_nxt;
    logic   [ P_DWIDTH  - 1 : 0 ]   w_tx_crc_nxt;
    logic                           w_sdo_nxt   ;
    logic   [             7 : 0 ]   r_tx_data   ;
    logic   [             7 : 0 ]   r_rx_data   ;
    logic   [             7 : 0 ]   r_frm_cnt   ;
    logic   [             2 : 0 ]   w_bit_cnt   ;
    logic   [             4 : 0 ]   w_byte_cnt  ;

    //-------------------------------------------------------------------------
    //  Combinational assignments
    //-------------------------------------------------------------------------
    assign  w_scsn_rise                 =  r_scsn[1] & !r_scsn[2];
    assign  w_scsn_fall                 = !r_scsn[1] &  r_scsn[2];
    assign  w_sclk_rise                 =  r_sclk[1] & !r_sclk[2];
    assign  w_sclk_fall                 = !r_sclk[1] &  r_sclk[2];
    assign  cmpl_pls                    =  r_scsn[1] & !r_scsn[2];
    assign  { w_byte_cnt, w_bit_cnt }   =  r_frm_cnt;
    assign  w_sdo_nxt                   =  r_tx_data[w_bit_cnt];
    assign  _intf_bufr.ren              =  w_scsn_fall || (w_sclk_rise && r_txen && (w_bit_cnt == 7) && (w_byte_cnt <  14));
    assign  _intf_bufw.wen              =  r_rxen & w_sclk_fall && (w_bit_cnt == 0) && (w_byte_cnt > 0) && (w_byte_cnt <= 15);
    assign  _intf_bufw.wdata            = {r_sdi[1], r_rx_data[7:1]};
    assign  _intf_spictrl.txcmpl        =  w_scsn_rise;

    always_comb begin
        logic tx_feedback;
        logic rx_feedback;

        rx_feedback         = r_rx_crc[7] ^ r_sdi[1];
        w_rx_crc_nxt[0]     = rx_feedback;
        w_rx_crc_nxt[1]     = r_rx_crc[0];
        w_rx_crc_nxt[2]     = r_rx_crc[1];
        w_rx_crc_nxt[3]     = r_rx_crc[2];
        w_rx_crc_nxt[4]     = r_rx_crc[3] ^ rx_feedback;
        w_rx_crc_nxt[5]     = r_rx_crc[4] ^ rx_feedback;
        w_rx_crc_nxt[6]     = r_rx_crc[5];
        w_rx_crc_nxt[7]     = r_rx_crc[6];

        tx_feedback         = r_tx_crc[7] ^ w_sdo_nxt;
        w_tx_crc_nxt[0]     = tx_feedback;
        w_tx_crc_nxt[1]     = r_tx_crc[0];
        w_tx_crc_nxt[2]     = r_tx_crc[1];
        w_tx_crc_nxt[3]     = r_tx_crc[2];
        w_tx_crc_nxt[4]     = r_tx_crc[3] ^ tx_feedback;
        w_tx_crc_nxt[5]     = r_tx_crc[4] ^ tx_feedback;
        w_tx_crc_nxt[6]     = r_tx_crc[5];
        w_tx_crc_nxt[7]     = r_tx_crc[6];
    end

    //-------------------------------------------------------------------------
    //  Sequential assignments
    //-------------------------------------------------------------------------
    //  Synchronizer
    always_ff @(posedge _intf_clkrst.clk) begin
        r_rst_sync  <= { r_rst_sync [0]     , _intf_clkrst  .resetn };
        r_scsn      <= { r_scsn     [1:0]   , _intf_spi     .SCSn   };
        r_sclk      <= { r_sclk     [1:0]   , _intf_spi     .SCLK   };
        r_sdi       <= { r_sdi      [0]     , _intf_spi     .MOSI   };
    end

    //  r_txen, r_rxen
    //      - Reset         : 0
    //      - w_scsn_fall   : txen, rxen
    //      - w_scsn_rise   : 0
    always_ff @(posedge _intf_clkrst.clk) begin
        if (!r_rst_sync[0] || !_intf_clkrst.srstn || w_scsn_rise) begin
            r_txen  <= 0;
            r_rxen  <= 0;
        end
        else if (w_scsn_fall) begin
            r_txen  <= _intf_spictrl.txen;
            r_rxen  <= _intf_spictrl.rxen;
        end
    end

    //  r_tx_latch
    //      - Reset         : 0
    //      - txstart_pulse
    //          - r_scsn[2] || r_scsn[1]: 0
    //          - else                  : 1
    //      - scsn_rise                 : 0
    always_ff @(posedge _intf_clkrst.clk) begin
        if      (!r_rst_sync[0] || !_intf_clkrst.srstn  )   r_tx_latch  <= 0;
        else if (_intf_spictrl.txstart_pulse            ) begin
            if  (r_scsn[2] || r_scsn[1]                 )   r_tx_latch  <= 0;
            else                                            r_tx_latch  <= 1;
        end
        else if (w_scsn_rise                            )   r_tx_latch  <= 0;
    end

    //  r_frm_cnt
    //      - Reset         : 0
    //      - scsn_fall     : 0
    //      - sclk_rise     : increase until '1
    always_ff @(posedge _intf_clkrst.clk) begin
        if      (!_intf_clkrst.srstn                    )   r_frm_cnt   <= 0;
        else if ( w_scsn_fall                           )   r_frm_cnt   <= 0;
        else if ( w_sclk_rise   && (r_frm_cnt == 128)   )   r_frm_cnt   <= '1;
        else if ( w_sclk_rise                           )   r_frm_cnt   <= r_frm_cnt + 1;
    end

    //  TX_REQ
    //      - Reset         : 0
    //      - txstart_pulse
    //          - r_scsn[2] : 1
    //          - r_scsn[1] : 1
    //          - other     : 0
    //      - scsn_rise     : r_tx_latch
    //      - sclk_rise & (w_bit_cnt == 7): 0
    always_ff @(posedge _intf_clkrst.clk) begin
        if      (!r_rst_sync[0] || !_intf_clkrst.srstn  )   TX_REQ  <= 0;
        else if (_intf_spictrl.txstart_pulse            ) begin
            if      (r_scsn[2]                          )   TX_REQ  <= 1;
            else if (r_scsn[1]                          )   TX_REQ  <= 1;
            else                                            TX_REQ  <= 0;
        end
        else if (w_scsn_rise                            )   TX_REQ  <= r_tx_latch;
        else if (w_sclk_rise & (w_bit_cnt == 7)         )   TX_REQ  <= 0;
    end

    //  RX CRC
    //      - scsn_fall     : 8'hFF
    //      - sclk_fall     : next CRC
    always_ff @(posedge _intf_clkrst.clk) begin
        if      (w_scsn_fall                        )   r_rx_crc    <= 8'hFF;
        else if (w_sclk_fall && (r_frm_cnt <= 8'h78))   r_rx_crc    <= w_rx_crc_nxt;
    end

    //  TX CRC
    //      - scsn_fall     : 8'hFF
    //      - sclk_fall     : next CRC
    always_ff @(posedge _intf_clkrst.clk) begin
        if      (w_scsn_fall)   r_tx_crc    <= 8'hFF;
        else if (w_sclk_rise)   r_tx_crc    <= w_tx_crc_nxt;
    end

    //  r_rx_data
    //      - scsn_fall         : 8'h00
    //      - sclk_fall & r_rxen: shift r_sdi[1] to MSB
    always_ff @(posedge _intf_clkrst.clk) begin
        if      (w_scsn_fall    )   r_rx_data   <= 8'h00;
        else if (w_sclk_fall    )   r_rx_data   <= { r_sdi[1], r_rx_data[7:1]};
    end

    //  r_tx_data
    //      - scsn_fall     : rdata & {8{rempty & r_txen}}
    //      - sclk_rise
    //          - r_txen                                : 8'h00
    //          - (w_bit_cnt == 7) && (w_byte_cnt < 14) : rdata & {8{rempty & r_txen}}
    //          - (w_bit_cnt == 7) && (w_byte_cnt ==14) : w_tx_crc_nxt
    always_ff @(posedge _intf_clkrst.clk) begin
        if      (w_scsn_fall                    )   r_tx_data   <= _intf_bufr.rdata & {8{!_intf_bufr.rempty & _intf_spictrl.txen}};
        else if (w_sclk_rise && (w_bit_cnt == 7)) begin
            if      ((w_byte_cnt == 14)         )   r_tx_data   <= w_tx_crc_nxt;
            else if (!r_txen                    )   r_tx_data   <= 8'h00;
            else if ((w_byte_cnt <  14)         )   r_tx_data   <= _intf_bufr.rdata & {8{!_intf_bufr.rempty & _intf_spictrl.txen}};
            else if ((w_bit_cnt == 7)           )   r_tx_data   <= 8'h00;
        end
    end

    //  SDO
    //      - SCSn      : 0 (asynchronous reset)
    //      - other     : r_tx_data[w_bit_cnt]
    always_ff @(posedge _intf_spi.SCLK, posedge _intf_spi.SCSn) begin
        if (_intf_spi.SCSn) _intf_spi.MISO  <= 0;
        else                _intf_spi.MISO  <= r_tx_data[w_bit_cnt];
    end

    //  CRC error, Frame len error
    always_ff @(posedge _intf_clkrst.clk, negedge _intf_clkrst.resetn) begin
        if (!_intf_clkrst.resetn) begin
            _intf_spictrl.crc_err   <= '0;
            _intf_spictrl.len_err   <= '0;
        end
        else if (!_intf_clkrst.srstn) begin
            _intf_spictrl.crc_err   <= '0;
            _intf_spictrl.len_err   <= '0;
        end
        else if (w_scsn_fall) begin
            _intf_spictrl.crc_err   <= '0;
            _intf_spictrl.len_err   <= '0;
        end
        else if (w_scsn_rise) begin
            if (r_frm_cnt == 128) begin
                _intf_spictrl.crc_err   <= (r_rx_crc != r_rx_data);
                _intf_spictrl.len_err   <= '0;
            end
            else begin
                _intf_spictrl.crc_err   <= '0;
                _intf_spictrl.len_err   <= '1;
            end
        end
    end

endmodule
