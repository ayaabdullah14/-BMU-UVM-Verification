SHELL := /bin/bash
.DEFAULT_GOAL := run

# ============================================================
# USER OPTIONS
# ============================================================

# Default test. Override from command line when needed:
#   make run TEST=bmu_ctz_test SEED=4
TEST      ?= bmu_regression_test
SEED      ?= 1
VERBOSITY ?= UVM_LOW

# Keep each test/seed in a separate coverage database.
RUN_NAME := $(TEST)_seed$(SEED)


# ============================================================
# DESIGN
# ============================================================

FILELIST := filelist.f
SNAPSHOT := bmu_uvm_snapshot


# ============================================================
# DIRECTORIES / OUTPUT
# ============================================================

BUILD_DIR  := build
LOG_DIR    := logs
COV_DIR    := cov_work
REPORT_DIR := reports/$(RUN_NAME)

LOG    := $(LOG_DIR)/$(RUN_NAME).log
COV_DB := $(COV_DIR)/scope/$(RUN_NAME)

# Official IMC reports.
FUNC_SUMMARY   := $(REPORT_DIR)/functional_summary.txt
FUNC_DETAIL    := $(REPORT_DIR)/functional_detail.txt

BLOCK_SUMMARY  := $(REPORT_DIR)/block_summary.txt
BLOCK_DETAIL   := $(REPORT_DIR)/block_detail.txt

EXPR_SUMMARY   := $(REPORT_DIR)/expression_summary.txt
EXPR_DETAIL    := $(REPORT_DIR)/expression_detail.txt

TOGGLE_SUMMARY := $(REPORT_DIR)/toggle_summary.txt
TOGGLE_DETAIL  := $(REPORT_DIR)/toggle_detail.txt


# ============================================================
# XRUN OPTIONS
#
# Keep the same final coverage scope:
#   - coverage enabled during compile and run
#   - no -covdut restriction
#   - no -top restriction
#   - every TEST + SEED gets its own database
# ============================================================

COMPILE_FLAGS := \
	-64bit \
	-sv \
	-uvm \
	-f $(FILELIST) \
	-elaborate \
	-snapshot $(SNAPSHOT) \
	-xmlibdirname $(BUILD_DIR)/xcelium.d \
	-access +rwc \
	-timescale 1ns/1ps \
	-coverage all \
	-covworkdir $(COV_DIR)

RUN_FLAGS := \
	-64bit \
	-R \
	-snapshot $(SNAPSHOT) \
	-xmlibdirname $(BUILD_DIR)/xcelium.d \
	+UVM_TESTNAME=$(TEST) \
	+UVM_VERBOSITY=$(VERBOSITY) \
	-svseed $(SEED) \
	-coverage all \
	-covworkdir $(COV_DIR) \
	-covtest $(RUN_NAME) \
	-covoverwrite


# ============================================================
# CLEAN
#   make clean
# ============================================================

clean:
	@echo "[CLEAN] Removing generated simulation files"
	@rm -rf \
		$(BUILD_DIR) \
		$(LOG_DIR) \
		$(COV_DIR) \
		reports \
		xcelium.d \
		INCA_libs \
		.simvision \
		waves \
		waves.shm \
		html_* \
		xrun.* \
		xcelium.* \
		*.history \
		*.key \
		*.diag \
		mdv.log \
		imc.log \
		hdl.var \
		cds.lib
	@echo "[CLEAN] Done"


# ============================================================
# COMPILE
#   make compile
# ============================================================

compile:
	@mkdir -p $(BUILD_DIR) $(LOG_DIR) $(COV_DIR) $(REPORT_DIR)
	@echo "============================================================"
	@echo " COMPILE"
	@echo "============================================================"
	@xrun $(COMPILE_FLAGS) \
		-l $(LOG_DIR)/compile.log


# ============================================================
# RUN
#   make run
#   make run TEST=bmu_ctz_test SEED=4
# ============================================================

run: compile
	@mkdir -p $(REPORT_DIR)
	@echo ""
	@echo "============================================================"
	@echo " RUN"
	@echo " TEST : $(TEST)"
	@echo " SEED : $(SEED)"
	@echo " DB   : $(COV_DB)"
	@echo "============================================================"

	@xrun $(RUN_FLAGS) \
		-l $(LOG)

	@echo ""
	@echo "============================================================"
	@echo " UVM RESULT"
	@echo "============================================================"
	@grep "\[BMU_SB_SUMMARY\]" $(LOG) | tail -1 || true
	@grep -E "^UVM_(ERROR|FATAL)[[:space:]]*:" $(LOG) | tail -2 || true


# ============================================================
# COVERAGE
#   make coverage
#   make coverage TEST=bmu_regression_test SEED=4
#
# IMPORTANT:
#   This keeps the final method we reached:
#   - IMC/Xcelium is the only source of coverage numbers.
#   - Functional coverage is separate from code coverage.
#   - Block / Expression / Toggle are separate code metrics.
#   - No fake source ratio.
#   - No hand-calculated coverage percentage.
# ============================================================

