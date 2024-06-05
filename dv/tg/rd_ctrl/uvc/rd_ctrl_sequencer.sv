class rd_ctrl_sequencer extends uvm_sequencer;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   `uvm_component_utils(rd_ctrl_sequencer)
endclass

