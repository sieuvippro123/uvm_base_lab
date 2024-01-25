interface vip_apb_intf #(
    parameter   P_ADDR_WIDTH    = 8,
    parameter   P_DATA_WIDTH    = 32
) (
    input   PCLK    ,   //  APB clock
    input   PRESETn     //  APB asynchronous active low reset
);
    //-------------------------------------------------------------------------
    //  Local parameters
    //-------------------------------------------------------------------------
    localparam  P_PROT_WIDTH    = 3;
    localparam  P_STRB_WIDTH    = P_DATA_WIDTH / 8;

    //-------------------------------------------------------------------------
    //  Signals
    //-------------------------------------------------------------------------
    logic   [ P_ADDR_WIDTH  - 1 : 0 ]   PADDR   ;
    logic   [ P_PROT_WIDTH  - 1 : 0 ]   PPROT   ;
    logic                               PSEL    ;
    logic                               PENABLE ;
    logic                               PWRITE  ;
    logic   [ P_DATA_WIDTH  - 1 : 0 ]   PWDATA  ;
    logic   [ P_STRB_WIDTH  - 1 : 0 ]   PSTRB   ;
    logic                               PREADY  ;
    logic   [ P_DATA_WIDTH  - 1 : 0 ]   PRDATA  ;
    logic                               PSLVERR ;

    //-------------------------------------------------------------------------
    //  Modport
    //-------------------------------------------------------------------------
    modport MASTER(
        input   PCLK        ,
        input   PRESETn     ,
        output  PADDR       ,
        output  PPROT       ,
        output  PSEL        ,
        output  PENABLE     ,
        output  PWRITE      ,
        output  PWDATA      ,
        output  PSTRB       ,
        input   PREADY      ,
        input   PRDATA      ,
        input   PSLVERR
    );

    modport SLAVE(
        input   PCLK        ,
        input   PRESETn     ,
        input   PADDR       ,
        input   PPROT       ,
        input   PSEL        ,
        input   PENABLE     ,
        input   PWRITE      ,
        input   PWDATA      ,
        input   PSTRB       ,
        output  PREADY      ,
        output  PRDATA      ,
        output  PSLVERR
    );

    modport MONITOR(
        input   PCLK        ,
        input   PRESETn     ,
        input   PADDR       ,
        input   PPROT       ,
        input   PSEL        ,
        input   PENABLE     ,
        input   PWRITE      ,
        input   PWDATA      ,
        input   PSTRB       ,
        input   PREADY      ,
        input   PRDATA      ,
        input   PSLVERR
    );

endinterface
