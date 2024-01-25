/*
 *-----------------------------------------------------------------------------
 *  Module      :   intf_spi
 *  Project     :   SPI slave peripheral
 *  Author      :   Truong.Nguyen
 *  Created     :   06/25/2020
 *  Description :
 *                  This interface contains all signals of SPI bus
 *
 *  History     :
 *  Date        By              Base Rev.   Change Description
 *  06-25-2020  Truong.Nguyen   NA          Initial create
 *-----------------------------------------------------------------------------
 */
interface intf_spi();
    //-------------------------------------------------------------------------
    //  APB bus signals
    //-------------------------------------------------------------------------
    logic                           SCLK    ;   //  SPI clock
    logic                           SCSn    ;   //  SPI chip select
    logic                           MOSI    ;   //  SPI master-to-slave data
    logic                           MISO    ;   //  SPI slave-to-master data

    modport SLAVE (
        input   SCLK    ,
        input   SCSn    ,
        input   MOSI    ,
        output  MISO
    );

    modport MASTER(
        output  SCLK    ,
        output  SCSn    ,
        output  MOSI     ,
        input   MISO
    );

    modport MONITOR(
        input   SCLK    ,
        input   SCSn    ,
        input   MOSI    ,
        input   MISO
    );

endinterface : intf_spi