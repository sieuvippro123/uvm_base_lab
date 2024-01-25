`ifndef __VIP_SPI_MSTR_PKG__
`define __VIP_SPI_MSTR_PKG__

package vip_spi_mstr_pkg;
    import  uvm_pkg::*;

    typedef enum {
        SPI_FRAME_SEND  ,   //  Send a SPI frame to slave, receive response frame from slave
        SPI_FRAME_RECEIVE   //  Send IDLE frame to slave, receive response frame from slave
    } ENU_SPI_REQUEST;

    typedef enum {
        ENU_SPI_NORMAL   ,  //  Response frame completes successfully
        ENU_SPI_CRC_ERROR   //  Response frame has CRC error
    } ENU_SPI_STATUS;

    function automatic logic[7:0] crc_cal(logic[7:0] data[]);
        logic   [ 7 : 0 ]   result  ;
        logic               feedback;

        result  = '1;
        for (int i = 0; i < data.size(); i++) begin
            for (int j = 0; j < 8; j++) begin
                feedback    = result[7] ^ data[i][j];
                result[7]   = result[6];
                result[6]   = result[5];
                result[5]   = result[4] ^ feedback;
                result[4]   = result[3] ^ feedback;
                result[3]   = result[2];
                result[2]   = result[1];
                result[1]   = result[0];
                result[0]   = feedback;
            end
        end

        return result;
    endfunction

    `include "uvm_macros.svh"

    `include "vip_spi_mstr_req.sv"
    `include "vip_spi_mstr_resp.sv"
    `include "vip_spi_mstr_seqr.sv"
    `include "vip_spi_mstr_send.sv"
    `include "vip_spi_mstr_send_err.sv"
    `include "vip_spi_mstr_recv.sv"
    `include "vip_spi_mstr_drv.sv"
    `include "vip_spi_mstr_agent.sv"

endpackage

`endif
