`ifndef __VIP_SPI_MSTR_REQ__
`define __VIP_SPI_MSTR_REQ__

class vip_spi_mstr_req extends uvm_sequence_item;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    rand    ENU_SPI_REQUEST     _req_type       ;
    rand    bit [ 7 : 0 ]       _req_payload[]  ;
            bit [ 7 : 0 ]       _req_crc        ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_param_utils_begin(vip_spi_mstr_req)
        `uvm_field_enum     ( ENU_SPI_REQUEST   ,   _req_type   , UVM_ALL_ON    )
        `uvm_field_array_int(                       _req_payload, UVM_ALL_ON    )
        `uvm_field_int      (                       _req_crc    , UVM_ALL_ON    )
    `uvm_object_utils_end

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_spi_mstr_req");
        super.new(name);
    endfunction

endclass

`endif
