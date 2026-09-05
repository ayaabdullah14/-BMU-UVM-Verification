class bmu_env extends uvm_env;
  `uvm_component_utils(bmu_env)

  function new(string name = "bmu_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // TODO: build and connect the agent, scoreboard, and coverage subscriber.
endclass

