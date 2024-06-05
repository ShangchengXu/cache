class mem_ctrl_case0_vseq extends uvm_sequence;

   `uvm_object_utils(mem_ctrl_case0_vseq)
   `uvm_declare_p_sequencer(mem_ctrl_vsqr)
   
   function  new(string name= "mem_ctrl_case0_vseq");
      super.new(name);
      set_automatic_phase_objection(1);
   endfunction 
   
   virtual task body();
      mem_ctrl_case0_sequence dseq;
      dseq = mem_ctrl_case0_sequence::type_id::create("dseq");
      dseq.start(p_sequencer.sqr0);
      
   endtask

endclass