class list_ctrl_vsqr extends uvm_sequencer;
  
   list_ctrl_sequencer  sqr0;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   `uvm_component_utils(list_ctrl_vsqr)
endclass