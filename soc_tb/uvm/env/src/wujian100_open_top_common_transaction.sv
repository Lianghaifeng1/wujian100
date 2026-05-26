class wujian100_open_top_common_transaction extends uvm_sequence_item;
  // *****************************************************************
  // * Begin enum type definition
  // *****************************************************************
  // (add your enum typedefs here)
  // *****************************************************************
  // * End enum type definition
  // *****************************************************************

  // *****************************************************************
  // * Begin variable definition
  // *****************************************************************
  rand bit [31:0] m_addr;         // define m_addr
  rand bit  [7:0] m_data[];       // define m_data[]
  rand bit        m_wr_en;        // define m_wr_en
  rand bit [31:0] m_tr_id;        // define m_tr_id
  rand bit [31:0] m_transfer_cnt; // define m_transfer_cnt
  rand bit  [3:0] m_burst_size;   // define m_burst_size
  rand bit  [3:0] m_burst_type;   // define m_burst_type
  rand bit  [3:0] m_prot;         // define m_prot
  rand bit  [1:0] m_response[];   // define m_response[]
  // *****************************************************************
  // * End variable definition
  // *****************************************************************

  // *****************************************************************
  // * Begin constant type definition
  // *****************************************************************
  // (add your localparams/typedefs here)
  // *****************************************************************
  // * End constant type definition
  // *****************************************************************

  // *****************************************************************
  // * Begin constraint definition
  // *****************************************************************
  constraint addr_typical;       // typical constraint for m_addr variable
  constraint data_typical;       // typical constraint for m_data variable
  constraint wr_en_typical;      // typical constraint for m_wr_en variable
  constraint tr_id_typical;      // typical constraint for m_tr_id variable
  constraint transfer_cnt_typical; // typical constraint for m_transfer_cnt variable
  constraint burst_size_typical; // typical constraint for m_burst_size variable
  constraint burst_type_typical; // typical constraint for m_burst_type variable
  constraint prot_typical;       // typical constraint for m_prot variable
  constraint response_typical;   // typical constraint for m_response variable
  // *****************************************************************
  // * End constraint definition
  // *****************************************************************

  // *****************************************************************
  // * Begin variable register definition
  // *****************************************************************
  `uvm_object_utils_begin(wujian100_open_top_common_transaction)
    // `uvm_field_array_int(m_data, UVM_ALL_ON | UVM_NOPACK | UVM_NOCOPY | UVM_NOCOMPARE | UVM_NOPRINT)
    `uvm_field_array_int(m_data,     UVM_ALL_ON)
    `uvm_field_int      (m_addr,     UVM_ALL_ON)
    `uvm_field_int      (m_wr_en,    UVM_ALL_ON)
    `uvm_field_int      (m_tr_id,    UVM_ALL_ON)
    `uvm_field_int      (m_transfer_cnt, UVM_ALL_ON)
    `uvm_field_int      (m_burst_size,   UVM_ALL_ON)
    `uvm_field_int      (m_burst_type,   UVM_ALL_ON)
    `uvm_field_int      (m_prot,     UVM_ALL_ON)
    `uvm_field_array_int(m_response, UVM_ALL_ON)
  `uvm_object_utils_end
  // *****************************************************************
  // * End variable register definition
  // *****************************************************************

  // *****************************************************************
  // * Begin method declaration
  // *****************************************************************
  extern function new(string name = "wujian100_open_top_common_transaction");
  extern function void pre_randomize();
  extern function void post_randomize();
  // *****************************************************************
  // * End method declaration
  // *****************************************************************
endclass : wujian100_open_top_common_transaction


// *******************************************************************
// * new() function
// *******************************************************************
function wujian100_open_top_common_transaction::new(string name = "wujian100_open_top_common_transaction");
  super.new(name);
endfunction : new


// *******************************************************************
// * pre_randomize() function
// *******************************************************************
function void wujian100_open_top_common_transaction::pre_randomize();
  `uvm_info("WUJIAN100_OPEN_TOP_COMMON_TRANSACTION", $sformatf("pre_randomize"), UVM_LOW)
endfunction : pre_randomize


// *******************************************************************
// * post_randomize() function
// *******************************************************************
function void wujian100_open_top_common_transaction::post_randomize();
  `uvm_info("WUJIAN100_OPEN_TOP_COMMON_TRANSACTION", $sformatf("post_randomize"), UVM_LOW)
endfunction : post_randomize


// *******************************************************************
// * Begin external constraint definition
// *******************************************************************
constraint wujian100_open_top_common_transaction::addr_typical {
  // m_addr
}

constraint wujian100_open_top_common_transaction::data_typical {
  // m_data
}

constraint wujian100_open_top_common_transaction::wr_en_typical {
  // m_wr_en
}

constraint wujian100_open_top_common_transaction::tr_id_typical {
  // m_tr_id
}

constraint wujian100_open_top_common_transaction::transfer_cnt_typical {
  // m_transfer_cnt
}

constraint wujian100_open_top_common_transaction::burst_size_typical {
  // m_burst_size
}

constraint wujian100_open_top_common_transaction::burst_type_typical {
  // m_burst_type
}

constraint wujian100_open_top_common_transaction::prot_typical {
  // m_prot
}

constraint wujian100_open_top_common_transaction::response_typical {
  // m_response
}
// *******************************************************************
// * End external constraint definition
// *******************************************************************