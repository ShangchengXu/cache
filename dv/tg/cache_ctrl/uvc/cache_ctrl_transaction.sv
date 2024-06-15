class cache_ctrl_transaction extends uvm_sequence_item;
   bit [31:0] rd_data;
   bit        req;
 rand  bit [31:0] wr_data;
 rand  bit [31:0] addr;


    constraint pload_cons{
      addr < 5 * 32 *4;
      addr % 4 == 0;
 
   }



   function void post_randomize();
      endfunction

   `uvm_object_utils_begin(cache_ctrl_transaction)
      `uvm_field_int(rd_data,UVM_ALL_ON)
      `uvm_field_int(wr_data,UVM_ALL_ON)
      `uvm_field_int(addr   ,UVM_ALL_ON | UVM_NOCOMPARE)
      `uvm_field_int(req   ,UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "cache_ctrl_transaction");
      super.new();
   endfunction

endclass
