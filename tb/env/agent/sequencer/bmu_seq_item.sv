// BMU request fields and sampled outputs.
class bmu_seq_item extends uvm_sequence_item;

// Randomized input fields
  rand logic                 rst_l;
  rand logic                 valid_in;
  rand rtl_pkg::rtl_alu_pkt_t ap;
  rand logic                 csr_ren_in;

  rand logic        [31:0] a_in;
  rand logic        [31:0] b_in;
  rand logic        [31:0] csr_rddata_in;

  // Functional-mode default; sequences must keep this value zero.
  logic scan_mode = 1'b0;

  // Sampled output fields
  logic [31:0] result_ff;
  logic        error;


  // Restrict random AP generation to the currently verified operations.
// Operations outside the current scope remain zero.
constraint c_ap_scope_only {

  ap.clz        == 1'b0;
  ap.siext_h    == 1'b0;
  ap.min        == 1'b0;
  ap.packu      == 1'b0;
  ap.packh      == 1'b0;
  ap.rol        == 1'b0;
  ap.gorc       == 1'b0;
  ap.bset       == 1'b0;
  ap.bclr       == 1'b0;
  ap.bext       == 1'b0;
  ap.sh1add     == 1'b0;
  ap.sh3add     == 1'b0;
  ap.land       == 1'b0;
  ap.sll        == 1'b0;
  ap.beq        == 1'b0;
  ap.bne        == 1'b0;
  ap.blt        == 1'b0;
  ap.bge        == 1'b0;
  ap.add        == 1'b0;
  ap.jal        == 1'b0;
  ap.predict_t  == 1'b0;
  ap.predict_nt == 1'b0;
  }
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