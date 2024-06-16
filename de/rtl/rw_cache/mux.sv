module mux #
            (
                parameter IN_WIDTH = 32,
                parameter UNIT_WIDTH = 4
            )
            (
                input logic [IN_WIDTH - 1 : 0] src_data,
                input logic [IN_WIDTH/UNIT_WIDTH - 1 : 0] src_sel,
                output logic [UNIT_WIDTH - 1 : 0] dst_data
            );
logic [UNIT_WIDTH - 1 : 0] src_data_slice [IN_WIDTH/UNIT_WIDTH];

generate
    for(genvar i = 0; i < IN_WIDTH/UNIT_WIDTH; i++) begin: mux_gen
        assign src_data_slice[i] = src_data[i * UNIT_WIDTH +: UNIT_WIDTH];
    end
endgenerate

always_comb begin
    dst_data = {UNIT_WIDTH{1'b0}};
    for(integer k = 0; k < IN_WIDTH/UNIT_WIDTH; k++) begin
        if(src_sel[k]) begin
            dst_data = src_data_slice[k];
        end
    end
end

endmodule