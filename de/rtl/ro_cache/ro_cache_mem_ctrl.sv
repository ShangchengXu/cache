module ro_cache_mem_ctrl #(
                parameter mem_depth = 32,
                parameter data_width = 32

                )
                (

                    input    logic          clk,
                    input    logic          rst_n,

                    input    logic  [$clog2(mem_depth) - 1 : 0]                        mem_raddr_0,
                    input    logic                                                     mem_ren_0,
                    input    logic  [1:0]                                              mem_rpri_0,
                    output   logic                                                     mem_rready_0,
                    output   logic  [data_width - 1 : 0]                               mem_rdata_0,
                    output   logic                                                     mem_rdata_valid_0,


                    input    logic  [$clog2(mem_depth) - 1 : 0]                        mem_raddr_1,
                    input    logic                                                     mem_ren_1,
                    input    logic  [1:0]                                              mem_rpri_1,
                    output   logic                                                     mem_rready_1,
                    output   logic  [data_width - 1 : 0]                               mem_rdata_1,
                    output   logic                                                     mem_rdata_valid_1,


                    input    logic  [$clog2(mem_depth) - 1 : 0]                        fetch_mem_raddr,
                    input    logic                                                     fetch_mem_ren,
                    output   logic                                                     fetch_mem_rready,
                    output   logic  [data_width - 1 : 0]                               fetch_mem_rdata,
                    output   logic                                                     fetch_mem_rdata_valid,


                    input    logic  [$clog2(mem_depth) - 1 : 0]                        fetch_mem_waddr,
                    input    logic                                                     fetch_mem_wen,
                    output   logic                                                     fetch_mem_wready,
                    input    logic  [data_width - 1 : 0]                               fetch_mem_wdata


                );
logic [31:0] mem [mem_depth];

logic local_mem_wen,local_mem_ren;
logic [$clog2(mem_depth) - 1 : 0] local_mem_raddr_0, local_mem_waddr;
logic [$clog2(mem_depth) - 1 : 0] local_mem_raddr_1;
logic [data_width - 1 : 0] local_mem_wdata, local_mem_rdata_0,local_mem_rdata_1;
logic wr_rd_conflict_0;
logic wr_rd_conflict_1;

logic fetch_whsked;
logic fetch_rhsked;
logic whsked;
logic rhsked_0;
logic rhsked_1;

logic [1:0] mem_wr_req;

logic [1:0] mem_rd_req;

logic [1:0] mem_wr_gnt;

logic [1:0] mem_rd_gnt;

always_ff @( posedge clk ) begin
    if(local_mem_wen)
        mem[local_mem_waddr] <= local_mem_wdata;
end

assign fetch_whsked = fetch_mem_wen && fetch_mem_wready;
assign fetch_rhsked = fetch_mem_ren && fetch_mem_rready;

assign rhsked_0 = mem_ren_0 && mem_rready_0;
assign rhsked_1 = mem_ren_1 && mem_rready_1;

assign local_mem_wen = fetch_whsked;
assign local_mem_ren_0 = rhsked_0 || fetch_rhsked;
assign local_mem_ren_1 = rhsked_1;

assign wr_rd_conflict_0 = (local_mem_wen && local_mem_ren_0) && (local_mem_raddr_0 == local_mem_waddr);
assign wr_rd_conflict_1 = (local_mem_wen && local_mem_ren_1) && (local_mem_raddr_1 == local_mem_waddr);

assign local_mem_waddr = fetch_mem_waddr;
assign local_mem_raddr_0 = fetch_rhsked ? fetch_mem_raddr : mem_raddr_0;
assign local_mem_raddr_1 = mem_raddr_1;

assign local_mem_wdata = fetch_mem_wdata;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mem_rdata_valid_0 <= 1'b0;
    end else if(mem_ren_0  && mem_rready_0) begin
        mem_rdata_valid_0 <= 1'b1;
    end else begin
        mem_rdata_valid_0 <= 1'b0;
    end
end


always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mem_rdata_valid_1 <= 1'b0;
    end else if(mem_ren_1  && mem_rready_1) begin
        mem_rdata_valid_1 <= 1'b1;
    end else begin
        mem_rdata_valid_1 <= 1'b0;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fetch_mem_rdata_valid <= 1'b0;
    end else if(fetch_mem_ren  && fetch_mem_rready) begin
        fetch_mem_rdata_valid <= 1'b1;
    end else begin
        fetch_mem_rdata_valid <= 1'b0;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        local_mem_rdata_0 <= 0;
    end else if(wr_rd_conflict_0) begin
        local_mem_rdata_0 <= local_mem_wdata;
    end else if(local_mem_ren_0) begin
        local_mem_rdata_0 <= mem[local_mem_raddr_0];
    end
end


always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        local_mem_rdata_1 <= 0;
    end else if(wr_rd_conflict_1) begin
        local_mem_rdata_1 <= local_mem_wdata;
    end else if(local_mem_ren_1) begin
        local_mem_rdata_1 <= mem[local_mem_raddr_1];
    end
end

assign mem_rdata_0 = local_mem_rdata_0;
assign mem_rdata_1 = local_mem_rdata_1;

assign fetch_mem_rdata = local_mem_rdata_0;

assign mem_rd_req = {fetch_mem_ren, mem_ren_0};

assign {fetch_mem_rready, mem_rready_0} = mem_rd_gnt;

assign fetch_mem_wready = 1'b1;

assign mem_rready_1 = 1'b1;

cache_rr_arb #(
        .WIDTH       (2       ),
        .REFLECTION  (0       ))
             cache_rr_arb_rd_inst (
        .clk         (clk                ) ,//input   
        .rst_n       (rst_n              ) ,//input   
        .req         (mem_rd_req         ) ,//input   [WIDTH - 1 : 0]
        .req_end     (mem_rd_gnt         ) ,//input   [WIDTH - 1 : 0]
        .gnt         (mem_rd_gnt         ));//output  [WIDTH - 1 : 0]

endmodule