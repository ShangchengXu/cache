class cache_ctrl_scoreboard extends uvm_scoreboard;
   cache_ctrl_transaction  expect_queue[$];
   uvm_blocking_get_port #(uvm_sequence_item)  exp_port;
   uvm_blocking_get_port #(uvm_sequence_item)  act_port;
   `uvm_component_utils(cache_ctrl_scoreboard)

   extern function new(string name, uvm_component parent = null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual task main_phase(uvm_phase phase);
endclass 

function cache_ctrl_scoreboard::new(string name, uvm_component parent = null);
   super.new(name, parent);
endfunction 

function void cache_ctrl_scoreboard::build_phase(uvm_phase phase);
   super.build_phase(phase);
   exp_port = new("exp_port", this);
   act_port = new("act_port", this);
endfunction 

task cache_ctrl_scoreboard::main_phase(uvm_phase phase);
   uvm_sequence_item  get_expect,  get_actual;
   cache_ctrl_transaction  expect_tr,  actual_tr, tmp_tran;
   bit result;
 
   super.main_phase(phase);
   fork 
      while (1) begin
         act_port.get(get_actual);
         exp_port.get(get_expect);
         $cast(expect_tr,get_expect);
         $cast(actual_tr, get_actual);
            result = actual_tr.compare(expect_tr);
            if(result) begin 
               `uvm_info("cache_ctrl_scoreboard", "Compare SUCCESSFULLY", UVM_LOW);
            end
            else begin
               `uvm_error("cache_ctrl_scoreboard", "Compare FAILED");
            end
      end
   join
endtask