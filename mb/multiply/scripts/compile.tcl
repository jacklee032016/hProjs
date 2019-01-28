# get the directory where this script resides
set thisDir [file dirname [info script]]
# source common utilities
source -notrace $thisDir/utils.tcl

set localRoot ./

set PROJ 	"xyv"

# Create project
open_project $localRoot/works/$PROJ.xpr

#launch_runs impl_1 -to_step write_bitstream
#launch_runs impl_1 -to_step write_bitstream -jobs 2

reset_run impl_1
launch_runs impl_1 
wait_on_run impl_1
open_run impl_1

write_bitstream $PROJ.bit

# export hardware
# file mkdir bd/works/xyv.sdk
# file copy -force bd/works/xyv.runs/impl_1/designFirst_wrapper.sysdef bd/designFirst_wrapper.hdf

# hwdef is hardware definition only
write_hwdef -file $PROJ.hwdef
# *.sysdef include bitstream and hardware definition
write_sysdef -bitfile $PROJ.bit -hwdef $PROJ.hwdef -file $PROJ.sysdef

# If successful, "touch" a file so the make utility will know it's done 
touch {.compile.done}
