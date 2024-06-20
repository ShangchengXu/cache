module cache_ctrl #(
       parameter data_width = 32,
       parameter cache_num = 2,
       parameter cache_id = 0,
       parameter addr_width = 32,
       parameter list_depth = 4,
       parameter id_width = $clog2(cache_num) == 0 ? 1 : $clog2(cache_num),
       parameter list_width = 32)
          (
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic                      acc_rd_valid,
    output logic                      acc_rd_ready,
    input  logic [addr_width - 1 : 0] acc_rd_addr,
    output logic [data_width - 1 : 0] acc_rd_data,
    output logic                      acc_rd_data_valid,
    output logic                      acc_rd_done,
    input  logic                      acc_wr_valid,
    output logic                      acc_wr_ready,
    input  logic [addr_width - 1 : 0] acc_wr_addr,
    input  logic [data_width - 1 : 0] acc_wr_data,
    output logic                      acc_wr_done,
    output logic                      wr_req,
    input  logic                      wr_gnt,
    output logic [15:0]               wr_len,
    output logic [addr_width - 1 : 0] wr_addr,
    output logic [data_width - 1 : 0] wr_data,
    output logic                      wr_last,
    input  logic                      wr_done,
    output logic                      wr_valid,
    input  logic                      wr_ready,
    output logic                      rd_req,
    input  logic                      rd_gnt,
    output logic [15:0]               rd_len,
    output logic [addr_width - 1 : 0] rd_addr,
    input  logic [data_width - 1 : 0] rd_data,
    input  logic                      rd_done,
    input  logic                      rd_valid,
    output logic                                         msg_req,
    input  logic                                         msg_gnt,
    output logic [4 + 2 * id_width + addr_width - 1 : 0] msg,
    input  logic                                         msg_in_valid,
    input  logic [4 + 2 * id_width + addr_width - 1 : 0] msg_in,
    output logic                      rd_ready);


logic [addr_width - 1 :0]                 acc_index_2;
logic [2:0]                               acc_status_2;
logic [2:0]                               acc_cmd_2;
logic [$clog2(list_depth) - 1 : 0]        acc_tag_2;
logic [$clog2(list_depth) - 1 : 0]        return_tag_2;
logic [addr_width - 1 :0]                 return_index_2;
logic                                     acc_req_2;
logic                                     acc_gnt_2;


logic                                     msg_req_0;
logic [3:0]                               msg_0;
logic [addr_width - 1 :0]                 msg_index_0;
logic [3:0]                               msg_rsp_0;
logic                                     msg_valid_0;
logic                                     msg_gnt_0;

logic                                     msg_req_1;
logic [3:0]                               msg_1;
logic [addr_width - 1 :0]                 msg_index_1;
logic [3:0]                               msg_rsp_1;
logic                                     msg_valid_1;
logic                                     msg_gnt_1;



