class bmu_reset_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_reset_sequence)

  function new(string name = "bmu_reset_sequence");
    super.new(name);
  endfunction


  task body();

    bmu_seq_item req;

    req = bmu_seq_item::type_id::create("req");


    //--------------------------- TST-01---------------------------------------
    
    // Reset at:
    //   Startup
    //   After a nonzero registered result
    //   During a known conflict
    
    
    // Expected on reset:
    //   result_ff = 0
    //   error     = 0

    `uvm_info(
      get_type_name(),
      "[TST-01] Reset at startup, after nonzero result, and during conflict",
      UVM_LOW
    )


    // ---------------------------------------------------------------------
    // Startup reset
    
    // Expected:
    // result_ff = 0
    // error     = 0

    start_item(req);

    req.rst_l = 0;
    req.scan_mode = 0;
    req.valid_in = 0;

    req.a_in = 32'h00000000;
    req.b_in = 32'h00000000;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.ap = 0;

    finish_item(req);



    // ---------------------------------------------------------------------
    // Register a known nonzero result.

    // CSR Read:
    // result_ff = DEADBEEF one cycle later.


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


// ---------------------------------------------------------------------
// Extra legal request.
//
// Its purpose is only to give the previous CSR read enough time
// to place DEADBEEF on result_ff before reset is asserted.

// This request itself produces 00000000.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hAAAAAAAA;
    req.b_in = 32'h55555555;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'h00000000;

    req.ap = 0;

    finish_item(req);



    // ---------------------------------------------------------------------
    // Reset after a nonzero result has already been registered.
    //
    // Immediately before this reset edge:
    // result_ff contains DEADBEEF.
   
    // Reset has priority.

    // Expected:
    // result_ff = 0
    // error     = 0

    start_item(req);

    req.rst_l = 0;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hAAAAAAAA;
    req.b_in = 32'h55555555;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'hCAFEBABE;

    req.ap = 0;

    finish_item(req);



    // ---------------------------------------------------------------------
    // Release reset.

    // Verify normal operation resumes.

    // Expected:
    // result_ff = CAFEBABE one cycle later.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hAAAAAAAA;
    req.b_in = 32'h55555555;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'hCAFEBABE;

    req.ap = 0;

    finish_item(req);



    // ---------------------------------------------------------------------
    // Create a KNOWN error condition.
    //
    // SH2ADD requires:
    //   sh2add = 1 zba= 1
    
    // Here zba = 0 intentionally.
    // This conflict was already verified to generate an error.

    // Expected:
    // result_ff = 0
    // error     = 1

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h00000010;
    req.b_in = 32'h00000003;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.ap = 0;
    req.ap.sh2add = 1;
    req.ap.zba = 0;

    finish_item(req);



    // ---------------------------------------------------------------------
    //Reset during the same known error condition.

    // Keep the illegal controls active.
    // Reset must override:
    //   error = 1

    // Expected:
    // result_ff = 0
    // error     = 0

    start_item(req);

    req.rst_l = 0;
    req.scan_mode = 0;
    req.valid_in = 0;

    req.a_in = 32'h00000010;
    req.b_in = 32'h00000003;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.ap = 0;
    req.ap.sh2add = 1;
    req.ap.zba = 0;

    finish_item(req);



    // ---------------------------------------------------------------------
    // Release reset again.
    
    // Expected:
    // result_ff = 13579BDF

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hAAAAAAAA;
    req.b_in = 32'h55555555;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'h13579BDF;

    req.ap = 0;

    finish_item(req);



    //------------------- TST-02 Reset during back-to-back traffic while a result is pending.----------------
    
    // Reset during back-to-back traffic.
    //
    // The second request produces zero and is pending when reset
    // is asserted.
    //
    // Expected:
    //   - First request appears normally.
    //   - Reset clears result_ff to 0.
    //   - error = 0.
    //   - Normal operation resumes after reset release.
    // =====================================================================

    `uvm_info(
    get_type_name(),
    "[TST-02] Reset during back-to-back traffic with pending result",
    UVM_LOW
    )


    // First legal request
    // Expected result = 11111111

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hAAAAAAAA;
    req.b_in = 32'h55555555;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'h11111111;

    req.ap = 0;

    finish_item(req);


    // Second legal request
    // This request is pending when reset is asserted.
    // Expected result = 00000000

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hAAAAAAAA;
    req.b_in = 32'h55555555;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'h00000000;

    req.ap = 0;

    finish_item(req);


    // Assert reset while previous request is pending.
    //
    // Expected:
    // result_ff = 00000000
    // error     = 0

    start_item(req);

    req.rst_l = 0;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hAAAAAAAA;
    req.b_in = 32'h55555555;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'h33333333;

    req.ap = 0;

    finish_item(req);


    // Release reset and verify recovery.
    //
    // Expected result = A5A55A5A

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hAAAAAAAA;
    req.b_in = 32'h55555555;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'hA5A55A5A;

    req.ap = 0;

    finish_item(req);



    // -----------------------Final idle cycles-------------------------
    
    `uvm_info(
      get_type_name(),
      "[RST-IDLE] Final idle cycles",
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

endclass : bmu_reset_sequence