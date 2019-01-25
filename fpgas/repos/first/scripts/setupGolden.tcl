# get the directory where this script resides
set thisDir [file dirname [info script]]

# source common utilities
source -notrace $thisDir/utils.tcl

set hdlRoot ./src/hdl
set xdcRoot ./src/constraints

set PROJ "golden"

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

add_files -norecurse $hdlRoot/goldenMainCtrl.vhd

add_files -norecurse $xdcRoot/topGolden.xdc
add_files -norecurse $xdcRoot/board.xdc

# If successful, "touch" a file so the make utility will know it's done 
touch {.setupGolden.done}
