/*
 *-----------------------------------------------------------------------------
 *  Module      :   intf_spictrl
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
interface intf_spictrl();
    //-------------------------------------------------------------------------
    //  APB bus signals
    //-------------------------------------------------------------------------
    logic                           txen            ;   //  SPI transmit logic enable
    logic                           rxen            ;   //  SPI receive logic enable
    logic                           txstart_pulse   ;   //  SPI transmit request pulse
    logic                           txcmpl          ;   //  SPI transmision complete
    logic                           crc_err         ;   //  CRC error status
    logic                           len_err         ;   //  SPI frame length error status

    modport APB (
        output  txen            ,
        output  rxen            ,
        output  txstart_pulse   ,
        input   txcmpl          ,
        input   crc_err         ,
        input   len_err
    );

    modport SPI (
        input   txen            ,
        input   rxen            ,
        input   txstart_pulse   ,
        output  txcmpl          ,
        output  crc_err         ,
        output  len_err
    );

    modport MONITOR (
        input   txen            ,
        input   rxen            ,
        input   txstart_pulse   ,
        input   txcmpl          ,
        input   crc_err         ,
        input   len_err
    );

endinterface : intf_spictrl