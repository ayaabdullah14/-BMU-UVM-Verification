class bmu_or_sequence extends uvm_sequence #(bmu_seq_item);

`uvm_object_utils(bmu_or_sequence)

function new(string name = "bmu_or_sequence");
  super.new(name);
endfunction: new


task body();

    bmu_seq_item req;
    // Bit positions used for neighboring-bit OR coverage checks
    int bit_a[5] = '{0, 7, 15, 23, 30};
    int bit_b[5] = '{1, 8, 16, 24, 31};

    // Selected A values covering zero, all-ones, alternating-bit, and mixed-bit patterns
    logic [31:0] a_values[4] = '{
    32'h00000000,
    32'hFFFFFFFF,
    32'hAAAAAAAA,
    32'h12345678
    }; //

    req = bmu_seq_item::type_id::create("req");


    // ==================== Randomized Testing ===================================================

    // OR-01: General OR operation with randomized operands
    `uvm_info(get_type_name(), "[OR-01] General OR operation with randomized operands",              UVM_LOW);


    repeat(16) begin
      start_item(req);
      void'(req.randomize() with {
          rst_l      == 1;
          scan_mode  == 0;
          valid_in   == 1;
          csr_ren_in == 0;}
      );
      req.csr_rddata_in = 32'h00000000;
      req.ap = 0;
      req.ap.lor = 1;
      req.ap.zbb = 0;
      finish_item(req);

    end


    // ==================== Directed Testing =====================================================

    // OR-02: Neighboring-bit and boundary behavior

    `uvm_info(get_type_name(),
              "[OR-02] Neighboring-bit and boundary behavior",
              UVM_LOW);

    for (int i = 0; i <5; i++) begin

      start_item(req);

      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;
      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      // One bit from A and the neighboring bit from B
      req.a_in = (32'h00000001 << bit_a[i]);
      req.b_in = (32'h00000001 << bit_b[i]);

      req.ap = 0;
      req.ap.lor = 1;
      req.ap.zbb = 0;

      finish_item(req);

    end



    // OR-03: Identity and extreme operand behavior

    `uvm_info(get_type_name(),
              "[OR-03] OR identity and extreme operand behavior",
              UVM_LOW);

    for (int i = 0; i <4; i++) begin

      start_item(req);
      // A OR 0 = A
      req.rst_l = 1;
      req.scan_mode = 0;
      req.valid_in = 1;
      req.csr_ren_in = 0;
      req.csr_rddata_in = 32'h00000000;

      req.a_in = a_values[i];
      req.b_in = 32'h00000000;

      req.ap = 0;
      req.ap.lor = 1;
      req.ap.zbb = 0;

      finish_item(req);


      // A OR FFFFFFFF = FFFFFFFF

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
      req.ap.zbb = 0;

      finish_item(req);

    end

   // One drain cycle to allow the last valid request to complete
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



endtask: body

endclass: bmu_or_sequence