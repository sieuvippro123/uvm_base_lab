database -open -shm $::env(UVM_TESTNAME)
probe -create $::env(UVM_TEST_TOP) -depth all -all -shm -database $::env(UVM_TESTNAME)
run
exit