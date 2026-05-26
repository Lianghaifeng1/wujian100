module tb_top;
  //import uvm package
  import uvm_pkg::*;
  import dv_utils_pkg::*;
  // Import the DDVAPI AHB SV interface and the generic Mem interface
  import wujian100_open_top_env_pkg::*;
  import wujian100_open_top_test_pkg::*;

  //signals definition
  wire       h_clk;
  wire       h_rst;
  wire       sys_clk;
  wire       sys_rstn;
  reg        pon_rst;
  bit [31:0] stop_count;
  bit [31:0] timeout_count;
  reg        firmware_case_done;

  bit        sequence_starting;
  reg        dig_rstn;
  bit        soc_ahb_takeover_en;

  reg        pin_ehs_drv;
  reg        pin_els_drv;
  reg        pad_mcurst_drv;

  assign sys_clk  = h_clk;
  assign sys_rstn = h_rst;

  initial begin
    dig_rstn           = 1'b0;
    pon_rst            = 1'b0;
    sequence_starting  = 1'b0;
    wait (sys_rstn === 1'b1);
    #100ns;
    dig_rstn          = 1'b1;
    pon_rst           = 1'b1;
    sequence_starting = 1'b1;
  end

  initial begin
    pin_ehs_drv = 1'b0;
    forever #10ns pin_ehs_drv = ~pin_ehs_drv;
  end

  initial begin
    pin_els_drv = 1'b0;
    forever #15.258789us pin_els_drv = ~pin_els_drv;
  end

  initial begin
    pad_mcurst_drv = 1'b0;
    #20us;
    pad_mcurst_drv = 1'b1;
  end

  wujian100_open_top_dut_intf dut_intf();

`ifndef ONLY_COMP_TB
  //instantiate DUT
  `include "dut_inst.sv"

  assign PIN_EHS    = pin_ehs_drv;
  assign PIN_ELS    = pin_els_drv;
  assign PAD_MCURST = pad_mcurst_drv;
  assign PAD_JTAG_TMS = 1'b1;

  assign h_clk = u_wujian100_open_top.pmu_hmain0_hclk;
  assign h_rst = u_wujian100_open_top.pmu_hmain0_hrst_b;

  initial begin
    #1us;
    dig_rstn = 1'b1;
  end
`endif

  reg error_flag;
  reg c_end_flag;
  assign dut_intf.clk                = sys_clk;
  assign dut_intf.rst_n              = sys_rstn;
  assign dut_intf.sequence_starting  = sequence_starting;
  assign dut_intf.stop_count         = stop_count;
  assign dut_intf.timeout_count      = timeout_count;
  assign dut_intf.firmware_case_done = firmware_case_done;
  assign dut_intf.firmware_data_error= error_flag;
  assign dut_intf.c_end_flag         = c_end_flag;

  wire tran_valid = 1'b1;
  reg  bus_tran_d1;
  reg  bus_tran_d2;

  wire bus_tran_chg = (bus_tran_d1 != bus_tran_d2);
  reg  bus_tran_chg_d1;
  wire bus_valid    = bus_tran_chg | bus_tran_chg_d1;

  always @(posedge sys_clk or negedge sys_rstn) begin
    if (sys_rstn != 1'b1) begin
      bus_tran_d1     <= 1'b0;
      bus_tran_d2     <= 1'b0;
      bus_tran_chg_d1 <= 1'b0;
    end else begin
      bus_tran_d1     <= tran_valid;
      bus_tran_d2     <= bus_tran_d1;
      bus_tran_chg_d1 <= bus_tran_chg;
    end
  end

  wire clear_dmac_en;
  assign clear_dmac_en = (bus_valid === 1'b1) || 1'b0;
  wire clear_en;
  assign clear_en = clear_dmac_en;

  always @(posedge sys_clk or negedge sys_rstn) begin
    if (!sys_rstn) begin
      stop_count <= 32'd0;
    end else if (clear_en === 1'b1) begin
      stop_count <= 32'd0;
    end else if (clear_en == 1'b0) begin
      stop_count <= stop_count + 1;
    end
  end

  always @(posedge sys_clk or negedge sys_rstn) begin
    if (!sys_rstn) begin
      timeout_count <= 32'd0;
    end else if (clear_en === 1'b1) begin
      timeout_count <= timeout_count + 1;
    end else begin
      timeout_count <= 32'd0;
    end
  end

  integer start_dump = 0;
  integer end_dump   = 0;
  `ifdef FSDB
  initial begin
    if ($test$plusargs("WAVE_DUMP_EN")) begin
      if ($value$plusargs("START_TIME=%d", start_dump)) begin
        repeat (start_dump) begin
          #1us;
        end
      end

      $fsdbDumpfile("wujian100_open_top.fsdb");
      $fsdbDumpvars(0, tb_top);
      $fsdbDumpSVA(0, tb_top);
      $fsdbDumpMDA(0, tb_top);
      $fsdbDumpon;

      if ($value$plusargs("END_TIME=%d", end_dump)) begin
        repeat ((end_dump - start_dump)) begin
          #1us;
        end
        $fsdbDumpoff;
      end
    end
  end
  `endif

  clk_rst_if hclk_rst_if(
    .clk  (h_clk),
    .rst_n(h_rst)
  );



  cdnAhbInterface #(
    .NUM_OF_SLAVES      (`CDN_AHB_NUM_OF_SLAVES),
    .NUM_OF_MASTERS     (`CDN_AHB_NUM_OF_MASTERS),
    .ADDRESS_WIDTH      (`CDN_AHB_ADDRESS_WIDTH),
    .DATA_WIDTH         (`CDN_AHB_DATA_WIDTH),
    .DEFAULT_SLAVE_IDX  (`CDN_AHB_DEFAULT_SLAVE_IDX)
  ) Bus (h_clk, h_rst);

  initial begin
    uvm_config_string::set(null, $sformatf("*uvm_test_top.m_env_h.activeArbiter"),
                           "hdlPath", $sformatf("tb_top.Bus.activeArbiter"));
    uvm_config_string::set(null, $sformatf("*uvm_test_top.m_env_h.activeDecoder"),
                           "hdlPath", $sformatf("tb_top.Bus.decoder"));
    uvm_config_string::set(null, $sformatf("*uvm_test_top.m_env_h.m_reg_bus_mon_agt_h"),
                           "hdlPath", $sformatf("tb_top.Bus.master[0].passive_master"));
  end

  generate
    for (genvar i = 0; i < `CDN_AHB_NUM_OF_MASTERS; i++) begin : mst_bus_if
      initial begin
        uvm_config_string::set(null, $sformatf("*uvm_test_top.m_env_h.m_ahb_mst_agt_h[%0d]", i),
                               "hdlPath", $sformatf("tb_top.Bus.master[%0d].active_master", i));
      end
    end
  endgenerate

  generate
    for (genvar i = 0; i < `CDN_AHB_NUM_OF_SLAVES; i++) begin : slv_bus_if
      initial begin
        uvm_config_string::set(null, $sformatf("*uvm_test_top.m_env_h.m_ahb_slv_agt_h[%0d]", i),
                               "hdlPath", $sformatf("tb_top.Bus.slave[%0d].active_slave", i));
      end
    end
  endgenerate
