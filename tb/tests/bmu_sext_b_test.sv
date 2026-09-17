class bmu_sext_b_test extends bmu_base_test;

  `uvm_component_utils(bmu_sext_b_test)

  function new(
    string name = "bmu_sext_b_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_sext_b_sequence seq;

    phase.raise_objection(this);

    seq = bmu_sext_b_sequence::type_id::create("seq");

    `uvm_info(
      "BMU_SEXT_B",
      "Starting BMU SEXT.B sequence",
      UVM_LOW
    )

    seq.start(env.agent.sequencer);

    `uvm_info(
      "BMU_SEXT_B",
      "BMU SEXT.B sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask

endclass: bmu_sext_b_test
