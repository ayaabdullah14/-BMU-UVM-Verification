class bmu_cpop_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_cpop_sequence)

  function new(string name = "bmu_cpop_sequence");
    super.new(name);
  endfunction


  task body();

    bmu_seq_item req;

    logic [31:0] corner_a[8];
    logic [31:0] b_indep_a[8];

    int bit_positions[8];
    int weight_values[16];

    int weight;

    logic [31:0] one_hot;
    logic [31:0] one_cold;


    req = bmu_seq_item::type_id::create("req");


    // POP-01
    // Directed corner and pattern cases

    corner_a[0] = 32'h00000000;  // count = 0
    corner_a[1] = 32'h00000001;  // count = 1
    corner_a[2] = 32'h80000000;  // count = 1
    corner_a[3] = 32'hFFFFFFFF;  // count = 32
    corner_a[4] = 32'hFFFF0000;  // count = 16
    corner_a[5] = 32'h0000FFFF;  // count = 16
    corner_a[6] = 32'hAAAAAAAA;  // count = 16
    corner_a[7] = 32'h55555555;  // count = 16


    `uvm_info(
      get_type_name(),
      "[POP-01] Directed corner and pattern cases",
      UVM_LOW
    )


    for (int i = 0; i < 8; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = corner_a[i];
      req.b_in = 32'h00000000;

      req.ap = 0;
      req.ap.cpop = 1;

      finish_item(req);

    end



    
    //------------- POP-02 Constrained-random population-count testing------------------
  
    weight_values[0]  = 2;
    weight_values[1]  = 3;
    weight_values[2]  = 5;
    weight_values[3]  = 7;

    weight_values[4]  = 9;
    weight_values[5]  = 11;
    weight_values[6]  = 13;
    weight_values[7]  = 15;

    weight_values[8]  = 17;
    weight_values[9]  = 19;
    weight_values[10] = 21;
    weight_values[11] = 23;

    weight_values[12] = 25;
    weight_values[13] = 27;
    weight_values[14] = 29;
    weight_values[15] = 30;


    `uvm_info(
      get_type_name(),
      "[POP-02] Constrained-random population-count cases",
      UVM_LOW
    )


    for (int i = 0; i < 16; i++) begin

      weight = weight_values[i];

      start_item(req);

      assert(req.randomize() with {

        rst_l      == 1;
        scan_mode  == 0;
        valid_in   == 1;
        csr_ren_in == 0;

        $countones(a_in) == weight;

      });

      req.csr_rddata_in = 32'h00000000;
      req.b_in = 32'h00000000;

      req.ap = 0;
      req.ap.cpop = 1;

      finish_item(req);

    end



    // ----------------------POP-03 Representative one-hot and one-cold positions-------------------
    
    bit_positions[0] = 0;
    bit_positions[1] = 7;
    bit_positions[2] = 8;
    bit_positions[3] = 15;
    bit_positions[4] = 16;
    bit_positions[5] = 23;
    bit_positions[6] = 24;
    bit_positions[7] = 31;


    `uvm_info(
      get_type_name(),
      "[POP-03] One-hot and one-cold position cases",
      UVM_LOW
    )


    for (int i = 0; i < 8; i++) begin

      one_hot  = 32'h00000001 << bit_positions[i];
      one_cold = ~(32'h00000001 << bit_positions[i]);


      // ---------------- One-hot ----------------

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = one_hot;
      req.b_in = 32'h00000000;

      req.ap = 0;
      req.ap.cpop = 1;

      finish_item(req);


      // ---------------- One-cold ----------------

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = one_cold;
      req.b_in = 32'h00000000;

      req.ap = 0;
      req.ap.cpop = 1;

      finish_item(req);

    end



    // ------ POP-04 B independence-----------------
    
    b_indep_a[0] = 32'h00000000;  // count = 0
    b_indep_a[1] = 32'h00000001;  // count = 1
    b_indep_a[2] = 32'h000000FF;  // count = 8
    b_indep_a[3] = 32'h0000FFFF;  // count = 16
    b_indep_a[4] = 32'h00FFFFFF;  // count = 24
    b_indep_a[5] = 32'hFFFFFFFE;  // count = 31
    b_indep_a[6] = 32'hFFFFFFFF;  // count = 32
    b_indep_a[7] = 32'hA5A5A5A5;  // count = 16


    `uvm_info(
      get_type_name(),
      "[POP-04] Verify CPOP result is independent of B",
      UVM_LOW
    )


    for (int i = 0; i < 8; i++) begin

      //  B = 00000000 

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = b_indep_a[i];
      req.b_in = 32'h00000000;

      req.ap = 0;
      req.ap.cpop = 1;

      finish_item(req);


      // - B = FFFFFFFF -

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = b_indep_a[i];
      req.b_in = 32'hFFFFFFFF;

      req.ap = 0;
      req.ap.cpop = 1;

      finish_item(req);

    end



    //---------idle cycle ------------------------
    `uvm_info(
      get_type_name(),
      "[CPOP-IDLE] Final idle cycles",
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


  endtask: body

endclass: bmu_cpop_sequence