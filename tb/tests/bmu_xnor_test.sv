class bmu_xnor_test extends bmu_base_test;

  `uvm_component_utils(bmu_xnor_test)

  function new(
    string        name   = "bmu_xnor_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_xnor_sequence seq;

    phase.raise_objection(this);

    seq = bmu_xnor_sequence::type_id::create("seq");

    `uvm_info(
      "BMU_XNOR",
      "Starting BMU XNOR sequence",
      UVM_LOW
    )

    seq.start(env.agent.sequencer);

    // Wait for monitor samples and the final one-cycle result.
    repeat (4)
      @(env.agent.monitor.vif.cb_mon);

    `uvm_info(
      "BMU_XNOR",
      "BMU XNOR sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask

endclass
