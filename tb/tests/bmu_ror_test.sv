class bmu_ror_test extends bmu_base_test;

  `uvm_component_utils(bmu_ror_test)

  function new(
    string name = "bmu_ror_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_ror_sequence seq;

    phase.raise_objection(this);

    seq = bmu_ror_sequence::type_id::create("seq");

    `uvm_info(
      "BMU_ROR",
      "Starting BMU ROR sequence",
      UVM_LOW
    )

    seq.start(env.agent.sequencer);

    `uvm_info(
      "BMU_ROR",
      "BMU ROR sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask

endclass: bmu_ror_test