logic [addr_width - 1 :0]                               acc_index_1           ;
logic [2:0]                                             acc_status_1          ;
logic [2:0]                                             acc_cmd_1             ;
logic [$clog2(list_depth) - 1 : 0]                      acc_tag_1             ;
logic [$clog2(list_depth) - 1 : 0]                      return_tag_1          ;
logic [addr_width - 1 :0]                               return_index_1        ;
logic                                                   acc_req_1             ;
logic                                                   acc_gnt_1             ;
logic                                                   acc_gnt_0             ;
logic [$clog2(list_depth) + $clog2(list_width) - 1 : 0] mem_raddr             ;
logic                                                   mem_ren               ;
logic                                                   mem_rready            ;
logic [data_width - 1 : 0]                              mem_rdata             ;
logic                                                   mem_rdata_valid       ;
logic [addr_width - 1 :0]                               acc_index_0           ;
logic [2:0]                                             acc_status_0          ;
logic [2:0]                                             acc_cmd_0             ;
logic [$clog2(list_depth) - 1 : 0]                      acc_tag_0             ;
logic [$clog2(list_depth) - 1 : 0]                      return_tag_0          ;
logic [addr_width - 1 :0]                               return_index_0        ;
logic                                                   acc_req_0             ;
logic [2:0]                                             proc_status_w         ;
logic [addr_width - 1 : 0]                              proc_addr_w           ;
logic [$clog2(list_depth) - 1 : 0]                      proc_tag_w            ;
logic [2:0]                                             proc_status_r         ;
logic [addr_width - 1 : 0]                              proc_addr_r           ;
logic [$clog2(list_depth) - 1 : 0]                      proc_tag_r            ;
logic [$clog2(list_depth) + $clog2(list_width) - 1 : 0] mem_waddr             ;
logic                                                   mem_wen               ;
logic                                                   mem_wready            ;
logic [data_width - 1 : 0]                              mem_wdata             ;
logic [1:0]                                             fetch_cmd_w           ;
logic                                                   fetch_req_w           ;
logic [$clog2(list_depth) - 1 : 0]                      fetch_tag_w           ;
logic [addr_width - 1 : 0]                              fetch_addr_w          ;
logic                                                   fetch_gnt_w           ;
logic                                                   fetch_done_w          ;
logic [1:0]                                             fetch_cmd_r           ;
logic                                                   fetch_req_r           ;
logic [$clog2(list_depth) - 1 : 0]                      fetch_tag_r           ;
logic [addr_width - 1 : 0]                              fetch_addr_r          ;
logic                                                   fetch_gnt_r           ;
logic                                                   fetch_done_r          ;



logic [1:0]                                             fetch_cmd_m           ;
logic                                                   fetch_req_m           ;
logic [$clog2(list_depth) - 1 : 0]                      fetch_tag_m           ;
logic [addr_width - 1 : 0]                              fetch_addr_m          ;
logic                                                   fetch_gnt_m           ;
logic                                                   fetch_done_m          ;

logic [$clog2(list_depth * list_width) - 1 : 0]         fetch_mem_raddr       ;
logic                                                   fetch_mem_ren         ;
logic                                                   fetch_mem_rready      ;
logic [data_width - 1 : 0]                              fetch_mem_rdata       ;
logic                                                   fetch_mem_rdata_valid ;
logic [$clog2(list_depth * list_width) - 1 : 0]         fetch_mem_waddr       ;
logic                                                   fetch_mem_wen         ;
logic                                                   fetch_mem_wready      ;
logic [data_width - 1 : 0]                              fetch_mem_wdata       ;
logic  [1:0]                                            mem_rpri              ;
logic  [1:0]                                            mem_wpri              ;

list_ctrl #(
        .list_depth     (list_depth     ),
        .index_lenth     (addr_width      ))
          list_ctrl_inst (
        .clk             (clk             ) ,//input   
        .rst_n           (rst_n           ) ,//input   
        .acc_index_2     (acc_index_2     ) ,//input   [index_lenth - 1 :0]
        .acc_status_2    (acc_status_2    ) ,//output  [2:0]
        .acc_cmd_2       (acc_cmd_2       ) ,//input   [2:0]
        .acc_tag_2       (acc_tag_2       ) ,//input   [$clog2(list_depth) - 1 : 0]
        .return_tag_2    (return_tag_2    ) ,//output  [$clog2(list_depth) - 1 : 0]
        .return_index_2  (return_index_2  ) ,//output  [index_lenth         - 1 : 0]
        .acc_req_2       (acc_req_2       ) ,//input   
        .acc_gnt_2       (acc_gnt_2       ) ,//output
        .acc_index_0     (acc_index_0     ) ,//input   [index_lenth - 1 :0]
        .acc_status_0    (acc_status_0    ) ,//output  [2:0]
        .acc_cmd_0       (acc_cmd_0       ) ,//input   [2:0]
        .acc_tag_0       (acc_tag_0       ) ,//input   [$clog2(list_depth) - 1 : 0]
        .return_tag_0    (return_tag_0    ) ,//output  [$clog2(list_depth) - 1 : 0]
        .return_index_0  (return_index_0  ) ,//output  [index_lenth         - 1 : 0]
        .acc_req_0       (acc_req_0       ) ,//input   
        .acc_gnt_0       (acc_gnt_0       ) ,//output
        .acc_index_1     (acc_index_1     ) ,//input   [index_lenth - 1 :0]
        .acc_status_1    (acc_status_1    ) ,//output  [2:0]
        .acc_cmd_1       (acc_cmd_1       ) ,//input   [2:0]
        .acc_tag_1       (acc_tag_1       ) ,//input   [$clog2(list_depth) - 1 : 0]
        .return_tag_1    (return_tag_1    ) ,//output  [$clog2(list_depth) - 1 : 0]
        .return_index_1  (return_index_1  ) ,//output  [index_lenth         - 1 : 0]
        .acc_gnt_1       (acc_gnt_1       ) ,//output
        .acc_req_1       (acc_req_1       ));//input   

