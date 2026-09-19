class bmu_ctz_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_ctz_sequence)

  function new(string name = "bmu_ctz_sequence");
    super.new(name);
  endfunction


  task body();

    bmu_seq_item req;

    logic [31:0] corner_a[4];
    logic [31:0] b_indep_a[8];

    int k;

    int k_values[16] = '{
      0, 1, 3, 5,
      7, 8, 10, 12,
      15, 16, 18, 20,
      23, 24, 27, 31
    };


    req = bmu_seq_item::type_id::create("req");


    // ------------------ CTZ-01 Directed corner cases ------------------

    corner_a[0] = 32'h00000000;
    corner_a[1] = 32'h00000001;
    corner_a[2] = 32'hFFFFFFFF;
    corner_a[3] = 32'h80000000;


    `uvm_info(
      get_type_name(),
      "[CTZ-01] Directed corner cases",
      UVM_LOW
    )


    for (int i = 0; i < 4; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = corner_a[i];
      req.b_in = 32'h00000000;

      req.ap = 0;
      req.ap.ctz = 1;

      finish_item(req);

    end



       // ------------------ CTZ-02 All nonzero CTZ results ------------------

    `uvm_info(
      get_type_name(),
      "[CTZ-02] Exercise every nonzero-input CTZ count from 0 to 31",
      UVM_LOW
    );

    for (int k = 0; k < 32; k++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      // The first set bit is exactly at position k.
      req.a_in = (32'h00000001 << k);
      req.b_in = 32'h00000000;

      req.ap = 0;
      req.ap.ctz = 1;

      finish_item(req);

    end



    // ------------------ CTZ-03 B independence ------------------

    b_indep_a[0] = 32'h00000001;  // CTZ = 0
    b_indep_a[1] = 32'h00000080;  // CTZ = 7
    b_indep_a[2] = 32'h00000100;  // CTZ = 8
    b_indep_a[3] = 32'h00008000;  // CTZ = 15
    b_indep_a[4] = 32'h00010000;  // CTZ = 16
    b_indep_a[5] = 32'h00800000;  // CTZ = 23
    b_indep_a[6] = 32'h80000000;  // CTZ = 31
    b_indep_a[7] = 32'h00000000;  // CTZ = 32


    `uvm_info(
      get_type_name(),
      "[CTZ-03] Verify CTZ result is independent of B",
      UVM_LOW
    )


    for (int i = 0; i < 8; i++) begin

      // B = 00000000

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = b_indep_a[i];
      req.b_in = 32'h00000000;

      req.ap = 0;
      req.ap.ctz = 1;

      finish_item(req);


      // B = FFFFFFFF

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = b_indep_a[i];
      req.b_in = 32'hFFFFFFFF;

      req.ap = 0;
      req.ap.ctz = 1;

      finish_item(req);

    end



    // ------------------ Final idle cycles ------------------

    `uvm_info(
      get_type_name(),
      "[CTZ-IDLE] Final idle cycles",
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

endclass: bmu_ctz_sequence