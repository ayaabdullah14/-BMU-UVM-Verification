class bmu_agent extends uvm_agent;
  `uvm_component_utils(bmu_agent)

  function new(string name = "bmu_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // TODO: declare, build, and connect the sequencer, driver, and monitor.
endclass

