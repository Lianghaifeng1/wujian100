 
class wujian100_open_top_cfg extends uvm_object;

  // ------------------------------------------------------------
  // presence flags (per-agent)
  // ------------------------------------------------------------
  

  
  
  bit m_has_ahb_mst_agt_en[`AHB_MST_AGENT_NUM ];
  
  bit m_has_ahb_slv_agt_en[`AHB_SLV_AGENT_NUM ];
  
  

  // ------------------------------------------------------------
  // basic knobs
  // ------------------------------------------------------------
  integer m_stop_value;
  integer m_timeout_value;
  integer m_check_log_start_time;

  // ------------------------------------------------------------
  // agent cfg handles
  // ------------------------------------------------------------
  

  
  
  rand cdnAhbUvmConfig m_ahb_mst_agt_cfg_h[`AHB_MST_AGENT_NUM ];
  
  rand cdnAhbUvmConfig m_ahb_slv_agt_cfg_h[`AHB_SLV_AGENT_NUM ];
  
  

  
  // AHB reg bus monitor agent cfg
  rand cdnAhbUvmConfig m_reg_bus_mon_agt_cfg_h;
  
  // AHB decoder and arbiter enable flags and configs
  bit m_has_ahb_decoder_en;
  bit m_has_ahb_arbiter_en;
  rand cdnAhbUvmConfig activeDecoderCfg;
  rand cdnAhbUvmConfig activeArbiterCfg;
  

  

  // ------------------------------------------------------------
  // ref model enable flag
  // ------------------------------------------------------------
  

  // ------------------------------------------------------------
  // scoreboard enable flags (per-scoreboard)
  // ------------------------------------------------------------
  

  // ------------------------------------------------------------
  // top-level dut cfg
  // ------------------------------------------------------------
  rand wujian100_open_top_dut_cfg m_dut_cfg_h; // all sub dut cfg is instantiated under this cfg

  `uvm_object_utils_begin(wujian100_open_top_cfg)
    `uvm_field_object(m_dut_cfg_h, UVM_ALL_ON)
  `uvm_object_utils_end

  extern function new(string name = "wujian100_open_top_cfg");

endclass : wujian100_open_top_cfg

function wujian100_open_top_cfg::new(string name = "wujian100_open_top_cfg");
  super.new(name);

  m_dut_cfg_h = wujian100_open_top_dut_cfg::type_id::create("m_dut_cfg_h");
  m_stop_value = 10000;
  m_timeout_value = 10000;
  m_check_log_start_time = 30;

  for (int indx = 0; indx < `AHB_MST_AGENT_NUM; indx++) begin
      m_ahb_mst_agt_cfg_h[indx] =
        cdnAhbUvmConfig::type_id::create(
          $sformatf("m_ahb_mst_agt_cfg_h[%0d]", indx)
        );
      m_has_ahb_mst_agt_en[indx] = 1;
  
  m_ahb_mst_agt_cfg_h[indx].is_active             = UVM_ACTIVE;
      m_ahb_mst_agt_cfg_h[indx].device_type           = CDN_AHB_CFG_DEVICE_TYPE_MASTER;
      m_ahb_mst_agt_cfg_h[indx].addr_width            = 32;
      m_ahb_mst_agt_cfg_h[indx].data_width            = 32;
      m_ahb_mst_agt_cfg_h[indx].use_memory            = 0;
      m_ahb_mst_agt_cfg_h[indx].is_lite               = 0;
      m_ahb_mst_agt_cfg_h[indx].split_retry_supported = 1;
      m_ahb_mst_agt_cfg_h[indx].set_ttxHCLKToSigValid(1, CDN_VIP_PS, 1);
      m_ahb_mst_agt_cfg_h[indx].verbosity             = CDN_AHB_CFG_MESSAGEVERBOSITY_FULL;
  end
  for (int indx = 0; indx < `AHB_SLV_AGENT_NUM; indx++) begin
      m_ahb_slv_agt_cfg_h[indx] =
        cdnAhbUvmConfig::type_id::create(
          $sformatf("m_ahb_slv_agt_cfg_h[%0d]", indx)
        );
      m_has_ahb_slv_agt_en[indx] = 1;
  
  m_ahb_slv_agt_cfg_h[indx].is_active             = UVM_ACTIVE;
      m_ahb_slv_agt_cfg_h[indx].device_type           = CDN_AHB_CFG_DEVICE_TYPE_SLAVE;
      m_ahb_slv_agt_cfg_h[indx].addr_width            = 32;
      m_ahb_slv_agt_cfg_h[indx].data_width            = 32;
      m_ahb_slv_agt_cfg_h[indx].use_memory            = 1;
      m_ahb_slv_agt_cfg_h[indx].is_lite               = 0;
      m_ahb_slv_agt_cfg_h[indx].split_retry_supported = 1;
      m_ahb_slv_agt_cfg_h[indx].set_ttxHCLKToSigValid(1, CDN_VIP_PS, 1);
      m_ahb_slv_agt_cfg_h[indx].verbosity             = CDN_AHB_CFG_MESSAGEVERBOSITY_FULL;
      m_ahb_slv_agt_cfg_h[indx].addToAddressSegments(32'h0000_0000, 32'hFFFF_FFFF, 0);
  end
  
    // active decoder config.
    if (m_has_ahb_decoder_en) begin
      activeDecoderCfg = cdnAhbUvmConfig::type_id::create("activeDecoderCfg");
      activeDecoderCfg.is_active             = UVM_ACTIVE;
      activeDecoderCfg.device_type           = CDN_AHB_CFG_DEVICE_TYPE_DECODER;
      activeDecoderCfg.use_memory            = 1;
      activeDecoderCfg.is_lite               = 1;
      activeDecoderCfg.split_retry_supported = 1;
      activeDecoderCfg.default_slave_idx     = 1;
      activeDecoderCfg.data_width            = 32;
      activeDecoderCfg.addr_width            = 32;
      activeDecoderCfg.addToAddressSegments('h0000, 'hFFF_FFFF, 'h0000);
      activeDecoderCfg.verbosity             = CDN_AHB_CFG_MESSAGEVERBOSITY_NONE;
    end
  
    if (m_has_ahb_arbiter_en) begin
      activeArbiterCfg = cdnAhbUvmConfig::type_id::create("activeArbiterCfg");
      activeArbiterCfg.data_width            = 32;
      activeArbiterCfg.addr_width            = 32;
      activeArbiterCfg.is_active             = UVM_ACTIVE;
      activeArbiterCfg.device_type           = CDN_AHB_CFG_DEVICE_TYPE_ARBITER;
      activeArbiterCfg.use_memory            = 1;
      activeArbiterCfg.is_lite               = 0;
      activeArbiterCfg.split_retry_supported = 1;
      activeArbiterCfg.dummy_master_idx      = 2;
      activeArbiterCfg.default_master_idx    = 0;
      activeArbiterCfg.addToArbMasterPriority(0, 2);
      activeArbiterCfg.addToArbMasterPriority(1, 2);
      activeArbiterCfg.verbosity             = CDN_AHB_CFG_MESSAGEVERBOSITY_NONE;
    end
  
    m_reg_bus_mon_agt_cfg_h = cdnAhbUvmConfig::type_id::create($sformatf("m_reg_bus_mon_agt_cfg_h"));
    m_reg_bus_mon_agt_cfg_h.is_active             = UVM_PASSIVE;
    m_reg_bus_mon_agt_cfg_h.device_type           = CDN_AHB_CFG_DEVICE_TYPE_MASTER;
    m_reg_bus_mon_agt_cfg_h.addr_width            = 32;
    m_reg_bus_mon_agt_cfg_h.data_width            = 32;
    m_reg_bus_mon_agt_cfg_h.use_memory            = 0;
    m_reg_bus_mon_agt_cfg_h.is_lite               = 1;
    m_reg_bus_mon_agt_cfg_h.split_retry_supported = 1;
    m_reg_bus_mon_agt_cfg_h.set_ttxHCLKToSigValid(1, CDN_VIP_PS, 1);
    m_reg_bus_mon_agt_cfg_h.verbosity             = CDN_AHB_CFG_MESSAGEVERBOSITY_NONE;
  

  
endfunction : new