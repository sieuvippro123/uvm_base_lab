/*
 *-----------------------------------------------------------------------------
 *  Module      :   spi_slv_int
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
module spi_slv_int(
    intf_clkrst .SYNCASYNC  _intf_clkrst    ,
    intf_int    .CONTROL    _intf_int       ,
    input                   cmpl_pls        ,
    output                  INT
);
    //-------------------------------------------------------------------------
    //  Combinational assignments
    //-------------------------------------------------------------------------
    assign  INT     = _intf_int.fl & !_intf_int.msk;

    //-------------------------------------------------------------------------
    //  Sequential assignments
    //-------------------------------------------------------------------------
    always_ff @(posedge _intf_clkrst.clk, negedge _intf_clkrst.resetn) begin
        if      (!_intf_clkrst.resetn       )   _intf_int.fl    <= 0;
        else if ( _intf_int.en && cmpl_pls  )   _intf_int.fl    <= 1;
        else if ( _intf_int.clr             )   _intf_int.fl    <= 0;
    end

endmodule : spi_slv_int