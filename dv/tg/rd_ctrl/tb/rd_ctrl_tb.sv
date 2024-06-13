`include "uvm_macros.svh"
module rd_ctrl_tb;
parameter addr_width = 32;
parameter list_depth = 4;
parameter data_width = 32;
parameter list_width = 32;
rd_ctrl_interface_port #(
        .addr_width  (addr_width  ),
        .list_depth  (list_depth  ),
        .data_width  (data_width  ),
        .list_width  (list_width  ))
                       ifo ();
rd_ctrl_interface_inner ifi ();
logic clk;
logic rst_n;
logic rst_p;
rd_ctrl #(
        .addr_width  (addr_width  ),
        .list_depth  (list_depth  ),
        .data_width  (data_width  ),
        .list_width  (list_width  ))
        rd_ctrl_inst (
        .clk              (ifo.clk            ) ,//input   
        .rst_n            (ifo.rst_n          ) ,//input   
        .rd_valid         (ifo.rd_valid       ) ,//input   
        .rd_ready         (ifo.rd_ready       ) ,//output  
        .rd_addr          (ifo.rd_addr        ) ,//input   [addr_width - 1 : 0]
        .rd_data          (ifo.rd_data        ) ,//output  [data_width - 1 : 0]
        .rd_data_valid    (ifo.rd_data_valid  ) ,//output  
        .acc_index        (ifo.acc_index      ) ,//output  [addr_width - 1 :0]
        .acc_status       (ifo.acc_status     ) ,//input   [2:0]
        .acc_cmd          (ifo.acc_cmd        ) ,//output  [1:0]
        .acc_tag          (ifo.acc_tag        ) ,//output  [$clog2(list_depth) - 1 : 0]
        .return_tag       (ifo.return_tag     ) ,//input   [$clog2(list_depth) - 1 : 0]
        .acc_req          (ifo.acc_req        ) ,//output  
        .proc_status_r    (ifo.proc_status_r  ) ,//output  [2:0]
        .proc_addr_r      (ifo.proc_addr_r    ) ,//output  [addr_width - 1 : 0]
        .proc_status_w    (ifo.proc_status_w  ) ,//input   [2:0]
        .proc_addr_w      (ifo.proc_addr_w    ) ,//input   [addr_width - 1 : 0]
        .fetch_cmd        (ifo.fetch_cmd      ) ,//output  [1:0]
        .fetch_req        (ifo.fetch_req      ) ,//output  
        .fetch_tag        (ifo.fetch_tag      ) ,//output  [$clog2(list_depth) - 1 : 0]
        .fetch_addr       (ifo.fetch_addr     ) ,//output  [addr_width - 1 : 0]
        .fetch_gnt        (ifo.fetch_gnt      ) ,//input   
        .fetch_done       (ifo.fetch_done     ) ,//input   
        .mem_raddr        (ifo.mem_raddr      ) ,//output  [$clog2(list_depth) + $clog2(list_width) - 1 : 0]
        .mem_ren          (ifo.mem_ren        ) ,//output  
        .mem_rready       (ifo.mem_rready     ) ,//input   
        .mem_rdata        (ifo.mem_rdata      ) ,//input   [data_width - 1 : 0]
        .mem_rdata_valid  (ifo.mem_rdata_valid));//input   
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
   uvm_config_db#(virtual rd_ctrl_interface_port)::set(null, "uvm_test_top.env.mst_agt.drv", "vif", ifo);
   uvm_config_db#(virtual rd_ctrl_interface_port)::set(null, "uvm_test_top.env.mst_agt.mon", "vif", ifo);
   uvm_config_db#(virtual rd_ctrl_interface_port)::set(null, "uvm_test_top.env.slv_agt.mon", "vif", ifo);
   uvm_config_db#(virtual rd_ctrl_interface_inner)::set(null, "uvm_test_top.env.mst_agt.drv", "vif_i", ifi);
   uvm_config_db#(virtual rd_ctrl_interface_inner)::set(null, "uvm_test_top.env.mst_agt.mon", "vif_i", ifi);
   uvm_config_db#(virtual rd_ctrl_interface_inner)::set(null, "uvm_test_top.env.slv_agt.mon", "vif_i", ifi);
end
initial begin
   $fsdbDumpvars();
end





endmodule
