class bmu_csr_write_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_csr_write_sequence)

  function new(string name = "bmu_csr_write_sequence");
    super.new(name);
  endfunction


  task body();

    bmu_seq_item req;

    logic [31:0] a_values[5];
    logic [31:0] b_values[5];


    req = bmu_seq_item::type_id::create("req");


    // Directed values for Write-A
    a_values[0] = 32'h12345678;
    a_values[1] = 32'h00000000;
    a_values[2] = 32'hFFFFFFFF;
    a_values[3] = 32'h00000001;
    a_values[4] = 32'h80000000;


    // Directed values for Write-B
    b_values[0] = 32'h89ABCDEF;
    b_values[1] = 32'h00000000;
    b_values[2] = 32'hFFFFFFFF;
    b_values[3] = 32'h00000001;
    b_values[4] = 32'h80000000;



    // --------------------------CSR-WR-01 CSR Write-A------------------------------
    // B must not affect the selected result.
   
    `uvm_info(
      get_type_name(),
      "[CSR-WR-01] CSR Write-A directed cases",
      UVM_LOW
    )


    for (int i = 0; i < 5; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.a_in = a_values[i];

      // Keep B visibly different from A.
      req.b_in = 32'hA5A55A5A;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.ap = 0;
      req.ap.csr_write = 1;
      req.ap.csr_imm = 0;

      finish_item(req);

    end



    //---------------------------- CSR-WR-02 CSR Write-B---------------------------------------
    // A must not affect the selected result.
  
    `uvm_info(
      get_type_name(),
      "[CSR-WR-02] CSR Write-B directed cases",
      UVM_LOW
    )


    for (int i = 0; i < 5; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      // Keep A visibly different from B.
      req.a_in = 32'h5A5AA5A5;

      req.b_in = b_values[i];

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.ap = 0;
      req.ap.csr_write = 1;
      req.ap.csr_imm = 1;

      finish_item(req);

    end



    // --------------------------------CSR-WR-03 Consecutive CSR writes while switching csr_imm.-----------------
    // Tests:
    // - correct source selection
    // - back-to-back writes
    // - no stale csr_imm selection
    // - one-cycle request/result alignment
  
    `uvm_info(
      get_type_name(),
      "[CSR-WR-03] Consecutive CSR source-selection changes",
      UVM_LOW
    )


    // ---------------------------------------------------------
    // Write 1
    // csr_imm = 0
    // Expected = A = 11223344

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h11223344;
    req.b_in = 32'h55667788;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h99AABBCC;

    req.ap = 0;
    req.ap.csr_write = 1;
    req.ap.csr_imm = 0;

    finish_item(req);


    // ---------------------------------------------------------
    // Write 2
    // csr_imm = 1
    // Expected = B = 2468ACE0

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h13579BDF;
    req.b_in = 32'h2468ACE0;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'hDEADBEEF;

    req.ap = 0;
    req.ap.csr_write = 1;
    req.ap.csr_imm = 1;

    finish_item(req);


    // ---------------------------------------------------------
    // Write 3
    // csr_imm = 0 again
    // Expected = A = CAFEBABE

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hCAFEBABE;
    req.b_in = 32'h0BADF00D;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h1234ABCD;

    req.ap = 0;
    req.ap.csr_write = 1;
    req.ap.csr_imm = 0;

    finish_item(req);



    //-------------------- Final idle cycles-----------------------------------------
   
    `uvm_info(
      get_type_name(),
      "[CSR-WR-IDLE] Final idle cycles",
      UVM_LOW
    )


    repeat (2) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 0;

      req.a_in = 32'h00000000;
      req.b_in = 32'h00000000;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.ap = 0;

      finish_item(req);

    end


  endtask : body

endclass : bmu_csr_write_sequence