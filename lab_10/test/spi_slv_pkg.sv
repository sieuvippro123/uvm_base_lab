`ifndef __SPI_SLV_PKG__
`define __SPI_SLV_PKG__

package spi_slv_pkg;
    import uvm_pkg::*;
    import vip_clkrst_pkg::*;
    import vip_sig_mnt_pkg::*;
    import vip_spi_mstr_pkg::*;
    import vip_apb_mstr_pkg::*;

    localparam  P_ADDR_WIDTH    = 3;
    localparam  P_DATA_WIDTH    = 8;

    typedef vip_apb_mstr_wrapper#(P_ADDR_WIDTH, P_DATA_WIDTH) spi_slv_mstr;
    typedef spi_slv_mstr::AGENT spi_slv_mstr_AGENT;

    `include "uvm_macros.svh"

    `include "spi_slv_msg_demoter.sv"
    `include "spi_slv_apb_mnt.sv"
    `include "spi_slv_apb_mstr_agent.sv"
    `include "spi_slv_reg_model.sv"
    `include "spi_slv_sb.sv"
    `include "spi_slv_scrb.sv"

    `include "spi_slv_seqr.sv"
    `include "spi_slv_seq_base.sv"
    `include "spi_slv_seq_por.sv"
    `include "spi_slv_seq_host_init.sv"
    `include "spi_slv_seq_device_init.sv"

    `include "spi_slv_env.sv"
    `include "spi_slv_test.sv"
    `include "spi_slv_test_reg.sv"

    `include "spi_slv_test_host_init.sv"
    `include "spi_slv_test_device_init.sv"
    // `include "spi_slv_seq_host_trans_cmpl_crcerr.sv"
endpackage

`endif
