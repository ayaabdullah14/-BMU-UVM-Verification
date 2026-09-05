class bmu_base_test extends uvm_test;
  `uvm_component_utils(bmu_base_test)

  function new(string name = "bmu_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // TODO: build the BMU environment.
endclass

