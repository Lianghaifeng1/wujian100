// uvm_macros.svh is included in tb_top_define.sv, no need to include here
import uvm_pkg::*;

class wujian100_open_top_word_access_regs_model extends uvm_reg_block;

  `uvm_object_utils(wujian100_open_top_word_access_regs_model)

  function new(input string name = "wujian100_open_top_word_access_regs_model");
    super.new(name, UVM_NO_COVERAGE);
  endfunction : new

  virtual function void build();
    default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN, 1);
  endfunction : build

endclass