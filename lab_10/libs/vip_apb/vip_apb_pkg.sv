`ifndef __VIP_APB_MSTR_PKG__
`define __VIP_APB_MSTR_PKG__

package vip_apb_mstr_pkg;
    import  uvm_pkg::*;

    typedef enum {
        APB_WRITE   ,   //  Generate write transfer on APB bus
        APB_READ    ,   //  Generate read transfer on APB bus
        APB_IDLE        //  Wait on clock event
    } ENU_APB_TRANS;

    `include "uvm_macros.svh"

    `include "vip_apb_mstr/vip_apb_mstr_trans.sv"
    `include "vip_apb_mstr/vip_apb_mstr_idle.sv"
    `include "vip_apb_mstr/vip_apb_mstr_write.sv"
    `include "vip_apb_mstr/vip_apb_mstr_read.sv"
    `include "vip_apb_mstr/vip_apb_mstr_seqr.sv"
    `include "vip_apb_mstr/vip_apb_mstr_drv.sv"
    `include "vip_apb_mstr/vip_apb_mstr_agent.sv"

    class vip_apb_mstr_wrapper#(
        parameter   P_ADDR_WIDTH    = 8,
        parameter   P_DATA_WIDTH    = 32
    );
        typedef vip_apb_mstr_trans  #(P_ADDR_WIDTH, P_DATA_WIDTH)   TRANS       ;
        typedef vip_apb_mstr_idle   #(P_ADDR_WIDTH, P_DATA_WIDTH)   SEQ_IDLE    ;
        typedef vip_apb_mstr_write  #(P_ADDR_WIDTH, P_DATA_WIDTH)   SEQ_WRITE   ;
        typedef vip_apb_mstr_read   #(P_ADDR_WIDTH, P_DATA_WIDTH)   SEQ_READ    ;
        typedef vip_apb_mstr_seqr   #(P_ADDR_WIDTH, P_DATA_WIDTH)   SEQR        ;
        typedef vip_apb_mstr_drv    #(P_ADDR_WIDTH, P_DATA_WIDTH)   DRV         ;
        typedef vip_apb_mstr_agent  #(P_ADDR_WIDTH, P_DATA_WIDTH)   AGENT       ;
    endclass

endpackage

package vip_apb_inter_pkg;
    import  uvm_pkg::*;

    `include "vip_apb_inter/vip_apb_inter_agent.sv"

endpackage

`endif
