#!/usr/bin/env bash
set -euo pipefail

# TODO: extend this command as simulator and coverage options are approved.
xrun -64bit -sv -uvm -f filelist.f -top bmu_tb_top

