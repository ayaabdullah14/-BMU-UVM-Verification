################################################################################
# BMU UVM Verification Makefile
# Simulator: Cadence Xcelium
#
# Main usage:
#   make                          -> run one test (default smoke)
#   make TEST=bmu_ctz_test        -> run one specific test
#   make regression               -> run bmu_regression_test
#   make wave TEST=bmu_ctz_test   -> run with GUI
#   make report                   -> print last generated reports
#   make imc                      -> open coverage database
#   make clean                    -> remove generated files
################################################################################

SHELL := /bin/bash

.DEFAULT_GOAL := _run


################################################################################
# Configuration
################################################################################

TEST       ?= bmu_smoke_test
REG_TEST   := bmu_regression_test

SEED       ?= 1
VERBOSITY  ?= UVM_MEDIUM

TOP        := bmu_tb_top
DUT        := Bit_Manipulation_Unit

FILELIST   := filelist.f
SNAPSHOT   := bmu_uvm_snapshot

TIMESCALE  := 1ns/1ps


################################################################################
# Directories
################################################################################

BUILD_DIR   := build
LOG_DIR     := logs
COV_DIR     := cov_work
REPORT_DIR  := reports

FUNC_REPORT := $(REPORT_DIR)/functional_detail.txt
CODE_REPORT := $(REPORT_DIR)/code_summary.txt


################################################################################
# Xcelium Compile Options
################################################################################

COMPILE_FLAGS := \
	-64bit \
	-sv \
	-uvm \
	-f $(FILELIST) \
	-top $(TOP) \
	-elaborate \
	-snapshot $(SNAPSHOT) \
	-xmlibdirname $(BUILD_DIR)/xcelium.d \
	-access +rwc \
	-timescale $(TIMESCALE) \
	-coverage all \
	-covdut $(DUT) \
	-covworkdir $(COV_DIR)


################################################################################
# Xcelium Run Options
################################################################################

RUN_FLAGS := \
	-64bit \
	-R \
	-snapshot $(SNAPSHOT) \
	-xmlibdirname $(BUILD_DIR)/xcelium.d \
	+UVM_VERBOSITY=$(VERBOSITY) \
	-svseed $(SEED) \
	-coverage all \
	-covworkdir $(COV_DIR) \
	-covoverwrite


################################################################################
# Compile + Elaborate
################################################################################

_compile:

	@mkdir -p \
		$(BUILD_DIR) \
		$(LOG_DIR) \
		$(COV_DIR) \
		$(REPORT_DIR)

	@echo ""
	@echo "============================================================"
	@echo "               COMPILE BMU UVM ENVIRONMENT"
	@echo "============================================================"

	@xrun $(COMPILE_FLAGS) \
		-l $(LOG_DIR)/compile.log


################################################################################
# SINGLE TEST
#
# Examples:
#
#   make
#   make TEST=bmu_ctz_test
#   make TEST=bmu_ror_test
#   make TEST=bmu_error_test
#   make TEST=bmu_ctz_test SEED=20
################################################################################

_run: _compile

	@echo ""
	@echo "============================================================"
	@echo "                    BMU SINGLE TEST"
	@echo "============================================================"
	@echo "[TEST] $(TEST)"
	@echo "[SEED] $(SEED)"
	@echo "============================================================"

	@xrun $(RUN_FLAGS) \
		+UVM_TESTNAME=$(TEST) \
		-covtest $(TEST) \
		-l $(LOG_DIR)/$(TEST)_seed$(SEED).log

	@errors=$$(awk \
		'/^UVM_ERROR[[:space:]]*:/ {v=$$3} END {print v+0}' \
		$(LOG_DIR)/$(TEST)_seed$(SEED).log); \
	\
	fatals=$$(awk \
		'/^UVM_FATAL[[:space:]]*:/ {v=$$3} END {print v+0}' \
		$(LOG_DIR)/$(TEST)_seed$(SEED).log); \
	\
	if [[ $$fatals -gt 0 ]]; then \
		status="FATAL"; \
	elif [[ $$errors -gt 0 ]]; then \
		status="FAIL"; \
	else \
		status="PASS"; \
	fi; \
	\
	echo ""; \
	echo "------------------------------------------------------------"; \
	echo "[RESULT] $(TEST) : $$status"; \
	echo "[ERRORS] $$errors"; \
	echo "[FATALS] $$fatals"; \
	echo "[LOG]    $(LOG_DIR)/$(TEST)_seed$(SEED).log"; \
	echo "------------------------------------------------------------"


