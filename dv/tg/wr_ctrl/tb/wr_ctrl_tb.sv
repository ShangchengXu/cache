`include "uvm_macros.svh"
module wr_ctrl_tb;
parameter addr_width = 32;
parameter list_depth = 4;
parameter data_width = 32;
parameter list_width = 32;
wr_ctrl_interface_port #(
        .addr_width  (addr_width  ),
        .list_depth  (list_depth  ),
        .data_width  (data_width  ),
        .list_width  (list_width  ))
                       ifo ();
wr_ctrl_interface_inner ifi ();
logic clk;
logic rst_n;
logic rst_p;
wr_ctrl #(
        .addr_width  (addr_width  ),
        .list_depth  (list_depth  ),
        .data_width  (data_width  ),
        .list_width  (list_width  ))
        wr_ctrl_inst (
        .clk            (ifo.clk          ) ,//input   
        .rst_n          (ifo.rst_n        ) ,//input   
        .wr_valid       (ifo.wr_valid     ) ,//input   
        .wr_ready       (ifo.wr_ready     ) ,//output  
        .wr_addr        (ifo.wr_addr      ) ,//input   [addr_width - 1 : 0]
        .wr_data        (ifo.wr_data      ) ,//input   [data_width - 1 : 0]
        .acc_index      (ifo.acc_index    ) ,//output  [addr_width - 1 :0]
        .acc_status     (ifo.acc_status   ) ,//input   [2:0]
        .acc_cmd        (ifo.acc_cmd      ) ,//output  [1:0]
        .acc_tag        (ifo.acc_tag      ) ,//output  [$clog2(list_depth) - 1 : 0]
        .return_tag     (ifo.return_tag   ) ,//input   [$clog2(list_depth) - 1 : 0]
        .acc_req        (ifo.acc_req      ) ,//output  
        .proc_status_w  (ifo.proc_status_w) ,//output  [2:0]
        .proc_addr_w    (ifo.proc_addr_w  ) ,//output  [addr_width - 1 : 0]
        .proc_status_r  (ifo.proc_status_r) ,//input   [2:0]
        .proc_addr_r    (ifo.proc_addr_r  ) ,//input   [addr_width - 1 : 0]
        .fetch_cmd      (ifo.fetch_cmd    ) ,//output  [1:0]
        .fetch_req      (ifo.fetch_req    ) ,//output  
        .fetch_tag      (ifo.fetch_tag    ) ,//output  [$clog2(list_depth) - 1 : 0]
        .fetch_addr     (ifo.fetch_addr   ) ,//output  [addr_width - 1 : 0]
        .fetch_gnt      (ifo.fetch_gnt    ) ,//input   
        .fetch_done     (ifo.fetch_done   ) ,//input   
        .mem_waddr      (ifo.mem_waddr    ) ,//output  [$clog2(list_depth) + $clog2(list_width) - 1 : 0]
        .mem_wen        (ifo.mem_wen      ) ,//output  
        .mem_wready     (ifo.mem_wready   ) ,//input   
        .mem_wdata      (ifo.mem_wdata    ));//output  [data_width - 1 : 0]
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
   uvm_config_db#(virtual wr_ctrl_interface_port)::set(null, "uvm_test_top.env.mst_agt.drv", "vif", ifo);
   uvm_config_db#(virtual wr_ctrl_interface_port)::set(null, "uvm_test_top.env.mst_agt.mon", "vif", ifo);
   uvm_config_db#(virtual wr_ctrl_interface_port)::set(null, "uvm_test_top.env.slv_agt.mon", "vif", ifo);
   uvm_config_db#(virtual wr_ctrl_interface_inner)::set(null, "uvm_test_top.env.mst_agt.drv", "vif_i", ifi);
   uvm_config_db#(virtual wr_ctrl_interface_inner)::set(null, "uvm_test_top.env.mst_agt.mon", "vif_i", ifi);
   uvm_config_db#(virtual wr_ctrl_interface_inner)::set(null, "uvm_test_top.env.slv_agt.mon", "vif_i", ifi);
end
initial begin
   $fsdbDumpvars();
end





endmodule
