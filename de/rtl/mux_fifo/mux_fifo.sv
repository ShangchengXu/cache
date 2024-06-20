module mux_fifo
    #(
        parameter DATA_WIDTH = 32,
        parameter DATA_UNIT = 8,
        parameter USER_INFO_WIDTH = 8,
        parameter IN_PIPE_MODE = 2'b00,
        parameter OUT_PIPE_MODE = 2'b00
    )
    (
        input logic clk,
        input logic rst_n,
        input logic flush,
        input logic [DATA_WIDTH - 1 : 0] src_data,
        input logic src_valid,
        output logic src_ready,
        input logic src_bgin,
        input logic [$clog2(DATA_WIDTH/DATA_UNIT) :0] src_unit_num,
        input logic src_done,
        input logic src_last,
        input logic  [$clog2(DATA_WIDTH/DATA_UNIT) - 1 : 0] src_offset,
        input logic [$clog2(DATA_WIDTH/DATA_UNIT) - 1: 0] src_initial_offset,
        output logic dst_valid,
        input logic [USER_INFO_WIDTH - 1 : 0] src_user_info,
        output logic [DATA_WIDTH - 1 : 0 ] dst_data,
        input logic dst_ready,
        output logic [$clog2(DATA_WIDTH/DATA_UNIT):0] dst_unit_num,
        output logic dst_done,
        output logic dst_last,
        output logic [USER_INFO_WIDTH - 1 : 0] dst_user_info,
        output logic [(DATA_WIDTH/DATA_UNIT) - 1 : 0] dst_strb
    );

//=======================================================================
// variables 
//=======================================================================
localparam IN_PIPE_DATA_WIDTH = DATA_WIDTH + 3 + (3 * $clog2(DATA_WIDTH/DATA_UNIT)) + 1 + USER_INFO_WIDTH;
localparam OUT_PIPE_DATA_WIDTH = DATA_WIDTH + 2 + ($clog2(DATA_WIDTH/DATA_UNIT)) + (DATA_WIDTH/DATA_UNIT) + 1 + USER_INFO_WIDTH;

logic [IN_PIPE_DATA_WIDTH - 1 : 0] src_data_in;
logic [IN_PIPE_DATA_WIDTH - 1 : 0] dst_data_in;
logic [OUT_PIPE_DATA_WIDTH - 1 : 0] src_data_out;
logic [OUT_PIPE_DATA_WIDTH - 1 : 0] dst_data_out;

logic [DATA_WIDTH - 1 : 0] src_data_inner;
logic src_valid_inner;
logic src_ready_inner;
logic src_bgin_inner;
logic [$clog2(DATA_WIDTH/DATA_UNIT) :0] src_unit_num_inner;
logic src_done_inner;
logic src_last_inner;
logic  [$clog2(DATA_WIDTH/DATA_UNIT) - 1 : 0] src_offset_inner;
logic [$clog2(DATA_WIDTH/DATA_UNIT) - 1: 0] src_initial_offset_inner;
logic dst_valid_inner;
logic [USER_INFO_WIDTH - 1 : 0] src_user_info_inner;
logic [DATA_WIDTH - 1 : 0 ] dst_data_inner;
logic dst_ready_inner;
logic [$clog2(DATA_WIDTH/DATA_UNIT):0] dst_unit_num_inner;
logic dst_done_inner;
logic dst_last_inner;
logic [USER_INFO_WIDTH - 1 : 0] dst_user_info_inner;
logic [(DATA_WIDTH/DATA_UNIT) - 1 : 0] dst_strb_inner;

//=======================================================================
// main logic 
//=======================================================================
assign src_data_in = {src_data, src_bgin, src_unit_num,
                        src_done, src_last, src_offset, src_initial_offset, src_user_info};

assign {src_data_inner, src_bgin_inner, src_unit_num_inner,
            src_done_inner, src_last_inner, src_offset_inner, src_initial_offset_inner, src_user_info_inner} = dst_data_in;


assign src_data_out = {dst_data_inner, dst_unit_num_inner,
                        dst_done_inner, dst_last_inner, dst_strb_inner, dst_user_info_inner};

assign {dst_data,  dst_unit_num,
            dst_done, dst_last, dst_strb, dst_user_info} = dst_data_out;

//=======================================================================
// inst
//=======================================================================
pipe # (
    .MODE        (IN_PIPE_MODE),
    .DATA_WIDTH  (IN_PIPE_DATA_WIDTH))
    pipe_in_inst (
        .clk      (clk                   ),
        .rst_n    (rst_n                 ),
        .soft_rst (flush                 ),
        .src_vld  (src_valid             ),
        .src_rdy  (src_ready             ),
        .src_data (src_data_in           ),
        .dst_vld  (src_valid_inner       ),
        .dst_rdy  (src_ready_inner       ),
        .dst_data (dst_data_in           ));
mux_fifo_core #(
        .DATA_WIDTH          (DATA_WIDTH          ),
        .DATA_UNIT           (DATA_UNIT           ),
        .USER_INFO_WIDTH     (USER_INFO_WIDTH     ))
              mux_fifo_core_inst (
        .clk                 (clk                       ) ,//input   
        .rst_n               (rst_n                     ) ,//input   
        .flush               (flush                     ) ,//input   
        .src_data            (src_data_inner            ) ,//input   [DATA_WIDTH - : 0]
        .src_valid           (src_valid_inner           ) ,//input   
        .src_ready           (src_ready_inner           ) ,//output  
        .src_bgin            (src_bgin_inner            ) ,//input   
        .src_unit_num        (src_unit_num_inner        ) ,//input   [$clog2(DATA_WIDTH/DATA_UNIT) :0]
        .src_done            (src_done_inner            ) ,//input   
        .src_last            (src_last_inner            ) ,//input   
        .src_offset          (src_offset_inner          ) ,//input   [$clog2(DATA_WIDTH/DATA_UNIT) 1 : 0]
        .src_initial_offset  (src_initial_offset_inner  ) ,//input   [$clog2(DATA_WIDTH/DATA_UNIT) - 1: 0]
        .dst_valid           (dst_valid_inner           ) ,//output  
        .src_user_info       (src_user_info_inner       ) ,//input   [USER_INFO_WIDTH - 1 : 0]
        .dst_data            (dst_data_inner            ) ,//output  [DATA_WIDTH - 1 : 0 ]
        .dst_ready           (dst_ready_inner           ) ,//input   
        .dst_unit_num        (dst_unit_num_inner        ) ,//output  [$clog2(DATA_WIDTH/DATA_UNIT):0]
        .dst_done            (dst_done_inner            ) ,//output  
        .dst_last            (dst_last_inner            ) ,//output  
        .dst_user_info       (dst_user_info_inner       ) ,//output  [USER_INFO_WIDTH 1 : 0]
        .dst_strb            (dst_strb_inner            ));//output  [(DATA_WIDTH/DATA_UNIT) - 1 : 0]

pipe # (
    .MODE        (OUT_PIPE_MODE),
    .DATA_WIDTH  (OUT_PIPE_DATA_WIDTH))
    pipe_out_inst (
        .clk      (clk             ),
        .rst_n    (rst_n           ),
        .soft_rst (flush           ),
        .src_vld  (dst_valid_inner ),
        .src_rdy  (dst_ready_inner ),
        .src_data (src_data_out    ),
        .dst_vld  (dst_valid   ),
        .dst_rdy  (dst_ready   ),
        .dst_data (dst_data_out    ));

endmodule