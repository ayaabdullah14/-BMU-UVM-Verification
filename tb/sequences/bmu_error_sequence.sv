class bmu_error_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_error_sequence)

  bmu_seq_item req;

  logic [4:0] unsupported_modes[5];


  // ================================================================
  // Constructor
  // ================================================================
  function new(string name = "bmu_error_sequence");
    super.new(name);
  endfunction


  // ================================================================
  // Common request defaults
  // ================================================================
  function void set_defaults(bit valid_value = 1'b1);

    req.rst_l          = 1;
    req.scan_mode      = 0;
    req.valid_in       = valid_value;

    req.a_in           = 32'h12345678;
    req.b_in           = 32'h00000004;

    req.csr_ren_in     = 0;
    req.csr_rddata_in  = 32'h00000000;

    req.ap             = '0;

  endfunction


  // ================================================================
  // Operation name for clear log messages
  // ================================================================
  function string op_name(int op);

    case (op)

      0  : return "OR";
      1  : return "ORN";
      2  : return "XOR";
      3  : return "XNOR";
      4  : return "SRL";
      5  : return "SRA";
      6  : return "ROR";
      7  : return "BINV";
      8  : return "SH2ADD";
      9  : return "SUB";
      10 : return "SLT";
      11 : return "SLTU";
      12 : return "CTZ";
      13 : return "CPOP";
      14 : return "SEXT.B";
      15 : return "MAX";
      16 : return "PACK";
      17 : return "GREV";

      default : return "UNKNOWN";

    endcase

  endfunction


  // ================================================================
  // Build only the legal control recipe for each operation
  // ================================================================
  function void set_legal_operation(int op);

    req.ap = '0;

    case (op)

      // OR
      0: begin
        req.ap.lor = 1;
      end


      // ORN
      1: begin
        req.ap.lor = 1;
        req.ap.zbb = 1;
      end


      // XOR
      2: begin
        req.ap.lxor = 1;
      end


      // XNOR
      3: begin
        req.ap.lxor = 1;
        req.ap.zbb  = 1;
      end


      // SRL
      4: begin
        req.ap.srl = 1;
      end


      // SRA
      5: begin
        req.ap.sra = 1;
      end


      // ROR
      6: begin
        req.ap.ror = 1;
      end


      // BINV
      7: begin
        req.ap.binv = 1;
      end


      // SH2ADD
      8: begin
        req.ap.sh2add = 1;
        req.ap.zba    = 1;
      end


      // SUB
      9: begin
        req.ap.sub = 1;
      end


      // SLT
      10: begin
        req.ap.slt    = 1;
        req.ap.sub    = 1;
        req.ap.unsign = 0;
      end


      // SLTU
      11: begin
        req.ap.slt    = 1;
        req.ap.sub    = 1;
        req.ap.unsign = 1;
      end


      // CTZ
      12: begin
        req.ap.ctz = 1;
      end


      // CPOP
      13: begin
        req.ap.cpop = 1;
      end


      // SEXT.B
      14: begin
        req.ap.siext_b = 1;
      end


      // MAX
      15: begin
        req.ap.max    = 1;
        req.ap.sub    = 1;
        req.ap.unsign = 0;
      end


      // PACK
      16: begin
        req.ap.pack = 1;
      end


      // GREV / REV8
      17: begin
        req.b_in    = 32'h00000018;
        req.ap.grev = 1;
      end

    endcase

  endfunction


  // ================================================================
  // Print scenario ID and important controls
  // ================================================================
  function void log_case(
    string case_id,
    string description
  );

    `uvm_info(
      get_type_name(),
      $sformatf(
        "[%s] %s | rst_l=%0b valid=%0b csr_ren=%0b ap=0x%0h B[4:0]=%0d",
        case_id,
        description,
        req.rst_l,
        req.valid_in,
        req.csr_ren_in,
        req.ap,
        req.b_in[4:0]
      ),
      UVM_LOW
    )

  endfunction



  // ================================================================
  // Main sequence
  // ================================================================
  task body();


    req = bmu_seq_item::type_id::create("req");


    unsupported_modes[0] = 5'd0;
    unsupported_modes[1] = 5'd1;
    unsupported_modes[2] = 5'd23;
    unsupported_modes[3] = 5'd25;
    unsupported_modes[4] = 5'd31;



    // ================================================================
    // NEG-01
    // Generic forbidden AP-field conflicts
    //
    // Objective:
    // For every documented operation except GREV:
    //   1. Start from its legal control recipe.
    //   2. Add exactly ONE unrelated AP field.
    //
    // GREV is excluded because its forbidden AP-field case
    // is verified separately in NEG-05.
    //
    // Expected:
    //   error = 1
    //   result_ff = 0 at N+1
    // ================================================================

    `uvm_info(
      get_type_name(),
      "[NEG-01] Generic forbidden AP-field conflicts",
      UVM_LOW
    )


    // Operations 0..16 only.
    // GREV = operation 17 and is handled by NEG-05.
    for (int op = 0; op < 17; op++) begin

      start_item(req);

      set_defaults(1'b1);
      set_legal_operation(op);


      // Add exactly one unrelated AP field.
      //
      // For CPOP itself, use LOR because CPOP cannot
      // be used as its own forbidden extra field.
      if (op == 13)
        req.ap.lor = 1;
      else
        req.ap.cpop = 1;


      if (op == 13) begin

        log_case(
          $sformatf("NEG-01.%02d", op),
          $sformatf(
            "%s legal recipe + one forbidden LOR field; expected error=1",
            op_name(op)
          )
        );

      end
      else begin

        log_case(
          $sformatf("NEG-01.%02d", op),
          $sformatf(
            "%s legal recipe + one forbidden CPOP field; expected error=1",
            op_name(op)
          )
        );

      end


      finish_item(req);

    end



    // ================================================================
    // NEG-02
    // CSR conflict
    //
    // Objective:
    // Apply each complete legal functional-operation recipe,
    // then change only csr_ren_in from 0 to 1.
    //
    // GREV is included here because GREV + CSR conflict belongs
    // to this scenario and is not repeated in NEG-05.
    //
    // Expected:
    //   error = 1
    //   result_ff = 0 at N+1
    // ================================================================

    `uvm_info(
      get_type_name(),
      "[NEG-02] CSR conflicts with documented operations",
      UVM_LOW
    )


    for (int op = 0; op < 18; op++) begin

      start_item(req);

      set_defaults(1'b1);
      set_legal_operation(op);

      req.csr_ren_in     = 1;
      req.csr_rddata_in  = 32'hCAFEBABE;

      log_case(
        $sformatf("NEG-02.%02d", op),
        $sformatf(
          "%s legal recipe + csr_ren_in=1; expected error=1",
          op_name(op)
        )
      );

      finish_item(req);

    end



    // ================================================================
    // NEG-03
    // Required qualifier: SH2ADD requires ZBA
    //
    // Objective:
    // Compare legal SH2ADD with SH2ADD missing its required ZBA.
    //
    // Expected:
    //   Legal    -> error = 0
    //   Missing ZBA -> error = 1
    // ================================================================

    `uvm_info(
      get_type_name(),
      "[NEG-03] SH2ADD required ZBA qualifier",
      UVM_LOW
    )


    // ------------------------------------------------
    // Legal baseline
    // ------------------------------------------------

    start_item(req);

    set_defaults(1'b1);

    req.a_in       = 32'h00000010;
    req.b_in       = 32'h00000003;

    req.ap.sh2add  = 1;
    req.ap.zba     = 1;

    log_case(
      "NEG-03.BASE",
      "Legal SH2ADD: sh2add=1 zba=1; expected error=0"
    );

    finish_item(req);


    // ------------------------------------------------
    // Illegal: SH2ADD without ZBA
    // ------------------------------------------------

    start_item(req);

    set_defaults(1'b1);

    req.a_in       = 32'h00000010;
    req.b_in       = 32'h00000003;

    req.ap.sh2add  = 1;
    req.ap.zba     = 0;

    log_case(
      "NEG-03.INVALID",
      "SH2ADD missing required ZBA; expected error=1"
    );

    finish_item(req);



    // ================================================================
    // NEG-04
    // Forbidden qualifier: SUB must have ZBA = 0
    //
    // Objective:
    // Compare legal SUB with illegal SUB + ZBA.
    //
    // Expected:
    //   SUB + ZBA=0 -> error = 0
    //   SUB + ZBA=1 -> error = 1
    // ================================================================

    `uvm_info(
      get_type_name(),
      "[NEG-04] SUB forbidden ZBA qualifier",
      UVM_LOW
    )


    // ------------------------------------------------
    // Legal baseline
    // ------------------------------------------------

    start_item(req);

    set_defaults(1'b1);

    req.a_in     = 32'h00000020;
    req.b_in     = 32'h00000005;

    req.ap.sub   = 1;
    req.ap.zba   = 0;

    log_case(
      "NEG-04.BASE",
      "Legal SUB: sub=1 zba=0; expected error=0"
    );

    finish_item(req);


    // ------------------------------------------------
    // Illegal SUB + ZBA
    // ------------------------------------------------

    start_item(req);

    set_defaults(1'b1);

    req.a_in     = 32'h00000020;
    req.b_in     = 32'h00000005;

    req.ap.sub   = 1;
    req.ap.zba   = 1;

    log_case(
      "NEG-04.INVALID",
      "SUB + forbidden ZBA=1; expected error=1"
    );

    finish_item(req);



    // ================================================================
    // NEG-05
    // GREV forbidden AP-field conflict
    //
    // Objective:
    // Verify that the legal GREV/REV8 recipe becomes invalid
    // when exactly ONE unrelated AP field is asserted.
    //
    // GREV functional result checking belongs to bmu_grev_test.
    // GREV + CSR conflict already belongs to NEG-02.
    //
    // Expected:
    //   error = 1
    //   result_ff = 0 at N+1
    // ================================================================

    `uvm_info(
      get_type_name(),
      "[NEG-05] GREV forbidden AP-field conflict",
      UVM_LOW
    )


    start_item(req);

    set_defaults(1'b1);

    req.a_in          = 32'h12345678;
    req.b_in          = 32'h00000018;   // REV8 mode = 24

    req.csr_ren_in    = 0;
    req.csr_rddata_in = 0;

    req.ap            = '0;

    // Legal GREV recipe
    req.ap.grev       = 1;

    // Exactly one unrelated forbidden AP field
    req.ap.cpop       = 1;

    log_case(
      "NEG-05",
      "GREV/REV8 legal recipe + one forbidden CPOP field; expected error=1"
    );

    finish_item(req);



    // ================================================================
    // NEG-06
    // Unsupported GREV modes
    //
    // Objective:
    // Verify that unsupported GREV mode values alone are NOT
    // treated as illegal-control conflicts.
    //
    // Expected:
    //
    // valid_in = 1:
    //   error = 0
    //   result_ff = 0 at N+1
    //
    // valid_in = 0:
    //   error = 0
    //   result_ff holds its previous value
    // ================================================================

    `uvm_info(
      get_type_name(),
      "[NEG-06] GREV unsupported modes",
      UVM_LOW
    )


    // ------------------------------------------------
    // Unsupported modes with valid_in = 1
    // ------------------------------------------------

    for (int i = 0; i < 5; i++) begin

      start_item(req);

      set_defaults(1'b1);

      req.a_in     = 32'h12345678;
      req.b_in     = {27'h0, unsupported_modes[i]};

      req.ap.grev  = 1;

      log_case(
        $sformatf(
          "NEG-06.MODE%0d",
          unsupported_modes[i]
        ),
        $sformatf(
          "Unsupported GREV mode %0d; expected result=0 error=0",
          unsupported_modes[i]
        )
      );

      finish_item(req);

    end


    // ------------------------------------------------
    // Setup known nonzero registered result
    // ------------------------------------------------

    start_item(req);

    set_defaults(1'b1);

    req.a_in           = 32'h11111111;
    req.b_in           = 32'h22222222;

    req.csr_ren_in     = 1;
    req.csr_rddata_in  = 32'hDEADBEEF;

    req.ap             = '0;

    log_case(
      "NEG-06.SETUP",
      "Legal CSR read setup; expected registered result DEADBEEF"
    );

    finish_item(req);


    // ------------------------------------------------
    // Unsupported GREV while valid_in = 0
    // ------------------------------------------------

    start_item(req);

    set_defaults(1'b0);

    req.a_in      = 32'h12345678;
    req.b_in      = 32'h00000019;   // Unsupported mode 25

    req.ap.grev   = 1;

    log_case(
      "NEG-06.HOLD",
      "Unsupported GREV mode 25 with valid=0; expected result hold and error=0"
    );

    finish_item(req);



    // ================================================================
    // NEG-07
    // Error / valid interaction
    //
    // Objective:
    // Verify that error detection does NOT depend on valid_in.
    //
    // Use SUB + ZBA because NEG-04 independently proves that this
    // control combination is a valid error source.
    //
    // This avoids using the generic forbidden-field bug as the
    // error source for this scenario.
    //
    // Expected during conflict:
    //   valid_in = 0
    //   error = 1
    //   result_ff holds previous legal value
    // ================================================================

    `uvm_info(
      get_type_name(),
      "[NEG-07] Error remains active when valid_in=0",
      UVM_LOW
    )


    // ------------------------------------------------
    // Setup known legal nonzero result
    // ------------------------------------------------

    start_item(req);

    set_defaults(1'b1);

    req.a_in           = 32'hAAAAAAAA;
    req.b_in           = 32'h55555555;

    req.csr_ren_in     = 1;
    req.csr_rddata_in  = 32'h11223344;

    req.ap             = '0;

    log_case(
      "NEG-07.SETUP",
      "Legal CSR read; setup result_ff=11223344"
    );

    finish_item(req);


    // ------------------------------------------------
    // Known conflict with valid_in = 0
    // ------------------------------------------------

    start_item(req);

    set_defaults(1'b0);

    req.a_in      = 32'h00000020;
    req.b_in      = 32'h00000005;

    req.ap.sub    = 1;
    req.ap.zba    = 1;

    log_case(
      "NEG-07.INVALID0",
      "Known SUB+ZBA conflict with valid=0; expected error=1 and result hold"
    );

    finish_item(req);


    // ------------------------------------------------
    // Legal recovery
    // ------------------------------------------------

    start_item(req);

    set_defaults(1'b1);

    req.a_in           = 32'hAAAAAAAA;
    req.b_in           = 32'h55555555;

    req.csr_ren_in     = 1;
    req.csr_rddata_in  = 32'h55667788;

    req.ap             = '0;

    log_case(
      "NEG-07.RECOVERY",
      "Legal request after conflict; expected result=55667788"
    );

    finish_item(req);



    // ================================================================
    // NEG-08
    // Reset priority over an active known error
    //
    // Objective:
    // First prove that SUB + ZBA produces an active error.
    // Then keep EXACTLY the same conflict and change only rst_l.
    //
    // Expected:
    //
    // Before reset:
    //   error = 1
    //
    // During synchronous reset:
    //   error = 0
    //   result_ff = 0
    // ================================================================

    `uvm_info(
      get_type_name(),
      "[NEG-08] Reset overrides a known active error",
      UVM_LOW
    )


    // ------------------------------------------------
    // Active known conflict, no reset
    // ------------------------------------------------

    start_item(req);

    set_defaults(1'b1);

    req.a_in      = 32'h00000020;
    req.b_in      = 32'h00000005;

    req.ap.sub    = 1;
    req.ap.zba    = 1;

    log_case(
      "NEG-08.ACTIVE",
      "Known SUB+ZBA conflict before reset; expected error=1"
    );

    finish_item(req);


    // ------------------------------------------------
    // Same conflict + synchronous reset
    // ------------------------------------------------

    start_item(req);

    set_defaults(1'b1);

    // Only reset changes relative to the previous request.
    req.rst_l     = 0;

    req.a_in      = 32'h00000020;
    req.b_in      = 32'h00000005;

    req.ap.sub    = 1;
    req.ap.zba    = 1;

    log_case(
      "NEG-08.RESET",
      "Same SUB+ZBA conflict with rst_l=0; expected error=0 result_ff=0"
    );

    finish_item(req);



    // ================================================================
    // Final idle cycles
    //
    // Allow the final registered result/check to be observed cleanly.
    // ================================================================

    `uvm_info(
      get_type_name(),
      "[NEG-IDLE] Final idle cycles",
      UVM_LOW
    )


    repeat (2) begin

      start_item(req);

      set_defaults(1'b0);

      req.a_in = 0;
      req.b_in = 0;
      req.ap   = '0;

      finish_item(req);

    end


  endtask : body


endclass : bmu_error_sequence