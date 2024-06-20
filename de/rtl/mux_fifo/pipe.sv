module pipe 
            #(
                parameter MODE = 2'b01,
                parameter DATA_WIDTH = 32
            )
            (
                input  logic clk,
                input  logic rst_n,
                input  logic soft_rst,

                input  logic src_vld,
                output logic src_rdy,
                input  [DATA_WIDTH - 1 : 0] src_data,

                output logic dst_vld,
                input  logic dst_rdy,
                output [DATA_WIDTH - 1 : 0] dst_data
            );

logic src_hsked;
logic dst_hsked;

assign src_hsked = src_vld & src_rdy;
assign dst_hsked = dst_vld & dst_rdy;

generate
    if(MODE == 2'b00) begin : direct_mode
        assign dst_vld = src_vld;       
        assign src_rdy = dst_rdy;
        assign dst_data = src_data;
    end else if( MODE == 2'b01) begin: vld_pipe
        logic [DATA_WIDTH - 1 : 0] register;
        logic  register_vld;
        always @(posedge clk or negedge rst_n) begin
            if(~rst_n) begin
                register <= {DATA_WIDTH{1'b0}};
                register_vld <= 1'b0;
            end else if(soft_rst) begin
                register <= {DATA_WIDTH{1'b0}};
                register_vld <= 1'b0;
            end else if(src_hsked) begin
                register <= src_data;
                register_vld <= 1'b1;
            end else if(dst_hsked) begin
                register <= {DATA_WIDTH{1'b0}};
                register_vld <= 1'b0;
            end
        end
        assign src_rdy = ((~register_vld) || dst_hsked);
        assign dst_data = register;
        assign dst_vld = register_vld;
    end else if( MODE == 2'b10 ) begin: rdy_pipe
        logic [DATA_WIDTH - 1 : 0] register;
        logic  register_vld;
        logic  src_rdy_ff;
        always @(posedge clk or negedge rst_n) begin if(~rst_n) begin
                register <= {DATA_WIDTH{1'b0}};
                register_vld <= 1'b0;
                src_rdy_ff <= 1'b1;
            end else if(soft_rst) begin
                register <= {DATA_WIDTH{1'b0}};
                register_vld <= 1'b0;
                src_rdy_ff <= 1'b1;
            end else if(src_hsked && ~dst_rdy) begin
                register <= src_data;
                register_vld <= 1'b1;
                src_rdy_ff <= 1'b0;
            end else if(dst_hsked) begin
                register <= {DATA_WIDTH{1'b0}};
                register_vld <= 1'b0;
                src_rdy_ff <= 1'b1;
            end
        end
        assign src_rdy = src_rdy_ff;
        assign dst_data = register_vld ? register : src_data;
        assign dst_vld = register_vld || src_vld;
    end else if( MODE == 2'b11) begin:full_pipe
        logic [DATA_WIDTH - 1 : 0] register[2];
        logic  register_vld[2];
        logic  src_rdy_ff;
        always @(posedge clk or negedge rst_n) begin 
            if(~rst_n) begin
                register[0] <= {DATA_WIDTH{1'b0}};
                register_vld[0] <= 1'b0;
            end else if(soft_rst) begin
                register[0] <= {DATA_WIDTH{1'b0}};
                register_vld[0] <= 1'b0;
            end else if(src_hsked &&  dst_hsked && ~register_vld[1]) begin
                register[0] <= src_data;
                register_vld[0] <= 1'b1;
            end else if(src_hsked && ~register_vld[0]) begin
                register[0] <= src_data;
                register_vld[0] <= 1'b1;
            end else if(dst_hsked && register_vld[1]) begin
                register[0] <= register[1];
                register_vld[0] <= 1'b1;
            end else if(dst_hsked) begin
                register[0] <= {DATA_WIDTH{1'b0}};
                register_vld[0] <= 1'b0;
            end
        end

        always @(posedge clk or negedge rst_n) begin 
            if(~rst_n) begin
                register[1] <= {DATA_WIDTH{1'b0}};
                register_vld[1] <= 1'b0;
            end else if(soft_rst) begin
                register[1] <= {DATA_WIDTH{1'b0}};
                register_vld[1] <= 1'b0;
            end else if(src_hsked &&  dst_hsked) begin
                register[1] <= register_vld[1] ? src_data : register[1];;
            end else if(src_hsked && register_vld[0]) begin
                register[1] <= src_data;
                register_vld[1] <= 1'b1;
            end else if(dst_hsked && register_vld[1]) begin
                register[1] <= {DATA_WIDTH{1'b0}};
                register_vld[1] <= 1'b0;
            end
        end
        
        
        always @(posedge clk or negedge rst_n) begin
            if(~rst_n) begin
                src_rdy_ff <= 1'b1;
            end else if(soft_rst) begin
                src_rdy_ff <= 1'b1;
            end else if(src_hsked && dst_hsked) begin
                src_rdy_ff <= 1'b1;
            end else if(src_hsked) begin
                src_rdy_ff <= ~register_vld[0];
            end else if(dst_hsked) begin
                src_rdy_ff <= 1'b1;
            end
        end
        assign src_rdy = src_rdy_ff;
        assign dst_vld = register_vld[0];
        assign dst_data = register[0];
    end
endgenerate
endmodule