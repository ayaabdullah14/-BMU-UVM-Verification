class bmu_valid_in_test extends bmu_base_test;

  `uvm_component_utils(bmu_valid_in_test)


  function new(
    string name = "bmu_valid_in_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_valid_in_sequence seq;

    phase.raise_objection(this);

    seq = bmu_valid_in_sequence::type_id::create("seq");


    `uvm_info(
      "BMU_VALID_IN",
      "Starting BMU valid_in sequence",
      UVM_LOW
    )


    seq.start(env.agent.sequencer);


    `uvm_info(
      "BMU_VALID_IN",
      "BMU valid_in sequence completed",
      UVM_LOW
    )


    phase.drop_objection(this);

  endtask : run_phase


endclass : bmu_valid_in_test
