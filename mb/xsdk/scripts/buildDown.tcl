HW_NAME=vMicroBlaze_wrapper
OUTPUT_DIR=output

puts "Build download bitstream containing FSBL..."

updatemem -force -meminfo $HW_NAME.mmi -bit $HW_NAME.bit -data executable.elf -proc vMicroBlaze_i/microblaze_0 -out $OUTPUT_DIR/system.bit 

