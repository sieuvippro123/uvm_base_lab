`ifndef __SPI_SLV_SB__
`define __SPI_SLV_SB__

class spi_slv_sb extends uvm_scoreboard;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    uvm_analysis_export     #(vip_spi_mstr_req  )   _spi_sent       ;
    uvm_analysis_export     #(vip_spi_mstr_resp )   _spi_recv       ;
    uvm_analysis_export     #(vip_spi_mstr_resp )   _apb_sent       ;
    uvm_analysis_export     #(vip_spi_mstr_req  )   _apb_recv       ;

    uvm_tlm_analysis_fifo   #(vip_spi_mstr_req  )   _spi_sent_fifo  ;
    uvm_tlm_analysis_fifo   #(vip_spi_mstr_resp )   _spi_recv_fifo  ;
    uvm_tlm_analysis_fifo   #(vip_spi_mstr_resp )   _apb_sent_fifo  ;
    uvm_tlm_analysis_fifo   #(vip_spi_mstr_req  )   _apb_recv_fifo  ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_utils(spi_slv_sb)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "spi_slv_sb", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //  Build phase
    //  Arguments
    //      phase   : UVM phasing object
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        _spi_sent       = new("_spi_sent");
        _spi_recv       = new("_spi_recv");
        _apb_sent       = new("_apb_sent");
        _apb_recv       = new("_apb_recv");

        _spi_sent_fifo  = new("_spi_sent_fifo");
        _spi_recv_fifo  = new("_spi_recv_fifo");
        _apb_sent_fifo  = new("_apb_sent_fifo");
        _apb_recv_fifo  = new("_apb_recv_fifo");

    endfunction

    //  Connect phase
    //  Arguments
    //      phase   : UVM phasing object
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        _spi_sent.connect(_spi_sent_fifo.analysis_export);
        _spi_recv.connect(_spi_recv_fifo.analysis_export);
        _apb_sent.connect(_apb_sent_fifo.analysis_export);
        _apb_recv.connect(_apb_recv_fifo.analysis_export);
    endfunction

    //  UVM run phase
    //  Arguments
    //      phase   : UVM phasing object
    task run_phase(uvm_phase phase);
        vip_spi_mstr_req    _spi_sent_item  ;
        vip_spi_mstr_req    _apb_recv_item  ;
        vip_spi_mstr_resp   _spi_recv_item  ;
        vip_spi_mstr_resp   _apb_sent_item  ;
        bit                 _zero_frame     ;
        fork
            //  SPI to APB
            forever begin
                _apb_recv_fifo.get(_apb_recv_item);
                if (_spi_sent_fifo.try_get(_spi_sent_item)) begin
                    if (_spi_sent_item != _apb_recv_item) begin
                        uvm_report_error(
                            "SB_SPI_TO_APB_MISMATCH",
                            {   "Received SPI frame from APB side and sent SPI frame from SPI side are mismatch\n",
                                _spi_sent_item.sprint(),
                                "\n",
                                _apb_recv_item.sprint()
                            },
                            UVM_NONE                ,
                            `__FILE__               ,
                            `__LINE__               ,
                            get_full_name()         ,
                            1
                        );
                    end
                end
                else begin
                    uvm_report_error(
                        "SB_SPI_TO_APB_MISSING" ,
                        {   "Received SPI frame from APB side but missing sent SPI frame from SPI side\n",
                            _apb_recv_item.sprint()
                        },
                        UVM_NONE                ,
                        `__FILE__               ,
                        `__LINE__               ,
                        get_full_name()         ,
                        1
                    );
                end
            end

            //  APB to SPI
            forever begin
                _spi_recv_fifo.get(_spi_recv_item);
                if (_apb_sent_fifo.try_get(_apb_sent_item)) begin
                    if (!_apb_sent_item.compare(_spi_recv_item)) begin
                        uvm_report_error(
                            "SB_APB_TO_SPI_MISMATCH",
                            {   "Received SPI frame from SPI side and sent SPI frame from APB side are mismatch\n",
                                _apb_sent_item.sprint(),
                                "\n",
                                _spi_recv_item.sprint()
                            },
                            UVM_NONE                ,
                            `__FILE__               ,
                            `__LINE__               ,
                            get_full_name()         ,
                            1
                        );
                    end
                end
                else begin
                    _zero_frame = 1;
                    for (int idx = 0; idx < _spi_recv_item._resp_payload.size(); idx++) begin
                        if (_spi_recv_item._resp_payload[idx]) _zero_frame = 0;
                    end
                    if (!_zero_frame) begin
                        uvm_report_error(
                            "SB_APB_TO_SPI_MISSING" ,
                            {   "Received SPI frame from SPI side but missing sent SPI frame from APB side\n",
                                _spi_recv_item.sprint()
                            },
                            UVM_NONE                ,
                            `__FILE__               ,
                            `__LINE__               ,
                            get_full_name()         ,
                            1
                        );
                    end
                end
            end
        join
    endtask

endclass

`endif
