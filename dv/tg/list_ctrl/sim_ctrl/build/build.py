build_opts = r"vcs  +acc +vpi -j16   -full64 +v2k -sverilog  -ntb_opts uvm-1.2   +define+DEBUG  -CFLAGS -DVCS -lca -kdb +lint=TFIPC-L -timescale=1ns/1ps -debug_acc+all -debug_region+cell+encrypt -LDFLAGS -rdynamic  -P ${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a  -f ../../filelist/filelist.f " + "../../tb/"+ self.filename + "_tb.sv"

lists = {
    "base_build":{"build_opts":build_opts}
}

for key  in lists.keys():
    # print("[INFO] add build: "+ key)
    self.build_list[key] = lists[key]