class bmu_driver extends uvm_driver #(bmu_seq_item);
  `uvm_component_utils(bmu_driver)

  function new(string name = "bmu_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // TODO: get the virtual interface and implement driving.
endclass

