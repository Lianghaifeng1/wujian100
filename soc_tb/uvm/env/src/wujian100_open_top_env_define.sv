
`define AHB_MST_AGENT_NUM 1
`define AHB_SLV_AGENT_NUM 1

`define CDN_AHB_NUM_OF_SLAVES       `AHB_SLV_AGENT_NUM
`define CDN_AHB_NUM_OF_MASTERS      `AHB_MST_AGENT_NUM
`define CDN_AHB_ADDRESS_WIDTH       32
`define CDN_AHB_DATA_WIDTH          32
`define CDN_AHB_DEFAULT_SLAVE_IDX   0
`define WUJIAN100_OPEN_TOP_DATA_WIDTH 32
`define WUJIAN100_OPEN_TOP_ADDR_WIDTH 32

typedef enum bit [1:0] {
  RstAssertSyncDeassertSync,
  RstAssertAsyncDeassertSync,
  RstAssertAsyncDeassertAsync
} rst_scheme_e;

`ifndef SOC_TEST
typedef enum bit [2:0] {SINGLE, INCR, WRAP4, INCR4, WRAP8, INCR8, WRAP16, INCR16} burst_t;
typedef enum bit [2:0] {BYTE, HALFWORD, WORD, WORDx2, WORDx4, WORDx8, WORDx16, WORDx32} size_t;
typedef enum bit {READ, WRITE} write_t;
typedef enum bit[1:0] {IDLE, BUSY, NONSEQ, SEQ} trans_t;
`endif