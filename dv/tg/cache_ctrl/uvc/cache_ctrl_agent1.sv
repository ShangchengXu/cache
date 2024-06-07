class cache_ctrl_agent1 extends uvm_agent ;
   cache_ctrl_sequencer  sqr;
   cache_ctrl_driver1     drv;
   
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);

   `uvm_component_utils(cache_ctrl_agent1)
endclass 


function void cache_ctrl_agent1::build_phase(uvm_phase phase);
   super.build_phase(phase);
   if (is_active == UVM_ACTIVE) begin
      sqr = cache_ctrl_sequencer::type_id::create("sqr", this);
      drv = cache_ctrl_driver1::type_id::create("drv", this);
   end
endfunction 

function void cache_ctrl_agent1::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   if (is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
   end
endfunction

