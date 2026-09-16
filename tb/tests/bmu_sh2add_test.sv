class bmu_sh2add_test extends bmu_base_test;

  `uvm_component_utils(bmu_sh2add_test)

  function new(
    string name = "bmu_sh2add_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_sh2add_sequence seq;

    phase.raise_objection(this);

    seq = bmu_sh2add_sequence::type_id::create("seq");

    `uvm_info(
      "BMU_SH2ADD",
      "Starting BMU SH2ADD sequence",
      UVM_LOW
    )

    seq.start(env.agent.sequencer);

    `uvm_info(
      "BMU_SH2ADD",
      "BMU SH2ADD sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask

endclass: bmu_sh2add_test
