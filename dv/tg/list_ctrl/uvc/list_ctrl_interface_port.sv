interface list_ctrl_interface_port;
parameter list_depth = 4;
parameter index_lenth = 4;
logic clk;
logic rst_n;
logic [index_lenth - 1 :0] acc_index_0;
logic [2:0] acc_status_0;
logic [1:0] acc_cmd_0;
logic [$clog2(list_depth) - 1 : 0] acc_tag_0;
logic [$clog2(list_depth) - 1 : 0] return_tag_0;
logic acc_req_0;
logic [index_lenth - 1 :0] acc_index_1;
logic [2:0] acc_status_1;
logic [1:0] acc_cmd_1;
logic [$clog2(list_depth) - 1 : 0] acc_tag_1;
logic [$clog2(list_depth) - 1 : 0] return_tag_1;
logic acc_req_1;




endinterface