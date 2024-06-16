class ro_cache_ctrl_model extends uvm_component;
   
   uvm_blocking_get_port #(uvm_sequence_item)  port;
   uvm_analysis_port #(uvm_sequence_item)  ap;

   extern function new(string name, uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   extern virtual  task main_phase(uvm_phase phase);

   `uvm_component_utils(ro_cache_ctrl_model)
endclass 

function ro_cache_ctrl_model::new(string name, uvm_component parent);
   super.new(name, parent);
endfunction 

function void ro_cache_ctrl_model::build_phase(uvm_phase phase);
   super.build_phase(phase);
   port = new("port", this);
   ap = new("ap", this);
endfunction

task ro_cache_ctrl_model::main_phase(uvm_phase phase);
   uvm_sequence_item drive_req;
   ro_cache_ctrl_transaction drive_tr;
   ro_cache_ctrl_transaction scb_tr;
   super.main_phase(phase);
   while(1) begin
      port.get(drive_req);
      $cast(drive_tr,drive_req);
      scb_tr = new("scb_tr");
      scb_tr.addr = drive_tr.addr;
      scb_tr.req = 1;
      scb_tr.rd_data = memory::mem_model[(drive_tr.addr)/4];
      // `uvm_info("ro_cache_model",$sformatf("rd_addr = %h, rd_data = %h",drive_tr.addr, scb_tr.rd_data), UVM_LOW);
      ap.write(scb_tr);
   end
endtask