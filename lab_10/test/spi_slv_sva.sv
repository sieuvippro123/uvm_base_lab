import lib_sva_pkg::*;

//  Module: spi_slv_sva
//
module spi_slv_sva
    /*  package imports  */
    #(
        parameter   P_AWIDTH  = 3,
        parameter   P_DWIDTH  = 8,
        parameter   P_SWIDTH  = P_DWIDTH/8,
        parameter   P_DEPTH   = 15,
        parameter   P_IWIDTH  = $clog2(P_DEPTH) + 1
    )(
        intf_clkrst     _clkrst_intf,
        intf_apb        _apb_intf,
        intf_spictrl    _spictrl_intf,
        intf_spi        _spi_intf,        
        intf_int        _int_intf,
        intf_bufw       _tx_bufw_intf,
        intf_bufw       _rx_bufw_intf,
        intf_bufr       _tx_bufr_intf,
        intf_bufr       _rx_bufr_intf,
        input   logic   INT,
        input   logic   cmpl_pls,
        
        input   logic   [P_AWIDTH-1 : 0]    r_paddr,
        input   logic                       r_pwrite,
        input   logic   [P_DWIDTH-1 : 0]    r_pwdata,
        input   logic   [P_SWIDTH-1 : 0]    r_pstrb,
        input   logic   [1          : 0]    r_psel,

        input   logic                       s_en_srstn,
        input   logic                       s_en_ctrl,
        input   logic                       s_en_txctrl,
        input   logic                       s_en_sts,
        input   logic                       s_en_intctrl,
        input   logic                       s_en_intsts,
        input   logic                       s_en_txbuf,
        input   logic                       s_en_rxbuf,

        input   logic   [P_DEPTH-1 : 0] [P_DWIDTH-1 : 0]    txbuf_buffer,
        input   logic   [P_IWIDTH-1 : 0]                    txbuf_widx,
        input   logic   [P_IWIDTH-1 : 0]                    txbuf_ridx,

        input   logic   [P_DEPTH-1 : 0] [P_DWIDTH-1 : 0]    rxbuf_buffer,
        input   logic   [P_IWIDTH-1 : 0]                    rxbuf_widx,
        input   logic   [P_IWIDTH-1 : 0]                    rxbuf_ridx,

        input   logic   [1 : 0]             r_rst_sync,
        input   logic   [2 : 0]             r_scsn,
        input   logic                       w_scsn_rise,
        input   logic                       w_scsn_fall,
        input   logic   [2 : 0]             r_sclk,
        input   logic                       w_sclk_rise,
        input   logic                       w_sclk_fall,
        input   logic   [1 : 0]             r_sdi,

        input   logic                       TX_REQ,
        input   logic                       r_tx_latch,
        input   logic   [2 : 0]             w_bit_cnt,
        input   logic   [4 : 0 ]            w_byte_cnt,

        input   logic   [7 : 0]             r_rx_crc,
        input   logic   [7 : 0]             w_rx_crc_nxt,
        input   logic   [7 : 0]             r_tx_crc,
        input   logic   [7 : 0]             w_tx_crc_nxt,

        input   logic   [7 : 0]             r_rx_data,
        input   logic   [7 : 0]             r_tx_data,
        input   logic   [P_DWIDTH-1 : 0]    s_rdata,
        input   logic   [7 : 0]             r_frm_cnt
    );

        //--------------------------------------------------------
        //	SRESET - Soft-reset register    
        //--------------------------------------------------------
        P_SRSTN_RESET: assert property(
            P_FF_ARn(_clkrst_intf.clk, _clkrst_intf.resetn, _clkrst_intf.srstn, 1'b0)
        );


        P_SRSTN_WRITE: assert property( 
            P_FF_ARn_SRn_UPDT(_clkrst_intf.clk, _clkrst_intf.resetn, r_psel[0] && !r_psel[1] && (r_paddr == 0) && r_pwrite, _clkrst_intf.srstn , r_pwdata[0])//r_pwdata[0])
        );

        P_SRSTN_CHANGE: assert property(
            P_FF_CHANGE(_clkrst_intf.clk, _clkrst_intf.resetn, _clkrst_intf.srstn, _clkrst_intf.resetn, r_psel[0] && !r_psel[1] && (r_paddr == 0) && r_pwrite)
        );

        //--------------------------------------------------------
        //	CTRL - Control register
        //--------------------------------------------------------

        P_TXEN_RESET: assert property(
            P_FF_ARn(_clkrst_intf.clk, _clkrst_intf.resetn, _spictrl_intf.txen, 1'b0)
        );
        P_TXEN_WRITE: assert property( 
            P_FF_ARn_EN_UPDT(_clkrst_intf.clk, _clkrst_intf.resetn, !r_psel[0] && !r_psel[1] && (r_paddr == 1) && r_pwrite, _spictrl_intf.txen, r_pwdata[0])
        );
        P_TXEN_CHANGE: assert property( 
            P_FF_CHANGE(_clkrst_intf.clk, _clkrst_intf.resetn, _spictrl_intf.txen, _clkrst_intf.resetn, r_psel[0] && !r_psel[1] && (r_paddr == 1) && r_pwrite)
        );

        P_RXEN_RESET: assert property(
            P_FF_ARn(_clkrst_intf.clk, _clkrst_intf.resetn, _spictrl_intf.rxen, 1'b0)
        );
        P_RXEN_WRITE: assert property( 
            P_FF_ARn_EN_UPDT(_clkrst_intf.clk, _clkrst_intf.resetn, r_psel[0] && !r_psel[1] && (r_paddr == 1) && r_pwrite, _spictrl_intf.rxen, r_pwdata[1])
        );
        P_RXEN_CHANGE: assert property( 
            P_FF_CHANGE(_clkrst_intf.clk, _clkrst_intf.resetn, _spictrl_intf.rxen, _clkrst_intf.resetn, r_psel[0] && !r_psel[1] && (r_paddr == 1) && r_pwrite)
        );

        //--------------------------------------------------------
        //	TXSTART - Start transmit register   
        //--------------------------------------------------------
        P_TXSTART_RESET: assert property( 
            P_FF_ARn(_clkrst_intf.clk, _clkrst_intf.resetn, _spictrl_intf.txstart_pulse, 1'b0)
        );
        P_TXSTART_WRITE: assert property( 
            P_FF_ARn_EN_UPDT(_clkrst_intf.clk, _clkrst_intf.resetn, r_psel[0] && !r_psel[1] && (r_paddr == 2) && r_pwrite,_spictrl_intf.txstart_pulse, r_pwdata[0])
        );
        P_TXSTART_ASSERT: assert property( 
            P_FF_AR_ASSERT(_clkrst_intf.clk, _clkrst_intf.resetn, _spictrl_intf.txstart_pulse, _spictrl_intf.txstart_pulse)
        );

        //--------------------------------------------------------
        //	INTCTRL
        //--------------------------------------------------------
        P_CMPLEN_RESET: assert property ( 
            P_FF_ARn(_clkrst_intf.clk, _clkrst_intf.resetn, _int_intf.en, 1'b0)
        );
        P_CMPLEN_WRITE: assert property ( 
            P_FF_ARn_EN_UPDT(_clkrst_intf.clk, _clkrst_intf.resetn, r_psel[0] && !r_psel[1] && (r_paddr == 4) && r_pwrite,_int_intf.en, r_pwdata[0])
        );
        P_CMPLEN_CHANGE: assert property ( 
            P_FF_CHANGE(_clkrst_intf.clk, _clkrst_intf.resetn, _int_intf.en, _clkrst_intf.resetn, r_psel[0] && !r_psel[1] && (r_paddr == 4) && r_pwrite)
        );

        P_CMPLMSK_RESET: assert property ( 
            P_FF_ARn(_clkrst_intf.clk, _clkrst_intf.resetn, _int_intf.msk, 1'b0)
        );
        P_CMPLMSK_WRITE: assert property ( 
            P_FF_ARn_EN_UPDT(_clkrst_intf.clk, _clkrst_intf.resetn, r_psel[0] && !r_psel[1] && (r_paddr == 4) && r_pwrite, _int_intf.msk, r_pwdata[4])
        );
        P_CMPLMSK_CHANGE: assert property ( 
            P_FF_CHANGE(_clkrst_intf.clk, _clkrst_intf.resetn, _int_intf.msk, _clkrst_intf.resetn, r_psel[0] && !r_psel[1] && (r_paddr == 4) && r_pwrite)
        );

        //--------------------------------------------------------
        //	INTSTS
        //--------------------------------------------------------
        P_INTSTS_RESET: assert property ( 
            P_FF_ARn(_clkrst_intf.clk, _clkrst_intf.resetn, _int_intf.clr, 1'b0)
        );
        P_INTSTS_WRITE: assert property ( 
            P_FF_ARn_EN_UPDT(_clkrst_intf.clk, _clkrst_intf.resetn, r_psel[0] && !r_psel[1] && (r_paddr == 5) && r_pwrite, _int_intf.clr, r_pwdata[0])
        );

        P_INTSTS_ASSERT: assert property ( 
            P_FF_AR_ASSERT(
                _clkrst_intf.clk, 
                _clkrst_intf.resetn, 
                _int_intf.clr,
                _int_intf.clr
            )
        );

        //--------------------------------------------------------
        //	APB support feature
        //--------------------------------------------------------
        P_ADDR_WIDTH: assert property ( 
            CHECK_WIDTH_BIT(
                _clkrst_intf.clk,
                _apb_intf.PADDR,
                3
            )
        );

        P_WDATA_WIDTH: assert property ( 
            CHECK_WIDTH_BIT( 
                _clkrst_intf.clk, 
                _apb_intf.PWDATA,
                8
            )
        );

        P_RDATA_WIDTH: assert property ( 
            CHECK_WIDTH_BIT( 
                _clkrst_intf.clk, 
                _apb_intf.PRDATA,
                8
            )
        );

        P_SLVERR_ZERO: assert property ( 
            CHECK_VALUE( 
                _clkrst_intf.clk,
                _apb_intf.PSLVERR,
                0
            )
        );

        //--------------------------------------------------------
        //	APB information Capture
        //--------------------------------------------------------
        P_APBINFO_RESET: assert property (   
            CHECK_INIT_VALUE (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                {r_paddr, r_pwrite, r_pwdata, r_pstrb} ,
                0
            )
        );

        P_APBINFO_NOT_CHANGE: assert property ( 
            P_FF_ARn_EN_UPDT (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                _apb_intf.PSEL == 0 ,
                {r_paddr, r_pwrite, r_pwdata, r_pstrb},
                {r_paddr, r_pwrite, r_pwdata, r_pstrb}
            )
        );

        P_APBINFO_CHANGE: assert property ( 
            P_FF_ARn_EN_UPDT (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                !_clkrst_intf.resetn || (_apb_intf.PSEL == 1 && _clkrst_intf.resetn),
                {r_paddr, r_pwrite, r_pwdata, r_pstrb},
                {_apb_intf.PADDR, _apb_intf.PWRITE, _apb_intf.PWDATA, _apb_intf.PSTRB} 
            )
        );

        //--------------------------------------------------------
        //	Address Decode
        //--------------------------------------------------------
        P_EN_RSTN: assert property ( 
            P_FF_ARn_COND_NOW (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                r_psel[0] && !r_psel[1] && r_paddr == 0,
                {s_en_srstn, s_en_ctrl, s_en_txctrl, s_en_sts, s_en_intctrl,s_en_intsts, s_en_txbuf, s_en_rxbuf},
                8'd128
            )
        );

        P_EN_CTRL: assert property ( 
            P_FF_ARn_COND_NOW (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                r_psel[0] && !r_psel[1] && r_paddr == 1,
                {s_en_srstn, s_en_ctrl, s_en_txctrl, s_en_sts, s_en_intctrl,s_en_intsts, s_en_txbuf, s_en_rxbuf},
                8'd64
            )
        );

        P_EN_TXCTRL: assert property ( 
            P_FF_ARn_COND_NOW (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                r_psel[0] && !r_psel[1] && r_paddr == 2,
                {s_en_srstn, s_en_ctrl, s_en_txctrl, s_en_sts, s_en_intctrl,s_en_intsts, s_en_txbuf, s_en_rxbuf},
                8'd32
            )
        );

        P_EN_STS: assert property ( 
            P_FF_ARn_COND_NOW (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                r_psel[0] && !r_psel[1] && r_paddr == 3,
                {s_en_srstn, s_en_ctrl, s_en_txctrl, s_en_sts, s_en_intctrl,s_en_intsts, s_en_txbuf, s_en_rxbuf},
                8'd16
            )
        );
        P_EN_INTCTRL: assert property ( 
            P_FF_ARn_COND_NOW (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                r_psel[0] && !r_psel[1] && r_paddr == 4,
                {s_en_srstn, s_en_ctrl, s_en_txctrl, s_en_sts, s_en_intctrl,s_en_intsts, s_en_txbuf, s_en_rxbuf},
                8'd8
            )
        );

        P_EN_INTSTS: assert property ( 
            P_FF_ARn_COND_NOW (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                r_psel[0] && !r_psel[1] && r_paddr == 5,
                {s_en_srstn, s_en_ctrl, s_en_txctrl, s_en_sts, s_en_intctrl,s_en_intsts, s_en_txbuf, s_en_rxbuf},
                8'd4
            )
        );
       
        P_EN_TXBUF: assert property ( 
            P_FF_ARn_COND_NOW (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                r_psel[0] && !r_psel[1] && r_paddr == 6 && r_pwrite == 1,
                {s_en_srstn, s_en_ctrl, s_en_txctrl, s_en_sts, s_en_intctrl,s_en_intsts, s_en_txbuf, s_en_rxbuf},
                8'd2
            )
        );

        P_EN_RXBUF: assert property ( 
            P_FF_ARn_COND_NOW (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                r_psel[0] && !r_psel[1] && r_paddr == 6 && r_pwrite == 0,
                {s_en_srstn, s_en_ctrl, s_en_txctrl, s_en_sts, s_en_intctrl,s_en_intsts, s_en_txbuf, s_en_rxbuf},
                8'd1
            )
        );

        //--------------------------------------------------------
        //	PREADY and PRDATA Generation
        //--------------------------------------------------------
        P_PREADY_RESET: assert property ( 
            P_FF_ARn (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                _apb_intf.PREADY,
                1'b0
            )
        );

        P_PREADY_WRITE_ASSERT: assert property ( 
            P_FF_ARn_COND_NOW (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                _apb_intf.PWRITE == 1 && _apb_intf.PSEL == 1 && _apb_intf.PENABLE == 0,
                _apb_intf.PREADY,
                1'b1
            )
        );

        P_PREADY_WRITE_DE_ASSERT: assert property ( 
            P_FF_ARn_COND_NOW (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                _apb_intf.PENABLE == 1 && _apb_intf.PSEL ==1 ,
                _apb_intf.PREADY,
                1'b0
            )
        );

        P_PREADY_READ_ASSERT: assert property ( 
                @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
                (r_psel[0] == 1) |=> _apb_intf.PREADY == 1'b1 
            
        );

        P_PREADY_READ_DE_ASSERT: assert property ( 
                @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
                (_apb_intf.PENABLE == 1 && _apb_intf.PSEL ==1) |=> _apb_intf.PREADY == 1'b0
            
        );

        P_PREADY_UNCHANGE: assert property ( 
            P_FF_ARn_COND_UCHANGE (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                _apb_intf.PSEL == 0,
                _apb_intf.PREADY
            )
        );

        P_PRDATA_ZERO: assert property ( 
            P_FF_COND_UPDT (
                _clkrst_intf.clk,
                !_clkrst_intf.resetn || (_clkrst_intf.resetn && r_psel == 2'b00),
                _apb_intf.PRDATA,
                1'b0
            )
        );
        P_PRDATA_CHANGE: assert property ( 
            P_FF_ARn_COND_WAIT (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                r_psel[0] == 1 && r_psel[1] ==0 && r_pwrite == 0,
                _apb_intf.PRDATA,
                s_rdata
            )
        );

        P_RDATA_UCHANGE: assert property ( 
            P_FF_ARn_COND_UCHANGE (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                r_psel[0]==0||(r_psel[1]==0 && r_psel[0]==1 && r_pwrite == 1),
                _apb_intf.PRDATA
            )
        );

        P_DATA_DEFAULT: assert property ( 
            CHECK_VALUE_COND (
                _clkrst_intf.clk,
                {s_en_srstn, s_en_ctrl, s_en_txctrl, s_en_sts, s_en_intctrl, s_en_intsts, s_en_rxbuf} == 7'd0,
                s_rdata,
                8'b0
            )
        );
        P_DATA_SRST: assert property ( 
            CHECK_VALUE_COND (
                _clkrst_intf.clk,
                {s_en_srstn, s_en_ctrl, s_en_txctrl, s_en_sts, s_en_intctrl, s_en_intsts, s_en_rxbuf} == 7'd64,
                s_rdata,
                {7'b0, _clkrst_intf.srstn}
            )
        );
        P_DATA_CTRL: assert property ( 
            CHECK_VALUE_COND (
                _clkrst_intf.clk,
                {s_en_srstn, s_en_ctrl, s_en_txctrl, s_en_sts, s_en_intctrl, s_en_intsts, s_en_rxbuf} == 7'd32,
                s_rdata,
                {6'b0, _spictrl_intf.rxen, _spictrl_intf.txen}
            )
        );
        P_DATA_TXCTRL: assert property ( 
            CHECK_VALUE_COND (
                _clkrst_intf.clk,
                {s_en_srstn, s_en_ctrl, s_en_txctrl, s_en_sts, s_en_intctrl, s_en_intsts, s_en_rxbuf} == 7'd16,
                s_rdata,
                8'b0
            )
        );
        P_DATA_STS: assert property ( 
            CHECK_VALUE_COND (
                _clkrst_intf.clk,
                {s_en_srstn, s_en_ctrl, s_en_txctrl, s_en_sts, s_en_intctrl, s_en_intsts, s_en_rxbuf} == 7'd8,
                s_rdata,
                {_spictrl_intf.txcmpl, 1'b0, _spictrl_intf.crc_err, _spictrl_intf.len_err, _rx_bufw_intf.wfull, _rx_bufr_intf.rempty, _tx_bufw_intf.wfull, _tx_bufr_intf.rempty}
            )
        );
        P_DATA_INTCTRL: assert property ( 
            CHECK_VALUE_COND (
                _clkrst_intf.clk,
                {s_en_srstn, s_en_ctrl, s_en_txctrl, s_en_sts, s_en_intctrl, s_en_intsts, s_en_rxbuf} == 7'd4,
                s_rdata,
                {3'b0, _int_intf.msk, 3'b0, _int_intf.en}
            )
        );
        P_DATA_INTSTS: assert property ( 
            CHECK_VALUE_COND (
                _clkrst_intf.clk,
                {s_en_srstn, s_en_ctrl, s_en_txctrl, s_en_sts, s_en_intctrl, s_en_intsts, s_en_rxbuf} == 7'd2,
                s_rdata,
                {7'b0, _int_intf.fl}
            )
        );
        P_DATA_RXBUF: assert property ( 
            CHECK_VALUE_COND (
                _clkrst_intf.clk,
                {s_en_srstn, s_en_ctrl, s_en_txctrl, s_en_sts, s_en_intctrl, s_en_intsts, s_en_rxbuf} == 7'd1,
                s_rdata,
                _rx_bufr_intf.rdata && {8{_rx_bufr_intf.rempty}}
            )
        );

        //--------------------------------------------------------
        //	Buffer Control
        //--------------------------------------------------------
        P_TXBUF_WEN: assert property ( 
                @(posedge _clkrst_intf.clk)
                $changed({r_psel,_spictrl_intf.txen, r_pwrite})
                |-> _tx_bufw_intf.wen == (r_psel[0] && !r_psel[1]  && r_pwrite && r_paddr == 6)
            
        );



        P_TXBUF_WDATA: assert property ( 
            CHECK_UPDT (
                _clkrst_intf.clk,
                r_pwdata,
                _tx_bufw_intf.wdata,
                r_pwdata
            )
        );

        P_RXBUF_REN: assert property ( 
            CHECK_UPDT (
                _clkrst_intf.clk,
                {r_psel,_spictrl_intf.txen, r_pwrite},
                _rx_bufr_intf.ren,
                r_psel[0] && !r_psel[1] && !r_pwrite && r_paddr == 6
            )
        );


        //--------------------------------------------------------
        //	Transmission and Reception Buffer
        //--------------------------------------------------------
        P_RXBUF_DWIDTH_W: assert property ( 
            CHECK_WIDTH_BIT (
                _clkrst_intf.clk,
                _rx_bufw_intf.wdata,
                8
            )
        );

        P_RXBUF_DWIDTH_R: assert property ( 
            CHECK_WIDTH_BIT (
                _clkrst_intf.clk,
                _rx_bufr_intf.rdata,
                8
            )
        );

        P_TXBUF_DWIDTH_W: assert property ( 
            CHECK_WIDTH_BIT (
                _clkrst_intf.clk,
                _tx_bufw_intf.wdata,
                8
            )
        );

        P_TXBUF_DWIDTH_R: assert property ( 
            CHECK_WIDTH_BIT (
                _clkrst_intf.clk,
                _tx_bufr_intf.rdata,
                8
            )
        );

        P_TXBUF_WIDX_RST: assert property ( 
            P_FF_ARn (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                txbuf_widx, 
                0
            )
        );  

        // roll in them same segment
        P_TXBUF_WIDX_UPDT_SAME_SEG: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (_tx_bufw_intf.wen == 1 && !_tx_bufw_intf.wfull && txbuf_widx[$clog2(P_DEPTH)-1:0] != P_DEPTH-1) |=> txbuf_widx == $past(txbuf_widx) + 1'b1
        );

        // roll to new segment
        P_TXBUF_WIDX_UPDT_NEXT_SEG: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (_tx_bufw_intf.wen == 1 && !_tx_bufw_intf.wfull && txbuf_widx[$clog2(P_DEPTH)-1:0] == P_DEPTH-1) |=> txbuf_widx[$clog2(P_DEPTH)-1:0] == 0
        );
        

        P_TXBUF_WIDX_CHANGE: assert property ( 
            P_FF_CHANGE (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                txbuf_widx,
                _clkrst_intf.resetn,
                _tx_bufw_intf.wen
            )
        );

        P_RXBUF_WIDX_RST: assert property ( 
            P_FF_ARn (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                rxbuf_ridx, 
                0
            )
        );  

        // roll in them same segment
        P_RXBUF_WIDX_UPDT_SAME_SEG: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (_rx_bufw_intf.wen == 1 && !_rx_bufw_intf.wfull && rxbuf_widx[$clog2(P_DEPTH)-1:0] != P_DEPTH-1) |=> rxbuf_widx == $past(rxbuf_widx) + 1'b1
        );

        // roll to new segment
        P_RXBUF_WIDX_UPDT_NEXT_SEG: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (_rx_bufw_intf.wen == 1 && !_rx_bufw_intf.wfull && rxbuf_widx[$clog2(P_DEPTH)-1:0] == P_DEPTH-1) |=> rxbuf_widx[$clog2(P_DEPTH)-1:0] == 0
        );
        

        P_RXBUF_WIDX_CHANGE: assert property ( 
            P_FF_CHANGE (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                rxbuf_ridx,
                _clkrst_intf.resetn,
                _rx_bufr_intf.ren
            )
        );

        //--------------------------------------------------------
        //	Write in Buffer
        //--------------------------------------------------------
        P_TXBUF_UPDT: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (_tx_bufw_intf.wen && !_tx_bufw_intf.wfull) |=> txbuf_buffer[$past(txbuf_widx[3:0])] ==$past(_tx_bufw_intf.wdata)
        );

        P_RXBUF_UPDT: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (_rx_bufw_intf.wen && !_rx_bufw_intf.wfull ) |=>  rxbuf_buffer[$past(rxbuf_widx[3:0])] == $past(_rx_bufw_intf.wdata)
        );
        
        //--------------------------------------------------------
        //	Output Data Update
        //--------------------------------------------------------
        P_RXBUF_RDATA: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (_rx_bufr_intf.ren == 1) |=> _rx_bufr_intf.rdata == rxbuf_buffer[rxbuf_ridx[P_AWIDTH:0]]
        );
        P_RXBUF_FULL: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (rxbuf_widx == {!rxbuf_ridx[$clog2(P_DEPTH)], rxbuf_ridx[$clog2(P_DEPTH)-1:0]}) |-> _rx_bufw_intf.wfull == 1
        );
        P_RXBUF_EMPTY: assert property (
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (rxbuf_widx == rxbuf_ridx) |-> _rx_bufr_intf.rempty == 1
        );

        P_TXBUF_RDATA: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (_tx_bufr_intf.ren == 1) |-> _tx_bufr_intf.rdata == txbuf_buffer[(txbuf_ridx[P_AWIDTH:0])]
        );

        P_TXBUF_FULL: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (txbuf_widx == {!txbuf_ridx[$clog2(P_DEPTH)], txbuf_ridx[$clog2(P_DEPTH)-1:0]}) |-> _tx_bufw_intf.wfull ==1 
        );
        P_TXBUF_EMPTY: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (txbuf_widx == txbuf_ridx) |-> _tx_bufr_intf.rempty == 1
        );
        
        //--------------------------------------------------------
        //	Synchronizer
        //--------------------------------------------------------
        P_SCLK_SYNC: assert property ( 
            @(posedge _clkrst_intf.clk) 
            (_clkrst_intf.resetn) |=> (r_sclk[0] == $past(_spi_intf.SCLK)) && (r_sclk[1] == $past(r_sclk[0])) && (r_sclk[2] == $past(r_sclk[1]))
        );
        P_SCLK_RISE: assert property ( 
            @(posedge _clkrst_intf.clk) 
            (_clkrst_intf.resetn) |->  w_sclk_rise == (!r_sclk[2] && r_sclk[1])  
        );
        P_SCLK_FALL: assert property ( 
            CHECK_VALUE_COND (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                w_sclk_fall,
                r_sclk[2] && !r_sclk[1]
            )
        );

        P_SCSN_SYNC: assert property ( 
            @(posedge _clkrst_intf.clk) 
            (_clkrst_intf.resetn) |=> (r_scsn[0] == $past(_spi_intf.SCSn)) && (r_scsn[1] == $past(r_scsn[0])) && (r_scsn[2] == $past(r_scsn[1]))
        );
        P_SCSN_RISE: assert property ( 
            CHECK_VALUE_COND (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                w_scsn_rise,
                !r_scsn[2] && r_scsn[1]
            )
        );  
        P_SCSN_FALL: assert property ( 
            CHECK_VALUE_COND (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                w_scsn_fall,
                r_scsn[2] && !r_scsn[1]
            )
        );

        P_PRESETn_SYNC: assert property ( 
            @(posedge _clkrst_intf.clk)  
            (_clkrst_intf.resetn == 1'b0 || _clkrst_intf.resetn == 1'b1 )  |-> ##2  (r_rst_sync[1] == $past(r_rst_sync[0]) && r_rst_sync[0] == $past(_clkrst_intf.resetn)) 
            
        );

        P_SDI_SYNC: assert property (
            @(posedge _clkrst_intf.clk)
            r_sdi[1] == $past(r_sdi[0]) && r_sdi[0] == $past(_spi_intf.MOSI) 
        );

        //--------------------------------------------------------
        //	TX request
        //--------------------------------------------------------
        P_TXREQ_ASSERT: assert property ( 
            P_FF_ARn_SR (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                (_spictrl_intf.txen == 1 && w_scsn_fall == 1 && _spictrl_intf.txstart_pulse == 1) || (w_scsn_rise == 1 && r_tx_latch == 1),
                TX_REQ,
                1'b1
            )
        );
        P_TXREQ_DEALY: assert property ( 
            P_FF_ARn_SR (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                w_scsn_rise == 1 && r_tx_latch == 1 && _spictrl_intf.txen == 1,
                TX_REQ,
                1'b1
            )
        );
        
        P_TXREQ_DEASSERT: assert property ( 
            P_FF_ARn_SR (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                w_bit_cnt == 7 && w_sclk_rise == 1,
                TX_REQ,
                1'b0
            )
        );

        P_TXREQ_RESET: assert property ( 
            @(posedge _clkrst_intf.clk)
            (!_clkrst_intf.resetn) |-> ##2 TX_REQ == 1'b0
        );

       
        
        //--------------------------------------------------------
        //	CRC calculation
        //--------------------------------------------------------
        P_RXCRC_INIT: assert property ( 
            P_FF_ARn_SR (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                w_scsn_fall == 1,
                r_rx_crc,
                8'hFF
            )
        );
        P_RXCRC_UPDT: assert property ( 
            @(posedge _clkrst_intf.clk)
            (w_sclk_fall == 1 && { w_byte_cnt, w_bit_cnt } <= 8'h78) |=> r_rx_crc == $past(w_rx_crc_nxt)
        );

        P_TXCRC_INIT: assert property ( 
            P_FF_ARn_SR (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                w_scsn_fall == 1,
                r_tx_crc,
                8'hFF
            )
        );
        P_TXCRC_DPDT: assert property ( 
            @(posedge _clkrst_intf.clk)
            (w_sclk_rise == 1) |=> r_tx_crc == $past(w_tx_crc_nxt)
        );
        
        //--------------------------------------------------------
        //	Reception data and reception buffer control
        //--------------------------------------------------------
        P_RXDATA_INIT: assert property ( 
            P_FF_ARn_SR (
                _clkrst_intf.clk,
                _clkrst_intf.resetn,
                w_scsn_fall == 1,
                r_rx_data,
                8'h0
            )
        );
        P_RXDATA_UPDT: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (w_sclk_fall == 1 && w_scsn_fall == 0) |=> (r_rx_data == { $past(r_rx_data[7:1]),r_sdi[1]})
        );
        P_RXDATA_CHANGE: assert property( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            $changed(r_rx_data) |-> $past(w_scsn_fall == 1) || $past(w_sclk_fall == 1)
        );
        
        P_RXBUF_WEN: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (w_sclk_fall == 1 && w_bit_cnt == 0 && _spictrl_intf.rxen == 1 && w_byte_cnt > 0 && w_byte_cnt <= 15) |-> _rx_bufw_intf.wen == 1
        );

        //--------------------------------------------------------
        //	SPI frame satatus generation
        //--------------------------------------------------------
        P_CRCSTS_RESET: assert property ( 
            @(posedge _clkrst_intf.clk) 
            (!_clkrst_intf.resetn) |-> _spictrl_intf.crc_err == 0
        );
        P_CRCSTS_CLR: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            ( w_scsn_fall == 1) |=> _spictrl_intf.crc_err == 0
        );
        P_CRCSTS_UPDT: assert property ( 
            @(posedge _clkrst_intf.clk)
            (w_sclk_fall == 1 && ({ w_byte_cnt, w_bit_cnt } == 128)) |=> _spictrl_intf.crc_err == (r_rx_crc != r_rx_data)
        );

        //--------------------------------------------------------
        //	Transimission buffer control and transmit data update
        //--------------------------------------------------------
        P_TXBUF_REN_START: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (w_scsn_fall == 1) |-> _tx_bufr_intf.ren == 1
        );
        P_TXBUF_REN_LOAD: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (w_sclk_rise == 1 && w_bit_cnt == 7 && w_byte_cnt < 14 && _spictrl_intf.txen == 1) |-> _tx_bufr_intf.ren == 1
        );
        P_TXBUF_REN_ASSERT: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            _tx_bufr_intf.ren == 1 |-> w_scsn_fall || (w_sclk_rise == 1 && w_bit_cnt == 7 && w_byte_cnt < 15 && _spictrl_intf.txen == 1)
        );

        P_TXDATA_START: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            w_scsn_fall == 1 |=> r_tx_data ==($past(_tx_bufr_intf.rdata & {8{!_tx_bufr_intf.rempty & _spictrl_intf.txen}}))
        );
        P_TXDATA_LOAD: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (w_sclk_rise ==1 && w_bit_cnt == 7 && w_byte_cnt < 14 ) |=> r_tx_data == $past(_tx_bufr_intf.rdata & {8{!_tx_bufr_intf.rempty & _spictrl_intf.txen}})
        );
        P_TXDATA_CRC: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (w_sclk_rise ==1 && w_bit_cnt == 7 && w_byte_cnt == 15) |=> r_tx_data == (r_tx_crc && {8{_spictrl_intf.txen}})
        );

        //--------------------------------------------------------
        //	SPI output data update
        //--------------------------------------------------------
        P_SDO_RESET: assert property ( 
            @(posedge _clkrst_intf.clk) 
            (!_clkrst_intf.resetn) |-> _spi_intf.MISO == 1'b0
        );
        P_SDO: assert property ( 
            @(posedge _spi_intf.SCLK) disable iff (_spi_intf.SCSn)
            (1) |=> (_spi_intf.MISO == $past(r_tx_data[w_bit_cnt]))
            // @(posedge _spi_intf.SCLK)  
            // (!_spi_intf.SCSn) |=> (_spi_intf.MISO == $past(r_tx_data[w_bit_cnt]))
        );

        //--------------------------------------------------------
        //	Interrupt Controller
        //--------------------------------------------------------
        P_INTFL_RESET: assert property ( 
            @(posedge _clkrst_intf.clk) 
            (!_clkrst_intf.resetn || !_clkrst_intf.srstn) |-> _int_intf.fl == 1'b0
        );
        P_INTFL_SET: assert property ( 
            @(posedge _clkrst_intf.clk) disable iff (!_clkrst_intf.resetn)
            (_int_intf.en == 1 && cmpl_pls == 1) |=> _int_intf.fl == 1'b1
        );
        P_INTFL_CLR: assert property ( 
            @(posedge _clkrst_intf.clk) 
            (!(_int_intf.en && cmpl_pls) && _int_intf.clr ) |=> _int_intf.fl == 1'b0
        );
        P_INTF_CHANGE: assert property (
            @(posedge _clkrst_intf.clk) 
            $changed(_int_intf.fl) |-> $past(!(_int_intf.en && cmpl_pls) && _int_intf.clr ) == 1 || (!_clkrst_intf.resetn || !_clkrst_intf.srstn) ==1 ||  $past((_int_intf.en == 1 && cmpl_pls == 1)) == 1
        );
        


endmodule