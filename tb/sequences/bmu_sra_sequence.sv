class bmu_sra_sequence extends uvm_sequence #(bmu_seq_item);

  `uvm_object_utils(bmu_sra_sequence)

  function new(string name = "bmu_sra_sequence");
    super.new(name);
  endfunction: new


  task body();

    bmu_seq_item req;

    // SRA-02
    int k_values[11] = '{ 0, 1, 7, 15, 16, 23, 30, 30, 31, 31, 31};
     

    int s_values[11] = '{0, 1, 4, 8, 16, 7, 15, 30, 1, 16, 31 };


    // SRA-03
    logic [31:0] corner_a[8] = '{
      32'hFFFFFFFF,
      32'hFFFFFFFF,
      32'hFFFFFFFF,
      32'h80000001,
      32'h80000001,
      32'h7FFFFFFF,
      32'h7FFFFFFF,
      32'h00000000
    };

    int corner_s[8] = '{0, 1, 31,1, 31,1, 31,31};
    
    // SRA-04
    logic [31:0] upper_a[2] = '{
      32'h40000001,
      32'h80000001  };
  

    int upper_shift[2] = '{1, 31 };
     


    logic [26:0] upper_b_patterns[2] = '{
      27'h7FFFFFF,
      27'h2AAAAAA
    };


    req = bmu_seq_item::type_id::create("req");


    // ==================== Randomized Testing =================================================

   
    `uvm_info(
      get_type_name(),
      "[SRA-01] Randomized positive and negative operands",
      UVM_LOW
    );


    // 8 positive A values

    repeat (8) begin

      start_item(req);

      void'(req.randomize() with {
        rst_l      == 1;
        scan_mode  == 0;
        valid_in   == 1;
        csr_ren_in == 0;

        a_in[31]   == 0;
        b_in[31:5] == 0;
      });

      req.csr_rddata_in = 32'h00000000;

      req.ap = 0;
      req.ap.sra = 1;

      finish_item(req);

    end


    // 8 negative A values

    repeat (8) begin

      start_item(req);

      void'(req.randomize() with {
        rst_l      == 1;
        scan_mode  == 0;
        valid_in   == 1;
        csr_ren_in == 0;

        a_in[31]   == 1;
        b_in[31:5] == 0;
      });

      req.csr_rddata_in = 32'h00000000;

      req.ap = 0;
      req.ap.sra = 1;

      finish_item(req);

    end



    // ==================== Directed Testing ===================================================

    //---------------------- SRA-02:Directed one-hot bit movement.--------------------
    
    `uvm_info(
      get_type_name(),
      "[SRA-02] One-hot bit movement and sign extension",
      UVM_LOW
    );

    for (int i = 0; i < 11; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = (32'h00000001 << k_values[i]);

      req.b_in = 32'h00000000;
      req.b_in[4:0] = s_values[i];

      req.ap = 0;
      req.ap.sra = 1;

      finish_item(req);

    end



    // -----------------------------SRA-03:Directed corner cases.----------------------
    
    `uvm_info(
      get_type_name(),
      "[SRA-03] Arithmetic-shift corner cases",
      UVM_LOW
    );

    for (int i = 0; i < 8; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;

      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = corner_a[i];

      req.b_in = 32'h00000000;
      req.b_in[4:0] = corner_s[i];

      req.ap = 0;
      req.ap.sra = 1;

      finish_item(req);

    end



    // -----------------SRA-04 Verify that only B[4:0] controls the shift amount.-----------------------
   
    
    `uvm_info(
      get_type_name(),
      "[SRA-04] Verify B upper bits do not affect SRA result",
      UVM_LOW
    );

    for (int i = 0; i < 2; i++) begin

      for (int j = 0; j < 2; j++) begin

        for (int p = 0; p < 2; p++) begin

          start_item(req);

          req.rst_l = 1;
          req.scan_mode = 0;
          req.valid_in = 1;

          req.csr_ren_in = 0;
          req.csr_rddata_in = 32'h00000000;

          req.a_in = upper_a[i];

          req.b_in = 32'h00000000;
          req.b_in[31:5] = upper_b_patterns[p];
          req.b_in[4:0]  = upper_shift[j];

          req.ap = 0;
          req.ap.sra = 1;

          finish_item(req);

        end

      end

    end



    // ==================== Idle Cycle ==========================================================

    

    `uvm_info(
      get_type_name(),
      "[SRA-IDLE] Final idle cycle",
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

endclass: bmu_sra_sequence
