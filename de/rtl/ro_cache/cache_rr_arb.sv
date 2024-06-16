module cache_rr_arb #
            (
                parameter WIDTH = 7,
                parameter REFLECTION = 1 //0:inc 1:dec
            )
            (
                input clk,
                input rst_n,
                input [WIDTH - 1 : 0] req,
                input [WIDTH - 1 : 0] req_end,
                output [WIDTH - 1 : 0] gnt
            );
//=======================================================================
// Variables declaration
//=======================================================================
logic [WIDTH - 1 : 0] mask;
logic [WIDTH - 1 : 0] req_masked;
logic [WIDTH - 1 : 0] req_unmasked;
logic [WIDTH - 1 : 0] req_reflect;
logic [WIDTH - 1 : 0] req_temp;
logic [WIDTH - 1 : 0] prev_gnt;
logic [WIDTH - 1 : 0] gnt_latch;
logic [WIDTH - 1 : 0] gnt_inner;
logic [WIDTH - 1 : 0] gnt_temp;
logic [WIDTH - 1 : 0] gnt_temp_masked;
logic [WIDTH - 1 : 0] gnt_temp_unmasked;
logic [WIDTH - 1 : 0] gnt_inner_reflect;
logic [WIDTH - 1 : 0] req_end_reflect;
logic [WIDTH - 1 : 0] req_end_temp;

//=======================================================================
// main logic 
//=======================================================================
generate 
    genvar i;
    for(i = 0; i < WIDTH; i ++) begin : generata_block
       assign req_reflect[i] = req[WIDTH - i - 1];
       if(i == WIDTH - 1) begin
            assign mask[i] = prev_gnt[i];
       end else begin
            assign mask[i] = prev_gnt[i] || mask[i + 1];
       end
       assign req_end_reflect[i] = req_end[WIDTH - i - 1];
       assign gnt_inner_reflect[i] = gnt_inner[WIDTH - i - 1];
    end
endgenerate

generate
    if(REFLECTION == 1) begin : REFLECTION_MODE
        assign req_temp = req_reflect;
        assign req_end_temp = req_end_reflect;
        assign gnt = gnt_inner_reflect;
    end else  begin : NOT_REFLECTION_MODE
        assign req_temp = req;
        assign req_end_temp = req_end;
        assign gnt = gnt_inner;
    end
endgenerate

assign req_masked = req_temp & mask;
assign req_unmasked = req_temp & ~mask;

assign gnt_temp_unmasked = (~req_unmasked + 1'b1) & (req_unmasked);
assign gnt_temp_masked = (~req_masked + 1'b1) & (req_masked);

assign gnt_temp = |gnt_temp_unmasked ?  gnt_temp_unmasked : gnt_temp_masked;

always_ff @( posedge clk or negedge rst_n ) begin
    if(~rst_n) begin
        prev_gnt <= {WIDTH{1'b0}};
    end else if(|(gnt_inner & req_end_temp)) begin
        prev_gnt <= gnt_inner;
    end
end

always_ff @( posedge clk or negedge rst_n ) begin
    if(~rst_n) begin
        gnt_latch <= {WIDTH{1'b0}};
    end else if(|(gnt_inner & req_end_temp)) begin
        gnt_latch <= {WIDTH{1'b0}};
    end else if(|gnt_inner) begin
        gnt_latch <= gnt_inner;
    end
end

assign gnt_inner = |gnt_latch ? gnt_latch : gnt_temp;
endmodule

