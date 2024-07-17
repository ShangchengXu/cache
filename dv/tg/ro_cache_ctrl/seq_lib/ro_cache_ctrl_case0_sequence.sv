class ro_cache_ctrl_case0_sequence extends uvm_sequence #(uvm_sequence_item);
   ro_cache_ctrl_transaction m_trans;

   function  new(string name= "ro_cache_ctrl_case0_sequence");
      super.new(name);
   endfunction 
   
   virtual task body();
      repeat (1000) begin
         `uvm_do(m_trans)
      end
   endtask

   `uvm_object_utils(ro_cache_ctrl_case0_sequence)
endclass