// `ifndef __VIP_SPI_MSTR_DRV__
// `define __VIP_SPI_MSTR_DRV__

// class vip_spi_mstr_drv extends uvm_driver #(vip_spi_mstr_req, vip_spi_mstr_resp);
//     //-------------------------------------------------------------------------
//     //  Properties
//     //-------------------------------------------------------------------------
//     time                        _t_s2c      ;
//     time                        _t_c2s      ;
//     time                        _t_d2c      ;
//     time                        _t_high     ;
//     time                        _t_low      ;
//     bit                         _latch_edge ;
//     virtual vip_spi_intf.MASTER _intf       ;
//     uvm_analysis_port #(vip_spi_mstr_req)   _sent_port;
//     uvm_analysis_port #(vip_spi_mstr_resp)  _recv_port;

//     //-------------------------------------------------------------------------
//     //  Factory registration
//     //-------------------------------------------------------------------------
//     `uvm_component_param_utils(vip_spi_mstr_drv)

//     //-------------------------------------------------------------------------
//     //  Methods
//     //-------------------------------------------------------------------------
//     //  Constructor
//     //  Arguments
//     //      name    : object's name
//     //      parent  : pointer to parrent of the object
//     function new(string name = "vip_spi_mstr_drv", uvm_component parent = null);
//         super.new(name, parent);
//         _t_s2c      = 100ns;
//         _t_c2s      = 100ns;
//         _t_d2c      = 100ns;
//         _t_high     = 100ns;
//         _t_low      = 100ns;
//         _latch_edge = '0;
//     endfunction

//     //  Build phase
//     //  Arguments
//     //      phase   : UVM phasing object
//     function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         _sent_port  = new("_sent_port", this);
//         _recv_port  = new("_recv_port", this);
//     endfunction

//     //  UVM run phase
//     //  Arguments
//     //      phase   : UVM phasing object
//     task run_phase(uvm_phase phase);
//         vip_spi_mstr_req    _item       ;
//         vip_spi_mstr_resp   _resp       ;
//         logic   [ 7 : 0 ]   _crc        ;
//         time                _period     ;
//         bit     [15 : 0 ]   _bit_idx    ;

//         //  Default value
//         _intf.SCSn  <= '1;
//         _intf.SCLK  <= '0;
//         _intf.MOSI  <= '0;

//         //  Main loop
//         forever begin
//             //  Get request item and create related response
//             seq_item_port.get_next_item(_item);
//             _resp   = vip_spi_mstr_resp::type_id::create("_resp");
//             _resp.set_id_info(_item);

//             //  Empty send request
//             if (_item._req_payload.size() == 0) begin
//                 uvm_report_warning(
//                     "SPI_FRAME_EMPTY"       ,
//                     { "\n", _item.sprint() },
//                     UVM_NONE                ,
//                     `__FILE__               ,
//                     `__LINE__               ,
//                     get_full_name()         ,
//                     1
//                 );
//                 seq_item_port.item_done(_resp);
//                 continue;
//             end

//             //  Calculate CRC for sending frame, allocate buffer for receiving frame
//             _resp._resp_payload  = new[_item._req_payload.size()];
//             _period = _t_high + _t_low;
//             // _crc    = crc_cal(_item._req_payload);
//             _crc    = _item._req_crc;
//             fork
//                 begin
//                     //  Start SPI frame and generate clock
//                     uvm_report_info(
//                         "SPI_FRAME_START"       ,
//                         { "\n", _item.sprint() },
//                         UVM_HIGH                ,
//                         `__FILE__               ,
//                         `__LINE__               ,
//                         get_full_name()         ,
//                         1
//                     );
//                     _intf.SCSn  <= '0;
//                     #(_t_s2c);

//                     //  Clock generation
//                     for (int i = 0; i < _item._req_payload.size() + 1; i++) begin
//                         for (int j = 0; j < 8; j++) begin
//                             _intf.SCLK  <= '1;
//                             #(_t_high);
//                             _intf.SCLK  <= '0;
//                             #(_t_low);
//                         end
//                     end
//                     _sent_port.write(_item);

//                     //  Stop SPI frame
//                     if (_t_c2s > _t_low) #(_t_c2s - _t_low);
//                     _intf.SCSn  <= '1;
//                     if (_resp._resp_type == ENU_SPI_NORMAL) begin
//                         uvm_report_info(
//                             "SPI_FRAME_COMPLETE"    ,
//                             { "\n", _resp.sprint() },
//                             UVM_HIGH                ,
//                             `__FILE__               ,
//                             `__LINE__               ,
//                             get_full_name()         ,
//                             1
//                         );
//                     end
//                 end

