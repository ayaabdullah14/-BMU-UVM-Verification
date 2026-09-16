class bmu_sh2add_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_sh2add_sequence)

  function new(string name = "bmu_sh2add_sequence");
    super.new(name);
  endfunction: new


  task body();

    bmu_seq_item req;

    // SH2-05 carry-chain target positions
    int carry_bits[8] = '{2, 7, 8, 15, 16, 23, 24, 31};

      
    req = bmu_seq_item::type_id::create("req");


    // ==================== Randomized Testing =================================================

   
    `uvm_info(
      get_type_name(),
      "[SH2-01] General SH2ADD operation with randomized operands",
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
      req.ap.sh2add = 1;
      req.ap.zba    = 1;

      finish_item(req);

    end



    // ==================== Directed Testing ===================================================




    // ----------------SH2-02:Verify A[31:30] are shifted out.-------------------

    `uvm_info(
      get_type_name(),
      "[SH2-02] Verify upper A bits are shifted out",
      UVM_LOW
    );

    for (int i = 0; i < 4; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = 32'h00000001;
      req.a_in[31:30] = i[1:0];

      req.b_in = 32'h00000003;

      req.ap = 0;
      req.ap.sh2add = 1;
      req.ap.zba    = 1;

      finish_item(req);

    end



    // -----------------------SH2-03 Overflow / 32-bit wrap-around cases.------------------------------------
    
    
    `uvm_info(
      get_type_name(),
      "[SH2-03] Overflow and 32-bit wrap-around behavior",
      UVM_LOW
    );


    // Case 1
    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h3FFFFFFF;
    req.b_in = 32'h00000004;

    req.ap = 0;
    req.ap.sh2add = 1;
    req.ap.zba    = 1;

    finish_item(req);


    // Case 2
    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'hFFFFFFFF;
    req.b_in = 32'hFFFFFFFF;

    req.ap = 0;
    req.ap.sh2add = 1;
    req.ap.zba    = 1;

    finish_item(req);



  
    //--------------------------- SH2-04 :Carry-chain propagation.------------------------
   
   
    `uvm_info(
      get_type_name(),
      "[SH2-04] Representative carry-chain propagation",
      UVM_LOW
    );

    for (int i = 0; i < 8; i++) begin

      int k;

      k = carry_bits[i];

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in =
        (32'h00000001 << (k - 2)) - 1;

      req.b_in = 32'h00000004;

      req.ap = 0;
      req.ap.sh2add = 1;
      req.ap.zba    = 1;

      finish_item(req);

    end



    // ==================== Idle Cycles =========================================================

    `uvm_info(
      get_type_name(),
      "[SH2-IDLE] Final idle cycles",
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

endclass: bmu_sh2add_sequence
