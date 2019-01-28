readme for making hardware definition
############################################

Steps for building hw def
================================
* scripts/bdBuild.tcl:
   * Block definition of Microblaze from previous project;
* ipRepos:
   * costom IP of AXI Lite slave interface and its repository
* make firstSetup:
   * rebuild project with block design and its top level wrapper file;
* Add mutiplier into block design with Vivado GUI;
* make firstCompile:
   * synthenticate and generate bitstream, and output hardware definition file;

   
Debugs   
=========================   
* IP (AXI Lite, Slave) repository
   * drivers must be included; and then drivers directory is created in SDK_WORKSPACE/HW_PROJECT;
   * otherwise, HW_PROJECT can't be created;
   
   