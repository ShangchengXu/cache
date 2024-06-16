class cache_ctrl_case0_sequence extends uvm_sequence #(uvm_sequence_item);
   cache_ctrl_transaction m_trans;

   function  new(string name= "cache_ctrl_case0_sequence");
      super.new(name);
   endfunction 
   
   virtual task body();
      repeat (100000) begin
         `uvm_do(m_trans)
      end
   endtask

   `uvm_object_utils(cache_ctrl_case0_sequence)
endclass