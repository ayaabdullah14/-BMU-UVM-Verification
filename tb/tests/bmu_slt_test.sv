class bmu_slt_test extends bmu_base_test;

  `uvm_component_utils(bmu_slt_test)

  function new(
    string name = "bmu_slt_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_slt_sequence seq;

    phase.raise_objection(this);

    seq = bmu_slt_sequence::type_id::create("seq");

    `uvm_info(
      "BMU_SLT",
      "Starting BMU SLT sequence",
      UVM_LOW
    )

    seq.start(env.agent.sequencer);

    `uvm_info(
      "BMU_SLT",
      "BMU SLT sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask

endclass: bmu_slt_test
