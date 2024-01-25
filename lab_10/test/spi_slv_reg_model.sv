`ifndef __SPI_SLV_REG_MODEL__
`define __SPI_SLV_REG_MODEL__

class spi_slv_field_wac extends uvm_reg_cbs;
    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  post_predict function
    //  Arguments
    //      fld     : Field object
    //      previous: Previous pridiction value
    //      value   : Current  pridiction value
    //      kind    : Direction (read/write)
    //      path    : Access path (front-door/back-door)
    //      map     : Register map object
    virtual function void post_predict(
        input   uvm_reg_field   fld     ,
        input   uvm_reg_data_t  previous,
        inout   uvm_reg_data_t  value   ,
        input   uvm_predict_e   kind    ,
        input   uvm_path_e      path    ,
        input   uvm_reg_map     map
    );
        if (kind != UVM_PREDICT_WRITE) return;  //  Return if not a write access
        value   = 0;                            //  Set value to 0 for write acccess
    endfunction

    //  pre_write function
    //  Arguments
    //      rw  : Register access sequence item
    virtual task pre_write(uvm_reg_item rw);
        if (rw.path != UVM_BACKDOOR )   return; //  Return if not a back-door access
        if (rw.kind != UVM_WRITE    )   return; //  Return if not a write access
        rw.status = UVM_NOT_OK;                 //  Set status to NOT_OK to discard this access
    endtask

endclass

class spi_slv_reg_sreset extends uvm_reg;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    rand uvm_reg_field  srstn   ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(spi_slv_reg_sreset)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new (string name = "spi_slv_reg_sreset");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction

    //  Build method
    //  Arguments: none
    function void build();
        //  Create register fiels
        srstn   = uvm_reg_field::type_id::create("srstn");

        //  Configure register fields
        //                  parent      size    lsb_pos     access      volatile    reset   has_reset   is_rand individually_accessible
        srstn.configure (   this    ,   1   ,   0   ,       "RW"    ,   0   ,       0   ,   1   ,       1   ,   1   );

    endfunction

endclass

class spi_slv_reg_ctrl extends uvm_reg;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    rand uvm_reg_field  txen    ;
    rand uvm_reg_field  rxen    ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(spi_slv_reg_ctrl)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new (string name = "spi_slv_reg_ctrl");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction

    //  Build method
    //  Arguments: none
    function void build();
        txen    = uvm_reg_field::type_id::create("txen");
        rxen    = uvm_reg_field::type_id::create("rxen");

        //  Configure register fields
        //                  parent      size    lsb_pos     access      volatile    reset   has_reset   is_rand individually_accessible
        txen.configure  (   this    ,   1   ,   0   ,       "RW"    ,   0   ,       0   ,   1   ,       1   ,   1   );
        rxen.configure  (   this    ,   1   ,   1   ,       "RW"    ,   0   ,       0   ,   1   ,       1   ,   1   );

    endfunction

endclass

class spi_slv_reg_txstart extends uvm_reg;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    rand uvm_reg_field  txstart ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(spi_slv_reg_txstart)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new (string name = "spi_slv_reg_txstart");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction

    //  Build method
    //  Arguments: none
    function void build();
        //  Create register fiels
        txstart = uvm_reg_field::type_id::create("txstart");

        //  Configure register fields
        //                      parent      size    lsb_pos     access      volatile    reset   has_reset   is_rand individually_accessible
        txstart.configure   (   this    ,   1   ,   0   ,       "RW"    ,   0   ,       0   ,   1   ,       1   ,   1   );

        //  add callback object to register field
        begin
            spi_slv_field_wac   _cb = new();
            uvm_reg_field_cb::add(txstart, _cb);
        end

    endfunction

endclass

class spi_slv_reg_status extends uvm_reg;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    rand uvm_reg_field  txempty     ;
    rand uvm_reg_field  txfull      ;
    rand uvm_reg_field  rxempty     ;
    rand uvm_reg_field  rxfull      ;
    rand uvm_reg_field  badrxcrc    ;
    rand uvm_reg_field  badspilength;
    rand uvm_reg_field  txcompl     ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(spi_slv_reg_status)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new (string name = "spi_slv_reg_status");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction

    //  Build method
    //  Arguments: none
    function void build();
        //  Create register fiels
        txempty     = uvm_reg_field::type_id::create("txempty"      );
        txfull      = uvm_reg_field::type_id::create("txfull"       );
        rxempty     = uvm_reg_field::type_id::create("rxempty"      );
        rxfull      = uvm_reg_field::type_id::create("rxfull"       );
        badrxcrc    = uvm_reg_field::type_id::create("badrxcrc"     );
        badspilength= uvm_reg_field::type_id::create("badspilength" );
        txcompl     = uvm_reg_field::type_id::create("txcompl"      );

        //  Configure register fields
        //                          parent      size    lsb_pos     access      volatile    reset   has_reset   is_rand individually_accessible
        txempty     .configure  (   this    ,   1   ,   0   ,       "RO"    ,   0   ,       1   ,   1   ,       0   ,   1   );
        txfull      .configure  (   this    ,   1   ,   1   ,       "RO"    ,   0   ,       0   ,   1   ,       0   ,   1   );
        rxempty     .configure  (   this    ,   1   ,   2   ,       "RO"    ,   0   ,       1   ,   1   ,       0   ,   1   );
        rxfull      .configure  (   this    ,   1   ,   3   ,       "RO"    ,   0   ,       0   ,   1   ,       0   ,   1   );
        badrxcrc    .configure  (   this    ,   1   ,   4   ,       "RO"    ,   0   ,       0   ,   1   ,       0   ,   1   );
        badspilength.configure  (   this    ,   1   ,   5   ,       "RO"    ,   0   ,       0   ,   1   ,       0   ,   1   );
        txcompl     .configure  (   this    ,   1   ,   7   ,       "RO"    ,   0   ,       0   ,   1   ,       0   ,   1   );

    endfunction

