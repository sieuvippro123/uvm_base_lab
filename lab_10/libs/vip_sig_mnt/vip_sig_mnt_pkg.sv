`ifndef __VIP_SIG_MNT_PKG__
`define __VIP_SIG_MNT_PKG__

package vip_sig_mnt_pkg;
    import  uvm_pkg::*;

    typedef enum {
        GET_LEVEL   ,   //  Get the current value if monitoring signal
        WAIT_HIGH   ,   //  Wait until monitoring signal level is high
        WAIT_LOW    ,   //  Wait until monitoring signal level is low
        WAIT_RISE   ,   //  Wait until rising edge of monitoring signal is detected
        WAIT_FALL   ,   //  Wait until falling edge of monitoring signal is detected
        WAIT_EDGE       //  Wait until monitoring signal is changed
    } ENU_SIG_MNT_CMD;

    `include "uvm_macros.svh"

    `include "vip_sig_mnt_cmd.sv"
    `include "vip_sig_mnt_resp.sv"
    `include "vip_sig_mnt_get_level.sv"
    `include "vip_sig_mnt_wait_high.sv"
    `include "vip_sig_mnt_wait_low.sv"
    `include "vip_sig_mnt_wait_rise.sv"
    `include "vip_sig_mnt_wait_fall.sv"
    `include "vip_sig_mnt_wait_edge.sv"
    `include "vip_sig_mnt_seqr.sv"
    `include "vip_sig_mnt_drv.sv"
    `include "vip_sig_mnt_agent.sv"

endpackage

`endif
