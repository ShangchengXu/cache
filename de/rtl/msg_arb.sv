module msg_arb #(
                parameter cache_num = 1,
                parameter addr_width = 32
                ) 
                (
                    input logic            clk,
                    input logic            rst_n,

                    input    logic [cache_num - 1 : 0]                                            msg_req,
                    output   logic [cache_num - 1 : 0]                                            msg_gnt,
                    input    logic [cache_num * (4 + 2 * $clog2(cache_num) + addr_width) - 1 : 0] msg,

                    output   logic                                                                msg_out_valid,
                    output   logic [4 + 2 * $clog2(cache_num) - 1 + addr_width : 0]               msg_out
                );



cache_rr_arb #(
        .WIDTH       (2       ),
        .REFLECTION  (0       ))
             cache_rr_arb_msg_inst (
        .clk         (clk                ) ,//input   
        .rst_n       (rst_n              ) ,//input   
        .req         (msg_req         ) ,//input   [WIDTH - 1 : 0]
        .req_end     (msg_gnt         ) ,//input   [WIDTH - 1 : 0]
        .gnt         (msg_gnt         ));//output  [WIDTH - 1 : 0]

mux           #(.IN_WIDTH(cache_num * (4 + 2 * $clog2(cache_num) + addr_width)),
                .UNIT_WIDTH((4 + 2 * $clog2(cache_num) + addr_width))
            )mux_inst
            (
                .src_data(msg),
                .src_sel(msg_gnt),
                .dst_data(msg_out)
            );

assign msg_out_valid = |msg_gnt;
endmodule