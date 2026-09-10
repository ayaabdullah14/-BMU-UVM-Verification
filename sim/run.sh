#!/usr/bin/env bash
set -euo pipefail

test_name="${1:-bmu_smoke_test}"

mkdir -p logs

xrun -64bit -sv -uvm \
  -timescale 1ns/1ps \
  -f filelist.f \
  -top bmu_tb_top \
  "+UVM_TESTNAME=${test_name}" \
  +UVM_VERBOSITY=UVM_MEDIUM \
  -l "logs/${test_name}.log"