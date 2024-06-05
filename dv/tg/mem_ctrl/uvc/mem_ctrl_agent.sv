class mem_ctrl_agent extends uvm_agent ;
   mem_ctrl_sequencer  sqr;
   mem_ctrl_driver     drv;
   mem_ctrl_monitor    mon;
   
   uvm_analysis_port #(uvm_sequence_item)  ap;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);

   `uvm_component_utils(mem_ctrl_agent)
endclass 


function void mem_ctrl_agent::build_phase(uvm_phase phase);
   super.build_phase(phase);
   if (is_active == UVM_ACTIVE) begin
      sqr = mem_ctrl_sequencer::type_id::create("sqr", this);
      drv = mem_ctrl_driver::type_id::create("drv", this);
   end
   mon = mem_ctrl_monitor::type_id::create("mon", this);
   mon.is_active = is_active;
endfunction 

function void mem_ctrl_agent::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   if (is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
   end
   ap = mon.ap;
endfunction

