/*
 *-----------------------------------------------------------------------------
 *  Module      :   std_lib
 *  Project     :   NA
 *  Author      :   Truong.Nguyen
 *  Created     :   06/25/2020
 *  Description :
 *                  Standard library
 *
 *  History     :
 *  Date        By              Base Rev.   Change Description
 *  06-25-2020  Truong.Nguyen   NA          Initial create
 *-----------------------------------------------------------------------------
 */

//  RW register field
module std_rw_reg #(
    parameter   P_DWIDTH    = 1,
    parameter   P_RESET     = 0
) (
    input                                   clk     ,
    input                                   resetn  ,
    input                                   enable  ,
    input           [ P_DWIDTH  - 1 : 0 ]   din     ,
    output  logic   [ P_DWIDTH  - 1 : 0 ]   dout
);
    //-------------------------------------------------------------------------
    //  Sequential assignments
    //-------------------------------------------------------------------------
    always_ff @(posedge clk, negedge resetn) begin
        if      (!resetn)   dout    <= P_RESET  ;
        else if ( enable)   dout    <= din      ;
    end

endmodule

//  WAC register field
module std_wac_reg #(
    parameter   P_DWIDTH    = 1,
    parameter   P_RESET     = 0
) (
    input                                   clk     ,
    input                                   resetn  ,
    input                                   enable  ,
    input           [ P_DWIDTH  - 1 : 0 ]   din     ,
    output  logic   [ P_DWIDTH  - 1 : 0 ]   dout
);
    //-------------------------------------------------------------------------
    //  Sequential assignments
    //-------------------------------------------------------------------------
    always_ff @(posedge clk, negedge resetn) begin
        if      (!resetn)   dout    <= P_RESET  ;
        else if ( enable)   dout    <= din      ;
        else                dout    <= 0        ;
    end

endmodule

//  RW1C register field
module std_rw1c_reg #(
    parameter   P_DWIDTH    = 1
) (
    input                                   clk     ,
    input                                   resetn  ,
    input                                   enable  ,
    input           [ P_DWIDTH  - 1 : 0 ]   din     ,
    output  logic   [ P_DWIDTH  - 1 : 0 ]   dout
);
    //-------------------------------------------------------------------------
    //  Sequential assignments
    //-------------------------------------------------------------------------
    always_ff @(posedge clk, negedge resetn) begin
        if      (!resetn)   dout    <= 0    ;
        else if ( enable)   dout    <= din  ;
        else                dout    <= 0;
    end

endmodule
