class soc_top_test_common extends uvm_test;
  `uvm_component_utils(soc_top_test_common)

  soc_top_cfg cfg;
  virtual soc_top_dut_intf vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(soc_top_cfg)::get(this, "", "soc_top_cfg", cfg)) begin
      `uvm_fatal("NOCFG", "soc_top_cfg is not configured")
    end
    if (cfg.case_name == "") begin
      `uvm_fatal("CASE", "Empty CASE_NAME")
    end
    if (!uvm_config_db#(virtual soc_top_dut_intf)::get(this, "", "soc_top_dut_vif", vif)) begin
      `uvm_fatal("NOVIF", "soc_top_dut_vif is not configured")
    end
  endfunction
endclass