endclass

class spi_slv_reg_intctrl extends uvm_reg;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    rand uvm_reg_field  cmplen  ;
    rand uvm_reg_field  cmplmsk ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(spi_slv_reg_intctrl)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new (string name = "spi_slv_reg_intctrl");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction

    //  Build method
    //  Arguments: none
    function void build();
        //  Create register fiels
        cmplen  = uvm_reg_field::type_id::create("cmplen"   );
        cmplmsk = uvm_reg_field::type_id::create("cmplmsk"  );

        //  Configure register fields
        //                      parent      size    lsb_pos     access      volatile    reset   has_reset   is_rand individually_accessible
        cmplen  .configure  (   this    ,   1   ,   0   ,       "RW"    ,   0   ,       0   ,   1   ,       1   ,   1   );
        cmplmsk .configure  (   this    ,   1   ,   4   ,       "RW"    ,   0   ,       0   ,   1   ,       1   ,   1   );

    endfunction

endclass

class spi_slv_reg_intsts extends uvm_reg;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    rand uvm_reg_field  cmpl    ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(spi_slv_reg_intsts)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new (string name = "spi_slv_reg_intsts");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction

    //  Build method
    //  Arguments: none
    function void build();
        //  Create register fiels
        cmpl    = uvm_reg_field::type_id::create("cmpl");

        //  Configure register fields
        //                  parent      size    lsb_pos     access      volatile    reset   has_reset   is_rand individually_accessible
        cmpl.configure  (   this    ,   1   ,   0   ,       "W1C"   ,   0   ,       0   ,   1   ,       1   ,   1   );

    endfunction

endclass

class spi_slv_reg_txrxbuf extends uvm_reg;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    rand uvm_reg_field  data    ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(spi_slv_reg_txrxbuf)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new (string name = "spi_slv_reg_txrxbuf");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction

    //  Build method
    //  Arguments: none
    function void build();
        //  Create register fiels
        data    = uvm_reg_field::type_id::create("data");

        //  Configure register fields
        //                  parent      size    lsb_pos     access      volatile    reset   has_reset   is_rand individually_accessible
        data.configure  (   this    ,   8   ,   0   ,       "RW"    ,   1   ,       0   ,   1   ,       1   ,   1   );

    endfunction

endclass

