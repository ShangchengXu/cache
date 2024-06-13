module fetch_ctrl 
                #(
                parameter addr_width = 32,
                parameter list_depth = 4,
                parameter data_width = 32,
                parameter list_width = 32
                )
                (
                    input    logic                                              clk,
                    input    logic                                              rst_n,

                    input    logic [1:0]                                        fetch_cmd_0,
                    input    logic                                              fetch_req_0,
                    input    logic [$clog2(list_depth) - 1 : 0]                 fetch_tag_0,
                    input    logic [addr_width - 1 : 0]                         fetch_addr_0,
                    output   logic                                              fetch_gnt_0,
                    output   logic                                              fetch_done_0,


                    input     logic [1:0]                                        fetch_cmd_1,
                    input     logic                                              fetch_req_1,
                    input     logic [$clog2(list_depth) - 1 : 0]                 fetch_tag_1,
                    input     logic [addr_width - 1 : 0]                         fetch_addr_1,
                    output    logic                                              fetch_gnt_1,
                    output    logic                                              fetch_done_1,



                    input     logic [1:0]                                        fetch_cmd_2,
                    input     logic                                              fetch_req_2,
                    input     logic [$clog2(list_depth) - 1 : 0]                 fetch_tag_2,
                    input     logic [addr_width - 1 : 0]                         fetch_addr_2,
                    output    logic                                              fetch_gnt_2,
                    output    logic                                              fetch_done_2,

                    output   logic  [$clog2(list_depth * list_width) - 1 : 0]   fetch_mem_raddr,
                    output   logic                                              fetch_mem_ren,
                    input    logic                                              fetch_mem_rready,
                    input    logic  [data_width - 1 : 0]                        fetch_mem_rdata,
                    input    logic                                              fetch_mem_rdata_valid,


                    output   logic  [$clog2(list_depth * list_width) - 1 : 0]   fetch_mem_waddr,
                    output   logic                                              fetch_mem_wen,
                    input    logic                                              fetch_mem_wready,
                    output   logic  [data_width - 1 : 0]                        fetch_mem_wdata,

                    output   logic                                              wr_req,
                    input    logic                                              wr_gnt,
                    output   logic  [15:0]                                      wr_len,
                    output   logic  [addr_width - 1 : 0]                        wr_addr,
                    output   logic  [data_width - 1 : 0]                        wr_data,
                    output   logic                                              wr_last,
                    output   logic                                              wr_valid,
                    input    logic                                              wr_ready,
                    input    logic                                              wr_done,

                    output   logic                                              rd_req,
                    input    logic                                              rd_gnt,
                    output   logic  [15:0]                                      rd_len,
                    output   logic  [addr_width - 1 : 0]                        rd_addr,

                    input    logic  [data_width - 1 : 0]                        rd_data,
                    input    logic                                              rd_done,
                    input    logic                                              rd_valid,
                    output   logic                                              rd_ready
                );
logic [$clog2(list_depth)  - 1 : 0] local_tag_w;
logic [1:0] local_owner_w;
logic [addr_width - 1 :0 ] local_addr_w;
logic [addr_width - 1 :0 ] local_addr_pre_w;
logic [1:0] local_cmd_w;

logic fetch_rd_req_0;
logic fetch_rd_req_1;
logic fetch_rd_req_2;
logic fetch_wr_req_0;
logic fetch_wr_req_1;
logic fetch_wr_req_2;
logic [2:0] fetch_rd_req;
logic [2:0] fetch_wr_req;
logic [2:0] fetch_rd_gnt;
logic [2:0] fetch_wr_gnt;

logic [$clog2(list_depth)  - 1 : 0] local_tag_r;
logic [1:0] local_owner_r;
logic [addr_width - 1 :0 ] local_addr_r;
logic [addr_width - 1 :0 ] local_addr_pre_r;
logic [1:0] local_cmd_r;

logic fetch_hsked_0, fetch_hsked_1, fetch_hsked_2;
logic local_done;
logic wr_state_done;
logic rd_state_done;
logic wr_hsked, rd_hsked;
logic wr_data_hsked;
logic rd_data_hsked;
logic mem_whsked;
logic mem_rhsked;

typedef enum logic [3:0] { 
        WR_IDLE,
        WR_REQ,
        WR_DATA,
        WR_WAIT_DONE,
        WR_DONE
} wr_state_t;
wr_state_t wr_cs,wr_ns;

typedef enum logic [3:0] { 
        RD_IDLE,
        RD_REQ,
        RD_WAIT_DONE,
        RD_WAIT_WR,
        RD_DONE
} rd_state_t;
rd_state_t rd_cs,rd_ns;

assign fetch_rd_req_0 = fetch_req_0 && fetch_cmd_0 == 2'b01;
assign fetch_rd_req_1 = fetch_req_1 && fetch_cmd_1 == 2'b01;
assign fetch_rd_req_2 = fetch_req_1 && fetch_cmd_1 == 2'b01;

