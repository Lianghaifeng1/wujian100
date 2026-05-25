class soc_top_scoreboard extends uvm_component;
  `uvm_component_utils(soc_top_scoreboard)

  uvm_analysis_imp #(soc_top_common_transaction, soc_top_scoreboard) item_export;
  soc_top_cfg cfg;
  int unsigned txn_count;
  int unsigned pass_mark_times;
  int unsigned fail_mark_times;
  bit final_seen;
  string fw_output;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_export = new("item_export", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(soc_top_cfg)::get(this, "", "soc_top_cfg", cfg)) begin
      `uvm_fatal("NOCFG", "soc_top_cfg is not configured")
    end
  endfunction

  function void write(soc_top_common_transaction tr);
    txn_count++;
    if (tr.resp != 2'b00) begin
      `uvm_error("AHB_RSP", $sformatf("AHB error response addr=0x%08h resp=%0b", tr.addr, tr.resp))
    end
    if (cfg.soc_mode == FM_MODE && tr.write && tr.addr == 32'h2000_7c50) begin
      if (tr.data == 32'h0000_2002) begin
        pass_mark_times++;
        if (pass_mark_times >= 2) begin
          final_seen = 1;
          `uvm_info("SOC_PASS", "Firmware reported TEST PASS", UVM_NONE)
          write_report("TEST PASS");
          $finish;
        end
      end
      else if (tr.data == 32'h0000_1001) begin
        fail_mark_times++;
        if (fail_mark_times >= 2) begin
          final_seen = 1;
          `uvm_error("SOC_FAIL", "Firmware reported TEST FAIL")
          write_report("TEST FAIL");
          $finish;
        end
      end
      else begin
        fw_output = {fw_output, byte'(tr.data[7:0])};
        $write("%c", tr.data[7:0]);
      end
    end
  endfunction

  function void write_report(string result);
    int fd;
    fd = $fopen("run_case.report", "w");
    if (fd != 0) begin
      $fdisplay(fd, "%0s", result);
      $fclose(fd);
    end
  endfunction

  function void report_phase(uvm_phase phase);
    if (cfg.soc_mode == FM_MODE && !final_seen) begin
      `uvm_error("NO_FW_RESULT", "FM_MODE ended without firmware pass/fail magic")
    end
    if (cfg.soc_mode == UVM_MODE && txn_count == 0) begin
      `uvm_error("NO_AHB_TXN", "UVM_MODE ended without observed AHB transaction")
    end
    `uvm_info("SOC_SUMMARY",
              $sformatf("case=%0s mode=%0s txns=%0d pass_marks=%0d fail_marks=%0d",
                        cfg.case_name, (cfg.soc_mode == FM_MODE) ? "FM_MODE" : "UVM_MODE",
                        txn_count, pass_mark_times, fail_mark_times),
              UVM_NONE)
  endfunction
endclass
