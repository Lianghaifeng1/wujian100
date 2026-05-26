class wujian100_open_top_test_base_seq extends uvm_sequence#(uvm_sequence_item);

`uvm_object_utils(wujian100_open_top_test_base_seq)

wujian100_open_top_cfg     m_cfg_h;
wujian100_open_top_dut_vif m_dut_vif_h;

function new(string name = "wujian100_open_top_test_base_seq");
  super.new(name);
endfunction : new

virtual function void set_config(wujian100_open_top_cfg cfg, wujian100_open_top_dut_vif vif);
  this.m_cfg_h     = cfg;
  this.m_dut_vif_h = vif;
endfunction : set_config

endclass : wujian100_open_top_test_base_seq