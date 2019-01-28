# get the directory where this script resides
set thisDir [file dirname [info script]]
# source common utilities
source -notrace $thisDir/utils.tcl

# passed into this script w/ -tclargs option to specify
# whether to reuse golden sources or rebuild all from scratch
# set this variable to 1 to reuse the latest "golden"
# sources checked into revision control repository
# and set it to 0 to use the local users "sandbox"
# which is rebuilt from scratch
if {[llength $argv] > 0 && "$argv" eq "reuseGolden"} {
   set reuseGolden 1
} else {
   set reuseGolden 0
}

# these variables point to the root directory location
# of various source types - change this to point to 
# any directory location accessible to the machine
set repoRoot ./
set localRoot ./


set PROJ 	"xyv"
set PART	"xc7a200tsbg484-1"
set BOARD	"digilentinc.com:nexys_video:part0:1.1"
set BD_NAME		"designFirst"

# Create project
create_project -force $PROJ $localRoot/works -part $PART

# setup up custom ip repository location
set_property ip_repo_paths "$repoRoot" [current_fileset]
update_ip_catalog

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects $PROJ]
#set_property "board_part" "xilinx.com:zc702:part0:1.0" $obj
#set_property "simulator_language" "Mixed" $obj
#set_property "target_language" "Verilog" $obj

set_property "board_part" $BOARD $obj
set_property "simulator_language" "VHDL" $obj
set_property "target_language" "VHDL" $obj


puts "INFO: Project created:$PROJ"

# Source the bd.tcl file to create the bd with custom ip module
# first get the major.minor version of the tool - and source
# the bd creation script that corresponds to the current tool version
set currVer [join [lrange [split [version -short] "."] 0 1] "."]
puts "Current Version $currVer"

source $thisDir/bdFirst.tcl

validate_bd_design
save_bd_design

# Generate Target
# set_property synth_checkpoint_mode Singular [get_files */${BD_NAME}.bd]

#create_fileset -blockset -define_from zynq_bd zynq_bd
# generate_target all [get_files */${BD_NAME}.bd]
# create_ip_run [get_files */${BD_NAME}.bd]
# launch_runs ${BD_NAME}_synth_1
# wait_on_run ${BD_NAME}_synth_1 

 # Generate the wrapper
set design_name [get_bd_designs]
make_wrapper -files [get_files $design_name.bd] -top -import

# If successful, "touch" a file so the make utility will know it's done 
touch {.firstSetup.done}
