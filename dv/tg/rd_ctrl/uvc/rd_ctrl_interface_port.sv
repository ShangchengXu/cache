interface rd_ctrl_interface_port;
parameter addr_width = 32;
parameter list_depth = 4;
parameter data_width = 32;
parameter list_width = 32;
logic clk;
logic rst_n;
logic rd_valid;
logic rd_ready;
logic [addr_width - 1 : 0] rd_addr;
logic [data_width - 1 : 0] rd_data;
logic rd_data_valid;
logic [addr_width - 1 :0] acc_index;
logic [2:0] acc_status;
logic [1:0] acc_cmd;
logic [$clog2(list_depth) - 1 : 0] acc_tag;
logic [$clog2(list_depth) - 1 : 0] return_tag;
logic acc_req;
logic [2:0] proc_status_r;
logic [addr_width - 1 : 0] proc_addr_r;
logic [2:0] proc_status_w;
logic [addr_width - 1 : 0] proc_addr_w;
logic [1:0] fetch_cmd;
logic fetch_req;
logic [$clog2(list_depth) - 1 : 0] fetch_tag;
logic [addr_width - 1 : 0] fetch_addr;
logic fetch_gnt;
logic fetch_done;
logic [$clog2(list_depth) + $clog2(list_width) - 1 : 0] mem_raddr;
logic mem_ren;
logic mem_rready;
logic [data_width - 1 : 0] mem_rdata;
logic mem_rdata_valid;




endinterface