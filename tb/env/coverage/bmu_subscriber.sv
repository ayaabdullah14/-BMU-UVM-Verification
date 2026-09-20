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
    option.name = "cg_operation";

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
    option.name = "cg_logic";

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
    option.name = "cg_shift";

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
    option.name = "cg_sra_sign";

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
    option.name = "cg_binv";

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
    option.name = "cg_compare";

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
    option.name = "cg_shift_data";

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
    option.name = "cg_sub";

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
    option.name = "cg_sh2add";

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
    option.name = "cg_ctz";

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
    option.name = "cg_cpop_count";

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
    option.name = "cg_cpop_region";

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
    option.name = "cg_sext_b";

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
    option.name = "cg_pack";

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
    option.name = "cg_grev";

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
    option.name = "cg_csr_source";

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
    option.name = "cg_csr_data";

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
    option.name = "cg_error_reason";

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
    option.name = "cg_error_valid";

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


// ============================================================================
  // WRITE
  //
  // All classification and sampling is intentionally kept inline here.
  // No custom helper functions are used.
  // ============================================================================

  virtual function void write(bmu_seq_item t);

    bmu_cov_op_e          op;
    bmu_cov_error_e       error_reason;
    bmu_cov_relation_e    relation;
    bmu_cov_upper_e       upper_class;
    bmu_cov_csr_data_e    csr_class;
    bmu_cov_shift_data_e  shift_class;

    logic [32:0] sub_wide;
    logic [33:0] sh2_wide;
    logic [31:0] csr_data;

    int unsigned n;
    int unsigned primary_n;
    int unsigned code;
    int unsigned count_value;
    int          bit_index;

    bit has_primary;
    bit legal_primary_recipe;
    bit unsupported_grev;
    bit has_error_intent;
    bit data_known;
    bit required_known;
    bit overflow;

    if ($isunknown({t.rst_l, t.scan_mode}))
      return;

    if (t.scan_mode != 1'b0)
      return;

    if (!t.rst_l) begin
      prev_accepted_legal = 0;
      prev_data_known     = 0;
      prev_op             = COV_OP_NONE;
      return;
    end

    if ($isunknown(t.valid_in))
      return;

    if ($isunknown({t.ap, t.csr_ren_in}))
      return;

    if (t.ap.grev && $isunknown(t.b_in[4:0]))
      return;

    n = $countones(t.ap);

    primary_n = $countones({
      t.ap.lor,
      t.ap.lxor,
      t.ap.srl,
      t.ap.sra,
      t.ap.ror,
      t.ap.binv,
      t.ap.sh2add,
      t.ap.sub,
      t.ap.slt,
      t.ap.ctz,
      t.ap.cpop,
      t.ap.siext_b,
      t.ap.max,
      t.ap.pack,
      t.ap.grev
    });

    has_primary = (
      t.ap.lor     ||
      t.ap.lxor    ||
      t.ap.srl     ||
      t.ap.sra     ||
      t.ap.ror     ||
      t.ap.binv    ||
      t.ap.sh2add  ||
      t.ap.sub     ||
      t.ap.slt     ||
      t.ap.ctz     ||
      t.ap.cpop    ||
      t.ap.siext_b ||
      t.ap.max     ||
      t.ap.pack    ||
      t.ap.grev
    );

    legal_primary_recipe =
      (t.ap.slt && t.ap.sub && (primary_n == 2)) ||
      (t.ap.max && t.ap.sub && (primary_n == 2)) ||
      ((primary_n == 1) && has_primary);

    unsupported_grev = (
      !t.csr_ren_in &&
      t.ap.grev &&
      (n == 1) &&
      (t.b_in[4:0] != 5'd24)
    );

    op = COV_OP_NONE;

    if (t.csr_ren_in && (t.ap == '0))
      op = COV_OP_CSR_READ;
    else if (t.csr_ren_in)
      op = COV_OP_NONE;
    else if (t.ap.slt && t.ap.sub && !t.ap.unsign && (n == 2))
      op = COV_OP_SLT;
    else if (t.ap.slt && t.ap.sub && t.ap.unsign && (n == 3))
      op = COV_OP_SLTU;
    else if (t.ap.max && t.ap.sub && !t.ap.unsign && (n == 2))
      op = COV_OP_MAX;
    else if (t.ap.sh2add && t.ap.zba && (n == 2))
      op = COV_OP_SH2ADD;
    else if (t.ap.lor && !t.ap.zbb && (n == 1))
      op = COV_OP_OR;
    else if (t.ap.lor && t.ap.zbb && (n == 2))
      op = COV_OP_ORN;
    else if (t.ap.lxor && !t.ap.zbb && (n == 1))
      op = COV_OP_XOR;
    else if (t.ap.lxor && t.ap.zbb && (n == 2))
      op = COV_OP_XNOR;
    else if (t.ap.srl && (n == 1))
      op = COV_OP_SRL;
    else if (t.ap.sra && (n == 1))
      op = COV_OP_SRA;
    else if (t.ap.ror && (n == 1))
      op = COV_OP_ROR;
    else if (t.ap.binv && (n == 1))
      op = COV_OP_BINV;
    else if (t.ap.sub && !t.ap.zba && (n == 1))
      op = COV_OP_SUB;
    else if (t.ap.ctz && (n == 1))
      op = COV_OP_CTZ;
    else if (t.ap.cpop && (n == 1))
      op = COV_OP_CPOP;
    else if (t.ap.siext_b && (n == 1))
      op = COV_OP_SEXT_B;
    else if (t.ap.pack && (n == 1))
      op = COV_OP_PACK;
    else if (t.ap.grev && (n == 1) && (t.b_in[4:0] == 5'd24))
      op = COV_OP_GREV;
    else if (t.ap.csr_write && !t.ap.csr_imm && (n == 1))
      op = COV_OP_CSR_WRITE_A;
    else if (t.ap.csr_write && t.ap.csr_imm && (n == 2))
      op = COV_OP_CSR_WRITE_B;

    has_error_intent = 0;

    if (t.csr_ren_in && (t.ap != '0)) begin
      error_reason     = COV_ERR_CSR_CONFLICT;
      has_error_intent = 1;
    end
    else if (t.ap.sh2add && (primary_n == 1) && !t.ap.zba) begin
      error_reason     = COV_ERR_SH2ADD_NO_ZBA;
      has_error_intent = 1;
    end
    else if (t.ap.sub && t.ap.zba && (primary_n == 1)) begin
      error_reason     = COV_ERR_SUB_WITH_ZBA;
      has_error_intent = 1;
    end
    else if (unsupported_grev) begin
      has_error_intent = 0;
    end
    else if (has_primary && (t.ap.csr_write || t.ap.csr_imm)) begin
      has_error_intent = 0;
    end
    else if (!t.csr_ren_in && (op == COV_OP_NONE)) begin
      if (legal_primary_recipe) begin
        error_reason     = COV_ERR_EXTRA_FIELD;
        has_error_intent = 1;
      end
      else if (primary_n > 1) begin
        error_reason     = COV_ERR_MULTI_OPERATION;
        has_error_intent = 1;
      end
    end

    if (has_error_intent) begin
      cg_error_reason.sample(error_reason);
      cg_error_valid.sample(t.valid_in);
    end

    if (t.valid_in && unsupported_grev)
      cg_grev.sample(0);

    if (t.valid_in && (op != COV_OP_NONE)) begin

      cg_operation.sample(op);

      data_known = !$isunknown({t.a_in, t.b_in});

      if (data_known && prev_accepted_legal && prev_data_known) begin
        if ((op inside {
              COV_OP_SRL, COV_OP_SRA, COV_OP_ROR, COV_OP_BINV, COV_OP_GREV
            }) &&
            (prev_op == op) &&
            (prev_a == t.a_in) &&
            (prev_b[4:0] == t.b_in[4:0]) &&
            (prev_b[31:5] != t.b_in[31:5])) begin
        end

        if ((op inside {COV_OP_CTZ, COV_OP_CPOP, COV_OP_SEXT_B}) &&
            (prev_op == op) &&
            (prev_a == t.a_in) &&
            (prev_b != t.b_in)) begin
        end
      end

      case (op)
        COV_OP_CSR_READ:
          required_known = !$isunknown(t.csr_rddata_in);
        COV_OP_CSR_WRITE_A:
          required_known = !$isunknown(t.a_in);
        COV_OP_CSR_WRITE_B:
          required_known = !$isunknown(t.b_in);
        default:
          required_known = !$isunknown({t.a_in, t.b_in});
      endcase

      if (required_known) begin

        if (op inside {COV_OP_OR, COV_OP_ORN, COV_OP_XOR, COV_OP_XNOR}) begin
          for (int unsigned i = 0; i < 32; i++)
            cg_logic.sample(op, {t.a_in[i], t.b_in[i]});
        end

        if (op inside {COV_OP_SRL, COV_OP_SRA, COV_OP_ROR}) begin
          cg_shift.sample(op, t.b_in[4:0]);

          if (t.a_in == 32'h00000000)
            shift_class = COV_SHIFT_ZERO;
          else if (t.a_in == 32'hffffffff)
            shift_class = COV_SHIFT_ONES;
          else if ($onehot(t.a_in))
            shift_class = COV_SHIFT_ONEHOT;
          else
            shift_class = COV_SHIFT_OTHER;

          cg_shift_data.sample(op, shift_class);

          if ((op == COV_OP_SRA) && (t.b_in[4:0] != 5'd0))
            cg_sra_sign.sample(t.a_in[31]);
        end

        if (op == COV_OP_BINV) begin
          cg_binv.sample(t.b_in[4:0], t.a_in[t.b_in[4:0]]);
        end

        if (op == COV_OP_SLT) begin
          if ($signed(t.a_in) < $signed(t.b_in))
            relation = COV_REL_LT;
          else if ($signed(t.a_in) > $signed(t.b_in))
            relation = COV_REL_GT;
          else
            relation = COV_REL_EQ;

          code = ({t.a_in[31], t.b_in[31]} * 3) + relation;
          cg_compare.sample(code);
        end
        else if (op == COV_OP_SLTU) begin
          if (t.a_in < t.b_in)
            relation = COV_REL_LT;
          else if (t.a_in > t.b_in)
            relation = COV_REL_GT;
          else
            relation = COV_REL_EQ;

          code = 12 + ({t.a_in[31], t.b_in[31]} * 3) + relation;
          cg_compare.sample(code);
        end
        else if (op == COV_OP_MAX) begin
          if ($signed(t.a_in) < $signed(t.b_in))
            relation = COV_REL_LT;
          else if ($signed(t.a_in) > $signed(t.b_in))
            relation = COV_REL_GT;
          else
            relation = COV_REL_EQ;

          code = 24 + ({t.a_in[31], t.b_in[31]} * 3) + relation;
          cg_compare.sample(code);
        end

        if (op == COV_OP_SUB) begin
          if (t.a_in < t.b_in)
            relation = COV_REL_LT;
          else if (t.a_in > t.b_in)
            relation = COV_REL_GT;
          else
            relation = COV_REL_EQ;

          sub_wide = {1'b0, t.a_in} - {1'b0, t.b_in};
          overflow = (t.a_in[31] != t.b_in[31]) &&
                     (sub_wide[31] != t.a_in[31]);

          if (relation == COV_REL_EQ)
            code = 0;
          else if (relation == COV_REL_LT)
            code = overflow ? 2 : 1;
          else
            code = overflow ? 4 : 3;

          cg_sub.sample(code);
        end

        if (op == COV_OP_SH2ADD) begin
          sh2_wide = {t.a_in, 2'b00} + {{2{1'b0}}, t.b_in};

          if (|t.a_in[31:30])
            code = 2;
          else
            code = (|sh2_wide[33:32]) ? 1 : 0;

          cg_sh2add.sample(code);
        end

        if (op == COV_OP_CTZ) begin
          count_value = 32;

          for (int unsigned i = 0; i < 32; i++) begin
            if ((count_value == 32) && t.a_in[i])
              count_value = i;
          end

          cg_ctz.sample(count_value);
        end

        if (op == COV_OP_CPOP) begin
          count_value = $countones(t.a_in);
          cg_cpop_count.sample(count_value);

          if ($onehot(t.a_in)) begin
            bit_index = -1;

            for (int unsigned i = 0; i < 32; i++) begin
              if ((bit_index < 0) && t.a_in[i])
                bit_index = i;
            end

            if (bit_index >= 0)
              cg_cpop_region.sample(bit_index);
          end
        end

        if (op == COV_OP_SEXT_B) begin
          if (t.a_in[31:8] == 24'h000000)
            upper_class = COV_UPPER_ZERO;
          else
            upper_class = COV_UPPER_NONZERO;

          cg_sext_b.sample(t.a_in[7:0], upper_class);
        end

        if (op == COV_OP_PACK) begin
          if ((t.a_in[15:0] == 16'h0000) &&
              (t.b_in[15:0] == 16'h0000))
            cg_pack.sample(0);
          else if ((t.a_in[15:0] == 16'hffff) &&
                   (t.b_in[15:0] == 16'hffff))
            cg_pack.sample(1);
          else
            cg_pack.sample(2);
        end

        if (op == COV_OP_GREV)
          cg_grev.sample(1);

        if (op == COV_OP_CSR_READ) begin
          if (!$isunknown({t.csr_rddata_in, t.a_in, t.b_in}) &&
              (t.csr_rddata_in != t.a_in) &&
              (t.csr_rddata_in != t.b_in))
            cg_csr_source.sample(0);
        end
        else if (op == COV_OP_CSR_WRITE_A) begin
          if (!$isunknown({t.a_in, t.b_in}) &&
              (t.a_in != t.b_in))
            cg_csr_source.sample(1);
        end
        else if (op == COV_OP_CSR_WRITE_B) begin
          if (!$isunknown({t.a_in, t.b_in}) &&
              (t.a_in != t.b_in))
            cg_csr_source.sample(2);
        end

        if (op inside {
              COV_OP_CSR_READ,
              COV_OP_CSR_WRITE_A,
              COV_OP_CSR_WRITE_B
            }) begin

          if (op == COV_OP_CSR_READ)
            csr_data = t.csr_rddata_in;
          else if (op == COV_OP_CSR_WRITE_A)
            csr_data = t.a_in;
          else
            csr_data = t.b_in;

          if (csr_data == 32'h00000000)
            csr_class = COV_CSR_ZERO;
          else if (csr_data == 32'hffffffff)
            csr_class = COV_CSR_ONES;
          else
            csr_class = COV_CSR_OTHER;

          cg_csr_data.sample(op, csr_class);
        end

      end

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

  // ==========================================================================
  // COVERAGE REPORT
  // Style follows the simple UVM report_phase approach from the reference
  // subscriber, while preserving all existing spec-driven covergroups.
  // ==========================================================================

  virtual function void report_phase(uvm_phase phase);
    real functional_group_average;

    super.report_phase(phase);

    functional_group_average = (
        cg_operation.get_coverage()
      + cg_logic.get_coverage()
      + cg_shift.get_coverage()
      + cg_sra_sign.get_coverage()
      + cg_binv.get_coverage()
      + cg_compare.get_coverage()
      + cg_shift_data.get_coverage()
      + cg_sub.get_coverage()
      + cg_sh2add.get_coverage()
      + cg_ctz.get_coverage()
      + cg_cpop_count.get_coverage()
      + cg_cpop_region.get_coverage()
      + cg_sext_b.get_coverage()
      + cg_pack.get_coverage()
      + cg_grev.get_coverage()
      + cg_csr_source.get_coverage()
      + cg_csr_data.get_coverage()
      + cg_error_reason.get_coverage()
      + cg_error_valid.get_coverage()
    ) / 19.0;

    `uvm_info(get_type_name(),
      "============================================================",
      UVM_LOW)

    `uvm_info(get_type_name(),
      "=== BMU FUNCTIONAL COVERAGE REPORT ===",
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("Operation Coverage      : %.2f%%", cg_operation.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("Logic Coverage          : %.2f%%", cg_logic.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("Shift Amount Coverage   : %.2f%%", cg_shift.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("SRA Sign Coverage       : %.2f%%", cg_sra_sign.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("Shift Data Coverage     : %.2f%%", cg_shift_data.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("BINV Coverage           : %.2f%%", cg_binv.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("Compare Coverage        : %.2f%%", cg_compare.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("SUB Coverage            : %.2f%%", cg_sub.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("SH2ADD Coverage         : %.2f%%", cg_sh2add.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("CTZ Coverage            : %.2f%%", cg_ctz.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("CPOP Count Coverage     : %.2f%%", cg_cpop_count.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("CPOP Region Coverage    : %.2f%%", cg_cpop_region.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("SEXT.B Coverage         : %.2f%%", cg_sext_b.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("PACK Coverage           : %.2f%%", cg_pack.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("GREV Coverage           : %.2f%%", cg_grev.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("CSR Source Coverage     : %.2f%%", cg_csr_source.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("CSR Data Coverage       : %.2f%%", cg_csr_data.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("Error Reason Coverage   : %.2f%%", cg_error_reason.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf("Error vs Valid Coverage : %.2f%%", cg_error_valid.get_coverage()),
      UVM_LOW)

    `uvm_info(get_type_name(),
      $sformatf(
        "Functional Group Average : %.2f%% (informational only)",
        functional_group_average
      ),
      UVM_LOW)

    `uvm_info(get_type_name(),
      "NOTE: Functional coverage is separate from Xcelium code coverage.",
      UVM_LOW)

    `uvm_info(get_type_name(),
      "=== END BMU FUNCTIONAL COVERAGE REPORT ===",
      UVM_LOW)

    `uvm_info(get_type_name(),
      "============================================================",
      UVM_LOW)

  endfunction

endclass : bmu_subscriber
