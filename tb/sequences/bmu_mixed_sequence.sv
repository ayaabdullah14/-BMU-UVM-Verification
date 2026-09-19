class bmu_mixed_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_mixed_sequence)

  function new(string name = "bmu_mixed_sequence");
    super.new(name);
  endfunction


  task body();

    bmu_seq_item req;

    req = bmu_seq_item::type_id::create("req");


    // -------------------------MIX-01---------------------------------------------
   
    // Apply all 21 legal BMU/CSR modes back-to-back.
    // valid_in stays high for every request.
    //
    // Then apply:
    //   - one legal NOP
    //   - one legal operation
    //   - one idle cycle
    
    // Check correct operation selection and one-cycle alignment.

    `uvm_info(
      get_type_name(),
      "[MIX-01] 21 legal modes back-to-back",
      UVM_LOW
    )


    // 1. OR

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h12345678;
    req.b_in = 32'h0F0F0F0F;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.lor = 1;

    finish_item(req);


    // 2. ORN

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h23456789;
    req.b_in = 32'h00FF00FF;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.lor = 1;
    req.ap.zbb = 1;

    finish_item(req);


    // 3. XOR

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h3456789A;
    req.b_in = 32'hAAAAAAAA;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.lxor = 1;

    finish_item(req);


    // 4. XNOR

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h456789AB;
    req.b_in = 32'h55555555;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.lxor = 1;
    req.ap.zbb = 1;

    finish_item(req);


    // 5. SRL

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h87654321;
    req.b_in = 32'h00000004;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.srl = 1;

    finish_item(req);


    // 6. SRA

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h87654321;
    req.b_in = 32'h00000005;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.sra = 1;

    finish_item(req);


    // 7. ROR

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h13579BDF;
    req.b_in = 32'h00000007;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.ror = 1;

    finish_item(req);


    // 8. BINV

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h2468ACE0;
    req.b_in = 32'h00000009;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.binv = 1;

    finish_item(req);


    // 9. SH2ADD

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h00000010;
    req.b_in = 32'h00000103;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.sh2add = 1;
    req.ap.zba = 1;

    finish_item(req);


    // 10. SUB

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h00001000;
    req.b_in = 32'h00000021;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.sub = 1;

    finish_item(req);


    // 11. SLTU

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h00000020;
    req.b_in = 32'h80000000;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.slt = 1;
    req.ap.sub = 1;
    req.ap.unsign = 1;

    finish_item(req);


    // 12. SLT

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hFFFFFFF0;
    req.b_in = 32'h00000030;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.slt = 1;
    req.ap.sub = 1;
    req.ap.unsign = 0;

    finish_item(req);


    // 13. CTZ

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h00000100;
    req.b_in = 32'hABCDEF01;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.ctz = 1;

    finish_item(req);


    // 14. CPOP

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hF0F00F0F;
    req.b_in = 32'h1234ABCD;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.cpop = 1;

    finish_item(req);


    // 15. SEXT.B

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h12345680;
    req.b_in = 32'h89ABCDEF;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.siext_b = 1;

    finish_item(req);


    // 16. MAX

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hFFFFFFF5;
    req.b_in = 32'h00000044;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.max = 1;
    req.ap.sub = 1;
    req.ap.unsign = 0;

    finish_item(req);


    // 17. PACK

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h12345678;
    req.b_in = 32'hABCDEF01;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.pack = 1;

    finish_item(req);


    // ---------------------------------------------------------------------
    // 18. GREV / REV8
    // Legal mode: B[4:0] = 24

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hA1B2C3D4;
    req.b_in = 32'h00000018;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.grev = 1;

    finish_item(req);


    // ---------------------------------------------------------------------
    // 19. CSR READ

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h11112222;
    req.b_in = 32'h33334444;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'hDEADBEEF;

    req.ap = 0;

    finish_item(req);


    // ---------------------------------------------------------------------
    // 20. CSR WRITE A
    // csr_imm = 0 -> A

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hCAFEBABE;
    req.b_in = 32'h10203040;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.csr_write = 1;
    req.ap.csr_imm = 0;

    finish_item(req);


    // ---------------------------------------------------------------------
    // 21. CSR WRITE B
    // csr_imm = 1 -> B

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h50607080;
    req.b_in = 32'h0BADF00D;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.csr_write = 1;
    req.ap.csr_imm = 1;

    finish_item(req);



    // Legal NOP
    // No BMU or CSR operation selected.

    `uvm_info(
      get_type_name(),
      "[MIX-01] Legal NOP",
      UVM_LOW
    )

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h11111111;
    req.b_in = 32'h22222222;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;

    finish_item(req);



    // ----------------------------------------------------------
    // Legal operation after NOP
    // Use OR to verify normal operation continues after NOP.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h0F0F0000;
    req.b_in = 32'h0000F0F0;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 0;

    req.ap = 0;
    req.ap.lor = 1;

    finish_item(req);



    //---------------------- One idle drain cycle-----------------------------------
    repeart (2) begin 
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

endclass : bmu_mixed_sequence
