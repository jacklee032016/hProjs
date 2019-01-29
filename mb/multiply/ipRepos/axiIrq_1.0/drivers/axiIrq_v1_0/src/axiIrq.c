

/***************************** Include Files *******************************/
#include "axiIrq.h"

/************************** Function Definitions ***************************/

void AXIIRQ_EnableInterrupt(void * baseaddr_p)
{
	Xuint32 baseaddr;
	baseaddr = (Xuint32) baseaddr_p;
	/*
	* Enable all interrupt source from user logic.
	*/
	AXIIRQ_mWriteReg(baseaddr, 0x4, 0x1); // offset 0x04, value 0x01
	/*
	* Set global interrupt enable.
	*/
	AXIIRQ_mWriteReg(baseaddr, 0x0, 0x1); // offset 0x0, value 0x01
}
 
 
void AXIIRQ_ACK(void * baseaddr_p)
{
	Xuint32 baseaddr;
	baseaddr = (Xuint32) baseaddr_p;
	
	/*
	* ACK interrupts on MYIP_WITH_INTERRUPTS.
	*/
	AXIIRQ_mWriteReg(baseaddr, 0xc, 0x1); 	// offset 0x0c, value 0x01
}