mem_ctrl #(
        .mem_depth              (list_width * list_depth),
        .data_width             (data_width             ))
         mem_ctrl_inst (
        .clk                    (clk                    ) ,//input   
        .rst_n                  (rst_n                  ) ,//input   
        .mem_raddr              (mem_raddr              ) ,//input   [$clog2(mem_depth) - 1 : 0]
        .mem_ren                (mem_ren                ) ,//input   
        .mem_rready             (mem_rready             ) ,//output  
        .mem_rdata              (mem_rdata              ) ,//output  [data_width - 1 : 0]
        .mem_rdata_valid        (mem_rdata_valid        ) ,//output  
        .mem_waddr              (mem_waddr              ) ,//input   [$clog2(mem_depth) - 1 : 0]
        .mem_wen                (mem_wen                ) ,//input   
        .mem_wready             (mem_wready             ) ,//output  
        .mem_wdata              (mem_wdata              ) ,//input   [data_width - 1 : 0]
        .mem_rpri               (mem_rpri               ) ,
        .mem_wpri               (mem_wpri               ) ,
        .fetch_mem_raddr        (fetch_mem_raddr        ) ,//input   [$clog2(mem_depth) - 1 : 0]
        .fetch_mem_ren          (fetch_mem_ren          ) ,//input   
        .fetch_mem_rready       (fetch_mem_rready       ) ,//output  
        .fetch_mem_rdata        (fetch_mem_rdata        ) ,//output  [data_width - 1 : 0]
        .fetch_mem_rdata_valid  (fetch_mem_rdata_valid  ) ,//output  
        .fetch_mem_waddr        (fetch_mem_waddr        ) ,//input   [$clog2(mem_depth) - 1 : 0]
        .fetch_mem_wen          (fetch_mem_wen          ) ,//input   
        .fetch_mem_wready       (fetch_mem_wready       ) ,//output  
        .fetch_mem_wdata        (fetch_mem_wdata        ));//input   [data_width - 1 : 0]

