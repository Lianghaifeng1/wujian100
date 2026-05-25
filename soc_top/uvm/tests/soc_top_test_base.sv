class soc_top_test_base extends soc_top_test_common;
  `uvm_component_utils(soc_top_test_base)

  soc_top_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = soc_top_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    repeat (cfg.timeout_cycles) @(posedge vif.sysclk);
    if (cfg.soc_mode == FM_MODE) begin
      `uvm_error("TIMEOUT", "FM_MODE timeout before firmware final result")
    end
    phase.drop_objection(this);
  endtask
endclass
