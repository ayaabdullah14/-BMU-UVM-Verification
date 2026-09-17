class bmu_cpop_test extends bmu_base_test;

  `uvm_component_utils(bmu_cpop_test)

  function new(
    string name = "bmu_cpop_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_cpop_sequence seq;

    phase.raise_objection(this);

    seq = bmu_cpop_sequence::type_id::create("seq");

    `uvm_info(
      "BMU_CPOP",
      "Starting BMU CPOP sequence",
      UVM_LOW
    )

    seq.start(env.agent.sequencer);

    `uvm_info(
      "BMU_CPOP",
      "BMU CPOP sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask

endclass: bmu_cpop_test
