`ifndef __VIP_SPI_MSTR_RESP__
`define __VIP_SPI_MSTR_RESP__

class vip_spi_mstr_resp extends uvm_sequence_item;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    ENU_SPI_STATUS      _resp_type      ;
    logic   [ 7 : 0 ]   _resp_payload[] ;
    logic   [ 7 : 0 ]   _resp_crc       ;


    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_param_utils_begin(vip_spi_mstr_resp)
        `uvm_field_enum     ( ENU_SPI_STATUS    ,   _resp_type      , UVM_ALL_ON    )
        `uvm_field_array_int(                       _resp_payload   , UVM_ALL_ON    )
        `uvm_field_int      (                       _resp_crc       , UVM_ALL_ON    )
    `uvm_object_utils_end

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_spi_mstr_resp");
        super.new(name);
    endfunction

endclass

`endif
