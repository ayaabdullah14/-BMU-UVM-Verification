class bmu_grev_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_grev_sequence)

  function new(string name = "bmu_grev_sequence");
    super.new(name);
  endfunction


  task body();

    bmu_seq_item req;

    logic [4:0] mode_values[5];


    req = bmu_seq_item::type_id::create("req");


    // Representative unsupported GREV modes
    mode_values[0] = 5'd0;
    mode_values[1] = 5'd1;
    mode_values[2] = 5'd23;
    mode_values[3] = 5'd25;
    mode_values[4] = 5'd31;



    // ------------------GREV-01 Verify correct byte reversal with clear directed values.--------------------
   
    `uvm_info(
      get_type_name(),
      "[GREV-01] Directed REV8 functional cases",
      UVM_LOW
    )


    // ---------------------------------------------------------
    // A = 12345678
    // Expected = 78563412

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h12345678;
    req.b_in = 32'h00000018;

    req.ap = 0;
    req.ap.grev = 1;

    finish_item(req);


    // ---------------------------------------------------------
    // A = 80010204
    // Expected = 04020180

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h80010204;
    req.b_in = 32'h00000018;

    req.ap = 0;
    req.ap.grev = 1;

    finish_item(req);


    // ---------------------------------------------------------
    // A = 00000001
    // Expected = 01000000

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00000001;
    req.b_in = 32'h00000018;

    req.ap = 0;
    req.ap.grev = 1;

    finish_item(req);



    // ------------------GREV-03  Representative unsupported modes--------------------
   
    `uvm_info(
      get_type_name(),
      "[GREV-02] Representative unsupported GREV modes",
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
      req.b_in = {27'h0000000, mode_values[i]};

      req.ap = 0;
      req.ap.grev = 1;

      finish_item(req);

    end



    // ----------------------GREV-04 Verify B[31:5] independence------------------------------------
    `uvm_info(
      get_type_name(),
      "[GREV-03] Verify B[31:5] independence",
      UVM_LOW
    )


    // ---------------------------------------------------------
    // Upper bits all ones
    // Low 5 bits remain 24

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h12345678;
    req.b_in = {27'h7FFFFFF, 5'd24};

    req.ap = 0;
    req.ap.grev = 1;

    finish_item(req);


    // ---------------------------------------------------------
    // Alternating upper-bit pattern
    // Low 5 bits remain 24

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h12345678;
    req.b_in = {27'h5555555, 5'd24};

    req.ap = 0;
    req.ap.grev = 1;

    finish_item(req);



    // --------------------------GREV-04  Back-to-back double REV8----------------------------
   
    `uvm_info(
      get_type_name(),
      "[GREV-04] Back-to-back double REV8",
      UVM_LOW
    )


    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'hA1B2C3D4;
    req.b_in = 32'h00000018;

    req.ap = 0;
    req.ap.grev = 1;

    finish_item(req);


   
    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'hD4C3B2A1;
    req.b_in = 32'h00000018;

    req.ap = 0;
    req.ap.grev = 1;

    finish_item(req);



    // Final idle cycles
  
    `uvm_info(
      get_type_name(),
      "[GREV-IDLE] Final idle cycles",
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


  endtask : body

endclass : bmu_grev_sequence