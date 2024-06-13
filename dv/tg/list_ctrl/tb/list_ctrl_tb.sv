`include "uvm_macros.svh"
module list_ctrl_tb;
parameter list_depth = 4;
parameter index_lenth = 4;
list_ctrl_interface_port #(
        .list_depth  (list_depth  ),
        .index_lenth  (index_lenth  ))
                         ifo ();
list_ctrl_interface_inner ifi ();
logic clk;
logic rst_n;
logic rst_p;
list_ctrl #(
        .list_depth  (list_depth  ),
        .index_lenth  (index_lenth  ))
          list_ctrl_inst (
        .clk           (ifo.clk         ) ,//input   
        .rst_n         (ifo.rst_n       ) ,//input   
        .acc_index_0   (ifo.acc_index_0 ) ,//input   [index_lenth - 1 :0]
        .acc_status_0  (ifo.acc_status_0) ,//output  [2:0]
        .acc_cmd_0     (ifo.acc_cmd_0   ) ,//input   [1:0]
        .acc_tag_0     (ifo.acc_tag_0   ) ,//input   [$clog2(list_depth) - 1 : 0]
        .return_tag_0  (ifo.return_tag_0) ,//output  [$clog2(list_depth) - 1 : 0]
        .acc_req_0     (ifo.acc_req_0   ) ,//input   
        .acc_index_1   (ifo.acc_index_1 ) ,//input   [index_lenth - 1 :0]
        .acc_status_1  (ifo.acc_status_1) ,//output  [2:0]
        .acc_cmd_1     (ifo.acc_cmd_1   ) ,//input   [1:0]
        .acc_tag_1     (ifo.acc_tag_1   ) ,//input   [$clog2(list_depth) - 1 : 0]
        .return_tag_1  (ifo.return_tag_1) ,//output  [$clog2(list_depth) - 1 : 0]
        .acc_req_1     (ifo.acc_req_1   ));//input   
always #5 clk = ~clk;

initial begin
clk = 0;
rst_n = 0;
rst_p = 1;
#2 rst_n = 1;
#1 rst_p = 0;

end

always_comb begin
ifo.clk = clk;
ifo.rst_n = rst_n;

end

initial begin
   run_test();
end

initial begin
   uvm_config_db#(virtual list_ctrl_interface_port)::set(null, "uvm_test_top.env.mst_agt.drv", "vif", ifo);
   uvm_config_db#(virtual list_ctrl_interface_port)::set(null, "uvm_test_top.env.mst_agt.mon", "vif", ifo);
   uvm_config_db#(virtual list_ctrl_interface_port)::set(null, "uvm_test_top.env.slv_agt.mon", "vif", ifo);
   uvm_config_db#(virtual list_ctrl_interface_inner)::set(null, "uvm_test_top.env.mst_agt.drv", "vif_i", ifi);
   uvm_config_db#(virtual list_ctrl_interface_inner)::set(null, "uvm_test_top.env.mst_agt.mon", "vif_i", ifi);
   uvm_config_db#(virtual list_ctrl_interface_inner)::set(null, "uvm_test_top.env.slv_agt.mon", "vif_i", ifi);
end
initial begin
   $fsdbDumpvars();
end





endmodule
