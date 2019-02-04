/******************************************************************************
*
* (c) Copyright 2013-2016 Xilinx, Inc. All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* XILINX CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
*******************************************************************************/
#include "fs-boot.h"
#ifdef CONFIG_PRIMARY_FLASH_SPI
#include "spi-flash.h"
#include "fs-xspi.h"

#ifndef SPI_CS
#define SPI_CS 0
#endif

#ifndef SPI_FLASH_SIZE
#define SPI_FLASH_SIZE 0x2000000
#endif

#define SPI_FLASH_16MB_BOUN 0x1000000

#define OPCODE_FAST_READ 0x0b
#define OPCODE_QUAD_READ 0x6B
#define OPCODE_READ_ID   0x9F
#define OPCODE_READ_STATUS 0x05
#define OPCODE_WRITE_ENABLE 0x06
#define OPCODE_WRITE_DISABLE 0x04
#define OPCODE_BANKADDR_BRWR 0x17
#define OPCODE_BANKADDR_BRRD 0x16
#define OPCODE_EXTNADDR_WREAR 0xC5
#define OPCODE_EXTNADDR_RDEAR 0xC8
#define OPCODE_EX4B 0xE9

int spi_flash_probe()
{
	unsigned char cmd[6];
	unsigned char bankaddr_wr, bankaddr_rd;
	unsigned int bank_sel = 0;
	xspi_init(0, 0);


	/* The following part of this function is
	 * to check the init status of the SPI flash
	 * different flash will have different init
	 * status requirements, please modify this part
	 * for your own device.
	 * This function has only been tested on Xilinx AC701.
	 * By default, fs-boot assumes the boot image is
	 * in one bank only, but not cross banks.
	 */

	/* Read jedec id */
	/* We will need to read the jedec id twice.
	 * This is the work around for the startup
	 * block issue in the spi controller. SPI clock
	 * is passing through STARTUP block to FLASH.
	 * STARTUP block don’t provide clock as soon as
	 * QSPI provides command. So first command fails.
	 */
	xspi_xfersetup(SPI_CS);
	cmd[0] = OPCODE_READ_ID;
	xspi_xfer(cmd, 1, 0, 0);
	xspi_xfer(0, 5, &cmd[1], 1);
	xspi_xfersetup(SPI_CS);
	xspi_xfer(cmd, 1, 0, 0);
	xspi_xfer(0, 5, cmd, 1);

	debug_fsprint_integer("JEDEC ", "\r\n", (unsigned)cmd[0]);
	debug_fsprint_integer("JEDEC ", "\r\n", (unsigned)cmd[1]);
	debug_fsprint_integer("JEDEC ", "\r\n", (unsigned)cmd[2]);
	debug_fsprint_integer("JEDEC ", "\r\n", (unsigned)cmd[3]);
	debug_fsprint_integer("JEDEC ", "\r\n", (unsigned)cmd[4]);

	if (SPI_FLASH_SIZE > SPI_FLASH_16MB_BOUN) {
		if (cmd[0] == 1) {
			bankaddr_wr = OPCODE_BANKADDR_BRWR;
			bankaddr_rd = OPCODE_BANKADDR_BRRD;
		} else {
			bankaddr_wr = OPCODE_EXTNADDR_WREAR;
			bankaddr_rd = OPCODE_EXTNADDR_RDEAR;
		}
		bank_sel = CONFIG_FS_BOOT_START >> 24;
		cmd[0]=OPCODE_WRITE_ENABLE;
		xspi_xfersetup(SPI_CS);
		xspi_xfer(cmd, 1, 0, 1);

		cmd[0]=OPCODE_EX4B;
		xspi_xfersetup(SPI_CS);
		xspi_xfer(cmd, 1, 0, 1);

		cmd[0]=OPCODE_WRITE_DISABLE;
		xspi_xfersetup(SPI_CS);
		xspi_xfer(cmd, 1, 0, 1);

		cmd[0]=OPCODE_WRITE_ENABLE;
		xspi_xfersetup(SPI_CS);
		xspi_xfer(cmd, 1, 0, 1);

		cmd[0]=bankaddr_wr;
		cmd[1]=bank_sel;
		xspi_xfersetup(SPI_CS);
		xspi_xfer(cmd, 1, 0, 0);
		xspi_xfer(&cmd[1], 1, 0, 1);

		cmd[0]=OPCODE_READ_STATUS;
		xspi_xfersetup(SPI_CS);
		xspi_xfer(cmd, 1, 0, 0);
		xspi_xfer(0, 1, &cmd[1], 1);

		cmd[0]=OPCODE_WRITE_DISABLE;
		xspi_xfersetup(SPI_CS);
		xspi_xfer(cmd, 1, 0, 1);
	}

	return 0;
}


int spi_flash_read(unsigned long offset, unsigned char *rx, int rxlen, char startflag, char endflag)
{
	unsigned char cmd[8];

	if (rx == 0 || rxlen == 0)
		return -1;

#if 0
	if (XSP_SPI_MODE == XSP_SPI_QUAD_MODE)
	{
//		cmd[0] = OPCODE_QUAD_READ;
		cmd[0] = OPCODE_FAST_READ;
//		cmd[0] = 0x03;
	}
	else
#endif		
	{
		cmd [0] = OPCODE_FAST_READ;
	}
	cmd[1] = (unsigned char) (offset >> 16);
	cmd[2] = (unsigned char) (offset >> 8);
	cmd[3] = (unsigned char) (offset);
	cmd[4] = 0;

	if (startflag)
		xspi_xfersetup(SPI_CS);

#if 0
	if (XSP_SPI_MODE == XSP_SPI_QUAD_MODE)
	{
		if (xspi_xfer(cmd, 8, 0, 0) != 0)
			return -1;
	}
	else
#endif

	{
		if (xspi_xfer(cmd, 5, 0, 0) != 0)
			return -1;
	}

	if (endflag)
		return xspi_xfer(0, rxlen, rx, 1);
	else
		return xspi_xfer(0, rxlen, rx, 0);
}
#endif