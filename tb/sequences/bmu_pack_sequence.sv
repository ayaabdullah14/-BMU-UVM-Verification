class bmu_pack_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_pack_sequence)

  function new(string name = "bmu_pack_sequence");
    super.new(name);
  endfunction


  task body();

    bmu_seq_item req;


    req = bmu_seq_item::type_id::create("req");


    //------------------------------ PACK-01 Directed corner and asymmetric cases-----------------------
    `uvm_info(
      get_type_name(),
      "[PACK-01] Directed corner and asymmetric cases",
      UVM_LOW
    )


    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h12345678;
    req.b_in = 32'hABCDEF01;

    req.ap = 0;
    req.ap.pack = 1;

    finish_item(req);


    //-------------------------------------------------------
    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'hABCDEF01;
    req.b_in = 32'h12345678;

    req.ap = 0;
    req.ap.pack = 1;

    finish_item(req);


    // ---------------------------------------------------------
    // Both low halves are zero
   
    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'hFFFF0000;
    req.b_in = 32'hAAAA0000;

    req.ap = 0;
    req.ap.pack = 1;

    finish_item(req);


    // ---------------------------------------------------------
    // Both low halves are all ones
    
    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h0000FFFF;
    req.b_in = 32'h0000FFFF;

    req.ap = 0;
    req.ap.pack = 1;

    finish_item(req);



    // -------------------PACK-02 8 constrained-random A/B pairs-----------------------------
   
    `uvm_info(
      get_type_name(),
      "[PACK-02] Constrained-random halfword concatenation cases",
      UVM_LOW
    )


    repeat (8) begin

      start_item(req);

      assert(req.randomize() with {

        rst_l      == 1;
        scan_mode  == 0;
        valid_in   == 1;
        csr_ren_in == 0;

        a_in[15:0] != b_in[15:0];

      });

      req.csr_rddata_in = 32'h00000000;

      req.ap = 0;
      req.ap.pack = 1;

      finish_item(req);

    end



    // -------------------PACK-03 Bit propagation through A[15:0] and B[15:0]--------------------------
    
    `uvm_info(
      get_type_name(),
      "[PACK-03] Low-half bit propagation",
      UVM_LOW
    )

    for (int i = 0; i < 16; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = (32'h00000001 << i);
      req.b_in = 32'h00000000;

      req.ap = 0;
      req.ap.pack = 1;

      finish_item(req);

    end


    // ---------------------------------------------------------
    

    for (int i = 0; i < 16; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = 32'h00000000;
      req.b_in = (32'h00000001 << i);

      req.ap = 0;
      req.ap.pack = 1;

      finish_item(req);

    end



    // ------------------------------04 Verify upper halves are ignored-------------------------
 
    `uvm_info(
      get_type_name(),
      "[PACK-04] Verify upper-half independence",
      UVM_LOW
    )


    // Base case

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00001234;
    req.b_in = 32'h0000ABCD;

    req.ap = 0;
    req.ap.pack = 1;

    finish_item(req);


    // Change A upper half to FFFF

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'hFFFF1234;
    req.b_in = 32'h0000ABCD;

    req.ap = 0;
    req.ap.pack = 1;

    finish_item(req);


    // Change A upper half to AAAA

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'hAAAA1234;
    req.b_in = 32'h0000ABCD;

    req.ap = 0;
    req.ap.pack = 1;

    finish_item(req);


    // Change B upper half to FFFF

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00001234;
    req.b_in = 32'hFFFFABCD;

    req.ap = 0;
    req.ap.pack = 1;

    finish_item(req);


    // Change B upper half to AAAA

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00001234;
    req.b_in = 32'hAAAAABCD;

    req.ap = 0;
    req.ap.pack = 1;

    finish_item(req);



 

    // -------------------------Final idle cycles----------------------------------
 
    `uvm_info(
      get_type_name(),
      "[PACK-IDLE] Final idle cycles",
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

endclass: bmu_pack_sequence