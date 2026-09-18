class bmu_regression_test extends bmu_base_test;

  `uvm_component_utils(bmu_regression_test)


  // ==========================================================================
  // Constructor
  // ==========================================================================

  function new(
    string name = "bmu_regression_test",
    uvm_component parent = null
  );

    super.new(name, parent);

  endfunction


  // ==========================================================================
  // Run Phase
  // ==========================================================================

  task run_phase(uvm_phase phase);


    // ------------------------------------------------------------------------
    // Sequence handles
    // ------------------------------------------------------------------------

    bmu_reset_sequence       reset_seq;

    bmu_or_sequence          or_seq;
    bmu_orn_sequence         orn_seq;
    bmu_xor_sequence         xor_seq;
    bmu_xnor_sequence        xnor_seq;

    bmu_srl_sequence         srl_seq;
    bmu_sra_sequence         sra_seq;
    bmu_ror_sequence         ror_seq;
    bmu_binv_sequence        binv_seq;

    bmu_sh2add_sequence      sh2add_seq;
    bmu_sub_sequence         sub_seq;

    bmu_slt_sequence         slt_seq;
    bmu_sltu_sequence        sltu_seq;

    bmu_ctz_sequence         ctz_seq;
    bmu_cpop_sequence        cpop_seq;
    bmu_sext_b_sequence      sext_b_seq;

    bmu_max_sequence         max_seq;
    bmu_pack_sequence        pack_seq;
    bmu_grev_sequence        grev_seq;

    bmu_csr_read_sequence    csr_read_seq;
    bmu_csr_write_sequence   csr_write_seq;

    bmu_valid_in_sequence    valid_seq;

    // IMPORTANT:
    // Actual class name in the project is bmu_error_sequence
    // not bmu_errors_sequence.
    bmu_error_sequence       error_seq;


    // ------------------------------------------------------------------------
    // Keep simulation alive
    // ------------------------------------------------------------------------

    phase.raise_objection(this);


    `uvm_info(
      get_type_name(),
      "============================================================",
      UVM_LOW
    )

    `uvm_info(
      get_type_name(),
      "              START BMU FULL REGRESSION",
      UVM_LOW
    )

    `uvm_info(
      get_type_name(),
      "============================================================",
      UVM_LOW
    )


    // ==========================================================================
    // Create sequences
    // ==========================================================================


    // ------------------------------------------------------------------------
    // Reset
    // ------------------------------------------------------------------------

    reset_seq =
      bmu_reset_sequence::type_id::create(
        "reset_seq"
      );


    // ------------------------------------------------------------------------
    // Logic
    // ------------------------------------------------------------------------

    or_seq =
      bmu_or_sequence::type_id::create(
        "or_seq"
      );

    orn_seq =
      bmu_orn_sequence::type_id::create(
        "orn_seq"
      );

    xor_seq =
      bmu_xor_sequence::type_id::create(
        "xor_seq"
      );

    xnor_seq =
      bmu_xnor_sequence::type_id::create(
        "xnor_seq"
      );


    // ------------------------------------------------------------------------
    // Shift / Rotate / Bit manipulation
    // ------------------------------------------------------------------------

    srl_seq =
      bmu_srl_sequence::type_id::create(
        "srl_seq"
      );

    sra_seq =
      bmu_sra_sequence::type_id::create(
        "sra_seq"
      );

    ror_seq =
      bmu_ror_sequence::type_id::create(
        "ror_seq"
      );

    binv_seq =
      bmu_binv_sequence::type_id::create(
        "binv_seq"
      );


    // ------------------------------------------------------------------------
    // Arithmetic
    // ------------------------------------------------------------------------

    sh2add_seq =
      bmu_sh2add_sequence::type_id::create(
        "sh2add_seq"
      );

    sub_seq =
      bmu_sub_sequence::type_id::create(
        "sub_seq"
      );


    // ------------------------------------------------------------------------
    // Compare
    // ------------------------------------------------------------------------

    slt_seq =
      bmu_slt_sequence::type_id::create(
        "slt_seq"
      );

    sltu_seq =
      bmu_sltu_sequence::type_id::create(
        "sltu_seq"
      );


    // ------------------------------------------------------------------------
    // Count / Extension
    // ------------------------------------------------------------------------

    ctz_seq =
      bmu_ctz_sequence::type_id::create(
        "ctz_seq"
      );

    cpop_seq =
      bmu_cpop_sequence::type_id::create(
        "cpop_seq"
      );

    sext_b_seq =
      bmu_sext_b_sequence::type_id::create(
        "sext_b_seq"
      );


    // ------------------------------------------------------------------------
    // MAX / PACK / GREV
    // ------------------------------------------------------------------------

    max_seq =
      bmu_max_sequence::type_id::create(
        "max_seq"
      );

    pack_seq =
      bmu_pack_sequence::type_id::create(
        "pack_seq"
      );

    grev_seq =
      bmu_grev_sequence::type_id::create(
        "grev_seq"
      );


    // ------------------------------------------------------------------------
    // CSR
    // ------------------------------------------------------------------------

    csr_read_seq =
      bmu_csr_read_sequence::type_id::create(
        "csr_read_seq"
      );

    csr_write_seq =
      bmu_csr_write_sequence::type_id::create(
        "csr_write_seq"
      );


    // ------------------------------------------------------------------------
    // valid_in
    // ------------------------------------------------------------------------

    valid_seq =
      bmu_valid_in_sequence::type_id::create(
        "valid_seq"
      );


    // ------------------------------------------------------------------------
    // Error / Negative tests
    // ------------------------------------------------------------------------

    error_seq =
      bmu_error_sequence::type_id::create(
        "error_seq"
      );


    // ==========================================================================
    // START REGRESSION
    // ==========================================================================


    // ------------------------------------------------------------------------
    // 1. Initial Reset
    // ------------------------------------------------------------------------

    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting RESET sequence",
      UVM_LOW
    )

    reset_seq.start(
      env.agent.sequencer
    );


    // ------------------------------------------------------------------------
    // 2. Logic Operations
    // ------------------------------------------------------------------------

    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting OR sequence",
      UVM_LOW
    )

    or_seq.start(
      env.agent.sequencer
    );


    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting ORN sequence",
      UVM_LOW
    )

    orn_seq.start(
      env.agent.sequencer
    );


    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting XOR sequence",
      UVM_LOW
    )

    xor_seq.start(
      env.agent.sequencer
    );


    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting XNOR sequence",
      UVM_LOW
    )

    xnor_seq.start(
      env.agent.sequencer
    );


    // ------------------------------------------------------------------------
    // 3. Shift / Rotate / Bit Operations
    // ------------------------------------------------------------------------

    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting SRL sequence",
      UVM_LOW
    )

    srl_seq.start(
      env.agent.sequencer
    );


    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting SRA sequence",
      UVM_LOW
    )

    sra_seq.start(
      env.agent.sequencer
    );


    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting ROR sequence",
      UVM_LOW
    )

    ror_seq.start(
      env.agent.sequencer
    );


    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting BINV sequence",
      UVM_LOW
    )

    binv_seq.start(
      env.agent.sequencer
    );


    // ------------------------------------------------------------------------
    // 4. Arithmetic
    // ------------------------------------------------------------------------

    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting SH2ADD sequence",
      UVM_LOW
    )

    sh2add_seq.start(
      env.agent.sequencer
    );


    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting SUB sequence",
      UVM_LOW
    )

    sub_seq.start(
      env.agent.sequencer
    );


    // ------------------------------------------------------------------------
    // 5. Compare
    // ------------------------------------------------------------------------

    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting SLT sequence",
      UVM_LOW
    )

    slt_seq.start(
      env.agent.sequencer
    );


    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting SLTU sequence",
      UVM_LOW
    )

    sltu_seq.start(
      env.agent.sequencer
    );


    // ------------------------------------------------------------------------
    // 6. Count / Extension
    // ------------------------------------------------------------------------

    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting CTZ sequence",
      UVM_LOW
    )

    ctz_seq.start(
      env.agent.sequencer
    );


    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting CPOP sequence",
      UVM_LOW
    )

    cpop_seq.start(
      env.agent.sequencer
    );


    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting SEXT.B sequence",
      UVM_LOW
    )

    sext_b_seq.start(
      env.agent.sequencer
    );


    // ------------------------------------------------------------------------
    // 7. MAX / PACK / GREV
    // ------------------------------------------------------------------------

    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting MAX sequence",
      UVM_LOW
    )

    max_seq.start(
      env.agent.sequencer
    );


    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting PACK sequence",
      UVM_LOW
    )

    pack_seq.start(
      env.agent.sequencer
    );


    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting GREV sequence",
      UVM_LOW
    )

    grev_seq.start(
      env.agent.sequencer
    );


    // ------------------------------------------------------------------------
    // 8. CSR
    // ------------------------------------------------------------------------

    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting CSR READ sequence",
      UVM_LOW
    )

    csr_read_seq.start(
      env.agent.sequencer
    );


    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting CSR WRITE sequence",
      UVM_LOW
    )

    csr_write_seq.start(
      env.agent.sequencer
    );


    // ------------------------------------------------------------------------
    // 9. valid_in behavior
    // ------------------------------------------------------------------------

    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting VALID_IN sequence",
      UVM_LOW
    )

    valid_seq.start(
      env.agent.sequencer
    );


    // ------------------------------------------------------------------------
    // 10. Negative / Error scenarios
    // ------------------------------------------------------------------------

    `uvm_info(
      get_type_name(),
      "[REGRESSION] Starting ERROR sequence",
      UVM_LOW
    )

    error_seq.start(
      env.agent.sequencer
    );


    // ==========================================================================
    // Regression Complete
    // ==========================================================================

    `uvm_info(
      get_type_name(),
      "============================================================",
      UVM_LOW
    )

    `uvm_info(
      get_type_name(),
      "               END BMU FULL REGRESSION",
      UVM_LOW
    )

    `uvm_info(
      get_type_name(),
      "============================================================",
      UVM_LOW
    )


    phase.drop_objection(this);

  endtask


endclass