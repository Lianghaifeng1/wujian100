class soc_top_ahb_monitor extends uvm_component;
  `uvm_component_utils(soc_top_ahb_monitor)

  virtual soc_top_dut_intf vif;
  uvm_analysis_port #(soc_top_common_transaction) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual soc_top_dut_intf)::get(this, "", "soc_top_dut_vif", vif)) begin
      `uvm_fatal("NOVIF", "soc_top_dut_vif is not configured")
    end
  endfunction

  task run_phase(uvm_phase phase);
    soc_top_common_transaction tr;
    forever begin
      @(posedge vif.sysclk);
      if (vif.sysrst_b && vif.hmain0_cpu_m2_hready && vif.cpu_hmain0_m2_htrans[1]) begin
        tr = soc_top_common_transaction::type_id::create("tr", this);
        tr.addr = vif.cpu_hmain0_m2_haddr;
        tr.write = vif.cpu_hmain0_m2_hwrite;
        tr.trans = vif.cpu_hmain0_m2_htrans;
        tr.ready = vif.hmain0_cpu_m2_hready;
        tr.resp = vif.hmain0_cpu_m2_hresp;
        tr.sample_time = $time;
        tr.data = vif.cpu_hmain0_m2_hwrite ? vif.cpu_hmain0_m2_hwdata : vif.hmain0_cpu_m2_hrdata;
        ap.write(tr);
      end
    end
  endtask
endclass
