SHELL := /bin/bash
.DEFAULT_GOAL := run


# ============================================================
# USER OPTIONS
# ============================================================

TEST      ?= bmu_smoke_test
REG_TEST  := bmu_regression_test
SEED      ?= 1
VERBOSITY ?= UVM_MEDIUM


# ============================================================
# DESIGN
# ============================================================

TOP      := bmu_tb_top
DUT      := Bit_Manipulation_Unit
FILELIST := filelist.f
SNAPSHOT := bmu_uvm_snapshot


# RTL files used only for the optional source-level exercise ratio.
RTL_FILES := \
	../rtl/Bit_Manipulation_Unit.sv \
	../rtl/rtl_lib.sv \
	../rtl/rtl_param.sv \
	../rtl/rtl_pdef.sv \
	../rtl/rtl_def.sv \
	../rtl/rtl_defines.sv


# ============================================================
# DIRECTORIES
# ============================================================

BUILD_DIR  := build
LOG_DIR    := logs
COV_DIR    := cov_work
REPORT_DIR := reports


# ============================================================
# TEST-SPECIFIC OUTPUT
# ============================================================

LOG           := $(LOG_DIR)/$(TEST)_seed$(SEED).log
COV_DB        := $(COV_DIR)/scope/$(TEST)

FUNC_REPORT   := $(REPORT_DIR)/$(TEST)_functional.txt
CODE_REPORT   := $(REPORT_DIR)/$(TEST)_code.txt
BLOCK_REPORT  := $(REPORT_DIR)/$(TEST)_block_detail.txt
EXPR_REPORT   := $(REPORT_DIR)/$(TEST)_expression_detail.txt
TOGGLE_REPORT := $(REPORT_DIR)/$(TEST)_toggle_detail.txt


# make imc              -> regression coverage
# make imc TEST=...     -> requested test coverage
IMC_TEST := $(if $(filter command line,$(origin TEST)),$(TEST),$(REG_TEST))
IMC_DB   := $(COV_DIR)/scope/$(IMC_TEST)


# ============================================================
# XRUN OPTIONS
# ============================================================

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
	-timescale 1ns/1ps \
	-coverage all \
	-covdut $(DUT) \
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
	-covtest $(TEST) \
	-covoverwrite


# ============================================================
# COMPILE
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
# ============================================================

run: compile
	@echo ""
	@echo "============================================================"
	@echo " RUN : $(TEST)"
	@echo " SEED: $(SEED)"
	@echo "============================================================"

	@xrun $(RUN_FLAGS) \
		-l $(LOG)

	@echo ""
	@echo "============================================================"
	@echo " SCOREBOARD : $(TEST)"
	@echo "============================================================"
	@grep "\[BMU_SB_SUMMARY\]" $(LOG) | tail -1 || true

	@echo ""
	@echo "============================================================"
	@echo " UVM RESULT"
	@echo "============================================================"
	@grep -E "UVM_(ERROR|FATAL)[[:space:]]*:" $(LOG) | tail -2 || true


# ============================================================
# CHECK
# ============================================================

check:
	@$(MAKE) --no-print-directory run \
		TEST=$(TEST) \
		SEED=$(SEED) \
		VERBOSITY=$(VERBOSITY)

	@$(MAKE) --no-print-directory coverage \
		TEST=$(TEST) \
		SEED=$(SEED)


# ============================================================
# REGRESSION
# ============================================================

regression:
	@$(MAKE) --no-print-directory check \
		TEST=$(REG_TEST) \
		SEED=$(SEED) \
		VERBOSITY=$(VERBOSITY)


# ============================================================
# COVERAGE
# ============================================================

