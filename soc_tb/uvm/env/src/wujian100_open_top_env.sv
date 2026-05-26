class wujian100_open_top_env extends uvm_env;
  `uvm_component_utils(wujian100_open_top_env)

  cdnAhbUvmAgent m_ahb_mst_agt_h[`AHB_MST_AGENT_NUM];
  cdnAhbUvmAgent m_ahb_slv_agt_h[`AHB_SLV_AGENT_NUM];
  
  cdnAhbUvmAgent m_reg_bus_mon_agt_h;
  cdnAhbUvmAgent activeArbiter;
  cdnAhbUvmAgent activeDecoder;
  wujian100_open_top_cfg m_cfg_h;//env configuration

  wujian100_open_top_regs_model m_regs_model_h;


  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void end_of_elaboration_phase(uvm_phase phase);
  extern virtual function void start_of_simulation_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual function void extract_phase(uvm_phase phase);
  extern virtual function void check_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);
  extern virtual function void final_phase(uvm_phase phase);
endclass: wujian100_open_top_env

//****************************************************************
//*********** new function definition          *******************
//****************************************************************
function wujian100_open_top_env::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new

//****************************************************************
//*********** build_phase definition           *******************
//****************************************************************
function void wujian100_open_top_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(get_full_name(),"build_phase is entered", UVM_MEDIUM)

  if (!uvm_config_db#(wujian100_open_top_cfg)::get(this,"","cfg", m_cfg_h)) begin
    `uvm_fatal(get_full_name(), "Getting wujian100_open_top_cfg failed,please check it!")
  end

  m_regs_model_h = m_cfg_h.m_dut_cfg_h.m_regs_model_h;


for(int indx=0; indx<`AHB_MST_AGENT_NUM; indx++) begin
    if(m_cfg_h.m_has_ahb_mst_agt_en[indx] == 1) begin
      m_ahb_mst_agt_h[indx] = cdnAhbUvmAgent::type_id::create($sformatf("m_ahb_mst_agt_h[%0d]",indx),this);
      uvm_config_object::set(this, $sformatf("m_ahb_mst_agt_h[%0d]*",indx), "cfg", m_cfg_h.m_ahb_mst_agt_cfg_h[indx]);
    end
  end
for(int indx=0; indx<`AHB_SLV_AGENT_NUM; indx++) begin
    if(m_cfg_h.m_has_ahb_slv_agt_en[indx] == 1) begin
      m_ahb_slv_agt_h[indx] = cdnAhbUvmAgent::type_id::create($sformatf("m_ahb_slv_agt_h[%0d]",indx),this);
      uvm_config_object::set(this, $sformatf("m_ahb_slv_agt_h[%0d]*",indx), "cfg", m_cfg_h.m_ahb_slv_agt_cfg_h[indx]);
    end
  end

  m_reg_bus_mon_agt_h = cdnAhbUvmAgent::type_id::create($sformatf("m_reg_bus_mon_agt_h"),this);
  uvm_config_object::set(this, $sformatf("m_reg_bus_mon_agt_h"), "cfg", m_cfg_h.m_reg_bus_mon_agt_cfg_h);

  if(m_cfg_h.m_has_ahb_decoder_en) begin
    activeDecoder = cdnAhbUvmAgent::type_id::create("activeDecoder", this);
    uvm_config_object::set(this,"activeDecoder","cfg",m_cfg_h.activeDecoderCfg);
  end
  if(m_cfg_h.m_has_ahb_arbiter_en) begin
    activeArbiter = cdnAhbUvmAgent::type_id::create("activeArbiter", this);
    uvm_config_object::set(this,"activeArbiter","cfg",m_cfg_h.activeArbiterCfg);
    m_cfg_h.activeArbiterCfg.pAgent = activeArbiter;
  end
`uvm_info(get_full_name(),"build_phase is exited", UVM_MEDIUM)
endfunction : build_phase

//****************************************************************
//*********** connect_phase definition         *******************
//****************************************************************
function void wujian100_open_top_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  `uvm_info(get_full_name(),"connect_phase is entered", UVM_MEDIUM)

  // ============================================================
  // 1. Agent Monitor -> Ref Model (输入)
  // ============================================================


  // ============================================================
  // 2. Ref Model -> Scoreboard (Expected)
  // ============================================================


  // ============================================================
  // 3. DUT Monitor -> Scoreboard (Actual)
  // ============================================================


  `uvm_info(get_full_name(),"connect_phase is exited", UVM_MEDIUM)
endfunction : connect_phase

//****************************************************************
//*********** end_of_elaboration_phase definition***************
//****************************************************************
function void wujian100_open_top_env::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
  `uvm_info(get_full_name(),"end_of_elaboration_phase is entered", UVM_MEDIUM)

  `uvm_info(get_full_name(),"end_of_elaboration_phase is exited", UVM_MEDIUM)
endfunction : end_of_elaboration_phase

//****************************************************************
//*********** start_of_simulation_phase definition***************
//****************************************************************
function void wujian100_open_top_env::start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
  `uvm_info(get_full_name(),"start_of_simulation_phase is entered", UVM_MEDIUM)

  `uvm_info(get_full_name(),"start_of_simulation_phase is exited", UVM_MEDIUM)
endfunction : start_of_simulation_phase

//****************************************************************
//*********** run_phase definition             *******************
//****************************************************************
task wujian100_open_top_env::run_phase(uvm_phase phase);
  super.run_phase(phase);
  `uvm_info(get_full_name(),"run_phase is entered", UVM_MEDIUM)
  #1ns;

for(int indx=0; indx<`AHB_MST_AGENT_NUM; indx++) begin
    if(m_cfg_h.m_has_ahb_mst_agt_en[indx] == 1) begin
      m_ahb_mst_agt_h[indx].regInst.writeReg(DENALI_CDN_AHB_REG_Verbosity,DENALI_CDN_AHB_MESSAGEVERBOSITY_NONE);
      if(!uvm_report_enabled(UVM_LOW,UVM_INFO,get_name())) begin
        m_ahb_mst_agt_h[indx].regInst.writeReg(DENALI_CDN_AHB_REG_EnableTracker,0);
      end
    end
  end
for(int indx=0; indx<`AHB_SLV_AGENT_NUM; indx++) begin
    if(m_cfg_h.m_has_ahb_slv_agt_en[indx] == 1) begin
      m_ahb_slv_agt_h[indx].regInst.writeReg(DENALI_CDN_AHB_REG_Verbosity,DENALI_CDN_AHB_MESSAGEVERBOSITY_NONE);
      if(!uvm_report_enabled(UVM_LOW,UVM_INFO,get_name())) begin
        m_ahb_slv_agt_h[indx].regInst.writeReg(DENALI_CDN_AHB_REG_EnableTracker,0);
      end
    end
  end

  m_reg_bus_mon_agt_h.regInst.writeReg(DENALI_CDN_AHB_REG_Verbosity,DENALI_CDN_AHB_MESSAGEVERBOSITY_NONE);
  if(!uvm_report_enabled(UVM_LOW,UVM_INFO,get_name())) begin
    m_reg_bus_mon_agt_h.regInst.writeReg(DENALI_CDN_AHB_REG_EnableTracker,0);
  end
  m_reg_bus_mon_agt_h.regInst.writeReg(DENALI_CDN_AHB_REG_EnableTracker,0);

  if(m_cfg_h.m_has_ahb_arbiter_en == 1) begin
    if(!uvm_report_enabled(UVM_LOW,UVM_INFO,get_name())) begin
      activeArbiter.regInst.writeReg(DENALI_CDN_AHB_REG_EnableTracker,0);
    end
    activeArbiter.regInst.writeReg(DENALI_CDN_AHB_REG_EnableTracker,0);
  end
  if(m_cfg_h.m_has_ahb_decoder_en == 1) begin
    if(!uvm_report_enabled(UVM_LOW,UVM_INFO,get_name())) begin
      activeDecoder.regInst.writeReg(DENALI_CDN_AHB_REG_EnableTracker,0);
    end
    activeDecoder.regInst.writeReg(DENALI_CDN_AHB_REG_EnableTracker,0);
  end
`uvm_info(get_full_name(),"run_phase is exited", UVM_MEDIUM)
endtask : run_phase

//****************************************************************
//*********** extract_phase definition         *******************
//****************************************************************
function void wujian100_open_top_env::extract_phase(uvm_phase phase);
  super.extract_phase(phase);
  `uvm_info(get_full_name(),"extract_phase is entered", UVM_MEDIUM)

  `uvm_info(get_full_name(),"extract_phase is exited", UVM_MEDIUM)
endfunction : extract_phase

//****************************************************************
//*********** check_phase definition           *******************
//****************************************************************
function void wujian100_open_top_env::check_phase(uvm_phase phase);
  super.check_phase(phase);
  `uvm_info(get_full_name(),"check_phase is entered", UVM_MEDIUM)

  `uvm_info(get_full_name(),"check_phase is exited", UVM_MEDIUM)
endfunction : check_phase

//****************************************************************
//*********** report_phase definition          *******************
//****************************************************************
function void wujian100_open_top_env::report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info(get_full_name(),"report_phase is entered", UVM_MEDIUM)

  `uvm_info(get_full_name(),"report_phase is exited", UVM_MEDIUM)
endfunction : report_phase

//****************************************************************
//*********** final_phase definition           *******************
//****************************************************************
function void wujian100_open_top_env::final_phase(uvm_phase phase);
  super.final_phase(phase);
  `uvm_info(get_full_name(),"final_phase is entered", UVM_MEDIUM)

  `uvm_info(get_full_name(),"final_phase is exited", UVM_MEDIUM)
endfunction : final_phase