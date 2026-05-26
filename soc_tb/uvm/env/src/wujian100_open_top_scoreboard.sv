class wujian100_open_top_scoreboard #(type T = uvm_sequence_item) extends uvm_scoreboard;

  typedef wujian100_open_top_scoreboard #(T) this_type_t;
  `uvm_component_param_utils(this_type_t)

  // analysis fifos
  protected uvm_tlm_analysis_fifo #(T) m_actual_analysis_fifo_h;    // define actual analysis fifo
  protected uvm_tlm_analysis_fifo #(T) m_expected_analysis_fifo_h;  // define expected analysis fifo

  // analysis exports
  uvm_analysis_export #(T) m_actual_analysis_export;    // define actual analysis export
  uvm_analysis_export #(T) m_expected_analysis_export;  // define expected analysis export

  // get ports
  uvm_get_port #(T) m_actual_get_port;    // connect to actual fifo.get_export
  uvm_get_port #(T) m_expected_get_port;  // connect to expected fifo.get_export

  // control knobs
  bit flush_fifo;
  bit m_out_of_order;    // define out-of-order variable
  bit m_scb_check_en;    // scoreboard check enable
  bit m_no_empty_en;     // compare until both fifos have transactions
  bit m_check_fifo_en;   // check fifos are empty when simulation ends

  // counters
  int m_match_num;          // matched transaction number
  int m_mismatch_num;       // mismatched transaction number
  int m_min_trans_num;      // at least number of transactions to receive
  int trans_num;
  int m_max_reserved_num;   // max transactions reserved in fifo

  extern function         new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task     run_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);
  extern virtual function void flush_tlm_fifo();
  extern virtual function void display_mis_pkt(T display_pkt, string info_id);

endclass : wujian100_open_top_scoreboard

// *********************** new() *************************
function wujian100_open_top_scoreboard::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new

// ******************** build_phase() ********************
function void wujian100_open_top_scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(get_name(), "build_phase is entered", UVM_LOW)

  m_out_of_order      = 0;
  m_scb_check_en      = 1;
  m_no_empty_en       = 0;
  m_match_num         = 0;
  m_mismatch_num      = 0;
  m_check_fifo_en     = 1;
  m_min_trans_num     = 0;
  trans_num           = 0;
  m_max_reserved_num  = 1023;

  m_actual_analysis_fifo_h   = new("m_actual_analysis_fifo_h",   this);
  m_expected_analysis_fifo_h = new("m_expected_analysis_fifo_h", this);

  m_actual_analysis_export   = new("m_actual_analysis_export",   this);
  m_expected_analysis_export = new("m_expected_analysis_export", this);

  m_actual_get_port   = new("m_actual_get_port",   this);
  m_expected_get_port = new("m_expected_get_port", this);

  `uvm_info(get_name(), "build_phase is exited", UVM_LOW)
endfunction : build_phase

// ******************* connect_phase() *******************
function void wujian100_open_top_scoreboard::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  `uvm_info(get_name(), "connect_phase is entered", UVM_LOW)

  m_actual_analysis_export  .connect(m_actual_analysis_fifo_h  .analysis_export);
  m_expected_analysis_export.connect(m_expected_analysis_fifo_h.analysis_export);

  m_actual_get_port  .connect(m_actual_analysis_fifo_h  .get_export);
  m_expected_get_port.connect(m_expected_analysis_fifo_h.get_export);

  `uvm_info(get_name(), "connect_phase is exited", UVM_LOW)
endfunction : connect_phase

