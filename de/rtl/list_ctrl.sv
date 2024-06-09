module list_ctrl 
            #(parameter lists_depth = 4,
              parameter index_lenth = 4
             )
            (
                input  logic clk,
                input  logic rst_n,
                
                // port0
                input  logic [index_lenth - 1 :0]          acc_index_0,
                output logic [2:0]                         acc_status_0,
                input  logic [1:0]                         acc_cmd_0,
                input  logic [$clog2(lists_depth) - 1 : 0] acc_tag_0,
                output logic [$clog2(lists_depth) - 1 : 0] return_tag_0,
                output logic [index_lenth         - 1 : 0] return_index_0,
                input  logic                               acc_req_0,

                output logic                               allocate_busy,


                // port1
                input  logic [index_lenth - 1 :0]          acc_index_1,
                output logic [2:0]                         acc_status_1,
                input  logic [1:0]                         acc_cmd_1,
                input  logic [$clog2(lists_depth) - 1 : 0] acc_tag_1,
                output logic [$clog2(lists_depth) - 1 : 0] return_tag_1,
                output logic [index_lenth         - 1 : 0] return_index_1,
                input  logic                               acc_req_1
            );

//variables
logic acc_hit_0, acc_hit_1;
logic proc_hit_0, proc_hit_1;
logic [$clog2(lists_depth) - 1 : 0] hit_tag_0;
logic [$clog2(lists_depth) - 1 : 0] hit_tag_1;
logic [$clog2(lists_depth) - 1 : 0] proc_tag_0;
logic [$clog2(lists_depth) - 1 : 0] proc_tag_1;
logic allocate_0, allocate_1;
logic tag0_is_head;
logic tag0_is_tail;
logic tag1_is_head;
logic tag1_is_tail;
logic tag0_tag1;
logic tag1_tag0;
logic hit_comflict;
typedef struct {
    logic [$clog2(lists_depth) - 1 : 0] head;
    logic [$clog2(lists_depth) - 1 : 0] tail;
    logic [$clog2(lists_depth)     : 0] length;
    logic                               empty;
} list_table_t;
list_table_t free_list, lru_list;

typedef struct {
    logic [$clog2(lists_depth) - 1 : 0] pre_tag;
    logic [$clog2(lists_depth) - 1 : 0] nxt_tag;
    logic [2:0]                         status;
    logic [index_lenth - 1 : 0]         index; 
} tag_table_t;

tag_table_t tag_table[lists_depth];

// status
// 3'b000 : invalid
// 3'b100 : in fetch proc
// 3'b001 : valid
// 3'b010 : dirty

//when allocate
// 3'b000 : allocate new line

