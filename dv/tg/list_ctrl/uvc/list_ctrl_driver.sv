class list_ctrl_driver extends uvm_driver;

   virtual list_ctrl_interface_port vif;
   virtual list_ctrl_interface_inner vif_i;

   `uvm_component_utils(list_ctrl_driver)
   function new(string name = "list_ctrl_driver", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual list_ctrl_interface_port)::get(this, "", "vif", vif))
         `uvm_fatal("list_ctrl_driver", "virtual interface must be set for vif!!!")
      if(!uvm_config_db#(virtual list_ctrl_interface_inner)::get(this, "", "vif_i", vif_i))
         `uvm_fatal("list_ctrl_driver", "virtual interface must be set for vif_i!!!")

   endfunction

   extern task main_phase(uvm_phase phase);
   extern task drive_one_pkt(list_ctrl_transaction tr);
endclass

task list_ctrl_driver::main_phase(uvm_phase phase);
   list_ctrl_transaction tr;
   while(1) begin
      seq_item_port.get_next_item(req);
      $cast(tr,req);
      drive_one_pkt(tr);
      seq_item_port.item_done();
   end
endtask

task list_ctrl_driver::drive_one_pkt(list_ctrl_transaction tr);
   // `uvm_info("list_ctrl_driver", "begin to drive one pkt", UVM_LOW);

   // `uvm_info("list_ctrl_driver", "end drive one pkt", UVM_LOW);
endtask