class spi_slv_reg_blk extends uvm_reg_block;
    //-------------------------------------------------------------------------
    //  Properties
    //-------------------------------------------------------------------------
    rand    spi_slv_reg_sreset      _sreset     ;
    rand    spi_slv_reg_ctrl        _ctrl       ;
    rand    spi_slv_reg_txstart     _txstart    ;
    rand    spi_slv_reg_status      _status     ;
    rand    spi_slv_reg_intctrl     _intctrl    ;
    rand    spi_slv_reg_intsts      _intsts     ;
    rand    spi_slv_reg_txrxbuf     _txrxbuf    ;

    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(spi_slv_reg_blk)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new (string name = "spi_slv_reg_blk");
        super.new(name);
    endfunction

    //  Build function
    //  Arguments: none
    function void build();
        //  Create register fiels
        _sreset     = spi_slv_reg_sreset    ::type_id::create("_sreset"     );
        _ctrl       = spi_slv_reg_ctrl      ::type_id::create("_ctrl"       );
        _txstart    = spi_slv_reg_txstart   ::type_id::create("_txstart"    );
        _status     = spi_slv_reg_status    ::type_id::create("_status"     );
        _intctrl    = spi_slv_reg_intctrl   ::type_id::create("_intctrl"    );
        _intsts     = spi_slv_reg_intsts    ::type_id::create("_intsts"     );
        _txrxbuf    = spi_slv_reg_txrxbuf   ::type_id::create("_txrxbuf"    );

        //  Create register fiels
        _sreset     .configure  (this, null, "" );
        _ctrl       .configure  (this, null, "" );
        _txstart    .configure  (this, null, "" );
        _status     .configure  (this, null, "" );
        _intctrl    .configure  (this, null, "" );
        _intsts     .configure  (this, null, "" );
        _txrxbuf    .configure  (this, null, "" );

        //  Add HDL path for registers
        //      Name              Offset  Size
        _sreset     .add_hdl_path( '{
            '{  "SRST.dout"     , 0     , 1 }
        });
        _ctrl       .add_hdl_path( '{
            '{  "CTRL.dout"     , 0     , 1 },
            '{  "CTRL.dout"     , 1     , 1 }
        });
        _txstart    .add_hdl_path( '{
            '{  "TXCTRL.dout"   , 0     , 1 }
        });
        _status     .add_hdl_path( '{
            '{  "_intf_spictrl.txcmpl"  , 7     , 1 },
            '{  "_intf_spictrl.crc_err" , 5     , 1 },
            '{  "_intf_spictrl.len_err" , 4     , 1 },
            '{  "rxbuf_full"            , 3     , 1 },
            '{  "_intf_bufr.rempty"     , 2     , 1 },
            '{  "_intf_bufw.wfull"      , 1     , 1 },
            '{  "txbuf_empty"           , 0     , 1 }
        });
        _intctrl    .add_hdl_path( '{
            '{  "INTCTRL.dout[0]", 0     , 1 },
            '{  "INTCTRL.dout[1]", 4     , 1 }
        });
        _intsts     .add_hdl_path( '{
            '{  "INTSTS.dout"   , 0     , 1 }
        });

        //  Build register fiels
        _sreset     .build      ();
        _ctrl       .build      ();
        _txstart    .build      ();
        _status     .build      ();
        _intctrl    .build      ();
        _intsts     .build      ();
        _txrxbuf    .build      ();

        //  Create address map
        default_map = create_map(
            "default_map"       ,   //  name
            0                   ,   //  base_addr
            1                   ,   //  n_bytes
            UVM_LITTLE_ENDIAN   ,   //  endian
            1                       //  byte_addressing
        );
        default_map.add_reg (   _sreset     ,   0   ,   "RW"    );
        default_map.add_reg (   _ctrl       ,   1   ,   "RW"    );
        default_map.add_reg (   _txstart    ,   2   ,   "RW"    );
        default_map.add_reg (   _status     ,   3   ,   "RW"    );
        default_map.add_reg (   _intctrl    ,   4   ,   "RW"    );
        default_map.add_reg (   _intsts     ,   5   ,   "RW"    );
        default_map.add_reg (   _txrxbuf    ,   6   ,   "RW"    );

    endfunction

endclass

class spi_slv_reg_adapter extends uvm_reg_adapter;
    //-------------------------------------------------------------------------
    //  Factory registration
    //-------------------------------------------------------------------------
    `uvm_object_utils(spi_slv_reg_adapter)

    //-------------------------------------------------------------------------
    //  Methods
    //-------------------------------------------------------------------------
    //  Constructor
    //  Arguments
    //      name    : object's name
    function new(string name = "spi_slv_reg_adapter");
        super.new(name);
        supports_byte_enable = 1;
    endfunction

    //  reg2bus function
    //  Arguments
    //      rw  : Bus operation
    //  Return  : uvm_sequence_item
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        vip_apb_mstr_trans#(3, 8)    _bus    ;

        _bus                = vip_apb_mstr_trans#(3, 8)::type_id::create("_bus");
        _bus._trans         = (rw.kind == UVM_READ) ? APB_READ : APB_WRITE;
        _bus._trans_addr    = rw.addr   ;
        _bus._trans_prot    = '0        ;
        _bus._trans_wdata   = rw.data   ;
        _bus._trans_strb    = rw.byte_en;

        return _bus;
    endfunction

    //  bus2reg function
    //  Arguments
    //      bus_item: Sequence item
    //      rw      : Bus operation
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        vip_apb_mstr_trans#(3, 8)  _bus;

        if (!$cast(_bus, bus_item)) begin
            `uvm_fatal("NOT_REG_TYPE","Provided bus_item is not of the correct type")
            return;
        end

        if (_bus._trans == APB_WRITE) begin
            rw.kind    = UVM_WRITE;
            rw.data    = _bus._trans_wdata  ;
        end
        else begin
            rw.kind    = UVM_READ;
            rw.data    = _bus._trans_rdata  ;
        end
        rw.addr    = _bus._trans_addr   ;
        rw.byte_en = _bus._trans_strb   ;
        if      ($isunknown(_bus._trans_resp)   )   rw.status  = UVM_NOT_OK ;
        else if (_bus._trans_resp === '1        )   rw.status  = UVM_NOT_OK ;
        else if ($isunknown(_bus._trans_rdata)  )   rw.status  = UVM_HAS_X  ;
        else                                        rw.status  = UVM_IS_OK  ;

    endfunction

endclass

`endif