// ************ run_phase(): periodic compare ************
task wujian100_open_top_scoreboard::run_phase(uvm_phase phase);
  bit    [31:0] item_id;
  string        item_diff;

  T expected_item;
  T actual_item;

  void'(uvm_config_db#(bit)::get(this, "", "m_scb_check_en",  m_scb_check_en ));
  void'(uvm_config_db#(bit)::get(this, "", "m_out_of_order",  m_out_of_order ));
  void'(uvm_config_db#(bit)::get(this, "", "m_no_empty_en",   m_no_empty_en  ));
  fork
    begin
      forever begin
        // void'(uvm_config_db#(bit)::get(this, "", "m_scb_check_en", m_scb_check_en));
        // if (m_scb_check_en) begin
          m_actual_get_port.get(actual_item);
          `uvm_info(get_name(), $sformatf("m_no_empty_en=%0d", m_no_empty_en), UVM_MEDIUM)
          void'(uvm_config_db#(bit)::get(this, "", "m_scb_check_en", m_scb_check_en));
          `uvm_info(get_name(), $sformatf("m_scb_check_en=%0d", m_scb_check_en), UVM_MEDIUM)
          if (m_scb_check_en) begin
            if (m_no_empty_en) begin
              m_expected_get_port.get(expected_item);
            end
            else begin
              void'(m_expected_get_port.try_get(expected_item));
            end

            if (expected_item == null) begin
              `uvm_error(get_name(), $sformatf("There is no item in expected analysis fifo"))
            end
            else begin
              // void'(uvm_config_db#(bit)::get(this, "", "m_scb_check_en", m_scb_check_en));
              item_id++;
              if (m_scb_check_en) begin
                if (actual_item.compare(expected_item)) begin
                  `uvm_info(get_name(), $sformatf("The %0d'th item Match", item_id), UVM_LOW)
                  m_match_num++;
                end
                else begin
                  `uvm_error(get_name(), $sformatf("The %0d'th item Mismatch", item_id))
                  display_mis_pkt(actual_item,  "Come from DUT");
                  display_mis_pkt(expected_item,"Come from RM");
                  m_mismatch_num++;
                end
              end
            end
          end
        // end
      end
    end
    begin
      forever begin
        uvm_config_db#(bit)::wait_modified(this, "", "flush_fifo");
        `uvm_info(get_name(), $sformatf("begin flush tlm fifo"), UVM_LOW)
        flush_tlm_fifo();
      end
    end
    begin
      forever begin
        uvm_config_db#(int)::wait_modified(this, "", "trans_num");
        void'(uvm_config_db#(int)::get(this, "", "trans_num", trans_num));
        m_min_trans_num = m_min_trans_num + trans_num;
        `uvm_info(get_name(),
                  $sformatf("get trans_num = %0d  m_min_trans_num = %0d",
                            trans_num, m_min_trans_num),
                  UVM_LOW)
      end
    end
  join
endtask : run_phase

function void wujian100_open_top_scoreboard::display_mis_pkt(T display_pkt, string info_id);
  `uvm_info(get_name(), $sformatf("%s: packet info", info_id), UVM_LOW)
  display_pkt.print();
endfunction : display_mis_pkt

// ****** report_phase(): summary & fifo leftover check ******
function void wujian100_open_top_scoreboard::report_phase(uvm_phase phase);
  int unsigned actual_fifo_size;
  int unsigned expected_fifo_size;

  `uvm_info(get_name(), "report_phase is entered", UVM_LOW)

  void'(uvm_config_db#(bit)::get(this, "", "m_check_fifo_en",   m_check_fifo_en  ));
  // void'(uvm_config_db#(int)::get(this, "", "m_min_trans_num",  m_min_trans_num  ));
  void'(uvm_config_db#(int)::get(this, "", "m_max_reserved_num", m_max_reserved_num));

  `uvm_info(get_name(),
            $sformatf("\033[31;47;5m %0d items match, %0d items mismatch when simulation done \033[0m",
                      m_match_num, m_mismatch_num),
            UVM_LOW)

  if (m_check_fifo_en) begin
    // void'(m_actual_get_port.try_get(tmp_item));
    // if (tmp_item != null) begin
    actual_fifo_size   = m_actual_analysis_fifo_h  .used();
    expected_fifo_size = m_expected_analysis_fifo_h.used();
    if (actual_fifo_size > m_max_reserved_num) begin
      `uvm_error(get_name(),
                 $sformatf("\033[37;41;5m Still there are %0d items in actual analysis fifo when simulation done \033[0m",
                           actual_fifo_size))
    end
    if (expected_fifo_size > m_max_reserved_num) begin
      `uvm_error(get_name(),
                 $sformatf("\033[37;41;5m Still there are %0d items in expected analysis fifo when simulation done \033[0m",
                           expected_fifo_size))
    end
  end

  if ((m_mismatch_num + m_match_num) < m_min_trans_num) begin
    `uvm_error(get_name(),
               $sformatf("\033[37;41;5m Please double check your sequence, only receive %0d transaction, at least send %0d transaction for this testcase simulation \033[0m",
                         m_mismatch_num + m_match_num, m_min_trans_num))
  end

  `uvm_info(get_name(), "report_phase is exited", UVM_LOW)
endfunction : report_phase

// ********************* flush_tlm_fifo() *********************
function void wujian100_open_top_scoreboard::flush_tlm_fifo();
  uvm_sequence_item item;
  while (m_expected_analysis_fifo_h.try_get(item));
  while (m_actual_analysis_fifo_h  .try_get(item));
endfunction