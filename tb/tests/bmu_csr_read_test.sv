class bmu_csr_read_test extends bmu_base_test;

  `uvm_component_utils(bmu_csr_read_test)


  function new(
    string name = "bmu_csr_read_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    bmu_csr_read_sequence seq;

    phase.raise_objection(this);

    seq = bmu_csr_read_sequence::type_id::create("seq");


    `uvm_info(
      "BMU_CSR_READ",
      "Starting BMU CSR read sequence",
      UVM_LOW
    )


    seq.start(env.agent.sequencer);


    `uvm_info(
      "BMU_CSR_READ",
      "BMU CSR read sequence completed",
      UVM_LOW
    )


    phase.drop_objection(this);

  endtask : run_phase


endclass : bmu_csr_read_test
