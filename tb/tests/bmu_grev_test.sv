class bmu_grev_test extends bmu_base_test;

  `uvm_component_utils(bmu_grev_test)


  function new(
    string name = "bmu_grev_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_grev_sequence seq;

    phase.raise_objection(this);

    seq = bmu_grev_sequence::type_id::create("seq");


    `uvm_info(
      "BMU_GREV",
      "Starting BMU GREV sequence",
      UVM_LOW
    )


    seq.start(env.agent.sequencer);


    `uvm_info(
      "BMU_GREV",
      "BMU GREV sequence completed",
      UVM_LOW
    )


    phase.drop_objection(this);

  endtask : run_phase


endclass : bmu_grev_test
