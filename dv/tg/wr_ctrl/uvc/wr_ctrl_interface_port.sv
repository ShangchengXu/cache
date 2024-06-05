interface wr_ctrl_interface_port;
parameter addr_width = 32;
parameter list_depth = 4;
parameter data_width = 32;
parameter list_width = 32;
logic clk;
logic rst_n;
logic wr_valid;
logic wr_ready;
logic [addr_width - 1 : 0] wr_addr;
logic [data_width - 1 : 0] wr_data;
logic [addr_width - 1 :0] acc_index;
logic [2:0] acc_status;
logic [1:0] acc_cmd;
logic [$clog2(list_depth) - 1 : 0] acc_tag;
logic [$clog2(list_depth) - 1 : 0] return_tag;
logic acc_req;
logic [2:0] proc_status_w;
logic [addr_width - 1 : 0] proc_addr_w;
logic [2:0] proc_status_r;
logic [addr_width - 1 : 0] proc_addr_r;
logic [1:0] fetch_cmd;
logic fetch_req;
logic [$clog2(list_depth) - 1 : 0] fetch_tag;
logic [addr_width - 1 : 0] fetch_addr;
logic fetch_gnt;
logic fetch_done;
logic [$clog2(list_depth) + $clog2(list_width) - 1 : 0] mem_waddr;
logic mem_wen;
logic mem_wready;
logic [data_width - 1 : 0] mem_wdata;




endinterface