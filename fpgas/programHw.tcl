# program bit file into fpga
# Jan.13, 2019  Jack Lee


set BIT_FILE "./oled/proj/OledDemo.runs/impl_1/top.bin"

open_hw

# connect_hw_server

open_hw_target

current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]

set_property PROGRAM.FILE [ list $BIT_FILE ] [lindex [get_hw_devices] 0]
set_property PROBES.FILE {} [lindex [get_hw_devices] 0]
set_property FULL_PROBES.FILE {} [lindex [get_hw_devices] 0]

program_hw_devices [lindex [get_hw_devices] 0]

refresh_hw_device [lindex [get_hw_devices] 0]
