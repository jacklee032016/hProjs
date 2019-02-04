set PROJ 			"xyv"
set PART			"xc7a200tsbg484-1"
set BOARD			"digilentinc.com:nexys_video:part0:1.1"
set design_name		"designFirst"

set output_dir 		$::env(OUTPUT_DIR)
set hw_project 		$::env(HW_PROJECT)
set bsp_project 	$::env(BSP_PROJECT)
set fsboot_exe 		$::env(FS_BOOT_EXE)
set download_file 	$::env(DOWNLOAD_FILE)

puts "OUTPUT DIR: $output_dir"
puts "HW Project: $hw_project"
puts "BSP Project: $bsp_project"
puts "fsboot EXE: $fsboot_exe"
puts "Download bit: $download_file"