regression:

	@echo ""
	@echo "============================================================"
	@echo "                   BMU FULL REGRESSION"
	@echo "============================================================"

	@rm -rf $(COV_DIR) $(REPORT_DIR)

	@mkdir -p \
		$(COV_DIR) \
		$(REPORT_DIR) \
		$(LOG_DIR)

	@$(MAKE) --no-print-directory _compile

	@echo ""
	@echo "------------------------------------------------------------"
	@echo "[RUN]  $(REG_TEST)"
	@echo "[SEED] $(SEED)"
	@echo "------------------------------------------------------------"

	@xrun $(RUN_FLAGS) \
		+UVM_TESTNAME=$(REG_TEST) \
		-covtest $(REG_TEST) \
		-l $(LOG_DIR)/$(REG_TEST)_seed$(SEED).log

	@errors=$$(awk \
		'/^UVM_ERROR[[:space:]]*:/ {v=$$3} END {print v+0}' \
		$(LOG_DIR)/$(REG_TEST)_seed$(SEED).log); \
	\
	fatals=$$(awk \
		'/^UVM_FATAL[[:space:]]*:/ {v=$$3} END {print v+0}' \
		$(LOG_DIR)/$(REG_TEST)_seed$(SEED).log); \
	\
	if [[ $$fatals -gt 0 ]]; then \
		status="FATAL"; \
	elif [[ $$errors -gt 0 ]]; then \
		status="FAIL"; \
	else \
		status="PASS"; \
	fi; \
	\
	echo ""; \
	echo "============================================================"; \
	echo "                 REGRESSION RESULT"; \
	echo "============================================================"; \
	echo "[STATUS] $$status"; \
	echo "[ERRORS] $$errors"; \
	echo "[FATALS] $$fatals"; \
	echo "[LOG]    $(LOG_DIR)/$(REG_TEST)_seed$(SEED).log"; \
	echo "============================================================"

	@$(MAKE) --no-print-directory coverage


################################################################################
# GENERATE COVERAGE REPORTS
#
# No merge is required.
#
# All sequences were executed inside bmu_regression_test,
# therefore its coverage database already contains the complete run.
################################################################################

coverage:

	@echo ""
	@echo "============================================================"
	@echo "                 GENERATE COVERAGE REPORTS"
	@echo "============================================================"

	@if [[ ! -d "$(COV_DIR)/scope/$(REG_TEST)" ]]; then \
		echo "Coverage database not found:"; \
		echo "  $(COV_DIR)/scope/$(REG_TEST)"; \
		exit 1; \
	fi

	@echo "[COVERAGE] Functional coverage..."

	@imc \
		-load $(COV_DIR)/scope/$(REG_TEST) \
		-execcmd \
		"report -detail \
		        -metrics functional \
		        -all \
		        -out $(FUNC_REPORT); exit" \
		> $(REPORT_DIR)/imc_functional.log 2>&1


	@echo "[COVERAGE] DUT code coverage..."

	@imc \
		-load $(COV_DIR)/scope/$(REG_TEST) \
		-execcmd \
		"report -summary \
		        -inst *... \
		        -metrics all \
		        -cumulative on \
		        -showempty on \
		        -out $(CODE_REPORT); exit" \
		> $(REPORT_DIR)/imc_code.log 2>&1


	@$(MAKE) --no-print-directory report


################################################################################
# REPORT
################################################################################

