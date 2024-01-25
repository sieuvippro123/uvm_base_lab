/*
 *-----------------------------------------------------------------------------
 *  Module      :   intf_bufw
 *  Project     :   SPI slave peripheral
 *  Author      :   Truong.Nguyen
 *  Created     :   06/25/2020
 *  Description :
 *                  This interface contains all signals to control write path of FIFO
 *
 *  History     :
 *  Date        By              Base Rev.   Change Description
 *  06-25-2020  Truong.Nguyen   NA          Initial create
 *-----------------------------------------------------------------------------
 */
interface intf_bufw();
    //-------------------------------------------------------------------------
    //  Parameter Declaration
    //-------------------------------------------------------------------------
    localparam      P_DWIDTH        = 8     ;   //  Buffer data bus width

    //-------------------------------------------------------------------------
    //  APB bus signals
    //-------------------------------------------------------------------------
    logic                           wen     ;   //  Buffer write enable
    logic   [ P_DWIDTH  - 1 : 0 ]   wdata   ;   //  Buffer write data
    logic                           wfull   ;   //  Buffer full status

    modport DRIVER(
        output  wen     ,
        output  wdata   ,
        input   wfull
    );

    modport TARGET(
        input   wen     ,
        input   wdata   ,
        output  wfull
    );

    modport MONITOR(
        input   wen     ,
        input   wdata   ,
        output  wfull
    );

endinterface : intf_bufw