Repository of Version Control for FPGA/SDK projects
######################################################
Jan.13, 2019   Jack Lee


Version control of FPGA with Block Design
============================================
* Steps like ``Without Block Design``
* export block design by select ``File/Export/Export Block Design...`` to create design.tcl ;
* Comments "# Set 'sources_1' fileset object"
* Add following lines at the end of project tcl:

::

  # Create block design, JL
  source $origin_dir/design_1.tcl

  # Generate the wrapper
  set design_name [get_bd_designs]
  make_wrapper -files [get_files $design_name.bd] -top -import

  

Version control of FPGA without Block Design
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

  