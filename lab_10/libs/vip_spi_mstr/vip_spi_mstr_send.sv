`ifndef __VIP_SPI_MSTR_SEND__
`define __VIP_SPI_MSTR_SEND__

class vip_spi_mstr_send extends uvm_sequence #(vip_spi_mstr_req, vip_spi_mstr_resp);
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    rand    logic   [ 7 : 0 ]   _payload[]  ;
    vip_spi_mstr_resp           _resp       ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_param_utils(vip_spi_mstr_send)

    //-------------------------------------------------------------------------
    //  Constraints
    //-------------------------------------------------------------------------
    constraint DEF_LENGTH   { soft _payload.size() == 15; }

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_spi_mstr_send");
        super.new(name);
    endfunction

    //  Body
    //  Arguments   : None
    virtual task body();
        vip_spi_mstr_req    _item   ;

        `uvm_do_with(_item, {
            _req_type           == SPI_FRAME_SEND   ;
            _req_payload.size() == _payload.size()  ;
            foreach (_req_payload[i]) _req_payload[i] == _payload[i];
            // _req_crc            == 8'b1;
        } )
        _item._req_crc            = crc_cal(_item._req_payload);
        
        _resp   = null;
        get_response(_resp);

    endtask

endclass

`endif
