
// BMU reference operations
typedef enum logic [4:0] {
  BMU_REF_NONE,
  BMU_REF_OR,
  BMU_REF_ORN,
  BMU_REF_XOR,
  BMU_REF_XNOR,
  BMU_REF_SRL,
  BMU_REF_SRA,
  BMU_REF_ROR,
  BMU_REF_BINV,
  BMU_REF_SH2ADD,
  BMU_REF_SUB,
  BMU_REF_SLT,
  BMU_REF_SLTU,
  BMU_REF_CTZ,
  BMU_REF_CPOP,
  BMU_REF_SEXT_B,
  BMU_REF_MAX_SIGNED,
  BMU_REF_PACK,
  BMU_REF_GREV_REV8,
  BMU_REF_CSR_READ,
  BMU_REF_CSR_WRITE_A,
  BMU_REF_CSR_WRITE_B
} bmu_ref_operation_e;


class bmu_reference_model extends uvm_object;
  `uvm_object_utils(bmu_reference_model)

  function new(string name = "bmu_reference_model");
    super.new(name);
  endfunction


  // Convenience method for the scoreboard.
  // No comparison or latency handling is performed here.
  function void predict(
    input  bmu_seq_item tr,
    output logic [31:0] expected_result,
    output logic        expected_error
  );
    expected_result = calculate_result(tr);
    expected_error  = calculate_error(tr);
  endfunction


  // ---------------------------------------------------------------------------
  // Expected combinational result
  // ---------------------------------------------------------------------------
  function logic [31:0] calculate_result(input bmu_seq_item tr);
    bmu_ref_operation_e operation;
    logic [31:0]        result;
    logic [4:0]         shift_amount;

    result       = 32'h0000_0000;
    operation    = BMU_REF_NONE;
    shift_amount = tr.b_in[4:0];

    if ($isunknown(tr.rst_l)) begin
      result = 32'hxxxx_xxxx;
    end
    else if (tr.rst_l == 1'b0) begin
      result = 32'h0000_0000;
    end
    else if ($isunknown({tr.ap, tr.csr_ren_in})) begin
      result = 32'hxxxx_xxxx;
    end
    else begin
      operation = decode_operation(tr);

      case (operation)
        BMU_REF_OR:
          result = tr.a_in | tr.b_in;

        BMU_REF_ORN:
          result = tr.a_in | ~tr.b_in;

        BMU_REF_XOR:
          result = tr.a_in ^ tr.b_in;

        BMU_REF_XNOR:
          result = ~(tr.a_in ^ tr.b_in);

        BMU_REF_SRL:
          result = $unsigned(tr.a_in) >> shift_amount;

        BMU_REF_SRA:
          result = $signed(tr.a_in) >>> shift_amount;

        BMU_REF_ROR:
          result = rotate_right_32(tr.a_in, shift_amount);

        BMU_REF_BINV:
          result = tr.a_in ^ (32'h0000_0001 << shift_amount);

        BMU_REF_SH2ADD:
          result = (tr.a_in << 2) + tr.b_in;

        BMU_REF_SUB:
          result = tr.a_in - tr.b_in;

        BMU_REF_SLT:
          result = ($signed(tr.a_in) < $signed(tr.b_in))
                 ? 32'h0000_0001 : 32'h0000_0000;

        BMU_REF_SLTU:
          result = ($unsigned(tr.a_in) < $unsigned(tr.b_in))
                 ? 32'h0000_0001 : 32'h0000_0000;

        BMU_REF_CTZ:
          result = count_trailing_zeros_32(tr.a_in);

        BMU_REF_CPOP:
          result = population_count_32(tr.a_in);

        BMU_REF_SEXT_B:
          result = {{24{tr.a_in[7]}}, tr.a_in[7:0]};

        BMU_REF_MAX_SIGNED:
          result = ($signed(tr.a_in) >= $signed(tr.b_in))
                 ? tr.a_in : tr.b_in;

        BMU_REF_PACK:
          result = {tr.b_in[15:0], tr.a_in[15:0]};

        BMU_REF_GREV_REV8: begin
          // The approved GREV subset implements REV8 only.
          if (tr.b_in[4:0] == 5'b11000)
            result = {tr.a_in[7:0], tr.a_in[15:8],
                      tr.a_in[23:16], tr.a_in[31:24]};
          else
            result = 32'h0000_0000;
        end

        BMU_REF_CSR_READ:
          result = tr.csr_rddata_in;

        BMU_REF_CSR_WRITE_A:
          result = tr.a_in;

        BMU_REF_CSR_WRITE_B:
          result = tr.b_in;

        default:
          result = 32'h0000_0000;
      endcase
    end

    calculate_result = result;
  endfunction


  // Expected combinational error
  // The function intentionally does not use valid_in.
   function logic calculate_error(input bmu_seq_item tr);

  bmu_ref_operation_e operation;
  logic               expected_error;

  operation      = BMU_REF_NONE;
  expected_error = 1'b0;

  if ($isunknown(tr.rst_l)) begin
    expected_error = 1'bx;
  end
  else if (tr.rst_l == 1'b0) begin
    expected_error = 1'b0;
  end
  else if ($isunknown({tr.ap, tr.csr_ren_in})) begin
    expected_error = 1'bx;
  end
  else if (no_operation_selected(tr)) begin
    // ap='0 and csr_ren_in=0 is a legal NOP.
    expected_error = 1'b0;
  end
  else begin
    operation = decode_operation(tr);

    if (operation != BMU_REF_NONE) begin
      expected_error = 1'b0;
    end
    else if (tr.csr_ren_in && (tr.ap != '0)) begin
      // CSR read cannot be active with any ap field.
      expected_error = 1'b1;
    end
    else if ((tr.ap.add || tr.ap.sub) && tr.ap.zba) begin
      // ADD/SUB must not be used as the primary operation in Zba mode.
      expected_error = 1'b1;
    end
    else if ((tr.ap.sh1add ||
              tr.ap.sh2add ||
              tr.ap.sh3add) &&
             !tr.ap.zba) begin
      // SHxADD requires the Zba qualifier.
      expected_error = 1'b1;
    end
    else if (approved_primary_control_selected(tr)) begin
      // An approved operation exists, but the complete packet
      // does not match a legal control recipe.
      expected_error = 1'b1;
    end
    else begin
      // Control outside the currently approved verification scope.
      expected_error = 1'b0;
    end
  end

  calculate_error = expected_error;

endfunction


  // Decode one exact legal operation.
  function bmu_ref_operation_e decode_operation(input bmu_seq_item tr);
    bmu_ref_operation_e operation;

    operation = BMU_REF_NONE;

    if (!$isunknown({tr.ap, tr.csr_ren_in})) begin
      if      (controls_match(tr, BMU_REF_CSR_READ))    operation = BMU_REF_CSR_READ;
      else if (controls_match(tr, BMU_REF_CSR_WRITE_A)) operation = BMU_REF_CSR_WRITE_A;
      else if (controls_match(tr, BMU_REF_CSR_WRITE_B)) operation = BMU_REF_CSR_WRITE_B;
      else if (controls_match(tr, BMU_REF_OR))          operation = BMU_REF_OR;
      else if (controls_match(tr, BMU_REF_ORN))         operation = BMU_REF_ORN;
      else if (controls_match(tr, BMU_REF_XOR))         operation = BMU_REF_XOR;
      else if (controls_match(tr, BMU_REF_XNOR))        operation = BMU_REF_XNOR;
      else if (controls_match(tr, BMU_REF_SRL))         operation = BMU_REF_SRL;
      else if (controls_match(tr, BMU_REF_SRA))         operation = BMU_REF_SRA;
      else if (controls_match(tr, BMU_REF_ROR))         operation = BMU_REF_ROR;
      else if (controls_match(tr, BMU_REF_BINV))        operation = BMU_REF_BINV;
      else if (controls_match(tr, BMU_REF_SH2ADD))      operation = BMU_REF_SH2ADD;
      else if (controls_match(tr, BMU_REF_SUB))         operation = BMU_REF_SUB;
      else if (controls_match(tr, BMU_REF_SLT))         operation = BMU_REF_SLT;
      else if (controls_match(tr, BMU_REF_SLTU))        operation = BMU_REF_SLTU;
      else if (controls_match(tr, BMU_REF_CTZ))         operation = BMU_REF_CTZ;
      else if (controls_match(tr, BMU_REF_CPOP))        operation = BMU_REF_CPOP;
      else if (controls_match(tr, BMU_REF_SEXT_B))      operation = BMU_REF_SEXT_B;
      else if (controls_match(tr, BMU_REF_MAX_SIGNED))  operation = BMU_REF_MAX_SIGNED;
      else if (controls_match(tr, BMU_REF_PACK))        operation = BMU_REF_PACK;
      else if (controls_match(tr, BMU_REF_GREV_REV8))   operation = BMU_REF_GREV_REV8;
    end

    decode_operation = operation;
  endfunction


  // Build the legal ap packet for one operation and compare the whole packet.
  // Because expected_ap starts at zero, any unwanted ap field makes the match
  // fail automatically.
  function bit controls_match(
    input bmu_seq_item       tr,
    input bmu_ref_operation_e operation
  );
    rtl_pkg::rtl_alu_pkt_t expected_ap;
    bit                    supported_operation;
    bit                    match;

    expected_ap         = '0;
    supported_operation = 1'b1;
    match               = 1'b0;

    case (operation)
      BMU_REF_CSR_READ: begin
        match = tr.csr_ren_in && (tr.ap == '0);
      end

      BMU_REF_CSR_WRITE_A: begin
        expected_ap.csr_write = 1'b1;
      end

      BMU_REF_CSR_WRITE_B: begin
        expected_ap.csr_write = 1'b1;
        expected_ap.csr_imm   = 1'b1;
      end

      BMU_REF_OR: begin
        expected_ap.lor = 1'b1;
      end

      BMU_REF_ORN: begin
        expected_ap.lor = 1'b1;
        expected_ap.zbb = 1'b1;
      end

      BMU_REF_XOR: begin
        expected_ap.lxor = 1'b1;
      end

      BMU_REF_XNOR: begin
        expected_ap.lxor = 1'b1;
        expected_ap.zbb  = 1'b1;
      end

      BMU_REF_SRL: begin
        expected_ap.srl = 1'b1;
      end

      BMU_REF_SRA: begin
        expected_ap.sra = 1'b1;
      end

      BMU_REF_ROR: begin
        expected_ap.ror = 1'b1;
      end

      BMU_REF_BINV: begin
        expected_ap.binv = 1'b1;
      end

      BMU_REF_SH2ADD: begin
        expected_ap.sh2add = 1'b1;
        expected_ap.zba    = 1'b1;
      end

      BMU_REF_SUB: begin
        expected_ap.sub = 1'b1;
      end

      BMU_REF_SLT: begin
        expected_ap.slt = 1'b1;
        expected_ap.sub = 1'b1;
      end

      BMU_REF_SLTU: begin
        expected_ap.slt    = 1'b1;
        expected_ap.sub    = 1'b1;
        expected_ap.unsign = 1'b1;
      end

      BMU_REF_CTZ: begin
        expected_ap.ctz = 1'b1;
      end

      BMU_REF_CPOP: begin
        expected_ap.cpop = 1'b1;
      end

      BMU_REF_SEXT_B: begin
        expected_ap.siext_b = 1'b1;
      end

      BMU_REF_MAX_SIGNED: begin
        expected_ap.max = 1'b1;
        expected_ap.sub = 1'b1;
      end

      BMU_REF_PACK: begin
        expected_ap.pack = 1'b1;
      end

      BMU_REF_GREV_REV8: begin
        expected_ap.grev = 1'b1;
      end

      default: begin
        supported_operation = 1'b0;
      end
    endcase

    if ((operation != BMU_REF_CSR_READ) && supported_operation)
      match = !tr.csr_ren_in && (tr.ap == expected_ap);

    controls_match = match;
  endfunction


  // Primary controls whose invalid combinations are covered by this model.
  function bit approved_primary_control_selected(input bmu_seq_item tr);
    bit selected;

    selected = tr.csr_ren_in   ||
               tr.ap.csr_write ||
               tr.ap.lor       ||
               tr.ap.lxor      ||
               tr.ap.srl       ||
               tr.ap.sra       ||
               tr.ap.ror       ||
               tr.ap.binv      ||
               tr.ap.sh2add    ||
               tr.ap.sub       ||
               tr.ap.slt       ||
               tr.ap.ctz       ||
               tr.ap.cpop      ||
               tr.ap.siext_b   ||
               tr.ap.max       ||
               tr.ap.pack      ||
               tr.ap.grev;

    approved_primary_control_selected = selected;
  endfunction


  function logic [31:0] rotate_right_32(
    input logic [31:0] value,
    input logic [4:0]  amount
  );
    logic [31:0] result;

    if (amount == 5'd0)
      result = value;
    else
      result = (value >> amount) | (value << (32 - amount));

    rotate_right_32 = result;
  endfunction


  // CTZ(0) is 32, per the approved correction.
  function logic [31:0] count_trailing_zeros_32(input logic [31:0] value);
    logic [31:0] count;
    bit          found_one;
    integer      bit_index;

    count     = 32'd32;
    found_one = 1'b0;

    for (bit_index = 0; bit_index < 32; bit_index = bit_index + 1) begin
      if (!found_one && value[bit_index]) begin
        count     = bit_index;
        found_one = 1'b1;
      end
    end

    count_trailing_zeros_32 = count;
  endfunction


  function logic [31:0] population_count_32(input logic [31:0] value);
    logic [31:0] count;
    integer      bit_index;

    count = 32'd0;

    for (bit_index = 0; bit_index < 32; bit_index = bit_index + 1)
      count = count + value[bit_index];

    population_count_32 = count;
  endfunction


  function string operation_name(input bmu_ref_operation_e operation);
    string name;

    case (operation)
      BMU_REF_OR:          name = "OR";
      BMU_REF_ORN:         name = "ORN";
      BMU_REF_XOR:         name = "XOR";
      BMU_REF_XNOR:        name = "XNOR";
      BMU_REF_SRL:         name = "SRL";
      BMU_REF_SRA:         name = "SRA";
      BMU_REF_ROR:         name = "ROR";
      BMU_REF_BINV:        name = "BINV";
      BMU_REF_SH2ADD:      name = "SH2ADD";
      BMU_REF_SUB:         name = "SUB";
      BMU_REF_SLT:         name = "SLT";
      BMU_REF_SLTU:        name = "SLTU";
      BMU_REF_CTZ:         name = "CTZ";
      BMU_REF_CPOP:        name = "CPOP";
      BMU_REF_SEXT_B:      name = "SEXT.B";
      BMU_REF_MAX_SIGNED:  name = "MAX";
      BMU_REF_PACK:        name = "PACK";
      BMU_REF_GREV_REV8:   name = "GREV/REV8";
      BMU_REF_CSR_READ:    name = "CSR_READ";
      BMU_REF_CSR_WRITE_A: name = "CSR_WRITE_A";
      BMU_REF_CSR_WRITE_B: name = "CSR_WRITE_B";
      default:             name = "NONE_OR_INVALID";
    endcase

    operation_name = name;
  endfunction

  function bit no_operation_selected(input bmu_seq_item tr);
  return !$isunknown({tr.ap, tr.csr_ren_in}) &&
         (tr.ap == '0) &&
         (tr.csr_ren_in == 1'b0);
  endfunction

endclass
