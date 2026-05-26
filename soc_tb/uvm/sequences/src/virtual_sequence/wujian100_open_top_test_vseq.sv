class wujian100_open_top_test_vseq extends wujian100_open_top_test_base_vseq;
  `uvm_object_utils(wujian100_open_top_test_vseq)

  extern function new(string name="wujian100_open_top_test_vseq");
  extern virtual task body();

endclass : wujian100_open_top_test_vseq

function wujian100_open_top_test_vseq::new(string name="wujian100_open_top_test_vseq");
  super.new(name);
endfunction : new

task wujian100_open_top_test_vseq::body();
  bit [31:0] rdata;

  if(starting_phase != null) begin
    starting_phase.raise_objection(this);
  end
  `uvm_info(get_name(),"start virtual sequence",UVM_LOW)

  hclk_rst_vif.wait_for_reset(.wait_negedge(1'b0), .wait_posedge(1'b1));
  hclk_rst_vif.wait_clks(20);

  wr_reg32(32'h6001_8004, 32'hFFFF_FFFF);
  wr_reg32(32'h6001_8000, 32'hA5A5_5A5A);
  rd_reg32(32'h6001_8000, rdata);
  `uvm_info(get_name(), $sformatf("GPIO0 SWPORT_DR readback = 0x%08x", rdata), UVM_LOW)

  if(starting_phase != null) begin
    starting_phase.drop_objection(this);
  end
endtask : body
