class bmu_seq_item extends uvm_sequence_item;
  `uvm_object_utils(bmu_seq_item)

  function new(string name = "bmu_seq_item");
    super.new(name);
  endfunction

  // TODO: add BMU transaction fields.
endclass

