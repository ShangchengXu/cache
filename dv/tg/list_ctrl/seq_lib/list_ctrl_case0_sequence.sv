class list_ctrl_case0_sequence extends uvm_sequence #(uvm_sequence_item);
   list_ctrl_transaction m_trans;

   function  new(string name= "list_ctrl_case0_sequence");
      super.new(name);
   endfunction 
   
   virtual task body();
      repeat (10) begin
         `uvm_do(m_trans)
      end
   endtask

   `uvm_object_utils(list_ctrl_case0_sequence)
endclass