class bmu_csr_write_test extends bmu_base_test;

  `uvm_component_utils(bmu_csr_write_test)


  function new(
    string name = "bmu_csr_write_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_csr_write_sequence seq;

    phase.raise_objection(this);

    seq = bmu_csr_write_sequence::type_id::create("seq");


    `uvm_info(
      "BMU_CSR_WRITE",
      "Starting BMU CSR write sequence",
      UVM_LOW
    )


    seq.start(env.agent.sequencer);


    `uvm_info(
      "BMU_CSR_WRITE",
      "BMU CSR write sequence completed",
      UVM_LOW
    )


    phase.drop_objection(this);

  endtask : run_phase


endclass : bmu_csr_write_test
