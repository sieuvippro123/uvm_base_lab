`ifndef __VIP_APB_MSTR_DRV__
`define __VIP_APB_MSTR_DRV__

class vip_apb_mstr_drv #(
    parameter   P_ADDR_WIDTH    = 8,
    parameter   P_DATA_WIDTH    = 32
) extends uvm_driver #(
    vip_apb_mstr_trans#(P_ADDR_WIDTH, P_DATA_WIDTH   )
);
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    virtual vip_apb_intf#(P_ADDR_WIDTH, P_DATA_WIDTH).MASTER                _intf       ;
    uvm_analysis_port #(vip_apb_mstr_trans#(P_ADDR_WIDTH, P_DATA_WIDTH))    _trans_ap   ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_param_utils(vip_apb_mstr_drv#(P_ADDR_WIDTH, P_DATA_WIDTH))

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "vip_apb_mstr_drv", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //  Build phase
    //  Arguments
    //      phase   : UVM phasing object
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        _trans_ap   = new("_trans_ap"   , this  );
    endfunction

    //  UVM run phase
    //  Arguments
    //      phase   : UVM phasing object
    task run_phase(uvm_phase phase);
        vip_apb_mstr_trans#(P_ADDR_WIDTH, P_DATA_WIDTH) _item   ;

        //  Reset
        fork
            forever begin
                @(negedge _intf.PRESETn);
                _intf.PADDR     <= '0;
                _intf.PPROT     <= '0;
                _intf.PSEL      <= '0;
                _intf.PENABLE   <= '0;
                _intf.PWRITE    <= '0;
                _intf.PWDATA    <= '0;
                _intf.PSTRB     <= '0;
                _intf.PENABLE   <= '0;
            end
        join_none

        //  Main loop
        @(posedge _intf.PCLK);
        forever begin
            //  Get request item and create related response
            seq_item_port.try_next_item(_item);
            if (_item == null) begin
                @(posedge _intf.PCLK);
                continue;
            end

            //  IDLE request
            if (_item._trans == APB_IDLE) begin
                uvm_report_info(
                    "APB_TRANS_IDLE"        ,
                    { "\n", _item.sprint() },
                    UVM_DEBUG               ,
                    `__FILE__               ,
                    `__LINE__               ,
                    get_full_name()         ,
                    1
                );
                repeat (_item._trans_wdata) @(posedge _intf.PCLK);
                _item._trans_rdata  = _intf.PRDATA  ;
                _item._trans_resp   = _intf.PSLVERR ;
            end

            //  Reset is active
            else if (!_intf.PRESETn) begin
                uvm_report_warning(
                    "APB_TRANS_RESET"       ,
                    { "\n", _item.sprint() },
                    UVM_NONE                ,
                    `__FILE__               ,
                    `__LINE__               ,
                    get_full_name()         ,
                    1
                );
                _item._trans_rdata  = _intf.PRDATA  ;
                _item._trans_resp   = 1;
            end

            //  Write/read transfer
            else begin
                fork    //  Exit thread on either active reset or transfer completed
                    begin
                        @(negedge _intf.PRESETn);
                        uvm_report_warning(
                            "APB_TRANS_ABORTED"     ,
                            { "\n", _item.sprint() },
                            UVM_NONE                ,
                            `__FILE__               ,
                            `__LINE__               ,
                            get_full_name()         ,
                            1
                        );
                        _item._trans_resp   = 1;
                        _item._trans_rdata  = _intf.PRDATA  ;
                    end
                    begin
                        uvm_report_info(
                            "APB_TRANS_STARTED"     ,
                            { "\n", _item.sprint() },
                            UVM_DEBUG               ,
                            `__FILE__               ,
                            `__LINE__               ,
                            get_full_name()         ,
                            1
                        );
                        _intf.PADDR     <= _item._trans_addr;
                        _intf.PPROT     <= _item._trans_prot;
                        _intf.PSEL      <= '1;
                        _intf.PENABLE   <= '0;/// '0
                        _intf.PWRITE    <= (_item._trans == APB_WRITE);
                        _intf.PWDATA    <= _item._trans_wdata;
                        _intf.PSTRB     <= _item._trans_strb;
                        @(posedge _intf.PCLK);
                        _intf.PENABLE   <= '1;
                        @(posedge _intf.PCLK);
                        while (!_intf.PREADY) @(posedge _intf.PCLK);
                        _item._trans_rdata  = _intf.PRDATA  ;
                        _item._trans_resp   = _intf.PSLVERR ;
                        _trans_ap.write(_item);
                        if (_intf.PSLVERR) begin
                            uvm_report_error(
                                "APB_TRANS_ERROR"       ,
                                { "\n", _item.sprint() },
                                UVM_NONE                ,
                                `__FILE__               ,
                                `__LINE__               ,
                                get_full_name()         ,
                                1
                            );
                        end
                        else begin
                            uvm_report_info(
                                "APB_TRANS_COMPLETED"   ,
                                { "\n", _item.sprint() },
                                UVM_NONE                ,
                                `__FILE__               ,
                                `__LINE__               ,
                                get_full_name()         ,
                                1
                            );
                        end
                    end
                join_any
                disable fork;
                _intf.PADDR     <= '0;
                _intf.PPROT     <= '0;
                _intf.PSEL      <= '0;
                _intf.PENABLE   <= '0;//'0
                _intf.PWRITE    <= '0;
                _intf.PWDATA    <= '0;
                _intf.PSTRB     <= '0;
            end

            //  Send response
            seq_item_port.item_done();
        end

    endtask

endclass

`endif
