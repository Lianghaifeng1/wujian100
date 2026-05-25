package soc_top_env_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum int {FM_MODE = 0, UVM_MODE = 1} soc_top_mode_e;

  `include "soc_top_common_transaction.sv"
  `include "soc_top_cfg.sv"
  `include "soc_top_dut_cfg.sv"
  `include "soc_top_ahb_monitor.sv"
  `include "soc_top_scoreboard.sv"
  `include "soc_top_env.sv"
endpackage
