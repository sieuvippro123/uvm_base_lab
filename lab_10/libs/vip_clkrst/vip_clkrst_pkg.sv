`ifndef __VIP_CLKRST_PKG__
`define __VIP_CLKRST_PKG__

package vip_clkrst_pkg;
    import  uvm_pkg::*;

    typedef enum {
        CLK_START   ,   //  Start generating clock signal
        CLK_STOP    ,   //  Stop generating clock signal
        RST_ASSERT  ,   //  Assert reset signal
        RST_DEASSERT,   //  De-assert reset signal
        CHG_PERIOD  ,   //  Change clock period
        CHG_DUTY        //  Change Duty cycle
    } ENU_CLKRST_ACTION;

    `include "uvm_macros.svh"

    `include "vip_clkrst_action.sv"
    `include "vip_clkrst_bseq.sv"
    `include "vip_clkrst_start_clk.sv"
    `include "vip_clkrst_stop_clk.sv"
    `include "vip_clkrst_assert_reset.sv"
    `include "vip_clkrst_deassert_reset.sv"
    `include "vip_clkrst_change_duty.sv"
    `include "vip_clkrst_change_period.sv"
    `include "vip_clkrst_seqr.sv"
    `include "vip_clkrst_drv.sv"
    `include "vip_clkrst_agent.sv"

endpackage

`endif
