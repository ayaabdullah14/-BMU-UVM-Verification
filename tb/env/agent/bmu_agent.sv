class bmu_agent extends uvm_agent;

  `uvm_component_utils(bmu_agent)

  bmu_driver    driver;
  bmu_monitor   monitor;
  bmu_sequencer sequencer;


  function new(string name = "bmu_agent",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // An active agent also needs a driver and sequencer.
    if (get_is_active() == UVM_ACTIVE) begin
      driver = bmu_driver::type_id::create("driver", this);
      sequencer = bmu_sequencer::type_id::create("sequencer", this);
       
    end

    monitor = bmu_monitor::type_id::create("monitor", this);// The monitor exists in both active and passive agents.


  endfunction


  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect the driver to the sequencer in active mode.
    if (get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(
        sequencer.seq_item_export);
    end

  endfunction

endclass