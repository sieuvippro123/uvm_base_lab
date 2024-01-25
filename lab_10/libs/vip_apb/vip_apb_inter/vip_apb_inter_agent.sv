`ifndef __VIP_APB_INTER_AGENT__
`define __VIP_APB_INTER_AGENT__

class vip_apb_inter_agent #(
    parameter   P_SLAVE_NUM     = 4,
    parameter   P_ADDR_WIDTH    = 8,
    parameter   P_DATA_WIDTH    = 32
) extends uvm_agent;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    virtual     vip_apb_intf#(P_ADDR_WIDTH, P_DATA_WIDTH).SLAVE     _intf_mstr              ;
    virtual     vip_apb_intf#(P_ADDR_WIDTH, P_DATA_WIDTH).MASTER    _intf_slv[P_SLAVE_NUM]  ;
    bit     [ P_ADDR_WIDTH  - 1 : 0 ]   _base_addr  [P_SLAVE_NUM];
    bit     [ P_ADDR_WIDTH  - 1 : 0 ]   _offset     [P_SLAVE_NUM];

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_param_utils(vip_apb_inter_agent#(P_SLAVE_NUM, P_ADDR_WIDTH, P_DATA_WIDTH))

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "vip_apb_inter_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //  Connect phase
    //  Arguments
    //      phase   : UVM phasing object
    function void connect_phase(uvm_phase phase);
        virtual vip_apb_intf#(P_ADDR_WIDTH, P_DATA_WIDTH)   _intf   ;

        super.connect_phase(phase);

        if(!uvm_config_db#(virtual vip_apb_intf#(P_ADDR_WIDTH, P_DATA_WIDTH))::get(this, "", "_intf_mstr", _intf))
            `uvm_fatal ("APB_MASTER_INTF_UNSET", "APB master interface is not set")
        else
            _intf_mstr  = _intf;

        for (int idx = 0; idx < P_SLAVE_NUM; idx++) begin
            if(!uvm_config_db#(virtual vip_apb_intf#(P_ADDR_WIDTH, P_DATA_WIDTH))::get(this, "", $psprintf("_intf_slv_%1d", idx), _intf))
                `uvm_fatal ("APB_SLAVE_INTF_UNSET", $psprintf("APB slave interface[%1d] is not set", idx))
            else
                _intf_slv[idx]  = _intf;
        end

    endfunction

    //  Run phase
    //  Arguments
    //      Phase   : UVM phasing object
    task run_phase(uvm_phase phase);
        for (int slv_idx = 0; slv_idx < P_SLAVE_NUM; slv_idx++) begin
            fork
                master_to_slave(slv_idx);
            join_none
            #0;
        end
    endtask

    //  master_to_slave task
    //  Arguments
    //      slv_idx : Slave index
    task master_to_slave(int slv_idx);
        fork
            forever begin @(_intf_mstr.PADDR    ); _intf_slv[slv_idx].PADDR     <= _intf_mstr.PADDR     ; end
            forever begin @(_intf_mstr.PPROT    ); _intf_slv[slv_idx].PPROT     <= _intf_mstr.PPROT     ; end
            forever begin @(_intf_mstr.PSEL     ); _intf_slv[slv_idx].PSEL      <= _intf_mstr.PSEL      ; end
            forever begin @(_intf_mstr.PENABLE  ); _intf_slv[slv_idx].PENABLE   <= _intf_mstr.PENABLE   ; end
            forever begin @(_intf_mstr.PWRITE   ); _intf_slv[slv_idx].PWRITE    <= _intf_mstr.PWRITE    ; end
            forever begin @(_intf_mstr.PWDATA   ); _intf_slv[slv_idx].PWDATA    <= _intf_mstr.PWDATA    ; end
            forever begin @(_intf_mstr.PSTRB    ); _intf_slv[slv_idx].PSTRB     <= _intf_mstr.PSTRB     ; end
        join
    endtask

endclass

`endif
