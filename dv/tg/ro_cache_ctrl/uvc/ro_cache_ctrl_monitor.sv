class ro_cache_ctrl_monitor extends uvm_monitor;

   virtual ro_cache_ctrl_interface_port vif;
   virtual ro_cache_ctrl_interface_inner vif_i;
   uvm_active_passive_enum is_active = UVM_ACTIVE;
   uvm_analysis_port #(uvm_sequence_item)  ap;
   
   `uvm_component_utils(ro_cache_ctrl_monitor)
   function new(string name = "ro_cache_ctrl_monitor", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      int active;
      super.build_phase(phase);
      if(!uvm_config_db#(virtual ro_cache_ctrl_interface_port)::get(this, "", "vif", vif))
         `uvm_fatal("ro_cache_ctrl_monitor", "virtual interface must be set for vif!!!")
      if(!uvm_config_db#(virtual ro_cache_ctrl_interface_inner)::get(this, "", "vif_i", vif_i))
         `uvm_fatal("ro_cache_ctrl_monitor", "virtual interface must be set for vif_i!!!")
      ap = new("ap", this);      
      if(get_config_int("is_active", active)) is_active = uvm_active_passive_enum'(active);
   endfunction

   extern task main_phase(uvm_phase phase);
   extern task collect_one_pkt_drv(ro_cache_ctrl_transaction tr);
   extern task collect_one_pkt_mon(ro_cache_ctrl_transaction tr);
endclass

task ro_cache_ctrl_monitor::main_phase(uvm_phase phase);
   //------------forever------//
   // while(1) begin
      // if(is_active == UVM_ACTIVE) begin
      //    tr = new("tr");
      //    collect_one_pkt_drv(tr);
      //    ap.write(tr);
      // end
      // else begin
      //    tr = new("tr");
      //    collect_one_pkt_mon(tr);
      //    ap.write(tr);
      // end
   // end

   ro_cache_ctrl_transaction tr;
   ro_cache_ctrl_transaction tr1;
   logic [31:0] rd_addr_queue [$];
   logic [31:0] rd_addr_queue1 [$];
   //------------forever------//
   while(1) begin
      if(is_active == UVM_ACTIVE) begin
         @(posedge vif.clk) ;
         if(vif.acc_rd_valid_0 && vif.acc_rd_ready_0) begin
            rd_addr_queue.push_front(vif.acc_rd_addr_0);
         end
         if(vif.acc_rd_done_0) begin
            tr = new("tr");
            tr.req = 1'b1;
            tr.addr = rd_addr_queue.pop_back();
            ap.write(tr);
         end
         if(vif.acc_rd_valid_1 && vif.acc_rd_ready_1) begin
            rd_addr_queue1.push_front(vif.acc_rd_addr_1);
         end
         if(vif.acc_rd_done_1) begin
            tr1 = new("tr1");
            tr1.req = 1'b1;
            tr1.addr = rd_addr_queue1.pop_back();
            ap.write(tr1);
         end
      end
      else begin
         @(posedge vif.clk) ;
         if(vif.acc_rd_data_valid_0) begin
            tr = new("tr");
            tr.req = 1'b1;
            tr.addr = 0;
            tr.rd_data = vif.acc_rd_data_0;
            ap.write(tr);
         end
         if(vif.acc_rd_data_valid_1) begin
            tr1 = new("tr1");
            tr1.req = 1'b1;
            tr1.addr = 0;
            tr1.rd_data = vif.acc_rd_data_1;
            ap.write(tr1);
         end
      end
   end

   //------------repeat-------//
   // repeat(1) begin
   //    if(is_active == UVM_ACTIVE) begin
   //       tr = new("tr");
   //       collect_one_pkt_drv(tr);
   //       ap.write(tr);
   //    end
   //    else begin
   //       tr = new("tr");
   //       collect_one_pkt_mon(tr);
   //       ap.write(tr);
   //    end
   // end


endtask

task ro_cache_ctrl_monitor::collect_one_pkt_drv(ro_cache_ctrl_transaction tr);
endtask


task ro_cache_ctrl_monitor::collect_one_pkt_mon(ro_cache_ctrl_transaction tr);
endtask