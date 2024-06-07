class cache_ctrl_model extends uvm_component;
   
   uvm_blocking_get_port #(uvm_sequence_item)  port;
   uvm_analysis_port #(uvm_sequence_item)  ap;
   bit [31:0] mem [4096];

   extern function new(string name, uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   extern virtual  task main_phase(uvm_phase phase);

   `uvm_component_utils(cache_ctrl_model)
endclass 

function cache_ctrl_model::new(string name, uvm_component parent);
   super.new(name, parent);
endfunction 

function void cache_ctrl_model::build_phase(uvm_phase phase);
   super.build_phase(phase);
   port = new("port", this);
   ap = new("ap", this);
   for(int i = 0; i < 4096; i++) begin
      memory::mem[i] = $random();
      mem[i] = memory::mem[i];
   end
endfunction

task cache_ctrl_model::main_phase(uvm_phase phase);
   uvm_sequence_item drive_req;
   cache_ctrl_transaction drive_tr;
   cache_ctrl_transaction scb_tr;
   super.main_phase(phase);
   while(1) begin
      port.get(drive_req);
      $cast(drive_tr,drive_req);
      if(drive_tr.req == 1'b0) begin
         mem[(drive_tr.addr)/4] = drive_tr.wr_data;
      end else if(drive_tr.req == 1'b1) begin
         scb_tr = new("scb_tr");
         scb_tr.addr = 0;
         scb_tr.req = 1;
         scb_tr.rd_data = mem[(drive_tr.addr)/4];
         ap.write(scb_tr);
      end
   end
endtask