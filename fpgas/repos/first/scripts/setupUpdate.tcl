# get the directory where this script resides
set thisDir [file dirname [info script]]

# source common utilities
source -notrace $thisDir/utils.tcl

set hdlRoot ./src/hdl
set xdcRoot ./src/constraints

set PROJ "update"

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

add_files -norecurse $hdlRoot/updateMainCtrl.vhd
add_files -norecurse $hdlRoot/cmn.vhd

add_files -norecurse $hdlRoot/i2cSlave/debounce.vhd
add_files -norecurse $hdlRoot/i2cSlave/I2C_slave.vhd
add_files -norecurse $hdlRoot/i2cSlave/i2cRegisters.vhd
add_files -norecurse $hdlRoot/i2cSlave/i2cSlaveEnhanced.vhd

add_files -norecurse $hdlRoot/suart/modCounter.vhd
add_files -norecurse $hdlRoot/suart/suart.vhd
add_files -norecurse $hdlRoot/suart/suartRx.vhd
add_files -norecurse $hdlRoot/suart/suartTx.vhd


add_files -norecurse $xdcRoot/topUpdate.xdc
add_files -norecurse $xdcRoot/board.xdc

# If successful, "touch" a file so the make utility will know it's done 
touch {.setup${PROJ}.done}
