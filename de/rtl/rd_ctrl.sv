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
                    output   logic [1:0]                         acc_cmd,
                    output   logic [$clog2(list_depth) - 1 : 0]  acc_tag,
                    input    logic [$clog2(list_depth) - 1 : 0]  return_tag,
                    input    logic [addr_width - 1 :0]           return_index,
                    output   logic                               acc_req,


                    input    logic                               allocate_busy,

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
                    output   logic [addr_width - 1 : 0]          fetch_addr_pre,
                    input    logic                               fetch_gnt,
                    input    logic                               fetch_done,

                    output   logic  [$clog2(list_depth) + $clog2(list_width) - 1 : 0] mem_raddr,
                    output   logic                                                     mem_ren,
                    input    logic                                                     mem_rready,
                    input    logic  [data_width - 1 : 0]                               mem_rdata,
                    input    logic                                                     mem_rdata_valid
                );


localparam addr_offset_width = $clog2(list_width * data_width / 8);

typedef enum logic [3:0] { 
        IDLE,
        NORM,
        WAIT_MEM,
        CHECK_COMFLICT,
        ALLOCATE_LINE,
        FETCH_REQ,
        WAIT_FETCH_CMP,
        ACC_MEM,
        WAIT_COMFLICT
} rd_state_t;

rd_state_t rd_cs,rd_ns;

logic [addr_width - 1 : 0] acc_rd_addr_ff;

logic [addr_width - 1 : 0] local_addr;

logic [$clog2(list_depth) - 1 : 0] return_tag_ff;

logic [addr_width - 1 :0]           return_index_ff;

logic rd_hsked;

logic fetch_hsked;

logic mem_rhsked;

logic has_comflict;

logic comflict_clear;

logic cs_is_check_comflict;

logic cs_is_allocate_line;

logic cs_is_fetch_req;

logic cs_is_wait_fetch_comp;

logic cs_is_acc_mem;

assign cs_is_acc_mem = rd_cs == ACC_MEM;

assign cs_is_allocate_line = rd_cs == ALLOCATE_LINE;

assign cs_is_check_comflict = rd_cs == CHECK_COMFLICT;

assign cs_is_fetch_req = rd_cs == FETCH_REQ;

assign cs_is_wait_fetch_comp = rd_cs == WAIT_FETCH_CMP;



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

assign comflict_clear = proc_status_w == 3'b011;

always_comb begin
    if(cs_is_check_comflict) begin
        proc_status_r = 3'b001;
    end else if(cs_is_acc_mem && mem_rhsked) begin
        proc_status_r = 3'b011;
    end else if(cs_is_allocate_line || cs_is_fetch_req || cs_is_wait_fetch_comp || cs_is_acc_mem) begin
        proc_status_r = 3'b010;
    end else begin
        proc_status_r = 3'b000;
    end
end

assign proc_tag_r = cs_is_allocate_line && !allocate_busy ? return_tag : return_tag_ff;

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
    end else if(cs_is_allocate_line && !allocate_busy || rd_hsked) begin
        return_tag_ff <= return_tag;
    end
end

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        return_index_ff <= 0;
    end else if(cs_is_allocate_line && !allocate_busy) begin
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
                if(acc_status == 3'b000 || acc_status == 3'b100) begin
                    rd_ns = CHECK_COMFLICT;
                end else if(!mem_rhsked) begin
                    rd_ns = WAIT_MEM;
                end else begin
                    rd_ns = NORM;
                end
            end else begin
                    rd_ns = IDLE;
            end
        end

        NORM: begin
            if(rd_hsked) begin
                if(acc_status == 3'b000 || acc_status == 3'b100) begin
                    rd_ns = CHECK_COMFLICT;
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
            if(!allocate_busy) begin
                rd_ns = FETCH_REQ;
            end else begin
                rd_ns = ALLOCATE_LINE;
            end
        end

        FETCH_REQ: begin
            if(fetch_hsked) begin
                rd_ns = WAIT_FETCH_CMP;
            end else begin
                rd_ns = FETCH_REQ;
            end
        end

        WAIT_FETCH_CMP: begin
            if(fetch_done) begin
                rd_ns = ACC_MEM;
            end else begin
                rd_ns = WAIT_FETCH_CMP;
            end
        end

        ACC_MEM: begin
            if(mem_rhsked) begin
                rd_ns = NORM;
            end else begin
                rd_ns = ACC_MEM;
            end
        end

        WAIT_COMFLICT: begin
            if(comflict_clear) begin
                rd_ns = ACC_MEM;
            end else begin
                rd_ns = WAIT_COMFLICT;
            end
        end

        default: rd_ns = rd_cs;
    endcase
end

assign fetch_req = cs_is_fetch_req;

assign fetch_addr = proc_addr_r;

assign fetch_tag = return_tag_ff;

assign fetch_addr_pre = return_index_ff;

always_comb begin
    acc_req = 1'b0;
    acc_cmd = 2'b0;
    acc_tag = 0;
    if(rd_hsked) begin
        acc_req = 1'b1;
        acc_cmd = 2'b00;
        acc_tag = 0;
    end else if(cs_is_allocate_line && !allocate_busy) begin
        acc_req = 1'b1;
        acc_cmd = 2'b10;
        acc_tag = 0;
    end else if(cs_is_acc_mem && mem_rready) begin
        acc_req = 1'b1;
        acc_cmd = 2'b11;
        acc_tag = return_tag_ff;
    end
end

always_comb begin
    mem_ren = 1'b0;
    mem_raddr = 0;
    if(rd_hsked && (acc_status == 3'b001 || acc_status == 3'b010)) begin
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
    end else if(cs_is_allocate_line && !allocate_busy) begin
        fetch_cmd <= acc_status;
    end
end

endmodule