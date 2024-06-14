`include "uvm_macros.svh"
module cache_ctrl_tb;
parameter mem_depth = 32;
parameter data_width = 32;
parameter addr_width = 32;
parameter list_depth = 32;
parameter list_width = 32;
parameter cache_num = 2;
parameter cache_id = 0;
cache_ctrl_interface_port #(
        .mem_depth    (mem_depth    ),
        .data_width   (data_width   ),
        .cache_id     (cache_id     ),
        .cache_num    (cache_num    ),
        .addr_width   (addr_width   ),
        .list_depth   (list_depth   ),
        .list_width   (list_width   ))
                          ifo ();

cache_ctrl_interface_port #(
        .mem_depth    (mem_depth    ),
        .data_width   (data_width   ),
        .cache_id     (cache_id     ),
        .cache_num    (cache_num    ),
        .addr_width   (addr_width   ),
        .list_depth   (list_depth   ),
        .list_width   (list_width   ))
                          ifo1 ();
cache_ctrl_interface_inner ifi ();
logic clk;
logic rst_n;
logic rst_p;
cache_ctrl #(
        .mem_depth    (mem_depth    ),
        .cache_id     (0     ),
        .cache_num    (cache_num    ),
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
        .acc_wr_done        (ifo.acc_wr_done      ) ,
        .acc_rd_done        (ifo.acc_rd_done      ) ,
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
        .msg_req            (ifo.msg_req          ) ,//output  
        .msg_gnt            (ifo.msg_gnt          ) ,//input   
        .msg                (ifo.msg              ) ,//output  [4 + 2 * $clog2(cache_num) - 1 : 0]
        .msg_in_valid       (ifo.msg_in_valid     ) ,//input   
        .msg_in             (ifo.msg_in           ) ,//input   [4 + 2 * $clog2(cache_num) - 1 : 0]
        .rd_addr            (ifo.rd_addr          ) ,//output  [addr_width - 1 : 0]
        .rd_data            (ifo.rd_data          ) ,//input   [data_width - 1 : 0]
        .rd_done            (ifo.rd_done          ) ,//input   
        .rd_valid           (ifo.rd_valid         ) ,//input   
        .rd_ready           (ifo.rd_ready         ));//output  


cache_ctrl #(
        .mem_depth    (mem_depth    ),
        .cache_id     (1     ),
        .cache_num    (cache_num    ),
        .data_width   (data_width   ),
        .addr_width   (addr_width   ),
        .list_depth   (list_depth   ),
        .list_width   (list_width   ))
           cache_ctrl_inst1 (
        .clk                (ifo1.clk              ) ,//input   
        .rst_n              (ifo1.rst_n            ) ,//input   
        .acc_rd_valid       (ifo1.acc_rd_valid     ) ,//input   
        .acc_rd_ready       (ifo1.acc_rd_ready     ) ,//output  
        .acc_rd_addr        (ifo1.acc_rd_addr      ) ,//input   [addr_width - 1 : 0]
        .acc_rd_data        (ifo1.acc_rd_data      ) ,//output  [data_width - 1 : 0]
        .acc_rd_data_valid  (ifo1.acc_rd_data_valid) ,//output  
        .acc_wr_valid       (ifo1.acc_wr_valid     ) ,//input   
        .acc_wr_ready       (ifo1.acc_wr_ready     ) ,//output  
        .acc_wr_addr        (ifo1.acc_wr_addr      ) ,//input   [addr_width - 1 : 0]
        .acc_wr_data        (ifo1.acc_wr_data      ) ,//input   [data_width - 1 : 0]
        .acc_wr_done        (ifo1.acc_wr_done      ) ,
        .acc_rd_done        (ifo1.acc_rd_done      ) ,
        .wr_req             (ifo1.wr_req           ) ,//output  
        .wr_gnt             (ifo1.wr_gnt           ) ,//input   
        .wr_len             (ifo1.wr_len           ) ,//output  [15:0]
        .wr_addr            (ifo1.wr_addr          ) ,//output  [addr_width - 1 : 0]
        .wr_data            (ifo1.wr_data          ) ,//output  [data_width - 1 : 0]
        .wr_last            (ifo1.wr_last          ) ,//output  
        .wr_done            (ifo1.wr_done          ) ,//input   
        .wr_valid           (ifo1.wr_valid         ) ,//output  
        .wr_ready           (ifo1.wr_ready         ) ,//input   
        .rd_req             (ifo1.rd_req           ) ,//output  
        .rd_gnt             (ifo1.rd_gnt           ) ,//input   
        .rd_len             (ifo1.rd_len           ) ,//output  [15:0]
        .msg_req            (ifo1.msg_req          ) ,//output  
        .msg_gnt            (ifo1.msg_gnt          ) ,//input   
        .msg                (ifo1.msg              ) ,//output  [4 + 2 * $clog2(cache_num) - 1 : 0]
        .msg_in_valid       (ifo1.msg_in_valid     ) ,//input   
        .msg_in             (ifo1.msg_in           ) ,//input   [4 + 2 * $clog2(cache_num) - 1 : 0]
        .rd_addr            (ifo1.rd_addr          ) ,//output  [addr_width - 1 : 0]
        .rd_data            (ifo1.rd_data          ) ,//input   [data_width - 1 : 0]
        .rd_done            (ifo1.rd_done          ) ,//input   
        .rd_valid           (ifo1.rd_valid         ) ,//input   
        .rd_ready           (ifo1.rd_ready         ));//output  


msg_arb #(
      .cache_num (cache_num),
      .addr_width(addr_width)
) msg_arb_inst(
   .clk(ifo.clk),
   .rst_n(ifo.rst_n),
   .msg_req({ifo.msg_req, ifo1.msg_req}),
   .msg_gnt({ifo.msg_gnt,ifo1.msg_gnt}),
   .msg({ifo.msg,ifo1.msg}),
   .msg_out(ifo.msg_in),
   .msg_out_valid(ifo.msg_in_valid)
);





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
ifo1.msg_in = ifo.msg_in;
ifo1.msg_in_valid = ifo.msg_in_valid;
ifo1.clk = clk;
ifo1.rst_n = rst_n;

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



   uvm_config_db#(virtual cache_ctrl_interface_port)::set(null, "uvm_test_top.env1.mst_agt.drv", "vif", ifo1);
   uvm_config_db#(virtual cache_ctrl_interface_port)::set(null, "uvm_test_top.env1.mst_agt1.drv", "vif", ifo1);
   uvm_config_db#(virtual cache_ctrl_interface_port)::set(null, "uvm_test_top.env1.mst_agt.mon", "vif", ifo1);
   uvm_config_db#(virtual cache_ctrl_interface_port)::set(null, "uvm_test_top.env1.slv_agt.mon", "vif", ifo1);
   uvm_config_db#(virtual cache_ctrl_interface_inner)::set(null, "uvm_test_top.env1.mst_agt1.drv", "vif_i", ifi);
   uvm_config_db#(virtual cache_ctrl_interface_inner)::set(null, "uvm_test_top.env1.mst_agt.drv", "vif_i", ifi);
   uvm_config_db#(virtual cache_ctrl_interface_inner)::set(null, "uvm_test_top.env1.mst_agt.mon", "vif_i", ifi);
   uvm_config_db#(virtual cache_ctrl_interface_inner)::set(null, "uvm_test_top.env1.slv_agt.mon", "vif_i", ifi);
end
initial begin
   $fsdbDumpvars();
end





endmodule
