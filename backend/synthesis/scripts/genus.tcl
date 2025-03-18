

# Last update: 2024/05/08

#-----------------------------------------------------------------------------
# General Comments
#-----------------------------------------------------------------------------
puts "  "
puts "  "
puts "  "
puts "  "

#-----------------------------------------------------------------------------
# Main Custom Variables Design Dependent (set local)
#-----------------------------------------------------------------------------

set TECH_DIR $env(TECH_DIR)
set TECH_DIR_GSC $env(TECH_DIR_GSC)
set TECH_DIR_GPDK $env(TECH_DIR_GPDK)
set PROJECT_DIR $env(PROJECT_DIR)
set DESIGNS $env(DESIGNS)
set HDL_NAME $env(HDL_NAME)
set INTERCONNECT_MODE ple
set CELLS_DIR $env(CELLS_DIR)
#-----------------------------------------------------------------------------
# MAIN Custom Variables to be used in SDC (constraints file)
#-----------------------------------------------------------------------------

set MAIN_CLOCK_NAME clk
set MAIN_RST_NAME rst
set BEST_LIB_OPERATING_CONDITION PVT_1P32V_0C
set WORST_LIB_OPERATING_CONDITION PVT_0P9V_125C
set period_clk $env(period_clock)  ;# (100 ns = 10 MHz) (10 ns = 100 MHz) (2 ns = 500 MHz) (1 ns = 1 GHz)
set clk_uncertainty 0.25 ;# ns (“a guess”)
set clk_latency 0.35 ;# ns (“a guess”)
set in_delay 1 ;# ns
set out_delay 2.958 ;#ns 
set out_load 0.045 ;#pF 
set slew "146 164 264 252" ;#minimum rise, minimum fall, maximum rise and maximum fall 
set slew_min_rise 0.146 ;# ns
set slew_min_fall 0.164 ;# ns
set slew_max_rise 0.264 ;# ns
set slew_max_fall 0.252 ;# ns


#
set WORST_LIST {slow_vdd1v0_basicCells.lib} 
set BEST_LIST {fast_vdd1v2_basicCells.lib} 
set LEF_LIST {gsclib045_tech.lef gsclib045_macro.lef}
set WORST_CAP_LIST ${TECH_DIR_GPDK}/soce/gpdk045.basic.CapTbl
set QRC_LIST ${TECH_DIR_GPDK}/qrc/rcworst/qrcTechFile

puts $QRC_LIST

#-----------------------------------------------------------------------------
# Load Path File
#-----------------------------------------------------------------------------
source ${PROJECT_DIR}/backend/synthesis/scripts/common/path.tcl

#-----------------------------------------------------------------------------
# Load Tech File
#-----------------------------------------------------------------------------
source ${SCRIPT_DIR}/common/tech.tcl

#-----------------------------------------------------------------------------
# Analyze RTL source (manually set; file_list.tcl is not covered in ELC1054)
#-----------------------------------------------------------------------------
set_db init_hdl_search_path "${DEV_DIR} ${FRONTEND_DIR}"
set rtl_files ${DESIGNS}.vhd
read_hdl -language vhdl $rtl_files

#-----------------------------------------------------------------------------
# Elaborate Design
#-----------------------------------------------------------------------------
elaborate ${HDL_NAME}
set_top_module ${HDL_NAME}
check_design -unresolved ${HDL_NAME}
get_db current_design
check_library


#-----------------------------------------------------------------------------
# Constraints
#-----------------------------------------------------------------------------
read_sdc ${BACKEND_DIR}/synthesis/constraints/constraints.sdc
report timing -lint


#-----------------------------------------------------------------------------
# Load Path File
#-----------------------------------------------------------------------------
create_clock -name $MAIN_CLOCK_NAME -period $period_clk [get_ports $MAIN_CLOCK_NAME]

#-----------------------------------------------------------------------------
# Pos "Elaborate" Attributes (manually set)
#-----------------------------------------------------------------------------
set_db auto_ungroup none ;# (none|both) ungrouping will not be performed

#------------------------------------------------------------------------------
#DFT 
define_test_mode -name TM -active high -create_port TM
set_db dft_scan_style muxed_scan
set_db dft_prefix dft_
define_shift_enable -name {scan_en} -active {high} -create_port {scan_en}
#define_shift_enable -name SE -active high -create_port SE
check_dft_rules


#-----------------------------------------------------------------------------
# Generic optimization (technology independent)
#-----------------------------------------------------------------------------
syn_generic ${HDL_NAME} 

#-----------------------------------------------------------------------------
# Agressively optimization (area, timing, power) and mapping
#-----------------------------------------------------------------------------
syn_map ${HDL_NAME}
get_db insts .base_cell.name -u ;# List all cell names used in the current design.

####Mais uma vez, vamos checar######
check_dft_rules

#Outros passos ainda de DFT#####
set_db design:${HDL_NAME} .dft_min_number_of_scan_chains 1
define_scan_chain -name top_chain -sdi scan_in -sdo scan_out -create_ports
connect_scan_chains -auto_create_chains
syn_opt -incr
report_scan_chains


#-----------------------------------------------------------------------------
# Report power with or without VCD
#-----------------------------------------------------------------------------
report_power > ${RPT_DIR}/${HDL_NAME}_power.rpt
#read_vcd ${PROJECT_DIR}/frontend/multiplier32FP_${period_clk}ns_rtl_t.vcd
#report_power > ${RPT_DIR}/${HDL_NAME}_power_${period_clk}ns_t.rpt

#read_vcd ${PROJECT_DIR}/frontend/multiplier32FP_${period_clk}ns_rtl_2t.vcd
#report_power > ${RPT_DIR}/${HDL_NAME}_power_${period_clk}ns_2t.rpt


#-----------------------------------------------------------------------------
# Preparing and generating output data (reports, verilog netlist)
#-----------------------------------------------------------------------------
report_design_rules > ${RPT_DIR}/${HDL_NAME}_drc.rpt
report_area > ${RPT_DIR}/${HDL_NAME}_area.rpt
report_timing > ${RPT_DIR}/${HDL_NAME}_timing.rpt
report_gates > ${RPT_DIR}/${HDL_NAME}_gates.rpt
report_qor > ${RPT_DIR}/${HDL_NAME}_qor.rpt
source ../scripts/common/sdf_width_wa.etf
write_sdf -edge check_edge -setuphold merge_always -nonegchecks -recrem merge_always -version 3.0 -design ${HDL_NAME}  > ${DEV_DIR}/${HDL_NAME}_worst.sdf
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > ${DEV_DIR}/dft_delays.sdf
write_hdl ${HDL_NAME} > ${DEV_DIR}/${HDL_NAME}_dft.v
write_sdc > ${DEV_DIR}/${HDL_NAME}_sdc_dft.sdc
write_scandef >${DEV_DIR}/${HDL_NAME}_scanDEF.scandef
write_dft_atpg -library ${CELLS_DIR}/slow_vdd1v0_basicCells.v
gui_show
