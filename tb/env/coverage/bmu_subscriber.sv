typedef enum int unsigned {
  COV_OP_NONE = 0,

  COV_OP_OR,
  COV_OP_ORN,
  COV_OP_XOR,
  COV_OP_XNOR,

  COV_OP_SRL,
  COV_OP_SRA,
  COV_OP_ROR,
  COV_OP_BINV,

  COV_OP_SH2ADD,
  COV_OP_SUB,
  COV_OP_SLT,
  COV_OP_SLTU,

  COV_OP_CTZ,
  COV_OP_CPOP,
  COV_OP_SEXT_B,
  COV_OP_MAX,

  COV_OP_PACK,
  COV_OP_GREV,

  COV_OP_CSR_READ,
  COV_OP_CSR_WRITE_A,
  COV_OP_CSR_WRITE_B
} bmu_cov_op_e;


typedef enum int unsigned {
  COV_REL_LT = 0,
  COV_REL_EQ,
  COV_REL_GT
} bmu_cov_relation_e;


typedef enum int unsigned {
  COV_ERR_CSR_CONFLICT = 0,
  COV_ERR_SH2ADD_NO_ZBA,
  COV_ERR_SUB_WITH_ZBA,

  COV_ERR_OR_EXTRA,
  COV_ERR_XOR_EXTRA,
  COV_ERR_SRL_EXTRA,
  COV_ERR_SRA_EXTRA,
  COV_ERR_ROR_EXTRA,
  COV_ERR_BINV_EXTRA,
  COV_ERR_GREV_EXTRA
} bmu_cov_error_e;


// ============================================================================
// SUBSCRIBER
// ============================================================================

