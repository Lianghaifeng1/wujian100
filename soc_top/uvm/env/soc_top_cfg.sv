class soc_top_cfg extends uvm_object;
  string case_name;
  soc_top_mode_e soc_mode;
  bit enable_sw_load;
  bit enable_ahb_active;
  bit enable_ahb_monitor;
  bit hold_cpu_in_reset_in_uvm_mode;
  string sw_pat_path;
  int unsigned timeout_cycles;
  int unsigned idle_cycles;

  `uvm_object_utils_begin(soc_top_cfg)
    `uvm_field_string(case_name, UVM_DEFAULT)
    `uvm_field_enum(soc_top_mode_e, soc_mode, UVM_DEFAULT)
    `uvm_field_int(enable_sw_load, UVM_DEFAULT)
    `uvm_field_int(enable_ahb_active, UVM_DEFAULT)
    `uvm_field_int(enable_ahb_monitor, UVM_DEFAULT)
    `uvm_field_int(hold_cpu_in_reset_in_uvm_mode, UVM_DEFAULT)
    `uvm_field_string(sw_pat_path, UVM_DEFAULT)
    `uvm_field_int(timeout_cycles, UVM_DEFAULT)
    `uvm_field_int(idle_cycles, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "soc_top_cfg");
    super.new(name);
    case_name = "";
    soc_mode = FM_MODE;
    enable_sw_load = 0;
    enable_ahb_active = 0;
    enable_ahb_monitor = 1;
    hold_cpu_in_reset_in_uvm_mode = 1;
    sw_pat_path = "";
    timeout_cycles = 1000000;
    idle_cycles = 100;
  endfunction
endclass
