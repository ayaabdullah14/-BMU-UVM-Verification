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


// ============================================================================
// BMU SPEC-DRIVEN FUNCTIONAL COVERAGE
// Coverage measures whether required stimulus was exercised.
// Scoreboard/assertions check result, error, reset, hold and one-cycle latency.
// Equivalent visible behaviors are grouped; distinct boundaries and risks are
// kept separate so a high percentage cannot hide a missing requirement.
// ============================================================================

typedef enum int unsigned {
  COV_REL_LT = 0,
  COV_REL_EQ,
  COV_REL_GT
} bmu_cov_relation_e;


typedef enum int unsigned {
  COV_UPPER_ZERO = 0,
  COV_UPPER_NONZERO
} bmu_cov_upper_e;


typedef enum int unsigned {
  COV_CSR_ZERO = 0,
  COV_CSR_ONES,
  COV_CSR_OTHER
} bmu_cov_csr_data_e;


typedef enum int unsigned {
  COV_SHIFT_ZERO = 0,
  COV_SHIFT_ONES,
  COV_SHIFT_ONEHOT,
  COV_SHIFT_OTHER
} bmu_cov_shift_data_e;


typedef enum int unsigned {
  COV_ERR_CSR_CONFLICT = 0,
  COV_ERR_SH2ADD_NO_ZBA,
  COV_ERR_SUB_WITH_ZBA,
  COV_ERR_MULTI_OPERATION,
  COV_ERR_EXTRA_FIELD
} bmu_cov_error_e;


// ============================================================================
// SUBSCRIBER
// ============================================================================

