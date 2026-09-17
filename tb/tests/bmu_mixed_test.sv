class bmu_mixed_test extends bmu_base_test;

  `uvm_component_utils(bmu_mixed_test)

  function new(
    string name = "bmu_mixed_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_mixed_sequence seq;

    phase.raise_objection(this);

    seq = bmu_mixed_sequence::type_id::create("seq");

    `uvm_info(
      "BMU_MIXED",
      "Starting BMU mixed legal-mode sequence",
      UVM_LOW
    )

    seq.start(env.agent.sequencer);

    `uvm_info(
      "BMU_MIXED",
      "BMU mixed legal-mode sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask : run_phase

endclass : bmu_mixed_test
