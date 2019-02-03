HW_NAME=vMicroBlaze_wrapper
OUTPUT_DIR=output

echo "Build download bitstream containing FSBL..."
mkdir -p $OUTPUT_DIR

updatemem -force -meminfo $HW_NAME.mmi -bit $HW_NAME.bit -data executable.elf -proc vMicroBlaze_i/microblaze_0 -out $OUTPUT_DIR/system.bit 
