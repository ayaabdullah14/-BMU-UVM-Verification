class bmu_srl_sequence extends uvm_sequence #(bmu_seq_item);

`uvm_object_utils(bmu_srl_sequence)

function new(string name = "bmu_srl_sequence");
  super.new(name);
endfunction: new


task body();

    bmu_seq_item req;

    // All legal 5-bit shift amounts.
    // SRL-01 shuffles this array so every value 0..31
    int shift_values[32];

    // Important bit, byte, halfword, and word boundary positions
    int boundary_bits[8] = '{0, 7, 8, 15, 16, 23, 24, 31};
        

    // Corner shift amounts
    int corner_shifts[4] = '{0, 1, 30, 31};


    // Representative shift amounts for checking that B[31:5]
    int upper_b_shifts[4] = '{  0, 1, 15, 31 };
      

    // Two nonzero upper-B patterns
    logic [26:0] upper_b_patterns[2] = '{
        27'h7FFFFFF,
        27'h2AAAAAA};
    

    req = bmu_seq_item::type_id::create("req");


    // ==================== Randomized Testing ===================================================





    // ---------------------SRL-01: General SRL operation with randomized operands--------------
    
    
  repeat(16) begin

    start_item(req);

    void'(req.randomize() with {
        rst_l      == 1;
        scan_mode  == 0;
        valid_in   == 1;
        csr_ren_in == 0;
    });

    req.csr_rddata_in = 32'h00000000;

    req.ap = 0;
    req.ap.srl = 1;

    finish_item(req);

  end


    // ==================== Directed Testing =====================================================


    //-------------------- SRL-02: One-hot bit movement and boundary behavior----------------------------
  
    `uvm_info(
        get_type_name(),
        "[SRL-02] One-hot bit movement and boundary behavior",
        UVM_LOW
    );

    for (int i = 0; i < 8; i++) begin

      int k;
      int s;

      k = boundary_bits[i];

      for (int j = 0; j < 3; j++) begin

        // k=0 cannot move further toward bit 0.
        // Use s=0,1,31 to check preserve and shift-out behavior.
        if (k == 0) begin
          if (j == 0)
            s = 0;
          else if (j == 1)
            s = 1;
          else
            s = 31;
        end

        // k=31 cannot be shifted completely out using a legal
        // 5-bit shift amount. Use two in-range movements and s=31.
        else if (k == 31) begin
          if (j == 0)
            s = 1;
          else if (j == 1)
            s = 16;
          else
            s = 31;
        end

        else begin
          if (j == 0)
            s = 1;
          else if (j == 1)
            s = k;
          else
            s = k + 1;
        end


        start_item(req);

        req.rst_l = 1;
        req.scan_mode = 0;
        req.valid_in = 1;
        req.csr_ren_in = 0;
        req.csr_rddata_in = 32'h00000000;

        req.a_in = (32'h00000001 << k);

        req.b_in = 32'h00000000;
        req.b_in[4:0] = s;

        req.ap = 0;
        req.ap.srl = 1;

        finish_item(req);

      end

    end


      //--------------------------- SRL-03: Corner shift and data behavior -----------------------------

      `uvm_info(
          get_type_name(),
          "[SRL-03] SRL corner shift and data behavior",
          UVM_LOW
      );

      // Corner shift amounts using mixed data.
      for (int i = 0; i < 4; i++) begin

        start_item(req);

        req.rst_l = 1;
        req.scan_mode = 0;
        req.valid_in = 1;
        req.csr_ren_in = 0;
        req.csr_rddata_in = 32'h00000000;

        req.a_in = 32'h80000001;

        req.b_in = 32'h00000000;
        req.b_in[4:0] = corner_shifts[i];

        req.ap = 0;
        req.ap.srl = 1;

        finish_item(req);

      end


      // All-zero input remains zero after a nonzero shift.
      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;
      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = 32'h00000000;
      req.b_in = 32'd5;

      req.ap = 0;
      req.ap.srl = 1;

      finish_item(req);


      // All-one input checks that SRL inserts zeros from the left.
      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;
      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = 32'hFFFFFFFF;
      req.b_in = 32'd5;

      req.ap = 0;
      req.ap.srl = 1;

      finish_item(req);


    // -----------------------------SRL-04: B[31:5] independence-------------------------
    
    `uvm_info(
        get_type_name(),
        "[SRL-04] Verify B upper bits do not affect SRL result",
        UVM_LOW
    );

    for (int i = 0; i < 4; i++) begin

      for (int j = 0; j < 2; j++) begin

        start_item(req);

        req.rst_l = 1;
        req.scan_mode = 0;
        req.valid_in = 1;
        req.csr_ren_in = 0;
        req.csr_rddata_in = 32'h00000000;

        req.a_in = 32'hA5A55A5A;

        req.b_in = {upper_b_patterns[j], 5'b00000};
        req.b_in[4:0] = upper_b_shifts[i];

        req.ap = 0;
        req.ap.srl = 1;

        finish_item(req);

      end

    end


    //---------------------------- SRL-05: SRL / SRA mode-selection check---------------------------
  
    `uvm_info(
        get_type_name(),
        "[SRL-05] SRL versus SRA mode selection",
        UVM_LOW
    );


    // SRL
    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;
    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h80000000;
    req.b_in = 32'h00000001;

    req.ap = 0;
    req.ap.srl = 1;

    finish_item(req);


    // SRA using exactly the same operands
    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;
    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h80000000;
    req.b_in = 32'h00000001;

    req.ap = 0;
    req.ap.sra = 1;

    finish_item(req);

  
// ------------------------------Idle cycle--------------------------------
    repeat (20) begin 
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

endclass: bmu_srl_sequence