class bmu_subscriber extends uvm_subscriber #(bmu_seq_item);

  `uvm_component_utils(bmu_subscriber)

  // Only temporal state that is actually required by coverage.
  bit          have_prev_valid;
  bit          prev_valid_in;
  bit          activity_seen;

  bit          hold_active;
  int unsigned hold_length;


  // ==========================================================================
  // 1. OPERATION COVERAGE
  // 18 documented BMU modes + 3 CSR source-selection modes = 21.
  // ==========================================================================

  covergroup cg_operation with function sample(bmu_cov_op_e op);
    option.per_instance = 1;

    cp_op: coverpoint op {
      bins legal_modes[] = {
        COV_OP_OR,
        COV_OP_ORN,
        COV_OP_XOR,
        COV_OP_XNOR,

        COV_OP_SRL,
        COV_OP_SRA,
        COV_OP_ROR,
        COV_OP_BINV,

        COV_OP_SH2ADD,
        COV_OP_SUB,
        COV_OP_SLT,
        COV_OP_SLTU,

        COV_OP_CTZ,
        COV_OP_CPOP,
        COV_OP_SEXT_B,
        COV_OP_MAX,

        COV_OP_PACK,
        COV_OP_GREV,

        COV_OP_CSR_READ,
        COV_OP_CSR_WRITE_A,
        COV_OP_CSR_WRITE_B
      };
    }
  endgroup


  // ==========================================================================
  // 2. LOGIC TRUTH TABLE
  // OR / ORN / XOR / XNOR x {00,01,10,11} = 16 meaningful combinations.
  // No bit-position cross: full 32-bit correctness belongs to the scoreboard.
  // ==========================================================================

  covergroup cg_logic with function sample(
    bmu_cov_op_e op,
    logic [1:0] pair
  );
    option.per_instance = 1;

    cp_op: coverpoint op {
      option.weight = 0;
      bins ops[] = {
        COV_OP_OR,
        COV_OP_ORN,
        COV_OP_XOR,
        COV_OP_XNOR
      };
    }

    cp_pair: coverpoint pair {
      option.weight = 0;
      bins b00 = {2'b00};
      bins b01 = {2'b01};
      bins b10 = {2'b10};
      bins b11 = {2'b11};
    }

    op_x_pair: cross cp_op, cp_pair;
  endgroup


  // ==========================================================================
  // 3. SHIFT / ROTATE AMOUNT CLASSES
  //
  // Spec-visible behavior only: shift amount is b_in[4:0].
  // We group values into useful boundaries/ranges rather than model internal
  // barrel-shifter implementation stages.
  //
  // 3 operations x 7 classes = 21 cross bins.
  // ==========================================================================

  covergroup cg_shift with function sample(
    bmu_cov_op_e op,
    logic [4:0] amount
  );
    option.per_instance = 1;

    cp_op: coverpoint op {
      option.weight = 0;
      bins ops[] = {
        COV_OP_SRL,
        COV_OP_SRA,
        COV_OP_ROR
      };
    }

    cp_amount: coverpoint amount {
      option.weight = 0;

      bins zero       = {5'd0};
      bins one        = {5'd1};
      bins low        = {[5'd2:5'd7]};
      bins byte_mid   = {[5'd8:5'd15]};
      bins half       = {5'd16};
      bins high       = {[5'd17:5'd30]};
      bins max        = {5'd31};
    }

    op_x_amount: cross cp_op, cp_amount;
  endgroup


  // ==========================================================================
  // 4. SRA SIGN BEHAVIOR
  // Amount behavior is already covered by cg_shift.
  // ==========================================================================

  covergroup cg_sra_sign with function sample(bit sign_bit);
    option.per_instance = 1;

    cp_sign: coverpoint sign_bit {
      bins positive = {0};
      bins negative = {1};
    }
  endgroup


  // ==========================================================================
  // 5. BINV
  // Selected index classes + original target-bit value.
  // No index x value Cartesian cross.
  // ==========================================================================

  covergroup cg_binv with function sample(
    logic [4:0] index,
    bit original_bit
  );
    option.per_instance = 1;

    cp_index: coverpoint index {
      bins lsb            = {5'd0};
      bins lower_half     = {[5'd1:5'd15]};
      bins upper_half     = {[5'd16:5'd30]};
      bins msb            = {5'd31};
    }

    cp_original: coverpoint original_bit {
      bins zero = {0};
      bins one  = {1};
    }
  endgroup


  // ==========================================================================
  // 6. COMPARISON COVERAGE
  //
  // 3 operations x relation {LT,EQ,GT} = 9 bins
  // + focused mixed-sign observations = 3 bins.
  // ==========================================================================

  covergroup cg_compare with function sample(int unsigned code);
    option.per_instance = 1;

    cp_case: coverpoint code {
      bins slt_lt   = {0};
      bins slt_eq   = {1};
      bins slt_gt   = {2};

      bins sltu_lt  = {3};
      bins sltu_eq  = {4};
      bins sltu_gt  = {5};

      bins max_lt   = {6};
      bins max_eq   = {7};
      bins max_gt   = {8};

      bins signed_a_neg_b_pos = {9};
      bins signed_a_pos_b_neg = {10};
      bins unsigned_mixed_sign = {11};
    }
  endgroup


  // ==========================================================================
  // 7. CTZ
  //
  // Exact 0..32 is justified:
  //   0..31 = first-set-bit position
  //   32    = all-zero input (trainer correction)
  // ==========================================================================

  covergroup cg_ctz with function sample(int unsigned count);
    option.per_instance = 1;

    cp_count: coverpoint count {
      bins values[] = {[0:32]};
    }
  endgroup


  // ==========================================================================
  // 8. CPOP COUNT
  // Semantic count ranges, not all values as separate closure targets.
  // ==========================================================================

  covergroup cg_cpop_count with function sample(int unsigned count);
    option.per_instance = 1;

    cp_count: coverpoint count {
      bins zero       = {0};
      bins one        = {1};
      bins low        = {[2:7]};
      bins mid_low    = {[8:15]};
      bins half       = {16};
      bins high       = {[17:31]};
      bins full       = {32};
    }
  endgroup


  // ==========================================================================
  // 9. CPOP SOURCE REGION
  //
  // For one-hot inputs, prove that all four byte regions participate in the
  // 32-bit population count. This is enough to catch partial-width counting
  // risks without 32 independent position bins.
  // ==========================================================================

  covergroup cg_cpop_region with function sample(int unsigned bit_index);
    option.per_instance = 1;

    cp_region: coverpoint bit_index {
      bins byte0 = {[0:7]};
      bins byte1 = {[8:15]};
      bins byte2 = {[16:23]};
      bins byte3 = {[24:31]};
    }
  endgroup


  // ==========================================================================
  // 10. SEXT.B
  // ==========================================================================

  covergroup cg_sext_b with function sample(logic [7:0] byte_value);
    option.per_instance = 1;

    cp_byte: coverpoint byte_value {
      bins zero           = {8'h00};
      bins max_positive   = {8'h7f};
      bins min_negative   = {8'h80};
      bins minus_one      = {8'hff};
      bins other_positive = {[8'h01:8'h7e]};
      bins other_negative = {[8'h81:8'hfe]};
    }
  endgroup


  // ==========================================================================
  // 11. PACK
  //
  // Operation coverage already proves PACK was selected.
  // This single bin only proves the test used distinguishable low halfwords,
  // so an A/B lane swap would be observable by the scoreboard.
  // ==========================================================================

  covergroup cg_pack with function sample(bit asymmetric_low_halves);
    option.per_instance = 1;

    cp_case: coverpoint asymmetric_low_halves {
      bins distinguishable_sources = {1};
    }
  endgroup


  // ==========================================================================
  // 12. GREV / REV8
  //
  // Supported mode: 24.
  // All other low-5-bit values are the same unsupported class.
  // ==========================================================================

  covergroup cg_grev with function sample(bit supported);
    option.per_instance = 1;

    cp_mode: coverpoint supported {
      bins unsupported = {0};
      bins rev8        = {1};
    }
  endgroup


  // ==========================================================================
  // 13. CSR SOURCE DISCRIMINATION
  //
  // Operation coverage proves READ / WRITE-A / WRITE-B were selected.
  // These bins prove the selected source was distinguishable from alternatives,
  // so a wrong mux selection can be caught by the scoreboard.
  // ==========================================================================

  covergroup cg_csr_source with function sample(int unsigned code);
    option.per_instance = 1;

    cp_source: coverpoint code {
      bins read_distinct    = {0};
      bins write_a_distinct = {1};
      bins write_b_distinct = {2};
    }
  endgroup


  // ==========================================================================
  // 14. ERROR REASONS
  //
  // These are stimulus-intent bins only.
  // The scoreboard checks the actual DUT error/result behavior.
  // ==========================================================================

  covergroup cg_error_reason with function sample(bmu_cov_error_e reason);
    option.per_instance = 1;

    cp_reason: coverpoint reason {
      bins reasons[] = {
        COV_ERR_CSR_CONFLICT,
        COV_ERR_SH2ADD_NO_ZBA,
        COV_ERR_SUB_WITH_ZBA,

        COV_ERR_OR_EXTRA,
        COV_ERR_XOR_EXTRA,
        COV_ERR_SRL_EXTRA,
        COV_ERR_SRA_EXTRA,
        COV_ERR_ROR_EXTRA,
        COV_ERR_BINV_EXTRA,
        COV_ERR_GREV_EXTRA
      };
    }
  endgroup


  // ==========================================================================
  // 15. ERROR vs valid_in
  //
  // Trainer clarification: error detection is independent of valid_in.
  // We only need to prove error stimulus was exercised with valid low and high;
  // no full error-reason x valid Cartesian cross.
  // ==========================================================================

  covergroup cg_error_valid with function sample(bit valid_value);
    option.per_instance = 1;

    cp_valid: coverpoint valid_value {
      bins low  = {0};
      bins high = {1};
    }
  endgroup


  // ==========================================================================
  // 16. valid_in TRANSITIONS
  // ==========================================================================

  covergroup cg_valid_transition with function sample(logic [1:0] transition);
    option.per_instance = 1;

    cp_transition: coverpoint transition {
      bins t00 = {2'b00};
      bins t01 = {2'b01};
      bins t10 = {2'b10};
      bins t11 = {2'b11};
    }
  endgroup


  // ==========================================================================
  // 17. RESULT-HOLD LENGTH CLASS
  //
  // valid_in=0 must hold result_ff.
  // One-cycle and multi-cycle hold are the only distinct temporal classes
  // needed for functional coverage.
  // ==========================================================================

  covergroup cg_hold with function sample(int unsigned length);
    option.per_instance = 1;

    cp_length: coverpoint length {
      bins single_cycle = {1};
      bins multi_cycle  = {[2:$]};
    }
  endgroup


  // ==========================================================================
  // 18. RESET CONTEXT
  //
  // Reset correctness itself is checked by scoreboard/assertions.
  // Coverage only proves reset was exercised at startup and after activity.
  // ==========================================================================

  covergroup cg_reset with function sample(bit after_activity);
    option.per_instance = 1;

    cp_context: coverpoint after_activity {
      bins startup   = {0};
      bins midstream = {1};
    }
  endgroup


  // ==========================================================================
  // CONSTRUCTOR
  // ==========================================================================

  function new(
    string name = "bmu_subscriber",
    uvm_component parent = null
  );
    super.new(name, parent);

    cg_operation        = new();
    cg_logic            = new();
    cg_shift            = new();
    cg_sra_sign         = new();
    cg_binv             = new();
    cg_compare          = new();
    cg_ctz              = new();
    cg_cpop_count       = new();
    cg_cpop_region      = new();
    cg_sext_b           = new();
    cg_pack             = new();
    cg_grev             = new();
    cg_csr_source       = new();
    cg_error_reason     = new();
    cg_error_valid      = new();
    cg_valid_transition = new();
    cg_hold             = new();
    cg_reset            = new();

    have_prev_valid = 0;
    prev_valid_in   = 0;
    activity_seen   = 0;

    hold_active = 0;
    hold_length = 0;
  endfunction


  // ==========================================================================
  // HELPERS
  // ==========================================================================

  function automatic int unsigned active_bits(bmu_seq_item tr);
    return $countones(tr.ap);
  endfunction


  // Primary BMU controls only.
  // Mode/companion bits (zbb/zba/unsign) are intentionally not enough by
  // themselves to constitute a BMU instruction.
  function automatic bit has_bmu_primary(bmu_seq_item tr);
    return (
      tr.ap.lor     ||
      tr.ap.lxor    ||
      tr.ap.srl     ||
      tr.ap.sra     ||
      tr.ap.ror     ||
      tr.ap.binv    ||
      tr.ap.sh2add  ||
      tr.ap.sub     ||
      tr.ap.slt     ||
      tr.ap.ctz     ||
      tr.ap.cpop    ||
      tr.ap.siext_b ||
      tr.ap.max     ||
      tr.ap.pack    ||
      tr.ap.grev
    );
  endfunction


  // Decode only clean, documented functional requests.
  //
  // IMPORTANT:
  // For CSR WRITE, the exact ap-bit-count checks are used only to identify the
  // clean functional request for coverage. They do NOT define the error policy
  // for undocumented CSR-write collisions.
  function automatic bmu_cov_op_e decode_legal_op(bmu_seq_item tr);
    int unsigned n;

    n = active_bits(tr);

    // CSR read bypass: documented example uses csr_ren_in=1 with ap cleared.
    if (tr.csr_ren_in && (tr.ap == '0))
      return COV_OP_CSR_READ;

    if (tr.csr_ren_in)
      return COV_OP_NONE;

    // SLT / SLTU
    if (tr.ap.slt && tr.ap.sub && !tr.ap.unsign && (n == 2))
      return COV_OP_SLT;

    if (tr.ap.slt && tr.ap.sub && tr.ap.unsign && (n == 3))
      return COV_OP_SLTU;

    // Signed MAX
    if (tr.ap.max && tr.ap.sub && !tr.ap.unsign && (n == 2))
      return COV_OP_MAX;

    // SH2ADD
    if (tr.ap.sh2add && tr.ap.zba && (n == 2))
      return COV_OP_SH2ADD;

    // Logic
    if (tr.ap.lor && !tr.ap.zbb && (n == 1))
      return COV_OP_OR;

    if (tr.ap.lor && tr.ap.zbb && (n == 2))
      return COV_OP_ORN;

    if (tr.ap.lxor && !tr.ap.zbb && (n == 1))
      return COV_OP_XOR;

    if (tr.ap.lxor && tr.ap.zbb && (n == 2))
      return COV_OP_XNOR;

    // Shift / rotate / bit index
    if (tr.ap.srl && (n == 1))
      return COV_OP_SRL;

    if (tr.ap.sra && (n == 1))
      return COV_OP_SRA;

    if (tr.ap.ror && (n == 1))
      return COV_OP_ROR;

    if (tr.ap.binv && (n == 1))
      return COV_OP_BINV;

    // Arithmetic
    if (tr.ap.sub && !tr.ap.zba && (n == 1))
      return COV_OP_SUB;

    // Count / extend
    if (tr.ap.ctz && (n == 1))
      return COV_OP_CTZ;

    if (tr.ap.cpop && (n == 1))
      return COV_OP_CPOP;

    if (tr.ap.siext_b && (n == 1))
      return COV_OP_SEXT_B;

    // PACK
    if (tr.ap.pack && (n == 1))
      return COV_OP_PACK;

    // GREV supported REV8 mode
    if (tr.ap.grev &&
        (n == 1) &&
        (tr.b_in[4:0] == 5'd24))
      return COV_OP_GREV;

    // CSR write source selection.
    if (tr.ap.csr_write &&
        !tr.ap.csr_imm &&
        (n == 1))
      return COV_OP_CSR_WRITE_A;

    if (tr.ap.csr_write &&
        tr.ap.csr_imm &&
        (n == 2))
      return COV_OP_CSR_WRITE_B;

    return COV_OP_NONE;
  endfunction


  function automatic bit is_unsupported_grev(bmu_seq_item tr);
    return (
      !tr.csr_ren_in &&
      tr.ap.grev &&
      (active_bits(tr) == 1) &&
      (tr.b_in[4:0] != 5'd24)
    );
  endfunction


  // Error classification is based on the request stimulus, never on DUT error.
  //
  // CSR conflict is restricted to CSR read + BMU primary control, matching
  // the spec statement. csr_ren_in + csr_write is NOT guessed here.
  function automatic bit classify_error(
    bmu_seq_item tr,
    output bmu_cov_error_e reason
  );
    bmu_cov_op_e op;

    // CSR read OR bit-manipulation request conflict.
    if (tr.csr_ren_in && has_bmu_primary(tr)) begin
      reason = COV_ERR_CSR_CONFLICT;
      return 1;
    end

    // SH2ADD requires zba.
    if (tr.ap.sh2add && !tr.ap.zba) begin
      reason = COV_ERR_SH2ADD_NO_ZBA;
      return 1;
    end

    // Standalone SUB forbids zba.
    if (tr.ap.sub &&
        tr.ap.zba &&
        !tr.ap.sh2add &&
        !tr.ap.slt &&
        !tr.ap.max) begin
      reason = COV_ERR_SUB_WITH_ZBA;
      return 1;
    end

    // GREV with a clean control vector but mode != 24 is unsupported,
    // not an error according to the approved interpretation.
    if (is_unsupported_grev(tr))
      return 0;

    op = decode_legal_op(tr);

    // Trainer-corrected extra-field conflicts.
    // These are sampled only when the request is not a clean legal recipe.
    if (!tr.csr_ren_in && (op == COV_OP_NONE)) begin

      if (tr.ap.lor) begin
        reason = COV_ERR_OR_EXTRA;
        return 1;
      end

      if (tr.ap.lxor) begin
        reason = COV_ERR_XOR_EXTRA;
        return 1;
      end

      if (tr.ap.srl) begin
        reason = COV_ERR_SRL_EXTRA;
        return 1;
      end

      if (tr.ap.sra) begin
        reason = COV_ERR_SRA_EXTRA;
        return 1;
      end

      if (tr.ap.ror) begin
        reason = COV_ERR_ROR_EXTRA;
        return 1;
      end

      if (tr.ap.binv) begin
        reason = COV_ERR_BINV_EXTRA;
        return 1;
      end

      if (tr.ap.grev) begin
        reason = COV_ERR_GREV_EXTRA;
        return 1;
      end

    end

    return 0;
  endfunction


  function automatic bmu_cov_relation_e unsigned_relation(
    logic [31:0] a,
    logic [31:0] b
  );
    if (a < b)
      return COV_REL_LT;

    if (a > b)
      return COV_REL_GT;

    return COV_REL_EQ;
  endfunction


  function automatic bmu_cov_relation_e signed_relation(
    logic [31:0] a,
    logic [31:0] b
  );
    if ($signed(a) < $signed(b))
      return COV_REL_LT;

    if ($signed(a) > $signed(b))
      return COV_REL_GT;

    return COV_REL_EQ;
  endfunction


  function automatic int unsigned ctz32(logic [31:0] value);
    if (value == 32'h0)
      return 32;

    for (int unsigned i = 0; i < 32; i++) begin
      if (value[i])
        return i;
    end

    return 32;
  endfunction


  function automatic int onehot_index32(logic [31:0] value);
    for (int unsigned i = 0; i < 32; i++) begin
      if (value[i])
        return i;
    end

    return -1;
  endfunction


  function automatic bit required_data_known(
    bmu_seq_item tr,
    bmu_cov_op_e op
  );
    case (op)

      COV_OP_CSR_READ:
        return !$isunknown(tr.csr_rddata_in);

      COV_OP_CSR_WRITE_A:
        return !$isunknown(tr.a_in);

      COV_OP_CSR_WRITE_B:
        return !$isunknown(tr.b_in);

      default:
        return !$isunknown({tr.a_in, tr.b_in});

    endcase
  endfunction


  function void close_hold_run();
    if (hold_active && (hold_length > 0))
      cg_hold.sample(hold_length);

    hold_active = 0;
    hold_length = 0;
  endfunction


  // ==========================================================================
  // OPERATION-SPECIFIC SAMPLING
  // ==========================================================================

  function void sample_legal_data(
    bmu_seq_item tr,
    bmu_cov_op_e op
  );
    bmu_cov_relation_e relation;
    int unsigned code;
    int unsigned count_value;
    int bit_index;


    // ------------------------------------------------------------------------
    // Logic truth tables
    // ------------------------------------------------------------------------
    if (op inside {
          COV_OP_OR,
          COV_OP_ORN,
          COV_OP_XOR,
          COV_OP_XNOR
        }) begin

      for (int unsigned i = 0; i < 32; i++)
        cg_logic.sample(op, {tr.a_in[i], tr.b_in[i]});

    end


    // ------------------------------------------------------------------------
    // Shift / rotate
    // ------------------------------------------------------------------------
    if (op inside {
          COV_OP_SRL,
          COV_OP_SRA,
          COV_OP_ROR
        }) begin

      cg_shift.sample(op, tr.b_in[4:0]);

      // Amount 0 does not exercise arithmetic sign extension.
      if ((op == COV_OP_SRA) &&
          (tr.b_in[4:0] != 5'd0))
        cg_sra_sign.sample(tr.a_in[31]);

    end


    // ------------------------------------------------------------------------
    // BINV
    // ------------------------------------------------------------------------
    if (op == COV_OP_BINV) begin
      cg_binv.sample(
        tr.b_in[4:0],
        tr.a_in[tr.b_in[4:0]]
      );
    end


    // ------------------------------------------------------------------------
    // SLT / SLTU / MAX
    // ------------------------------------------------------------------------
    if (op == COV_OP_SLT) begin

      relation = signed_relation(tr.a_in, tr.b_in);
      cg_compare.sample(0 + relation);

      if (tr.a_in[31] != tr.b_in[31]) begin
        if (tr.a_in[31])
          cg_compare.sample(9);
        else
          cg_compare.sample(10);
      end

    end


    else if (op == COV_OP_SLTU) begin

      relation = unsigned_relation(tr.a_in, tr.b_in);
      cg_compare.sample(3 + relation);

      if (tr.a_in[31] != tr.b_in[31])
        cg_compare.sample(11);

    end


    else if (op == COV_OP_MAX) begin

      relation = signed_relation(tr.a_in, tr.b_in);
      cg_compare.sample(6 + relation);

      if (tr.a_in[31] != tr.b_in[31]) begin
        if (tr.a_in[31])
          cg_compare.sample(9);
        else
          cg_compare.sample(10);
      end

    end


    // ------------------------------------------------------------------------
    // CTZ
    // ------------------------------------------------------------------------
    if (op == COV_OP_CTZ) begin
      cg_ctz.sample(
        ctz32(tr.a_in)
      );
    end


    // ------------------------------------------------------------------------
    // CPOP
    // ------------------------------------------------------------------------
    if (op == COV_OP_CPOP) begin

      count_value = $countones(tr.a_in);
      cg_cpop_count.sample(count_value);

      if ($onehot(tr.a_in)) begin
        bit_index = onehot_index32(tr.a_in);

        if (bit_index >= 0)
          cg_cpop_region.sample(bit_index);
      end

    end


    // ------------------------------------------------------------------------
    // SEXT.B
    // ------------------------------------------------------------------------
    if (op == COV_OP_SEXT_B)
      cg_sext_b.sample(tr.a_in[7:0]);


    // ------------------------------------------------------------------------
    // PACK
    // ------------------------------------------------------------------------
    if (op == COV_OP_PACK)
      cg_pack.sample(tr.a_in[15:0] != tr.b_in[15:0]);


    // ------------------------------------------------------------------------
    // GREV supported REV8
    // ------------------------------------------------------------------------
    if (op == COV_OP_GREV)
      cg_grev.sample(1);


    // ------------------------------------------------------------------------
    // CSR source-selection observability
    // ------------------------------------------------------------------------
    if (op == COV_OP_CSR_READ) begin

      if (!$isunknown({
            tr.csr_rddata_in,
            tr.a_in,
            tr.b_in
          }) &&
          (tr.csr_rddata_in != tr.a_in) &&
          (tr.csr_rddata_in != tr.b_in))
        cg_csr_source.sample(0);

    end


    else if (op == COV_OP_CSR_WRITE_A) begin

      if (!$isunknown({tr.a_in, tr.b_in}) &&
          (tr.a_in != tr.b_in))
        cg_csr_source.sample(1);

    end


    else if (op == COV_OP_CSR_WRITE_B) begin

      if (!$isunknown({tr.a_in, tr.b_in}) &&
          (tr.a_in != tr.b_in))
        cg_csr_source.sample(2);

    end

  endfunction


  // ==========================================================================
  // WRITE
  // ==========================================================================

  virtual function void write(bmu_seq_item t);

    bmu_cov_op_e    op;
    bmu_cov_error_e error_reason;
    bit             has_error_intent;


    // ------------------------------------------------------------------------
    // Ignore unknown reset/scan samples and scan mode.
    // ------------------------------------------------------------------------
    if ($isunknown({t.rst_l, t.scan_mode}))
      return;

    if (t.scan_mode != 1'b0)
      return;


    // ------------------------------------------------------------------------
    // Synchronous reset coverage.
    // Scoreboard/assertions check result_ff=0 and error=0.
    // ------------------------------------------------------------------------
    if (!t.rst_l) begin

      close_hold_run();

      cg_reset.sample(activity_seen);

      have_prev_valid = 0;
      prev_valid_in   = 0;
      activity_seen   = 0;

      return;

    end


    // ------------------------------------------------------------------------
    // valid_in temporal coverage.
    // ------------------------------------------------------------------------
    if (!$isunknown(t.valid_in)) begin

      if (have_prev_valid)
        cg_valid_transition.sample({prev_valid_in, t.valid_in});

      if (!t.valid_in) begin

        if (!hold_active) begin
          hold_active = 1;
          hold_length = 1;
        end
        else begin
          hold_length++;
        end

      end
      else begin

        close_hold_run();

      end

      have_prev_valid = 1;
      prev_valid_in   = t.valid_in;

    end
    else begin

      return;

    end


    // ------------------------------------------------------------------------
    // Need known controls for request classification.
    // ------------------------------------------------------------------------
    if ($isunknown({t.ap, t.csr_ren_in}))
      return;

    if (t.ap.grev && $isunknown(t.b_in[4:0]))
      return;


    // ------------------------------------------------------------------------
    // Error-intent coverage is independent of valid_in.
    // ------------------------------------------------------------------------
    has_error_intent =
      classify_error(
        t,
        error_reason
      );

    if (has_error_intent) begin
      cg_error_reason.sample(error_reason);
      cg_error_valid.sample(t.valid_in);
    end


    // ------------------------------------------------------------------------
    // Unsupported GREV mode: valid functional request class, no error.
    // ------------------------------------------------------------------------
    if (t.valid_in && is_unsupported_grev(t)) begin
      cg_grev.sample(0);
      activity_seen = 1;
    end


    // ------------------------------------------------------------------------
    // Legal operation coverage is sampled only for valid accepted requests.
    // ------------------------------------------------------------------------
    op = decode_legal_op(t);

    if (t.valid_in &&
        (op != COV_OP_NONE)) begin

      cg_operation.sample(op);
      activity_seen = 1;

      if (required_data_known(t, op))
        sample_legal_data(t, op);

    end

  endfunction


  // If a valid_in=0 run reaches end-of-test, close it for hold coverage.
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    close_hold_run();
  endfunction


endclass : bmu_subscriber
