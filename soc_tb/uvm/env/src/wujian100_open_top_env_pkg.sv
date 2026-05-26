`include "wujian100_open_top_dut_intf.sv"

package wujian100_open_top_env_pkg;

  import uvm_pkg::*;

  // UVM REG pkgs
  import uvmreg_byte_pkg::*;
  import uvmreg_word_pkg::*;
  // Import the DDVAPI AHB SV interface and the generic Mem interface
  import DenaliSvCdn_ahb::*;
  import DenaliSvMem::*;
  // Include the VIP UVM base classes
  import cdnAhbUvm::*;

  typedef virtual wujian100_open_top_dut_intf wujian100_open_top_dut_vif;

  // uvm_macros.svh is included in tb_top_define.sv, no need to include here
  `include "wujian100_open_top_env_define.sv"

  // dut cfg
  `include "wujian100_open_top_dut_cfg.sv"
  `include "wujian100_open_top_cfg.sv"

  // environment
  `include "wujian100_open_top_common_transaction.sv"
  `include "wujian100_open_top_scoreboard.sv"
  `include "wujian100_open_top_ref_model.sv"
  `include "wujian100_open_top_env.sv"

endpackage : wujian100_open_top_env_pkg