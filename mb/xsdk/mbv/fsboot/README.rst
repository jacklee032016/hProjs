Readme of fsboot
#########################

What is fsboot
==================
* Program into ROM of FPGA firmware;
* Initialize UART and SPI flash;
* Load bootloader from SPI flash;


Logs
---------

**Nov.14, 2018**
* Work with VideoSys CPU and S25fl256 flash: read command(0x0b) + 5 bytes transfer;
* Not work with qemu even with correct flash chip configuration in DTB;
