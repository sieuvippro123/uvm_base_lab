`ifndef __VIP_SPI_MSTR_RECV__
`define __VIP_SPI_MSTR_RECV__

class vip_spi_mstr_recv extends uvm_sequence #(vip_spi_mstr_req, vip_spi_mstr_resp);
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    vip_spi_mstr_resp           _resp       ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_param_utils(vip_spi_mstr_recv)

    //-------------------------------------------------------------------------
    //  Constraints
    //-------------------------------------------------------------------------

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "vip_spi_mstr_recv");
        super.new(name);
    endfunction

    //  Body
    //  Arguments   : None
    virtual task body();
        vip_spi_mstr_req    _item   ;

        `uvm_do_with(_item, {
            _req_type           == SPI_FRAME_RECEIVE;
            _req_payload.size() == 15               ;
            foreach (_req_payload[i]) _req_payload[i] == 0;
        } )
        _resp   = null;
        get_response(_resp);

    endtask

endclass

`endif
