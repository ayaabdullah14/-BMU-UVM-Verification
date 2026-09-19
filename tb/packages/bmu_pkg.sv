`timescale 1ns/1ps

package bmu_pkg;

  import uvm_pkg::*;
  import rtl_pkg::*;

  `include "uvm_macros.svh"


  `include "env/agent/sequencer/bmu_seq_item.sv"


  // Reference Model

  `include "bmu_reference_model.sv"


  // Agent
  `include "env/agent/sequencer/bmu_sequencer.sv"
  `include "env/agent/driver/bmu_driver.sv"
  `include "env/agent/monitor/bmu_monitor.sv"
  `include "env/agent/bmu_agent.sv"


  // Environment

  `include "env/scoreboard/bmu_scoreboard.sv"
  `include "env/coverage/bmu_subscriber.sv"
  `include "env/bmu_env.sv"


  // ------------------------------Sequences------------------------

  `include "sequences/bmu_base_sequence.sv"
  `include "sequences/bmu_smoke_sequence.sv"

  `include "sequences/bmu_or_sequence.sv"
  `include "sequences/bmu_orn_sequence.sv"
  `include "sequences/bmu_xor_sequence.sv"
  `include "sequences/bmu_xnor_sequence.sv"

  `include "sequences/bmu_srl_sequence.sv"
  `include "sequences/bmu_sra_sequence.sv"
  `include "sequences/bmu_ror_sequence.sv"
  `include "sequences/bmu_binv_sequence.sv"

  `include "sequences/bmu_sh2add_sequence.sv"
  `include "sequences/bmu_sub_sequence.sv"

  `include "sequences/bmu_sltu_sequence.sv"
  `include "sequences/bmu_slt_sequence.sv"

  `include "sequences/bmu_ctz_sequence.sv"
  `include "sequences/bmu_ctz_debug_sequence.sv"

  `include "sequences/bmu_cpop_sequence.sv"
  `include "sequences/bmu_sext_b_sequence.sv"

  `include "sequences/bmu_max_sequence.sv"
  `include "sequences/bmu_pack_sequence.sv"
  `include "sequences/bmu_grev_sequence.sv"

  `include "sequences/bmu_csr_read_sequence.sv"
  `include "sequences/bmu_csr_write_sequence.sv"

  `include "sequences/bmu_error_sequence.sv"
  `include "sequences/bmu_reset_sequence.sv"
  `include "sequences/bmu_valid_in_sequence.sv"
  `include "sequences/bmu_mixed_sequence.sv"


  //----------------------------------------- Tests---------------------------------------------------------------

  // Base test must come before all derived tests
  `include "tests/bmu_base_test.sv"

  `include "tests/bmu_smoke_test.sv"

  // Reference-model unit test
  `include "tests/bmu_reference_model_unit_test.sv"

  `include "tests/bmu_or_test.sv"
  `include "tests/bmu_orn_test.sv"
  `include "tests/bmu_xor_test.sv"
  `include "tests/bmu_xnor_test.sv"

  `include "tests/bmu_srl_test.sv"
  `include "tests/bmu_sra_test.sv"
  `include "tests/bmu_ror_test.sv"
  `include "tests/bmu_binv_test.sv"

  `include "tests/bmu_sh2add_test.sv"
  `include "tests/bmu_sub_test.sv"

  `include "tests/bmu_sltu_test.sv"
  `include "tests/bmu_slt_test.sv"

  `include "tests/bmu_ctz_test.sv"
  `include "tests/bmu_ctz_debug_test.sv"

  `include "tests/bmu_cpop_test.sv"
  `include "tests/bmu_sext_b_test.sv"

  `include "tests/bmu_max_test.sv"
  `include "tests/bmu_pack_test.sv"
  `include "tests/bmu_grev_test.sv"

  `include "tests/bmu_csr_read_test.sv"
  `include "tests/bmu_csr_write_test.sv"

  `include "tests/bmu_error_test.sv"
  `include "tests/bmu_reset_test.sv"
  `include "tests/bmu_valid_in_test.sv"
  `include "tests/bmu_mixed_test.sv"

  // Full regression test comes last
  `include "tests/bmu_regression_test.sv"


endpackage : bmu_pkg