`ifndef __VIP_CLKRST_DRV__
`define __VIP_CLKRST_DRV__

class vip_clkrst_drv extends uvm_driver #(vip_clkrst_action);
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    int                             _duty_cycle ;
    time                            _high_time  ;
    time                            _low_time   ;
    bit                             _clk_en     ;
    virtual vip_clkrst_intf.TEST    _intf       ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_utils(vip_clkrst_drv)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "vip_clkrst_drv", uvm_component parent = null);
        super.new(name, parent);
        _duty_cycle = 50    ;
        _high_time  = 5ns   ;
        _low_time   = 5ns   ;
        _clk_en     = 0     ;
    endfunction

    //  UVM run phase
    //  Arguments
    //      phase   : UVM phasing object
    task run_phase(uvm_phase phase);
        vip_clkrst_action   _item   ;

        //  Start clock generate task
        fork
            clk_gen();
        join_none

        //  Main loop
        forever begin
            seq_item_port.get_next_item(_item);
            _item.print();
            if      (_item._action == CLK_START     ) _clk_en       = 1;
            else if (_item._action == CLK_STOP      ) _clk_en       = 0;
            else if (_item._action == RST_ASSERT    ) _intf.resetn  <= 0;
            else if (_item._action == RST_DEASSERT  ) begin
                @(posedge _intf.clk);
                _intf.resetn  <= 1;
            end
            else if (_item._action == CHG_DUTY      ) begin
                time    _period = _high_time + _low_time;
                _high_time  = _period * 100 / _item._value;
                _low_time   = _period - _high_time;
                _duty_cycle = _item._value;
            end
            else if (_item._action == CHG_PERIOD    ) begin
                _high_time  = _item._value * 100 / _duty_cycle;
                _low_time   = _item._value - _high_time;
            end
            seq_item_port.item_done();
        end

    endtask

    //  UVM run phase
    //  Arguments
    //      phase   : UVM phasing object
    task clk_gen();
        time    _high   ;
        time    _low    ;

        forever begin
            //  Wait until clock is enabled
            if (_clk_en == 0) wait(_clk_en == 1);

            //  Check for valid clock period
            if ((_high_time == 0) && (_low_time == 0)) begin
                _high   = 5ns;
                _low    = 5ns;
            end
            else if ((_high_time == 0) || (_low_time == 0)) begin
                _high   = _high_time + _low_time;
                _low    = _high;
            end
            else begin
                _high   = _high_time;
                _low    = _low_time ;
            end

            fork
                //  Waiting until clock is disabled
                wait(_clk_en == 0);

                //  Generate clock
                forever begin
                    _intf.clk   <= 1;
                    #_high;
                    _intf.clk   <= 0;
                    #_low;
                end
            join_any
            disable fork;
        end
    endtask

endclass

`endif
