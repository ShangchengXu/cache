class list_ctrl_base_test extends uvm_test;

   list_ctrl_env         env;
   list_ctrl_vsqr        vsqr;
   
   function new(string name = "list_ctrl_base_test", uvm_component parent = null);
      super.new(name,parent);
   endfunction
   
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);
   extern task main_phase(uvm_phase phase);
   `uvm_component_utils(list_ctrl_base_test)
endclass

task list_ctrl_base_test::main_phase(uvm_phase phase);
   // phase.phase_done.set_drain_time(this,20);
endtask

function void list_ctrl_base_test::build_phase(uvm_phase phase);
   super.build_phase(phase);
   env  =  list_ctrl_env::type_id::create("env", this); 
   vsqr =  list_ctrl_vsqr::type_id::create("vsqr", this); 
endfunction

function void list_ctrl_base_test::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   vsqr.sqr0 = env.mst_agt.sqr;
endfunction


function void list_ctrl_base_test::report_phase(uvm_phase phase);
   uvm_report_server server;
   int err_num;
   super.report_phase(phase);

   server = get_report_server();
   err_num = server.get_severity_count(UVM_ERROR);

   if (err_num != 0) begin
      $display("TEST CASE FAILED");
   end
   else begin
      $display("TEST CASE PASSED");
   end
endfunction

