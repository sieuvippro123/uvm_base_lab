/*
 *-----------------------------------------------------------------------------
 *  Module      :   intf_apb
 *  Project     :   SPI slave peripheral
 *  Author      :   Truong.Nguyen
 *  Created     :   06/25/2020
 *  Description :
 *                  This interface contains all signals of APB bus
 *
 *  History     :
 *  Date        By              Base Rev.   Change Description
 *  06-25-2020  Truong.Nguyen   NA          Initial create
 *-----------------------------------------------------------------------------
 */
interface intf_apb(
    input   wire    PCLK    ,
    input   wire    PRESETn
);
    //-------------------------------------------------------------------------
    //  Parameter Declaration
    //-------------------------------------------------------------------------
    localparam      P_AWIDTH    = 3 ;                       //  APB address bus width
    localparam      P_DWIDTH    = 8 ;                       //  APB data bus width
    localparam      P_SWIDTH    = P_DWIDTH / 8;             //  APB strobe width

    //-------------------------------------------------------------------------
    //  APB bus signals
    //-------------------------------------------------------------------------
    logic                           PSEL    ;   //  APB chip select
    logic                           PENABLE ;   //  APB transfer enable
    logic                           PWRITE  ;   //  APB transfer enable
    logic   [ P_AWIDTH  - 1 : 0 ]   PADDR   ;   //  APB address bus
    logic   [ P_DWIDTH  - 1 : 0 ]   PWDATA  ;   //  APB write data bus
    logic   [ P_SWIDTH  - 1 : 0 ]   PSTRB   ;   //  APB write strobe bus
    logic   [ P_DWIDTH  - 1 : 0 ]   PRDATA  ;   //  APB read data bus
    logic                           PREADY  ;   //  APB transfer ready
    logic                           PSLVERR ;   //  APB transfer status

    modport SLAVE (
        input   PCLK    ,
        input   PRESETn ,
        input   PSEL    ,
        input   PENABLE ,
        input   PWRITE  ,
        input   PSTRB   ,
        input   PADDR   ,
        input   PWDATA  ,
        output  PRDATA  ,
        output  PREADY  ,
        output  PSLVERR
    );

    modport MASTER(
        input   PCLK    ,
        input   PRESETn ,
        output  PSEL    ,
        output  PENABLE ,
        output  PWRITE  ,
        output  PSTRB   ,
        output  PADDR   ,
        output  PWDATA  ,
        input   PRDATA  ,
        input   PREADY  ,
        input   PSLVERR
    );

    modport MONITOR(
        input   PCLK    ,
        input   PRESETn ,
        input   PSEL    ,
        input   PENABLE ,
        input   PWRITE  ,
        input   PSTRB   ,
        input   PADDR   ,
        input   PWDATA  ,
        input   PRDATA  ,
        input   PREADY  ,
        input   PSLVERR
    );

endinterface : intf_apb