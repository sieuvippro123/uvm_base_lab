`ifndef __VIP_CLKRST_SEQR__
`define __VIP_CLKRST_SEQR__

class vip_clkrst_seqr extends uvm_sequencer #(vip_clkrst_action);
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_utils(vip_clkrst_seqr)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "vip_clkrst_seqr", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass

`endif
