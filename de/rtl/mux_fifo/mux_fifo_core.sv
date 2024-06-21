module mux_fifo_core
    #(
    parameter DATA_WIDTH = 32,
    parameter DATA_UNIT = 8,
    parameter USER_INFO_WIDTH = 8
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
input logic  [$clog2(DATA_WIDTH/DATA_UNIT) -  1 : 0] src_offset,
input logic [$clog2(DATA_WIDTH/DATA_UNIT) - 1: 0] src_initial_offset,
output logic dst_valid,
input logic [USER_INFO_WIDTH - 1 : 0] src_user_info,
output logic [DATA_WIDTH - 1 : 0 ] dst_data,
input logic dst_ready,
output logic [$clog2(DATA_WIDTH/DATA_UNIT):0] dst_unit_num,
output logic dst_done,
output logic dst_last,
output logic [USER_INFO_WIDTH - 1 : 0] dst_user_info,
output logic [(DATA_WIDTH/DATA_UNIT) - 1 : 0] dst_strb);
// variables declaration
localparam PTR_WIDTH = $clog2(DATA_WIDTH/DATA_UNIT) + 1;
localparam OFST_WIDTH = $clog2(DATA_WIDTH/DATA_UNIT);
localparam STRB_WIDTH = (DATA_WIDTH/DATA_UNIT);

typedef struct {
logic  [PTR_WIDTH - 1 : 0] unit_num;
logic done;
logic  [DATA_WIDTH - 1 : 0 ]  data;
logic bgin; 
logic valid;
logic last;
logic [OFST_WIDTH - 1:0] ofst;
logic [USER_INFO_WIDTH - 1: 0] user_info;
} mux_ff_t;
mux_ff_t ff0;
logic [PTR_WIDTH - 1 :0] ptr,nxt_ptr;
logic src_hsked,dst_hsked;
logic [DATA_WIDTH - 1 : 0] src_data_shift;
logic [STRB_WIDTH - 1:0] strb_inner;
logic [OFST_WIDTH - 1 : 0] dst_ofst;
logic dst_bgin;
function logic [DATA_WIDTH - 1:0] shift_left(input logic [DATA_WIDTH - 1:0] data_in, input logic [OFST_WIDTH - 1 : 0] ofst);
    shift_left = data_in << DATA_UNIT * ofst;
endfunction
function logic [DATA_WIDTH - 1:0] shift_right(input logic [DATA_WIDTH - 1:0] data_in, input logic [OFST_WIDTH - 1 : 0] ofst);
    shift_right = data_in >> DATA_UNIT * ofst;
endfunction
function logic [STRB_WIDTH - 1:0] shift_left_unit(input logic [STRB_WIDTH - 1:0] data_in, input logic [OFST_WIDTH - 1 : 0] ofst);
    shift_left_unit = data_in << ofst;
endfunction
function logic [STRB_WIDTH - 1:0] shift_right_unit(input logic [STRB_WIDTH - 1:0] data_in, input logic [OFST_WIDTH - 1 : 0] ofst);
    shift_right_unit = data_in >> ofst;
