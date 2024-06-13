sim_opts = " +vcs+lic+wait  +fsdb+all=on  +fsdbfile+hw.fsdb   -l sim.log"
# sim_opts = "../../build/simv +vcs+lic+wait  +fsdb+all=on  +fsdbfile+hw.fsdb   -l sim.log"

lists = {
    self.filename+"_case0":{"sim_opts":sim_opts +" +UVM_TESTNAME="+ self.filename+"_case0"+" +UVM_TIMEOUT=\"9000000ns, yes\" +UVM_MAX_QUIT_COUNT=15,no ", "repeat_num":1}
}


for key in lists.keys():
    # print("[INFO] add test case: "+ key)
    self.test_list[key] = lists[key]