interface cache_ctrl_interface_port;
parameter mem_depth = 32;
parameter data_width = 32;
parameter addr_width = 32;
parameter cache_num = 4;
parameter cache_id = 0;
parameter list_depth = 4;
parameter list_width = 32;
logic clk;
logic rst_n;
logic acc_rd_valid;
logic acc_rd_ready;
logic [addr_width - 1 : 0] acc_rd_addr;
logic [data_width - 1 : 0] acc_rd_data;
logic acc_rd_data_valid;
logic acc_wr_valid;
logic acc_wr_ready;
logic [addr_width - 1 : 0] acc_wr_addr;
logic [data_width - 1 : 0] acc_wr_data;
logic wr_req;
logic wr_gnt;
logic [15:0] wr_len;
logic [addr_width - 1 : 0] wr_addr;
logic [data_width - 1 : 0] wr_data;
logic wr_last;
logic wr_done;
logic acc_wr_done;
logic acc_rd_done;
logic wr_valid;
logic wr_ready;
logic rd_req;
logic rd_gnt;
logic [15:0] rd_len;
logic [addr_width - 1 : 0] rd_addr;
logic [data_width - 1 : 0] rd_data;
logic rd_done;
logic rd_valid;
logic rd_ready;

logic                                     msg_req;
logic                                     msg_gnt;
logic [4 + 2 * $clog2(cache_num) + addr_width - 1 : 0] msg;
logic                                     msg_in_valid;
logic [4 + 2 * $clog2(cache_num) + addr_width - 1 : 0] msg_in;



endinterface