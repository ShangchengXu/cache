class ro_cache_ctrl_case0_vseq extends uvm_sequence;

   `uvm_object_utils(ro_cache_ctrl_case0_vseq)
   `uvm_declare_p_sequencer(ro_cache_ctrl_vsqr)
   
   function  new(string name= "ro_cache_ctrl_case0_vseq");
      super.new(name);
      set_automatic_phase_objection(1);
   endfunction 
   
   virtual task body();
      ro_cache_ctrl_case0_sequence dseq;
      ro_cache_ctrl_case0_sequence dseq1;
      dseq = ro_cache_ctrl_case0_sequence::type_id::create("dseq");
      dseq1 = ro_cache_ctrl_case0_sequence::type_id::create("dseq1");

      fork
      dseq.start(p_sequencer.sqr0);
      
      dseq1.start(p_sequencer.sqr1);
      join
   endtask

endclass