class wr_ctrl_driver extends uvm_driver;

   virtual wr_ctrl_interface_port vif;
   virtual wr_ctrl_interface_inner vif_i;

   `uvm_component_utils(wr_ctrl_driver)
   function new(string name = "wr_ctrl_driver", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual wr_ctrl_interface_port)::get(this, "", "vif", vif))
         `uvm_fatal("wr_ctrl_driver", "virtual interface must be set for vif!!!")
      if(!uvm_config_db#(virtual wr_ctrl_interface_inner)::get(this, "", "vif_i", vif_i))
         `uvm_fatal("wr_ctrl_driver", "virtual interface must be set for vif_i!!!")

   endfunction

   extern task main_phase(uvm_phase phase);
   extern task drive_one_pkt(wr_ctrl_transaction tr);
endclass

task wr_ctrl_driver::main_phase(uvm_phase phase);
   wr_ctrl_transaction tr;
   while(1) begin
      seq_item_port.get_next_item(req);
      $cast(tr,req);
      drive_one_pkt(tr);
      seq_item_port.item_done();
   end
endtask

task wr_ctrl_driver::drive_one_pkt(wr_ctrl_transaction tr);
   // `uvm_info("wr_ctrl_driver", "begin to drive one pkt", UVM_LOW);

   // `uvm_info("wr_ctrl_driver", "end drive one pkt", UVM_LOW);
endtask


