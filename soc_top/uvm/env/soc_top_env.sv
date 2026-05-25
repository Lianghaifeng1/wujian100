class soc_top_env extends uvm_env;
  `uvm_component_utils(soc_top_env)

  soc_top_ahb_monitor ahb_monitor;
  soc_top_scoreboard scoreboard;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_monitor = soc_top_ahb_monitor::type_id::create("ahb_monitor", this);
    scoreboard = soc_top_scoreboard::type_id::create("scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ahb_monitor.ap.connect(scoreboard.item_export);
  endfunction
endclass
