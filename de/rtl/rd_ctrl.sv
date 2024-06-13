module rd_ctrl #(
                parameter addr_width = 32,
                parameter list_depth = 4,
                parameter data_width = 32,
                parameter list_width = 32
                )
                (
                    input    logic                               clk,
                    input    logic                               rst_n,

                    input    logic                               acc_rd_valid,
                    output   logic                               acc_rd_ready,
                    input    logic [addr_width - 1 : 0]          acc_rd_addr,
                    output   logic [data_width - 1 : 0]          acc_rd_data,
                    output   logic                               acc_rd_data_valid,

                    output   logic [addr_width - 1 :0]           acc_index,
                    input    logic [2:0]                         acc_status,
                    output   logic [2:0]                         acc_cmd,
                    output   logic [$clog2(list_depth) - 1 : 0]  acc_tag,
                    input    logic [$clog2(list_depth) - 1 : 0]  return_tag,
                    input    logic [addr_width - 1 :0]           return_index,
                    output   logic                               acc_req,
                    input    logic                               acc_gnt,



                    output   logic [2:0]                         proc_status_r,
                    output   logic [addr_width - 1 : 0]          proc_addr_r,
                    output   logic [$clog2(list_depth) - 1 : 0]  proc_tag_r,

                    input    logic [2:0]                         proc_status_w,
                    input    logic [addr_width - 1 : 0]          proc_addr_w,
                    input    logic [$clog2(list_depth) - 1 : 0]  proc_tag_w,


                    output   logic [1:0]                         fetch_cmd,
                    output   logic                               fetch_req,
                    output   logic [$clog2(list_depth) - 1 : 0]  fetch_tag,
                    output   logic [addr_width - 1 : 0]          fetch_addr,
                    input    logic                               fetch_gnt,
                    input    logic                               fetch_done,


                    output   logic                               msg_req,
                    output   logic [3:0]                         msg,
                    input    logic [3:0]                         msg_rsp,
                    input    logic                               msg_valid,
                    input    logic                               msg_gnt,

                    output   logic  [$clog2(list_depth) + $clog2(list_width) - 1 : 0] mem_raddr,
                    output   logic                                                     mem_ren,
                    output   logic  [1:0]                                              mem_rpri,
                    input    logic                                                     mem_rready,
                    input    logic  [data_width - 1 : 0]                               mem_rdata,
                    input    logic                                                     mem_rdata_valid
                );


localparam addr_offset_width = $clog2(list_width * data_width / 8);

typedef enum logic [5:0] { 
        IDLE,
        NORM,
        WAIT_LOOKUP,
        WAIT_MEM,
        CHECK_COMFLICT,
        ALLOCATE_LINE,
        MSG_REQ,
        WAIT_MSG_RSP,
        WR_REQ,
        WAIT_WR_DONE,
        RD_REQ,
        WAIT_RD_DONE,
        ACC_MEM,
        UPDATE_LIST,
        UPDATE_LIST_DONE,
        WAIT_COMFLICT
} rd_state_t;

rd_state_t rd_cs,rd_ns;

logic req_hsked;

logic [addr_width - 1 : 0] acc_rd_addr_ff;

logic [addr_width - 1 : 0] local_addr;

logic [$clog2(list_depth) - 1 : 0] return_tag_ff;

logic [addr_width - 1 :0]           return_index_ff;

logic rd_hsked;

logic rd_req_pending;

logic wr_req_pending;

logic fetch_hsked;

logic exclusive_rd;

logic mem_rhsked;

logic msg_hsked;

logic has_comflict;

logic comflict_clear;

logic cs_is_check_comflict;

logic cs_is_allocate_line;

logic cs_is_fetch_req;

logic cs_is_wait_fetch_comp;

logic cs_is_update_list;

logic cs_is_acc_mem;

logic fetch_proc;

assign cs_is_acc_mem = rd_cs == ACC_MEM;

assign cs_is_allocate_line = rd_cs == ALLOCATE_LINE;

assign cs_is_check_comflict = rd_cs == CHECK_COMFLICT;

