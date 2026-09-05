class bmu_coverage extends uvm_subscriber #(bmu_seq_item);
  `uvm_component_utils(bmu_coverage)

  function new(string name = "bmu_coverage", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void write(bmu_seq_item tr);
    // TODO: sample the approved functional coverage model.
  endfunction
endclass

