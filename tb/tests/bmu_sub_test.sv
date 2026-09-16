class bmu_sub_test extends bmu_base_test;

  `uvm_component_utils(bmu_sub_test)

  function new(
    string name = "bmu_sub_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_sub_sequence seq;

    phase.raise_objection(this);

    seq = bmu_sub_sequence::type_id::create("seq");

    `uvm_info(
      "BMU_SUB",
      "Starting BMU SUB sequence",
      UVM_LOW
    )

    seq.start(env.agent.sequencer);

    `uvm_info(
      "BMU_SUB",
      "BMU SUB sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask

endclass: bmu_sub_test
