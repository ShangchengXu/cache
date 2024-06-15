class cache_ctrl_base_test extends uvm_test;

   cache_ctrl_env         env;
   cache_ctrl_env         env1;
   cache_ctrl_vsqr        vsqr;
   
   function new(string name = "cache_ctrl_base_test", uvm_component parent = null);
      super.new(name,parent);
   endfunction
   
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);
   extern task main_phase(uvm_phase phase);
   `uvm_component_utils(cache_ctrl_base_test)
endclass

task cache_ctrl_base_test::main_phase(uvm_phase phase);
   // phase.phase_done.set_drain_time(this,20);
endtask

function void cache_ctrl_base_test::build_phase(uvm_phase phase);
   logic [31:0] temp; 
   super.build_phase(phase);
   env  =  cache_ctrl_env::type_id::create("env", this); 
   env1  =  cache_ctrl_env::type_id::create("env1", this); 
   vsqr =  cache_ctrl_vsqr::type_id::create("vsqr", this); 
   for(int i = 0; i < 4096; i++) begin
      temp = $random();
      memory::mem[i] = temp;
      memory::mem_model[i] = temp;
   end
endfunction

function void cache_ctrl_base_test::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   vsqr.sqr0 = env.mst_agt.sqr;
   vsqr.sqr1 = env.mst_agt1.sqr;

   vsqr.sqr2 = env1.mst_agt.sqr;
   vsqr.sqr3 = env1.mst_agt1.sqr;
endfunction


function void cache_ctrl_base_test::report_phase(uvm_phase phase);
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

