`ifndef __VIP_CLKRST_BSEQ__
`define __VIP_CLKRST_BSEQ__

class vip_clkrst_bseq extends uvm_sequence#(vip_clkrst_action);
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(vip_clkrst_bseq)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_clkrst_bseq");
        super.new(name);
    endfunction

    //  Body
    //  Arguments   : None
    virtual task body();
        vip_clkrst_action   _item   ;

        //repeat (5) begin
        //    `uvm_do(_item)
        //end

        #100ns;
        `uvm_do_with(_item, { _action == CLK_START;     } )
        #100ns;
        `uvm_do_with(_item, { _action == RST_ASSERT;    } )
        #100ns;
        `uvm_do_with(_item, { _action == RST_DEASSERT;  } )

    endtask

endclass

`endif
