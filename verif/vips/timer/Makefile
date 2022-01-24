SEED                := $(shell echo $$RANDOM)
OUT                 := out
OUT-SEED            := $(OUT)/seed-$(SEED)
GEN_OPTS            := -clean \
                       -sv \
                       -uvm \
                       -access rwc \
                       -linedebug \
                       -f ./compile_file/run.f \
                       -svseed $(SEED) \
                       +UVM_TESTNAME=tx_test \
                       +UVM_VERBOSITY=UVM_LOW \
                       +define+UVM_REPORT_DISABLE_FILE_LINE \
                       +uvm_set_config_int=uvm_test_top,base_address,23 \
                       +UVM_CONFIG_DB_TRACE +UVM_OBJECTION_TRACE

export SEED
export OUT
export OUT-SEED
export GEN_OPTS

run_test:
	@echo "SEED=" $(SEED)
	@echo "OUT-SEED=" $(OUT-SEED)
	@echo "GEN_OPTS=" $(GEN_OPTS)
	xrun $(GEN_OPTS)

run_py:
	python run_test.py