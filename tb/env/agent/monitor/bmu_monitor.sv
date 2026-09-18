class bmu_monitor extends uvm_monitor;

  `uvm_component_utils(bmu_monitor)

  virtual bmu_if vif;

  bmu_seq_item transaction;

  uvm_analysis_port #(bmu_seq_item) item_collected_port;  // Sends captured transactions to scoreboard and coverage.


  function new(string name = "bmu_monitor",
               uvm_component parent = null);
    super.new(name, parent);

    item_collected_port = new("item_collected_port", this);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual bmu_if)::get(this, "", "vif", vif)) // Get the interface from the configuration database.
      `uvm_fatal("NO_VIF",{"Please set the interface for ", get_full_name()})
  endfunction


  virtual task run_phase(uvm_phase phase);

    forever begin

      transaction = bmu_seq_item::type_id::create("transaction");

      capture_bmu_signals(transaction);      // Capture the current BMU signals.
      // Send the captured transaction to subscribers.
      item_collected_port.write(transaction);
    end

  endtask


  virtual task capture_bmu_signals(bmu_seq_item trans);  // Capture all BMU inputs and outputs at the monitor clock event.

    @(vif.cb_mon);

    // Capture DUT inputs.
    trans.rst_l         = vif.cb_mon.rst_l;
    trans.scan_mode     = vif.cb_mon.scan_mode;
    trans.valid_in      = vif.cb_mon.valid_in;
    trans.ap            = vif.cb_mon.ap;
    trans.csr_ren_in    = vif.cb_mon.csr_ren_in;
    trans.csr_rddata_in = vif.cb_mon.csr_rddata_in;
    trans.a_in          = vif.cb_mon.a_in;
    trans.b_in          = vif.cb_mon.b_in;

    // Capture DUT outputs.
    trans.result_ff     = vif.cb_mon.result_ff;
    trans.error         = vif.cb_mon.error;

  endtask

endclass