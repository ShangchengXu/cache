module wr_ctrl #(
                parameter addr_width = 32,
                parameter list_depth = 4,
                parameter data_width = 32,
                parameter list_width = 32
                )
                (
                    input    logic                               clk,
                    input    logic                               rst_n,

                    input    logic                               acc_wr_valid,
                    output   logic                               acc_wr_ready,
                    input    logic [addr_width - 1 : 0]          acc_wr_addr,
                    input    logic [data_width - 1 : 0]          acc_wr_data,

                    output   logic [addr_width - 1 :0]           acc_index,
                    input    logic [2:0]                         acc_status,
                    output   logic [1:0]                         acc_cmd,
                    output   logic [$clog2(list_depth) - 1 : 0]  acc_tag,
                    input    logic [$clog2(list_depth) - 1 : 0]  return_tag,
                    input    logic [addr_width - 1 :0]           return_index,
                    output   logic                               acc_req,

                    input    logic                               allocate_busy,

                    output   logic [2:0]                         proc_status_w,
                    output   logic [addr_width - 1 : 0]          proc_addr_w,
                    output   logic [$clog2(list_depth) - 1 : 0]  proc_tag_w,

                    input    logic [2:0]                         proc_status_r,
                    input    logic [addr_width - 1 : 0]          proc_addr_r,
                    input    logic [$clog2(list_depth) - 1 : 0]  proc_tag_r,


                    output   logic [1:0]                         fetch_cmd,
                    output   logic                               fetch_req,
                    output   logic [$clog2(list_depth) - 1 : 0]  fetch_tag,
                    output   logic [addr_width - 1 : 0]          fetch_addr,
                    output   logic [addr_width - 1 : 0]          fetch_addr_pre,
                    input    logic                               fetch_gnt,
                    input    logic                               fetch_done,

                    output   logic  [$clog2(list_depth) + $clog2(list_width) - 1 : 0]  mem_waddr,
                    output   logic                                                     mem_wen,
                    output   logic  [1:0]                                              mem_wpri,
                    input    logic                                                     mem_wready,
                    output   logic  [data_width - 1 : 0]                               mem_wdata
                );

typedef enum logic [3:0] { 
        IDLE,
        NORM,
        WAIT_MEM,
        CHECK_COMFLICT,
        ALLOCATE_LINE,
        FETCH_REQ,
        WAIT_FETCH_CMP,
        ACC_MEM,
        ACC_MEM_DONE,
        WAIT_COMFLICT
} wr_state_t;

wr_state_t wr_cs,wr_ns;

localparam addr_offset_width = $clog2(list_width * data_width / 8);

logic [addr_width - 1 : 0] acc_wr_addr_ff;

logic [addr_width - 1 : 0] local_addr;

logic [data_width - 1 : 0] local_wdata;

logic [data_width - 1 : 0] acc_wr_data_ff;

logic [$clog2(list_depth) - 1 : 0] return_tag_ff;

logic wr_hsked;

logic fetch_hsked;

logic [addr_width - 1 :0]  return_index_ff;

logic mem_whsked;

logic has_comflict;

logic comflict_clear;

logic cs_is_check_comflict;

logic cs_is_allocate_line;

logic cs_is_fetch_req;

logic cs_is_wait_fetch_comp;

logic cs_is_acc_mem;

logic fetch_proc;

assign cs_is_acc_mem = wr_cs == ACC_MEM;

assign cs_is_allocate_line = wr_cs == ALLOCATE_LINE;

assign cs_is_check_comflict = wr_cs == CHECK_COMFLICT;

assign cs_is_fetch_req = wr_cs == FETCH_REQ;

assign cs_is_wait_fetch_comp = wr_cs == WAIT_FETCH_CMP;



//proc status
//3'b000 no need
//3'b001 check_conflict
//3'b010 busy
//3'b011 done

assign wr_hsked = acc_wr_valid && acc_wr_ready;

assign fetch_hsked = fetch_req && fetch_gnt;

assign mem_whsked = mem_wen && mem_wready;

assign acc_wr_ready = (wr_cs == IDLE) || (wr_cs == NORM);

