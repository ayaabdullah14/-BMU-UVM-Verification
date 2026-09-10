`timescale 1ns/1ps

package bmu_pkg;

  import uvm_pkg::*;
  import rtl_pkg::*;

  `include "uvm_macros.svh"

  // Must be first because all following classes use bmu_seq_item
  `include "env/bmu_seq_item.sv"

  // Uses bmu_seq_item
  `include "reference_model/bmu_reference_model.sv"

  // Agent
  `include "env/bmu_sequencer.sv"
  `include "env/bmu_driver.sv"
  `include "env/bmu_monitor.sv"
  `include "env/bmu_agent.sv"

  // Environment
  `include "env/bmu_scoreboard.sv"
  `include "env/bmu_coverage.sv"
  `include "env/bmu_env.sv"

 // Base sequence before derived sequence
  `include "sequences/bmu_base_sequence.sv"
  `include "sequences/bmu_smoke_sequence.sv"

  // Base test must be before smoke test
  `include "tests/bmu_base_test.sv"
  `include "tests/bmu_smoke_test.sv"

  // Golden-vector test
  `include "tests/bmu_reference_model_unit_test.sv"

endpackage