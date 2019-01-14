GPIO Project
####################

LED is initialized, but no display output;

Port COM8
================
* setup: 9600
* After configured, display: "NEXYS VIDEO UART DEMO!", LED: "This is digilent's nexyz video"
* output "Button press detected" when one button is pressed;


Debug problem of module 'charlib' not found
=============================================
Copy ip/charlib from looper, and recreate project

::

   # Add IPs
   add_files -quiet [glob -nocomplain ../src/ip/*/*.xci]
   add_files -quiet [glob -nocomplain ../src/ip/*/*.xco]

