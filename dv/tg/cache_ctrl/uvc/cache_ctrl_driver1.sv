class cache_ctrl_driver1 extends uvm_driver;

   virtual cache_ctrl_interface_port vif;
   virtual cache_ctrl_interface_inner vif_i;

   `uvm_component_utils(cache_ctrl_driver1)
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

task cache_ctrl_driver1::main_phase(uvm_phase phase);
   cache_ctrl_transaction tr;
   logic [31:0] temp_addr;
   int index;
   vif.acc_wr_valid <= 1'b0;
   vif.acc_wr_data <= 0;
   vif.acc_wr_addr <= 0;
   vif.wr_gnt <= 1'b1;
   vif.wr_ready <= 1'b1;
   vif.wr_done <= 1'b0;
   fork
   while(1) begin
      seq_item_port.get_next_item(req);
      $cast(tr,req);
      drive_one_pkt(tr);
      seq_item_port.item_done();
   end

   while(1) begin
      @(posedge vif.clk);
      if(vif.wr_req &&  vif.wr_gnt) begin
         temp_addr = (vif.wr_addr)/4;
         index = 0;
            while(1) begin
               if(vif.wr_valid) begin
                  memory::mem[temp_addr + index] = vif.wr_data;
                  index = index + 1;
                  @(posedge vif.clk);
                  if(index == 32) begin
                     break;
                  end
               end else begin
               @(posedge vif.clk);
               end
         end
            repeat(3) begin
            @(posedge vif.clk);
            end
            vif.wr_done <= 1'b1;
            @(posedge vif.clk);
         vif.wr_done <= 1'b0;
      end

   end

   join
endtask

task cache_ctrl_driver1::drive_one_pkt(cache_ctrl_transaction tr);
   // `uvm_info("cache_ctrl_driver", "begin to drive one pkt", UVM_LOW);

   vif.acc_wr_valid <= 1'b1;
   vif.acc_wr_data <= tr.wr_data;
   vif.acc_wr_addr <= tr.addr;
   while(1) begin
   @(posedge vif.clk);
      if(vif.acc_wr_valid && vif.acc_wr_ready) begin
         break;
      end
   end
   vif.acc_wr_valid <= 1'b0;
   repeat($urandom_range(20,0)) begin
      @(posedge vif.clk);
   end

   // `uvm_info("cache_ctrl_driver", "end drive one pkt", UVM_LOW);
endtask