assign cs_is_fetch_req = rd_cs == RD_REQ || rd_cs == WR_REQ;

assign cs_is_wait_fetch_comp = rd_cs == WAIT_WR_DONE || rd_cs == WAIT_RD_DONE;

assign cs_is_update_list = rd_cs == UPDATE_LIST;

assign req_hsked = acc_req && acc_gnt;

assign msg_hsked = msg_req && msg_gnt;
//proc status
//3'b000 no need
//3'b001 check_conflict
//3'b010 busy
//3'b011 done

assign rd_hsked = acc_rd_valid && acc_rd_ready;

assign fetch_hsked = fetch_req && fetch_gnt;


assign mem_rhsked = mem_ren && mem_rready;

assign acc_rd_ready = (rd_cs == IDLE) || (rd_cs == NORM);

assign has_comflict = (proc_status_w == 3'b010 || proc_status_w == 3'b001) && (proc_addr_r == proc_addr_w);

assign comflict_clear = (proc_status_w != 3'b010);

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fetch_proc <= 1'b0;
    end else if(cs_is_fetch_req) begin
        fetch_proc <= 1'b1;
    end else if(cs_is_acc_mem && mem_rready && fetch_proc) begin
        fetch_proc <= 1'b0;
    end
end


always_comb begin
    if(cs_is_check_comflict) begin
        proc_status_r = 3'b001;
    end else if(rd_cs == WAIT_COMFLICT) begin
        proc_status_r = 3'b100;
    end else if(cs_is_allocate_line || cs_is_fetch_req || 
                cs_is_wait_fetch_comp || cs_is_acc_mem || (cs_is_update_list && rd_req_pending) ||
                (cs_is_update_list && !rd_req_pending && !req_hsked)) begin
        proc_status_r = 3'b010;
    end else begin
        proc_status_r = 3'b000;
    end
end

assign proc_tag_r = cs_is_allocate_line && req_hsked ? return_tag : return_tag_ff;

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        acc_rd_addr_ff <= 0;
    end else if(rd_hsked) begin
        acc_rd_addr_ff <= acc_rd_addr;
    end
end


always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        return_tag_ff <= 0;
    end else if(rd_cs == WAIT_COMFLICT && rd_ns != WAIT_COMFLICT) begin
        return_tag_ff <= proc_tag_w;
    end else if(cs_is_allocate_line && req_hsked || rd_hsked && req_hsked) begin
        return_tag_ff <= return_tag;
    end
end


always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_req_pending <= 1'b0;
    end else if(cs_is_allocate_line && req_hsked && acc_status == 3'b010) begin
        wr_req_pending <= 1'b1;
    end else if(rd_cs == WAIT_WR_DONE) begin
        wr_req_pending <= 1'b0;
    end
end


always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_req_pending <= 1'b0;
    end else if(cs_is_allocate_line && req_hsked) begin
        rd_req_pending <= 1'b1;
    end else if(rd_cs == WAIT_RD_DONE) begin
        rd_req_pending <= 1'b0;
    end
end

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        return_index_ff <= 0;
    end else if(cs_is_allocate_line && req_hsked) begin
        return_index_ff <= return_index;
    end
end

assign local_addr = rd_hsked ? acc_rd_addr : acc_rd_addr_ff;

assign proc_addr_r = {local_addr[addr_width - 1 : addr_offset_width],{addr_offset_width{1'b0}}};

assign acc_index = proc_addr_r;

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_cs <= IDLE;
    end else if(rd_cs != rd_ns) begin
        rd_cs <= rd_ns;
    end
end

always_comb begin:RD_FSM
    rd_ns = rd_cs;
    case(rd_cs)

        IDLE : begin
            if(rd_hsked) begin
                if(!req_hsked) begin
                    rd_ns = WAIT_LOOKUP;
                end else if(acc_status == 3'b000) begin
                    rd_ns = CHECK_COMFLICT;
                end else if(acc_status == 3'b100) begin
                    rd_ns = WAIT_COMFLICT;
                end else if(!mem_rhsked) begin
                    rd_ns = WAIT_MEM;
                end else begin
                    rd_ns = NORM;
                end
            end else begin
                    rd_ns = IDLE;
            end
        end

        WAIT_LOOKUP: begin
                if(!req_hsked) begin
                    rd_ns = WAIT_LOOKUP;
                end else if(acc_status == 3'b000) begin
                    rd_ns = CHECK_COMFLICT;
                end else if(acc_status == 3'b100) begin
                    rd_ns = WAIT_COMFLICT;
                end else if(!mem_rhsked) begin
                    rd_ns = WAIT_MEM;
                end else begin
                    rd_ns = NORM;
                end
        end

        NORM: begin
            if(rd_hsked) begin
                if(acc_status == 3'b000) begin
                    rd_ns = CHECK_COMFLICT;
                end else if(acc_status == 3'b100) begin
                    rd_ns = WAIT_COMFLICT;
                end else if(!mem_rhsked) begin
                    rd_ns = WAIT_MEM;
                end else begin
                    rd_ns = NORM;
                end
            end else begin
                    rd_ns = IDLE;
            end
        end

        WAIT_MEM: begin
            if(mem_rhsked) begin
                rd_ns = NORM;
            end else begin
                rd_ns = WAIT_MEM;
            end
        end

        CHECK_COMFLICT: begin
            if(has_comflict) begin
                rd_ns = WAIT_COMFLICT;
            end else begin
                rd_ns = ALLOCATE_LINE;
            end
        end

        ALLOCATE_LINE: begin
            if(req_hsked) begin
                rd_ns = MSG_REQ;
            end else begin
                rd_ns = ALLOCATE_LINE;
            end
        end


        MSG_REQ: begin
            if(msg_hsked) begin
                rd_ns = WAIT_MSG_RSP;
            end else begin
                rd_ns = MSG_REQ;
            end
        end

        WAIT_MSG_RSP: begin
            if(msg_valid) begin
                if(wr_req_pending) begin
                    rd_ns = WR_REQ;
                end else if(rd_req_pending) begin
                    rd_ns = RD_REQ;
                end else begin
                    rd_ns = WAIT_LOOKUP;
                end
            end else begin
                rd_ns = WAIT_MSG_RSP;
            end
        end


        WR_REQ: begin
            if(fetch_hsked) begin
                rd_ns = WAIT_WR_DONE;
            end else begin
                rd_ns = WR_REQ;
            end
        end

        WAIT_WR_DONE: begin
            if(fetch_done) begin
                rd_ns = UPDATE_LIST;
            end else begin
                rd_ns = WAIT_WR_DONE;
            end
        end

        RD_REQ: begin
            if(fetch_hsked) begin
                rd_ns = WAIT_RD_DONE;
            end else begin
                rd_ns = RD_REQ;
            end
        end

        WAIT_RD_DONE: begin
            if(fetch_done) begin
                rd_ns = ACC_MEM;
            end else begin
                rd_ns = WAIT_RD_DONE;
            end
        end

        ACC_MEM: begin
            if(mem_rhsked) begin
                rd_ns = UPDATE_LIST;
            end else begin
                rd_ns = ACC_MEM;
            end
        end

        UPDATE_LIST: begin
            if(req_hsked && !rd_req_pending) begin
                rd_ns = UPDATE_LIST_DONE;
            end else if(req_hsked && rd_req_pending) begin
                rd_ns = RD_REQ;
            end else begin
                rd_ns = UPDATE_LIST;
            end
        end

        UPDATE_LIST_DONE: begin
            if(proc_status_w == 3'b100) begin
                rd_ns = UPDATE_LIST_DONE;
            end else begin
                rd_ns = NORM;
            end
        end

        WAIT_COMFLICT: begin
            if(comflict_clear) begin
                rd_ns = WAIT_LOOKUP;
            end else begin
                rd_ns = WAIT_COMFLICT;
            end
        end

        default: rd_ns = rd_cs;
    endcase
end

assign fetch_req = cs_is_fetch_req;

assign fetch_addr = rd_cs == RD_REQ ? proc_addr_r : return_index_ff;

assign fetch_tag = return_tag_ff;

always_comb begin
    acc_req = 1'b0;
    acc_cmd = 3'b0;
    acc_tag = 0;
    if(rd_hsked || rd_cs == WAIT_LOOKUP) begin
        acc_req = 1'b1;
        acc_cmd = 3'b01;
        acc_tag = 0;
    end else if(cs_is_allocate_line) begin
        acc_req = 1'b1;
        acc_cmd = 3'b10;
        acc_tag = 0;
    end else if(rd_cs == UPDATE_LIST && rd_req_pending) begin
        acc_req = 1'b1;
        acc_cmd = 3'b11;
        acc_tag = return_tag_ff;
    end else if(rd_cs == UPDATE_LIST && !rd_req_pending && exclusive_rd) begin
        acc_req = 1'b1;
        acc_cmd = 3'b101;
        acc_tag = return_tag_ff;
    end else if(rd_cs == UPDATE_LIST && !rd_req_pending && !exclusive_rd) begin
        acc_req = 1'b1;
        acc_cmd = 3'b110;
        acc_tag = return_tag_ff;
    end
end

always_comb begin
    mem_ren = 1'b0;
    mem_raddr = 0;
    if(req_hsked && (rd_cs == NORM || rd_cs == IDLE || rd_cs == WAIT_LOOKUP) 
                    && (acc_status == 3'b001 || acc_status == 3'b011
                     || acc_status == 3'b010 || acc_status == 3'b110)) begin
            mem_ren = 1'b1;
            mem_raddr = {return_tag,local_addr[addr_offset_width - 1 : 2]};
    end else if(rd_cs == WAIT_MEM) begin
            mem_ren = 1'b1;
            mem_raddr = {return_tag_ff,local_addr[addr_offset_width - 1 : 2]};
    end else if(cs_is_acc_mem) begin
            mem_ren = 1'b1;
            mem_raddr = {return_tag_ff,local_addr[addr_offset_width - 1 : 2]};
    end
end

assign acc_rd_data = mem_rdata;

assign acc_rd_data_valid = mem_rdata_valid;


//acc status
//2'b01 : fetch line
//2'b10 : write the line into mem and fetch line
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fetch_cmd <= 2'b0;
    end else if(cs_is_allocate_line && req_hsked && acc_status == 3'b010) begin
        fetch_cmd <= 2'b00;
    end else if(cs_is_allocate_line && req_hsked && acc_status == 3'b001) begin
        fetch_cmd <= 2'b01;
    end else if(cs_is_allocate_line && req_hsked && acc_status == 3'b011) begin
        fetch_cmd <= 2'b01;
    end else if(cs_is_allocate_line && req_hsked && acc_status == 3'b000) begin
        fetch_cmd <= 2'b01;
    end else if(rd_cs == UPDATE_LIST && rd_req_pending && req_hsked) begin
        fetch_cmd <= 2'b01;
    end
end


always_comb begin
    // if(rd_cs == NORM || rd_cs == IDLE) begin
    //     mem_rpri = 2'b00;
    // end else if(rd_cs == WAIT_MEM || rd_cs == ACC_MEM) begin
    //     mem_rpri = 2'b01;
    // end else begin
        mem_rpri = 2'b00;
    // end

end
// msg
// 3'b010 : rd_normal_ack
// 3'b011 : rd_share_ack
// 3'b000 : wr_normal_ack
// 3'b100 : wr_req
// 3'b101 : rd_req

assign msg_req = rd_cs == MSG_REQ;

assign msg = 3'b101;

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        exclusive_rd <= 1'b0;
    end else if(msg_hsked) begin
        exclusive_rd <= 1'b0;
    end else if(msg_valid && msg_rsp == 3'b011) begin
        exclusive_rd <= 1'b0;
    end else if(msg_valid && msg_rsp == 3'b010) begin
        exclusive_rd <= 1'b1;
    end
end

endmodule