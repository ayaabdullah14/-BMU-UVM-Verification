class bmu_base_sequence extends uvm_sequence #(bmu_seq_item);
  `uvm_object_utils(bmu_base_sequence)

  function new(string name = "bmu_base_sequence");
    super.new(name);
  endfunction

  // TODO: add shared sequence helpers.
endclass

