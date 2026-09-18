class bmu_env extends uvm_env;
  `uvm_component_utils(bmu_env)

  bmu_agent      agent;
  bmu_scoreboard scoreboard;
  bmu_subscriber   coverage;

  function new( string name = "bmu_env",    uvm_component parent = null  );
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agent = bmu_agent::type_id::create("agent", this); 
    scoreboard = bmu_scoreboard::type_id::create("scoreboard",this); 
    coverage = bmu_subscriber::type_id::create("subscriber",  this);
    
  endfunction


  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Send every monitored transaction to the scoreboard.
    agent.monitor.item_collected_port.connect(scoreboard.analysis_export  );
 

    // Send the same transaction to functional coverage.
    agent.monitor.item_collected_port.connect( coverage.analysis_export);
     
    `uvm_info(
      "BMU_ENV_CONNECT",
      "Connected monitor analysis port to scoreboard and coverage",
      UVM_LOW
    )
  endfunction

endclass