coverage:
	@if [[ ! -d "$(COV_DB)" ]]; then \
		echo "ERROR: Coverage database not found for $(TEST)"; \
		echo "Expected: $(COV_DB)"; \
		echo ""; \
		echo "Run first:"; \
		echo "  make run TEST=$(TEST)"; \
		exit 1; \
	fi

	@mkdir -p $(REPORT_DIR)

	@echo ""
	@echo "============================================================"
	@echo " COVERAGE : $(TEST)"
	@echo "============================================================"


	@imc \
		-load $(COV_DB) \
		-execcmd "report -detail -metrics functional -all -out $(FUNC_REPORT); exit" \
		> $(REPORT_DIR)/$(TEST)_functional_imc.log 2>&1


	@imc \
		-load $(COV_DB) \
		-execcmd "report -summary -metrics all -cumulative on -showempty on -out $(CODE_REPORT); exit" \
		> $(REPORT_DIR)/$(TEST)_code_imc.log 2>&1


	@imc \
		-load $(COV_DB) \
		-execcmd "report -detail -metrics block -all -out $(BLOCK_REPORT); exit" \
		> $(REPORT_DIR)/$(TEST)_block_imc.log 2>&1


	@imc \
		-load $(COV_DB) \
		-execcmd "report -detail -metrics expression -all -out $(EXPR_REPORT); exit" \
		> $(REPORT_DIR)/$(TEST)_expression_imc.log 2>&1


	@imc \
		-load $(COV_DB) \
		-execcmd "report -detail -metrics toggle -all -out $(TOGGLE_REPORT); exit" \
		> $(REPORT_DIR)/$(TEST)_toggle_imc.log 2>&1


	@echo ""
	@echo "============================================================"
	@echo " FUNCTIONAL COVERAGE"
	@echo "============================================================"

	@if [[ -s "$(FUNC_REPORT)" ]]; then \
		awk '$$1 ~ /^cg_/ { \
			name=$$1; \
			sub(/^cg_/, "", name); \
			gsub(/_/, " ", name); \
			printf "%-28s %8s %s\n", name, $$3, $$4; \
		}' $(FUNC_REPORT); \
	else \
		echo "Functional coverage report is empty."; \
	fi


	@echo ""
	@echo "============================================================"
	@echo " OFFICIAL XCELIUM CODE COVERAGE"
	@echo "============================================================"

	@awk '$$1 == "$(DUT)" { \
		printf "Block Coverage      : %s %s\n", $$3, $$4; \
		printf "Expression Coverage : %s %s\n", $$8, $$9; \
		printf "Toggle Coverage     : %s %s\n", $$13, $$14; \
		found=1; \
		exit; \
	} \
	END { \
		if (!found) \
			print "DUT coverage row not found in code report."; \
	}' $(CODE_REPORT)


	@echo ""
	@echo "============================================================"
	@echo " SOURCE BLOCK EXERCISE RATIO"
	@echo "============================================================"

	@total_blocks=$$(awk '\
		{ \
			line=$$0; \
			sub(/\/\/.*/, "", line); \
			\
			if (line ~ /^[[:space:]]*always_comb([[:space:]]|$$)/ || \
			    line ~ /^[[:space:]]*always_ff([[:space:]]|$$)/ || \
			    line ~ /^[[:space:]]*always_latch([[:space:]]|$$)/ || \
			    line ~ /^[[:space:]]*always[[:space:]]*@/) \
				total += 1; \
			\
			if (line ~ /^[[:space:]]*if[[:space:]]*\(/) \
				total += 1; \
			\
			if (line ~ /^[[:space:]]*(end[[:space:]]+)?else([[:space:]]|$$)/) \
				total += 1; \
			\
			if (line ~ /^[[:space:]]*for[[:space:]]*\(/) \
				total += 2; \
		} \
		END { print total+0 }' $(RTL_FILES)); \
	\
	covered_blocks=$$(awk '\
		/^File name:/ { \
			file=$$0; \
			sub(/^File name:[[:space:]]*/, "", file); \
		} \
		$$1 ~ /^[0-9]+$$/ && \
		$$2 ~ /^[0-9]+$$/ && \
		$$3 ~ /^[0-9]+$$/ { \
			if ($$1 > 0) { \
				key=file "|" $$2 "|" $$3; \
				hit[key]=1; \
			} \
		} \
		END { \
			n=0; \
			for (k in hit) n++; \
			print n; \
		}' $(BLOCK_REPORT)); \
	\
	if [[ $$covered_blocks -gt $$total_blocks ]]; then \
		covered_blocks=$$total_blocks; \
	fi; \
	\
	pct=$$(awk \
		-v c="$$covered_blocks" \
		-v t="$$total_blocks" \
		'BEGIN { \
			if (t > 0) \
				printf "%.2f", 100*c/t; \
			else \
				printf "0.00"; \
		}'); \
	\
	echo "Source Exercise      : $$covered_blocks/$$total_blocks ($$pct%)"; \
	echo "(Source-level audit metric; not an official Xcelium metric.)"


	@echo ""
	@echo "============================================================"
	@echo " SCOREBOARD"
	@echo "============================================================"

	@if [[ -f "$(LOG)" ]]; then \
		grep "\[BMU_SB_SUMMARY\]" $(LOG) | tail -1 || true; \
	else \
		echo "Log not found: $(LOG)"; \
	fi


	@echo ""
	@echo "============================================================"
	@echo " REPORT FILES"
	@echo "============================================================"
	@echo "Functional : $(FUNC_REPORT)"
	@echo "Code       : $(CODE_REPORT)"
	@echo "Block      : $(BLOCK_REPORT)"
	@echo "Expression : $(EXPR_REPORT)"
	@echo "Toggle     : $(TOGGLE_REPORT)"
	@echo "============================================================"