endfunction
function logic [DATA_WIDTH -  1:0] connect_proc(input logic [DATA_WIDTH - 1:0] data_ori, input logic [DATA_WIDTH - 1:0] data_in, input logic [OFST_WIDTH - 1 : 0] ori_offset);
    logic [DATA_WIDTH - 1 : 0] data_temp0, data_temp1;
    data_temp0 = data_in << (DATA_UNIT * ori_offset);
    data_temp1 = data_ori & (~({DATA_WIDTH{1'b1}} << (DATA_UNIT * ori_offset)));
    connect_proc =  data_temp0  | data_temp1;
endfunction


// main logic
assign src_hsked = src_valid && src_ready;
assign dst_hsked = dst_valid && dst_ready;
always_comb begin
    src_ready =  1'b1;
    if(ff0.done && ff0.valid && dst_ready && ((src_initial_offset  +  src_unit_num > DATA_WIDTH/DATA_UNIT - 1))) begin
        src_ready =  1'b0;
    end else if(ff0.done && ff0.valid && !dst_ready) begin
        src_ready = 1'b0;
    end else if(!dst_ready && src_done) begin
        src_ready = 1'b0;
    end else if(!dst_ready && src_bgin && (nxt_ptr[PTR_WIDTH - 1] != 1'b0)) begin
        src_ready = 1'b0;
    end else if(!dst_ready && ~src_bgin && (nxt_ptr[PTR_WIDTH - 1] != ptr[PTR_WIDTH - 1])) begin
        src_ready = 1'b0;
    end
end
assign src_data_shift = shift_right(src_data, src_offset);
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        ptr <= {PTR_WIDTH{1'b0}};
    end else if(flush) begin
        ptr <= {PTR_WIDTH{1'b0}};
    end else if(src_hsked) begin
        ptr <=  nxt_ptr;
    end
end
always@* begin
    nxt_ptr= ptr;
    if (src_bgin) begin
        nxt_ptr = src_unit_num + src_initial_offset;
    end else begin
        nxt_ptr = ptr + src_unit_num;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(~rst_n) begin
        ff0.data <= {DATA_WIDTH{1'b0}};
        ff0.done <=  1'b0;
        ff0.last <=  1'b0;
        ff0.unit_num <=  {PTR_WIDTH{1'b0}};
        ff0.bgin <= 1'b0;
        ff0.ofst <=  {OFST_WIDTH{1'b0}};
        ff0.valid <=  1'b0;
        ff0.user_info <=  {USER_INFO_WIDTH{1'b0}};
    end else if(flush) begin
        ff0.data <= {DATA_WIDTH{1'b0}};
        ff0.done <=  1'b0;
        ff0.last <= 1'b0;
        ff0.unit_num <= {PTR_WIDTH{1'b0}};
        ff0.bgin <=  1'b0;
        ff0.ofst <= {OFST_WIDTH{1'b0}};
        ff0.valid <=  1'b0;
        ff0.user_info <=  {USER_INFO_WIDTH{1'b0}};
    end else if(src_hsked && src_bgin &&(nxt_ptr[(PTR_WIDTH - 2):0] != {(PTR_WIDTH - 1){1'b0}}) &&
        (nxt_ptr[PTR_WIDTH - 1] == 1'b0) && src_done && ~(ff0.valid && ff0.done) ) begin
        ff0.done <=  1'b0;
        ff0.last <= 1'b0;
        ff0.unit_num <=  {PTR_WIDTH{1'b0}};
        ff0.bgin <=  1'b0;
        ff0.ofst <= {OFST_WIDTH{1'b0}};
        ff0.valid <=  1'b0;
        ff0.user_info <=  {USER_INFO_WIDTH{1'b0}};
    end else if(src_hsked && ~src_bgin&& (nxt_ptr[(PTR_WIDTH - 2):0] != {(PTR_WIDTH - 1){1'b0}}) &&
        (ptr[PTR_WIDTH - 1] == nxt_ptr[PTR_WIDTH - 1]) && src_done && ~(ff0.valid && ff0.done) ) begin
        ff0.user_info <= {USER_INFO_WIDTH{1'b0}};
        ff0.done <=  1'b0;
        ff0.last <=  1'b0;
        ff0.unit_num <= {PTR_WIDTH{1'b0}};
        ff0.bgin <=  1'b0;
        ff0.ofst <=  {OFST_WIDTH{1'b0}};
        ff0.valid <=  1'b0;
        ff0.user_info <=  {USER_INFO_WIDTH{1'b0}};
    end else if(src_hsked && src_bgin && nxt_ptr[(PTR_WIDTH - 2):0] != {(PTR_WIDTH - 1){1'b0}}) begin
        ff0.valid <=  1'b1;
        ff0.done <=  src_done;
        ff0.user_info <=  src_user_info;
        ff0.unit_num <=  {1'b0,nxt_ptr[(PTR_WIDTH - 2):0]};
        if((src_done &&(nxt_ptr[PTR_WIDTH - 1]== 1'b1)) || nxt_ptr[PTR_WIDTH - 1] == 1'b0) begin
            ff0.last <=  src_last;
        end
        if(nxt_ptr[PTR_WIDTH - 1] != 1'b0) begin
            ff0.data <=  src_data_shift >> (DATA_WIDTH - DATA_UNIT * src_initial_offset);
        end else begin
            ff0.data <=  src_data_shift << DATA_UNIT * src_initial_offset;
            ff0.ofst <=  src_initial_offset;
            ff0.bgin <=  1'b1;
        end
    end else if(src_hsked && nxt_ptr[(PTR_WIDTH - 2) : 0] != {(PTR_WIDTH -1){1'b0}}) begin
        ff0.valid <=  1'b1;
        ff0.user_info <=  src_user_info;
        ff0.done <=  src_done;
        ff0.unit_num <=  {1'b0,nxt_ptr[(PTR_WIDTH - 2):0]};
        if((src_done && (nxt_ptr[PTR_WIDTH - 1] != ptr[PTR_WIDTH - 1])) || nxt_ptr[PTR_WIDTH - 1] == ptr[PTR_WIDTH - 1]) begin
            ff0.last <=  src_last;
        end
        if(ptr[PTR_WIDTH - 1] != nxt_ptr[PTR_WIDTH - 1]) begin
            ff0.data <=  src_data_shift >> (DATA_WIDTH - DATA_UNIT * ptr[PTR_WIDTH - 2 : 0 ]);
            ff0.ofst <= {OFST_WIDTH{1'b0}};
            ff0.bgin <=  1'b0;
        end else begin
            ff0.data <=  connect_proc(ff0.data,src_data_shift,ptr[PTR_WIDTH - 2:0]);
        end
    end else if(src_hsked && nxt_ptr[PTR_WIDTH - 2 : 0] == {(PTR_WIDTH -1){1'b0}}) begin
        ff0.valid <=  1'b0;
        ff0.last <=  1'b0;
        ff0.done <=  1'b0;
        ff0.bgin <=  1'b0;
        ff0.user_info <= {USER_INFO_WIDTH{1'b0}};
        ff0.ofst <=  {OFST_WIDTH{1'b0}};
    end else if(dst_hsked) begin
        ff0.valid <=  1'b0;
        ff0.last <=  1'b0;
        ff0.done <=  1'b0;
        ff0.bgin <=  1'b0;
        ff0.unit_num <=  {PTR_WIDTH{1'b0}};
        ff0.ofst <=  {OFST_WIDTH{1'b0}};
        ff0.user_info <=  {USER_INFO_WIDTH{1'b0}};
        end
end
always_comb  begin
    dst_data = {DATA_WIDTH{1'b0}};
    dst_last = 1'b0;
    dst_done = 1'b0;
    dst_strb = {STRB_WIDTH{1'b0}};
    dst_unit_num = {PTR_WIDTH{1'b0}};
    dst_bgin = 1'b0;
    dst_ofst = {OFST_WIDTH{1'b0}};
    dst_user_info = src_user_info;
    if(flush) begin
        dst_data = {DATA_WIDTH{1'b0}};
        dst_last = 1'b0;
        dst_done = 1'b0;
        dst_strb = {STRB_WIDTH{1'b0}};
        dst_unit_num = {PTR_WIDTH{1'b0}};
        dst_bgin = 1'b0;
        dst_ofst = {OFST_WIDTH{1'b0}};
        dst_user_info = {USER_INFO_WIDTH{1'b0}};
    end else if(ff0.done && ff0.valid) begin
        dst_data = ff0.data;
        dst_unit_num = ff0.unit_num;
        dst_last = ff0.last;
        dst_done = ff0.done;
        dst_strb = strb_inner;
        dst_bgin = ff0.bgin;
        dst_ofst = ff0.ofst;
        dst_user_info = ff0.user_info;
    end else if(src_bgin && (nxt_ptr[PTR_WIDTH - 1] == 1'b0) && src_done) begin
        dst_data = shift_left(src_data_shift,src_initial_offset);
        dst_unit_num = src_unit_num + src_initial_offset;
        dst_last = src_last;
        dst_done = src_done;
        dst_strb = strb_inner;
        dst_bgin = 1'b1;
        dst_ofst = src_initial_offset;
    end else if(src_bgin && (nxt_ptr[PTR_WIDTH - 1] != 1'b0)) begin
        dst_unit_num = PTR_WIDTH'(1'b1) << OFST_WIDTH;
        if(nxt_ptr[PTR_WIDTH - 2 : 0] == {(PTR_WIDTH - 1){1'b0}}) begin
            dst_last = src_last;
            dst_done = src_done;
        end else begin
            dst_done = 1'b0;
            dst_last = src_done ? 1'b0 : src_last;
        end
        dst_strb = strb_inner;
        dst_data = shift_left(src_data_shift,src_initial_offset);
        dst_bgin = 1'b1;
        dst_ofst = src_initial_offset;
    end else if ((nxt_ptr[PTR_WIDTH  - 1] == ptr[PTR_WIDTH - 1]) && src_done) begin
        dst_unit_num = {1'b0,nxt_ptr[PTR_WIDTH - 2 :0]};
        dst_last = src_last;
        dst_done = src_done;
        dst_strb = strb_inner;
        dst_data = connect_proc(ff0.data,src_data_shift,ptr[PTR_WIDTH - 2:0]);
        dst_bgin = 1'b0;
        dst_ofst = ff0.ofst;
    end else if((nxt_ptr[PTR_WIDTH - 1] != ptr[PTR_WIDTH - 1])) begin
        dst_ofst = ff0.ofst;
        dst_bgin = ff0.bgin;
        dst_unit_num =  PTR_WIDTH'(1'b1) << OFST_WIDTH;
        dst_strb  = strb_inner;
        if(nxt_ptr[PTR_WIDTH -2 : 0] == {(PTR_WIDTH- 1){1'b0}}) begin
            dst_done = src_done;
        end
        if((nxt_ptr[PTR_WIDTH - 2 : 0] != {(PTR_WIDTH - 1){1'b0}}) && src_done) begin
            dst_last = 1'b0;
        end else begin
            dst_last = src_last;
        end
        dst_data = connect_proc(ff0.data,src_data_shift,ptr[PTR_WIDTH - 2 : 0]);
    end
end
always_comb begin
    dst_valid = 1'b0;
    if(flush) begin 
        dst_valid = 1'b0;
    end else if(ff0.done && ff0.valid)  begin
        dst_valid = 1'b1;
    end else if(src_valid && src_done) begin
        dst_valid = 1'b1;
    end else if(src_valid && src_bgin && (nxt_ptr[PTR_WIDTH - 1] != 1'b0)) begin
        dst_valid = 1'b1;
    end else if(src_valid && ~src_bgin && (nxt_ptr[PTR_WIDTH - 1] != ptr[PTR_WIDTH - 1])) begin
        dst_valid = 1'b1;
    end
end
assign strb_inner = shift_right_unit({STRB_WIDTH{1'b1}} ,OFST_WIDTH'(STRB_WIDTH - dst_unit_num)) & shift_left_unit({STRB_WIDTH{1'b1}},dst_ofst);

endmodule