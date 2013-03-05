/*
 * Copyright (c) 2009 Xilinx, Inc.  All rights reserved.
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

/*
 * helloworld.c: simple test application
 */

#include <stdio.h>
#include "platform.h"
#include <xparameters.h>

extern void xil_printf(const char *ctrl1, ...);

#define SET 	0x4
#define ENABLE 	0x2
#define RESET 	0x1
#define DONE 	0x1

#define WAIT_FOR_DONE(addr) while((*addr & DONE) != DONE) { xil_printf("%x\n\r", *addr); };

void print(char *str);

int main() {

	volatile unsigned int *gpio = (unsigned int *) XPAR_XPS_GPIO_0_BASEADDR,
                          *gpio_tristate = (unsigned int *) (XPAR_XPS_GPIO_0_BASEADDR + 0x04),
                          *gpio2 = (unsigned int *) (XPAR_XPS_GPIO_0_BASEADDR + 0x08);
	init_platform();

	*gpio_tristate = 0x0;
	int i, j;

	xil_printf("Foo\r\n");

	*gpio = RESET;
	*gpio = 0;

	xil_printf("reset\n\r");

	// key schreiben 128 bits

	volatile unsigned int *mem = (unsigned int *) XPAR_XPS_BRAM_IF_CNTLR_0_BASEADDR;

	for (i = 0; i < 4; i++) {
		mem[i+4] = i+1;
	}

	xil_printf("Key: %X %X %X %X \r\n", mem[0], mem[1], mem[2], mem[3]);

	// enable set
	*gpio = SET;

	WAIT_FOR_DONE(gpio2);

	xil_printf("set done\n\r");

	*gpio = 0;

	for (j = 0; j < 10; j++) {
		// write data
		for (i = 0; i < 4; i ++) {
			mem[i] = j;
		}

		//xil_printf("data written\n\r");

		*gpio = ENABLE;
		*gpio = 0;
		WAIT_FOR_DONE(gpio2);

		// xil_printf("encryption done\n\r");
		xil_printf("Result: %X %X %X %X \r\n", mem[0], mem[1], mem[2], mem[3]);

	}

	cleanup_platform();

	return 0;
}
