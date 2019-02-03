README for Digilent projects with Makefile
############################################
Fevier 3, 2019

Todo
==============================
* load bitstream of FPGA with Makefile;
* support mixed HDL languages;
* support charlib and IP packages;


Build Process
==============================
Verilog only projects

::

   set environment variable of MODULE=oled|keyboard
   make setup: create vivado project in works/$MODULE/$MODULE.xpr
   make build: compile the project and generate bit file in current directory


Structure of Directory
=============================

::

    scripts/ : tcl script for setup, build and program bitstream
    src/constrains
        hdl/oled
             /keyboard
   	Makefile
    readme.rst	
   
Support Projects 
=============================
#. oled: 
   * reset button to make LED0 bright;
   * Central button to make OLED birght/dark;
   * Up/Bottom buttons to make string display/disappear in OLED;
#. keyboard:
   * USB keyboard insert into USB port;
   * key code output in debug serial port (9600 bps);
   

	