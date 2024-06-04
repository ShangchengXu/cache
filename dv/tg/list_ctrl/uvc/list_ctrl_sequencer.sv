class list_ctrl_sequencer extends uvm_sequencer;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   `uvm_component_utils(list_ctrl_sequencer)
endclass

