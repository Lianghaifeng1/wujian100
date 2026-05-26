class wujian100_open_top_dut_cfg extends uvm_object;

  `uvm_object_utils_begin(wujian100_open_top_dut_cfg)
    // `uvm_field_object(xxx, UVM_ALL_ON)
  `uvm_object_utils_end


  wujian100_open_top_regs_model  m_regs_model_h;  // m_regs_model_h
  wujian100_open_top_word_access_regs_model  m_word_regs_model_h;  // m_regs_model_h
  uvm_path_e                   m_path;          // operation path for backdoor or frontdoor. default: frontdoor


  extern function new(string name = "wujian100_open_top_dut_cfg");

endclass : wujian100_open_top_dut_cfg


function wujian100_open_top_dut_cfg::new(string name = "wujian100_open_top_dut_cfg");
  super.new(name);
endfunction : new