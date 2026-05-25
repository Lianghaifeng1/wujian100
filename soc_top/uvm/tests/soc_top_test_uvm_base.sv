class soc_top_test_uvm_base extends soc_top_test_base;
  `uvm_component_utils(soc_top_test_uvm_base)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    if (cfg.soc_mode != UVM_MODE) begin
      `uvm_fatal("MODE", "soc_top_test_uvm_base requires CASE_NAME=soc_top*")
    end
  endfunction

  task run_phase(uvm_phase phase);
    soc_top_reg_access_vseq vseq;
    phase.raise_objection(this);
    vseq = soc_top_reg_access_vseq::type_id::create("vseq");
    vseq.start(null);
    repeat (cfg.idle_cycles) @(posedge vif.sysclk);
    phase.drop_objection(this);
  endtask
endclass