always_comb begin
    if(!free_list.empty) begin
        allocate_busy = 1'b0;
    end else if(tag_table[lru_list.tail].status[2]) begin
        allocate_busy = 1'b1;
    end else if(acc_req_0 && acc_cmd_0 == 2'b00 && hit_tag_0 == lru_list.tail) begin
        allocate_busy = 1'b1;
    end else if(acc_req_0 && acc_cmd_0 == 2'b01 && hit_tag_0 == lru_list.tail) begin
        allocate_busy = 1'b1;
    end else if(acc_req_1 && acc_cmd_1 == 2'b00 && hit_tag_1 == lru_list.tail) begin
        allocate_busy = 1'b1;
    end else if(acc_req_1 && acc_cmd_1 == 2'b01 && hit_tag_1 == lru_list.tail) begin
        allocate_busy = 1'b1;
    end else begin
        allocate_busy = 1'b0;
    end
end

always_comb begin
    hit_tag_0 = 0;
    acc_hit_0 = 1'b0;
    for(integer i = 0; i < lists_depth; i++) begin
        if(tag_table[i].status != 3'b000 && tag_table[i].index == acc_index_0 && acc_req_0 &&
                                (acc_cmd_0 == 2'b01 || acc_cmd_0 == 2'b00)) begin
            hit_tag_0 = i;
            acc_hit_0 = 1'b1;
        end
    end
end



always_comb begin
    hit_tag_1 = 0;
    acc_hit_1 = 1'b0;
    for(integer i = 0; i < lists_depth; i++) begin
        if(tag_table[i].status != 3'b000 && tag_table[i].index == acc_index_1 && acc_req_1 &&
                                 (acc_cmd_1 == 2'b01 || acc_cmd_1 == 2'b00)) begin
            hit_tag_1 = i;
            acc_hit_1 = 1'b1;
        end
    end
end

assign proc_tag_0 = acc_hit_0 ? hit_tag_0 : return_tag_0;
assign proc_tag_1 = acc_hit_1 ? hit_tag_1 : return_tag_1;

assign proc_hit_0 = acc_hit_0 || ((acc_cmd_0 == 2'b10)&& acc_req_0 && free_list.empty);
assign proc_hit_1 = acc_hit_1 || ((acc_cmd_1 == 2'b10)&& acc_req_1 && (free_list.empty || (free_list.length <= 1 && allocate_0)));

assign allocate_0 = (acc_cmd_0 == 2'b10)&& acc_req_0 && !free_list.empty;
assign allocate_1 = (acc_cmd_1 == 2'b10)&& acc_req_1 && ((free_list.length > 1) || (!allocate_0 && !free_list.empty));


assign tag0_is_head = proc_tag_0 == lru_list.head && !lru_list.empty;
assign tag0_is_tail = proc_tag_0 == lru_list.tail && !lru_list.empty;

assign tag1_is_head = proc_tag_1 == lru_list.head && !lru_list.empty;
assign tag1_is_tail = proc_tag_1 == lru_list.tail && !lru_list.empty;

assign tag0_tag1 = (tag_table[proc_tag_0].nxt_tag == proc_tag_1) && (tag_table[proc_tag_1].pre_tag == proc_tag_0) && !tag1_is_head && !tag0_is_tail;
assign tag1_tag0 = (tag_table[proc_tag_1].nxt_tag == proc_tag_0) && (tag_table[proc_tag_0].pre_tag == proc_tag_1) && !tag0_is_head && !tag1_is_tail;

assign hit_comflict = hit_tag_0 == hit_tag_1;

always_comb begin
    return_tag_0 = 0;
    if(allocate_0) begin
        return_tag_0 = free_list.tail;
    end else if((acc_cmd_0 == 2'b10)&& acc_req_0 && free_list.empty) begin
        return_tag_0 = lru_list.tail;
    end else if(acc_req_0 && acc_cmd_0 == 2'b00 && acc_hit_0) begin
        return_tag_0 = hit_tag_0;
    end else if(acc_req_0 && acc_cmd_0 == 2'b01 && acc_hit_0) begin
        return_tag_0 = hit_tag_0;
    end
end


always_comb begin
    return_tag_1 = 0;
    if(allocate_1) begin
        if(allocate_0) begin
            return_tag_1 = tag_table[free_list.tail].pre_tag;
        end else begin
            return_tag_1 = free_list.tail;
        end
    end else if((acc_cmd_1 == 2'b10)&& acc_req_1 && free_list.empty) begin
        if((acc_cmd_0 == 2'b10)&& acc_req_0) begin
            return_tag_1 = tag_table[lru_list.tail].pre_tag;
        end else begin
            return_tag_1 = lru_list.tail;
        end
    end else if(acc_req_1 && acc_cmd_1 == 2'b00 && acc_hit_1) begin
        return_tag_1 = hit_tag_1;
    end else if(acc_req_1 && acc_cmd_1 == 2'b01 && acc_hit_1) begin
        return_tag_1 = hit_tag_1;
    end
end


always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        lru_list.head <= 0;
        lru_list.tail <= 0;
        lru_list.length <= 0;
        free_list.head <= 0;
        free_list.tail <= lists_depth - 1;
        free_list.length <= lists_depth;
    end else if(allocate_0 && allocate_1 && !lru_list.empty) begin
        lru_list.head <= return_tag_0;
        lru_list.length <= lru_list.length + 2;
        free_list.length <= free_list.length - 2;
        free_list.tail <= tag_table[return_tag_1].pre_tag;
    end else if(allocate_0 && allocate_1 && lru_list.empty) begin
        lru_list.head <= return_tag_0;
        lru_list.tail <= return_tag_1;
        lru_list.length <= lru_list.length + 2;
        free_list.length <= free_list.length - 2;
        free_list.tail <= tag_table[return_tag_1].pre_tag;
    end else if(allocate_0 && proc_hit_1) begin
        if(!tag1_is_head && tag1_is_tail) begin
            lru_list.head <= proc_tag_1;
            lru_list.tail <= tag_table[proc_tag_1].pre_tag;
            lru_list.length <= lru_list.length + 1;
            free_list.length <= free_list.length - 1;
            free_list.tail <= tag_table[return_tag_0].pre_tag;
        end else if(!tag1_is_head && !tag1_is_tail) begin
            lru_list.head <= proc_tag_1;
            lru_list.length <= lru_list.length + 1;
            free_list.length <= free_list.length - 1;
            free_list.tail <= tag_table[return_tag_0].pre_tag;
        end else if(tag1_is_head) begin
            lru_list.head <= proc_tag_0;
            lru_list.length <= lru_list.length + 1;
            free_list.tail <= tag_table[return_tag_0].pre_tag;
            free_list.length <= free_list.length - 1;
        end
    end else if(allocate_1 && proc_hit_0) begin
        if(!tag0_is_head && tag0_is_tail) begin
            lru_list.head <= proc_tag_0;
            lru_list.tail <= tag_table[proc_tag_0].pre_tag;
            lru_list.length <= lru_list.length + 1;
            free_list.length <= free_list.length - 1;
            free_list.tail <= tag_table[return_tag_1].pre_tag;
        end else if(!tag0_is_head && !tag0_is_tail) begin
            lru_list.head <= proc_tag_0;
            lru_list.length <= lru_list.length + 1;
            free_list.length <= free_list.length - 1;
            free_list.tail <= tag_table[return_tag_1].pre_tag;
        end else if(tag0_is_head) begin
            lru_list.head <= proc_tag_1;
            lru_list.length <= lru_list.length + 1;
            free_list.tail <= tag_table[return_tag_1].pre_tag;
            free_list.length <= free_list.length - 1;
        end
    end else if(proc_hit_0 && proc_hit_1 && !hit_comflict) begin
        if(tag0_tag1 && !tag0_is_head && !tag1_is_tail) begin
            lru_list.head <= proc_tag_0;
        end else if(tag0_tag1 && !tag0_is_head && tag1_is_tail) begin
            lru_list.head <= proc_tag_0;
            lru_list.tail <= tag_table[proc_tag_0].pre_tag;
        end else if (tag1_tag0 && !tag1_is_head && !tag0_is_tail) begin
            lru_list.head <= proc_tag_1;
        end else if (tag1_tag0 && !tag1_is_head && tag0_is_tail) begin
            lru_list.head <= proc_tag_1;
            lru_list.tail <= tag_table[proc_tag_1].pre_tag;
        end else if(!tag0_tag1 && !tag1_tag0) begin
            if(tag0_is_head && tag1_is_tail) begin
                lru_list.head <= proc_tag_1;
                lru_list.tail <= tag_table[proc_tag_1].pre_tag;
            end else if(tag1_is_head && tag0_is_tail) begin
                lru_list.head <= proc_tag_0;
                lru_list.tail <= tag_table[proc_tag_0].pre_tag;
            end else if(tag0_is_head && !tag1_is_tail) begin
                lru_list.head <= proc_tag_1;
            end else if(tag1_is_head && !tag0_is_tail) begin
                lru_list.head <= proc_tag_0;
            end else if(tag0_is_tail) begin
                lru_list.head <= proc_tag_0;
                lru_list.tail <= tag_table[proc_tag_0].pre_tag;
            end else if(tag1_is_tail) begin
                lru_list.head <= proc_tag_0;
                lru_list.tail <= tag_table[proc_tag_1].pre_tag;
            end else begin
                lru_list.head <= proc_tag_0;
            end
        end
    end else if(proc_hit_0 && proc_hit_1 && hit_comflict) begin
        if(!tag0_is_head && tag0_is_tail) begin
                lru_list.head <= proc_tag_0;
                lru_list.tail <= tag_table[proc_tag_0].pre_tag;
        end else if(!tag0_is_head) begin
                lru_list.head <= proc_tag_0;
        end
    end else if(proc_hit_0) begin
        if(!tag0_is_head && tag0_is_tail) begin
                lru_list.head <= proc_tag_0;
                lru_list.tail <= tag_table[proc_tag_0].pre_tag;
        end else if(!tag0_is_head) begin
                lru_list.head <= proc_tag_0;
        end
    end else if(proc_hit_1) begin
        if(!tag1_is_head && tag1_is_tail) begin
                lru_list.head <= proc_tag_1;
                lru_list.tail <= tag_table[proc_tag_1].pre_tag;
        end else if(!tag1_is_head) begin
                lru_list.head <= proc_tag_1;
        end
    end else if(allocate_0) begin
        free_list.length <= free_list.length - 1;
        free_list.tail <= tag_table[free_list.tail].pre_tag;
        if(!lru_list.empty) begin
            lru_list.head <= return_tag_0;
            lru_list.length <= lru_list.length + 1;
        end else begin
            lru_list.head <= return_tag_0;
            lru_list.tail <= return_tag_0;
            lru_list.length <= lru_list.length + 1;
        end
    end else if(allocate_1) begin
        free_list.length <= free_list.length - 1;
        free_list.tail <= tag_table[free_list.tail].pre_tag;
        if(!lru_list.empty) begin
            lru_list.head <= return_tag_1;
            lru_list.length <= lru_list.length + 1;
        end else begin
            lru_list.head <= return_tag_1;
            lru_list.tail <= return_tag_1;
            lru_list.length <= lru_list.length + 1;
        end
    end
end




always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
            for(integer i = 0; i < lists_depth; i++) begin
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
    end else if(allocate_0 && allocate_1 && !lru_list.empty) begin
        tag_table[return_tag_0].nxt_tag <= return_tag_1;
        tag_table[return_tag_1].pre_tag <= return_tag_0;
        tag_table[return_tag_1].nxt_tag <= lru_list.head;
        tag_table[lru_list.head].pre_tag <= return_tag_1;
    end else if(allocate_0 && allocate_1 && lru_list.empty) begin
        tag_table[return_tag_0].nxt_tag <= return_tag_1;
        tag_table[return_tag_1].pre_tag <= return_tag_0;
    end else if(allocate_0 && proc_hit_1) begin
        if(!tag1_is_head && tag1_is_tail) begin
            tag_table[return_tag_0].nxt_tag <= lru_list.head;
            tag_table[return_tag_0].pre_tag <= proc_tag_1;
            tag_table[lru_list.head].pre_tag <= return_tag_0;
            tag_table[proc_tag_1].nxt_tag <= return_tag_0;
        end else if(!tag1_is_head && !tag1_is_tail) begin
            tag_table[return_tag_0].nxt_tag <= lru_list.head;
            tag_table[return_tag_0].pre_tag <= proc_tag_1;
            tag_table[lru_list.head].pre_tag <= return_tag_0;
            tag_table[proc_tag_1].nxt_tag <= return_tag_0;
            tag_table[tag_table[proc_tag_1].pre_tag].nxt_tag <= tag_table[proc_tag_1].nxt_tag;
            tag_table[tag_table[proc_tag_1].nxt_tag].pre_tag <= tag_table[proc_tag_1].pre_tag;
        end else if(tag1_is_head) begin
            tag_table[proc_tag_1].pre_tag <= return_tag_0;
            tag_table[return_tag_0].nxt_tag <= proc_tag_1;
        end
    end else if(allocate_1 && proc_hit_0) begin
        if(!tag0_is_head && tag0_is_tail) begin
            tag_table[return_tag_1].nxt_tag <= lru_list.head;
            tag_table[return_tag_1].pre_tag <= proc_tag_0;
            tag_table[lru_list.head].pre_tag <= return_tag_1;
            tag_table[proc_tag_0].nxt_tag <= return_tag_1;
        end else if(!tag0_is_head && !tag0_is_tail) begin
            tag_table[return_tag_1].nxt_tag <= lru_list.head;
            tag_table[return_tag_1].pre_tag <= proc_tag_0;
            tag_table[lru_list.head].pre_tag <= return_tag_1;
            tag_table[proc_tag_0].nxt_tag <= return_tag_1;
            tag_table[tag_table[proc_tag_0].pre_tag].nxt_tag <= tag_table[proc_tag_0].nxt_tag;
            tag_table[tag_table[proc_tag_0].nxt_tag].pre_tag <= tag_table[proc_tag_0].pre_tag;
        end else if(tag0_is_head) begin
            tag_table[proc_tag_0].pre_tag <= return_tag_1;
            tag_table[return_tag_1].nxt_tag <= proc_tag_0;
        end
    end else if(proc_hit_0 && proc_hit_1 && !hit_comflict) begin
        if(tag0_tag1 && !tag0_is_head && !tag1_is_tail) begin
            tag_table[tag_table[proc_tag_0].pre_tag].nxt_tag <= tag_table[proc_tag_1].nxt_tag;
            tag_table[tag_table[proc_tag_1].nxt_tag].pre_tag <= tag_table[proc_tag_0].pre_tag;
            tag_table[proc_tag_1].nxt_tag <= lru_list.head;
            tag_table[lru_list.head].pre_tag <= proc_tag_1;
        end else if(tag0_tag1 && !tag0_is_head && tag1_is_tail) begin
            tag_table[proc_tag_1].nxt_tag <= lru_list.head;
            tag_table[lru_list.head].pre_tag <= proc_tag_1;
            tag_table[proc_tag_1].nxt_tag <= lru_list.head;
        end else if (tag1_tag0 && !tag1_is_head && !tag0_is_tail) begin
            tag_table[tag_table[proc_tag_1].pre_tag].nxt_tag <= tag_table[proc_tag_0].nxt_tag;
            tag_table[tag_table[proc_tag_0].nxt_tag].pre_tag <= tag_table[proc_tag_1].pre_tag;
            tag_table[proc_tag_0].nxt_tag <= lru_list.head;
            tag_table[lru_list.head].pre_tag <= proc_tag_0;
        end else if (tag1_tag0 && !tag1_is_head && tag0_is_tail) begin
            tag_table[proc_tag_0].nxt_tag <= lru_list.head;
            tag_table[lru_list.head].pre_tag <= proc_tag_0;
            tag_table[proc_tag_0].nxt_tag <= lru_list.head;
        end else if(!tag0_tag1 && !tag1_tag0) begin
            if(tag0_is_head && tag1_is_tail) begin
                tag_table[proc_tag_0].pre_tag <= proc_tag_1;
                tag_table[proc_tag_1].nxt_tag <= proc_tag_0;
            end else if(tag1_is_head && tag0_is_tail) begin
                tag_table[proc_tag_1].pre_tag <= proc_tag_0;
                tag_table[proc_tag_0].nxt_tag <= proc_tag_1;
            end else if(tag0_is_head && !tag1_is_tail) begin
                tag_table[proc_tag_0].pre_tag <= proc_tag_1;
                tag_table[proc_tag_1].nxt_tag <= proc_tag_0;
                tag_table[tag_table[proc_tag_1].pre_tag].nxt_tag <= tag_table[proc_tag_1].nxt_tag;
                tag_table[tag_table[proc_tag_1].nxt_tag].pre_tag <= tag_table[proc_tag_1].pre_tag;
            end else if(tag1_is_head && !tag0_is_tail) begin
                tag_table[proc_tag_1].pre_tag <= proc_tag_0;
                tag_table[proc_tag_0].nxt_tag <= proc_tag_1;
                tag_table[tag_table[proc_tag_0].pre_tag].nxt_tag <= tag_table[proc_tag_0].nxt_tag;
                tag_table[tag_table[proc_tag_0].nxt_tag].pre_tag <= tag_table[proc_tag_0].pre_tag;
            end else if(tag0_is_tail) begin
                tag_table[proc_tag_0].nxt_tag     <= proc_tag_1;
                tag_table[proc_tag_1].pre_tag     <= proc_tag_0;
                tag_table[proc_tag_1].nxt_tag     <= lru_list.head;
                tag_table[lru_list.head].pre_tag <= proc_tag_1;
                tag_table[tag_table[proc_tag_1].pre_tag].nxt_tag <= tag_table[proc_tag_1].nxt_tag;
                tag_table[tag_table[proc_tag_1].nxt_tag].pre_tag <= tag_table[proc_tag_1].pre_tag;
            end else if(tag1_is_tail) begin
                tag_table[proc_tag_0].nxt_tag     <= proc_tag_1;
                tag_table[proc_tag_1].pre_tag     <= proc_tag_0;
                tag_table[proc_tag_1].nxt_tag     <= lru_list.head;
                tag_table[lru_list.head].pre_tag <= proc_tag_1;
                tag_table[tag_table[proc_tag_0].pre_tag].nxt_tag <= tag_table[proc_tag_0].nxt_tag;
                tag_table[tag_table[proc_tag_0].nxt_tag].pre_tag <= tag_table[proc_tag_0].pre_tag;
            end else begin
                tag_table[proc_tag_0].nxt_tag     <= proc_tag_1;
                tag_table[proc_tag_1].pre_tag     <= proc_tag_0;
                tag_table[proc_tag_1].nxt_tag     <= lru_list.head;
                tag_table[lru_list.head].pre_tag <= proc_tag_1;
                tag_table[tag_table[proc_tag_0].pre_tag].nxt_tag <= tag_table[proc_tag_0].nxt_tag;
                tag_table[tag_table[proc_tag_0].nxt_tag].pre_tag <= tag_table[proc_tag_0].pre_tag;
                tag_table[tag_table[proc_tag_1].pre_tag].nxt_tag <= tag_table[proc_tag_1].nxt_tag;
                tag_table[tag_table[proc_tag_1].nxt_tag].pre_tag <= tag_table[proc_tag_1].pre_tag;
            end
        end
    end else if(proc_hit_0 && proc_hit_1 && hit_comflict) begin
        if(!tag0_is_head && tag0_is_tail) begin
                tag_table[proc_tag_0].nxt_tag <= lru_list.head;
                tag_table[lru_list.head].pre_tag <= proc_tag_0;
        end else if(!tag0_is_head) begin
                tag_table[proc_tag_0].nxt_tag <= lru_list.head;
                tag_table[lru_list.head].pre_tag <= proc_tag_0;
                tag_table[tag_table[proc_tag_0].pre_tag].nxt_tag <= tag_table[proc_tag_0].nxt_tag;
                tag_table[tag_table[proc_tag_0].nxt_tag].pre_tag <= tag_table[proc_tag_0].pre_tag;
        end
    end else if(proc_hit_0) begin
        if(!tag0_is_head && tag0_is_tail) begin
                tag_table[proc_tag_0].nxt_tag <= lru_list.head;
                tag_table[lru_list.head].pre_tag <= proc_tag_0;
        end else if(!tag0_is_head) begin
                tag_table[proc_tag_0].nxt_tag <= lru_list.head;
                tag_table[lru_list.head].pre_tag <= proc_tag_0;
                tag_table[tag_table[proc_tag_0].pre_tag].nxt_tag <= tag_table[proc_tag_0].nxt_tag;
                tag_table[tag_table[proc_tag_0].nxt_tag].pre_tag <= tag_table[proc_tag_0].pre_tag;
        end
    end else if(proc_hit_1) begin
        if(!tag1_is_head && tag1_is_tail) begin
                tag_table[proc_tag_1].nxt_tag <= lru_list.head;
                tag_table[lru_list.head].pre_tag <= proc_tag_1;
        end else if(!tag1_is_head) begin
                tag_table[proc_tag_1].nxt_tag <= lru_list.head;
                tag_table[lru_list.head].pre_tag <= proc_tag_1;
                tag_table[tag_table[proc_tag_1].pre_tag].nxt_tag <= tag_table[proc_tag_1].nxt_tag;
                tag_table[tag_table[proc_tag_1].nxt_tag].pre_tag <= tag_table[proc_tag_1].pre_tag;
        end
    end else if(allocate_0) begin
        if(!lru_list.empty) begin
            tag_table[return_tag_0].nxt_tag <= lru_list.head;
            tag_table[lru_list.head].pre_tag <= return_tag_0;
        end
    end else if(allocate_1) begin
        if(!lru_list.empty) begin
            tag_table[return_tag_1].nxt_tag <= lru_list.head;
            tag_table[lru_list.head].pre_tag <= return_tag_1;
        end
    end
end

assign lru_list.empty  = lru_list.length  == 0;
assign free_list.empty = free_list.length == 0;

generate
    for(genvar i = 0; i < lists_depth; i++) begin:tag_table_grp
        always_ff@(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                tag_table[i].status <= 3'b000;
                tag_table[i].index <= 0;
            end else if(allocate_0 && return_tag_0 == i) begin
                tag_table[i].status <= 3'b100;
                tag_table[i].index <= acc_index_0;
            end else if(acc_req_0 && acc_cmd_0 == 2'b10 && return_tag_0 == i) begin
                tag_table[i].status <= 3'b100;
                tag_table[i].index <= acc_index_0;
            end else if(allocate_1 && return_tag_1 == i) begin
                tag_table[i].status <= 3'b100;
                tag_table[i].index <= acc_index_1;
            end else if(acc_req_1 && acc_cmd_1 == 2'b10 && return_tag_1 == i) begin
                tag_table[i].status <= 3'b100;
                tag_table[i].index <= acc_index_1;
            end else if(acc_req_0 && acc_tag_0 == i && acc_cmd_0 == 2'b11) begin
                tag_table[i].status <= 3'b010;
            end else if(acc_req_0 && return_tag_0 == i && acc_hit_0 && acc_cmd_0 == 2'b00 && tag_table[i].status!= 3'b100) begin
                tag_table[i].status <= 3'b010;
            end else if(acc_req_1 && return_tag_1 == i && acc_hit_1 && acc_cmd_1 == 2'b00 && tag_table[i].status!= 3'b100) begin
                tag_table[i].status <= 3'b010;
            end else if(acc_req_1 && acc_tag_1 == i && acc_cmd_1 == 2'b11) begin
                tag_table[i].status <= 3'b001;
            end
        end
    end
endgenerate


always_comb begin
    acc_status_0 = 2'b00;
    return_index_0 = 0;
    if((acc_cmd_0 == 2'b00 || acc_cmd_0 == 2'b01) && acc_hit_0) begin
        acc_status_0 = tag_table[hit_tag_0].status;
        return_index_0 = tag_table[hit_tag_0].index;
    end else if(acc_cmd_0 == 2'b10 && acc_req_0) begin
        acc_status_0 = tag_table[return_tag_0].status;
        return_index_0 = tag_table[return_tag_0].index;
    end
end

always_comb begin
    acc_status_1 = 2'b00;
    return_index_1 = 0;
    if((acc_cmd_1 == 2'b00 || acc_cmd_1 == 2'b01) && acc_hit_1) begin
        acc_status_1 = tag_table[hit_tag_1].status;
        return_index_1 = tag_table[hit_tag_1].index;
    end else if(acc_cmd_1 == 2'b10 && acc_req_1) begin
        acc_status_1 = tag_table[return_tag_1].status;
        return_index_1 = tag_table[return_tag_1].index;
    end
end



int lru_temp;
logic lru_check;
initial begin
    forever begin
        @(posedge clk);
            lru_check = 0;
            lru_temp = lru_list.head;
            lru_check = 1;
        for(int i = 0; i < lists_depth; i++) begin
            lru_temp = tag_table[lru_temp].nxt_tag;
            if(lru_temp == lru_list.tail && (i == lru_list.length - 2)) begin
                lru_check = 0;
                break;
            end
        end
        if(lru_list.length < 2) begin
            lru_check = 0;
        end
    end
end


int lru_temp_rev;
logic lru_check_rev;
initial begin
    forever begin
        @(posedge clk);
            lru_check_rev = 0;
            lru_temp_rev = lru_list.tail;
            lru_check_rev = 1;
        for(int i = 0; i < lists_depth; i++) begin
            lru_temp_rev = tag_table[lru_temp_rev].pre_tag;
            if(lru_temp_rev == lru_list.head && (i == lru_list.length - 2)) begin
                lru_check_rev = 0;
                break;
            end
        end
        if(lru_list.length < 2) begin
            lru_check_rev = 0;
        end
    end
end



int free_temp;
logic free_check;
initial begin
    forever begin
        @(posedge clk);
            free_check = 0;
            free_temp = free_list.head;
            free_check = 1;
        for(int i = 0; i < lists_depth; i++) begin
            free_temp = tag_table[free_temp].nxt_tag;
            if(free_temp == free_list.tail && (i == free_list.length - 2)) begin
                free_check = 0;
                break;
            end
        end
        if(free_list.length < 2) begin
            free_check = 0;
        end
    end
end


int free_temp_rev;
logic free_check_rev;
initial begin
    forever begin
        @(posedge clk);
            free_check_rev = 0;
            free_temp_rev = free_list.tail;
            free_check_rev = 1;
        for(int i = 0; i < lists_depth; i++) begin
            free_temp_rev = tag_table[free_temp_rev].pre_tag;
            if(free_temp_rev == free_list.head && (i == free_list.length - 2)) begin
                free_check_rev = 0;
                break;
            end
        end
        if(free_list.length < 2) begin
            free_check_rev = 0;
        end
    end
end




endmodule