assign has_comflict = (proc_status_r == 3'b010) && (proc_addr_r == proc_addr_w);

assign comflict_clear = (proc_status_r != 3'b010) && (proc_addr_r != 3'b011);

always_comb begin
    if(cs_is_check_comflict) begin
        proc_status_w = 3'b001;
    end else if(cs_is_allocate_line || cs_is_fetch_req || cs_is_wait_fetch_comp) begin
        proc_status_w = 3'b010;
    end else if(cs_is_acc_mem && mem_whsked) begin
        proc_status_w = 3'b011;
    end else if(wr_cs == WAIT_COMFLICT) begin
        proc_status_w = 3'b100;
    end else if(cs_is_allocate_line || cs_is_fetch_req || cs_is_wait_fetch_comp || cs_is_acc_mem) begin
        proc_status_w = 3'b010;
    end else begin
        proc_status_w = 3'b000;
    end
end

assign proc_tag_w = cs_is_allocate_line && !allocate_busy ? return_tag : return_tag_ff;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fetch_proc <= 1'b0;
    end else if(cs_is_fetch_req) begin
        fetch_proc <= 1'b1;
    end else if(cs_is_acc_mem && fetch_proc) begin
        fetch_proc <= 1'b0;
    end
end


always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        acc_wr_addr_ff <= 0;
    end else if(wr_hsked) begin
        acc_wr_addr_ff <= acc_wr_addr;
    end
end

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        acc_wr_data_ff <= 0;
    end else if(wr_hsked) begin
        acc_wr_data_ff <= acc_wr_data;
    end
end


always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        return_tag_ff <= 0;
    end else if(wr_cs == WAIT_COMFLICT && wr_ns != WAIT_COMFLICT)begin
        return_tag_ff <= proc_tag_r;
    end else if((cs_is_allocate_line && !allocate_busy) || wr_hsked) begin
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

assign local_addr = wr_hsked ? acc_wr_addr : acc_wr_addr_ff;

assign local_wdata = wr_hsked ? acc_wr_data : acc_wr_data_ff;

assign proc_addr_w = {local_addr[addr_width - 1 : addr_offset_width],{addr_offset_width{1'b0}}};

assign acc_index = proc_addr_w;

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_cs <= IDLE;
    end else if(wr_cs != wr_ns) begin
        wr_cs <= wr_ns;
    end
end

always_comb begin:WR_FSM
    wr_ns = wr_cs;
    case(wr_cs)

        IDLE : begin
            if(wr_hsked) begin
                if(acc_status == 3'b000) begin
                    wr_ns = CHECK_COMFLICT;
                end else if(acc_status == 3'b100) begin
                    wr_ns = WAIT_COMFLICT;
                end else if(!mem_whsked) begin
                    wr_ns = WAIT_MEM;
                end else begin
                    wr_ns = NORM;
                end
            end else begin
                    wr_ns = IDLE;
            end
        end

        NORM: begin
            if(wr_hsked) begin
                if(acc_status == 3'b000) begin
                    wr_ns = CHECK_COMFLICT;
                end else if(acc_status == 3'b100) begin
                    wr_ns = WAIT_COMFLICT;
                end else if(!mem_whsked) begin
                    wr_ns = WAIT_MEM;
                end else begin
                    wr_ns = NORM;
                end
            end else begin
                    wr_ns = IDLE;
            end
        end

        WAIT_MEM: begin
            if(mem_whsked) begin
                wr_ns = NORM;
            end else begin
                wr_ns = WAIT_MEM;
            end
        end

        CHECK_COMFLICT: begin
            if(has_comflict) begin
                wr_ns = WAIT_COMFLICT;
            end else begin
                wr_ns = ALLOCATE_LINE;
            end
        end

        FETCH_REQ: begin
            if(fetch_hsked) begin
                wr_ns = WAIT_FETCH_CMP;
            end else begin
                wr_ns = FETCH_REQ;
            end
        end

        WAIT_FETCH_CMP: begin
            if(fetch_done) begin
                wr_ns = ACC_MEM;
            end else begin
                wr_ns = WAIT_FETCH_CMP;
            end
        end

        ALLOCATE_LINE: begin
            if(!allocate_busy) begin
                wr_ns = FETCH_REQ;
            end else begin
                wr_ns = ALLOCATE_LINE;
            end
        end

        ACC_MEM: begin
            if(mem_whsked) begin
                wr_ns = ACC_MEM_DONE;
            end else begin
                wr_ns = ACC_MEM;
            end
        end

        ACC_MEM_DONE: begin
            if(proc_status_r == 3'b100) begin
                wr_ns = ACC_MEM_DONE;
            end else begin
                wr_ns = NORM;
            end
        end

        WAIT_COMFLICT: begin
            if(comflict_clear) begin
                wr_ns = ACC_MEM;
            end else begin
                wr_ns = WAIT_COMFLICT;
            end
        end

        default: wr_ns = wr_cs;
    endcase
end

assign fetch_req = cs_is_fetch_req;

assign fetch_addr = proc_addr_w;

assign fetch_addr_pre = return_index_ff;

assign fetch_tag = return_tag_ff;


always_comb begin
    acc_req = 1'b0;
    acc_cmd = 2'b0;
    acc_tag = 0;
    if(wr_hsked) begin
        acc_req = 1'b1;
        acc_cmd = 2'b00;
        acc_tag = 0;
    end else if(cs_is_allocate_line && !allocate_busy) begin
        acc_req = 1'b1;
        acc_cmd = 2'b10;
        acc_tag = 0;
    end else if(cs_is_acc_mem && mem_wready) begin
        acc_req = 1'b1;
        acc_cmd = 2'b11;
        acc_tag = return_tag_ff;
    end
end

assign mem_wdata = local_wdata; 

always_comb begin
    mem_wen = 1'b0;
    mem_waddr = 0;
    if(wr_hsked && (acc_status == 3'b001 || acc_status == 3'b010)) begin
            mem_wen = 1'b1;
            mem_waddr = {return_tag,local_addr[addr_offset_width - 1 : 2]};
    end else if(wr_cs == WAIT_MEM) begin
            mem_wen = 1'b1;
            mem_waddr = {return_tag_ff,local_addr[addr_offset_width - 1 : 2]};
    end else if(cs_is_acc_mem) begin
            mem_wen = 1'b1;
            mem_waddr = {return_tag_ff,local_addr[addr_offset_width - 1 : 2]};
    end
end


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

always_comb begin
    // if(wr_cs == NORM || wr_cs == IDLE) begin
    //     mem_wpri = 2'b00;
    // end else if(wr_cs == WAIT_MEM || wr_cs == ACC_MEM) begin
    //     mem_wpri = 2'b01;
    // end else begin
        mem_wpri = 2'b00;
    // end

end



endmodule