//                 begin
//                     //  Wait before sending data
//                     if (_latch_edge) begin
//                         if (_t_s2c > _t_d2c) #(_t_s2c - _t_d2c);
//                     end
//                     else begin
//                         if ((_t_s2c + _t_high) > _t_d2c) #(_t_s2c + _t_high - _t_d2c);
//                     end

//                     //  Send data
//                     for (int i = 0; i < _item._req_payload.size(); i++) begin
//                         for (int j = 0; j < 8; j++) begin
//                             _intf.MOSI  <= _item._req_payload[i][j];
//                             #_period;
//                         end
//                     end
//                     for (int j = 0; j < 8; j++) begin
//                         _intf.MOSI  <= _crc[j];
//                         #_period;
//                     end
//                 end

//                 begin
//                     //  Wait for latching edge
//                     if (_latch_edge)    @(posedge _intf.SCLK);
//                     else                @(negedge _intf.SCLK);

//                     _bit_idx    = 0;
//                     while (_bit_idx < (_item._req_payload.size() * 8 - 1)) begin
//                         _resp._resp_payload[_bit_idx[15:3]][_bit_idx[2:0]] = _intf.MISO;
//                         _bit_idx++;
//                         @(_intf.SCLK);@(_intf.SCLK);
//                     end
//                     _resp._resp_payload[_bit_idx[15:3]][_bit_idx[2:0]] = _intf.MISO;

//                     _bit_idx    = 0;
//                     while (_bit_idx < 8) begin
//                         @(_intf.SCLK);@(_intf.SCLK);
//                         _resp._resp_crc[_bit_idx]   = _intf.MISO;
//                         _bit_idx++;
//                     end

//                     _crc    = crc_cal(_resp._resp_payload);
//                     if (_resp._resp_crc != _crc) begin
//                         _resp._resp_type = ENU_SPI_CRC_ERROR;
//                         uvm_report_error(
//                             "SPI_FRAME_CRC_ERROR"   ,
//                             { $psprintf("Expecting CRC code: 'h%02h\n", _crc), _resp.sprint() },
//                             UVM_NONE                ,
//                             `__FILE__               ,
//                             `__LINE__               ,
//                             "RX CRC check"          ,
//                             1
//                         );
//                     end

//                     fork begin
//                         @(posedge _intf.SCSn);
//                         #0;
//                         _recv_port.write(_resp);
//                     end join_none
//                 end
//             join

//             //  Send response
//             seq_item_port.item_done(_resp);
//         end

//     endtask

// endclass

// `endif

`ifndef __VIP_SPI_MSTR_DRV__
`define __VIP_SPI_MSTR_DRV__

