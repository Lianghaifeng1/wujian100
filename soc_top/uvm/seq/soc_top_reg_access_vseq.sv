class soc_top_reg_access_vseq extends soc_top_test_base_vseq;
  `uvm_object_utils(soc_top_reg_access_vseq)

  localparam string CPU_AHB_PATH = "tb_top.x_wujian100_open_top";
  localparam string CPU_RST_PATH = "tb_top.x_wujian100_open_top.x_cpu_top.pad_cpu_rst_b";

  function new(string name = "soc_top_reg_access_vseq");
    super.new(name);
  endfunction

  task body();
    super.body();
    if (cfg.soc_mode != UVM_MODE) begin
      `uvm_info("SKIP", "soc_top_reg_access_vseq runs only in UVM_MODE", UVM_LOW)
      return;
    end
    wait (vif.sysrst_b === 1'b1);
    repeat (10) @(posedge vif.sysclk);
    isolate_cpu();
    ahb_write(32'h2000_7c50, 32'h5555_aaaa);
    ahb_idle();
    repeat (cfg.idle_cycles) @(posedge vif.sysclk);
    release_cpu_ahb();
  endtask

  task isolate_cpu();
    if (cfg.hold_cpu_in_reset_in_uvm_mode) begin
      void'(uvm_hdl_force(CPU_RST_PATH, 1'b0));
      repeat (5) @(posedge vif.sysclk);
    end
  endtask

  task ahb_write(bit [31:0] addr, bit [31:0] data);
    `uvm_info("AHB_WRITE", $sformatf("force AHB write addr=0x%08h data=0x%08h", addr, data), UVM_MEDIUM)
    void'(uvm_hdl_force({CPU_AHB_PATH, ".cpu_hmain0_m2_haddr"}, addr));
    void'(uvm_hdl_force({CPU_AHB_PATH, ".cpu_hmain0_m2_hburst"}, 3'b000));
    void'(uvm_hdl_force({CPU_AHB_PATH, ".cpu_hmain0_m2_hprot"}, 4'b0011));
    void'(uvm_hdl_force({CPU_AHB_PATH, ".cpu_hmain0_m2_hsize"}, 3'b010));
    void'(uvm_hdl_force({CPU_AHB_PATH, ".cpu_hmain0_m2_hwrite"}, 1'b1));
    void'(uvm_hdl_force({CPU_AHB_PATH, ".cpu_hmain0_m2_hwdata"}, data));
    void'(uvm_hdl_force({CPU_AHB_PATH, ".cpu_hmain0_m2_htrans"}, 2'b10));
    @(posedge vif.sysclk);
    wait (vif.hmain0_cpu_m2_hready === 1'b1);
    @(posedge vif.sysclk);
  endtask

  task ahb_idle();
    void'(uvm_hdl_force({CPU_AHB_PATH, ".cpu_hmain0_m2_htrans"}, 2'b00));
    void'(uvm_hdl_force({CPU_AHB_PATH, ".cpu_hmain0_m2_hwrite"}, 1'b0));
  endtask

  task release_cpu_ahb();
    void'(uvm_hdl_release({CPU_AHB_PATH, ".cpu_hmain0_m2_haddr"}));
    void'(uvm_hdl_release({CPU_AHB_PATH, ".cpu_hmain0_m2_hburst"}));
    void'(uvm_hdl_release({CPU_AHB_PATH, ".cpu_hmain0_m2_hprot"}));
    void'(uvm_hdl_release({CPU_AHB_PATH, ".cpu_hmain0_m2_hsize"}));
    void'(uvm_hdl_release({CPU_AHB_PATH, ".cpu_hmain0_m2_hwrite"}));
    void'(uvm_hdl_release({CPU_AHB_PATH, ".cpu_hmain0_m2_hwdata"}));
    void'(uvm_hdl_release({CPU_AHB_PATH, ".cpu_hmain0_m2_htrans"}));
    void'(uvm_hdl_release(CPU_RST_PATH));
  endtask
endclass
