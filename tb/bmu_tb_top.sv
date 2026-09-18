`timescale 1ns/1ps

module bmu_tb_top;

  import uvm_pkg::*;
  import rtl_pkg::*;
  import bmu_pkg::*;

  // Clock: 10 ns period
  logic clk = 1'b0;
  always #5 clk = ~clk;

  // BMU interface
  bmu_if vif(clk);

  // DUT instance
  Bit_Manipulation_Unit dut (
    .clk           (vif.clk),
    .rst_l         (vif.rst_l),
    .scan_mode     (vif.scan_mode),
    .valid_in      (vif.valid_in),
    .ap            (vif.ap),
    .csr_ren_in    (vif.csr_ren_in),
    .csr_rddata_in (vif.csr_rddata_in),
    .a_in          (vif.a_in),
    .b_in          (vif.b_in),
    .result_ff     (vif.result_ff),
    .error         (vif.error)
  );

  initial begin
    // Give the virtual interface to the UVM agent.
    uvm_config_db#(virtual bmu_if)::set(
      null,
      "uvm_test_top.env.agent.*",
      "vif",
      vif
    );

    // Test selected using +UVM_TESTNAME.
    run_test();
  end

endmodule

