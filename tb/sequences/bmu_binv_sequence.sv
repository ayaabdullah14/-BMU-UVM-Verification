class bmu_binv_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_binv_sequence)

  function new(string name = "bmu_binv_sequence");
    super.new(name);
  endfunction: new


  task body();

    bmu_seq_item req;

    // BINV-02
    int boundary_indices[8] = '{ 0, 7, 8, 15, 16, 23, 24, 31};
     

    logic [31:0] boundary_a[8] = '{
      32'h00000000,   // bit 0  = 0
      32'h00000080,   // bit 7  = 1
      32'h00000000,   // bit 8  = 0
      32'h00008000,   // bit 15 = 1
      32'h00000000,   // bit 16 = 0
      32'h00800000,   // bit 23 = 1
      32'h00000000,   // bit 24 = 0
      32'h80000000    // bit 31 = 1
    };


    // BINV-04
    int upper_indices[4] = '{ 0, 7, 16, 31};

  
    logic [26:0] upper_b_patterns[2] = '{
      27'h7FFFFFF,
      27'h2AAAAAA
    };


    // BINV-05
    logic [31:0] first_a;
    logic [31:0] first_expected;

    first_a        = 32'h12345678;
    first_expected = first_a ^ (32'h00000001 << 13);


    req = bmu_seq_item::type_id::create("req");


    // ==================== Randomized Testing =================================================

    // ---------------------------------BINV-01 :General randomized BINV operation.---------------------
   
    `uvm_info(
      get_type_name(),
      "[BINV-01] General BINV operation with randomized operands",
      UVM_LOW
    );

    repeat (16) begin

      start_item(req);

      void'(req.randomize() with {
        rst_l      == 1;
        scan_mode  == 0;
        valid_in   == 1;
        csr_ren_in == 0;

        b_in[31:5] == 0;
      });

      req.csr_rddata_in = 32'h00000000;

      req.ap = 0;
      req.ap.binv = 1;

      finish_item(req);

    end



    // ==================== Directed Testing ===================================================


    // ------------------BINV-02:Boundary bit-index testing.---------------------------
    
    `uvm_info(
      get_type_name(),
      "[BINV-02] Boundary bit inversion behavior",
      UVM_LOW
    );

    for (int i = 0; i < 8; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = boundary_a[i];

      req.b_in = 32'h00000000;
      req.b_in[4:0] = boundary_indices[i];

      req.ap = 0;
      req.ap.binv = 1;

      finish_item(req);

    end



    // -----------------------------BINV-03:Corner cases.-----------------------------
    
    `uvm_info(
      get_type_name(),
      "[BINV-03] Zero and all-ones corner cases",
      UVM_LOW
    );


    // Toggle MSB from 0 -> 1
    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00000000;

    req.b_in = 32'h00000000;
    req.b_in[4:0] = 31;

    req.ap = 0;
    req.ap.binv = 1;

    finish_item(req);


    // Toggle LSB from 1 -> 0
    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'hFFFFFFFF;

    req.b_in = 32'h00000000;
    req.b_in[4:0] = 0;

    req.ap = 0;
    req.ap.binv = 1;

    finish_item(req);



    // ----------------------BINV-04 :Verify B[31:5] independence.--------------------------------
   
    `uvm_info(
      get_type_name(),
      "[BINV-04] Verify B upper bits do not affect BINV result",
      UVM_LOW
    );

    for (int i = 0; i < 4; i++) begin

      for (int j = 0; j < 2; j++) begin

        start_item(req);

        req.rst_l = 1;
        req.scan_mode = 0;
        req.valid_in = 1;

        req.csr_ren_in = 0;
        req.csr_rddata_in = 32'h00000000;

        req.a_in = 32'hA5A55A5A;

        req.b_in = 32'h00000000;
        req.b_in[31:5] = upper_b_patterns[j];
        req.b_in[4:0]  = upper_indices[i];

        req.ap = 0;
        req.ap.binv = 1;

        finish_item(req);

      end

    end



    //----------------- BINV-05 Toggle the same bit twice.-------------------------
  
    `uvm_info(
      get_type_name(),
      "[BINV-05] Toggle same bit twice and restore original value",
      UVM_LOW
    );


    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = first_a;

    req.b_in = 32'h00000000;
    req.b_in[4:0] = 13;

    req.ap = 0;
    req.ap.binv = 1;

    finish_item(req);


    // Second inversion
    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = first_expected;

    req.b_in = 32'h00000000;
    req.b_in[4:0] = 13;

    req.ap = 0;
    req.ap.binv = 1;

    finish_item(req);



    // ==================== Idle Cycles =========================================================

    `uvm_info(
      get_type_name(),
      "[BINV-IDLE] Final idle cycles",
      UVM_LOW
    );

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

endclass: bmu_binv_sequence
