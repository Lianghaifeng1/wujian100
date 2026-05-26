class wujian100_open_top_ref_model extends uvm_component;
    wujian100_open_top_common_transaction common_tr;
    bit compare_begin;
    wujian100_open_top_cfg m_cfg_h;

    `uvm_component_utils(wujian100_open_top_ref_model)

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
    
endclass

/*******************************************************/
function wujian100_open_top_ref_model::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction : new

/*******************************************************/
function void wujian100_open_top_ref_model::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(wujian100_open_top_cfg)::get(this, "", "cfg", m_cfg_h)) begin
        `uvm_fatal(get_full_name(), "Getting wujian100_open_top_cfg failed in reference model, please check it!")
    end
    `uvm_info(get_full_name(), "build_phase is exited", UVM_MEDIUM)
endfunction : build_phase

/*******************************************************/
function void wujian100_open_top_ref_model::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_full_name(), "connect_phase is exited", UVM_MEDIUM)
endfunction : connect_phase

/*******************************************************/
function void wujian100_open_top_ref_model::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info(get_full_name(), "end_of_elaboration_phase is entered", UVM_MEDIUM)
    `uvm_info(get_full_name(), "end_of_elaboration_phase is exited", UVM_MEDIUM)
endfunction : end_of_elaboration_phase

/*******************************************************/
function void wujian100_open_top_ref_model::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info(get_full_name(), "start_of_simulation_phase is entered", UVM_MEDIUM)
    `uvm_info(get_full_name(), "start_of_simulation_phase is exited", UVM_MEDIUM)
endfunction : start_of_simulation_phase

/*******************************************************/
task wujian100_open_top_ref_model::run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_full_name(), "run_phase is entered", UVM_MEDIUM)
    forever begin
        uvm_config_db#(bit)::wait_modified(this, "", "compare_begin");
        void'(uvm_config_db#(bit)::get(this, "", "compare_begin", compare_begin));
        `uvm_info(get_name(), $sformatf("get compare_begin = %0d", compare_begin), UVM_LOW)
    end
    `uvm_info(get_full_name(), "run_phase is exited", UVM_MEDIUM)
endtask : run_phase



/*******************************************************/
function void wujian100_open_top_ref_model::extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    `uvm_info(get_full_name(), "extract_phase is entered", UVM_MEDIUM)
    `uvm_info(get_full_name(), "extract_phase is exited", UVM_MEDIUM)
endfunction : extract_phase

/*******************************************************/
function void wujian100_open_top_ref_model::check_phase(uvm_phase phase);
    bit [31:0] rdata;
    super.check_phase(phase);
    `uvm_info(get_full_name(), "check_phase is entered", UVM_MEDIUM)
    `uvm_info(get_full_name(), "check_phase is exited", UVM_MEDIUM)
endfunction : check_phase

/*******************************************************/
function void wujian100_open_top_ref_model::report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_full_name(), "report_phase is entered", UVM_MEDIUM)
    `uvm_info(get_full_name(), "report_phase is exited", UVM_MEDIUM)
endfunction : report_phase

/*******************************************************/
function void wujian100_open_top_ref_model::final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info(get_full_name(), "final_phase is entered", UVM_MEDIUM)
    `uvm_info(get_full_name(), "final_phase is exited", UVM_MEDIUM)
endfunction : final_phase