# ============================================================
# WAVEFORM
# ============================================================

wave: compile
	@echo ""
	@echo "============================================================"
	@echo " WAVE : $(TEST)"
	@echo "============================================================"

	@xrun $(RUN_FLAGS) \
		-gui \
		-l $(LOG)


# ============================================================
# IMC GUI
# ============================================================

imc:
	@if [[ ! -d "$(IMC_DB)" ]]; then \
		echo "ERROR: Coverage database not found for $(IMC_TEST)"; \
		echo "Expected: $(IMC_DB)"; \
		echo ""; \
		echo "Available coverage databases:"; \
		if [[ -d "$(COV_DIR)/scope" ]]; then \
			find $(COV_DIR)/scope -mindepth 1 -maxdepth 1 -type d \
				-printf "  %f\n" 2>/dev/null || true; \
		else \
			echo "  none"; \
		fi; \
		echo ""; \
		echo "Examples:"; \
		echo "  make regression"; \
		echo "  make imc"; \
		echo "  make imc TEST=bmu_ctz_test"; \
		exit 1; \
	fi

	@echo "[IMC] $(IMC_TEST)"

	@imc \
		-load $(IMC_DB) \
		-gui


# ============================================================
# CLEAN
# ============================================================

clean:
	@echo "[CLEAN] Removing generated simulation files"

	@rm -rf \
		$(BUILD_DIR) \
		$(LOG_DIR) \
		$(COV_DIR) \
		$(REPORT_DIR) \
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
# HELP
# ============================================================

help:
	@echo ""
	@echo "BMU UVM Verification"
	@echo ""
	@echo "Run default smoke test:"
	@echo "  make"
	@echo ""
	@echo "Run specific test:"
	@echo "  make run TEST=bmu_ctz_test"
	@echo ""
	@echo "Run test + coverage:"
	@echo "  make check TEST=bmu_ctz_test"
	@echo ""
	@echo "Generate coverage report:"
	@echo "  make coverage TEST=bmu_ctz_test"
	@echo ""
	@echo "Run full regression:"
	@echo "  make regression"
	@echo "  make regression SEED=20"
	@echo ""
	@echo "Open regression coverage in IMC:"
	@echo "  make imc"
	@echo ""
	@echo "Open specific test in IMC:"
	@echo "  make imc TEST=bmu_ctz_test"
	@echo ""
	@echo "Run with GUI:"
	@echo "  make wave TEST=bmu_ctz_test"
	@echo ""
	@echo "Remove generated files:"
	@echo "  make clean"
	@echo ""


.PHONY: compile run check regression coverage wave imc clean help
