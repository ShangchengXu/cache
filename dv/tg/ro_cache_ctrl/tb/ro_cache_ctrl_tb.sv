`include "uvm_macros.svh"
module ro_cache_ctrl_tb;
parameter mem_depth = 32;
parameter data_width = 32;
parameter cache_num = 1;
parameter cache_id = 0;
parameter addr_width = 32;
parameter list_depth = 4;
parameter id_width = $clog2(cache_num) == 0 ? 1 : $clog2(cache_num);
parameter list_width = 32;
ro_cache_ctrl_interface_port #(
        .mem_depth   (mem_depth   ),
        .data_width  (data_width  ),
        .cache_num   (cache_num   ),
        .cache_id    (cache_id    ),
        .addr_width  (addr_width  ),
        .list_depth  (list_depth  ),
        .id_width    (id_width    ),
        .list_width  (list_width  ))
                             ifo ();
ro_cache_ctrl_interface_inner ifi ();
logic clk;
logic rst_n;
logic rst_p;
ro_cache_ctrl #(
        .mem_depth   (mem_depth   ),
        .data_width  (data_width  ),
        .cache_num   (cache_num   ),
        .cache_id    (cache_id    ),
        .addr_width  (addr_width  ),
        .list_depth  (list_depth  ),
        .id_width    (id_width    ),
        .list_width  (list_width  ))
              ro_cache_ctrl_inst (
        .clk                  (ifo.clk                ) ,//input   
        .rst_n                (ifo.rst_n              ) ,//input   
        .acc_rd_valid_0       (ifo.acc_rd_valid_0     ) ,//input   
        .acc_rd_ready_0       (ifo.acc_rd_ready_0     ) ,//output  
        .acc_rd_addr_0        (ifo.acc_rd_addr_0      ) ,//input   [addr_width - 1 : 0]
        .acc_rd_data_0        (ifo.acc_rd_data_0      ) ,//output  [data_width - 1 : 0]
        .acc_rd_data_valid_0  (ifo.acc_rd_data_valid_0) ,//output  
        .acc_rd_done_0        (ifo.acc_rd_done_0      ) ,//output  
        .acc_rd_valid_1       (ifo.acc_rd_valid_1     ) ,//input   
        .acc_rd_ready_1       (ifo.acc_rd_ready_1     ) ,//output  
        .acc_rd_addr_1        (ifo.acc_rd_addr_1      ) ,//input   [addr_width - 1 : 0]
        .acc_rd_data_1        (ifo.acc_rd_data_1      ) ,//output  [data_width - 1 : 0]
        .acc_rd_data_valid_1  (ifo.acc_rd_data_valid_1) ,//output  
        .acc_rd_done_1        (ifo.acc_rd_done_1      ) ,//output  
        .wr_req               (ifo.wr_req             ) ,//output  
        .wr_gnt               (ifo.wr_gnt             ) ,//input   
        .wr_len               (ifo.wr_len             ) ,//output  [15:0]
        .wr_addr              (ifo.wr_addr            ) ,//output  [addr_width - 1 : 0]
        .wr_data              (ifo.wr_data            ) ,//output  [data_width - 1 : 0]
        .wr_last              (ifo.wr_last            ) ,//output  
        .wr_done              (ifo.wr_done            ) ,//input   
        .wr_valid             (ifo.wr_valid           ) ,//output  
        .wr_ready             (ifo.wr_ready           ) ,//input   
        .rd_req               (ifo.rd_req             ) ,//output  
        .rd_gnt               (ifo.rd_gnt             ) ,//input   
        .rd_len               (ifo.rd_len             ) ,//output  [15:0]
        .rd_addr              (ifo.rd_addr            ) ,//output  [addr_width - 1 : 0]
        .rd_data              (ifo.rd_data            ) ,//input   [data_width - 1 : 0]
        .rd_done              (ifo.rd_done            ) ,//input   
        .rd_valid             (ifo.rd_valid           ) ,//input   
        .msg_req              (ifo.msg_req            ) ,//output  
        .msg_gnt              (ifo.msg_gnt            ) ,//input   
        .msg                  (ifo.msg                ) ,//output  [4 + 2 * id_width + addr_width - 1 : 0]
        .msg_in_valid         (ifo.msg_in_valid       ) ,//input   
        .msg_in               (ifo.msg_in             ) ,//input   [4 + 2 * id_width + addr_width - 1 : 0]
        .rd_ready             (ifo.rd_ready           ));//output  
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
   uvm_config_db#(virtual ro_cache_ctrl_interface_port)::set(null, "uvm_test_top.env.mst_agt.drv", "vif", ifo);
   uvm_config_db#(virtual ro_cache_ctrl_interface_port)::set(null, "uvm_test_top.env.mst_agt.mon", "vif", ifo);
   uvm_config_db#(virtual ro_cache_ctrl_interface_port)::set(null, "uvm_test_top.env.mst_agt1.drv", "vif", ifo);
   uvm_config_db#(virtual ro_cache_ctrl_interface_port)::set(null, "uvm_test_top.env.slv_agt.mon", "vif", ifo);
   uvm_config_db#(virtual ro_cache_ctrl_interface_inner)::set(null, "uvm_test_top.env.mst_agt.drv", "vif_i", ifi);
   uvm_config_db#(virtual ro_cache_ctrl_interface_inner)::set(null, "uvm_test_top.env.mst_agt1.drv", "vif_i", ifi);
   uvm_config_db#(virtual ro_cache_ctrl_interface_inner)::set(null, "uvm_test_top.env.mst_agt.mon", "vif_i", ifi);
   uvm_config_db#(virtual ro_cache_ctrl_interface_inner)::set(null, "uvm_test_top.env.slv_agt.mon", "vif_i", ifi);
end
initial begin
   $fsdbDumpvars();
end





endmodule
