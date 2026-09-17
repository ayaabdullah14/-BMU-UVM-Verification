class bmu_pack_test extends bmu_base_test;

  `uvm_component_utils(bmu_pack_test)

  function new(
    string name = "bmu_pack_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_pack_sequence seq;

    phase.raise_objection(this);

    seq = bmu_pack_sequence::type_id::create("seq");

    `uvm_info(
      "BMU_PACK",
      "Starting BMU PACK sequence",
      UVM_LOW
    )

    seq.start(env.agent.sequencer);

    `uvm_info(
      "BMU_PACK",
      "BMU PACK sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask

endclass: bmu_pack_test
