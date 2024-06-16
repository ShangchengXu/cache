class ro_cache_ctrl_driver1 extends uvm_driver;

   virtual ro_cache_ctrl_interface_port vif;
   virtual ro_cache_ctrl_interface_inner vif_i;

   `uvm_component_utils(ro_cache_ctrl_driver1)
   function new(string name = "ro_cache_ctrl_driver1", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual ro_cache_ctrl_interface_port)::get(this, "", "vif", vif))
         `uvm_fatal("ro_cache_ctrl_driver1", "virtual interface must be set for vif!!!")
      if(!uvm_config_db#(virtual ro_cache_ctrl_interface_inner)::get(this, "", "vif_i", vif_i))
         `uvm_fatal("ro_cache_ctrl_driver1", "virtual interface must be set for vif_i!!!")

   endfunction

   extern task main_phase(uvm_phase phase);
   extern task drive_one_pkt(ro_cache_ctrl_transaction tr);
endclass

task ro_cache_ctrl_driver1::main_phase(uvm_phase phase);
   ro_cache_ctrl_transaction tr;
   vif.acc_rd_valid_1 <= 1'b0;
   vif.acc_rd_addr_1 <= 0;
   while(1) begin
      seq_item_port.get_next_item(req);
      $cast(tr,req);
      drive_one_pkt(tr);
      seq_item_port.item_done();
   end
endtask

task ro_cache_ctrl_driver1::drive_one_pkt(ro_cache_ctrl_transaction tr);
   // `uvm_info("ro_cache_ctrl_driver1", "begin to drive one pkt", UVM_LOW);

   vif.acc_rd_valid_1 <= 1'b1;
   vif.acc_rd_addr_1 <= tr.addr;
   while(1) begin
   @(posedge vif.clk);
      if(vif.acc_rd_valid_1 && vif.acc_rd_ready_1) begin
         break;
      end
   end
   vif.acc_rd_valid_1 <= 1'b0;
      repeat($urandom_range(20,0)) begin
         @(posedge vif.clk);
      end
   // `uvm_info("ro_cache_ctrl_driver1", "end drive one pkt", UVM_LOW);
endtask


