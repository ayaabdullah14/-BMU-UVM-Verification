// BMU request fields and sampled outputs.
class bmu_seq_item extends uvm_sequence_item;

// Randomized input fields
  rand logic                 rst_l;
  rand logic                 valid_in;
  rand rtl_pkg::rtl_alu_pkt_t ap;
  rand logic                 csr_ren_in;

  // Operand signedness matches the DUT interface.
  rand logic        [31:0] a_in;
  rand logic        [31:0] b_in;
  rand logic        [31:0] csr_rddata_in;

  // Functional-mode default; sequences must keep this value zero.
  logic scan_mode = 1'b0;

  // Sampled output fields
  logic [31:0] result_ff;
  logic        error;

  // Factory registration and field automation.
  `uvm_object_utils_begin(bmu_seq_item)
    `uvm_field_int(rst_l,         UVM_DEFAULT)
    `uvm_field_int(scan_mode,     UVM_DEFAULT)
    `uvm_field_int(valid_in,      UVM_DEFAULT)
    `uvm_field_int(ap,            UVM_DEFAULT)
    `uvm_field_int(csr_ren_in,    UVM_DEFAULT)
    `uvm_field_int(csr_rddata_in, UVM_DEFAULT)
    `uvm_field_int(a_in,          UVM_DEFAULT)
    `uvm_field_int(b_in,          UVM_DEFAULT)
    `uvm_field_int(result_ff,     UVM_DEFAULT)
    `uvm_field_int(error,         UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "bmu_seq_item");
    super.new(name);
  endfunction


endclass