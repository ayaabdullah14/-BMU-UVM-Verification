class bmu_or_test extends bmu_base_test;

  `uvm_component_utils(bmu_or_test)

  function new(
    string        name   = "bmu_or_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_or_sequence seq;

    phase.raise_objection(this);

    seq = bmu_or_sequence::type_id::create("seq");

    `uvm_info(  "BMU_OR","Starting BMU OR sequence", UVM_LOW )

    seq.start(env.agent.sequencer);

    // Wait for monitor samples and the final one-cycle result.
  
    `uvm_info(
      "BMU_OR",
      "BMU OR sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask

endclass