/*
 *-----------------------------------------------------------------------------
 *  Module      :   intf_bufr
 *  Project     :   SPI slave peripheral
 *  Author      :   Truong.Nguyen
 *  Created     :   06/25/2020
 *  Description :
 *                  This interface contains all signals to control read path of FIFO
 *
 *  History     :
 *  Date        By              Base Rev.   Change Description
 *  06-25-2020  Truong.Nguyen   NA          Initial create
 *-----------------------------------------------------------------------------
 */
interface intf_bufr();
    //-------------------------------------------------------------------------
    //  Parameter Declaration
    //-------------------------------------------------------------------------
    localparam      P_DWIDTH        = 8     ;   //  Buffer data bus width

    //-------------------------------------------------------------------------
    //  APB bus signals
    //-------------------------------------------------------------------------
    logic                           ren     ;   //  Buffer read enable
    logic   [ P_DWIDTH  - 1 : 0 ]   rdata   ;   //  Buffer read data
    logic                           rempty  ;   //  Buffer empty status

    modport DRIVER(
        output  ren     ,
        input   rdata   ,
        input   rempty
    );

    modport TARGET(
        input   ren     ,
        output  rdata   ,
        output  rempty
    );

    modport MONITOR(
        input   ren     ,
        input   rdata   ,
        input   rempty
    );

endinterface : intf_bufr