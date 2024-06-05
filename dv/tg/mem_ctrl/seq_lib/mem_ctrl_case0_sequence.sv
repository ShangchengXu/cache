class mem_ctrl_case0_sequence extends uvm_sequence #(uvm_sequence_item);
   mem_ctrl_transaction m_trans;

   function  new(string name= "mem_ctrl_case0_sequence");
      super.new(name);
   endfunction 
   
   virtual task body();
      repeat (10) begin
         `uvm_do(m_trans)
      end
   endtask

   `uvm_object_utils(mem_ctrl_case0_sequence)
endclass