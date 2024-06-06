rtl_path = "./rtl/"
cmd = "inst"
name = ""
sp = "./rtl/top/cache_ctrl.pv"
tp = "./rtl/top/cache_ctrl.sv"
fp = ""
inst:
	python ${PYTOOLS_HOME}/main.py -c inst -n ${name} -e 
gen_top:
	python ${PYTOOLS_HOME}/main.py -c gen_top --sp ${sp} --tp ${tp} -e 
gen_filelist:
	python ${PYTOOLS_HOME}/main.py -c gen_filelist -n ${name} --tp ${fp} -e 
