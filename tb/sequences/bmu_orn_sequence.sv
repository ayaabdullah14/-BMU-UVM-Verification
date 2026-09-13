class bmu_orn_sequence extends uvm_sequence #(bmu_seq_item);

`uvm_object_utils(bmu_orn_sequence)

function new(string name = "bmu_orn_sequence");
  super.new(name);
endfunction: new


task body();

    bmu_seq_item req;

    // Representative A values covering zero, all-ones,
    // alternating-bit, and mixed-bit patterns
    logic [31:0] a_values[4] = '{
        32'h00000000,
        32'hFFFFFFFF,
        32'hAAAAAAAA,
        32'h12345678
    };

    // Important bit, byte, halfword, and word boundary positions
    int boundary_bits[8] = '{
        0, 7, 8, 15, 16, 23, 24, 31
    };

    req = bmu_seq_item::type_id::create("req");


    // ==================== Randomized Testing ===================================================

    // ORN-01: General ORN operation with randomized operands
    `uvm_info( get_type_name(), "[ORN-01] General ORN operation with randomized operands", UVM_LOW );
       

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
      req.ap.lor = 1;
      req.ap.zbb = 1;

      finish_item(req);

    end


    // ==================== Directed Testing =====================================================


    // ---------------ORN-02: Identity and extreme operand behavior---------------------------
   

    `uvm_info(
        get_type_name(),
        "[ORN-02] ORN identity and extreme operand behavior",
        UVM_LOW
    );

    for (int i = 0; i < 4; i++) begin

      // Test with B = 0
      // Expected: F = FFFFFFFF
      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;
      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = a_values[i];
      req.b_in = 32'h00000000;

      req.ap = 0;
      req.ap.lor = 1;
      req.ap.zbb = 1;

      finish_item(req);


      // Test with B = FFFFFFFF
      // Expected: F = A
      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;
      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = a_values[i];
      req.b_in = 32'hFFFFFFFF;

      req.ap = 0;
      req.ap.lor = 1;
      req.ap.zbb = 1;

      finish_item(req);

    end


    // ------------------ORN-03: Boundary-bit inversion checks---------------------------
    
    

    `uvm_info(  get_type_name(),"[ORN-03] Boundary-bit inversion checks",    UVM_LOW );



    for (int i = 0; i < 8; i++) begin

      // One-hot B pattern
      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;
      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = 32'h00000000;
      req.b_in = (32'h00000001 << boundary_bits[i]);

      req.ap = 0;
      req.ap.lor = 1;
      req.ap.zbb = 1;

      finish_item(req);


      // One-low B pattern
      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;
      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = 32'h00000000;
      req.b_in = ~(32'h00000001 << boundary_bits[i]);

      req.ap = 0;
      req.ap.lor = 1;
      req.ap.zbb = 1;

      finish_item(req);

    end


    // ORN-04: OR / ORN mode-selection check
    
    `uvm_info(
        get_type_name(),
        "[ORN-05] ORN versus OR mode selection using zbb",
        UVM_LOW
    );


    // ORN operation
    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;
    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h0F0F00FF;
    req.b_in = 32'h3333CCCC;

    req.ap = 0;
    req.ap.lor = 1;
    req.ap.zbb = 1;

    finish_item(req);


    // OR operation using exactly the same operands
    start_item(req);

    req.rst_l = 1;
    req.scan_mode = 0;
    req.valid_in = 1;
    req.csr_ren_in = 0;
    req.csr_rddata_in = 32'h00000000;

    req.a_in = 32'h0F0F00FF;
    req.b_in = 32'h3333CCCC;

    req.ap = 0;
    req.ap.lor = 1;
    req.ap.zbb = 0;

    finish_item(req);


endtask: body

endclass: bmu_orn_sequence
