class bmu_driver extends uvm_driver #(bmu_seq_item);

  `uvm_component_utils(bmu_driver)

  virtual bmu_if vif;

  function new(string name = "bmu_driver",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual bmu_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "BMU driver interface is not configured")

    if (vif == null)
      `uvm_fatal("NULLVIF", "BMU driver interface handle is null")
  endfunction

  virtual task run_phase(uvm_phase phase);

    // Initialize once; hold reset until a sequence releases it.
    @(vif.cb_drv);
    vif.cb_drv.rst_l         <= 1'b0;
    vif.cb_drv.scan_mode     <= 1'b0;
    vif.cb_drv.valid_in      <= 1'b0;
    vif.cb_drv.ap            <= '0;
    vif.cb_drv.csr_ren_in    <= 1'b0;
    vif.cb_drv.csr_rddata_in <= '0;
    vif.cb_drv.a_in          <= '0;
    vif.cb_drv.b_in          <= '0;

    forever begin
      @(vif.cb_drv);

      // Check for a new item at each falling edge.
      seq_item_port.try_next_item(req);

      if (req != null) begin
        drive_item(req);
        seq_item_port.item_done(); // notify the sequencer that the item is complete.
      end
      else begin
        vif.cb_drv.valid_in <= 1'b0; // disable result updates during gaps between requests.
      end

    end
  endtask

  // Called at cb_drv; preserve all requested control combinations.
  virtual task drive_item(bmu_seq_item tr);

    vif.cb_drv.rst_l         <= tr.rst_l;
    vif.cb_drv.scan_mode     <= tr.scan_mode;
    vif.cb_drv.valid_in      <= tr.valid_in;
    vif.cb_drv.ap            <= tr.ap;
    vif.cb_drv.csr_ren_in    <= tr.csr_ren_in;
    vif.cb_drv.csr_rddata_in <= tr.csr_rddata_in;
    vif.cb_drv.a_in          <= tr.a_in;
    vif.cb_drv.b_in          <= tr.b_in;

  endtask

endclass