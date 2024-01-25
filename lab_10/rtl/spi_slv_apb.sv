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
module spi_slv_apb(
    intf_apb        .SLAVE      _intf_apb       ,
    intf_spictrl    .APB        _intf_spictrl   ,
    intf_int        .APB        _intf_int       ,
    intf_bufw       .DRIVER     _intf_bufw      ,
    intf_bufr       .DRIVER     _intf_bufr      ,
    output                      srstn           ,
    input                       rxbuf_full      ,
    input                       txbuf_empty
);
    //-------------------------------------------------------------------------
    //  Parameter Declaration
    //-------------------------------------------------------------------------
    localparam      P_AWIDTH    = 3             ;   //  APB address bus width
    localparam      P_DWIDTH    = 8             ;   //  APB data bus width
    localparam      P_SWIDTH    = P_DWIDTH / 8  ;   //  APB strobe width

    //-------------------------------------------------------------------------
    //  Internal signal declaration
    //-------------------------------------------------------------------------
    //  APB information register
    logic   [ P_AWIDTH  - 1 : 0 ]   r_paddr         ;
    logic                           r_pwrite        ;
    logic   [ P_DWIDTH  - 1 : 0 ]   r_pwdata        ;
    logic   [ P_SWIDTH  - 1 : 0 ]   r_pstrb         ;
    logic   [             1 : 0 ]   r_psel          ;

    //  Address decoder
    logic                           s_en_srstn      ;
    logic                           s_en_ctrl       ;
    logic                           s_en_txctrl     ;
    logic                           s_en_sts        ;
    logic                           s_en_intctrl    ;
    logic                           s_en_intsts     ;
    logic                           s_en_txbuf      ;
    logic                           s_en_rxbuf      ;
    logic   [ P_DWIDTH  - 1 : 0 ]   s_rdata         ;

    logic                           s_en_srstn_w    ;
    logic                           s_en_ctrl_w     ;
    logic                           s_en_txctrl_w   ;
    logic                           s_en_intctrl_w  ;
    logic                           s_en_intsts_w   ;

    //-------------------------------------------------------------------------
    //  Combinational assignments
    //-------------------------------------------------------------------------
    assign  s_en_srstn      = r_psel[0] && !r_psel[1] && (r_paddr == 0);
    assign  s_en_ctrl       = r_psel[0] && !r_psel[1] && (r_paddr == 1);
    assign  s_en_txctrl     = r_psel[0] && !r_psel[1] && (r_paddr == 2);
    assign  s_en_sts        = r_psel[0] && !r_psel[1] && (r_paddr == 3);
    assign  s_en_intctrl    = r_psel[0] && !r_psel[1] && (r_paddr == 4);
    assign  s_en_intsts     = r_psel[0] && !r_psel[1] && (r_paddr == 5);
    assign  s_en_txbuf      = r_psel[0] && !r_psel[1] && (r_paddr == 6) &&  r_pwrite;
    assign  s_en_rxbuf      = r_psel[0] && !r_psel[1] && (r_paddr == 6) && !r_pwrite;

    assign  s_en_srstn_w    = r_pwrite && s_en_srstn    ;
    assign  s_en_ctrl_w     = r_pwrite && s_en_ctrl     ;
    assign  s_en_txctrl_w   = r_pwrite && s_en_txctrl   ;
    assign  s_en_intctrl_w  = r_pwrite && s_en_intctrl  ;
    assign  s_en_intsts_w   = r_pwrite && s_en_intsts   ;

    assign  _intf_bufw.wen  = r_psel[0] && !r_psel[1] && (r_paddr == 6) &&  r_pwrite;
    assign  _intf_bufw.wdata= r_pwdata;
    assign  _intf_bufr.ren  = r_psel[0] && !r_psel[1] && (r_paddr == 6) && !r_pwrite;

    assign  _intf_apb.PSLVERR   = 0;

    always_comb begin
        s_rdata = 0;
        case (1)
            s_en_srstn  : s_rdata   = { 7'b0, srstn};
            s_en_ctrl   : s_rdata   = { 6'b0, _intf_spictrl.rxen, _intf_spictrl.txen};
            s_en_sts    : s_rdata   = { _intf_spictrl.txcmpl    ,
                                        1'b0                    ,
                                        _intf_spictrl.crc_err   ,
                                        _intf_spictrl.len_err   ,
                                        rxbuf_full              ,
                                        _intf_bufr.rempty       ,
                                        _intf_bufw.wfull        ,
                                        txbuf_empty
                                      };
            s_en_intctrl: s_rdata   = { 3'b0                    ,
                                        _intf_int.msk           ,
                                        3'b0                    ,
                                        _intf_int.en
                                      };
            s_en_intsts : s_rdata   = { 7'b0, _intf_int.fl};
            s_en_rxbuf  : s_rdata   = _intf_bufr.rdata & {8{!_intf_bufr.rempty}};
        endcase
    end

    //-------------------------------------------------------------------------
    //  Sequential assignments
    //-------------------------------------------------------------------------
    //  APB information
    //      Update when PSEL = 1
    always_ff @(posedge _intf_apb.PCLK, negedge _intf_apb.PRESETn) begin
        if (!_intf_apb.PRESETn) begin
            r_paddr     <= '0;
            r_pwrite    <= '0;
            r_pwdata    <= '0;
            r_pstrb     <= '0;
        end
        else if (_intf_apb.PSEL) begin
            r_paddr     <= _intf_apb.PADDR  ;
            r_pwrite    <= _intf_apb.PWRITE ;
            r_pwdata    <= _intf_apb.PWDATA ;
            r_pstrb     <= _intf_apb.PSTRB  ;
        end
    end

    //  PREADY
    //      - Reset         : 1
    //      - r_psel[0]     : 1
    //      - PSEL          : PWRITE
    always_ff @(posedge _intf_apb.PCLK, negedge _intf_apb.PRESETn) begin
        if      (!_intf_apb.PRESETn )   _intf_apb.PREADY  <= 1;
        else if (r_psel[0]          )   _intf_apb.PREADY  <= 1;
        else if (_intf_apb.PSEL     )   _intf_apb.PREADY  <= _intf_apb.PWRITE;
    end

    //  PRDATA
    //      - Reset         : 0
    //      - r_psel[0]
    //          - r_psel[1] : 0
    //          - !r_pwrite : s_rdata
    always_ff @(posedge _intf_apb.PCLK, negedge _intf_apb.PRESETn) begin
        if      (!_intf_apb.PRESETn )   _intf_apb.PRDATA  <= '0;
        else if (r_psel[0]          ) begin
            if      (r_psel[1]      )   _intf_apb.PRDATA  <= '0;
            else if (!r_pwrite      )   _intf_apb.PRDATA  <= s_rdata;
        end
    end

    //  r_psel
    //      - Reset             : 0
    //      - PENABLE && PREADY : 0
    //      - Other             : {r_psel[0], PSEL}
    always_ff @(posedge _intf_apb.PCLK, negedge _intf_apb.PRESETn) begin
        if      (!_intf_apb.PRESETn                     )   r_psel  <= '0;
        else if ( _intf_apb.PENABLE && _intf_apb.PREADY )   r_psel  <= '0;
        else                                                r_psel  <= {r_psel[0], _intf_apb.PSEL};
    end

    //-------------------------------------------------------------------------
    //  Submodule instance
    //-------------------------------------------------------------------------
    std_rw_reg          SRST    ( .clk( _intf_apb.PCLK ), .resetn( _intf_apb.PRESETn ), .din( r_pwdata[0]                   ), .enable( s_en_srstn_w    ), .dout(   srstn                                       ));
    std_rw_reg  #( 2 )  CTRL    ( .clk( _intf_apb.PCLK ), .resetn( _intf_apb.PRESETn ), .din( r_pwdata[1:0]                 ), .enable( s_en_ctrl_w     ), .dout( { _intf_spictrl.rxen, _intf_spictrl.txen }    ));
    std_wac_reg         TXCTRL  ( .clk( _intf_apb.PCLK ), .resetn( _intf_apb.PRESETn ), .din( r_pwdata[0]                   ), .enable( s_en_txctrl_w   ), .dout(   _intf_spictrl.txstart_pulse                 ));
    std_rw_reg  #( 2 )  INTCTRL ( .clk( _intf_apb.PCLK ), .resetn( _intf_apb.PRESETn ), .din( { r_pwdata[4], r_pwdata[0] }  ), .enable( s_en_intctrl_w  ), .dout( { _intf_int.msk, _intf_int.en            }    ));
    std_wac_reg         INTSTS  ( .clk( _intf_apb.PCLK ), .resetn( _intf_apb.PRESETn ), .din( r_pwdata[0]                   ), .enable( s_en_intsts_w   ), .dout(   _intf_int.clr                               ));

endmodule