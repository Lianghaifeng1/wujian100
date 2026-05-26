//------------------------------------------------------------------------------
// wujian100_open_top test base
//------------------------------------------------------------------------------

class wujian100_open_top_test_base extends wujian100_open_top_test_common;

  `uvm_component_utils(wujian100_open_top_test_base)

  wujian100_open_top_env                m_env_h;
  wujian100_open_top_test_vseqr          m_vseqr_h;
  reg_model_adapter                   m_adapter_h;
  reg_model_adapter                   m_word_adapter_h;
  wujian100_open_top_regs_model                  m_regs_model_h;
  wujian100_open_top_word_access_regs_model      m_word_regs_model_h;


  uvm_reg_predictor#(denaliCdn_ahbTransaction) m_reg_predict_h;
  uvm_reg_predictor#(denaliCdn_ahbTransaction) m_word_reg_predict_h;


  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

endclass : wujian100_open_top_test_base


function wujian100_open_top_test_base::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void wujian100_open_top_test_base::build_phase(uvm_phase phase);
  super.build_phase(phase);

  m_cfg_h  = wujian100_open_top_cfg::type_id::create("m_cfg_h", this);

  m_env_h  = wujian100_open_top_env::type_id::create("m_env_h", this);
  uvm_config_db#(wujian100_open_top_cfg)::set(this, "m_env_h", "cfg", m_cfg_h);

  m_vseqr_h = wujian100_open_top_test_vseqr::type_id::create("m_vseqr_h", this);
  uvm_config_db#(wujian100_open_top_cfg)::set(this, "m_vseqr_h", "cfg", m_cfg_h);

    m_regs_model_h = wujian100_open_top_regs_model::type_id::create("m_regs_model_h",this);
    m_regs_model_h.build();
    m_regs_model_h.configure(null,"tb_top");
    m_regs_model_h.lock_model();
    m_regs_model_h.reset();

    m_word_regs_model_h = wujian100_open_top_word_access_regs_model::type_id::create("m_word_regs_model_h",this);
    m_word_regs_model_h.build();
    m_word_regs_model_h.configure(null,"tb_top");
    m_word_regs_model_h.lock_model();
    m_word_regs_model_h.reset();

  m_adapter_h      = reg_model_adapter::type_id::create("m_adapter_h");
  m_word_adapter_h = reg_model_adapter::type_id::create("m_word_adapter_h");

  
  m_reg_predict_h = uvm_reg_predictor#(denaliCdn_ahbTransaction)::type_id::create("m_reg_predict_h", this);
  m_word_reg_predict_h = uvm_reg_predictor#(denaliCdn_ahbTransaction)::type_id::create("m_word_reg_predict_H", this);
  

  m_cfg_h.m_dut_cfg_h.m_regs_model_h = m_regs_model_h ;
  m_cfg_h.m_dut_cfg_h.m_path         = UVM_FRONTDOOR ;

  m_cfg_h.m_dut_cfg_h.m_word_regs_model_h = m_word_regs_model_h ;
  m_cfg_h.m_dut_cfg_h.m_path         = UVM_FRONTDOOR ;

endfunction : build_phase


function void wujian100_open_top_test_base::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  if(uvm_report_enabled(UVM_MEDIUM,UVM_INFO,get_name())) begin
    uvm_top.print_topology();
  end


  for(int indx=0; indx<`AHB_MST_AGENT_NUM; indx++) begin
    if(m_cfg_h.m_has_ahb_mst_agt_en[indx] == 1) begin
      if(!$cast(m_vseqr_h.m_ahb_mst_seqr_h[indx], m_env_h.m_ahb_mst_agt_h[indx].sequencer)) begin
        `uvm_fatal(get_type_name(),
                   $sformatf("$cast(m_vseqr_h.m_ahb_mst_seqr_h[indx], m_env_h.m_ahb_mst_agt_h[indx].sequencer )) call failed!"));
      end
    end
  end

  for(int indx=0; indx<`AHB_SLV_AGENT_NUM; indx++) begin
    if(m_cfg_h.m_has_ahb_slv_agt_en[indx] == 1) begin
      if(!$cast(m_vseqr_h.m_ahb_slv_seqr_h[indx], m_env_h.m_ahb_slv_agt_h[indx].sequencer)) begin
        `uvm_fatal(get_type_name(),
                   $sformatf("$cast(m_vseqr_h.m_ahb_slv_seqr_h[indx], m_env_h.m_ahb_slv_agt_h[indx].sequencer )) call failed!"));
      end
    end
  end

  m_regs_model_h.default_map.set_sequencer(m_env_h.m_ahb_mst_agt_h[0].sequencer, m_adapter_h);
  m_word_regs_model_h.default_map.set_sequencer(m_env_h.m_ahb_mst_agt_h[0].sequencer, m_word_adapter_h);


  m_reg_predict_h.map      = m_regs_model_h.default_map;
  m_word_reg_predict_h.map = m_word_regs_model_h.default_map;
  m_reg_predict_h.adapter  = m_adapter_h;
  m_word_reg_predict_h.adapter = m_word_adapter_h;

  m_regs_model_h.default_map.set_auto_predict(0);
  m_word_regs_model_h.default_map.set_auto_predict(0);

  m_env_h.m_reg_bus_mon_agt_h.monitor.EndedBurstCbPort.connect(m_reg_predict_h.bus_in);
  m_env_h.m_reg_bus_mon_agt_h.monitor.EndedBurstCbPort.connect(m_word_reg_predict_h.bus_in);

  if(!$test$plusargs("NO_TIMEOUT")) uvm_top.set_timeout(400ms,0);

endfunction : connect_phase