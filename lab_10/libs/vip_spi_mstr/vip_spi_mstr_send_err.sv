`ifndef __VIP_SPI_MSTR_SEND_ERR__
`define __VIP_SPI_MSTR_SEND_ERR__

class vip_spi_mstr_send_err extends uvm_sequence #(vip_spi_mstr_req, vip_spi_mstr_resp);
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    rand    logic   [ 7 : 0 ]   _payload[]  ;
    vip_spi_mstr_resp           _resp       ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_param_utils(vip_spi_mstr_send_err)

    //-------------------------------------------------------------------------
    //  Constraints
    //-------------------------------------------------------------------------
    constraint DEF_LENGTH   { soft _payload.size() == 20; }

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_spi_mstr_send_err");
        super.new(name);
    endfunction

    //  Body
    //  Arguments   : None
    virtual task body();
        vip_spi_mstr_req    _item   ;

        `uvm_do_with(_item, {
            _req_type           == SPI_FRAME_SEND   ;
            _req_payload.size() == _payload.size()   ;
            foreach (_req_payload[i]) _req_payload[i] == _payload[i];
        } )
        _item._req_crc            = crc_cal(_item._req_payload) + 1;
        
        _resp   = null;
        get_response(_resp);

    endtask

endclass

`endif
