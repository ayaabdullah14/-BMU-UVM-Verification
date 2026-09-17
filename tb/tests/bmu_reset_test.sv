class bmu_reset_test extends bmu_base_test;

  `uvm_component_utils(bmu_reset_test)


  function new(
    string name = "bmu_reset_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_reset_sequence seq;

    phase.raise_objection(this);

    seq = bmu_reset_sequence::type_id::create("seq");


    `uvm_info(
      "BMU_RESET",
      "Starting BMU reset sequence",
      UVM_LOW
    )


    seq.start(env.agent.sequencer);


    `uvm_info(
      "BMU_RESET",
      "BMU reset sequence completed",
      UVM_LOW
    )


    phase.drop_objection(this);

  endtask : run_phase


endclass : bmu_reset_test
