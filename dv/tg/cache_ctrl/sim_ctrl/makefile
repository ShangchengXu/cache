OUTPUT = cache_ctrl
export name = ${OUTPUT}
REPEAT=1
SEED=0
DEL_PASS=False
TC=base_build_${name}_case0
UVM_VERBOSITY=UVM_MEDIUM
clean:
	cd ../build && rm -rf  ./verdiLog  ./dff ./csrc *.daidir *log *.vpd *.vdb simv* *.key *race.out* *.rc *.fsdb *.vpd *.log *.conf *.dat *.conf

comp:
	python ${PYTOOLS_HOME}/main.py -c comp -n ${name}

sim:
	python ${PYTOOLS_HOME}/main.py -c sim -n ${name}  -s ${SEED} -x ${TC} -r ${REPEAT} --del_pass ${DEL_PASS} --uvm_verbosity ${UVM_VERBOSITY}

all: 
	python ${PYTOOLS_HOME}/main.py -c all -n ${name}  -s ${SEED} -x ${TC} -r ${REPEAT} --del_pass ${DEL_PASS} --uvm_verbosity ${UVM_VERBOSITY}

regress:
	python ${PYTOOLS_HOME}/main.py -c regress -n ${name}  -s ${SEED} -x ${TC} -r ${REPEAT} --del_pass ${DEL_PASS} --uvm_verbosity ${UVM_VERBOSITY}

lint:
	python ${PYTOOLS_HOME}/main.py -c lint -n ${name}

lint_gui:
	python ${PYTOOLS_HOME}/main.py -c lint_gui -n ${name}

dc:
	python ${PYTOOLS_HOME}/main.py -c dc -n ${name}