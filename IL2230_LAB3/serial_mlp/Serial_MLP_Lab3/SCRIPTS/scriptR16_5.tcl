#tclsh 8.6
####### Set Directary #########
set LIB typical
set SYNDIR /afs/kth.se/home/d/e/debrajd/HWAFDL_Lab/Serial_MLP_Lab3/
set SRCDIR ${SYNDIR}/SOURCE
set SCRDIR ${SYNDIR}/SCRIPTS
set RPTDIR ${SYNDIR}/REPORTS
set SYNDB ${SYNDIR}/db
####### Set Global Libraries #########
source ${SYNDIR}/synopsys_dc.setup
######Enviroment############
define_design_lib WORK -path $SYNDIR/WORK
######Read Design###########
analyze -library WORK -format vhdl ${SRCDIR}/neuron_pkgR16_5.vhd
analyze -library WORK -format vhdl ${SRCDIR}/deb_para_neuron.vhd
analyze -library WORK -format verilog ${SRCDIR}/activation.v
analyze -library WORK -format verilog ${SRCDIR}/activationStep.v
analyze -library WORK -format verilog ${SRCDIR}/activationSigmoid.v
analyze -library WORK -format vhdl ${SRCDIR}/serial_mlp_one_process.vhd
######Elaborate Design###########
elaborate serial_mlp1 -lib WORK
########Set Constraints#############
set_wire_load_mode top
set_wire_load_selection_group WireAreaLowkCon
set_operating_conditions -library tcbn90gtc NCCOM
create_clock -name "clk" -period 5 -waveform { 0 2.5 } { clk }
set_false_path -setup -reset_path -from { rst_n }
set_false_path -hold -reset_path -from { rst_n }
#######Compile Option############
compile -map_effort medium
#######Report####################
report_timing > ${RPTDIR}/report_timingR16_5.rpt
report_area > 	${RPTDIR}/report_areaR16_5.rpt
report_cell > 	${RPTDIR}/report_cellR16_5.rpt
report_power -analysis_effort low > $RPTDIR/report_powerR16_5.rpt
#######Save Design####################
write -hierarchy -format ddc -output ${SYNDB}/mainR16_5.ddc
write -format verilog -hier -o ${SYNDB}/mainR16_5.v
write_sdf -version 2.1 ${SYNDB}/mainR16_5.sdf