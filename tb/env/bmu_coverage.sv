class bmu_coverage extends uvm_subscriber #(bmu_seq_item);

  `uvm_component_utils(bmu_coverage)

  int unsigned observed_count = 0;

  function new(string name = "bmu_coverage",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void write(bmu_seq_item t);
    observed_count++;
    // TODO: sample functional coverage
  endfunction

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info(
      "BMU_COV_SUMMARY",
      $sformatf("observed=%0d", observed_count),
      UVM_NONE
    )
  endfunction

endclass