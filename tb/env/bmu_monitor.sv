class bmu_monitor extends uvm_monitor;
  `uvm_component_utils(bmu_monitor)

  function new(string name = "bmu_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // TODO: add the analysis port and implement interface sampling.
endclass

