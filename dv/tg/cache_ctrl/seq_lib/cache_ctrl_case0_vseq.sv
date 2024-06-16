class cache_ctrl_case0_vseq extends uvm_sequence;

   `uvm_object_utils(cache_ctrl_case0_vseq)
   `uvm_declare_p_sequencer(cache_ctrl_vsqr)
   
   function  new(string name= "cache_ctrl_case0_vseq");
      super.new(name);
      set_automatic_phase_objection(1);
   endfunction 
   
   virtual task body();
      cache_ctrl_case0_sequence dseq;
      cache_ctrl_case0_sequence dseq1;
      cache_ctrl_case0_sequence dseq2;
      cache_ctrl_case0_sequence dseq3;
      cache_ctrl_case0_sequence dseq4;
      cache_ctrl_case0_sequence dseq5;

      ro_cache_ctrl_case0_sequence dseq6;
      ro_cache_ctrl_case0_sequence dseq7;
      dseq6 = ro_cache_ctrl_case0_sequence::type_id::create("dseq7");
      dseq7 = ro_cache_ctrl_case0_sequence::type_id::create("dseq6");


      dseq = cache_ctrl_case0_sequence::type_id::create("dseq");
      dseq1 = cache_ctrl_case0_sequence::type_id::create("dseq1");
      dseq2 = cache_ctrl_case0_sequence::type_id::create("dseq2");
      dseq3 = cache_ctrl_case0_sequence::type_id::create("dseq3");
      dseq4 = cache_ctrl_case0_sequence::type_id::create("dseq4");
      dseq5 = cache_ctrl_case0_sequence::type_id::create("dseq5");
      fork
         dseq.start(p_sequencer.sqr0);
         dseq1.start(p_sequencer.sqr1);
         dseq2.start(p_sequencer.sqr2);
         dseq3.start(p_sequencer.sqr3);
         dseq4.start(p_sequencer.sqr4);
         dseq5.start(p_sequencer.sqr5);
         dseq6.start(p_sequencer.sqr6);
         dseq7.start(p_sequencer.sqr7);
      join
      
   endtask

endclass