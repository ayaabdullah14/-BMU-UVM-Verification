class bmu_sra_test extends bmu_base_test;

  `uvm_component_utils(bmu_sra_test)

  function new(
    string name = "bmu_sra_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_sra_sequence seq;

    phase.raise_objection(this);

    seq = bmu_sra_sequence::type_id::create("seq");

    `uvm_info(
      "BMU_SRA",
      "Starting BMU SRA sequence",
      UVM_LOW
    )

    seq.start(env.agent.sequencer);

    `uvm_info(
      "BMU_SRA",
      "BMU SRA sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask

endclass: bmu_sra_test
