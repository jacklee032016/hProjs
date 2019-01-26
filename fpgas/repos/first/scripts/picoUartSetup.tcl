# PicoBlaze + UART
# Rebuild with script from scratch
# 01.26, 2019   Jack Lee

# get the directory where this script resides
set thisDir [file dirname [info script]]

# source common utilities
source -notrace $thisDir/utils.tcl

set hdlRoot ./src/hdl
set xdcRoot ./src/constraints

set PROJ "picoUart"

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

###### Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# top module
add_files -norecurse $hdlRoot/$PROJ/pico_board767.vhd

add_files -norecurse $hdlRoot/$PROJ/uart_rx6.vhd
add_files -norecurse $hdlRoot/$PROJ/uart_tx6.vhd

# KCPSM6 - PicoBlaze for Spartan-6 and Virtex-6 devices
add_files -norecurse $hdlRoot/$PROJ/kcpsm6.vhd
# This file is created by assemble code
add_files -norecurse $hdlRoot/$PROJ/auto_baud_rate_control.vhd


# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}
#add_files -fileset constrs_1 -quiet $src_dir/constraints

add_files -fileset constrs_1 -norecurse $xdcRoot/top.xdc
add_files -fileset constrs_1 -norecurse $xdcRoot/board.xdc

update_compile_order -fileset sources_1

# If successful, "touch" a file so the make utility will know it's done 
touch {.setupPicoUart.done}
