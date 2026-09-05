// Pin-level connection between the BMU and UVM testbench.
interface bmu_if(input logic clk);

  timeunit 1ns;
  timeprecision 1ps;

  // DUT controls
  logic rst_l;      // Active-low synchronous reset
  logic scan_mode;  // Scan mode control
  logic valid_in;   // Enables result register updates

  rtl_pkg::rtl_alu_pkt_t ap;  // Decoded operation controls

  // Operand and CSR inputs
  logic        csr_ren_in;
  logic [31:0] csr_rddata_in;
  logic [31:0] a_in;
  logic [31:0] b_in;

  // DUT outputs
  logic [31:0] result_ff;
  logic        error;

  // Drive inputs on the falling edge, ahead of DUT capture.
  clocking cb_drv @(negedge clk);
    default input #1step output #0;

    output rst_l;
    output scan_mode;
    output valid_in;
    output ap;
    output csr_ren_in;
    output csr_rddata_in;
    output a_in;
    output b_in;
  endclocking

  // Sample before the rising edge; result_ff precedes that edge's update.
  clocking cb_mon @(posedge clk);
    default input #1step;

    input rst_l;
    input scan_mode;
    input valid_in;
    input ap;
    input csr_ren_in;
    input csr_rddata_in;
    input a_in;
    input b_in;
    input result_ff;
    input error;
  endclocking

  // Separate access views for driver and monitor.
  modport DRV(clocking cb_drv, input clk);
  modport MON(clocking cb_mon, input clk);

endinterface