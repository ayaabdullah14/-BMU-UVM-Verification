class bmu_valid_in_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_valid_in_sequence)

  function new(string name = "bmu_valid_in_sequence");
    super.new(name);
  endfunction


  task body();

    bmu_seq_item req;

    req = bmu_seq_item::type_id::create("req");


    //------------------------ TST-03-------------------------------
    
   // Check that result_ff does not change when valid_in = 0.

    // Test 1, 2, and 3 invalid cycles.
    // Change inputs and controls during these cycles.

    // Also verify:
    //   legal control    error = 0
    //   illegal control  error = 1

    // result_ff must keep the last valid result.

    `uvm_info(
      get_type_name(),
      "[TST-03] Verify result hold for 1, 2, and 3 invalid cycles",
      UVM_LOW
    )


    // ---------------------------------------------------------------------
    // Case 1:
    // Register 11111111.
    // Then apply valid_in = 0 for one cycle.

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


    // One invalid cycle with legal CSR controls.
    //
    // Expected:
    // result_ff holds 11111111
    // error = 0

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 0;

    req.a_in = 32'h12345678;
    req.b_in = 32'h87654321;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'hAAAAAAAA;

    req.ap = 0;

    finish_item(req);



    // ---------------------------------------------------------------------
    // Case 2:
    // Register 22222222.
    // Then apply valid_in = 0 for two cycles.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hAAAAAAAA;
    req.b_in = 32'h55555555;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'h22222222;

    req.ap = 0;

    finish_item(req);


    // First invalid cycle - legal control.
    
    // Expected:
    // result_ff holds 22222222
    // error = 0

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 0;

    req.a_in = 32'h00000010;
    req.b_in = 32'h00000003;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.ap = 0;
    req.ap.sub = 1;
    req.ap.zba = 0;

    finish_item(req);


    // Second invalid cycle - known conflict.

    // SH2ADD requires zba = 1.
    // Here zba = 0 intentionally.
    //
    // Expected:
    // result_ff still holds 22222222
    // error = 1 even though valid_in = 0

    start_item(req);

    req.rst_l = 1;
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
    // Case 3:
    // Register 33333333.
    // Then apply valid_in = 0 for three cycles.
    // ---------------------------------------------------------------------

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'hAAAAAAAA;
    req.b_in = 32'h55555555;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'h33333333;

    req.ap = 0;

    finish_item(req);


    // Invalid cycle 1 - legal CSR control.
    //
    // Expected:
    // result_ff holds 33333333
    // error = 0

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 0;

    req.a_in = 32'h11111111;
    req.b_in = 32'h22222222;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'hAAAAAAAA;

    req.ap = 0;

    finish_item(req);


    // Invalid cycle 2 - known conflict.
    //
    // Expected:
    // result_ff holds 33333333
    // error = 1

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 0;

    req.a_in = 32'h00000020;
    req.b_in = 32'h00000004;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.ap = 0;
    req.ap.sh2add = 1;
    req.ap.zba = 0;

    finish_item(req);


    // Invalid cycle 3 - another legal control.
    //
    // Expected:
    // result_ff still holds 33333333
    // error returns to 0

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 0;

    req.a_in = 32'h12345678;
    req.b_in = 32'h00000004;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.ap = 0;
    req.ap.sra = 1;

    finish_item(req);



    // =====================================================================
    // ------------------TST-04 Check valid_in transitions------------------------

    //   0 -> 0
    //   0 -> 1
    //   1 -> 1
    //   1 -> 0
    //
    // result_ff updates only when valid_in = 1.
    // When valid_in = 0, result_ff keeps the previous valid result.

    `uvm_info(
      get_type_name(),
      "[TST-04] Verify valid_in transitions 00, 01, 11, and 10",
      UVM_LOW
    )


    // ---------------------------------------------------------------------
    // Register a known value before transition testing.

    // Expected:
    // result_ff = CAFEBABE

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
    // valid_in = 0

    // Legal OR controls.
    // Result must not update.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 0;

    req.a_in = 32'h11111111;
    req.b_in = 32'h22222222;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.ap = 0;
    req.ap.lor = 1;

    finish_item(req);



    // ---------------------------------------------------------------------
    // Transition 00

    // valid_in remains 0.
    // Legal SUB controls.
    // result_ff must still hold CAFEBABE.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 0;

    req.a_in = 32'h00000020;
    req.b_in = 32'h00000005;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.ap = 0;
    req.ap.sub = 1;
    req.ap.zba = 0;

    finish_item(req);



    // ---------------------------------------------------------------------
    // Transition 01
  
    // valid_in changes from 0 to 1.
    // Legal CSR Read.

    // Expected one cycle later:
    // result_ff = 11111111

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



    // ---------------------------------------------------------------------
    // Transition 11

    // valid_in remains 1.
    // Legal OR request.
    //
    // A | B:
    // 11111111 | 22222222 = 33333333

    // Expected one cycle later:
    // result_ff = 33333333
    // ---------------------------------------------------------------------

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h11111111;
    req.b_in = 32'h22222222;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.ap = 0;
    req.ap.lor = 1;

    finish_item(req);



    // ---------------------------------------------------------------------
    // Transition 10

    // valid_in changes from 1 to 0.
    // Legal SRA controls are applied, but the request is not accepted.

    // Expected:
    // result_ff retains the previous valid result.
    // ---------------------------------------------------------------------

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 0;

    req.a_in = 32'h80000000;
    req.b_in = 32'h00000004;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.ap = 0;
    req.ap.sra = 1;

    finish_item(req);



    // -----------------------Final idle cycles-----------------------

    `uvm_info(
      get_type_name(),
      "[VALID-IDLE] Final idle cycles",
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

endclass : bmu_valid_in_sequence