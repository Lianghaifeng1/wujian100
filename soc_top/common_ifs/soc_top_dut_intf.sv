interface soc_top_dut_intf;
  logic         sysclk;
  logic         sysrst_b;
  logic [31:0]  cpu_hmain0_m2_haddr;
  logic [2:0]   cpu_hmain0_m2_hburst;
  logic [3:0]   cpu_hmain0_m2_hprot;
  logic [2:0]   cpu_hmain0_m2_hsize;
  logic [1:0]   cpu_hmain0_m2_htrans;
  logic [31:0]  cpu_hmain0_m2_hwdata;
  logic         cpu_hmain0_m2_hwrite;
  logic [31:0]  hmain0_cpu_m2_hrdata;
  logic         hmain0_cpu_m2_hready;
  logic [1:0]   hmain0_cpu_m2_hresp;
endinterface
