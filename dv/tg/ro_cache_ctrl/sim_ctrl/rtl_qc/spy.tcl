#设置变量top，用于指定不同的设计的top
set top ro_cache_ctrl   
#设置变量prj_loc为当前工作/脚本执行路径
set prj_loc [pwd] 
#在当前路径下，新建一个名字为top的文件夹，用于spyglass的工作文件夹
new_project ${top} -projectwdir $prj_loc -force 
#设置spyglass工作的顶层
set_option top ro_cache_ctrl 
##read rtl and lib
read_file -type sourcelist ../../filelist/filelist_def.f
read_file -type sourcelist ../../filelist/filelist_rtl.f
#读入sgdc文件
# read_file -type sgdc ../../sim_ctrl/rtl_qc/spy.sgdc 
#读入waive文件
read_file -type awl  ../../sim_ctrl/rtl_qc/spy_waive.awl 
#设置waive文件
set_option default_waiver_file ../../sim_ctrl/rtl_qc/spy_waive.awl 

##spyglass setup
# set_option sdc2sgdc yes
set_option enable_precompile_vlog yes
set_option sort yes
set_option 87 yes
set_option language_mode mixed
set_option designread_disable_flatten yes
set_option enableSV yes
# set_parameter enable_generated_clock yes
# set_parameter enable_glitchfreecell_detection yes
set_parameter pt no 
set_option sgsyn_clock_gating 1
set_option allow_module_override yes
set_option vlog2001_generate_name yes
set_option handlememory yes
set_option define_cell_sim_depth 11
set_option mthresh 400000
# set_option incdir {}

current_methodology $SPYGLASS_HOME/GuideWare/latest/block/rtl_handoff

##lint rtl
current_goal lint/lint_rtl_enhanced -top ${top}
run_goal
current_goal lint/lint_turbo_rtl -top ${top}
run_goal
current_goal lint/lint_functional_rtl -top ${top}
run_goal
current_goal lint/lint_abstract -top ${top}
run_goal
current_goal lint/lint_rtl -top ${top}
run_goal
write_report moresimple > ${top}_nLint.rpt

# ##cdc setup
# current_goal cdc/cdc_setup_check -top ${top}
# run_goal
# write_report moresimple > ${top}_cdc_setup.rpt

# ##cdc verify struct
# current_goal cdc/cdc_verify_struct -top ${top}
# run_goal
# write_report moresimple > ${top}_cdc_verify_struct.rpt

# ##cdc verify
# current_goal cdc/cdc_verify -top ${top}
# run_goal
# write_report moresimple > ${top}_cdc_verify.rpt

# ##rdc verify struct
# current_goal cdc/cdc_verify_struct -top ${top}
# run_goal
# write_report moresimple > ${top}_rdc_verify_struct.rpt

save_project -force ${top}.prj

exit -force 