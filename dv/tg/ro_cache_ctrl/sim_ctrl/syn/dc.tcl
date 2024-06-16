set top_design ro_cache_ctrl
set sh_output_log_file  ./log/dc_output.log
set sh_command_log_file ./log/dc_command.log

# set path
set work_path    ./work
set script_path  ./script
set netlist_path ./netlist
set report_path  ./report
set sdc_path     ./sdc
set svf_path     ./svf
set db_path      /opt/pdk/UMC28/stdcell/UM22LB062-FB-00000-r1p0-00eac0/arm/umc/l28hpc/sc9mcpp140z_base_rvt_c30/r1p0/db
set symbol_path  /opt/pdk/UMC28/stdcell/UM22LB062-FB-00000-r1p0-00eac0/arm/umc/l28hpc/sc9mcpp140z_base_rvt_c30/r1p0/sdb
set search_path  " . $db_path $symbol_path"

# set libs
set target_library sc9mcpp140z_l28hpc_base_rvt_c30_ss_cworst_max_0p81v_125c.db
set symbol_library sc9mcpp140z_l28hpc_base_rvt_c30.sdb
set synthetic_library ""
#set link_library [concat [concat * $target_library ] $synthetic_library ]
set link_library " * $target_library $synthetic_library "


set filelist { -f ../../filelist/filelist_def.f \
            -f ../../filelist/filelist_rtl.f }

define_design_lib work -path $work_path

set_svf $svf_path/$top_design.svf

analyze -format sverilog -vcs $filelist -lib work

elaborate $top_design 

set current_design $top_design

set clk_src(clk) [get_ports clk]

set Period(300M) [expr 1000/300]

create_clock  -name clk -period $Period(300M)  $clk_src(clk)

set input_ports_grp(clk) [all_inputs]

set output_ports_grp(clk) [all_outputs]

set_input_delay -max [expr $Period(300M) * 0.4] -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_input_delay -min [expr $Period(300M) * 0.0] -clock clk [remove_from_collection [all_inputs] [get_ports clk]]

set_output_delay -max [expr $Period(300M) * 0.4] -clock clk [all_outputs]
set_output_delay -min [expr $Period(300M) * 0.0] -clock clk [all_outputs]

set_operating_conditions ss_cworst_max_0p81v_125c

set auto_wire_load_selection true

set_wire_load_mode top


set_clock_transtion 0.2 [all_clocks]

set_max_area 0



uniquify

link > $report_path/link.rpt

check_design > $report_path/check_design.rpt

set insert_CG        1 
set replace_CG       0

#-----------#
# read file #
#-----------#


#---------------#
# set constrain #
#---------------#


set_ideal_network [get_ports rst_n]

#set_max_fanout 16 [get_designs high_fanout]

set_driving_cell -lib_cell BUF_X0P5B_A9PP140ZTR_C30 -library sc9mcpp140z_l28hpc_base_rvt_c30_ss_cworst_max_0p81v_125c [remove_from_collection [all_inputs] [get_ports clk]]
set_load [expr [load_of sc9mcpp140z_l28hpc_base_rvt_c30_ss_cworst_max_0p81v_125c/AND2_X11M_A9PP140ZTR_C30/A]*3] [all_outputs]

check_timing > $report_path/check_timing.rpt

#set_clock_gating_check -setup 0.1 -hold 0.1 [get_clocks clk]

if { $insert_CG } {
  #set power_cg_print_enable_condition true ;# print to where??
  #set compile_clock_gating_through_hierarchy true
  set_clock_gating_style -positive_edge_logic integrated \
    -negative_edge_logic integrated \
    -control_point before \
    -max_fanout 16 \
    -num_stage 1
  #insert_clock_gating -global
  compile_ultra -gate_clock
  # compile -gate_clock
  if { $replace_CG } {
    replace_clock_gates -global
    compile_ultra -inc
    #compile -inc
  }
} else {
  compile_ultra
  # compile
}

report_constraint -all_violators -verbose > $report_path/report_constraint.rpt
report_timing  -max_path 10           > $report_path/report_timing.rpt
report_timing -delay max -max_path 10 > $report_path/timing_setup.rpt
report_timing -delay min -max_path 10 > $report_path/timing_hold.rpt
report_area              > $report_path/report_area.rpt
report_area -hierarchy   > $report_path/report_area_hier.rpt
report_power             > $report_path/report_power.rpt
report_power -hierarchy  > $report_path/report_power_hier.rpt
report_net_fanout        > $report_path/report_net.rpt

write -format verilog -h $top_design -output $netlist_path/$top_design.v
write -format ddc -h $top_design -output $netlist_path/$top_design.ddc

write_sdc $sdc_path/$top_design.sdc

set_svf off