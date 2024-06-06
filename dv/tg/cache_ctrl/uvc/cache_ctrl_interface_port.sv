interface cache_ctrl_interface_port;
parameter lists_depth = 4;
parameter mem_depth = 32;
parameter data_width = 32;
parameter addr_width = 32;
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




endinterface