initial begin
    $timeformat(-9, 3, "ns", 10);
`ifdef ONLY_COMP_TB
hclk_rst_if.set_active(
      .drive_clk_val  (1),
      .drive_rst_n_val(1)
    );
`else
hclk_rst_if.set_active(
      .drive_clk_val  (0),
      .drive_rst_n_val(0)
    );
`endif
uvm_config_db#(wujian100_open_top_dut_vif)::set(null, "uvm_test_top", "vif", dut_intf);

uvm_config_db#(wujian100_open_top_dut_vif)::set(null, "uvm_test_top.m_vseqr_h", "vif", dut_intf);

uvm_config_db#(virtual interface clk_rst_if)::set(
      null,
      "uvm_test_top.m_vseqr_h",
      "hclk_rst_vif",
      hclk_rst_if
    );
run_test();  // run_test
  end

  reg error_flag_l;
  initial begin
    error_flag_l = 1'b0;
    error_flag   = 1'b0;
    c_end_flag   = 1'b0;
  end

`ifndef ONLY_COMP_TB
  initial begin
    soc_ahb_takeover_en = !$test$plusargs("NO_AHB_VIP_TAKEOVER");
    wait (h_rst === 1'b1);
    repeat (5) @(posedge h_clk);
    if (soc_ahb_takeover_en) begin
      apply_ahb_vip_cpu_takeover();
    end
  end

  task automatic apply_ahb_vip_cpu_takeover();
    $display("[%0t] AHB VIP takes over CPU AHB master port m2", $time);

    force Bus.hgrant[0]  = 1'b1;
    force Bus.hmaster    = 4'h0;
    force Bus.hmastlock  = 1'b0;

    force u_wujian100_open_top.cpu_hmain0_m0_haddr   = 32'h0;
    force u_wujian100_open_top.cpu_hmain0_m0_hburst  = 3'h0;
    force u_wujian100_open_top.cpu_hmain0_m0_hprot   = 4'h0;
    force u_wujian100_open_top.cpu_hmain0_m0_hsize   = 3'h2;
    force u_wujian100_open_top.cpu_hmain0_m0_htrans  = 2'h0;
    force u_wujian100_open_top.cpu_hmain0_m0_hwdata  = 32'h0;
    force u_wujian100_open_top.cpu_hmain0_m0_hwrite  = 1'b0;

    force u_wujian100_open_top.cpu_hmain0_m1_haddr   = 32'h0;
    force u_wujian100_open_top.cpu_hmain0_m1_hburst  = 3'h0;
    force u_wujian100_open_top.cpu_hmain0_m1_hprot   = 4'h0;
    force u_wujian100_open_top.cpu_hmain0_m1_hsize   = 3'h2;
    force u_wujian100_open_top.cpu_hmain0_m1_htrans  = 2'h0;
    force u_wujian100_open_top.cpu_hmain0_m1_hwdata  = 32'h0;
    force u_wujian100_open_top.cpu_hmain0_m1_hwrite  = 1'b0;

    force u_wujian100_open_top.cpu_hmain0_m2_haddr   = Bus.haddr[0];
    force u_wujian100_open_top.cpu_hmain0_m2_hburst  = Bus.hburst[0];
    force u_wujian100_open_top.cpu_hmain0_m2_hprot   = Bus.hprot[0];
    force u_wujian100_open_top.cpu_hmain0_m2_hsize   = Bus.hsize[0];
    force u_wujian100_open_top.cpu_hmain0_m2_htrans  = Bus.htrans[0];
    force u_wujian100_open_top.cpu_hmain0_m2_hwdata  = Bus.hwdata[0];
    force u_wujian100_open_top.cpu_hmain0_m2_hwrite  = Bus.hwrite[0];

    force Bus.hrdata[0] = u_wujian100_open_top.hmain0_cpu_m2_hrdata;
    force Bus.hready[0] = u_wujian100_open_top.hmain0_cpu_m2_hready;
    force Bus.hresp[0]  = u_wujian100_open_top.hmain0_cpu_m2_hresp;
  endtask
`endif

endmodule