report:

	@echo ""
	@echo "============================================================"
	@echo "                    BMU LAST REPORT"
	@echo "============================================================"


	@log="$(LOG_DIR)/$(REG_TEST)_seed$(SEED).log"; \
	\
	if [[ -f "$$log" ]]; then \
		\
		echo ""; \
		echo "============================================================"; \
		echo "                     REGRESSION"; \
		echo "============================================================"; \
		\
		errors=$$(awk \
			'/^UVM_ERROR[[:space:]]*:/ {v=$$3} END {print v+0}' \
			"$$log"); \
		\
		fatals=$$(awk \
			'/^UVM_FATAL[[:space:]]*:/ {v=$$3} END {print v+0}' \
			"$$log"); \
		\
		if [[ $$fatals -gt 0 ]]; then \
			status="FATAL"; \
		elif [[ $$errors -gt 0 ]]; then \
			status="FAIL"; \
		else \
			status="PASS"; \
		fi; \
		\
		echo "Status : $$status"; \
		echo "Errors : $$errors"; \
		echo "Fatals : $$fatals"; \
		echo "Log    : $$log"; \
	fi


	@echo ""
	@echo "============================================================"
	@echo "                 FUNCTIONAL COVERAGE"
	@echo "============================================================"

	@if [[ -f "$(FUNC_REPORT)" ]]; then \
		awk '/^cg_/ { \
			name=$$1; \
			sub(/^cg_/, "", name); \
			gsub(/_/, " ", name); \
			pct=$$3; \
			gsub(/,/, "", pct); \
			bins=$$4; \
			printf "%-30s %8s  %s\n", \
			       name, pct, bins; \
		}' $(FUNC_REPORT); \
	else \
		echo "Functional coverage report not found."; \
	fi


	@echo ""
	@echo "============================================================"
	@echo "                   DUT CODE COVERAGE"
	@echo "============================================================"

	@if [[ -f "$(CODE_REPORT)" ]]; then \
		awk '/^Bit_Manipulation_Unit[[:space:]]/ { \
			printf "%-25s %s %s\n", \
			       "Block", $$3, $$4; \
			printf "%-25s %s %s\n", \
			       "Expression", $$8, $$9; \
			printf "%-25s %s %s\n", \
			       "Toggle", $$13, $$14; \
			found=1; \
		} END { \
			if (!found) \
				print "DUT code coverage not found."; \
		}' $(CODE_REPORT); \
	else \
		echo "Code coverage report not found."; \
	fi


	@echo ""
	@echo "============================================================"
	@echo "                    SCOREBOARD"
	@echo "============================================================"

	@log="$(LOG_DIR)/$(REG_TEST)_seed$(SEED).log"; \
	if [[ -f "$$log" ]]; then \
		grep "\[BMU_SB_SUMMARY\]" "$$log" | tail -1 || true; \
	else \
		echo "Regression log not found."; \
	fi

	@echo "============================================================"


################################################################################
# WAVEFORM / GUI
#
# Example:
#
#   make wave TEST=bmu_ctz_test
#   make wave TEST=bmu_regression_test
################################################################################

wave: _compile

	@echo ""
	@echo "============================================================"
	@echo "                    BMU WAVE RUN"
	@echo "============================================================"
	@echo "[TEST] $(TEST)"
	@echo "[SEED] $(SEED)"
	@echo "============================================================"

	@xrun $(RUN_FLAGS) \
		+UVM_TESTNAME=$(TEST) \
		-covtest $(TEST) \
		-gui \
		-l $(LOG_DIR)/$(TEST)_seed$(SEED).log


################################################################################
# OPEN IMC
################################################################################

imc:

	@if [[ -d "$(COV_DIR)/scope/$(REG_TEST)" ]]; then \
		echo "Opening regression coverage..."; \
		imc \
			-load $(COV_DIR)/scope/$(REG_TEST) \
			-gui; \
	else \
		latest=$$(ls -1dt \
			$(COV_DIR)/scope/*/ \
			2>/dev/null | head -1); \
		\
		if [[ -z "$$latest" ]]; then \
			echo "No coverage database found."; \
			exit 1; \
		fi; \
		\
		echo "Opening coverage: $$latest"; \
		imc \
			-load "$$latest" \
			-gui; \
	fi


################################################################################
# CLEAN
################################################################################

clean:

	@echo "Cleaning generated files..."

	@rm -rf \
		$(BUILD_DIR) \
		$(LOG_DIR) \
		$(COV_DIR) \
		$(REPORT_DIR) \
		xcelium.d \
		INCA_libs \
		.simvision \
		waves.shm \
		xrun.* \
		*.history \
		*.key


################################################################################

.PHONY: \
	_run \
	_compile \
	regression \
	coverage \
	report \
	wave \
	imc \
	clean