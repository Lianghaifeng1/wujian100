class reg_model_adapter extends uvm_reg_adapter;
  `uvm_object_utils(reg_model_adapter)

  integer data_size;
  function new(string name = "reg_model_adapter");
    super.new(name);
    provides_responses=1; // driver provides separate response items
  endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    denaliCdn_ahbTransaction ahb_tr = denaliCdn_ahbTransaction::type_id::create("ahb_tr");
    data_size = rw.n_bits/8;
    ahb_tr.Direction = (rw.kind == UVM_READ) ? DENALI_CDN_AHB_DIRECTION_READ : DENALI_CDN_AHB_DIRECTION_WRITE;
    ahb_tr.Data = new[data_size]; // Get the no of beats from reg op
    ahb_tr.Kind = DENALI_CDN_AHB_BURSTKIND_SINGLE; // For reg access, need only single transfer in one burst
    if(rw.n_bits==8) begin
      ahb_tr.Size = DENALI_CDN_AHB_TRANSFERSIZE_BYTE;
      ahb_tr.Data = {rw.data[7:0]};
    end else if(rw.n_bits==16) begin
      ahb_tr.Size = DENALI_CDN_AHB_TRANSFERSIZE_HALFWORD;
      ahb_tr.Data = {rw.data[7:0],rw.data[15:8]};
    end else begin
      ahb_tr.Size = DENALI_CDN_AHB_TRANSFERSIZE_WORD;
      ahb_tr.Data = {rw.data[7:0],rw.data[15:8],rw.data[23:16],rw.data[31:24]};
    end

    ahb_tr.FirstAddress = rw.addr; // reg address becomes the first address of the transfer
    ahb_tr.NumOfBusyTransfers = 0;
    ahb_tr.IoMode = DENALI_CDN_AHB_IOMODE_DATA; // data access

    if (rw.kind == UVM_WRITE) begin
      `uvm_info(get_type_name(), $sformatf("REG_DEBUG :: REG2BUS Completed WRITE at Address = %0h", rw.addr), UVM_MEDIUM)
      `uvm_info(get_type_name(), $sformatf("REG_DEBUG :: REG2BUS Completed WRITE with Data = %0h", rw.data), UVM_MEDIUM)
      `uvm_info(get_type_name(), $sformatf("REG_DEBUG :: REG2BUS Completed WRITE with bits = %0h", rw.n_bits), UVM_MEDIUM)
    end
    if (rw.kind == UVM_READ)
      `uvm_info(get_type_name(), $sformatf("REG_DEBUG :: REG2BUS Completed READ at Address = %0h", rw.addr), UVM_MEDIUM)
    return ahb_tr;
  endfunction

  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    denaliCdn_ahbTransaction ahb_tr;
    if (!$cast(ahb_tr, bus_item)) begin
      `uvm_fatal("NOT_AHB_TYPE", "Provided bus_item is not of the correct type")
      return;
    end
    rw.kind = (ahb_tr.Direction == DENALI_CDN_AHB_DIRECTION_READ) ? UVM_READ : UVM_WRITE;
    rw.addr = ahb_tr.FirstAddress;
    begin
      bit [7:0] data_byte[4];
      foreach (ahb_tr.Data[i]) begin
        if (i < 4) data_byte[i] = ahb_tr.Data[i];
      end
      if(rw.n_bits==8) begin
        rw.data[7:0] = data_byte[0];
      end else if(rw.n_bits==16) begin
        rw.data[15:0] = {data_byte[1], data_byte[0]};
      end else begin
        rw.data = {data_byte[3], data_byte[2], data_byte[1], data_byte[0]};
      end
    end

    if (rw.kind == UVM_WRITE) begin
      `uvm_info(get_type_name(), $sformatf( "REG_DEBUG :: BUS2REG Completed WRITE at Address = %0h", rw.addr ), UVM_MEDIUM)
      `uvm_info(get_type_name(), $sformatf( "REG_DEBUG :: BUS2REG Completed WRITE with Data = %0h", rw.data), UVM_MEDIUM)
    end
    if (rw.kind == UVM_READ) begin
      `uvm_info(get_type_name(), $sformatf( "REG_DEBUG :: BUS2REG Completed READ at Address = %0h", rw.addr ), UVM_MEDIUM)
      `uvm_info(get_type_name(), $sformatf( "REG_DEBUG :: BUS2REG Completed READ with Data = %0h", rw.data), UVM_MEDIUM)
    end
    rw.status = UVM_IS_OK;
  endfunction
endclass