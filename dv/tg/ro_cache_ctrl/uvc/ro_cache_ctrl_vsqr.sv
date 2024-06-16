class ro_cache_ctrl_vsqr extends uvm_sequencer;
  
   ro_cache_ctrl_sequencer  sqr0;
   ro_cache_ctrl_sequencer  sqr1;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   `uvm_component_utils(ro_cache_ctrl_vsqr)
endclass