//------------------------------------------------------------------------------
// wujian100_open_top test sanity
//------------------------------------------------------------------------------

class wujian100_open_top_test_sanity extends wujian100_open_top_test_base;

  `uvm_component_utils(wujian100_open_top_test_sanity)

  wujian100_open_top_test_vseq m_vseq_h;

  // Extern methods
  extern function               new(string name, uvm_component parent);
  extern virtual function void  build_phase(uvm_phase phase);
  extern virtual function void  connect_phase(uvm_phase phase);
  extern virtual task           vseq_run(uvm_phase phase);

endclass : wujian100_open_top_test_sanity


//------------------------------------------------------------------------------
// new
//------------------------------------------------------------------------------
function wujian100_open_top_test_sanity::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


//------------------------------------------------------------------------------
// build_phase
//------------------------------------------------------------------------------
function void wujian100_open_top_test_sanity::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_vseq_h = wujian100_open_top_test_vseq::type_id::create("m_vseq_h", this);
endfunction : build_phase


//------------------------------------------------------------------------------
// connect_phase
//------------------------------------------------------------------------------
function void wujian100_open_top_test_sanity::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction : connect_phase


//------------------------------------------------------------------------------
// vseq_run
//------------------------------------------------------------------------------
task wujian100_open_top_test_sanity::vseq_run(uvm_phase phase);
  m_vseq_h.start(m_vseqr_h);
  `uvm_info(get_full_name(), "send item finished ...", UVM_LOW)
endtask : vseq_run