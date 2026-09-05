class bmu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(bmu_scoreboard)

  function new(string name = "bmu_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // TODO: connect the monitor stream and implement prediction comparison.
endclass

