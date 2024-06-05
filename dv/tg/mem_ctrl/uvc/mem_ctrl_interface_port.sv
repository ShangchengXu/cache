interface mem_ctrl_interface_port;
parameter mem_depth = 32;
parameter data_width = 32;
logic clk;
logic rst_n;
logic [$clog2(mem_depth) - 1 : 0] mem_raddr;
logic mem_ren;
logic mem_rready;
logic [data_width - 1 : 0] mem_rdata;
logic mem_rdata_valid;
logic [$clog2(mem_depth) - 1 : 0] mem_waddr;
logic mem_wen;
logic mem_wready;
logic [data_width - 1 : 0] mem_wdata;
logic [$clog2(mem_depth) - 1 : 0] fetch_mem_raddr;
logic fetch_mem_ren;
logic fetch_mem_rready;
logic [data_width - 1 : 0] fetch_mem_rdata;
logic fetch_mem_rdata_valid;
logic [$clog2(mem_depth) - 1 : 0] fetch_mem_waddr;
logic fetch_mem_wen;
logic fetch_mem_wready;
logic [data_width - 1 : 0] fetch_mem_wdata;




endinterface