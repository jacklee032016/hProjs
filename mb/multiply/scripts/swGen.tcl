# Create software projects from hardware definition
# Usage: enter into 'xsct', and 'source createSwProject.tcl
# 11.07, 2018


set SYS "designFirst_wrapper"
# set SYS "xyv"
# set SYS mb767


set HW_DEF		$SYS.hdf
set WORKSPACE	ws

set HW_PROJECT						hwProj
set DEVICE_TREE_PROJECT		deviceTreeBsp
set BSP_PROJECT						bspProj
set APP_PROJECT_HELLO			appHello
set APP_PROJECT_LWIP			appLwip


# 'device-tree-xlnx' in this repo directory
set REPO_DIR			../repo

# command in vivado to start HSI

# common::load_feature hsi
# hsi::open_hw_design 

puts "############################################"
puts "Create projects for hardware $HW_DEF"
puts "############################################\r\n"

puts "-------------------------------------------"
puts "Step 1: create workspace '$WORKSPACE'"
puts "-------------------------------------------"

# create a directory of 'workspace';
setws ./$WORKSPACE
# repo -set $REPO_DIR
repo -os

puts "\r\n-------------------------------------------"
puts "Step 2: create hardware project '$HW_PROJECT'"
puts "-------------------------------------------"

createhw -name $HW_PROJECT -hwspec $HW_DEF 



puts "\r\n-------------------------------------------"
puts "Step 3: create Device Tree BSP project '$DEVICE_TREE_PROJECT'"
puts "-------------------------------------------"
# hw project and processor must be defined
# specify a processor instance or a mss file to create a BSP project
# processor instance can be gotten with 'hsi get_cells'
# xparameters.h is created

# createbsp -name $DEVICE_TREE_PROJECT -hwproject $HW_PROJECT -proc microblaze_0 -os device_tree


puts "\r\n-------------------------------------------"
puts "Step 4: create BSP project '$BSP_PROJECT'"
puts "-------------------------------------------"
# hw project and processor must be defined
# specify a processor instance or a mss file to create a BSP project
# processor instance can be gotten with 'hsi get_cells'
# xparameters.h is created

createbsp -name $BSP_PROJECT -hwproject $HW_PROJECT -proc microblaze_0


# BSP must be regenratte after settings are changed
puts "\tregenerate $BSP_PROJECT......"
regenbsp -bsp $BSP_PROJECT



puts "\r\n-------------------------------------------"
puts "Step 5: create App projecte '$APP_PROJECT_HELLO' and '$APP_PROJECT_LWIP'"
puts "-------------------------------------------"

puts "\tcreate app project ' $APP_PROJECT_HELLO'....."
createapp -name $APP_PROJECT_HELLO -hwproject $HW_PROJECT -proc microblaze_0 -bsp $BSP_PROJECT -app "Hello World" 

# puts "\tcreate app project ' $APP_PROJECT_LWIP'....."
# createapp -name $APP_PROJECT_LWIP -hwproject $HW_PROJECT -proc microblaze_0 -bsp $BSP_PROJECT -app "lwIP Echo Server" 



puts "\r\n-------------------------------------------"
puts "Step 6: Build all"
puts "-------------------------------------------"
# build all projects
projects -build 


puts "\r\n-------------------------------------------"
puts "Step 6: Build Binary Device Tree"
puts "-------------------------------------------"

# exec dtc -I dts -O dtb -o $WORKSPACE/system-top.dtb $WORKSPACE/$DEVICE_TREE_PROJECT/system-top.dts 

