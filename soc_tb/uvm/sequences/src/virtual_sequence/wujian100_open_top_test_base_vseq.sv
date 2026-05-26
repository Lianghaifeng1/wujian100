class wujian100_open_top_test_base_vseq extends uvm_sequence#(uvm_sequence_item,uvm_sequence_item);

  `uvm_object_utils(wujian100_open_top_test_base_vseq)
  uvm_declare_p_sequencer(wujian100_open_top_test_vseqr)

  int          value;
  int          period;
  uvm_status_e stat;
  uvm_reg_data_t wdata;
  uvm_reg_data_t rdata;
  intr_info_t  intr_map[string];
  wujian100_open_top_cfg     m_cfg_h;
  wujian100_open_top_dut_vif m_dut_vif_h;

  
  cdnAhbUvmSequencer m_ahb_mst_seqr_h['AHB_MST_AGENT_NUM];
  
  cdnAhbUvmSequencer m_ahb_slv_seqr_h['AHB_SLV_AGENT_NUM];
  extern function new(string name="wujian100_open_top_test_base_vseq");

  extern virtual task pre_body();
  extern virtual task system_config();

  `include "./common_task.sv"
endclass : wujian100_open_top_test_base_vseq


function wujian100_open_top_test_base_vseq::new(string name="wujian100_open_top_test_base_vseq");
  super.new(name);
endfunction : new


task wujian100_open_top_test_base_vseq::pre_body();
  super.pre_body();
  if (!uvm_config_db#(wujian100_open_top_cfg)::get(m_sequencer, "", "cfg", m_cfg_h)) begin
    `uvm_fatal(get_name(),"can't get m_cfg_h")
  end

  if (!uvm_config_db#(wujian100_open_top_dut_vif)::get(m_sequencer, "", "vif",m_dut_vif_h)) begin
    `uvm_fatal(get_name() ,"can't get dut_if")
  end

  
  for(int indx=0;indx<'AHB_MST_AGENT_NUM';indx++) begin
    if(m_cfg_h.m_has_ahb_mst_agt_en[indx] == 1) begin
      m_ahb_mst_seqr_h[indx] = p_sequencer.m_ahb_mst_seqr_h[indx];
    end
  end
  
  for(int indx=0;indx<'AHB_SLV_AGENT_NUM';indx++) begin
    if(m_cfg_h.m_has_ahb_slv_agt_en[indx] == 1) begin
      m_ahb_slv_seqr_h[indx] = p_sequencer.m_ahb_slv_seqr_h[indx];
    end
  end
  

  system_config();
  `include "./intr_map.sv"
  `uvm_info(get_name(),"finished system configuration ",UVM_LOW)
endtask : pre_body


task wujian100_open_top_test_base_vseq::system_config();
  uvm_status_e  stat;
  uvm_reg_data_t wdata;
  uvm_reg_data_t rdata;
endtask : system_config