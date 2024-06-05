`include "uvm_macros.svh"
module mem_ctrl_tb;
parameter mem_depth = 32;
parameter data_width = 32;
mem_ctrl_interface_port #(
        .mem_depth   (mem_depth   ),
        .data_width  (data_width  ))
                        ifo ();
mem_ctrl_interface_inner ifi ();
logic clk;
logic rst_n;
logic rst_p;
mem_ctrl #(
        .mem_depth   (mem_depth   ),
        .data_width  (data_width  ))
         mem_ctrl_inst (
        .clk                    (ifo.clk                  ) ,//input   
        .rst_n                  (ifo.rst_n                ) ,//input   
        .mem_raddr              (ifo.mem_raddr            ) ,//input   [$clog2(mem_depth) - 1 : 0]
        .mem_ren                (ifo.mem_ren              ) ,//input   
        .mem_rready             (ifo.mem_rready           ) ,//output  
        .mem_rdata              (ifo.mem_rdata            ) ,//output  [data_width - 1 : 0]
        .mem_rdata_valid        (ifo.mem_rdata_valid      ) ,//output  
        .mem_waddr              (ifo.mem_waddr            ) ,//input   [$clog2(mem_depth) - 1 : 0]
        .mem_wen                (ifo.mem_wen              ) ,//input   
        .mem_wready             (ifo.mem_wready           ) ,//output  
        .mem_wdata              (ifo.mem_wdata            ) ,//input   [data_width - 1 : 0]
        .fetch_mem_raddr        (ifo.fetch_mem_raddr      ) ,//input   [$clog2(mem_depth) - 1 : 0]
        .fetch_mem_ren          (ifo.fetch_mem_ren        ) ,//input   
        .fetch_mem_rready       (ifo.fetch_mem_rready     ) ,//output  
        .fetch_mem_rdata        (ifo.fetch_mem_rdata      ) ,//output  [data_width - 1 : 0]
        .fetch_mem_rdata_valid  (ifo.fetch_mem_rdata_valid) ,//output  
        .fetch_mem_waddr        (ifo.fetch_mem_waddr      ) ,//input   [$clog2(mem_depth) - 1 : 0]
        .fetch_mem_wen          (ifo.fetch_mem_wen        ) ,//input   
        .fetch_mem_wready       (ifo.fetch_mem_wready     ) ,//output  
        .fetch_mem_wdata        (ifo.fetch_mem_wdata      ));//input   [data_width - 1 : 0]
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
   uvm_config_db#(virtual mem_ctrl_interface_port)::set(null, "uvm_test_top.env.mst_agt.drv", "vif", ifo);
   uvm_config_db#(virtual mem_ctrl_interface_port)::set(null, "uvm_test_top.env.mst_agt.mon", "vif", ifo);
   uvm_config_db#(virtual mem_ctrl_interface_port)::set(null, "uvm_test_top.env.slv_agt.mon", "vif", ifo);
   uvm_config_db#(virtual mem_ctrl_interface_inner)::set(null, "uvm_test_top.env.mst_agt.drv", "vif_i", ifi);
   uvm_config_db#(virtual mem_ctrl_interface_inner)::set(null, "uvm_test_top.env.mst_agt.mon", "vif_i", ifi);
   uvm_config_db#(virtual mem_ctrl_interface_inner)::set(null, "uvm_test_top.env.slv_agt.mon", "vif_i", ifi);
end
initial begin
   $fsdbDumpvars();
end





endmodule
