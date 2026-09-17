class bmu_ctz_debug_test extends bmu_base_test;

  `uvm_component_utils(bmu_ctz_debug_test)

  function new(
    string name = "bmu_ctz_debug_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_ctz_debug_sequence seq;

    phase.raise_objection(this);

    seq = bmu_ctz_debug_sequence::type_id::create("seq");

    `uvm_info(
      "BMU_CTZ_DEBUG",
      "Starting BMU CTZ debug sequence",
      UVM_LOW
    )

    seq.start(env.agent.sequencer);

    `uvm_info(
      "BMU_CTZ_DEBUG",
      "BMU CTZ debug sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask

endclass: bmu_ctz_debug_test
