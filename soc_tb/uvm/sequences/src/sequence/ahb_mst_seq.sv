class ahbm_base_seq extends cdnAhbUvmSequence;
  `uvm_object_utils(ahbm_base_seq)

  bit [31:0] wdata_array [$];
  bit [31:0] rdata_array [$];
  rand logic [31:0] addr = 0;
  burst_t burst_mode = SINGLE;
  size_t  trans_size = WORD;
  write_t read_write = WRITE;
  bit [31:0] wdata;
  bit        busy_en;
  bit [7:0]  address_size;
  burst_t    burst_wrap = WRAP4;

  denaliCdn_ahbBurstKind Kind = DENALI_CDN_AHB_BURSTKIND_SINGLE;

  // Constructor
  function new(string name = "ahbm_base_seq");
    super.new(name);
  endfunction
endclass: ahbm_base_seq

//------------------------------------------------------------------------------
// Single read sequence
//------------------------------------------------------------------------------
class ahbm_sread_seq extends ahbm_base_seq;
  cdnAhbUvmSequencer        seqr;
  uvm_object                obj;
  denaliCdn_ahbTransaction  ahb_tr;
  denaliCdn_ahbTransaction  receivedTransaction;

  `uvm_object_utils(ahbm_sread_seq)

  // Constructor
  function new(string name = "ahbm_sread_seq");
    super.new(name);
  endfunction

  // Body
  task body();
    $cast(seqr, get_sequencer());
    `uvm_create(ahb_tr);
    `uvm_rand_send_with(ahb_tr, {
      Kind         == DENALI_CDN_AHB_BURSTKIND_SINGLE;
      FirstAddress == local::addr;
      Direction    == DENALI_CDN_AHB_DIRECTION_READ;
      (trans_size  == BYTE)     -> Size == DENALI_CDN_AHB_TRANSFERSIZE_BYTE;
      (trans_size  == HALFWORD) -> Size == DENALI_CDN_AHB_TRANSFERSIZE_HALFWORD;
      (trans_size  == WORD)     -> Size == DENALI_CDN_AHB_TRANSFERSIZE_WORD;
    })
    while (1) begin
      seqr.pAgent.monitor.EndedBurstCbEvent.wait_trigger_data(obj);
      if (!$cast(receivedTransaction, obj)) begin
        `uvm_fatal(get_type_name(), "$cast(receivedTransaction,obj) call failed!");
      end
      if ((receivedTransaction.FirstAddress == addr) &&
          (receivedTransaction.Direction == DENALI_CDN_AHB_DIRECTION_READ)) begin
        break;
      end
    end

    if (trans_size == BYTE) begin
      rdata_array[0] = {24'h0, receivedTransaction.Data[0]};
    end
    else if (trans_size == HALFWORD) begin
      rdata_array[0] = {16'h0, receivedTransaction.Data[1], receivedTransaction.Data[0]};
    end
    else begin
      rdata_array[0] = {receivedTransaction.Data[3], receivedTransaction.Data[2],
                         receivedTransaction.Data[1], receivedTransaction.Data[0]};
    end
  endtask
endclass: ahbm_sread_seq

//------------------------------------------------------------------------------
// Single write sequence
//------------------------------------------------------------------------------
class ahbm_swrite_seq extends ahbm_base_seq;
  cdnAhbUvmSequencer        seqr;
  denaliCdn_ahbTransaction  ahb_tr;

  `uvm_object_utils(ahbm_swrite_seq)

  // Constructor
  function new(string name = "ahbm_swrite_seq");
    super.new(name);
  endfunction

  // Body
  task body();
    $cast(seqr, get_sequencer());
    `uvm_create(ahb_tr);
    `uvm_rand_send_with(ahb_tr, {
      FirstAddress == local::addr;
      Direction    == DENALI_CDN_AHB_DIRECTION_WRITE;
      Kind         == DENALI_CDN_AHB_BURSTKIND_SINGLE;
      //foreach (Data[i]) Data[i] == local::wdata_array[i][7:0];
      (trans_size == BYTE)     -> foreach (Data[i]) Data[i] == local::wdata_array[i][7:0];
      (trans_size == HALFWORD) -> foreach (Data[i]) Data[i] == local::wdata_array[i/2][8*(i%2)+:8];
      (trans_size == WORD)     -> foreach (Data[i]) Data[i] == local::wdata_array[i/4][8*(i%4)+:8];
      (trans_size == BYTE)     -> Size == DENALI_CDN_AHB_TRANSFERSIZE_BYTE;
      (trans_size == HALFWORD) -> Size == DENALI_CDN_AHB_TRANSFERSIZE_HALFWORD;
      (trans_size == WORD)     -> Size == DENALI_CDN_AHB_TRANSFERSIZE_WORD;
    })
    seqr.pAgent.monitor.EndedBurstCbEvent.wait_trigger();
  endtask
endclass: ahbm_swrite_seq
