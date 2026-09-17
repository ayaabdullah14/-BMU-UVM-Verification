class bmu_error_test extends bmu_base_test;

  `uvm_component_utils(bmu_error_test)


  function new(
    string name = "bmu_error_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_error_sequence seq;

    phase.raise_objection(this);

    seq = bmu_error_sequence::type_id::create("seq");


    `uvm_info(
      "BMU_ERROR",
      "Starting BMU negative/error sequence",
      UVM_LOW
    )


    seq.start(env.agent.sequencer);


    `uvm_info(
      "BMU_ERROR",
      "BMU negative/error sequence completed",
      UVM_LOW
    )


    phase.drop_objection(this);

  endtask : run_phase


endclass : bmu_error_test
