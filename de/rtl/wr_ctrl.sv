module wr_ctrl #(
                parameter addr_width = 32,
                parameter list_depth = 4,
                parameter data_width = 32,
                parameter list_width = 32
                )
                (
                    input    logic                               clk,
                    input    logic                               rst_n,

                    input    logic                               wr_valid,
                    output   logic                               wr_ready,
                    input    logic [addr_width - 1 : 0]          wr_addr,
                    input    logic [data_width - 1 : 0]          wr_data,

                    output   logic [index_lenth - 1 :0]          acc_index,
                    input    logic [2:0]                         acc_status,
                    output   logic [1:0]                         acc_cmd,
                    output   logic [$clog2(lists_depth) - 1 : 0] acc_tag,
                    input    logic [$clog2(lists_depth) - 1 : 0] return_tag,
                    output   logic                               acc_req,


                    output   logic [1:0]                         proc_status,
                    output   logic [addr_width - 1 : 0]          proc_addr,


                    output   logic [1:0]                         fetch_cmd,
                    output   logic                               fetch_req,
                    output   logic [$clog2(list_depth) - 1 : 0]  fetch_tag,
                    output   logic [addr_width - 1 : 0]          fetch_addr,
                    input    logic                               fetch_gnt,
                    input    logic                               fetch_done

                    output   logic  [$clog2(lists_depth) + $clog2(list_width) - 1 : 0] mem_waddr,
                    output   logic                                                     mem_wen,
                    input    logic                                                     mem_wready,
                    output   logic  [data_width - 1 : 0]                               mem_wdata
                );



endmodule
