# get the directory where this script resides
set thisDir [file dirname [info script]]

# source common utilities
source -notrace $thisDir/utils.tcl

set hdlRoot ./src/hdl
set xdcRoot ./src/constraints

set PROJ "ledCtrl"

# Create project
create_project -force ${PROJ} ./works/${PROJ}/ -part xc7a75tfgg676-2 
# xc7k325tffg900-2

# Set project properties
set obj [get_projects ${PROJ}]

#set_property "board_part" "xilinx.com:kc705:part0:1.2" $obj
#set_property "simulator_language" "Mixed" $obj
#set_property "target_language" "Verilog" $obj

set_property "board_part" "" $obj
set_property "simulator_language" "VHDL" $obj
set_property "target_language" "VHDL" $obj

##### Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

add_files -fileset sources_1 -norecurse $hdlRoot/ledTimeCtrl.vhd

##### Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

##### add constraints file into constrs_1
add_files -fileset constrs_1 -norecurse $xdcRoot/topLedTimeCtl.xdc
add_files -fileset constrs_1 -norecurse $xdcRoot/board.xdc

# If successful, "touch" a file so the make utility will know it's done 
touch {.setupLedCtrl.done}
