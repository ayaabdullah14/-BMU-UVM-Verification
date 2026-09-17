class bmu_error_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_error_sequence)

  function new(string name = "bmu_error_sequence");
    super.new(name);
  endfunction


  task body();

    bmu_seq_item req;

    logic [4:0] unsupported_modes[5];

    req = bmu_seq_item::type_id::create("req");

    unsupported_modes[0] = 5'd0;
    unsupported_modes[1] = 5'd1;
    unsupported_modes[2] = 5'd23;
    unsupported_modes[3] = 5'd25;
    unsupported_modes[4] = 5'd31;



    // --------------------NEG-01:Single forbidden ap-field conflict-------------------------------
    
    /* For every documented functional operation:
       - start from its legal control recipe
       - add ONE unrelated ap field
       - csr_ren_in = 0
       - valid_in = 1  */
   
    // Expected:  error = 1  result_ff = 0
   
    `uvm_info(
      get_type_name(),
      "[NEG-01] Single forbidden ap-field conflicts",
      UVM_LOW
    )


    for (int op = 0; op < 18; op++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.a_in = 32'h12345678;
      req.b_in = 32'h00000004;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.ap = 0;


      case (op)

        // OR + illegal LXOR
        0: begin
          req.ap.lor  = 1;
          req.ap.lxor = 1;
        end

        // ORN + illegal SRL
        1: begin
          req.ap.lor = 1;
          req.ap.zbb = 1;
          req.ap.srl = 1;
        end

        // XOR + illegal SRA
        2: begin
          req.ap.lxor = 1;
          req.ap.sra  = 1;
        end

        // XNOR + illegal ROR
        3: begin
          req.ap.lxor = 1;
          req.ap.zbb  = 1;
          req.ap.ror  = 1;
        end

        // SRL + illegal BINV
        4: begin
          req.ap.srl  = 1;
          req.ap.binv = 1;
        end

        // SRA + illegal SH2ADD
        5: begin
          req.ap.sra    = 1;
          req.ap.sh2add = 1;
        end

        // ROR + illegal SUB
        6: begin
          req.ap.ror = 1;
          req.ap.sub = 1;
        end

        // BINV + illegal SLT
        7: begin
          req.ap.binv = 1;
          req.ap.slt  = 1;
        end

        // SH2ADD legal qualifier + illegal CTZ
        8: begin
          req.ap.sh2add = 1;
          req.ap.zba    = 1;
          req.ap.ctz    = 1;
        end

        // SUB + illegal CPOP
        9: begin
          req.ap.sub  = 1;
          req.ap.cpop = 1;
        end

        // SLT + illegal SEXT.B
        10: begin
          req.ap.slt     = 1;
          req.ap.sub     = 1;
          req.ap.unsign  = 0;
          req.ap.siext_b = 1;
        end

        // SLTU + illegal MAX
        11: begin
          req.ap.slt    = 1;
          req.ap.sub    = 1;
          req.ap.unsign = 1;
          req.ap.max    = 1;
        end

        // CTZ + illegal PACK
        12: begin
          req.ap.ctz  = 1;
          req.ap.pack = 1;
        end

        // CPOP + illegal GREV
        13: begin
          req.ap.cpop = 1;
          req.ap.grev = 1;
        end

        // SEXT.B + illegal OR
        14: begin
          req.ap.siext_b = 1;
          req.ap.lor     = 1;
        end

        // MAX + illegal XOR
        15: begin
          req.ap.max  = 1;
          req.ap.sub  = 1;
          req.ap.lxor = 1;
        end

        // PACK + illegal CSR write
        16: begin
          req.ap.pack      = 1;
          req.ap.csr_write = 1;
        end

        // GREV + illegal CPOP
        17: begin
          req.b_in = 32'h00000018;
          req.ap.grev = 1;
          req.ap.cpop = 1;
        end

      endcase


      finish_item(req);

    end



    // ----------------------------NEG-02 CSR conflict------------------------------
 
    // Apply each legal operation control recipe,
    // but assert csr_ren_in = 1.
   
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

      req.a_in = 32'h12345678;
      req.b_in = 32'h00000004;

      req.csr_ren_in = 1;
      req.csr_rddata_in = 32'hCAFEBABE;

      req.ap = 0;


      case (op)

        0: begin
          req.ap.lor = 1;
        end

        1: begin
          req.ap.lor = 1;
          req.ap.zbb = 1;
        end

        2: begin
          req.ap.lxor = 1;
        end

        3: begin
          req.ap.lxor = 1;
          req.ap.zbb  = 1;
        end

        4: begin
          req.ap.srl = 1;
        end

        5: begin
          req.ap.sra = 1;
        end

        6: begin
          req.ap.ror = 1;
        end

        7: begin
          req.ap.binv = 1;
        end

        8: begin
          req.ap.sh2add = 1;
          req.ap.zba    = 1;
        end

        9: begin
          req.ap.sub = 1;
        end

        10: begin
          req.ap.slt    = 1;
          req.ap.sub    = 1;
          req.ap.unsign = 0;
        end

        11: begin
          req.ap.slt    = 1;
          req.ap.sub    = 1;
          req.ap.unsign = 1;
        end

        12: begin
          req.ap.ctz = 1;
        end

        13: begin
          req.ap.cpop = 1;
        end

        14: begin
          req.ap.siext_b = 1;
        end

        15: begin
          req.ap.max = 1;
          req.ap.sub = 1;
        end

        16: begin
          req.ap.pack = 1;
        end

        17: begin
          req.b_in = 32'h00000018;
          req.ap.grev = 1;
        end

      endcase


      finish_item(req);

    end



    // =====================================================================
    // -----------------------------NEG-03 Required qualifier - SH2ADD----------------------
  
    `uvm_info(
      get_type_name(),
      "[NEG-03] SH2ADD required zba qualifier",
      UVM_LOW
    )


    // Legal SH2ADD
    // A = 0x10, B = 3
    // Expected legal result = (0x10 << 2) + 3 = 0x43

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h00000010;
    req.b_in = 32'h00000003;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.sh2add = 1;
    req.ap.zba = 1;

    finish_item(req);


    // Illegal: missing zba

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h00000010;
    req.b_in = 32'h00000003;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.sh2add = 1;
    req.ap.zba = 0;

    finish_item(req);



    // ---------------------NEG-04 Forbidden qualifier - SUB----------------------

    
    // Illegal:
    //   sub = 1
    //   zba = 1
   
    `uvm_info(
      get_type_name(),
      "[NEG-04] SUB forbidden zba qualifier",
      UVM_LOW
    )


    // Legal SUB
    // Expected = 0x20 - 0x05 = 0x1B

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h00000020;
    req.b_in = 32'h00000005;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.sub = 1;
    req.ap.zba = 0;

    finish_item(req);


    // Illegal SUB + zba

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h00000020;
    req.b_in = 32'h00000005;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.sub = 1;
    req.ap.zba = 1;

    finish_item(req);



    //------------------ NEG-05 :GREV conflicts-----------------------------------------------
    
    /* Legal REV8 mode:
       grev = 1
       B[4:0] = 24
    
       Conflict 1:
       add one unrelated ap field
    
       Conflict 2:
       csr_ren_in = 1*/
  
   
    `uvm_info(
      get_type_name(),
      "[NEG-05] GREV isolated conflict cases",
      UVM_LOW
    )


    // GREV + forbidden ap field

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h12345678;
    req.b_in = 32'h00000018;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.grev = 1;
    req.ap.cpop = 1;

    finish_item(req);


    // GREV + CSR conflict

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h12345678;
    req.b_in = 32'h00000018;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'hCAFEBABE;

    req.ap = 0;
    req.ap.grev = 1;

    finish_item(req);



    //-------------------- NEG-06 Unsupported GREV mode-------------------------
  
    // Unsupported modes alone are NOT control conflicts.
    //
    // valid_in = 1:
    //   result = 0
    //   error  = 0
   
    // valid_in = 0:
    //   result_ff holds
    //   error remains 0

    `uvm_info(
      get_type_name(),
      "[NEG-06] GREV unsupported modes",
      UVM_LOW
    )


    // Five representative unsupported modes

    for (int i = 0; i < 5; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.a_in = 32'h12345678;
      req.b_in = {27'h0, unsupported_modes[i]};

      req.csr_ren_in = 0;
      req.csr_rddata_in = 0;

      req.ap = 0;
      req.ap.grev = 1;

      finish_item(req);

    end

     //-------------------------------------------------
    // Setup a known nonzero registered value.
    //
    // Use CSR Read because it is independent of GREV behavior.
    // Expected result = DEADBEEF.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h11111111;
    req.b_in = 32'h22222222;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'hDEADBEEF;

    req.ap = 0;

    finish_item(req);


    // Unsupported GREV mode while valid_in=0.
    // Result must hold DEADBEEF.
    // Unsupported mode itself still gives error=0.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 0;

    req.a_in = 32'h12345678;
    req.b_in = 32'h00000019;   // mode 25

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.grev = 1;

    finish_item(req);



    // -------------------NEG-07 Error / valid interaction----------------------------------
 
    // Legal valid request
    // Known conflict with valid_in = 0
    // Another legal valid request
    //
    // Expected during step 2:
    // result_ff HOLDS previous legal result
    // error = 1 despite valid_in = 0
   

    `uvm_info(
      get_type_name(),
      "[NEG-07] Error remains active when valid_in=0",
      UVM_LOW
    )


    // Legal CSR read
    // Expected result = 11223344

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hAAAAAAAA;
    req.b_in = 32'h55555555;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'h11223344;

    req.ap = 0;

    finish_item(req);


    // Known forbidden-field conflict while valid_in = 0.
    //
    // result_ff must HOLD 11223344
    // error must still become 1.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 0;

    req.a_in = 32'hAAAAAAAA;
    req.b_in = 32'h55555555;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.lor  = 1;
    req.ap.cpop = 1;

    finish_item(req);


    // Legal request after the conflict.
    // Expected result = 55667788.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hAAAAAAAA;
    req.b_in = 32'h55555555;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'h55667788;

    req.ap = 0;

    finish_item(req);



    // -------------------NEG-08 Reset priority over active conflict----------------------------
  
    // Apply known conflict with rst_l = 1
    //  Keep conflict asserted and drive synchronous rst_l = 0
    
    // Expected reset cycle:
    //   result_ff = 0
    //   error     = 0
   
    `uvm_info(
      get_type_name(),
      "[NEG-08] Reset overrides active error condition",
      UVM_LOW
    )


    // Active conflict

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h12345678;
    req.b_in = 32'h87654321;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.lor  = 1;
    req.ap.cpop = 1;

    finish_item(req);


    // Synchronous reset while same conflict remains asserted.

    start_item(req);

    req.rst_l = 0;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h12345678;
    req.b_in = 32'h87654321;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.lor  = 1;
    req.ap.cpop = 1;

    finish_item(req);



    // ----------------- idle cycles-----------------------------

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

      req.a_in = 0;
      req.b_in = 0;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 0;

      req.ap = 0;

      finish_item(req);

    end


  endtask : body

endclass : bmu_error_sequence