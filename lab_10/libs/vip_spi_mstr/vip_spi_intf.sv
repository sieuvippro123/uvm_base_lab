interface vip_spi_intf();
    //-------------------------------------------------------------------------
    //  Signals
    //-------------------------------------------------------------------------
    logic   SCSn    ;
    logic   SCLK    ;
    logic   MOSI    ;
    logic   MISO    ;

    //-------------------------------------------------------------------------
    //  Modport
    //-------------------------------------------------------------------------
    modport MASTER(
        output  SCSn    ,
        output  SCLK    ,
        output  MOSI    ,
        input   MISO
    );

    modport SLAVE(
        input   SCSn    ,
        input   SCLK    ,
        input   MOSI    ,
        output  MISO
    );

endinterface
