class bmu_sltu_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_sltu_sequence)

  function new(string name = "bmu_sltu_sequence");
    super.new(name);
  endfunction: new


  task body();

    bmu_seq_item req;


    // SLTU-02
    // Equality and unsigned boundary cases

    logic [31:0] boundary_a[10] = '{
      32'h00000000,
      32'h7FFFFFFF,
      32'h80000000,
      32'hFFFFFFFF,
      32'h00000000,
      32'h00000001,
      32'h7FFFFFFF,
      32'h80000000,
      32'hFFFFFFFE,
      32'hFFFFFFFF
    };

    logic [31:0] boundary_b[10] = '{
      32'h00000000,
      32'h7FFFFFFF,
      32'h80000000,
      32'hFFFFFFFF,
      32'h00000001,
      32'h00000000,
      32'h80000000,
      32'h7FFFFFFF,
      32'hFFFFFFFF,
      32'hFFFFFFFE
    };


    // SLTU-03
    // Cases where signed and unsigned ordering differ

    logic [31:0] trap_a[4] = '{
      32'hFFFFFFFF,
      32'h00000000,
      32'h80000000,
      32'h7FFFFFFF
    };

    logic [31:0] trap_b[4] = '{
      32'h00000000,
      32'hFFFFFFFF,
      32'h7FFFFFFF,
      32'h80000000
    };


    req = bmu_seq_item::type_id::create("req");


    // ==================== Randomized Testing =================================================


    `uvm_info(
      get_type_name(),
      "[SLTU-01] General SLTU operation with randomized operands",
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
      req.ap.unsign = 1;

      finish_item(req);

    end



    // ==================== Directed Testing ===================================================


    //----------------------------------- SLTU-02 Equality and unsigned boundary cases.---------------------------------
    
    `uvm_info(
      get_type_name(),
      "[SLTU-02] Equality and unsigned boundary cases",
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
      req.ap.unsign = 1;

      finish_item(req);

    end



    //-------------------------------- SLTU-03 Signed-vs-unsigned trap cases.---------------------------------
    
    `uvm_info(
      get_type_name(),
      "[SLTU-03] Signed-vs-unsigned trap cases",
      UVM_LOW
    );

    for (int i = 0; i < 4; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = trap_a[i];
      req.b_in = trap_b[i];

      req.ap = 0;
      req.ap.slt    = 1;
      req.ap.sub    = 1;
      req.ap.unsign = 1;

      finish_item(req);

    end



    

    //-------------------------------- SLTU-04 Mode-selection test.--------------------------------------
    
    `uvm_info(
      get_type_name(),
      "[SLTU-04] Unsigned-versus-signed mode selection",
      UVM_LOW
    );


    // Unsigned comparison
    // Expected result = 0

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'hFFFFFFFF;
    req.b_in = 32'h00000000;

    req.ap = 0;
    req.ap.slt    = 1;
    req.ap.sub    = 1;
    req.ap.unsign = 1;

    finish_item(req);


    // Signed comparison
    // Expected result = 1

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'hFFFFFFFF;
    req.b_in = 32'h00000000;

    req.ap = 0;
    req.ap.slt    = 1;
    req.ap.sub    = 1;
    req.ap.unsign = 0;

    finish_item(req);



    // ==================== Idle Cycles =========================================================

   
    `uvm_info(
      get_type_name(),
      "[SLTU-IDLE] Final idle cycles",
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

endclass: bmu_sltu_sequence
