class bmu_sext_b_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_sext_b_sequence)

  function new(string name = "bmu_sext_b_sequence");
    super.new(name);
  endfunction


  task body();

    bmu_seq_item req;

    logic [31:0] corner_a[6];


    req = bmu_seq_item::type_id::create("req");


    // SEXT-01 Directed low-byte corner cases
  
    corner_a[0] = 32'h00000000;
    corner_a[1] = 32'h00000001;
    corner_a[2] = 32'h0000007F;
    corner_a[3] = 32'h00000080;
    corner_a[4] = 32'h000000FE;
    corner_a[5] = 32'h000000FF;


    `uvm_info(
      get_type_name(),
      "[SEXT-01] Directed low-byte corner cases",
      UVM_LOW
    )


    for (int i = 0; i < 6; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = corner_a[i];
      req.b_in = 32'h00000000;

      req.ap = 0;
      req.ap.siext_b = 1;

      finish_item(req);

    end



    // -----------------------SEXT-02 Constrained-random testing--------------------------

    `uvm_info(
      get_type_name(),
      "[SEXT-02] Constrained-random positive and negative byte cases",
      UVM_LOW
    )


    // ---------------- Positive low bytes ----------------
    // A[7] = 0

    repeat (8) begin

      start_item(req);

      assert(req.randomize() with {

        rst_l      == 1;
        scan_mode  == 0;
        valid_in   == 1;
        csr_ren_in == 0;

        a_in[7] == 0;

      });

      req.csr_rddata_in = 32'h00000000;
      req.b_in = 32'h00000000;

      req.ap = 0;
      req.ap.siext_b = 1;

      finish_item(req);

    end


    // ---------------- Negative low bytes ----------------
    // A[7] = 1

    repeat (8) begin

      start_item(req);

      assert(req.randomize() with {

        rst_l      == 1;
        scan_mode  == 0;
        valid_in   == 1;
        csr_ren_in == 0;

        a_in[7] == 1;

      });

      req.csr_rddata_in = 32'h00000000;
      req.b_in = 32'h00000000;

      req.ap = 0;
      req.ap.siext_b = 1;

      finish_item(req);

    end



    //--------------------------------------- SEXT-03 B independence-----------------
 
    `uvm_info(
      get_type_name(),
      "[SEXT-03] Verify SEXT.B result is independent of B",
      UVM_LOW
    )


    // ---------------- A low byte = 7F ----------------

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h0000007F;
    req.b_in = 32'h00000000;

    req.ap = 0;
    req.ap.siext_b = 1;

    finish_item(req);


    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h0000007F;
    req.b_in = 32'hFFFFFFFF;

    req.ap = 0;
    req.ap.siext_b = 1;

    finish_item(req);


    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h0000007F;
    req.b_in = 32'hAAAAAAAA;

    req.ap = 0;
    req.ap.siext_b = 1;

    finish_item(req);


    // ---------------- A low byte = 80 ----------------

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00000080;
    req.b_in = 32'h00000000;

    req.ap = 0;
    req.ap.siext_b = 1;

    finish_item(req);


    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00000080;
    req.b_in = 32'hFFFFFFFF;

    req.ap = 0;
    req.ap.siext_b = 1;

    finish_item(req);


    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00000080;
    req.b_in = 32'hAAAAAAAA;

    req.ap = 0;
    req.ap.siext_b = 1;

    finish_item(req);



    // ------------------------------SEXT-04 Adjacent transition-----------------------------
   
    `uvm_info(
      get_type_name(),
      "[SEXT-04] Adjacent positive-to-negative byte transition",
      UVM_LOW
    )


    // A[31] = 1, but A[7] = 0
    // Must remain positive

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h8000007F;
    req.b_in = 32'h00000000;

    req.ap = 0;
    req.ap.siext_b = 1;

    finish_item(req);


    // A[31] = 0, but A[7] = 1
    // Must sign-extend as negative

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00000080;
    req.b_in = 32'h00000000;

    req.ap = 0;
    req.ap.siext_b = 1;

    finish_item(req);



    // -------------------------Final idle cycles----------------------
    
    `uvm_info(
      get_type_name(),
      "[SEXT-IDLE] Final idle cycles",
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

endclass: bmu_sext_b_sequence