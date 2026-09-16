class bmu_sub_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_sub_sequence)

  function new(string name = "bmu_sub_sequence");
    super.new(name);
  endfunction: new


  task body();

    bmu_seq_item req;

    logic [31:0] equal_values[4] = '{
      32'h00000000,
      32'h00000001,
      32'h80000000,
      32'hFFFFFFFF};
    

    logic [31:0] corner_a[3] = '{
      32'h00000000,
      32'h80000000,
      32'h7FFFFFFF};
    

    logic [31:0] corner_b[3] = '{
      32'h00000001,
      32'h00000001,
      32'hFFFFFFFF};
    

    int borrow_bits[8] = '{ 1, 7, 8, 15, 16, 23, 24, 31};
     
  
    req = bmu_seq_item::type_id::create("req");


    // ==================== Randomized Testing =================================================

    `uvm_info(
      get_type_name(),
      "[SUB-01] General SUB operation with randomized operands",
      UVM_LOW
    );

    repeat (16) begin

      start_item(req);

      void'(req.randomize() with {
        rst_l      == 1;
        scan_mode  == 0;
        valid_in   == 1;
        csr_ren_in == 0;
      });

      req.csr_rddata_in = 32'h00000000;

      req.ap = 0;
      req.ap.sub = 1;
      req.ap.zba = 0;

      finish_item(req);

    end



    // ==================== Directed Testing ===================================================

    //----------------------- SUB-02 :Equality cases.------------------------------------
    
    `uvm_info(
      get_type_name(),
      "[SUB-02] Equality subtraction cases",
      UVM_LOW
    );

    for (int i = 0; i < 4; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = equal_values[i];
      req.b_in = equal_values[i];

      req.ap = 0;
      req.ap.sub = 1;
      req.ap.zba = 0;

      finish_item(req);

    end



    // ------------------------------SUB-03 Corner / wrap-around cases.-------------------------------
   
    `uvm_info(
      get_type_name(),
      "[SUB-03] Underflow and 32-bit wrap-around cases",
      UVM_LOW
    );

    for (int i = 0; i < 3; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = corner_a[i];
      req.b_in = corner_b[i];

      req.ap = 0;
      req.ap.sub = 1;
      req.ap.zba = 0;

      finish_item(req);

    end



    // ---------------------------------SUB-04 Borrow propagation.-----------------------------
   
    `uvm_info(
      get_type_name(),
      "[SUB-04] Representative borrow-chain propagation",
      UVM_LOW
    );

    for (int i = 0; i < 8; i++) begin

      int k;

      k = borrow_bits[i];

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = (32'h00000001 << k);
      req.b_in = 32'h00000001;

      req.ap = 0;
      req.ap.sub = 1;
      req.ap.zba = 0;

      finish_item(req);

    end



    // ==================== Idle Cycles =========================================================

    `uvm_info(
      get_type_name(),
      "[SUB-IDLE] Final idle cycles",
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

endclass: bmu_sub_sequence
