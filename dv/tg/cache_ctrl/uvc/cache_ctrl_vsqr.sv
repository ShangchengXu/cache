class cache_ctrl_vsqr extends uvm_sequencer;
  
   cache_ctrl_sequencer  sqr0;
   cache_ctrl_sequencer  sqr1;
   cache_ctrl_sequencer  sqr2;
   cache_ctrl_sequencer  sqr3;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   `uvm_component_utils(cache_ctrl_vsqr)
endclass