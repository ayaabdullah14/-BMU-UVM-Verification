class bmu_csr_read_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_csr_read_sequence)

  function new(string name = "bmu_csr_read_sequence");
    super.new(name);
  endfunction


  task body();

    bmu_seq_item req;

    logic [31:0] read_values[6];
    logic [31:0] consecutive_values[3];


    req = bmu_seq_item::type_id::create("req");


    // Directed CSR read patterns
    read_values[0] = 32'h00000000;
    read_values[1] = 32'hFFFFFFFF;
    read_values[2] = 32'h80000001;
    read_values[3] = 32'h12345678;
    read_values[4] = 32'hAAAAAAAA;
    read_values[5] = 32'h55555555;


    // Consecutive CSR read values
    consecutive_values[0] = 32'h11111111;
    consecutive_values[1] = 32'h22222222;
    consecutive_values[2] = 32'h44444444;



    //------------------------ CSR-01 Basic CSR read functionality.-------------------------------
    
    `uvm_info(
      get_type_name(),
      "[CSR-01] Directed CSR read data patterns",
      UVM_LOW
    )


    for (int i = 0; i < 6; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.a_in = 32'h13579BDF;
      req.b_in = 32'h2468ACE0;

      req.csr_ren_in = 1;
      req.csr_rddata_in = read_values[i];

      req.ap = 0;

      finish_item(req);

    end



    // ------------------------------CSR-02 Consecutive CSR reads.----------------------------
   

    `uvm_info(
      get_type_name(),
      "[CSR-02] Consecutive CSR read requests",
      UVM_LOW
    )


    for (int i = 0; i < 3; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.a_in = 32'h13579BDF;
      req.b_in = 32'h2468ACE0;

      req.csr_ren_in = 1;
      req.csr_rddata_in = consecutive_values[i];

      req.ap = 0;

      finish_item(req);

    end



    // --------------------------------CSR-03 valid_in hold behavior.------------------------------------
    
  
    `uvm_info(
      get_type_name(),
      "[CSR-03] Verify result hold when valid_in=0",
      UVM_LOW
    )


    // ---------------------------------------------------------
    // First register DEADBEEF

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.a_in = 32'h13579BDF;
    req.b_in = 32'h2468ACE0;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'hDEADBEEF;

    req.ap = 0;

    finish_item(req);


    // ---------------------------------------------------------
    // First invalid cycle
    // csr_rddata_in changes, but result_ff must hold DEADBEEF.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 0;

    req.a_in = 32'h13579BDF;
    req.b_in = 32'h2468ACE0;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'h01234567;

    req.ap = 0;

    finish_item(req);


    // ---------------------------------------------------------
    // Second invalid cycle
    // csr_rddata_in changes again.
    // result_ff must still hold DEADBEEF.

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 0;

    req.a_in = 32'h13579BDF;
    req.b_in = 32'h2468ACE0;

    req.csr_ren_in = 1;
    req.csr_rddata_in = 32'h89ABCDEF;

    req.ap = 0;

    finish_item(req);



    // -------------------------------Final idle cycles---------------------------------------
    
    `uvm_info(
      get_type_name(),
      "[CSR-IDLE] Final idle cycles",
      UVM_LOW
    )


    repeat (2) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 0;

      req.a_in = 32'h00000000;
      req.b_in = 32'h00000000;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.ap = 0;

      finish_item(req);

    end


  endtask : body

endclass : bmu_csr_read_sequence