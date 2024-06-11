`include "uvm_macros.svh"
module cache_ctrl_tb;
parameter lists_depth = 4;
parameter mem_depth = 32;
parameter data_width = 32;
parameter addr_width = 32;
parameter list_depth = 4;
parameter list_width = 32;
cache_ctrl_interface_port #(
        .lists_depth  (lists_depth  ),
        .mem_depth    (mem_depth    ),
        .data_width   (data_width   ),
        .addr_width   (addr_width   ),
        .list_depth   (list_depth   ),
        .list_width   (list_width   ))
                          ifo ();
cache_ctrl_interface_inner ifi ();
logic clk;
logic rst_n;
logic rst_p;
cache_ctrl #(
        .lists_depth  (lists_depth  ),
        .mem_depth    (mem_depth    ),
        .data_width   (data_width   ),
        .addr_width   (addr_width   ),
        .list_depth   (list_depth   ),
        .list_width   (list_width   ))
           cache_ctrl_inst (
        .clk                (ifo.clk              ) ,//input   
        .rst_n              (ifo.rst_n            ) ,//input   
        .acc_rd_valid       (ifo.acc_rd_valid     ) ,//input   
        .acc_rd_ready       (ifo.acc_rd_ready     ) ,//output  
        .acc_rd_addr        (ifo.acc_rd_addr      ) ,//input   [addr_width - 1 : 0]
        .acc_rd_data        (ifo.acc_rd_data      ) ,//output  [data_width - 1 : 0]
        .acc_rd_data_valid  (ifo.acc_rd_data_valid) ,//output  
        .acc_wr_valid       (ifo.acc_wr_valid     ) ,//input   
        .acc_wr_ready       (ifo.acc_wr_ready     ) ,//output  
        .acc_wr_addr        (ifo.acc_wr_addr      ) ,//input   [addr_width - 1 : 0]
        .acc_wr_data        (ifo.acc_wr_data      ) ,//input   [data_width - 1 : 0]
        .wr_req             (ifo.wr_req           ) ,//output  
        .wr_gnt             (ifo.wr_gnt           ) ,//input   
        .wr_len             (ifo.wr_len           ) ,//output  [15:0]
        .wr_addr            (ifo.wr_addr          ) ,//output  [addr_width - 1 : 0]
        .wr_data            (ifo.wr_data          ) ,//output  [data_width - 1 : 0]
        .wr_last            (ifo.wr_last          ) ,//output  
        .wr_done            (ifo.wr_done          ) ,//input   
        .wr_valid           (ifo.wr_valid         ) ,//output  
        .wr_ready           (ifo.wr_ready         ) ,//input   
        .rd_req             (ifo.rd_req           ) ,//output  
        .rd_gnt             (ifo.rd_gnt           ) ,//input   
        .rd_len             (ifo.rd_len           ) ,//output  [15:0]
        .rd_addr            (ifo.rd_addr          ) ,//output  [addr_width - 1 : 0]
        .rd_data            (ifo.rd_data          ) ,//input   [data_width - 1 : 0]
        .rd_done            (ifo.rd_done          ) ,//input   
        .rd_valid           (ifo.rd_valid         ) ,//input   
        .rd_ready           (ifo.rd_ready         ));//output  
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
   uvm_config_db#(virtual cache_ctrl_interface_port)::set(null, "uvm_test_top.env.mst_agt.drv", "vif", ifo);
   uvm_config_db#(virtual cache_ctrl_interface_port)::set(null, "uvm_test_top.env.mst_agt1.drv", "vif", ifo);
   uvm_config_db#(virtual cache_ctrl_interface_port)::set(null, "uvm_test_top.env.mst_agt.mon", "vif", ifo);
   uvm_config_db#(virtual cache_ctrl_interface_port)::set(null, "uvm_test_top.env.slv_agt.mon", "vif", ifo);
   uvm_config_db#(virtual cache_ctrl_interface_inner)::set(null, "uvm_test_top.env.mst_agt1.drv", "vif_i", ifi);
   uvm_config_db#(virtual cache_ctrl_interface_inner)::set(null, "uvm_test_top.env.mst_agt.drv", "vif_i", ifi);
   uvm_config_db#(virtual cache_ctrl_interface_inner)::set(null, "uvm_test_top.env.mst_agt.mon", "vif_i", ifi);
   uvm_config_db#(virtual cache_ctrl_interface_inner)::set(null, "uvm_test_top.env.slv_agt.mon", "vif_i", ifi);
end
initial begin
   $fsdbDumpvars();
end





endmodule
