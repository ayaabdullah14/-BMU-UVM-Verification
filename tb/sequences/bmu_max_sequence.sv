class bmu_max_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_max_sequence)

  function new(string name = "bmu_max_sequence");
    super.new(name);
  endfunction


  task body();

    bmu_seq_item req;

    logic [31:0] equal_values[4];


    req = bmu_seq_item::type_id::create("req");


    /* 16 constrained-random signed comparison
     4 positive / positive
     4 negative / negative
     4 negative / positive
     4 positive / negative*/
    
    //  Expected:return the larger operand using signed comparison

    `uvm_info(
      get_type_name(),
      "[MAX-01] Constrained-random signed comparisons",
      UVM_LOW
    )


    // ---------------- Positive A / Positive B ----------------

    repeat (4) begin

      start_item(req);

      assert(req.randomize() with {

        rst_l      == 1;
        scan_mode  == 0;
        valid_in   == 1;
        csr_ren_in == 0;

        a_in[31] == 0;
        b_in[31] == 0;

      });

      req.csr_rddata_in = 32'h00000000;

      req.ap = 0;
      req.ap.max    = 1;
      req.ap.sub    = 1;
      req.ap.unsign = 0;

      finish_item(req);

    end


    // ---------------- Negative A / Negative B ----------------

    repeat (4) begin

      start_item(req);

      assert(req.randomize() with {

        rst_l      == 1;
        scan_mode  == 0;
        valid_in   == 1;
        csr_ren_in == 0;

        a_in[31] == 1;
        b_in[31] == 1;

      });

      req.csr_rddata_in = 32'h00000000;

      req.ap = 0;
      req.ap.max    = 1;
      req.ap.sub    = 1;
      req.ap.unsign = 0;

      finish_item(req);

    end


    // ---------------- Negative A / Positive B ----------------

    repeat (4) begin

      start_item(req);

      assert(req.randomize() with {

        rst_l      == 1;
        scan_mode  == 0;
        valid_in   == 1;
        csr_ren_in == 0;

        a_in[31] == 1;
        b_in[31] == 0;

      });

      req.csr_rddata_in = 32'h00000000;

      req.ap = 0;
      req.ap.max    = 1;
      req.ap.sub    = 1;
      req.ap.unsign = 0;

      finish_item(req);

    end


    // ---------------- Positive A / Negative B ----------------

    repeat (4) begin

      start_item(req);

      assert(req.randomize() with {

        rst_l      == 1;
        scan_mode  == 0;
        valid_in   == 1;
        csr_ren_in == 0;

        a_in[31] == 0;
        b_in[31] == 1;

      });

      req.csr_rddata_in = 32'h00000000;

      req.ap = 0;
      req.ap.max    = 1;
      req.ap.sub    = 1;
      req.ap.unsign = 0;

      finish_item(req);

    end



    //------------------------- MAX-02 :Equality cases-----------------------------
   
    equal_values[0] = 32'h00000000;
    equal_values[1] = 32'h00000001;
    equal_values[2] = 32'h80000000;
    equal_values[3] = 32'hFFFFFFFF;


    `uvm_info(
      get_type_name(),
      "[MAX-02] Equal operand cases",
      UVM_LOW
    )


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
      req.ap.max    = 1;
      req.ap.sub    = 1;
      req.ap.unsign = 0;

      finish_item(req);

    end



    //-------------------------- MAX-03 Mixed-sign boundary cases------------------------
   
    `uvm_info(
      get_type_name(),
      "[MAX-03] Mixed-sign signed-boundary cases",
      UVM_LOW
    )


    // MIN vs MAX

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h80000000;
    req.b_in = 32'h7FFFFFFF;

    req.ap = 0;
    req.ap.max    = 1;
    req.ap.sub    = 1;
    req.ap.unsign = 0;

    finish_item(req);


    // MAX vs MIN

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h7FFFFFFF;
    req.b_in = 32'h80000000;

    req.ap = 0;
    req.ap.max    = 1;
    req.ap.sub    = 1;
    req.ap.unsign = 0;

    finish_item(req);


    // -1 vs 0

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'hFFFFFFFF;
    req.b_in = 32'h00000000;

    req.ap = 0;
    req.ap.max    = 1;
    req.ap.sub    = 1;
    req.ap.unsign = 0;

    finish_item(req);


    // 0 vs -1

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h00000000;
    req.b_in = 32'hFFFFFFFF;

    req.ap = 0;
    req.ap.max    = 1;
    req.ap.sub    = 1;
    req.ap.unsign = 0;

    finish_item(req);



    //---------------- MAX-04 Compare two negative operands----------------------
    
    `uvm_info(
      get_type_name(),
      "[MAX-04] Negative-versus-negative signed comparison",
      UVM_LOW
    )


    // -2 vs -1

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'hFFFFFFFE;
    req.b_in = 32'hFFFFFFFF;

    req.ap = 0;
    req.ap.max    = 1;
    req.ap.sub    = 1;
    req.ap.unsign = 0;

    finish_item(req);


    // -1 vs -2

    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;

    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'hFFFFFFFF;
    req.b_in = 32'hFFFFFFFE;

    req.ap = 0;
    req.ap.max    = 1;
    req.ap.sub    = 1;
    req.ap.unsign = 0;

    finish_item(req);




    // --------------------------------Final idle cycles-----------------------------------

    `uvm_info(
      get_type_name(),
      "[MAX-IDLE] Final idle cycles",
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

endclass: bmu_max_sequence