class bmu_slt_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_slt_sequence)

  function new(string name = "bmu_slt_sequence");
    super.new(name);
  endfunction: new


  task body();

    bmu_seq_item req;


    //signed boundary cases

    logic [31:0] boundary_a[10] = '{
      32'h00000000,   //  0
      32'h7FFFFFFF,   //  MAX
      32'h80000000,   //  MIN
      32'hFFFFFFFF,   // -1

      32'hFFFFFFFF,   // -1
      32'h00000000,   //  0

      32'h80000000,   // MIN
      32'h80000001,   // MIN+1

      32'h7FFFFFFE,   // MAX-1
      32'h7FFFFFFF    // MAX
    };


    logic [31:0] boundary_b[10] = '{
      32'h00000000,   //  0
      32'h7FFFFFFF,   //  MAX
      32'h80000000,   //  MIN
      32'hFFFFFFFF,   // -1

      32'h00000000,   //  0
      32'hFFFFFFFF,   // -1

      32'h80000001,   // MIN+1
      32'h80000000,   // MIN

      32'h7FFFFFFF,   // MAX
      32'h7FFFFFFE    // MAX-1
    };


    req = bmu_seq_item::type_id::create("req");


    // ==================== Randomized Testing =================================================

    // -------------------------SLT-01 General signed comparison.-----------------------------
   
    `uvm_info(
      get_type_name(),
      "[SLT-01] General SLT operation with randomized operands",
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
      req.ap.slt    = 1;
      req.ap.sub    = 1;
      req.ap.unsign = 0;

      finish_item(req);

    end



    // ==================== Directed Testing ===================================================


    //---------------------- SLT-02 Equality and signed-boundary cases.------------------------
    
    `uvm_info(
      get_type_name(),
      "[SLT-02] Equality and signed-boundary cases",
      UVM_LOW
    );

    for (int i = 0; i < 10; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = boundary_a[i];
      req.b_in = boundary_b[i];

      req.ap = 0;
      req.ap.slt    = 1;
      req.ap.sub    = 1;
      req.ap.unsign = 0;

      finish_item(req);

    end



    //------------------ SLT-03 Signed minimum / maximum boundary.------------------------
   
    `uvm_info(
      get_type_name(),
      "[SLT-03] Signed MIN/MAX boundary comparison",
      UVM_LOW
    );


    // MIN < MAX -> 1

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h80000000;
    req.b_in = 32'h7FFFFFFF;

    req.ap = 0;
    req.ap.slt    = 1;
    req.ap.sub    = 1;
    req.ap.unsign = 0;

    finish_item(req);


    // MAX < MIN -> 0

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h7FFFFFFF;
    req.b_in = 32'h80000000;

    req.ap = 0;
    req.ap.slt    = 1;
    req.ap.sub    = 1;
    req.ap.unsign = 0;

    finish_item(req);



   

    //-------------------- SLT-05 Compare two negative numbers.----------------------
    
    `uvm_info(
      get_type_name(),
      "[SLT-04] Negative-versus-negative signed comparison",
      UVM_LOW
    );


    // -2 < -1 -> 1

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'hFFFFFFFE;
    req.b_in = 32'hFFFFFFFF;

    req.ap = 0;
    req.ap.slt    = 1;
    req.ap.sub    = 1;
    req.ap.unsign = 0;

    finish_item(req);


    // -1 < -2 -> 0

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'hFFFFFFFF;
    req.b_in = 32'hFFFFFFFE;

    req.ap = 0;
    req.ap.slt    = 1;
    req.ap.sub    = 1;
    req.ap.unsign = 0;

    finish_item(req);



    // ==================== Idle Cycles =========================================================

   
    `uvm_info(
      get_type_name(),
      "[SLT-IDLE] Final idle cycles",
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

endclass: bmu_slt_sequence