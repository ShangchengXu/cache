class cache_ctrl_monitor extends uvm_monitor;

   virtual cache_ctrl_interface_port vif;
   virtual cache_ctrl_interface_inner vif_i;
   uvm_active_passive_enum is_active = UVM_ACTIVE;
   uvm_analysis_port #(uvm_sequence_item)  ap;
   
   `uvm_component_utils(cache_ctrl_monitor)
   function new(string name = "cache_ctrl_monitor", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      int active;
      super.build_phase(phase);
      if(!uvm_config_db#(virtual cache_ctrl_interface_port)::get(this, "", "vif", vif))
         `uvm_fatal("cache_ctrl_monitor", "virtual interface must be set for vif!!!")
      if(!uvm_config_db#(virtual cache_ctrl_interface_inner)::get(this, "", "vif_i", vif_i))
         `uvm_fatal("cache_ctrl_monitor", "virtual interface must be set for vif_i!!!")
      ap = new("ap", this);      
      if(get_config_int("is_active", active)) is_active = uvm_active_passive_enum'(active);
   endfunction

   extern task main_phase(uvm_phase phase);
   extern task collect_one_pkt_drv(cache_ctrl_transaction tr);
   extern task collect_one_pkt_mon(cache_ctrl_transaction tr);
endclass

task cache_ctrl_monitor::main_phase(uvm_phase phase);
   cache_ctrl_transaction tr;
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

   //------------repeat-------//
   repeat(1) begin
      if(is_active == UVM_ACTIVE) begin
         tr = new("tr");
         collect_one_pkt_drv(tr);
         ap.write(tr);
      end
      else begin
         tr = new("tr");
         collect_one_pkt_mon(tr);
         ap.write(tr);
      end
   end


endtask

task cache_ctrl_monitor::collect_one_pkt_drv(cache_ctrl_transaction tr);
endtask


task cache_ctrl_monitor::collect_one_pkt_mon(cache_ctrl_transaction tr);
endtask