class bmu_subscriber extends uvm_subscriber #(bmu_seq_item);

  `uvm_component_utils(bmu_subscriber)

  // Retained only for documented ignored-input checks, where two requests
  // must differ solely in an input that the operation is specified to ignore.
  bit          prev_accepted_legal;
  bit          prev_data_known;
  bmu_cov_op_e prev_op;
  logic [31:0] prev_a;
  logic [31:0] prev_b;


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
  // 3. SHIFT / ROTATE AMOUNTS
  //
  // Spec-visible behavior only: shift amount is b_in[4:0].
  // The spec defines b_in[4:0] as the amount. Coverage keeps the meaningful
  // functional boundaries (no shift, half width, and maximum) while grouping
  // ordinary interior values that do not represent separate requirements.
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

      bins zero    = {5'd0};
      bins low     = {[5'd1:5'd15]};
      bins half    = {5'd16};
      bins high    = {[5'd17:5'd30]};
      bins maximum = {5'd31};
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
  // End bits are true boundaries. Interior positions are grouped by lower and
  // upper half so coverage does not require 32 nearly identical directed tests.
  // Original target-bit value is covered separately; no Cartesian cross.
  // ==========================================================================

  covergroup cg_binv with function sample(
    logic [4:0] index,
    bit original_bit
  );
    option.per_instance = 1;

    cp_index: coverpoint index {
      bins lsb        = {5'd0};
      bins lower_half = {[5'd1:5'd15]};
      bins upper_half = {[5'd16:5'd30]};
      bins msb        = {5'd31};
    }

    cp_original: coverpoint original_bit {
      bins zero = {0};
      bins one  = {1};
    }
  endgroup


  // ==========================================================================
  // 6. COMPARISON COVERAGE
  // Reachable operation x sign-pair x relation combinations only.
  // ==========================================================================

  covergroup cg_compare with function sample(int unsigned code);
    option.per_instance = 1;

    cp_case: coverpoint code {
      bins reachable[] = {[0:35]};
      ignore_bins impossible = {
        3, 4, 7, 8,
        16, 17, 18, 19,
        27, 28, 31, 32
      };
    }
  endgroup


  // Representative A classes for each shift/rotate operation.
  covergroup cg_shift_data with function sample(
    bmu_cov_op_e op,
    bmu_cov_shift_data_e data_class
  );
    option.per_instance = 1;

    cp_op: coverpoint op {
      option.weight = 0;
      bins ops[] = {COV_OP_SRL, COV_OP_SRA, COV_OP_ROR};
    }

    cp_data: coverpoint data_class {
      option.weight = 0;
    }

    op_x_data: cross cp_op, cp_data;
  endgroup


  // ==========================================================================
  // 7. SUB / SH2ADD ARITHMETIC RISKS
  // ==========================================================================

  covergroup cg_sub with function sample(int unsigned code);
    option.per_instance = 1;

    cp_case: coverpoint code {
      bins equal                    = {0};
      bins borrow_no_overflow       = {1};
      bins borrow_with_overflow     = {2};
      bins no_borrow_no_overflow    = {3};
      bins no_borrow_with_overflow  = {4};
    }
  endgroup


  covergroup cg_sh2add with function sample(int unsigned code);
    option.per_instance = 1;

    cp_case: coverpoint code {
      bins normal_no_carry     = {0};
      bins addition_carry      = {1};
      bins upper_bits_shifted  = {2};
    }
  endgroup


  // ==========================================================================
  // 8. CTZ
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
  // 9. CPOP COUNT
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
  // 10. CPOP SOURCE REGION
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
  // 11. SEXT.B
  // ==========================================================================

  covergroup cg_sext_b with function sample(
    logic [7:0] byte_value,
    bmu_cov_upper_e upper_class
  );
    option.per_instance = 1;

    cp_byte: coverpoint byte_value {
      bins zero           = {8'h00};
      bins max_positive   = {8'h7f};
      bins min_negative   = {8'h80};
      bins minus_one      = {8'hff};
      bins other_positive = {[8'h01:8'h7e]};
      bins other_negative = {[8'h81:8'hfe]};
    }

    cp_sign: coverpoint byte_value[7] {
      option.weight = 0;
      bins positive = {0};
      bins negative = {1};
    }

    cp_upper: coverpoint upper_class {
      option.weight = 0;
    }

    sign_x_upper: cross cp_sign, cp_upper;
  endgroup


  // ==========================================================================
  // 12. PACK
  // Small semantic classes. No 16-bit Cartesian data sweep.
  // ==========================================================================

  covergroup cg_pack with function sample(int unsigned code);
    option.per_instance = 1;

    cp_case: coverpoint code {
      bins both_zero = {0};
      bins both_ones = {1};
      bins other     = {2};
    }
  endgroup


  // ==========================================================================
  // 13. GREV / REV8
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
  // 14. CSR SOURCE DISCRIMINATION AND SELECTED-DATA CLASSES
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


  covergroup cg_csr_data with function sample(
    bmu_cov_op_e path,
    bmu_cov_csr_data_e data_class
  );
    option.per_instance = 1;

    cp_path: coverpoint path {
      option.weight = 0;
      bins paths[] = {
        COV_OP_CSR_READ,
        COV_OP_CSR_WRITE_A,
        COV_OP_CSR_WRITE_B
      };
    }

    cp_data: coverpoint data_class {
      option.weight = 0;
    }

    path_x_data: cross cp_path, cp_data;
  endgroup


  // ==========================================================================
  // 15. ERROR REASONS
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
        COV_ERR_MULTI_OPERATION,
        COV_ERR_EXTRA_FIELD
      };
    }
  endgroup


  // ==========================================================================
  // 16. ERROR vs valid_in
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
    cg_shift_data       = new();
    cg_binv             = new();
    cg_compare          = new();
    cg_sub              = new();
    cg_sh2add           = new();
    cg_ctz              = new();
    cg_cpop_count       = new();
    cg_cpop_region      = new();
    cg_sext_b           = new();
    cg_pack             = new();
    cg_grev             = new();
    cg_csr_source       = new();
    cg_csr_data         = new();
    cg_error_reason     = new();
    cg_error_valid      = new();

    prev_accepted_legal = 0;
    prev_data_known     = 0;
    prev_op             = COV_OP_NONE;
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


  function automatic int unsigned primary_count(bmu_seq_item tr);
    return $countones({
      tr.ap.lor,
      tr.ap.lxor,
      tr.ap.srl,
      tr.ap.sra,
      tr.ap.ror,
      tr.ap.binv,
      tr.ap.sh2add,
      tr.ap.sub,
      tr.ap.slt,
      tr.ap.ctz,
      tr.ap.cpop,
      tr.ap.siext_b,
      tr.ap.max,
      tr.ap.pack,
      tr.ap.grev
    });
  endfunction


  // Checks whether the primary-operation bits match one documented recipe.
  // Other AP bits are intentionally ignored here so an otherwise legal
  // primary recipe with an extra field can be classified separately.
  function automatic bit matches_legal_primary_recipe(bmu_seq_item tr);
    int unsigned n;

    n = primary_count(tr);

    if (tr.ap.slt && tr.ap.sub && (n == 2))
      return 1;

    if (tr.ap.max && tr.ap.sub && (n == 2))
      return 1;

    if ((n == 1) && has_bmu_primary(tr))
      return 1;

    return 0;
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
    // CSR read is legal only when all AP fields are zero.
// Error does not depend on valid_in.
    if (tr.csr_ren_in && (tr.ap != '0)) begin
      reason = COV_ERR_CSR_CONFLICT;
      return 1;
    end

    // SH2ADD requires zba.
    if (tr.ap.sh2add &&
        (primary_count(tr) == 1) &&
        !tr.ap.zba) begin
      reason = COV_ERR_SH2ADD_NO_ZBA;
      return 1;
    end

    // Standalone SUB forbids zba.
    if (tr.ap.sub &&
        tr.ap.zba &&
        (primary_count(tr) == 1)) begin
      reason = COV_ERR_SUB_WITH_ZBA;
      return 1;
    end

    // GREV with a clean control vector but mode != 24 is unsupported,
    // not an error according to the approved interpretation.
    if (is_unsupported_grev(tr))
      return 0;

    // CSR-write collisions are still undocumented in the verification plan.
    // Do not guess their error behavior until that clarification is closed.
    if (has_bmu_primary(tr) &&
        (tr.ap.csr_write || tr.ap.csr_imm))
      return 0;

    op = decode_legal_op(tr);

    // Trainer-corrected extra-field conflicts.
    // An invalid multi-primary request cannot be assigned reliably to one
    // operation name, so coverage records the conflict type instead.
    if (!tr.csr_ren_in && (op == COV_OP_NONE)) begin

      if (matches_legal_primary_recipe(tr)) begin
        reason = COV_ERR_EXTRA_FIELD;
        return 1;
      end

      if (primary_count(tr) > 1) begin
        reason = COV_ERR_MULTI_OPERATION;
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


  function automatic bmu_cov_upper_e upper24_class(logic [23:0] value);
    if (value == 24'h000000)
      return COV_UPPER_ZERO;

    return COV_UPPER_NONZERO;
  endfunction


  function automatic bmu_cov_csr_data_e csr_data_class(logic [31:0] value);
    if (value == 32'h00000000)
      return COV_CSR_ZERO;

    if (value == 32'hffffffff)
      return COV_CSR_ONES;

    return COV_CSR_OTHER;
  endfunction


  function automatic bmu_cov_shift_data_e shift_data_class(
    logic [31:0] value
  );
    if (value == 32'h00000000)
      return COV_SHIFT_ZERO;

    if (value == 32'hffffffff)
      return COV_SHIFT_ONES;

    if ($onehot(value))
      return COV_SHIFT_ONEHOT;

    return COV_SHIFT_OTHER;
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


  // ==========================================================================
  // OPERATION-SPECIFIC SAMPLING
  // ==========================================================================

  function void sample_legal_data(
    bmu_seq_item tr,
    bmu_cov_op_e op
  );
    bmu_cov_relation_e relation;
    logic [32:0] sub_wide;
    logic [33:0] sh2_wide;
    logic [31:0] csr_data;
    int unsigned code;
    int unsigned count_value;
    int bit_index;
    bit overflow;


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
      cg_shift_data.sample(op, shift_data_class(tr.a_in));

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
      code = ({tr.a_in[31], tr.b_in[31]} * 3) + relation;
      cg_compare.sample(code);

    end


    else if (op == COV_OP_SLTU) begin

      relation = unsigned_relation(tr.a_in, tr.b_in);
      code = 12 + ({tr.a_in[31], tr.b_in[31]} * 3) + relation;
      cg_compare.sample(code);

    end


    else if (op == COV_OP_MAX) begin

      relation = signed_relation(tr.a_in, tr.b_in);
      code = 24 + ({tr.a_in[31], tr.b_in[31]} * 3) + relation;
      cg_compare.sample(code);

    end


    // ------------------------------------------------------------------------
    // SUB
    // ------------------------------------------------------------------------
    if (op == COV_OP_SUB) begin
      relation = unsigned_relation(tr.a_in, tr.b_in);
      sub_wide = {1'b0, tr.a_in} - {1'b0, tr.b_in};
      overflow = (tr.a_in[31] != tr.b_in[31]) &&
                 (sub_wide[31] != tr.a_in[31]);

      if (relation == COV_REL_EQ)
        code = 0;
      else if (relation == COV_REL_LT)
        code = overflow ? 2 : 1;
      else
        code = overflow ? 4 : 3;

      cg_sub.sample(code);
    end


    // ------------------------------------------------------------------------
    // SH2ADD
    // ------------------------------------------------------------------------
    if (op == COV_OP_SH2ADD) begin
      sh2_wide = {tr.a_in, 2'b00} + {{2{1'b0}}, tr.b_in};

      if (|tr.a_in[31:30])
        code = 2;
      else
        code = (|sh2_wide[33:32]) ? 1 : 0;

      cg_sh2add.sample(code);
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
      cg_sext_b.sample(
        tr.a_in[7:0],
        upper24_class(tr.a_in[31:8])
      );


    // ------------------------------------------------------------------------
    // PACK
    // ------------------------------------------------------------------------
    if (op == COV_OP_PACK) begin
      if ((tr.a_in[15:0] == 16'h0000) &&
          (tr.b_in[15:0] == 16'h0000))
        cg_pack.sample(0);

      else if ((tr.a_in[15:0] == 16'hffff) &&
               (tr.b_in[15:0] == 16'hffff))
        cg_pack.sample(1);

      else
        cg_pack.sample(2);
    end


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


    if (op inside {
          COV_OP_CSR_READ,
          COV_OP_CSR_WRITE_A,
          COV_OP_CSR_WRITE_B
        }) begin

      if (op == COV_OP_CSR_READ)
        csr_data = tr.csr_rddata_in;
      else if (op == COV_OP_CSR_WRITE_A)
        csr_data = tr.a_in;
      else
        csr_data = tr.b_in;

      cg_csr_data.sample(op, csr_data_class(csr_data));
    end

  endfunction


  // ==========================================================================
  // WRITE
  // ==========================================================================

  virtual function void write(bmu_seq_item t);

    bmu_cov_op_e    op;
    bmu_cov_error_e error_reason;
    bit             has_error_intent;
    bit             data_known;


    // ------------------------------------------------------------------------
    // Ignore unknown reset/scan samples and scan mode.
    // ------------------------------------------------------------------------
    if ($isunknown({t.rst_l, t.scan_mode}))
      return;

    if (t.scan_mode != 1'b0)
      return;


    // ------------------------------------------------------------------------
    // Reset behavior is checked by scoreboard/assertions. Coverage only clears
    // local history so no ignored-input pair can span across reset.
    // ------------------------------------------------------------------------
    if (!t.rst_l) begin

      prev_accepted_legal = 0;
      prev_data_known     = 0;
      prev_op             = COV_OP_NONE;

      return;

    end


    // ------------------------------------------------------------------------
    // valid_in must be known before classifying an accepted request. Result
    // hold and one-cycle latency are checked by scoreboard/assertions.
    // ------------------------------------------------------------------------
    if ($isunknown(t.valid_in)) begin
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
    end


    // ------------------------------------------------------------------------
    // Legal operation coverage is sampled only for valid accepted requests.
    // ------------------------------------------------------------------------
    op = decode_legal_op(t);

    if (t.valid_in &&
        (op != COV_OP_NONE)) begin

      cg_operation.sample(op);

      data_known = !$isunknown({t.a_in, t.b_in});

      if (data_known && prev_accepted_legal && prev_data_known) begin

        if ((op inside {
              COV_OP_SRL,
              COV_OP_SRA,
              COV_OP_ROR,
              COV_OP_BINV,
              COV_OP_GREV
            }) &&
            (prev_op == op) &&
            (prev_a == t.a_in) &&
            (prev_b[4:0] == t.b_in[4:0]) &&
            (prev_b[31:5] != t.b_in[31:5])) begin

          
        end

        if ((op inside {
              COV_OP_CTZ,
              COV_OP_CPOP,
              COV_OP_SEXT_B
            }) &&
            (prev_op == op) &&
            (prev_a == t.a_in) &&
            (prev_b != t.b_in)) begin

          
        end

        

      end

      if (required_data_known(t, op))
        sample_legal_data(t, op);

      prev_accepted_legal = 1;
      prev_data_known     = data_known;
      prev_op             = op;

      if (data_known) begin
        prev_a = t.a_in;
        prev_b = t.b_in;
      end

    end
    else begin

      prev_accepted_legal = 0;
      prev_data_known     = 0;
      prev_op             = COV_OP_NONE;

    end

  endfunction


endclass : bmu_subscriber
