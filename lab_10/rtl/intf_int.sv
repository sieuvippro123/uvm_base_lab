/*
 *-----------------------------------------------------------------------------
 *  Module      :   intf_int
 *  Project     :   SPI slave peripheral
 *  Author      :   Truong.Nguyen
 *  Created     :   06/25/2020
 *  Description :
 *                  This interface contains interrupt signals
 *
 *  History     :
 *  Date        By              Base Rev.   Change Description
 *  06-25-2020  Truong.Nguyen   NA          Initial create
 *-----------------------------------------------------------------------------
 */
interface intf_int();
    //-------------------------------------------------------------------------
    //  APB bus signals
    //-------------------------------------------------------------------------
    logic       en      ;
    logic       msk     ;
    logic       clr     ;
    logic       fl      ;

    modport APB(
        output  en      ,
        output  msk     ,
        output  clr     ,
        input   fl
    );

    modport CONTROL(
        input   en      ,
        input   msk     ,
        input   clr     ,
        output  fl
    );

    modport MONITOR(
        input   en      ,
        input   msk     ,
        input   clr     ,
        input   fl
    );

endinterface : intf_int