/*This test does not compare against the DUT. It checks the reference model
against manually calculated expected values before the model is used by the
scoreboard.*/

class bmu_reference_model_unit_test extends uvm_test;
  `uvm_component_utils(bmu_reference_model_unit_test)

  bmu_reference_model model;
  bmu_seq_item      tr;

  int unsigned pass_count;
  int unsigned fail_count;


  function new(
    string        name   = "bmu_reference_model_unit_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    model = bmu_reference_model::type_id::create("model");
    tr    = bmu_seq_item::type_id::create("tr");
  endfunction


  // Return the transaction to a known legal idle state before every vector.
  task clear_transaction();
    tr.rst_l        = 1'b1;
    tr.scan_mode    = 1'b0; //by defult 
    tr.valid_in     = 1'b1;
    tr.ap           = '0;
    tr.csr_ren_in   = 1'b0;
    tr.csr_rddata_in = 32'h0000_0000;
    tr.a_in         = 32'h0000_0000;
    tr.b_in         = 32'h0000_0000;
    tr.result_ff    = 32'h0000_0000;
    tr.error        = 1'b0;
  endtask


  task check_vector(
    input string       vector_name,
    input logic [31:0] expected_result,
    input logic        expected_error
  );
    logic [31:0] actual_result;
    logic        actual_error;

    model.predict(tr, actual_result, actual_error);

    if ((actual_result === expected_result) &&
        (actual_error  === expected_error)) begin
      pass_count++;

      `uvm_info(
        "RM_GOLDEN_PASS",
        $sformatf(
          "%s PASS: result=0x%08h error=%0b",
          vector_name,
          actual_result,
          actual_error
        ),
        UVM_LOW
      )
    end
    else begin
      fail_count++;

      `uvm_error(
        "RM_GOLDEN_FAIL",
        $sformatf(
          "%s FAIL: expected result=0x%08h error=%0b, got result=0x%08h error=%0b",
          vector_name,
          expected_result,
          expected_error,
          actual_result,
          actual_error
        )
      )
    end
  endtask

  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    pass_count = 0;
    fail_count = 0;

    //----------------------- 18 approved operations--------------------

    // 1. OR
    clear_transaction();
    tr.a_in  = 32'hF0F0_0000;
    tr.b_in  = 32'h0F0F_0000;
    tr.ap.lor = 1'b1;
    check_vector("OR", 32'hFFFF_0000, 1'b0);

    // 2. ORN
    clear_transaction();
    tr.a_in   = 32'h0000_FFFF;
    tr.b_in   = 32'hFFFF_0000;
    tr.ap.lor = 1'b1;
    tr.ap.zbb = 1'b1;
    check_vector("ORN", 32'h0000_FFFF, 1'b0);

    // 3. XOR
    clear_transaction();
    tr.a_in    = 32'hFF00_FF00;
    tr.b_in    = 32'h0F0F_0F0F;
    tr.ap.lxor = 1'b1;
    check_vector("XOR", 32'hF00F_F00F, 1'b0);

    // 4. XNOR
    clear_transaction();
    tr.a_in    = 32'hFF00_FF00;
    tr.b_in    = 32'h0F0F_0F0F;
    tr.ap.lxor = 1'b1;
    tr.ap.zbb  = 1'b1;
    check_vector("XNOR", 32'h0FF0_0FF0, 1'b0);

    // 5. SRL
    clear_transaction();
    tr.a_in   = 32'h8000_0000;
    tr.b_in   = 32'd4;
    tr.ap.srl = 1'b1;
    check_vector("SRL", 32'h0800_0000, 1'b0);

    // 6. SRA
    clear_transaction();
    tr.a_in   = 32'h8000_0000;
    tr.b_in   = 32'd4;
    tr.ap.sra = 1'b1;
    check_vector("SRA", 32'hF800_0000, 1'b0);

    // 7. ROR
    clear_transaction();
    tr.a_in   = 32'h8000_0001;
    tr.b_in   = 32'd1;
    tr.ap.ror = 1'b1;
    check_vector("ROR", 32'hC000_0000, 1'b0);

    // 8. BINV: toggle bit 5
    clear_transaction();
    tr.a_in    = 32'h0000_0000;
    tr.b_in    = 32'd5;
    tr.ap.binv = 1'b1;
    check_vector("BINV", 32'h0000_0020, 1'b0);

    // 9. SH2ADD: (3 << 2) + 5 = 17
    clear_transaction();
    tr.a_in      = 32'd3;
    tr.b_in      = 32'd5;
    tr.ap.sh2add = 1'b1;
    tr.ap.zba    = 1'b1;
    check_vector("SH2ADD", 32'h0000_0011, 1'b0);

    // 10. SUB
    clear_transaction();
    tr.a_in   = 32'd10;
    tr.b_in   = 32'd3;
    tr.ap.sub = 1'b1;
    check_vector("SUB", 32'h0000_0007, 1'b0);

    // 11. Signed SLT: -1 < 1
    clear_transaction();
    tr.a_in   = 32'hFFFF_FFFF;
    tr.b_in   = 32'h0000_0001;
    tr.ap.slt = 1'b1;
    tr.ap.sub = 1'b1;
    check_vector("SLT_SIGNED", 32'h0000_0001, 1'b0);

    // 12. Unsigned SLTU: 1 < 0xFFFFFFFF
    clear_transaction();
    tr.a_in      = 32'h0000_0001;
    tr.b_in      = 32'hFFFF_FFFF;
    tr.ap.slt    = 1'b1;
    tr.ap.sub    = 1'b1;
    tr.ap.unsign = 1'b1;
    check_vector("SLTU", 32'h0000_0001, 1'b0);

    // 13. CTZ(8) = 3
    clear_transaction();
    tr.a_in   = 32'h0000_0008;
    tr.ap.ctz = 1'b1;
    check_vector("CTZ", 32'd3, 1'b0);

    // 14. CPOP(0xFFFF0000) = 16
    clear_transaction();
    tr.a_in    = 32'hFFFF_0000;
    tr.ap.cpop = 1'b1;
    check_vector("CPOP", 32'd16, 1'b0);

    // 15. SEXT.B(0x80) = 0xFFFFFF80
    clear_transaction();
    tr.a_in       = 32'h0000_0080;
    tr.ap.siext_b = 1'b1;
    check_vector("SEXT_B", 32'hFFFF_FF80, 1'b0);

    // 16. Signed MAX(-5, 3) = 3
    clear_transaction();
    tr.a_in   = 32'hFFFF_FFFB;
    tr.b_in   = 32'h0000_0003;
    tr.ap.max = 1'b1;
    tr.ap.sub = 1'b1;
    check_vector("MAX_SIGNED", 32'h0000_0003, 1'b0);

    // 17. PACK
    clear_transaction();
    tr.a_in    = 32'hAAAA_1234;
    tr.b_in    = 32'hBBBB_5678;
    tr.ap.pack = 1'b1;
    check_vector("PACK", 32'h5678_1234, 1'b0);

    // 18. GREV/REV8
    clear_transaction();
    tr.a_in    = 32'h1234_5678;
    tr.b_in    = 32'd24;
    tr.ap.grev = 1'b1;
    check_vector("GREV_REV8", 32'h7856_3412, 1'b0);

    // -------------------------------------------------------------------------
    // 3 CSR modes
    // -------------------------------------------------------------------------

    // 19. CSR bypass read
    clear_transaction();
    tr.csr_ren_in    = 1'b1;
    tr.csr_rddata_in = 32'hABCD_1234;
    check_vector("CSR_READ", 32'hABCD_1234, 1'b0);

    // 20. CSR write data from a_in
    clear_transaction();
    tr.a_in         = 32'h1357_9BDF;
    tr.ap.csr_write = 1'b1;
    check_vector("CSR_WRITE_A", 32'h1357_9BDF, 1'b0);

    // 21. CSR write data from b_in when csr_imm is set
    clear_transaction();
    tr.b_in         = 32'h2468_ACE0;
    tr.ap.csr_write = 1'b1;
    tr.ap.csr_imm   = 1'b1;
    check_vector("CSR_WRITE_B", 32'h2468_ACE0, 1'b0);

    // ----------------------Critical edge and control cases-----------------------------------

    // 22. Approved correction: CTZ(0) = 32
    clear_transaction();
    tr.a_in   = 32'h0000_0000;
    tr.ap.ctz = 1'b1;
    check_vector("CTZ_ZERO", 32'd32, 1'b0);

    // 23. Rotate by zero returns the original value
    clear_transaction();
    tr.a_in   = 32'h89AB_CDEF;
    tr.b_in   = 32'd0;
    tr.ap.ror = 1'b1;
    check_vector("ROR_ZERO", 32'h89AB_CDEF, 1'b0);

    // 24. GREV mode other than REV8: documented subset returns zero/no error
    clear_transaction();
    tr.a_in    = 32'h1234_5678;
    tr.b_in    = 32'd7;
    tr.ap.grev = 1'b1;
    check_vector("GREV_UNSUPPORTED_MODE", 32'h0000_0000, 1'b0);

    // 25. Two primary operations are illegal
    clear_transaction();
    tr.a_in    = 32'h1234_5678;
    tr.b_in    = 32'd4;
    tr.ap.lor  = 1'b1;
    tr.ap.srl  = 1'b1;
    check_vector("INVALID_OR_AND_SRL", 32'h0000_0000, 1'b1);

    // 26. CSR read conflicts with any asserted ap field
    clear_transaction();
    tr.csr_ren_in = 1'b1;
    tr.ap.lor     = 1'b1;
    check_vector("INVALID_CSR_READ_AND_OR", 32'h0000_0000, 1'b1);

    // 27. SH2ADD without zba is illegal
    clear_transaction();
    tr.a_in      = 32'd3;
    tr.b_in      = 32'd5;
    tr.ap.sh2add = 1'b1;
    check_vector("INVALID_SH2ADD_WITHOUT_ZBA", 32'h0000_0000, 1'b1);

    // 28. SUB with zba is illegal
    clear_transaction();
    tr.a_in   = 32'd10;
    tr.b_in   = 32'd3;
    tr.ap.sub = 1'b1;
    tr.ap.zba = 1'b1;
    check_vector("INVALID_SUB_WITH_ZBA", 32'h0000_0000, 1'b1);

    // 29. error remains combinational even when valid_in is zero
    clear_transaction();
    tr.valid_in = 1'b0;
    tr.ap.lor   = 1'b1;
    tr.ap.srl   = 1'b1;
    check_vector("ERROR_INDEPENDENT_OF_VALID", 32'h0000_0000, 1'b1);

    // 30. Reset overrides controls and clears both predictions
    clear_transaction();
    tr.rst_l  = 1'b0;
    tr.ap.lor = 1'b1;
    tr.ap.srl = 1'b1;
    check_vector("RESET", 32'h0000_0000, 1'b0);

    `uvm_info(
      "RM_GOLDEN_SUMMARY",
      $sformatf(
        "Reference-model golden test completed: PASS=%0d FAIL=%0d TOTAL=%0d",
        pass_count,
        fail_count,
        pass_count + fail_count
      ),
      UVM_NONE
    )
    //31. (NOP )  valid_in=1 with no selected operation is a legal NOP.
    clear_transaction();
    tr.valid_in   = 1'b1;
    tr.ap         = '0;
    tr.csr_ren_in = 1'b0;

check_vector(  "NO_OPERATION_NOP", 32'h0000_0000,  1'b0);

    if (fail_count != 0) begin
      `uvm_fatal("RM_GOLDEN_FAILED",
        $sformatf("Reference model is not approved: %0d vector(s) failed", fail_count)) 
    end

    phase.drop_objection(this);
  endtask
  
endclass

