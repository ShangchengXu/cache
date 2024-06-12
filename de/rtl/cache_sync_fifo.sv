module cache_sync_fifo 
                # (
                    parameter DATA_WIDTH = 32,
                    parameter FIFO_DEPTH = 16
                )
                (
                    input  logic clk,
                    input  logic rst_n,
                    input  logic soft_rst,

                    input  logic [DATA_WIDTH - 1 : 0] write_data,
                    input  logic write,
                    

                    input  logic read,
                    output logic [DATA_WIDTH - 1 : 0] read_data,
                    output logic full,
                    output logic empty,
                    output logic [$clog2(FIFO_DEPTH):0] data_num
                );
//=======================================================================
// variables declaration
//=======================================================================
logic [ADDR_WIDTH : 0] wtpr,rptr;

logic [DATA_WIDTH - 1 : 0] mem [FIFO_DEPTH];

//=======================================================================
// main logic
//=======================================================================

assign read_data = mem[rptr[ADDR_WIDTH - 1 : 0]];

always_ff @( posedge clk or negedge rst_n ) begin
    if(~rst_n) begin
        wptr <= {(ADDR_WIDTH + 1){1'b0}};
    end else if(soft_rst) begin
        wptr <= {(ADDR_WIDTH + 1){1'b0}};
    end else if(write) begin
        if(wptr[ADDR_WIDTH - 1 : 0] == FIFO_DEPTH - 1'b1) begin
            wptr[ADDR_WIDTH - 1 : 0] <= {(ADDR_WIDTH){1'b0}};
            wptr[ADDR_WIDTH] <= ~wptr[ADDR_WIDTH];
        end else begin
            wptr <= wptr + 1'b1;
        end
    end
end


always_ff @( posedge clk or negedge rst_n ) begin
    if(~rst_n) begin
        rptr <= {(ADDR_WIDTH + 1){1'b0}};
    end else if(soft_rst) begin
        rptr <= {(ADDR_WIDTH + 1){1'b0}};
    end else if(read) begin
        if(rptr[ADDR_WIDTH - 1 : 0] == FIFO_DEPTH - 1'b1) begin
            rptr[ADDR_WIDTH - 1 : 0] <= {(ADDR_WIDTH){1'b0}};
            rptr[ADDR_WIDTH] <= ~rptr[ADDR_WIDTH];
        end else begin
            rptr <= rptr + 1'b1;
        end
    end
end


always_ff @( posedge clk or negedge rst_n ) begin
    if(~rst_n) begin
        for(integer i = 0; i < FIFO_DEPTH; i++) begin
            mem[i] <= {DATA_WIDTH{1'b0}};
        end
    end else if(write) begin
        mem[wptr[ADDR_WIDTH - 1 : 0]] <= write_data;
    end
end


assign empty = rptr == wptr;
assign full =  (rptr[ADDR_WIDTH] != wptr[ADDR_WIDTH]) && (wptr[ADDR_WIDTH - 1 : 0] == rptr[ADDR_WIDTH - 1 : 0]);

assign data_num = (rptr[ADDR_WIDTH] == wptr[ADDR_WIDTH]) ? (wptr[ADDR_WIDTH - 1 : 0] - rptr[ADDR_WIDTH - 1 : 0]) :
                                                        (wptr[ADDR_WIDTH - 1 : 0] + FIFO_DEPTH - rptr[ADDR_WIDTH - 1 : 0]);

`ifdef ASSERT_ON
property full_write:
        @(posedge clk) disable iff (~rst_n) (full |-> ~write);
endproperty
full_write0: assert property(full_write);
property empty_read:
        @(posedge clk) disable iff (~rst_n) (empty |-> ~read);
endproperty
empty_read0: assert property(empty_read);
`endif


endmodule