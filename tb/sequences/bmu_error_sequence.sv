class bmu_error_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_error_sequence)

  function new(string name = "bmu_error_sequence");
    super.new(name);
  endfunction


  task body();

    bmu_seq_item req;

    logic [4:0] unsupported_modes[5] = '{
      5'd0,
      5'd1,
      5'd23,
      5'd25,
      5'd31
    };


    req = bmu_seq_item::type_id::create("req");


    // -------------------- NEG-01 Single forbidden AP-field conflicts --------------------

    // Each documented operation is configured using its legal control recipe.
    // One unrelated AP field is then added to make the request invalid.
    // The forbidden fields are distributed across the operations without
    // creating a full operation-by-field cross.

    `uvm_info(
      get_type_name(),
      "[NEG-01] Single forbidden AP-field conflicts",
      UVM_LOW
    )


    for (int op = 0; op < 18; op++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = 32'h12345678;
      req.b_in = 32'h00000004;

      req.ap = 0;


      case (op)

        // OR + forbidden LXOR
        0: begin
          req.ap.lor  = 1;
          req.ap.lxor = 1;
        end

        // ORN + forbidden SRL
        1: begin
          req.ap.lor = 1;
          req.ap.zbb = 1;
          req.ap.srl = 1;
        end

        // XOR + forbidden SRA
        2: begin
          req.ap.lxor = 1;
          req.ap.sra  = 1;
        end

        // XNOR + forbidden ROR
        3: begin
          req.ap.lxor = 1;
          req.ap.zbb  = 1;
          req.ap.ror  = 1;
        end

        // SRL + forbidden BINV
        4: begin
          req.ap.srl  = 1;
          req.ap.binv = 1;
        end

        // SRA + forbidden SH2ADD
        5: begin
          req.ap.sra    = 1;
          req.ap.sh2add = 1;
        end

        // ROR + forbidden SUB
        6: begin
          req.ap.ror = 1;
          req.ap.sub = 1;
        end

        // BINV + forbidden SLT
        7: begin
          req.ap.binv = 1;
          req.ap.slt  = 1;
        end

        // SH2ADD legal recipe + forbidden CTZ
        8: begin
          req.ap.sh2add = 1;
          req.ap.zba    = 1;
          req.ap.ctz    = 1;
        end

        // SUB + forbidden CPOP
        9: begin
          req.ap.sub  = 1;
          req.ap.cpop = 1;
        end

        // SLT legal recipe + forbidden SEXT.B
        10: begin
          req.ap.slt     = 1;
          req.ap.sub     = 1;
          req.ap.unsign  = 0;
          req.ap.siext_b = 1;
        end

        // SLTU legal recipe + forbidden MAX
        11: begin
          req.ap.slt    = 1;
          req.ap.sub    = 1;
          req.ap.unsign = 1;
          req.ap.max    = 1;
        end

        // CTZ + forbidden PACK
        12: begin
          req.ap.ctz  = 1;
          req.ap.pack = 1;
        end

        // CPOP + forbidden GREV
        13: begin
          req.ap.cpop = 1;
          req.ap.grev = 1;
        end

        // SEXT.B + forbidden OR
        14: begin
          req.ap.siext_b = 1;
          req.ap.lor     = 1;
        end

        // MAX legal recipe + forbidden ZBB qualifier
        15: begin
          req.ap.max = 1;
          req.ap.sub = 1;
          req.ap.zbb = 1;
        end

        // PACK + forbidden ZBA qualifier
        16: begin
          req.ap.pack = 1;
          req.ap.zba  = 1;
        end

        // GREV legal mode + forbidden UNSIGN qualifier
        17: begin
          req.b_in     = 32'h00000018;
          req.ap.grev  = 1;
          req.ap.unsign = 1;
        end

      endcase


      finish_item(req);

    end


    // -------------------- NEG-02 CSR conflicts --------------------

    // Each documented operation is first configured legally.
    // csr_ren_in is then asserted as the only external conflict.

    `uvm_info(
      get_type_name(),
      "[NEG-02] CSR conflicts with documented operations",
      UVM_LOW
    )


    for (int op = 0; op < 18; op++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 1;
      req.csr_rddata_in = 32'hCAFEBABE;

      req.a_in = 32'h12345678;
      req.b_in = 32'h00000004;

      req.ap = 0;


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


      finish_item(req);

    end


    // -------------------- NEG-03 SH2ADD required ZBA qualifier --------------------

    `uvm_info(
      get_type_name(),
      "[NEG-03] SH2ADD required ZBA qualifier",
      UVM_LOW
    )


    // Legal SH2ADD

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00000010;
    req.b_in = 32'h00000003;

    req.ap = 0;
    req.ap.sh2add = 1;
    req.ap.zba = 1;

    finish_item(req);


    // SH2ADD without required ZBA

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00000010;
    req.b_in = 32'h00000003;

    req.ap = 0;
    req.ap.sh2add = 1;
    req.ap.zba = 0;

    finish_item(req);


    // -------------------- NEG-04 SUB forbidden ZBA qualifier --------------------

    `uvm_info(
      get_type_name(),
      "[NEG-04] SUB forbidden ZBA qualifier",
      UVM_LOW
    )


    // Legal SUB

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00000020;
    req.b_in = 32'h00000005;

    req.ap = 0;
    req.ap.sub = 1;
    req.ap.zba = 0;

    finish_item(req);


    // SUB with forbidden ZBA

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00000020;
    req.b_in = 32'h00000005;

    req.ap = 0;
    req.ap.sub = 1;
    req.ap.zba = 1;

    finish_item(req);


    // -------------------- NEG-06 Unsupported GREV modes --------------------

    // Unsupported GREV modes are not control conflicts.
    // They must produce error=0.

    `uvm_info(
      get_type_name(),
      "[NEG-06] GREV unsupported modes",
      UVM_LOW
    )


    for (int i = 0; i < 5; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = 32'h12345678;
      req.b_in = {27'h0, unsupported_modes[i]};

      req.ap = 0;
      req.ap.grev = 1;

      finish_item(req);

    end


    // Register a known nonzero result before checking valid_in=0.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'hDEADBEEF;

    req.a_in = 32'h11111111;
    req.b_in = 32'h22222222;

    req.ap = 0;

    finish_item(req);


    // Unsupported GREV mode with valid_in=0.
    // result_ff must hold DEADBEEF and error must remain zero.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 0;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h12345678;
    req.b_in = 32'h00000019;

    req.ap = 0;
    req.ap.grev = 1;

    finish_item(req);


    // -------------------- NEG-07 Error is independent of valid_in --------------------

    `uvm_info(
      get_type_name(),
      "[NEG-07] Error remains active when valid_in=0",
      UVM_LOW
    )


    // Register a known legal result.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'h11223344;

    req.a_in = 32'hAAAAAAAA;
    req.b_in = 32'h55555555;

    req.ap = 0;

    finish_item(req);


    // Known SUB + ZBA conflict with valid_in=0.
    // error must be one while result_ff holds its previous value.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 0;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00000020;
    req.b_in = 32'h00000005;

    req.ap = 0;
    req.ap.sub = 1;
    req.ap.zba = 1;

    finish_item(req);


    // Legal request after the conflict.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'h55667788;

    req.a_in = 32'hAAAAAAAA;
    req.b_in = 32'h55555555;

    req.ap = 0;

    finish_item(req);


    // -------------------- NEG-08 Reset overrides an active error --------------------

    `uvm_info(
      get_type_name(),
      "[NEG-08] Reset overrides a known active error",
      UVM_LOW
    )


    // Active SUB + ZBA conflict before reset.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00000020;
    req.b_in = 32'h00000005;

    req.ap = 0;
    req.ap.sub = 1;
    req.ap.zba = 1;

    finish_item(req);


    // Keep the same conflict active and apply synchronous reset.

    start_item(req);

    req.rst_l = 0;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00000020;
    req.b_in = 32'h00000005;

    req.ap = 0;
    req.ap.sub = 1;
    req.ap.zba = 1;

    finish_item(req);


    // -------------------- Final idle cycles --------------------

    `uvm_info(
      get_type_name(),
      "[NEG-IDLE] Final idle cycles",
      UVM_LOW
    )


    repeat (2) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 0;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = 32'h00000000;
      req.b_in = 32'h00000000;

      req.ap = 0;

      finish_item(req);

    end


  endtask: body

endclass: bmu_error_sequence
