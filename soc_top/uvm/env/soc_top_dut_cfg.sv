class soc_top_dut_cfg extends uvm_object;
  string cpu_ahb_path = "tb_top.x_wujian100_open_top";
  string cpu_reset_path = "tb_top.x_wujian100_open_top.x_cpu_top.pad_cpu_rst_b";

  `uvm_object_utils_begin(soc_top_dut_cfg)
    `uvm_field_string(cpu_ahb_path, UVM_DEFAULT)
    `uvm_field_string(cpu_reset_path, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "soc_top_dut_cfg");
    super.new(name);
  endfunction
endclass
