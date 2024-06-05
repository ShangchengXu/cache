module mem_ctrl #(
                parameter mem_depth = 32,
                parameter data_width = 32

                )
                (

                    input    logic          clk,
                    input    logic          rst_n,

                    input    logic  [$clog2(mem_depth) - 1 : 0]                        mem_raddr,
                    input    logic                                                     mem_ren,
                    output   logic                                                     mem_rready,
                    output   logic  [data_width - 1 : 0]                               mem_rdata,
                    output   logic                                                     mem_rdata_valid,


                    input    logic  [$clog2(mem_depth) - 1 : 0]                        mem_waddr,
                    input    logic                                                     mem_wen,
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

always_ff @( posedge clk ) begin
    if(local_mem_wen)
        mem[local_mem_waddr] <= local_mem_wdata;
end

assign local_mem_wen = mem_wen || fetch_mem_wen;
assign local_mem_ren = mem_ren || fetch_mem_ren;

assign local_mem_waddr = fetch_mem_wen ? fetch_mem_waddr : mem_waddr;
assign local_mem_raddr = fetch_mem_ren ? fetch_mem_raddr : mem_raddr;

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
    end else if(local_mem_ren) begin
        local_mem_rdata <= mem[local_mem_raddr];
    end
end

assign mem_rdata = local_mem_rdata;

assign fetch_mem_rdata = local_mem_rdata;

assign mem_wready = !fetch_mem_wen;

assign mem_rready = !fetch_mem_ren;

assign fetch_mem_rready = 1'b1;

assign fetch_mem_wready = 1'b1;

endmodule