coverage:
	@if [[ ! -d "$(COV_DB)" ]]; then \
		echo "ERROR: Coverage database not found."; \
		echo "Expected: $(COV_DB)"; \
		echo "Run first:"; \
		echo "  make run TEST=$(TEST) SEED=$(SEED)"; \
		exit 1; \
	fi

	@mkdir -p $(REPORT_DIR)

	@echo ""
	@echo "============================================================"
	@echo " COVERAGE"
	@echo " TEST : $(TEST)"
	@echo " SEED : $(SEED)"
	@echo " DB   : $(COV_DB)"
	@echo "============================================================"

	@echo "[IMC] Functional coverage..."
	@imc -64 \
		-load $(COV_DB) \
		-execcmd "report -summary -metrics functional -cumulative on -showempty on -out $(FUNC_SUMMARY); exit" \
		> $(REPORT_DIR)/functional_summary_imc.log 2>&1

	@imc -64 \
		-load $(COV_DB) \
		-execcmd "report -detail -metrics functional -all -out $(FUNC_DETAIL); exit" \
		> $(REPORT_DIR)/functional_detail_imc.log 2>&1

	@echo "[IMC] Block coverage..."
	@imc -64 \
		-load $(COV_DB) \
		-execcmd "report -summary -metrics block -cumulative on -showempty on -out $(BLOCK_SUMMARY); exit" \
		> $(REPORT_DIR)/block_summary_imc.log 2>&1

	@imc -64 \
		-load $(COV_DB) \
		-execcmd "report -detail -metrics block -all -out $(BLOCK_DETAIL); exit" \
		> $(REPORT_DIR)/block_detail_imc.log 2>&1

	@echo "[IMC] Expression coverage..."
	@imc -64 \
		-load $(COV_DB) \
		-execcmd "report -summary -metrics expression -cumulative on -showempty on -out $(EXPR_SUMMARY); exit" \
		> $(REPORT_DIR)/expression_summary_imc.log 2>&1

	@imc -64 \
		-load $(COV_DB) \
		-execcmd "report -detail -metrics expression -all -out $(EXPR_DETAIL); exit" \
		> $(REPORT_DIR)/expression_detail_imc.log 2>&1

	@echo "[IMC] Toggle coverage..."
	@imc -64 \
		-load $(COV_DB) \
		-execcmd "report -summary -metrics toggle -cumulative on -showempty on -out $(TOGGLE_SUMMARY); exit" \
		> $(REPORT_DIR)/toggle_summary_imc.log 2>&1

	@imc -64 \
		-load $(COV_DB) \
		-execcmd "report -detail -metrics toggle -all -out $(TOGGLE_DETAIL); exit" \
		> $(REPORT_DIR)/toggle_detail_imc.log 2>&1

	@echo ""
	@echo "============================================================"
	@echo " COVERAGE SUMMARY"
	@echo "============================================================"

	@echo ""
	@echo "FUNCTIONAL COVERAGE - SUBSCRIBER"
	@echo "------------------------------------------------------------"
	@grep -E "subscriber[[:space:]]" $(FUNC_SUMMARY) | tail -1 || \
		echo "See: $(FUNC_SUMMARY)"

	@echo ""
	@echo "CODE COVERAGE - BMU HIERARCHY"
	@echo "------------------------------------------------------------"

	@echo "BLOCK:"
	@grep -E "^[[:space:]|+-]*bmu_tb_top[[:space:]]|^[[:space:]|+-]*dut[[:space:]]" \
		$(BLOCK_SUMMARY) | tail -2 || true

	@echo ""
	@echo "EXPRESSION:"
	@grep -E "^[[:space:]|+-]*bmu_tb_top[[:space:]]|^[[:space:]|+-]*dut[[:space:]]" \
		$(EXPR_SUMMARY) | tail -2 || true

	@echo ""
	@echo "TOGGLE:"
	@grep -E "^[[:space:]|+-]*bmu_tb_top[[:space:]]|^[[:space:]|+-]*dut[[:space:]]" \
		$(TOGGLE_SUMMARY) | tail -2 || true

	@echo ""
	@echo "CODE COVERAGE - ALL RTL SCOPE"
	@echo "------------------------------------------------------------"
	@echo "IMC GUI overall grades include every elaborated RTL design unit,"
	@echo "including standalone rtl_lib modules that may be unused by the BMU."
	@echo ""
	@echo "Top-level RTL entries with Block coverage data:"
	@grep -E "^[A-Za-z_][A-Za-z0-9_]*[[:space:]]+[0-9]" $(BLOCK_SUMMARY) || true

	@echo ""
	@echo "------------------------------------------------------------"
	@echo "IMPORTANT:"
	@echo "  BMU hierarchy numbers above are NOT the same as IMC's ALL-RTL grade."
	@echo "  Example: DUT Block can be 100% while IMC overall Block grade is lower"
	@echo "  because unused standalone rtl_lib modules are also in the denominator."
	@echo ""
	@echo "Full official IMC reports:"
	@echo "  Functional : $(FUNC_SUMMARY)"
	@echo "  Block      : $(BLOCK_SUMMARY)"
	@echo "  Expression : $(EXPR_SUMMARY)"
	@echo "  Toggle     : $(TOGGLE_SUMMARY)"
	@echo ""
	@echo "All displayed percentages are copied directly from IMC reports."
	@echo "No coverage percentage is calculated by the Makefile."
	@echo "============================================================"


# ============================================================
# WAVE
#   make wave
#   make wave TEST=bmu_ctz_test SEED=4
# ============================================================

wave: compile
	@mkdir -p $(REPORT_DIR)
	@echo ""
	@echo "============================================================"
	@echo " WAVE"
	@echo " TEST : $(TEST)"
	@echo " SEED : $(SEED)"
	@echo "============================================================"

	@xrun $(RUN_FLAGS) \
		-gui \
		-l $(LOG)


# ============================================================
# IMC
#   make imc
#   make imc TEST=bmu_regression_test SEED=4
# ============================================================

imc:
	@if [[ ! -d "$(COV_DB)" ]]; then \
		echo "ERROR: Coverage database not found."; \
		echo "Expected: $(COV_DB)"; \
		echo "Run first:"; \
		echo "  make run TEST=$(TEST) SEED=$(SEED)"; \
		exit 1; \
	fi

	@echo "[IMC] $(COV_DB)"
	@imc -64 \
		-load $(COV_DB) \
		-gui


.PHONY: clean compile run coverage wave imc
