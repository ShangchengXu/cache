module list_ctrl 
            #(parameter lists_depth = 4,
              parameter index_lenth = 4
             )
            (
                input  logic clk,
                input  logic rst_n,
                
                // port0
                input  logic [index_lenth - 1 :0]          acc_index_0,
                output logic [1:0]                         acc_status_0,
                input  logic [1:0]                         acc_cmd_0,
                output logic [$clog2(lists_depth) - 1 : 0] return_tag_0,
                input  logic                               acc_req_0,


                // port1
                input  logic [index_lenth - 1 :0]          acc_index_1,
                output logic [1:0]                         acc_status_1,
                input  logic [1:0]                         acc_cmd_1,
                output logic [$clog2(lists_depth) - 1 : 0] return_tag_1,
                input  logic                               acc_req_1,
            );

//variables
typedef struct {
    logic [$clog2(lists_depth) - 1 : 0] head;
    logic [$clog2(lists_depth) - 1 : 0] tail;
    logic [$clog2(lists_depth)     : 0] length;
    logic                               empty;
} list_table_t;
list_table_t free_list, lru_list;

struct {
    logic [$clog2(lists_depth) - 1 : 0] pre_tag;
    logic [$clog2(lists_depth) - 1 : 0] nxt_tag;
    logic [2:0]                         status;
} tag_table;


generate
    for(genvar i = 0; i < lists_depth; i++) begin:tag_table_grp
        always_ff@(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                tag_table[i].status <= 3'b0;
                if(i == 0) begin
                    tag_table[i].pre_tag <= lists_depth - 1;
                end else begin
                    tag_table[i].pre_tag <= i - 1;
                end
                if(i == lists_depth - 1) begin
                    tag_table[i].nxt_tag <= 0;
                end else begin
                    tag_table[i].nxt_tag <= i + 1;
                end
            end
        end else if(acc_cmd_0 == 2'b00 && acc_cmd_0) begin
        end


    end
endgenerate














endmodule