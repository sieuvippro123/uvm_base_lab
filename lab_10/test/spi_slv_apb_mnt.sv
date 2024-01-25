`ifndef __SPI_SLV_APB_MNT__
`define __SPI_SLV_APB_MNT__

class spi_slv_apb_mnt extends uvm_monitor;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    virtual vip_apb_intf#(P_ADDR_WIDTH, P_DATA_WIDTH).MONITOR  _intf_apb;
    virtual vip_spi_intf.MASTER             _intf_spi   ;
    virtual vip_sig_mnt_intf.TEST           _intf_int   ;
    uvm_analysis_port #(vip_spi_mstr_resp)  _sent_port  ;
    uvm_analysis_port #(vip_spi_mstr_req)   _recv_port  ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_param_utils(spi_slv_apb_mnt)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "spi_slv_apb_mnt", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //  Build phase
    //  Arguments
    //      phase   : UVM phasing object
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        _sent_port  = new("_sent_port"  , this  );
        _recv_port  = new("_recv_port"  , this  );
    endfunction

    //  UVM run phase
    //  Arguments
    //      phase   : UVM phasing object
    task run_phase(uvm_phase phase);
        logic   [ P_DATA_WIDTH  - 1 : 0 ]   _tx_queue[$];
        logic   [ P_DATA_WIDTH  - 1 : 0 ]   _rx_queue[$];
        logic   [ P_DATA_WIDTH  - 1 : 0 ]   _tx_buff [$];
        vip_spi_mstr_resp                   _tx_frame   ;
        vip_spi_mstr_req                    _rx_frame   ;
        int                                 _rx_idx     ;
        spi_slv_mstr::TRANS                 _apb_trans  ;

        fork
            //  Observes for sent SPI data (from master to slave)
            forever begin
                @(posedge _intf_apb.PCLK);
                if (_intf_apb.PSEL && _intf_apb.PENABLE && _intf_apb.PREADY && _intf_apb.PWRITE && !_intf_apb.PSLVERR)
                if (_intf_apb.PADDR == 3'h6) begin
                    _tx_queue.push_back(_intf_apb.PWDATA);
                end
            end

            //  Observes SPI start
            forever begin
                @(negedge _intf_spi.SCSn);
                _tx_buff.delete();

                fork
                    //  Wait for SPI frame complete
                    @(posedge _intf_spi.SCSn);

                    //  Get tx data
                    forever begin
                        if (_tx_queue.size())   _tx_buff.push_back(_tx_queue.pop_front());
                        else                    _tx_buff.push_back(0);
                        repeat (8) @(posedge _intf_spi.SCLK);
                    end
                join_any
                disable fork;

                _tx_frame = new("_tx_frame");
                _tx_frame._resp_payload = new[_tx_buff.size()-2];
                for (int idx = 0; idx < _tx_buff.size() - 2; idx++) begin
                    _tx_frame._resp_payload[idx] = _tx_buff[idx];
                end
                _tx_frame._resp_crc = crc_cal(_tx_frame._resp_payload);
                _sent_port.write(_tx_frame);
            end

            //  Observes for receipt SPI frame (from slave to master)
            forever begin
                @(posedge _intf_int.mnt_sig);
                _rx_idx = 0;
                while (_rx_idx < 16) begin
                    @(posedge _intf_apb.PCLK);
                    if (_intf_apb.PSEL && _intf_apb.PENABLE && _intf_apb.PREADY && !_intf_apb.PWRITE) begin
                        _rx_queue.push_back(_intf_apb.PRDATA);
                        _rx_idx++;
                    end
                end
                _rx_frame   = new("_rx_frame");
                _rx_frame._req_payload  = new[16];
                _rx_frame._req_crc      = crc_cal(_rx_frame._req_payload);
                _recv_port.write(_rx_frame);
            end
        join
    endtask

endclass

`endif
