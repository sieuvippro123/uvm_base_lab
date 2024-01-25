/*
 *-----------------------------------------------------------------------------
 *  Module      :   intf_clkrst
 *  Project     :   SPI slave peripheral
 *  Author      :   Truong.Nguyen
 *  Created     :   06/25/2020
 *  Description :
 *                  This interface contains clock and reset used in the design
 *
 *  History     :
 *  Date        By              Base Rev.   Change Description
 *  06-25-2020  Truong.Nguyen   NA          Initial create
 *-----------------------------------------------------------------------------
 */
interface intf_clkrst(
    input                           clk     ,   //  Clock
    input                           resetn  ,   //  Asynchronous active low reset
    input                           srstn       //  Synchronous active low reset
);
    modport ASYNC(
        input   clk     ,
        input   resetn
    );

    modport SYNCASYNC(
        input   clk     ,
        input   resetn  ,
        input   srstn
    );

endinterface : intf_clkrst