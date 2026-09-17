class bmu_ctz_test extends bmu_base_test;

  `uvm_component_utils(bmu_ctz_test)

  function new(
    string name = "bmu_ctz_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_ctz_sequence seq;

    phase.raise_objection(this);

    seq = bmu_ctz_sequence::type_id::create("seq");

    `uvm_info(
      "BMU_CTZ",
      "Starting BMU CTZ sequence",
      UVM_LOW
    )

    seq.start(env.agent.sequencer);

    `uvm_info(
      "BMU_CTZ",
      "BMU CTZ sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask

endclass: bmu_ctz_test
