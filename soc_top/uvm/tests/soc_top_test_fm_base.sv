class soc_top_test_fm_base extends soc_top_test_base;
  `uvm_component_utils(soc_top_test_fm_base)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    if (cfg.soc_mode != FM_MODE) begin
      `uvm_fatal("MODE", "soc_top_test_fm_base requires CASE_NAME=fm_test*")
    end
    `uvm_info("FM_MODE", $sformatf("firmware preload path: %0s", cfg.sw_pat_path), UVM_LOW)
  endfunction
endclass
