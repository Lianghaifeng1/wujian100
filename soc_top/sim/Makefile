XRUN ?= /opt/eda/cadence/XCELUMMAIN2309/tools/bin/xrun
CASE_NAME ?= soc_top_smoke
SW_PAT ?=
WAVE ?= 0

ifeq ($(filter fm_test% soc_top%,$(CASE_NAME)),)
$(error Invalid CASE_NAME '$(CASE_NAME)'. Expected fm_test* or soc_top*)
endif

ifeq ($(filter fm_test%,$(CASE_NAME)),)
UVM_TESTNAME := soc_top_test_uvm_base
SW_ARG :=
else
UVM_TESTNAME := soc_top_test_fm_base
ifneq ($(SW_PAT),)
SW_ARG := +SW_PAT=$(SW_PAT)
else
SW_ARG :=
endif
endif

WAVE_DEFINE :=
ifeq ($(WAVE),0)
WAVE_DEFINE := +define+NO_DUMP
endif

XRUN_FLAGS ?= -64bit -sv -uvm -timescale 1ns/100ps -access +rwc
XRUN_FLAGS += $(WAVE_DEFINE)
XRUN_FLAGS += -f rtl_file.list -f soc_top_file.list
XRUN_FLAGS += +CASE_NAME=$(CASE_NAME) +UVM_TESTNAME=$(UVM_TESTNAME) $(SW_ARG)

.PHONY: run compile clean

run:
	$(XRUN) $(XRUN_FLAGS) -R

compile:
	$(XRUN) $(XRUN_FLAGS) -elaborate

clean:
	rm -rf xcelium.d xrun.history xrun.log waves.shm test.vcd run_case.report rtl_gpr.log
