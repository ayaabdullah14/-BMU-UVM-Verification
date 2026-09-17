class bmu_sltu_test extends bmu_base_test;

  `uvm_component_utils(bmu_sltu_test)

  function new(
    string name = "bmu_sltu_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_sltu_sequence seq;

    phase.raise_objection(this);

    seq = bmu_sltu_sequence::type_id::create("seq");

    `uvm_info(
      "BMU_SLTU",
      "Starting BMU SLTU sequence",
      UVM_LOW
    )

    seq.start(env.agent.sequencer);

    `uvm_info(
      "BMU_SLTU",
      "BMU SLTU sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask

endclass: bmu_sltu_test