rd_ctrl #(
        .addr_width         (addr_width         ),
        .list_depth         (list_depth         ),
        .data_width         (data_width         ),
        .list_width         (list_width         ))
        rd_ctrl_inst (
        .clk                (clk                ) ,//input   
        .rst_n              (rst_n              ) ,//input   
        .acc_rd_valid       (acc_rd_valid       ) ,//input   
        .acc_rd_ready       (acc_rd_ready       ) ,//output  
        .acc_rd_addr        (acc_rd_addr        ) ,//input   [addr_width - 1 : 0]
        .acc_rd_data        (acc_rd_data        ) ,//output  [data_width - 1 : 0]
        .acc_rd_done        (acc_rd_done        ) ,
        .mem_rpri           (mem_rpri           ) ,
        .acc_rd_data_valid  (acc_rd_data_valid  ) ,//output  
        .acc_index          (acc_index_1        ) ,//output  [addr_width - 1 :0]
        .acc_status         (acc_status_1       ) ,//input   [2:0]
        .acc_cmd            (acc_cmd_1          ) ,//output  [2:0]
        .acc_tag            (acc_tag_1          ) ,//output  [$clog2(list_depth) - 1 : 0]
        .return_tag         (return_tag_1       ) ,//input   [$clog2(list_depth) - 1 : 0]
        .return_index       (return_index_1     ) ,//input   [addr_width - 1 :0]
        .acc_req            (acc_req_1          ) ,//output  
        .acc_gnt            (acc_gnt_1          ) ,//input
        .proc_status_r      (proc_status_r      ) ,//output  [2:0]
        .proc_addr_r        (proc_addr_r        ) ,//output  [addr_width - 1 : 0]
        .proc_tag_r         (proc_tag_r         ) ,//output  [$ - 1 : 0]
        .proc_tag_w         (proc_tag_w         ) ,//output  [$ - 1 : 0]
        .proc_status_w      (proc_status_w      ) ,//input   [2:0]
        .proc_addr_w        (proc_addr_w        ) ,//input   [addr_width - 1 : 0]
        .fetch_cmd          (fetch_cmd_r        ) ,//output  [1:0]
        .fetch_req          (fetch_req_r        ) ,//output  
        .fetch_tag          (fetch_tag_r        ) ,//output  [$clog2(list_depth) - 1 : 0]
        .fetch_addr         (fetch_addr_r       ) ,//output  [addr_width - 1 : 0]
        .fetch_gnt          (fetch_gnt_r        ) ,//input   
        .fetch_done         (fetch_done_r       ) ,//input   
        .msg_req            (msg_req_1          ) , 
        .msg                (msg_1              ) , 
        .msg_index          (msg_index_1        ) , 
        .msg_rsp            (msg_rsp_1          ) , 
        .msg_valid          (msg_valid_1        ) , 
        .msg_gnt            (msg_gnt_1          ) , 

        .mem_raddr          (mem_raddr          ) ,//output  [$clog2(list_depth) + $clog2(list_width) - 1 : 0]
        .mem_ren            (mem_ren            ) ,//output  
        .mem_rready         (mem_rready         ) ,//input   
        .mem_rdata          (mem_rdata          ) ,//input   [data_width - 1 : 0]
        .mem_rdata_valid    (mem_rdata_valid    ));//input   

wr_ctrl #(
        .addr_width      (addr_width      ),
        .list_depth      (list_depth      ),
        .data_width      (data_width      ),
        .list_width      (list_width      ))
        wr_ctrl_inst (
        .clk             (clk               ) ,//input   
        .rst_n           (rst_n             ) ,//input   
        .acc_wr_valid    (acc_wr_valid      ) ,//input   
        .acc_wr_ready    (acc_wr_ready      ) ,//output  
        .acc_wr_addr     (acc_wr_addr       ) ,//input   [addr_width - 1 : 0]
        .acc_wr_data     (acc_wr_data       ) ,//input   [data_width - 1 : 0]
        .acc_index       (acc_index_0       ) ,//output  [addr_width - 1 :0]
        .acc_status      (acc_status_0      ) ,//input   [2:0]
        .mem_wpri        (mem_wpri          ) ,
        .acc_cmd         (acc_cmd_0         ) ,//output  [2:0]
        .acc_tag         (acc_tag_0         ) ,//output  [$clog2(list_depth) - 1 : 0]
        .return_tag      (return_tag_0      ) ,//input   [$clog2(list_depth) - 1 : 0]
        .acc_wr_done     (acc_wr_done       ) ,
        .return_index    (return_index_0    ) ,//input   [addr_width - 1 :0]
        .acc_req         (acc_req_0         ) ,//output  
        .acc_gnt         (acc_gnt_0         ) ,//input
        .proc_status_w   (proc_status_w     ) ,//output  [2:0]
        .proc_addr_w     (proc_addr_w       ) ,//output  [addr_width - 1 : 0]
        .proc_status_r   (proc_status_r     ) ,//input   [2:0]
        .proc_tag_r      (proc_tag_r        ) ,//output  [$ - 1 : 0]
        .proc_tag_w      (proc_tag_w        ) ,//output  [$ - 1 : 0]
        .proc_addr_r     (proc_addr_r       ) ,//input   [addr_width - 1 : 0]
        .msg_req         (msg_req_0         ) , 
        .msg             (msg_0             ) , 
        .msg_index       (msg_index_0       ) , 
        .msg_rsp         (msg_rsp_0         ) , 
        .msg_valid       (msg_valid_0       ) , 
        .msg_gnt         (msg_gnt_0         ) , 
        .fetch_cmd       (fetch_cmd_w       ) ,//output  [1:0]
        .fetch_req       (fetch_req_w       ) ,//output  
        .fetch_tag       (fetch_tag_w       ) ,//output  [$clog2(list_depth) - 1 : 0]
        .fetch_addr      (fetch_addr_w      ) ,//output  [addr_width - 1 : 0]
        .fetch_gnt       (fetch_gnt_w       ) ,//input   
        .fetch_done      (fetch_done_w      ) ,//input   
        .mem_waddr       (mem_waddr         ) ,//output  [$clog2(list_depth) + $clog2(list_width) - 1 : 0]
        .mem_wen         (mem_wen           ) ,//output  
        .mem_wready      (mem_wready        ) ,//input   
        .mem_wdata       (mem_wdata         ));//output  [data_width - 1 : 0]
