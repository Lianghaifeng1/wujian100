class ahb_slv_seq extends cdnAhbUvmSequence;
  `uvm_object_utils(ahb_slv_seq)

  bit [31:0] slave_start_addr;

  cdnAhbUvmSequencer m_slv_seqr_h;

  function new(string name = "ahb_slv_seq");
    super.new(name);
  endfunction

  virtual task body();
    uvm_status_e             stat;
    bit [1:0]                response_type;
    denaliCdn_ahbTransaction ahb_tr;
    //uvm_object             obj;
    bit                      insert_dly_en;

    while(1) begin
      insert_dly_en = $urandom;
      response_type = $urandom;

      `uvm_create(ahb_tr);
      if(insert_dly_en) ahb_tr.transfersResponsesBusyDelayLengthConstraint.constraint_mode(0);

      `uvm_rand_send_with(ahb_tr, {
        Type         == DENALI_CDN_AHB_TR_TransactionResponse;
        Size         == DENALI_CDN_AHB_TRANSFERSIZE_WORD;
        Kind         == DENALI_CDN_AHB_BURSTKIND_INCR; // receivedTransaction.Kind;
        Length       == 64;
        TransfersResponses.size() == Length; // == receivedTransaction.TransfersResponses.size();
        //TransfersResponsesDelay.size() == Length; // == receivedTransaction.TransfersResponsesDelay.size();

        if(insert_dly_en) foreach (TransfersResponsesDelay[i]) TransfersResponsesDelay[i] inside {[0:500]};
        if(insert_dly_en) foreach (TransfersResponses[j])      TransfersResponses[j]      == DENALI_CDN_AHB_RESPONSEKIND_OKAY;

        solve Length before TransfersResponsesDelay;
        solve Length before TransfersResponses;
      })

      // m_slv_seqr_h.pAgent.monitor.BeforeSendTransactionResponseCbEvent.wait_trigger_data(obj);
      m_slv_seqr_h.pAgent.monitor.EndedBurstCbEvent.wait_trigger();
    end
  endtask : body

endclass : ahb_slv_seq