class cache_ctrl_transaction extends uvm_sequence_item;

    constraint pload_cons{
 
   }



   function void post_randomize();
      endfunction

   `uvm_object_utils_begin(cache_ctrl_transaction)
   `uvm_object_utils_end

   function new(string name = "cache_ctrl_transaction");
      super.new();
   endfunction

endclass
