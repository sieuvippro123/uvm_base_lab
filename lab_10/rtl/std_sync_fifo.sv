/*
 *-----------------------------------------------------------------------------
 *  Module      :   std_sync_fifo
 *  Project     :   SPI slave peripheral
 *  Author      :   Truong.Nguyen
 *  Created     :   06/25/2020
 *  Description :
 *                  Standard synchronous FIFO with configurable data width
 *
 *  History     :
 *  Date        By              Base Rev.   Change Description
 *  06-25-2020  Truong.Nguyen   NA          Initial create
 *-----------------------------------------------------------------------------
 */
module std_sync_fifo #(
    parameter   P_DEPTH     = 15,
    parameter   P_DWIDTH    = 8
) (
    intf_clkrst .SYNCASYNC  _intf_clkrst,
    intf_bufw   .TARGET     _intf_bufw  ,
    intf_bufr   .TARGET     _intf_bufr
);
    //-------------------------------------------------------------------------
    //  Parameter Declaration
    //-------------------------------------------------------------------------
    localparam  P_IWIDTH    = $clog2(P_DEPTH) + 1;
    localparam  P_BOUNDARY  = P_DEPTH - 1;

    //-------------------------------------------------------------------------
    //  Internal signal declaration
    //-------------------------------------------------------------------------
    logic   [ P_DEPTH   - 1 : 0 ] [ P_DWIDTH    - 1 : 0 ]   buffer  ;
    logic   [ P_IWIDTH  - 1 : 0 ]                           widx    ;
    logic   [ P_IWIDTH  - 1 : 0 ]                           ridx    ;

    //-------------------------------------------------------------------------
    //  Combinational assignments
    //-------------------------------------------------------------------------
    assign  _intf_bufw.wfull    = ~(|(widx ^ {!ridx[P_IWIDTH-1], ridx[P_IWIDTH-2:0]}));
    assign  _intf_bufr.rempty   = ~(|(widx ^ ridx));
    assign  _intf_bufr.rdata    = buffer[ridx[P_IWIDTH-2:0]];

    //-------------------------------------------------------------------------
    //  Sequential assignments
    //-------------------------------------------------------------------------
    //  buffer
    genvar  idx;
    generate
        for (idx = 0; idx < P_DEPTH; idx++) begin
            always_ff @(posedge _intf_clkrst.clk, negedge _intf_clkrst.resetn) begin
                if      (!_intf_clkrst.resetn)
                    buffer[idx] <= '0;
                else if (!_intf_clkrst.srstn)
                    buffer[idx] <= '0;
                else if (_intf_bufw.wen && !_intf_bufw.wfull && (widx[P_IWIDTH-2:0] == idx))
                    buffer[idx] <= _intf_bufw.wdata;
            end
        end
    endgenerate

    //  widx
    //      - Reset     : 0
    //      - wen
    //          - ren
    //              - Boundary reached  : switch segment
    //              - else              : increase
    //          - !full
    //              - Boundary reached  : switch segment
    //              - else              : increase
    always_ff @(posedge _intf_clkrst.clk, negedge _intf_clkrst.resetn) begin : widx_seq
        if      (!_intf_clkrst.resetn   )   widx    <= '0;
        else if (!_intf_clkrst.srstn    )   widx    <= '0;
        else if (_intf_bufw.wen) begin
            if (_intf_bufr.ren) begin
                if (widx[P_IWIDTH-2:0] == P_BOUNDARY)   widx    <= {!widx[P_IWIDTH-1], {P_IWIDTH-1{1'b0}} };
                else                                    widx    <= widx + 1;
            end
            else if (!_intf_bufw.wfull) begin
                if (widx[P_IWIDTH-2:0] == P_BOUNDARY)   widx    <= {!widx[P_IWIDTH-1], {P_IWIDTH-1{1'b0}} };
                else                                    widx    <= widx + 1;
            end
        end
    end

    //  ridx
    //      - Reset     : 0
    //      - ren
    //          - !empty
    //              - Boundary reached  : switch segment
    //              - else              : increase
    always_ff @(posedge _intf_clkrst.clk, negedge _intf_clkrst.resetn) begin : ridx_seq
        if      (!_intf_clkrst.resetn   )   ridx    <= '0;
        else if (!_intf_clkrst.srstn    )   ridx    <= '0;
        else if (_intf_bufr.ren) begin
            if (!_intf_bufr.rempty) begin
                if (ridx[P_IWIDTH-2:0] == P_BOUNDARY)   ridx    <= {!ridx[P_IWIDTH-1], {P_IWIDTH-1{1'b0}} };
                else                                    ridx    <= ridx + 1;
            end
        end
    end

endmodule