// 8-bit register write
task wr_reg8(bit[`WUJIAN100_OPEN_TOP_ADDR_WIDTH-1:0] addr,
             bit[`WUJIAN100_OPEN_TOP_DATA_WIDTH-1:0] wdata);
  ahbm_swrite_seq ahbm_swrite = ahbm_swrite_seq::type_id::create("swrite");
  $cast(ahbm_swrite.trans_size, BYTE);
  ahbm_swrite.addr = addr;
  ahbm_swrite.wdata_array[0][31:0] = wdata;
  ahbm_swrite.start(m_ahb_mst_seqr_h[0]);
endtask

// 8-bit register read
task rd_reg8(bit[`WUJIAN100_OPEN_TOP_ADDR_WIDTH-1:0] addr,
             output bit[`WUJIAN100_OPEN_TOP_DATA_WIDTH-1:0] rdata);
  ahbm_sread_seq ahbm_sread = ahbm_sread_seq::type_id::create("sread");
  $cast(ahbm_sread.trans_size, BYTE);
  ahbm_sread.addr = addr;
  ahbm_sread.start(m_ahb_mst_seqr_h[0]);
  rdata = ahbm_sread.rdata_array[0][7:0];
endtask

// 8-bit partial write (bit slice)
task sub_wr8(bit[`WUJIAN100_OPEN_TOP_ADDR_WIDTH-1:0] addr,
             bit[`WUJIAN100_OPEN_TOP_DATA_WIDTH-1:0] wdata,
             input [2:0] h, input [2:0] l);
  reg [7:0] reg_out;
  reg [3:0] sub_wr_i;
  begin
    if (h < l)
      `uvm_fatal("INFO","sub_wr parameter error .... ");
    rd_reg8(addr, reg_out);
    for (sub_wr_i = l; sub_wr_i <= h; sub_wr_i = sub_wr_i + 1) begin
      reg_out[sub_wr_i] = wdata[sub_wr_i - l];
    end
    wr_reg8(addr, reg_out);
  end
endtask

// 32-bit register write
task wr_reg32(bit[`WUJIAN100_OPEN_TOP_ADDR_WIDTH-1:0] addr,
              bit[`WUJIAN100_OPEN_TOP_DATA_WIDTH*4-1:0] wdata);
  ahbm_swrite_seq ahbm_swrite = ahbm_swrite_seq::type_id::create("swrite");
  $cast(ahbm_swrite.trans_size, WORD);
  ahbm_swrite.addr = addr;
  ahbm_swrite.wdata_array[0][31:0] = wdata;
  ahbm_swrite.start(m_ahb_mst_seqr_h[0]);
endtask

// 32-bit register read
task rd_reg32(bit[`WUJIAN100_OPEN_TOP_ADDR_WIDTH-1:0] addr,
              output bit[`WUJIAN100_OPEN_TOP_DATA_WIDTH*4-1:0] rdata);
  ahbm_sread_seq ahbm_sread = ahbm_sread_seq::type_id::create("sread");
  $cast(ahbm_sread.trans_size, WORD);
  ahbm_sread.addr = addr;
  ahbm_sread.start(m_ahb_mst_seqr_h[0]);
  rdata = ahbm_sread.rdata_array[0][31:0];
endtask

// 32-bit partial write (bit slice)
task sub_wr32(bit[`WUJIAN100_OPEN_TOP_ADDR_WIDTH-1:0] addr,
              bit[`WUJIAN100_OPEN_TOP_DATA_WIDTH*4-1:0] wdata,
              input [4:0] h, input [4:0] l);
  reg [31:0] reg_out;
  reg [4:0]  sub_wr_i;
  begin
    if (h < l)
      `uvm_fatal("INFO","sub_wr parameter error .... ");
    rd_reg32(addr, reg_out);
    for (sub_wr_i = l; sub_wr_i <= h; sub_wr_i = sub_wr_i + 1) begin
      reg_out[sub_wr_i] = wdata[sub_wr_i - l];
    end
    wr_reg32(addr, reg_out);
  end
endtask

// 16-bit register write
task wr_reg16(bit[`WUJIAN100_OPEN_TOP_ADDR_WIDTH-1:0] addr,
              bit[`WUJIAN100_OPEN_TOP_DATA_WIDTH*4-1:0] wdata);
  ahbm_swrite_seq ahbm_swrite = ahbm_swrite_seq::type_id::create("swrite");
  $cast(ahbm_swrite.trans_size, HALFWORD);
  ahbm_swrite.addr = addr;
  ahbm_swrite.wdata_array[0][15:0] = wdata;
  ahbm_swrite.start(m_ahb_mst_seqr_h[0]);
endtask

// 16-bit register read
task rd_reg16(bit[`WUJIAN100_OPEN_TOP_ADDR_WIDTH-1:0] addr,
              output bit[`WUJIAN100_OPEN_TOP_DATA_WIDTH*4-1:0] rdata);
  ahbm_sread_seq ahbm_sread = ahbm_sread_seq::type_id::create("sread");
  $cast(ahbm_sread.trans_size, HALFWORD);
  ahbm_sread.addr = addr;
  ahbm_sread.start(m_ahb_mst_seqr_h[0]);
  rdata = ahbm_sread.rdata_array[0][15:0];
endtask

// 16-bit partial write (bit slice)
task sub_wr16(bit[`WUJIAN100_OPEN_TOP_ADDR_WIDTH-1:0] addr,
              bit[`WUJIAN100_OPEN_TOP_DATA_WIDTH-1:0] wdata,
              input [3:0] h, input [3:0] l);
  reg [15:0] reg_out;
  reg [3:0]  sub_wr_i;
  begin
    if (h < l)
      `uvm_fatal("INFO","sub_wr parameter error .... ");
    rd_reg16(addr, reg_out);
    for (sub_wr_i = l; sub_wr_i <= h; sub_wr_i = sub_wr_i + 1) begin
      reg_out[sub_wr_i] = wdata[sub_wr_i - l];
    end
    wr_reg16(addr, reg_out);
  end
endtask