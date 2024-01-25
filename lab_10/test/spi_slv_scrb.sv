`ifndef __SPI_SLV_SCRB__
`define __SPI_SLV_SCRB__

class spi_slv_scrb#(type T = uvm_object) extends uvm_subscriber#(T);
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    string      _report_file    ;
    int         _report_handle  ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_component_param_utils_begin(spi_slv_scrb#(T))
        `uvm_field_string   ( _report_file  , UVM_ALL_ON   )
    `uvm_component_utils_end

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    //      parent  : pointer to parrent of the object
    function new(string name = "spi_slv_scrb", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //  UVM run phase
    //  Arguments
    //      phase   : UVM phasing object
    task run_phase(uvm_phase phase);
        _report_handle  = $fopen (_report_file, "w");
        if (!_report_handle)
            uvm_report_warning(
                "SCRB_FILE_OPEN_FAILED" ,
                { "Cannot open ", _report_file, " in write mode!!" },
                UVM_NONE                ,
                `__FILE__               ,
                `__LINE__               ,
                get_full_name()         ,
                1
            );
    endtask

    //  UVM report phase
    function void report_phase(uvm_phase phase);
        if (_report_handle)
            $fclose(_report_handle);
    endfunction

    //  Subscriber implementation
    function void write (T t);
        if (_report_handle)
            $fdisplay(_report_handle, t.sprint());
    endfunction

endclass

`endif
