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

                    input    logic [1:0]                                        fetch_cmd_w,
                    input    logic                                              fetch_req_w,
                    input    logic [$clog2(list_depth) - 1 : 0]                 fetch_tag_w,
                    input    logic [addr_width - 1 : 0]                         fetch_addr_w,
                    input    logic [addr_width - 1 : 0]                         fetch_addr_pre_w,
                    output   logic                                              fetch_gnt_w,
                    output   logic                                              fetch_done_w,


                    input     logic [1:0]                                        fetch_cmd_r,
                    input     logic                                              fetch_req_r,
                    input     logic [$clog2(list_depth) - 1 : 0]                 fetch_tag_r,
                    input     logic [addr_width - 1 : 0]                         fetch_addr_r,
                    input     logic [addr_width - 1 : 0]                         fetch_addr_pre_r,
                    output    logic                                              fetch_gnt_r,
                    output    logic                                              fetch_done_r,

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
logic [$clog2(list_depth)  - 1 : 0] local_tag;
logic [1:0] local_owner;
logic [addr_width - 1 :0 ] local_addr;
logic [addr_width - 1 :0 ] local_addr_pre;
logic [1:0] local_cmd;
logic fetch_hsked_w, fetch_hsked_r;
logic local_done;
logic wr_state_done;
logic rd_state_done;
logic wr_hsked, rd_hsked;
logic wr_data_hsked;
logic rd_data_hsked;
logic mem_whsked;
logic mem_rhsked;

typedef enum logic [3:0] { 
        IDLE,
        REQ,
        WAIT_RD_DONE,
        WAIT_WR_RD_DONE,
        WAIT_WR_DONE,
        DONE
} main_state_t;
main_state_t main_cs,main_ns;

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

assign fetch_hsked_w = fetch_req_w && fetch_gnt_w;
assign fetch_hsked_r = fetch_req_r && fetch_gnt_r;
assign wr_hsked = wr_req && wr_gnt;
assign rd_hsked = rd_req && rd_gnt;
assign wr_data_hsked = wr_valid && wr_ready;
assign rd_data_hsked = rd_valid && rd_ready;
assign mem_rhsked = fetch_mem_ren && fetch_mem_rready;
assign mem_whsked = fetch_mem_wen && fetch_mem_wready;
assign local_done = main_cs == DONE;
assign rd_state_done = rd_cs == RD_DONE;
assign wr_state_done = wr_cs == WR_DONE;
logic [$clog2(list_width) - 1 : 0] wr_cnt;
logic [$clog2(list_width) - 1 : 0] rd_cnt;

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        local_addr <= 0;
        local_addr_pre <= 0;
        local_owner <= 0;
        local_cmd <= 0;
        local_tag <= 0;
    end else if(fetch_hsked_w)begin
        local_addr <= fetch_addr_w;
        local_addr_pre <= fetch_addr_pre_w;
        local_owner <= 2'b00;
        local_cmd <= fetch_cmd_w;
        local_tag <= fetch_tag_w;
    end else if(fetch_hsked_r)begin
        local_addr <= fetch_addr_r;
        local_addr_pre <= fetch_addr_pre_r;
        local_owner <= 2'b01;
        local_cmd <= fetch_cmd_r;
        local_tag <= fetch_tag_r;
    end
end


always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        main_cs <= IDLE;
    end else if(main_cs != main_ns) begin
        main_cs <= main_ns;
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

always_comb begin:MAIN_FSM
    main_ns = main_cs;
    case(main_cs) 

    IDLE: begin
        if(fetch_hsked_w || fetch_hsked_r) begin
            main_ns = REQ;
        end else begin
            main_ns = IDLE;
        end
    end

    REQ: begin
        if(local_cmd == 2'b01 || local_cmd == 2'b00) begin
            main_ns = WAIT_RD_DONE;
        end else if(local_cmd == 2'b10) begin
            main_ns = WAIT_WR_RD_DONE;
        end else begin
            main_ns = IDLE;
        end
    end

    WAIT_RD_DONE: begin
        if(rd_state_done) begin
            main_ns = DONE;
        end else begin
            main_ns = WAIT_RD_DONE;
        end
    end

    WAIT_WR_RD_DONE: begin
        if(wr_state_done && rd_state_done) begin
            main_ns = DONE;
        end else if(wr_state_done) begin
            main_ns = WAIT_RD_DONE;
        end else if(rd_state_done) begin
            main_ns = WAIT_WR_DONE;
        end
    end

    WAIT_WR_DONE: begin
        if(wr_state_done) begin
            main_ns = DONE;
        end else begin
            main_ns = WAIT_WR_DONE;
        end
    end

    DONE: begin
        main_ns = IDLE;
    end

    default: main_ns = IDLE;

    endcase
end

always_comb begin:RD_FSM

    rd_ns = rd_cs;

    case(rd_cs) 

    RD_IDLE:begin
        if(main_cs == REQ && main_ns == WAIT_RD_DONE) begin
            rd_ns = RD_REQ;
        end else if(main_cs == REQ && main_ns == WAIT_WR_RD_DONE) begin
            rd_ns = RD_WAIT_WR;
        end else begin
            rd_ns = RD_IDLE;
        end
    end

    RD_WAIT_WR: begin
        if(wr_last && wr_data_hsked) begin
            rd_ns = RD_REQ;
        end else begin
            rd_ns = RD_WAIT_WR;
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
            if(main_cs == REQ && main_ns == WAIT_WR_RD_DONE) begin
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
    end else if(main_cs == REQ) begin
        rd_cnt <= 0;
    end else if(rd_data_hsked) begin
        rd_cnt <= rd_cnt + 1;
    end
end

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_cnt <= 0;
    end else if(main_cs == REQ) begin
        wr_cnt <= 0;
    end else if(mem_rhsked) begin
        wr_cnt <= wr_cnt + 1;
    end
end

assign fetch_mem_waddr = {local_tag,rd_cnt};

assign fetch_mem_raddr = {local_tag,wr_cnt};

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

assign wr_addr = {local_addr_pre[addr_width - 1 : $clog2(list_width)],{$clog2(list_width){1'b0}}};

assign rd_req = rd_cs == RD_REQ;

assign rd_len = list_width * data_width / 8;

assign rd_addr = {local_addr[addr_width - 1 : $clog2(list_width)],{$clog2(list_width){1'b0}}};

always_comb  begin
    if(fetch_req_w) begin
        fetch_gnt_w = main_cs == IDLE;
        fetch_gnt_r = 1'b0;
    end else if(fetch_req_r) begin
        fetch_gnt_r = main_cs == IDLE;
        fetch_gnt_w = 1'b0;
    end else begin
        fetch_gnt_w = 1'b0;
        fetch_gnt_r = 1'b0;
    end
end

assign fetch_done_w = local_done && local_owner == 2'b00;
assign fetch_done_r = local_done && local_owner == 2'b01;


endmodule