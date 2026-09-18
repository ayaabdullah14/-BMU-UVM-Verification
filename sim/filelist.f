+incdir+../tb
+incdir+../tb/packages

+incdir+../tb/env
+incdir+../tb/env/agent
+incdir+../tb/env/agent/driver
+incdir+../tb/env/agent/monitor
+incdir+../tb/env/agent/sequencer
+incdir+../tb/env/scoreboard
+incdir+../tb/env/coverage

+incdir+../tb/interface
+incdir+../tb/sequences
+incdir+../tb/tests

+incdir+../dut_rm
+incdir+../rtl


../rtl/rtl_pdef.sv
../rtl/rtl_def.sv
../rtl/rtl_defines.sv
../rtl/rtl_lib.sv
../rtl/Bit_Manipulation_Unit.sv


# Interface must be visible before classes that use virtual bmu_if
../tb/interface/bmu_if.sv


# UVM package
../tb/packages/bmu_pkg.sv


# Testbench top comes last
../tb/bmu_tb_top.sv