package lib_sva_pkg;

    //  Active low asynchronous reset
    //  CLK     : sampling clock
    //  ARSTn   : reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_ARn(CLK, ARSTn, TARGET, EXPECTED);
        @(posedge CLK)
        (!(ARSTn)) |-> ((TARGET) == (EXPECTED));
    endproperty

    //  Active high asynchronous reset
    //  CLK     : sampling clock
    //  ARST    : reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_AR(CLK, ARST, TARGET, EXPECTED);
        @(posedge CLK)
        (ARST) |-> ((TARGET) == (EXPECTED));
    endproperty

    //  Active low synchronous reset
    //  CLK     : sampling clock
    //  SRSTn   : reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_SRn(CLK, SRSTn, TARGET, EXPECTED);
        @(posedge CLK)
        (!(SRSTn)) |=> ((TARGET) == (EXPECTED));
    endproperty

    //  Active high asynchronous reset
    //  CLK     : sampling clock
    //  SRST    : reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_SR(CLK, SRST, TARGET, EXPECTED);
        @(posedge CLK)
        (SRST) |=> ((TARGET) == (EXPECTED));
    endproperty

    //  Active low asynchronous, Active low asynchronous reset
    //  CLK     : sampling clock
    //  ARSTn   : asynchronous reset signal
    //  SRSTn   : synchronous reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_ARn_SRn(CLK, ARSTn, SRSTn, TARGET, EXPECTED);
        @(posedge CLK) disable iff (!(ARSTn))
        (!(SRSTn)) |=> ((TARGET) == (EXPECTED));
    endproperty

    //  Active low asynchronous, Active high asynchronous reset
    //  CLK     : sampling clock
    //  ARSTn   : asynchronous reset signal
    //  SRST    : synchronous reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_ARn_SR(CLK, ARSTn, SRST, TARGET, EXPECTED);
        @(posedge CLK) disable iff (!(ARSTn))
        (SRST) |=> ((TARGET) == (EXPECTED));
    endproperty

    //  Active high asynchronous, Active low asynchronous reset
    //  CLK     : sampling clock
    //  ARST    : asynchronous reset signal
    //  SRSTn   : synchronous reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_AR_SRn(CLK, ARST, SRSTn, TARGET, EXPECTED);
        @(posedge CLK) disable iff (ARST)
        (!(SRSTn)) |-> ((TARGET) == (EXPECTED));
    endproperty

    //  Active high asynchronous, Active high asynchronous reset
    //  CLK     : sampling clock
    //  ARST    : asynchronous reset signal
    //  SRST    : synchronous reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_AR_SR(CLK, ARST, SRST, TARGET, EXPECTED);
        @(posedge CLK) disable iff (ARST)
        (SRST) |-> ((TARGET) == (EXPECTED));
    endproperty

    //  Update
    //  CLK     : sampling clock
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_UPDT(CLK, TARGET, EXPECTED);
        @(posedge CLK)
        (1) |=> (TARGET == $past(EXPECTED));
    endproperty

    //  Active low asynchronous reset, update
    //  CLK     : sampling clock
    //  ARSTn   : asynchronous reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_ARn_UPDT(CLK, ARSTn, TARGET, EXPECTED);
        @(posedge CLK) disable iff (!(ARSTn))
        (1) |=> (TARGET == $past(EXPECTED));
    endproperty

    //  Active high asynchronous reset, update
    //  CLK     : sampling clock
    //  ARST    : asynchronous reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_AR_UPDT(CLK, ARST, TARGET, EXPECTED);
        @(posedge CLK) disable iff (ARST)
        (1) |=> (TARGET == $past(EXPECTED));
    endproperty


    //  Active low synchronous reset, update
    //  CLK     : sampling clock
    //  SRSTn   : synchronous reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_SRn_UPDT(CLK, SRSTn, TARGET, EXPECTED);
        @(posedge CLK)
        (SRSTn) |=> (TARGET == $past(EXPECTED));
    endproperty

    //  Active high synchronous reset, update
    //  CLK     : sampling clock
    //  SRST    : synchronous reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_SR_UPDT(CLK, SRST, TARGET, EXPECTED);
        @(posedge CLK)
        (!(SRST)) |=> (TARGET == $past(EXPECTED));
    endproperty

    //  Active low asynchronous, active low synchronous reset, update
    //  CLK     : sampling clock
    //  ARSTn   : asynchronous reset signal
    //  SRSTn   : synchronous reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_ARn_SRn_UPDT(CLK, ARSTn, SRSTn, TARGET, EXPECTED);
        @(posedge CLK) disable iff (!(ARSTn))
        (SRSTn) |=> (TARGET == $past(EXPECTED));
    endproperty

    //  Active low asynchronous, active high synchronous reset, update
    //  CLK     : sampling clock
    //  ARSTn   : asynchronous reset signal
    //  SRST    : synchronous reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_ARn_SR_UPDT(CLK, ARSTn, SRST, TARGET, EXPECTED);
        @(posedge CLK) disable iff (!(ARSTn))
        (!(SRST)) |=> (TARGET == $past(EXPECTED));
    endproperty

    //  Active high asynchronous, active low synchronous reset, update
    //  CLK     : sampling clock
    //  ARST    : asynchronous reset signal
    //  SRSTn   : synchronous reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_AR_SRn_UPDT(CLK, ARST, SRSTn, TARGET, EXPECTED);
        @(posedge CLK) disable iff (ARST)
        (SRSTn) |=> (TARGET == $past(EXPECTED));
    endproperty

    //  Active high asynchronous, active high synchronous reset, update
    //  CLK     : sampling clock
    //  ARST    : asynchronous reset signal
    //  SRST    : synchronous reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_AR_SR_UPDT(CLK, ARST, SRST, TARGET, EXPECTED);
        @(posedge CLK) disable iff (ARST)
        (!(SRST)) |=> (TARGET == $past(EXPECTED));
    endproperty

    //  Active low asynchronous, active low synchronous reset, enable, update
    //  CLK     : sampling clock
    //  ARSTn   : asynchronous reset signal
    //  SRSTn   : synchronous reset signal
    //  EN      : enable signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_ARn_SRn_EN_UPDT(CLK, ARSTn, SRSTn, EN, TARGET, EXPECTED);
        @(posedge CLK) disable iff (!(ARSTn))
        (SRSTn) ##0 (EN) |=> (TARGET == $past(EXPECTED));
    endproperty

    //  Active low asynchronous, active high synchronous reset, enable, update
    //  CLK     : sampling clock
    //  ARSTn   : asynchronous reset signal
    //  SRST    : synchronous reset signal
    //  EN      : enable signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_ARn_SR_EN_UPDT(CLK, ARSTn, SRST, EN, TARGET, EXPECTED);
        @(posedge CLK) disable iff (!(ARSTn))
        (!(SRST)) ##0 (EN) |=> (TARGET == $past(EXPECTED));
    endproperty

    //  Active high asynchronous, active low synchronous reset, enable, update
    //  CLK     : sampling clock
    //  ARST    : asynchronous reset signal
    //  SRSTn   : synchronous reset signal
    //  EN      : enable signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_AR_SRn_EN_UPDT(CLK, ARST, SRSTn, EN, TARGET, EXPECTED);
        @(posedge CLK) disable iff (ARST)
        (SRSTn) ##0 (EN) |=> (TARGET == $past(EXPECTED));
    endproperty

    //  Active high asynchronous, active high synchronous reset, enable, update
    //  CLK     : sampling clock
    //  ARST    : asynchronous reset signal
    //  SRST    : synchronous reset signal
    //  EN      : enable signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_AR_SR_EN_UPDT(CLK, ARST, SRST, EN, TARGET, EXPECTED);
        @(posedge CLK) disable iff (ARST)
        (!(SRST)) ##0 (EN) |=> (TARGET == $past(EXPECTED));
    endproperty

    // Active high asynchronous, condition, expected 1, expected 2
    // CLK      : sampling clock
    // ARST     : asynchronous reset signal
    // COND     : condition to check
    // EXPECTED_1: expecting value
    // EXPECTED_2: expecting value
    // Register change
    property P_FF_CHANGE(CLK, ARST, COND, EXPECTED_1, EXPECTED_2);
        @(posedge CLK) disable iff (!ARST)
        $changed(COND) |-> $past(EXPECTED_1) == 0 or $past(EXPECTED_2) == 1;
    endproperty

    

    //  Active high asynchronous, active low synchronous reset, update
    //  CLK     : sampling clock
    //  ARST    : asynchronous reset signal
    //  Enable   : enable 
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_AR_EN_UPDT(CLK, ARST, EN, TARGET, EXPECTED);
        @(posedge CLK) disable iff (ARST)
        (EN) |=> (TARGET == $past(EXPECTED));
    endproperty

    //  Active high asynchronous, active low synchronous reset, update
    //  CLK     : sampling clock
    //  ARSTn    : asynchronous reset signal
    //  Enable   : enable 
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_ARn_EN_UPDT(CLK, ARSTn, EN, TARGET, EXPECTED);
        @(posedge CLK) disable iff (!ARSTn)
        (EN) |=> (TARGET == $past(EXPECTED));
    endproperty

    property P_FF_ARn_EN_UPDT_INCREASE_1(CLK, ARSTn, EN, TARGET, EXPECTED);
        @(posedge CLK) disable iff (!ARSTn)
        (EN) |=> (TARGET == $past(EXPECTED) + 1);
    endproperty

    // RWC assert 
    property P_FF_AR_ASSERT(CLK, ARST , TARGET, EXPECTED);
        @(posedge CLK) disable iff (!ARST) 
        (TARGET == 1)|=> (EXPECTED == 0);
    endproperty

    // Check width of bit
    property CHECK_WIDTH_BIT(CLK, VAR, VALUE);
        @(CLK) $bits(VAR) == VALUE;
    endproperty

    // Check value
    property CHECK_VALUE(CLK, VAR, VALUE);
        @(CLK) VAR == VALUE;
    endproperty

    property CHECK_VALUE_COND(CLK, COND, VALUE, EXPECTED);
        @(CLK)
        COND |-> VALUE == EXPECTED;
    endproperty

    // Check initial value
    property CHECK_INIT_VALUE(CLK, ARSTn, VAR , VALUE);
        @(posedge CLK) 
        (!ARSTn) |-> VAR == VALUE;
    endproperty

    property CHECK_UPDT(CLK,COND, TARGET, EXPECTED);
        @(CLK)
        $changed(COND) |-> TARGET == EXPECTED;
    endproperty

    //  Active high asynchronous, Active high asynchronous reset
    //  CLK     : sampling clock
    //  ARST    : asynchronous reset signal
    //  SRST    : synchronous reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_ARn_COND_NOW(CLK, ARSTn, COND, TARGET, EXPECTED);
        @(posedge CLK) disable iff (!ARSTn)
        (COND) |-> ((TARGET) == (EXPECTED));
    endproperty

    //  Active high asynchronous, Active high asynchronous reset
    //  CLK     : sampling clock
    //  ARST    : asynchronous reset signal
    //  SRST    : synchronous reset signal
    //  TARGET  : signal to be checked
    //  EXPECTED: expecting value
    property P_FF_ARn_COND_WAIT(CLK, ARSTn, COND, TARGET, EXPECTED);
        @(posedge CLK) disable iff (!ARSTn)
        (COND) |=> ((TARGET) == $past(EXPECTED));
    endproperty

    property P_FF_ARn_COND_UCHANGE(CLK, ARSTn, COND, VALUE);
        @(posedge CLK) disable iff (!ARSTn)
        (COND) |=> (VALUE) == $past(VALUE);
    endproperty
    
    property P_FF_ARn_COND_UPDT(CLK, ARSTn, COND, TARGET, EXPECTED);
        @(posedge CLK) disable iff (!ARSTn)
        (COND) |-> TARGET == $past(EXPECTED);
    endproperty

    property P_FF_COND_UPDT(CLK, COND, TARGET, EXPECTED);
        @(posedge CLK) 
        (COND) |-> TARGET == EXPECTED;
    endproperty

endpackage
