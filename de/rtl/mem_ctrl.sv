module mem_ctrl #(
                parameter mem_depth = 32,
                parameter data_width = 32

                )
                (

                    input    logic          clk,
                    input    logic          rst_n,

                    input    logic  [$clog2(mem_depth) - 1 : 0]                        mem_raddr,
                    input    logic                                                     mem_ren,
                    input    logic  [1:0]                                              mem_rpri,
                    output   logic                                                     mem_rready,
                    output   logic  [data_width - 1 : 0]                               mem_rdata,
                    output   logic                                                     mem_rdata_valid,


                    input    logic  [$clog2(mem_depth) - 1 : 0]                        mem_waddr,
                    input    logic                                                     mem_wen,
                    input    logic  [1:0]                                              mem_wpri,
                    output   logic                                                     mem_wready,
                    input    logic  [data_width - 1 : 0]                               mem_wdata,


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
logic [$clog2(mem_depth) - 1 : 0] local_mem_raddr, local_mem_waddr;
logic [data_width - 1 : 0] local_mem_wdata, local_mem_rdata;
logic wr_rd_conflict;

logic fetch_whsked;
logic fetch_rhsked;
logic whsked;
logic rhsked;

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

assign whsked = mem_wen && mem_wready;
assign rhsked = mem_ren && mem_rready;

assign local_mem_wen = whsked || fetch_whsked;
assign local_mem_ren = rhsked || fetch_rhsked;

assign wr_rd_conflict = (local_mem_wen && local_mem_ren) && (local_mem_raddr == local_mem_waddr);

assign local_mem_waddr = fetch_whsked ? fetch_mem_waddr : mem_waddr;
assign local_mem_raddr = fetch_rhsked ? fetch_mem_raddr : mem_raddr;

assign local_mem_wdata = fetch_hsked ? fetch_mem_wdata : mem_wdata;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mem_rdata_valid <= 1'b0;
    end else if(mem_ren  && mem_rready) begin
        mem_rdata_valid <= 1'b1;
    end else begin
        mem_rdata_valid <= 1'b0;
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
        local_mem_rdata <= 0;
    end else if(wr_rd_conflict) begin
        local_mem_rdata <= local_mem_wdata;
    end else if(local_mem_ren) begin
        local_mem_rdata <= mem[local_mem_raddr];
    end
end

assign mem_rdata = local_mem_rdata;

assign fetch_mem_rdata = local_mem_rdata;

assign mem_wr_req = {fetch_mem_wen, mem_wen};

assign mem_rd_req = {fetch_mem_ren, mem_ren};

assign {fetch_mem_rready, mem_rready} = mem_rd_gnt;

assign {fetch_mem_wready, mem_wready} = mem_wr_gnt;

cache_rr_arb #(
        .WIDTH       (2       ),
        .REFLECTION  (0       ))
             cache_rr_arb_wr_inst (
        .clk         (clk                ) ,//input   
        .rst_n       (rst_n              ) ,//input   
        .req         (mem_wr_req         ) ,//input   [WIDTH - 1 : 0]
        .req_end     (mem_wr_gnt         ) ,//input   [WIDTH - 1 : 0]
        .gnt         (mem_wr_gnt         ));//output  [WIDTH - 1 : 0]

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