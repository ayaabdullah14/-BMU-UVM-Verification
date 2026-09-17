class bmu_ctz_debug_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_ctz_debug_sequence)

  function new(string name = "bmu_ctz_debug_sequence");
    super.new(name);
  endfunction


  task body();

    bmu_seq_item req;

    logic [31:0] debug_a[9];

    req = bmu_seq_item::type_id::create("req");


    debug_a[0] = 32'h00000001;  // CTZ = 0
    debug_a[1] = 32'h00000002;  // CTZ = 1
    debug_a[2] = 32'h00000004;  // CTZ = 2

    debug_a[3] = 32'h00000080;  // CTZ = 7
    debug_a[4] = 32'h00000100;  // CTZ = 8

    debug_a[5] = 32'h00020000;  // CTZ = 17
    debug_a[6] = 32'h00040000;  // CTZ = 18
    debug_a[7] = 32'h00100000;  // CTZ = 20

    debug_a[8] = 32'h80000000;  // CTZ = 31


    `uvm_info(
      get_type_name(),
      "[CTZ-DEBUG] Starting directed CTZ debug cases",
      UVM_LOW
    )


    for (int i = 0; i < 9; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = debug_a[i];
      req.b_in = 32'h00000000;

      req.ap = 0;
      req.ap.ctz = 1;

      finish_item(req);

    end


    // Final idle cycles

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

endclass: bmu_ctz_debug_sequence
