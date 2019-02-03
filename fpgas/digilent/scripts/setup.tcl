# get the directory where this script resides
set thisDir [file dirname [info script]]

set PROJ $::env(MODULE)

puts "The project is: $PROJ"
# exit 2

# source common utilities
source -notrace $thisDir/utils.tcl

set hdlRoot ./src/hdl
set xdcRoot ./src/constraints

# Set the board part number
set part_num "xc7a200tsbg484-1"

# Create project
create_project -force ${PROJ} ./works/${PROJ}/ 


# Set project properties
set obj [get_projects ${PROJ}]
set_property "default_lib" "xil_defaultlib" $obj
set_property "part" "$part_num" $obj
#set_property "board_part" "" $obj
# Mixed, VHDL, or Verilog
set_property "simulator_language" "Mixed" $obj
set_property "target_language" "Verilog" $obj 


# ## create fileset of sources_1 and constrs_1
# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}


# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}


# Add sources
add_files -quiet $hdlRoot/$PROJ

# Add IPs
#add_files -quiet [glob -nocomplain ../src/ip/*/*.xci]
#add_files -quiet [glob -nocomplain ../src/ip/*/*.xco]

# Add constraints
#add_files -fileset constrs_1 -quiet $xdcRoot/
add_files -fileset constrs_1 -norecurse $xdcRoot/xdc$PROJ.xdc


update_compile_order -fileset sources_1

# If successful, "touch" a file so the make utility will know it's done 
# touch .$PROJ.done
touch .setup.done

puts "INFO: Project created:$PROJ"
