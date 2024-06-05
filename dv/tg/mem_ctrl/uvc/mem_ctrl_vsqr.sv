class mem_ctrl_vsqr extends uvm_sequencer;
  
   mem_ctrl_sequencer  sqr0;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   `uvm_component_utils(mem_ctrl_vsqr)
endclass