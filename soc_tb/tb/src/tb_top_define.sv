

`define AHB_MST_AGENT_NUM        1


`define AHB_SLV_AGENT_NUM        1


`define WUJIAN100_OPEN_TOP                              tb_top.u_wujian100_open_top

`define WUJIAN100_OPEN_TOP_MODEL                       m_cfg_h.m_dut_cfg_h.m_regs_model_h
`define WUJIAN100_OPEN_TOP_MODEL_WORD_ACCESS_MODEL     m_cfg_h.m_dut_cfg_h.m_word_regs_model_h


`include "dv_macros.svh"
// uvm_macros.svh is automatically included by -uvm option in Makefile, no need to include here
`include "common_ifs_pkg.sv"
`include "clk_rst_if.sv"
`include "pins_if.sv"

// vip agent pkg (included via Makefile VIP_SRC, not here)
// VIP packages are compiled separately in Makefile before this file

// DUT package (if specified)
// env pkg
`include "uvmreg_byte_pkg.sv"
`include "uvmreg_word_pkg.sv"

`include "wujian100_open_top_env_pkg.sv"
`include "wujian100_open_top_test_pkg.sv"