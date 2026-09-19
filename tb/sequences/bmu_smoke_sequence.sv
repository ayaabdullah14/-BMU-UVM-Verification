class bmu_smoke_sequence extends bmu_base_sequence;

  `uvm_object_utils(bmu_smoke_sequence)


  function new(string name = "bmu_smoke_sequence");
    super.new(name);
  endfunction


  virtual task body();

    bmu_seq_item tr;


    `uvm_info(
      "BMU_SMOKE_SEQ",
      "Smoke sequence body started",
      UVM_LOW
    )


    // ------------------------ 1. RESET ----------------------------

    tr = bmu_seq_item::type_id::create("reset_tr");

    start_item(tr);

    tr.rst_l         = 1'b0;
    tr.scan_mode     = 1'b0;
    tr.valid_in      = 1'b0;

    tr.csr_ren_in    = 1'b0;
    tr.csr_rddata_in = 32'h0000_0000;

    tr.a_in          = 32'h0000_0000;
    tr.b_in          = 32'h0000_0000;

    tr.ap            = '0;

    finish_item(tr);


    `uvm_info(
      "BMU_SMOKE_SEQ",
      "Sent RESET transaction",
      UVM_LOW
    )



    // ------------------------ 2. OR -------------------------------
    // F0F00000 | 0F0F0000 = FFFF0000

    tr = bmu_seq_item::type_id::create("or_tr");

    start_item(tr);

    tr.rst_l         = 1'b1;
    tr.scan_mode     = 1'b0;
    tr.valid_in      = 1'b1;

    tr.csr_ren_in    = 1'b0;
    tr.csr_rddata_in = 32'h0000_0000;

    tr.a_in          = 32'hF0F0_0000;
    tr.b_in          = 32'h0F0F_0000;

    tr.ap            = '0;
    tr.ap.lor        = 1'b1;

    finish_item(tr);


    `uvm_info(
      "BMU_SMOKE_SEQ",
      "Sent OR: expected result=0xFFFF0000",
      UVM_LOW
    )



    // ------------------------ 3. XOR ------------------------------
    // 12345678 ^ FFFFFFFF = EDCBA987

    tr = bmu_seq_item::type_id::create("xor_tr");

    start_item(tr);

    tr.rst_l         = 1'b1;
    tr.scan_mode     = 1'b0;
    tr.valid_in      = 1'b1;

    tr.csr_ren_in    = 1'b0;
    tr.csr_rddata_in = 32'h0000_0000;

    tr.a_in          = 32'h1234_5678;
    tr.b_in          = 32'hFFFF_FFFF;

    tr.ap            = '0;
    tr.ap.lxor       = 1'b1;

    finish_item(tr);


    `uvm_info(
      "BMU_SMOKE_SEQ",
      "Sent XOR: expected result=0xEDCBA987",
      UVM_LOW
    )



    // ------------------------ 4. LEGAL NOP ------------------------
    // valid_in=1, ap=0, csr_ren_in=0
    //
    // The previous XOR result is nonzero.
    // The legal NOP must capture result_ff=0 one cycle later.
    // Expected error=0.

    tr = bmu_seq_item::type_id::create("nop_tr");

    start_item(tr);

    tr.rst_l         = 1'b1;
    tr.scan_mode     = 1'b0;
    tr.valid_in      = 1'b1;

    tr.csr_ren_in    = 1'b0;
    tr.csr_rddata_in = 32'h0000_0000;

    // NOP must ignore both operands.
    tr.a_in          = 32'hAAAA_AAAA;
    tr.b_in          = 32'h5555_5555;

    tr.ap            = '0;

    finish_item(tr);

     `uvm_info(
      "BMU_SMOKE_SEQ",
      "Sent NOP: expected result=0x00000000 error=0",
      UVM_LOW
    )


    repeat (2) begin

    start_item(tr);
  
    tr.rst_l         = 1'b1;
    tr.scan_mode     = 1'b0;
    tr.valid_in      = 1'b0;
    tr.ap            = '0;
    tr.csr_ren_in    = 1'b0;
    tr.csr_rddata_in = 32'h0000_0000;
    tr.a_in          = 32'h0000_0000;
    tr.b_in          = 32'h0000_0000;
  
    finish_item(tr);
  
     end

    `uvm_info(
      "BMU_SMOKE_SEQ",
      "Sent NOP: expected result=0x00000000 error=0",
      UVM_LOW
    )


   


  endtask: body

endclass: bmu_smoke_sequence
