class bmu_binv_test extends bmu_base_test;

  `uvm_component_utils(bmu_binv_test)

  function new(
    string name = "bmu_binv_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_binv_sequence seq;

    phase.raise_objection(this);

    seq = bmu_binv_sequence::type_id::create("seq");

    `uvm_info(
      "BMU_BINV",
      "Starting BMU BINV sequence",
      UVM_LOW
    )

    seq.start(env.agent.sequencer);

    `uvm_info(
      "BMU_BINV",
      "BMU BINV sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask

endclass: bmu_binv_test
