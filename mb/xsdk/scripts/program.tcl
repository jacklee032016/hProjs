# program bitstream into FPGA chip, works in Vivado and XSDK
# Jack Lee

# get the directory where this script resides
set thisDir [file dirname [info script]]
# source common utilities
source -notrace $thisDir/utils.tcl
source -notrace $thisDir/params.tcl

#set PROJ $::env(MODULE)
#set PROJ $::env(MODULE)

set PROJ "download"

set BIT_FILE "$output_dir/$PROJ.bit"
puts "Open bitstream file $PROJ.bit..."

# open_hw: to initialize the labtools system
open_hw
# this line is not needed in XSDK 
connect_hw_server
open_hw_target

# Connect to the Digilent Cable on localhost:3121
# connect_hw_server -url localhost:3121
# current_hw_target [get_hw_targets */xilinx_tcf/Digilent/12345]
# open_hw_target

current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]

set_property PROGRAM.FILE [ list $BIT_FILE ] [lindex [get_hw_devices] 0]
set_property PROBES.FILE {} [lindex [get_hw_devices] 0]
set_property FULL_PROBES.FILE {} [lindex [get_hw_devices] 0]

program_hw_devices [lindex [get_hw_devices] 0]

refresh_hw_device [lindex [get_hw_devices] 0]