assign fetch_wr_req_0 = fetch_req_0 && fetch_cmd_0 == 2'b00;
assign fetch_wr_req_1 = fetch_req_1 && fetch_cmd_1 == 2'b00;
assign fetch_wr_req_2 = fetch_req_2 && fetch_cmd_2 == 2'b00;

assign fetch_hsked_0 = fetch_req_0 && fetch_gnt_0;
assign fetch_hsked_1 = fetch_req_1 && fetch_gnt_1;
assign fetch_hsked_2 = fetch_req_2 && fetch_gnt_2;
assign wr_hsked = wr_req && wr_gnt;
assign rd_hsked = rd_req && rd_gnt;
assign wr_data_hsked = wr_valid && wr_ready;
assign rd_data_hsked = rd_valid && rd_ready;
assign mem_rhsked = fetch_mem_ren && fetch_mem_rready;
assign mem_whsked = fetch_mem_wen && fetch_mem_wready;

assign rd_state_done = rd_cs == RD_DONE;
assign wr_state_done = wr_cs == WR_DONE;
logic [$clog2(list_width) - 1 : 0] wr_cnt;
logic [$clog2(list_width) - 1 : 0] rd_cnt;

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        local_addr_w <= 0;
        local_owner_w <= 0;
        local_tag_w <= 0;
    end else if(fetch_hsked_0 && fetch_cmd_0 == 2'b00)begin
        local_addr_w <= fetch_addr_0;
        local_owner_w <= 2'b00;
        local_tag_w <= fetch_tag_0;
    end else if(fetch_hsked_1 && fetch_cmd_1 == 2'b00)begin
        local_addr_w <= fetch_addr_1;
        local_owner_w <= 2'b01;
        local_tag_w <= fetch_tag_1;
    end else if(fetch_hsked_2 && fetch_cmd_2 == 2'b00)begin
        local_addr_w <= fetch_addr_2;
        local_owner_w <= 2'b10;
        local_tag_w <= fetch_tag_2;
    end
end


always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        local_addr_r <= 0;
        local_owner_r <= 0;
        local_tag_r <= 0;
    end else if(fetch_hsked_0 && fetch_cmd_0 == 2'b01)begin
        local_addr_r <= fetch_addr_0;
        local_owner_r <= 2'b00;
        local_tag_r <= fetch_tag_0;
    end else if(fetch_hsked_1 && fetch_cmd_1 == 2'b01)begin
        local_addr_r <= fetch_addr_1;
        local_owner_r <= 2'b01;
        local_tag_r <= fetch_tag_1;
    end else if(fetch_hsked_2 && fetch_cmd_2 == 2'b01)begin
        local_addr_r <= fetch_addr_2;
        local_owner_r <= 2'b10;
        local_tag_r <= fetch_tag_2;
    end
end


always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_cs <= WR_IDLE;
    end else if(wr_cs != wr_ns) begin
        wr_cs <= wr_ns;
    end
end

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_cs <= RD_IDLE;
    end else if(rd_cs != rd_ns) begin
        rd_cs <= rd_ns;
    end
end

always_comb begin:RD_FSM

    rd_ns = rd_cs;

    case(rd_cs) 

    RD_IDLE:begin
        if(fetch_hsked_0 && fetch_cmd_0 == 2'b01 ||
           fetch_hsked_2 && fetch_cmd_2 == 2'b01 ||
            fetch_hsked_1 && fetch_cmd_1 == 2'b01) begin
            rd_ns = RD_REQ;
        end else begin
            rd_ns = RD_IDLE;
        end
    end

    RD_REQ: begin
        if(rd_hsked) begin
            rd_ns = RD_WAIT_DONE;
        end else begin
            rd_ns = RD_REQ;
        end
    end

    RD_WAIT_DONE: begin
        if(rd_done && rd_data_hsked) begin
            rd_ns = RD_DONE;
        end else begin
            rd_ns = RD_WAIT_DONE;
        end
    end

    RD_DONE: begin
        rd_ns = RD_IDLE;
    end

    default: rd_ns = RD_IDLE;

    endcase
end

always_comb begin:WR_FSM
    wr_ns = wr_cs;

    case(wr_cs)

        WR_IDLE: begin
            if(fetch_hsked_0 && fetch_cmd_0 == 2'b00 ||
                fetch_hsked_2 && fetch_cmd_2 == 2'b00 ||
                fetch_hsked_1 && fetch_cmd_1 == 2'b00) begin
                wr_ns = WR_REQ;
            end else begin
                wr_ns = WR_IDLE;
            end
        end

        WR_REQ: begin
            if(wr_hsked) begin
                wr_ns = WR_DATA;
            end else begin
                wr_ns = WR_REQ;
            end
        end

        WR_DATA: begin
            if(wr_last && wr_data_hsked) begin
                wr_ns = WR_WAIT_DONE;
            end else begin
                wr_ns = WR_DATA;
            end
        end

        WR_WAIT_DONE: begin
            if(wr_done) begin
                wr_ns = WR_DONE;
            end else begin
                wr_ns = WR_WAIT_DONE;
            end
        end

        WR_DONE: begin
            wr_ns = WR_IDLE;
        end

        default: wr_ns = WR_IDLE;

    endcase
end


always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_cnt <= 0;
    end else if(rd_cs == RD_REQ) begin
        rd_cnt <= 0;
    end else if(rd_data_hsked) begin
        rd_cnt <= rd_cnt + 1;
    end
end

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_cnt <= 0;
    end else if(wr_cs == WR_REQ) begin
        wr_cnt <= 0;
    end else if(mem_rhsked) begin
        wr_cnt <= wr_cnt + 1;
    end
end

assign fetch_mem_waddr = {local_tag_r,rd_cnt};

assign fetch_mem_raddr = {local_tag_w,wr_cnt};

assign fetch_mem_wen = rd_valid;

assign fetch_mem_wdata = rd_data;

assign rd_ready = fetch_mem_wready;

assign fetch_mem_ren = (wr_cs == WR_DATA && !wr_last) && (!wr_valid || wr_data_hsked);

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_last <= 1'b0;
    end else if((wr_cs == WR_DATA) && (wr_cnt == list_width - 1)) begin
        wr_last <= 1'b1;
    end else if(wr_data_hsked) begin
        wr_last <= 1'b0;
    end
end

assign wr_valid = fetch_mem_rdata_valid;

assign wr_data = fetch_mem_rdata;

assign wr_req = wr_cs == WR_REQ;

assign wr_len = list_width * data_width / 8;

assign wr_addr = {local_addr_w[addr_width - 1 : $clog2(list_width)],{$clog2(list_width){1'b0}}};

assign rd_req = rd_cs == RD_REQ;

assign rd_len = list_width * data_width / 8;

assign rd_addr = {local_addr_r[addr_width - 1 : $clog2(list_width)],{$clog2(list_width){1'b0}}};

// always_comb  begin
//     if(fetch_req_0 && fetch_cmd_0 == 2'b00) begin
//         fetch_gnt_0 = wr_cs == WR_IDLE;
//     end else if(fetch_req_0 && fetch_cmd_1 == 2'b01) begin
//         fetch_gnt_0 = rd_cs == RD_IDLE;
//     end else begin
//         fetch_gnt_0 = 1'b0;
//     end
// end


// always_comb  begin
//     if(fetch_req_1 && fetch_cmd_1 == 2'b00) begin
//         fetch_gnt_1 = wr_cs == WR_IDLE && !(fetch_req_0 && fetch_cmd_0 == 2'b00);
//     end else if(fetch_req_1 && fetch_cmd_1 == 2'b01) begin
//         fetch_gnt_1 = rd_cs == RD_IDLE && !(fetch_req_0 && fetch_cmd_0 == 2'b01);
//     end else begin
//         fetch_gnt_1 = 1'b0;
//     end
// end

assign fetch_done_0 = rd_state_done && local_owner_r == 2'b00 || wr_state_done && local_owner_w == 2'b00;
assign fetch_done_1 = rd_state_done && local_owner_r == 2'b01 || wr_state_done && local_owner_w == 2'b01;
assign fetch_done_2 = rd_state_done && local_owner_r == 2'b10 || wr_state_done && local_owner_w == 2'b10;

assign fetch_rd_req = rd_cs == RD_IDLE ? {fetch_rd_req_2, fetch_rd_req_1, fetch_rd_req_0} : 2'b0;
assign fetch_wr_req = wr_cs == WR_IDLE ? {fetch_wr_req_2, fetch_wr_req_1, fetch_wr_req_0} : 2'b0;

assign fetch_gnt_0 = fetch_rd_gnt[0] || fetch_wr_gnt[0];
assign fetch_gnt_1 = fetch_rd_gnt[1] || fetch_wr_gnt[1];
assign fetch_gnt_2 = fetch_rd_gnt[2] || fetch_wr_gnt[2];

cache_rr_arb #(
        .WIDTH       (3       ),
        .REFLECTION  (0       ))
             cache_rr_arb_wr_inst (
        .clk         (clk                ) ,//input   
        .rst_n       (rst_n              ) ,//input   
        .req         (fetch_wr_req       ) ,//input   [WIDTH - 1 : 0]
        .req_end     (fetch_wr_gnt       ) ,//input   [WIDTH - 1 : 0]
        .gnt         (fetch_wr_gnt       ));//output  [WIDTH - 1 : 0]


cache_rr_arb #(
        .WIDTH       (3       ),
        .REFLECTION  (0       ))
             cache_rr_arb_rd_inst (
        .clk         (clk               ) ,//input   
        .rst_n       (rst_n             ) ,//input   
        .req         (fetch_rd_req      ) ,//input   [WIDTH - 1 : 0]
        .req_end     (fetch_rd_gnt      ) ,//input   [WIDTH - 1 : 0]
        .gnt         (fetch_rd_gnt      ));//output  [WIDTH - 1 : 0]


endmodule