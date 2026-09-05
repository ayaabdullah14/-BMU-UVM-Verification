class bmu_smoke_test extends bmu_base_test;
  `uvm_component_utils(bmu_smoke_test)

  function new(string name = "bmu_smoke_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // TODO: create and start bmu_smoke_sequence.
endclass