class vip_spi_mstr_drv extends uvm_driver #(vip_spi_mstr_req, vip_spi_mstr_resp);
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    time                        _t_s2c      ;
    time                        _t_c2s      ;
    time                        _t_d2c      ;
    time                        _t_high     ;
    time                        _t_low      ;
    bit                         _latch_edge ;
    virtual vip_spi_intf.MASTER _intf       ;
    uvm_analysis_port #(vip_spi_mstr_req)   _sent_port;
    uvm_analysis_port #(vip_spi_mstr_resp)  _recv_port;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_param_utils(vip_spi_mstr_drv)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "vip_spi_mstr_drv", uvm_component parent = null);
        super.new(name, parent);
        _t_s2c      = 100ns;
        _t_c2s      = 100ns;
        _t_d2c      = 100ns;
        _t_high     = 100ns;
        _t_low      = 100ns;
        _latch_edge = '0;
    endfunction

    //  Build phase
    //  Arguments
    //      phase   : UVM phasing object
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        _sent_port  = new("_sent_port", this);
        _recv_port  = new("_recv_port", this);
    endfunction

    //  UVM run phase
    //  Arguments
    //      phase   : UVM phasing object
    task run_phase(uvm_phase phase);
        vip_spi_mstr_req    _item       ;
        vip_spi_mstr_resp   _resp       ;
        logic   [ 7 : 0 ]   _crc        ;
        time                _period     ;
        bit     [15 : 0 ]   _bit_idx    ;

        //  Default value
        _intf.SCSn  <= '1;
        _intf.SCLK  <= '0;
        _intf.MOSI  <= '0;

        //  Main loop
        forever begin
            //  Get request item and create related response
            seq_item_port.get_next_item(_item);
            _resp   = vip_spi_mstr_resp::type_id::create("_resp");
            _resp.set_id_info(_item);

            //  Empty send request
            if (_item._req_payload.size() == 0) begin
                uvm_report_warning(
                    "SPI_FRAME_EMPTY"       ,
                    { "\n", _item.sprint() },
                    UVM_NONE                ,
                    `__FILE__               ,
                    `__LINE__               ,
                    get_full_name()         ,
                    1
                );
                seq_item_port.item_done(_resp);
                continue;
            end

            //  Calculate CRC for sending frame, allocate buffer for receiving frame
            _resp._resp_payload  = new[_item._req_payload.size()];
            _period = _t_high + _t_low;
            // _crc    = crc_cal(_item._req_payload);/////////////////
            _crc    = _item._req_crc;
            fork
                begin
                    //  Start SPI frame and generate clock
                    uvm_report_info(
                        "SPI_FRAME_START"       ,
                        { "\n", _item.sprint() },
                        UVM_HIGH                ,
                        `__FILE__               ,
                        `__LINE__               ,
                        get_full_name()         ,
                        1
                    );
                    _intf.SCSn  <= '0;
                    #(_t_s2c);
                    $display("\n\n\n\n\n\n\n\n\n\n\n\n\n %d", _item._req_payload.size());
                    //  Clock generation
                    for (int i = 0; i < _item._req_payload.size() + 1; i++) begin
                        for (int j = 0; j < 8; j++) begin
                            _intf.SCLK  <= '1;
                            #(_t_high);
                            _intf.SCLK  <= '0;
                            #(_t_low);
                        end
                    end
                    _sent_port.write(_item);

                    //  Stop SPI frame
                    if (_t_c2s > _t_low) #(_t_c2s - _t_low);
                    _intf.SCSn  <= '1;
                    if (_resp._resp_type == ENU_SPI_NORMAL) begin
                        uvm_report_info(
                            "SPI_FRAME_COMPLETE"    ,
                            { "\n", _resp.sprint() },
                            UVM_HIGH                ,
                            `__FILE__               ,
                            `__LINE__               ,
                            get_full_name()         ,
                            1
                        );
                    end
                end

                begin
                    //  Wait before sending data
                    if (_latch_edge) begin
                        if (_t_s2c > _t_d2c) #(_t_s2c - _t_d2c);
                    end
                    else begin
                        if ((_t_s2c + _t_high) > _t_d2c) #(_t_s2c + _t_high - _t_d2c);
                    end

                    //  Send data
                    for (int i = 0; i < _item._req_payload.size(); i++) begin
                        for (int j = 0; j < 8; j++) begin
                            _intf.MOSI  <= _item._req_payload[i][j];
                            #_period;
                        end
                    end
                    for (int j = 0; j < 8; j++) begin
                        _intf.MOSI  <= _crc[j];
                        #_period;
                    end
                end

                begin
                    //  Wait for latching edge
                    if (_latch_edge)    @(posedge _intf.SCLK);
                    else                @(negedge _intf.SCLK);

                    _bit_idx    = 0;
                    while (_bit_idx < (_item._req_payload.size() * 8 - 1)) begin
                        _resp._resp_payload[_bit_idx[15:3]][_bit_idx[2:0]] = _intf.MISO;
                        _bit_idx++;
                        @(_intf.SCLK);@(_intf.SCLK);
                    end
                    _resp._resp_payload[_bit_idx[15:3]][_bit_idx[2:0]] = _intf.MISO;

                    _bit_idx    = 0;
                    while (_bit_idx < 8) begin
                        @(_intf.SCLK);@(_intf.SCLK);
                        _resp._resp_crc[_bit_idx]   = _intf.MISO;
                        _bit_idx++;
                    end

                    _crc    = crc_cal(_resp._resp_payload);
                    if (_resp._resp_crc != _crc) begin
                        _resp._resp_type = ENU_SPI_CRC_ERROR;
                        uvm_report_error(
                            "SPI_FRAME_CRC_ERROR"   ,
                            { $psprintf("Expecting CRC code: 'h%02h\n", _crc), _resp.sprint() },
                            UVM_NONE                ,
                            `__FILE__               ,
                            `__LINE__               ,
                            "RX CRC check"          ,
                            1
                        );
                    end

                    fork begin
                        @(posedge _intf.SCSn);
                        #0;
                        _recv_port.write(_resp);
                    end join_none
                end
            join

            //  Send response
            seq_item_port.item_done(_resp);
        end

    endtask

endclass

`endif
