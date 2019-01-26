# compile for PicoBlaze + UART
# Jack Lee

# get the directory where this script resides
set thisDir [file dirname [info script]]
# source common utilities
source -notrace $thisDir/utils.tcl

set PROJ "picoUart"

# Create project
open_project ./works/${PROJ}/${PROJ}.xpr

# Implement and write_bitstream
launch_runs impl_1 
wait_on_run impl_1
open_run impl_1

write_bitstream ${PROJ}.bit

# If successful, "touch" a file so the make utility will know it's done 
touch {.compilePicoUart.done}
