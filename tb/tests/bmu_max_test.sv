class bmu_max_test extends bmu_base_test;

  `uvm_component_utils(bmu_max_test)

  function new(
    string name = "bmu_max_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_max_sequence seq;

    phase.raise_objection(this);

    seq = bmu_max_sequence::type_id::create("seq");

    `uvm_info(
      "BMU_MAX",
      "Starting BMU MAX sequence",
      UVM_LOW
    )

    seq.start(env.agent.sequencer);

    `uvm_info(
      "BMU_MAX",
      "BMU MAX sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask

endclass: bmu_max_test