fetch_ctrl #(
        .addr_width             (addr_width             ),
        .list_depth             (list_depth             ),
        .data_width             (data_width             ),
        .list_width             (list_width             ))
           fetch_ctrl_inst (
        .clk                    (clk                    ) ,//input   
        .rst_n                  (rst_n                  ) ,//input   
        .fetch_cmd_0            (fetch_cmd_w            ) ,//input   [1:0]
        .fetch_req_0            (fetch_req_w            ) ,//input   
        .fetch_tag_0            (fetch_tag_w            ) ,//input   [$clog2(list_depth) - 1 : 0]
        .fetch_addr_0           (fetch_addr_w           ) ,//input   [addr_width - 1 : 0]
        .fetch_gnt_0            (fetch_gnt_w            ) ,//output  
        .fetch_done_0           (fetch_done_w           ) ,//output  
        .fetch_cmd_1            (fetch_cmd_r            ) ,//input   [1:0]
        .fetch_req_1            (fetch_req_r            ) ,//input   
        .fetch_tag_1            (fetch_tag_r            ) ,//input   [$clog2(list_depth) - 1 : 0]
        .fetch_addr_1           (fetch_addr_r           ) ,//input   [addr_width - 1 : 0]
        .fetch_gnt_1            (fetch_gnt_r            ) ,//output  
        .fetch_done_1           (fetch_done_r           ) ,//output  
        .fetch_cmd_2            (fetch_cmd_m            ) ,//input   [1:0]
        .fetch_req_2            (fetch_req_m            ) ,//input   
        .fetch_tag_2            (fetch_tag_m            ) ,//input   [$clog2(list_depth) - 1 : 0]
        .fetch_addr_2           (fetch_addr_m           ) ,//input   [addr_width - 1 : 0]
        .fetch_gnt_2            (fetch_gnt_m            ) ,//output  
        .fetch_done_2           (fetch_done_m           ) ,//output  
        .fetch_mem_raddr        (fetch_mem_raddr        ) ,//output  [$clog2(mem_depth) - 1 : 0]
        .fetch_mem_ren          (fetch_mem_ren          ) ,//output  
        .fetch_mem_rready       (fetch_mem_rready       ) ,//input   
        .fetch_mem_rdata        (fetch_mem_rdata        ) ,//input   [data_width - 1 : 0]
        .fetch_mem_rdata_valid  (fetch_mem_rdata_valid  ) ,//input   
        .fetch_mem_waddr        (fetch_mem_waddr        ) ,//output  [$clog2(mem_depth) - 1 : 0]
        .fetch_mem_wen          (fetch_mem_wen          ) ,//output  
        .fetch_mem_wready       (fetch_mem_wready       ) ,//input   
        .fetch_mem_wdata        (fetch_mem_wdata        ) ,//output  [data_width - 1 : 0]
        .wr_req                 (wr_req                 ) ,//output  
        .wr_gnt                 (wr_gnt                 ) ,//input   
        .wr_len                 (wr_len                 ) ,//output  [15:0]
        .wr_addr                (wr_addr                ) ,//output  [addr_width - 1 : 0]
        .wr_data                (wr_data                ) ,//output  [data_width - 1 : 0]
        .wr_last                (wr_last                ) ,//output  
        .wr_done                (wr_done                ) ,//input  
        .wr_valid               (wr_valid               ) ,//output  
        .wr_ready               (wr_ready               ) ,//input   
        .rd_req                 (rd_req                 ) ,//output  
        .rd_gnt                 (rd_gnt                 ) ,//input   
        .rd_len                 (rd_len                 ) ,//output  [15:0]
        .rd_addr                (rd_addr                ) ,//output  [addr_width - 1 : 0]
        .rd_data                (rd_data                ) ,//input   [data_width - 1 : 0]
        .rd_done                (rd_done                ) ,//input   
        .rd_valid               (rd_valid               ) ,//input   
        .rd_ready               (rd_ready               ));//output  

