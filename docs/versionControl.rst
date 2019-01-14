Repository of Version Control for FPGA/SDK projects
######################################################
Jan.43, 2019   Jack Lee


Version control of FPGA with Block Design
============================================
* Select ``File/Write Project tcl...`` to output tcl file for creating whole project, includes block design;

* Modify build.tcl file as following:

::

  # set origin_dir "."
  # added JL. Set the reference directory to where the script is
  set origin_dir [file dirname [info script]]


  # create_project ${project_name} ./${project_name} -part xc7a200tsbg484-1
  # As following. J.L.
  create_project ${project_name} $origin_dir/${project_name} -part xc7a200tsbg484-1

* Recreate project:

::

  d:\Xilinx\Vivado\2017.4\bin\vivado.bat -mode batch -source build.tcl

  