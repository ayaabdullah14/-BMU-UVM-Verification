class bmu_srl_test extends bmu_base_test;

  `uvm_component_utils(bmu_srl_test)

  function new(
    string        name   = "bmu_srl_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_srl_sequence seq;

    phase.raise_objection(this);

    seq = bmu_srl_sequence::type_id::create("seq");

    `uvm_info("BMU_SRL",
      "Starting BMU SRL sequence",
      UVM_LOW )
   

   seq.start(env.agent.sequencer);

    `uvm_info(
      "BMU_SRL",
      "BMU SRL sequence completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask

endclass
