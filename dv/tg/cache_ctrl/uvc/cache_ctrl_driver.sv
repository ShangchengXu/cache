class cache_ctrl_driver extends uvm_driver;

   virtual cache_ctrl_interface_port vif;
   virtual cache_ctrl_interface_inner vif_i;

   `uvm_component_utils(cache_ctrl_driver)
   function new(string name = "cache_ctrl_driver", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual cache_ctrl_interface_port)::get(this, "", "vif", vif))
         `uvm_fatal("cache_ctrl_driver", "virtual interface must be set for vif!!!")
      if(!uvm_config_db#(virtual cache_ctrl_interface_inner)::get(this, "", "vif_i", vif_i))
         `uvm_fatal("cache_ctrl_driver", "virtual interface must be set for vif_i!!!")

   endfunction

   extern task main_phase(uvm_phase phase);
   extern task drive_one_pkt(cache_ctrl_transaction tr);
endclass

task cache_ctrl_driver::main_phase(uvm_phase phase);
   cache_ctrl_transaction tr;
   logic [31:0] temp_addr;
   logic [1:0] queue [$];
   logic [1:0] temp_req;
   vif.acc_rd_valid <= 1'b0;
   vif.acc_rd_addr <= 0;
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
   // while(1) begin
   //    @(posedge vif.clk);
   //    if(vif.msg_req && vif.msg_gnt) begin
   //       if(vif.msg[5 + 32 :2 + 32] == 4'b100)
   //          #3 queue.push_front(2'b00);
   //       else begin
   //          #3 queue.push_front(2'b01);
   //       end
   //    end
   // end
   // while(1) begin
   //    vif.msg_in_valid <= 1'b0;
   //    vif.msg_in <= {4'b000,1'b0,1'b0, 32'b0};
   //    if(queue.size()!=0) begin
   //         temp_req =  queue.pop_back();
   //         vif.msg_in_valid <= 1'b1;
   //         if(temp_req == 2'b00) begin
   //           vif.msg_in <= {4'b010,1'b1,1'b0,32'b0};
   //         end else begin
   //           vif.msg_in <= {4'b000,1'b1,1'b0, 32'b0};
   //         end
   //    end
   //    @(posedge vif.clk);
   // end

   join
endtask

task cache_ctrl_driver::drive_one_pkt(cache_ctrl_transaction tr);
   // `uvm_info("cache_ctrl_driver", "begin to drive one pkt", UVM_LOW);
   vif.acc_rd_valid <= 1'b1;
   vif.acc_rd_addr <= tr.addr;
   while(1) begin
   @(posedge vif.clk);
      if(vif.acc_rd_valid && vif.acc_rd_ready) begin
         break;
      end
   end
   vif.acc_rd_valid <= 1'b0;
      repeat($urandom_range(20,0)) begin
         @(posedge vif.clk);
      end

   // `uvm_info("cache_ctrl_driver", "end drive one pkt", UVM_LOW);
endtask


