SHELL := /bin/bash
.DEFAULT_GOAL := run


TEST      ?= bmu_smoke_test
REG_TEST  := bmu_regression_test
SEED      ?= 1
VERBOSITY ?= UVM_MEDIUM


TOP      := bmu_tb_top
DUT      := Bit_Manipulation_Unit
FILELIST := filelist.f
SNAPSHOT := bmu_uvm_snapshot


RTL_FILES := \
	../rtl/Bit_Manipulation_Unit.sv \
	../rtl/rtl_lib.sv \
	../rtl/rtl_param.sv \
	../rtl/rtl_pdef.sv \
	../rtl/rtl_def.sv \
	../rtl/rtl_defines.sv


BUILD_DIR  := build
LOG_DIR    := logs
COV_DIR    := cov_work
REPORT_DIR := reports


LOG           := $(LOG_DIR)/$(TEST)_seed$(SEED).log
COV_DB        := $(COV_DIR)/scope/$(TEST)
FUNC_REPORT   := $(REPORT_DIR)/$(TEST)_functional.txt
CODE_REPORT   := $(REPORT_DIR)/$(TEST)_code.txt
BLOCK_REPORT  := $(REPORT_DIR)/$(TEST)_block_detail.txt
EXPR_REPORT   := $(REPORT_DIR)/$(TEST)_expression_detail.txt
TOGGLE_REPORT := $(REPORT_DIR)/$(TEST)_toggle_detail.txt


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


compile:
	@mkdir -p $(BUILD_DIR) $(LOG_DIR) $(COV_DIR) $(REPORT_DIR)
	@echo "[COMPILE] BMU UVM"
	@xrun $(COMPILE_FLAGS) \
		-l $(LOG_DIR)/compile.log


run: compile
	@echo "[RUN] $(TEST) seed=$(SEED)"
	@xrun $(RUN_FLAGS) \
		-l $(LOG)

	@echo ""
	@grep "\[BMU_SB_SUMMARY\]" $(LOG) | tail -1 || true


check:
	@$(MAKE) --no-print-directory run \
		TEST=$(TEST) \
		SEED=$(SEED)

	@$(MAKE) --no-print-directory coverage \
		TEST=$(TEST) \
		SEED=$(SEED)


regression:
	@$(MAKE) --no-print-directory check \
		TEST=$(REG_TEST) \
		SEED=$(SEED)


coverage:
	@if [[ ! -d "$(COV_DB)" ]]; then \
		echo "Coverage database not found for $(TEST)"; \
		echo "Run: make run TEST=$(TEST)"; \
		exit 1; \
	fi

	@mkdir -p $(REPORT_DIR)

	@echo "[COVERAGE] $(TEST)"


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
	@echo " FUNCTIONAL COVERAGE : $(TEST)"
	@echo "============================================================"

	@awk '$$1 ~ /^cg_/ { \
		name=$$1; \
		sub(/^cg_/, "", name); \
		gsub(/_/, " ", name); \
		printf "%-28s %8s %s\n", name, $$3, $$4; \
	}' $(FUNC_REPORT)


	@echo ""
	@echo "============================================================"
	@echo " CODE COVERAGE : $(TEST)"
	@echo "============================================================"


	@total_blocks=$$(awk '\
		{ \
			line=$$0; \
			sub(/\/\/.*/, "", line); \
			\
			if (line ~ /^[[:space:]]*always_comb([[:space:]]|$$)/ || \
			    line ~ /^[[:space:]]*always_ff([[:space:]]|$$)/   || \
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
		END {print total+0}' $(RTL_FILES)); \
	\
	covered_blocks=$$(awk '\
		/^File name:/ { \
			file=$$0; \
			sub(/^File name:[[:space:]]*/, "", file); \
		} \
		$$1 ~ /^[0-9]+$$/ && $$2 ~ /^[0-9]+$$/ && $$3 ~ /^[0-9]+$$/ { \
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
	block_pct=$$(awk \
		-v c="$$covered_blocks" \
		-v t="$$total_blocks" \
		'BEGIN { \
			if (t > 0) printf "%.2f", 100*c/t; \
			else printf "0.00"; \
		}'); \
	\
	echo "Block Coverage      : $$covered_blocks/$$total_blocks ($$block_pct%)"


	@awk '$$1 == "$(DUT)" { \
		printf "Expression Coverage : %s %s\n", $$8, $$9; \
		printf "Toggle Coverage     : %s %s\n", $$13, $$14; \
	}' $(CODE_REPORT)


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
	@echo " REPORTS"
	@echo "============================================================"
	@echo "Functional : $(FUNC_REPORT)"
	@echo "Block      : $(BLOCK_REPORT)"
	@echo "Expression : $(EXPR_REPORT)"
	@echo "Toggle     : $(TOGGLE_REPORT)"
	@echo "============================================================"


wave: compile
	@echo "[WAVE] $(TEST) seed=$(SEED)"
	@xrun $(RUN_FLAGS) \
		-gui \
		-l $(LOG)


imc:
	@if [[ ! -d "$(COV_DB)" ]]; then \
		echo "Coverage database not found for $(TEST)"; \
		exit 1; \
	fi

	@echo "[IMC] $(TEST)"
	@imc \
		-load $(COV_DB) \
		-gui


clean:
	@echo "[CLEAN] Removing all generated simulation files"

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
		imc.key \
		hdl.var \
		cds.lib

	@echo "[CLEAN] Done"

help:
	@echo ""
	@echo "BMU Verification"
	@echo ""
	@echo "make"
	@echo "make run TEST=bmu_ctz_test"
	@echo "make check TEST=bmu_ctz_test"
	@echo "make coverage TEST=bmu_ctz_test"
	@echo "make regression"
	@echo "make regression SEED=20"
	@echo "make wave TEST=bmu_ctz_test"
	@echo "make imc TEST=bmu_ctz_test"
	@echo "make clean"
	@echo ""


.PHONY: compile run check regression coverage wave imc clean help