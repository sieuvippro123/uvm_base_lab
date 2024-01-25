`ifndef __SPI_SLV_MSG_DEMOTER__
`define __SPI_SLV_MSG_DEMOTER__

class spi_slv_msg_demoter extends uvm_report_catcher;
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(spi_slv_msg_demoter)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name="spi_slv_msg_demoter");
        super.new(name);
    endfunction

    //  Report caching
    function action_e catch();
        if (get_id() == "APB_TRANS_ERROR")
            set_severity(UVM_INFO);
        return THROW;
    endfunction

endclass

`endif
