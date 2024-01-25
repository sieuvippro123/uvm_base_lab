`ifndef __VIP_SIG_MNT_DRV__
`define __VIP_SIG_MNT_DRV__

class vip_sig_mnt_drv extends uvm_driver #(vip_sig_mnt_cmd, vip_sig_mnt_resp);
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    virtual vip_sig_mnt_intf.TEST   _intf   ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_utils(vip_sig_mnt_drv)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "vip_sig_mnt_drv", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //  UVM run phase
    //  Arguments
    //      phase   : UVM phasing object
    task run_phase(uvm_phase phase);
        vip_sig_mnt_cmd     _item   ;
        vip_sig_mnt_resp    _resp   ;

        //  Main loop
        forever begin
            seq_item_port.get_next_item(_item);
            _item.print();
            _resp = new();
            _resp.set_id_info(_item);
            if (_item._command == WAIT_HIGH) begin
                if (_intf.mnt_sig == 0) @(posedge _intf.mnt_sig);
                uvm_report_info(
                    "SMNT_HIGH_DETECTED"    ,
                    "SIG == 1 is captured"  ,
                    UVM_HIGH                ,
                    `__FILE__               ,
                    `__LINE__               ,
                    get_full_name()         ,
                    1
                );
            end
            else if (_item._command == WAIT_LOW) begin
                if (_intf.mnt_sig == 1) @(negedge _intf.mnt_sig);
                uvm_report_info(
                    "SMNT_LOW_DETECTED"     ,
                    "SIG == 0 is captured"  ,
                    UVM_HIGH                ,
                    `__FILE__               ,
                    `__LINE__               ,
                    get_full_name()         ,
                    1
                );
            end
            else if (_item._command == WAIT_RISE) begin
                @(posedge _intf.mnt_sig);
                uvm_report_info(
                    "SMNT_RISE_DETECTED"    ,
                    "SIG rising edge is captured",
                    UVM_HIGH                ,
                    `__FILE__               ,
                    `__LINE__               ,
                    get_full_name()         ,
                    1
                );
            end
            else if (_item._command == WAIT_FALL) begin
                @(negedge _intf.mnt_sig);
                uvm_report_info(
                    "SMNT_FALL_DETECTED"    ,
                    "SIG falling edge is captured",
                    UVM_HIGH                ,
                    `__FILE__               ,
                    `__LINE__               ,
                    get_full_name()         ,
                    1
                );
            end
            else if (_item._command == WAIT_EDGE) begin
                @(_intf.mnt_sig);
                uvm_report_info(
                    "SMNT_EDGE_DETECTED"    ,
                    "SIG changing edge is captured",
                    UVM_HIGH                ,
                    `__FILE__               ,
                    `__LINE__               ,
                    get_full_name()         ,
                    1
                );
            end
            else begin
                uvm_report_info(
                    "SMNT_VALUE_CAPTURE"    ,
                    "SIG value is captured" ,
                    UVM_HIGH                ,
                    `__FILE__               ,
                    `__LINE__               ,
                    get_full_name()         ,
                    1
                );
            end
            _resp._sig_val = _intf.mnt_sig;
            seq_item_port.item_done(_resp);
        end

    endtask

endclass

`endif
