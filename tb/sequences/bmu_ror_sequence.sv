class bmu_ror_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_ror_sequence)

  function new(string name = "bmu_ror_sequence");
    super.new(name);
  endfunction: new


  task body();

    bmu_seq_item req;

    // ROR-02
    int boundary_bits[8] = '{ 0, 7, 8, 15, 16, 23, 24, 31};
     

    int rotate_amounts[2] = '{1, 31};

    

    // ROR-04
    logic [26:0] upper_b_patterns[2] = '{
      27'h7FFFFFF,
      27'h2AAAAAA
    };


    // ROR-05
    logic [31:0] pattern_a[5] = '{
      32'h00000000,
      32'hFFFFFFFF,
      32'h55555555,
      32'hAAAAAAAA,
      32'h55555555
    };

    int pattern_s[5] = '{ 13,13,1, 1, 2};


    req = bmu_seq_item::type_id::create("req");


    // ==================== Randomized Testing =================================================

    
    `uvm_info(
      get_type_name(),
      "[ROR-01] General ROR operation with randomized operands",
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
      req.ap.ror = 1;

      finish_item(req);

    end



    // ==================== Directed Testing ===================================================


    //------------------------- ROR-02:One-hot rotation and wrap-around.--------------------------------
    
    `uvm_info(
      get_type_name(),
      "[ROR-02] One-hot rotation and wrap-around behavior",
      UVM_LOW
    );

    for (int i = 0; i < 8; i++) begin

      for (int j = 0; j < 2; j++) begin

        start_item(req);

        req.rst_l = 1;
        req.scan_mode = 0;
        req.valid_in = 1;

        req.csr_ren_in = 0;
        req.csr_rddata_in = 32'h00000000;

        req.a_in = (32'h00000001 << boundary_bits[i]);

        req.b_in = 32'h00000000;
        req.b_in[4:0] = rotate_amounts[j];

        req.ap = 0;
        req.ap.ror = 1;

        finish_item(req);

      end

    end



    // -------------------------ROR-03 :Zero shift and end-bit wrap-around.------------------------------
   
    `uvm_info(
      get_type_name(),
      "[ROR-03] Zero shift and wrap-around corner cases",
      UVM_LOW
    );


    // s = 0
    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;
    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h80000001;
    req.b_in = 32'h00000000;

    req.ap = 0;
    req.ap.ror = 1;

    finish_item(req);


    // s = 1
    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;
    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h80000001;
    req.b_in = 32'h00000001;

    req.ap = 0;
    req.ap.ror = 1;

    finish_item(req);


    // s = 31
    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;
    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h80000001;
    req.b_in = 32'h0000001F;

    req.ap = 0;
    req.ap.ror = 1;

    finish_item(req);



    //----------------- ROR-04 :Verify that B[31:5] does not affect the rotation.---------------
    
    `uvm_info(
      get_type_name(),
      "[ROR-04] Verify B upper bits do not affect ROR result",
      UVM_LOW
    );

    for (int i = 0; i < 2; i++) begin

      for (int j = 0; j < 2; j++) begin

        start_item(req);

        req.rst_l = 1;
        req.scan_mode = 0;
        req.valid_in = 1;

        req.csr_ren_in = 0;
        req.csr_rddata_in = 32'h00000000;

        req.a_in = 32'h80000001;

        req.b_in = 32'h00000000;
        req.b_in[31:5] = upper_b_patterns[j];
        req.b_in[4:0]  = rotate_amounts[i];

        req.ap = 0;
        req.ap.ror = 1;

        finish_item(req);

      end

    end



    // --------------------ROR-05: Representative invariant and alternating-pattern cases.---------------------
    
    `uvm_info(
      get_type_name(),
      "[ROR-05] Invariant and alternating pattern behavior",
      UVM_LOW
    );

    for (int i = 0; i < 5; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = pattern_a[i];

      req.b_in = 32'h00000000;
      req.b_in[4:0] = pattern_s[i];

      req.ap = 0;
      req.ap.ror = 1;

      finish_item(req);

    end



    // ==================== Idle Cycles =========================================================

    `uvm_info(
      get_type_name(),
      "[ROR-IDLE] Final idle cycles",
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

endclass: bmu_ror_sequence
