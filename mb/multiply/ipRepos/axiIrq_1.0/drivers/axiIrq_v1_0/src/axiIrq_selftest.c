
/***************************** Include Files *******************************/
#include "axiIrq.h"
#include "xparameters.h"
#include "stdio.h"
#include "xil_io.h"

/************************** Constant Definitions ***************************/
#define READ_WRITE_MUL_FACTOR 0x10

/************************** Function Definitions ***************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the AXIIRQinstance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus AXIIRQ_Reg_SelfTest(void * baseaddr_p)
{
	u32 baseaddr;
	int write_loop_index;
	int read_loop_index;
	int Index;

	baseaddr = (u32) baseaddr_p;

	xil_printf("******************************\n\r");
	xil_printf("* User Peripheral Self Test\n\r");
	xil_printf("******************************\n\n\r");

	/*
	 * Write to user logic slave module register(s) and read back
	 */
	xil_printf("User logic slave module test...\n\r");

	for (write_loop_index = 0 ; write_loop_index < 4; write_loop_index++)
	  AXIIRQ_mWriteReg (baseaddr, write_loop_index*4, (write_loop_index+1)*READ_WRITE_MUL_FACTOR);
	for (read_loop_index = 0 ; read_loop_index < 4; read_loop_index++)
	  if ( AXIIRQ_mReadReg (baseaddr, read_loop_index*4) != (read_loop_index+1)*READ_WRITE_MUL_FACTOR){
	    xil_printf ("Error reading register value at address %x\n", (int)baseaddr + read_loop_index*4);
	    return XST_FAILURE;
	  }

	xil_printf("   - slave register write/read passed\n\n\r");

	return XST_SUCCESS;
}


#include "xintc_l.h"


#define MYIP_WITH_INTERRUPT 0x44a10000

volatile int count = 0;
void handler()
{
	count++;
	xil_printf("interrupt %d \n\r", count);
	MYIP_WITH_INTERRUPT_ACK(MYIP_WITH_INTERRUPT);
}

int AXIIRQ_irq_test()
{
	microblaze_enable_interrupts();
	
	XIntc_RegisterHandler(XPAR_INTC_SINGLE_BASEADDR,XPAR_AXI_INTC_0_MYIP_WITH_INTERRUPT_0_IRQ_INTR,
	(XInterruptHandler)handler, XPAR_INTC_SINGLE_BASEADDR);
	
	XIntc_MasterEnable(XPAR_INTC_SINGLE_BASEADDR);
	
	XIntc_EnableIntr(XPAR_INTC_SINGLE_BASEADDR, XPAR_MYIP_WITH_INTERRUPT_0_IRQ_MASK);
	
	MYIP_WITH_INTERRUPT_EnableInterrupt(MYIP_WITH_INTERRUPT);
	
	xil_printf("Wait for Interrupts.... \n\r");
	while(count < 10);
}
