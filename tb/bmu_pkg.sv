`timescale 1ns/1ps

package bmu_pkg;

  import uvm_pkg::*;
  import rtl_pkg::*;

  `include "uvm_macros.svh"

  // Sequence item must be first
  `include "env/bmu_seq_item.sv"

  // Reference model
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

  // Sequences
  `include "sequences/bmu_base_sequence.sv"
  `include "sequences/bmu_smoke_sequence.sv"
  `include "sequences/bmu_or_sequence.sv"
  `include "sequences/bmu_orn_sequence.sv"
  `include "sequences/bmu_xor_sequence.sv"
  `include "sequences/bmu_xnor_sequence.sv"
  // Tests
  `include "tests/bmu_base_test.sv"
  `include "tests/bmu_smoke_test.sv"

  // Golden-vector test
  `include "tests/bmu_reference_model_unit_test.sv"

  // OR test
  `include "tests/bmu_or_test.sv"
  `include "tests/bmu_orn_test.sv"
  `include "tests/bmu_xor_test.sv"
  `include "tests/bmu_xnor_test.sv"

endpackage