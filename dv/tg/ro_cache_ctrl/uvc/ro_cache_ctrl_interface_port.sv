interface ro_cache_ctrl_interface_port;
parameter mem_depth = 32;
parameter data_width = 32;
parameter cache_num = 4;
parameter cache_id = 0;
parameter addr_width = 32;
parameter list_depth = 4;
parameter id_width = $clog2(cache_num) == 0 ? 1 : $clog2(cache_num);
parameter list_width = 32;
logic clk;
logic rst_n;
logic acc_rd_valid_0;
logic acc_rd_ready_0;
logic [addr_width - 1 : 0] acc_rd_addr_0;
logic [data_width - 1 : 0] acc_rd_data_0;
logic acc_rd_data_valid_0;
logic acc_rd_done_0;
logic acc_rd_valid_1;
logic acc_rd_ready_1;
logic [addr_width - 1 : 0] acc_rd_addr_1;
logic [data_width - 1 : 0] acc_rd_data_1;
logic acc_rd_data_valid_1;
logic acc_rd_done_1;
logic wr_req;
logic wr_gnt;
logic [15:0] wr_len;
logic [addr_width - 1 : 0] wr_addr;
logic [data_width - 1 : 0] wr_data;
logic wr_last;
logic wr_done;
logic wr_valid;
logic wr_ready;
logic rd_req;
logic rd_gnt;
logic [15:0] rd_len;
logic [addr_width - 1 : 0] rd_addr;
logic [data_width - 1 : 0] rd_data;
logic rd_done;
logic rd_valid;
logic msg_req;
logic msg_gnt;
logic [4 + 2 * id_width + addr_width - 1 : 0] msg;
logic msg_in_valid;
logic [4 + 2 * id_width + addr_width - 1 : 0] msg_in;
logic rd_ready;




endinterface