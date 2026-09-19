class bmu_xor_sequence extends uvm_sequence #(bmu_seq_item);

`uvm_object_utils(bmu_xor_sequence)

function new(string name = "bmu_xor_sequence");
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

    //--------------------- XOR-01: General XOR operation with randomized operands-------------------
  
    `uvm_info(  get_type_name(),  "[XOR-01] General XOR operation with randomized operands",UVM_LOW);

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
      req.ap.lxor = 1;

      finish_item(req);

    end


    // ==================== Directed Testing =====================================================


    // --------------------XOR-02: Identity and complement behavior------------------------------
   
    `uvm_info( get_type_name(),"[XOR-02] XOR identity and complement behavior",UVM_LOW);


    for (int i = 0; i < 4; i++) begin

      // B = A
      // Expected: F = 0
      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;
      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = a_values[i];
      req.b_in = a_values[i];

      req.ap = 0;
      req.ap.lxor = 1;

      finish_item(req);


      // B = ~A
      // Expected: F = FFFFFFFF
      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;
      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = a_values[i];
      req.b_in = ~a_values[i];

      req.ap = 0;
      req.ap.lxor = 1;

      finish_item(req);

    end


    // ---------------------------XOR-03: Boundary-bit behavior---------------------------------
    
   
    `uvm_info(
        get_type_name(),
        "[XOR-03] XOR boundary-bit behavior",
        UVM_LOW
    );

    for (int i = 0; i < 8; i++) begin

      // B = 0
      // Expected: F = A
      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;
      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = (32'h00000001 << boundary_bits[i]);
      req.b_in = 32'h00000000;

      req.ap = 0;
      req.ap.lxor = 1;

      finish_item(req);


      // B = FFFFFFFF
      // Expected: F = ~A
      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;
      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = (32'h00000001 << boundary_bits[i]);
      req.b_in = 32'hFFFFFFFF;

      req.ap = 0;
      req.ap.lxor = 1;

      finish_item(req);

    end
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

endclass: bmu_xor_sequence
