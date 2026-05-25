class soc_top_test_base_vseq extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(soc_top_test_base_vseq)

  soc_top_cfg cfg;
  virtual soc_top_dut_intf vif;

  function new(string name = "soc_top_test_base_vseq");
    super.new(name);
  endfunction

  task body();
    if (!uvm_config_db#(soc_top_cfg)::get(null, "*", "soc_top_cfg", cfg)) begin
      `uvm_fatal("NOCFG", "soc_top_cfg is not configured")
    end
    if (!uvm_config_db#(virtual soc_top_dut_intf)::get(null, "*", "soc_top_dut_vif", vif)) begin
      `uvm_fatal("NOVIF", "soc_top_dut_vif is not configured")
    end
  endtask
endclass
