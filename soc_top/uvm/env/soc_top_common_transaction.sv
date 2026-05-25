class soc_top_common_transaction extends uvm_sequence_item;
  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand bit        write;
  rand bit [1:0]  trans;
  rand bit [1:0]  resp;
  rand bit        ready;
  time            sample_time;

  `uvm_object_utils_begin(soc_top_common_transaction)
    `uvm_field_int(addr, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(write, UVM_DEFAULT)
    `uvm_field_int(trans, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(resp, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(ready, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "soc_top_common_transaction");
    super.new(name);
  endfunction
endclass