msg_ctrl #(
        .cache_id      (cache_id      ),
        .cache_num     (cache_num     ),
        .addr_width    (addr_width    ),
        .list_depth    (list_depth    ),
        .data_width    (data_width    ),
        .list_width    (list_width    ))
         msg_ctrl (
        .clk           (clk           ) ,//input   
        .rst_n         (rst_n         ) ,//input   
        .acc_index     (acc_index_2   ) ,//output  [addr_width - 1 :0]
        .acc_status    (acc_status_2  ) ,//input   [2:0]
        .acc_cmd       (acc_cmd_2     ) ,//output  [2:0]
        .acc_tag       (acc_tag_2     ) ,//output  [$clog2(list_depth) - 1 : 0]
        .return_tag    (return_tag_2  ) ,//input   [$clog2(list_depth) - 1 : 0]
        .return_index  (return_index_2) ,//input   [addr_width - 1 :0]
        .acc_req       (acc_req_2     ) ,//output  
        .acc_gnt       (acc_gnt_2     ) ,//input   
        .fetch_cmd     (fetch_cmd_m   ) ,//output  [1:0]
        .fetch_req     (fetch_req_m   ) ,//output  
        .fetch_tag     (fetch_tag_m   ) ,//output  [$clog2(list_depth) - 1 : 0]
        .fetch_addr    (fetch_addr_m  ) ,//output  [addr_width - 1 : 0]
        .fetch_gnt     (fetch_gnt_m   ) ,//input   
        .fetch_done    (fetch_done_m  ) ,//input   
        .msg_req_0     (msg_req_0     ) ,//input   
        .proc_status_r (proc_status_r ) ,//input  [2:0]
        .proc_addr_r   (proc_addr_r   ) ,//input  [addr_width - 1 : 0]
        .proc_tag_r    (proc_tag_r    ) ,//input  [$ - 1 : 0]
        .proc_tag_w    (proc_tag_w    ) ,//input  [$ - 1 : 0]
        .proc_status_w (proc_status_w ) ,//input   [2:0]
        .proc_addr_w   (proc_addr_w   ) ,//input   [addr_width - 1 : 0]
        .msg_0         (msg_0         ) ,//input   [3:0]
        .msg_index_0   (msg_index_0   ) ,//input   [addr_width - 1 :0]
        .msg_rsp_0     (msg_rsp_0     ) ,//output  [3:0]
        .msg_valid_0   (msg_valid_0   ) ,//output  
        .msg_gnt_0     (msg_gnt_0     ) ,//output  
        .msg_req_1     (msg_req_1     ) ,//input   
        .msg_1         (msg_1         ) ,//input   [3:0]
        .msg_index_1   (msg_index_1   ) ,//input   [addr_width - 1 :0]
        .msg_rsp_1     (msg_rsp_1     ) ,//output  [3:0]
        .msg_valid_1   (msg_valid_1   ) ,//output  
        .msg_gnt_1     (msg_gnt_1     ) ,//output  
        .msg_req       (msg_req       ) ,//output  
        .msg_gnt       (msg_gnt       ) ,//input   
        .msg           (msg           ) ,//output  [4 + 2 * id_width - 1 : 0]
        .msg_in_valid  (msg_in_valid  ) ,//input   
        .msg_in        (msg_in        ));//input   [4 + 2 * id_width - 1 : 0]



endmodule