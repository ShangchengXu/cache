class ro_cache_ctrl_driver extends uvm_driver;

   virtual ro_cache_ctrl_interface_port vif;
   virtual ro_cache_ctrl_interface_inner vif_i;

   `uvm_component_utils(ro_cache_ctrl_driver)
   function new(string name = "ro_cache_ctrl_driver", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual ro_cache_ctrl_interface_port)::get(this, "", "vif", vif))
         `uvm_fatal("ro_cache_ctrl_driver", "virtual interface must be set for vif!!!")
      if(!uvm_config_db#(virtual ro_cache_ctrl_interface_inner)::get(this, "", "vif_i", vif_i))
         `uvm_fatal("ro_cache_ctrl_driver", "virtual interface must be set for vif_i!!!")

   endfunction

   extern task main_phase(uvm_phase phase);
   extern task drive_one_pkt(ro_cache_ctrl_transaction tr);
endclass

task ro_cache_ctrl_driver::main_phase(uvm_phase phase);

   ro_cache_ctrl_transaction tr;
   logic [31:0] temp_addr;
   logic [1:0] queue [$];
   logic [1:0] temp_req;
   vif.acc_rd_valid_0 <= 1'b0;
   vif.acc_rd_addr_0 <= 0;
   vif.rd_gnt <= 1'b1;
   vif.rd_valid <= 1'b0;
   vif.rd_done <= 1'b0;

   fork
   while(1) begin
      seq_item_port.get_next_item(req);
      $cast(tr,req);
      drive_one_pkt(tr);
      seq_item_port.item_done();
   end
   while(1) begin
      @(posedge vif.clk);
      vif.acc_rd_data_ready_0 <= $urandom_range(0,1);
   end
   while(1) begin
      @(posedge vif.clk);
      if(vif.rd_req &&  vif.rd_gnt) begin
         temp_addr = (vif.rd_addr)/4;
         for(int i = 0 ; i < 32; i++) begin
            vif.rd_data <= memory::mem[temp_addr + i];
            vif.rd_valid <= 1'b1;
            if(i == 31) begin
               vif.rd_done <= 1'b1;
            end
            while(1) begin
               @(posedge vif.clk);
               if(vif.rd_valid && vif.rd_ready) begin
                  break;
               end
            end
         end
         vif.rd_valid <= 1'b0;
         vif.rd_done <= 1'b0;
      end
   end
   join

endtask

task ro_cache_ctrl_driver::drive_one_pkt(ro_cache_ctrl_transaction tr);
   // `uvm_info("ro_cache_ctrl_driver", "begin to drive one pkt", UVM_LOW);

   vif.acc_rd_valid_0 <= 1'b1;
   vif.acc_rd_addr_0 <= tr.addr;
   while(1) begin
   @(posedge vif.clk);
      if(vif.acc_rd_valid_0 && vif.acc_rd_ready_0) begin
         break;
      end
   end
   vif.acc_rd_valid_0 <= 1'b0;
      repeat($urandom_range(20,0)) begin
         @(posedge vif.clk);
      end
   // `uvm_info("ro_cache_ctrl_driver", "end drive one pkt", UVM_LOW);
endtask


