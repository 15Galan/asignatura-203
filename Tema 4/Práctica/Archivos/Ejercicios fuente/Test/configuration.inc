/* Configuration of all the I0 of the expansion board */
        .set    GPBASE,   0x3f200000
        .set    GPFSEL0,        0x00
        .set    GPFSEL1,        0x04
        .set    GPFSEL2,        0x08
.text
        ldr   r0, =GPBASE
	ldr   r1, [r0]  @, #GPFSEL0]    
	ldr r4, =0b11001111111111111001000000111111 @ Mask for forcing 0
	ldr r5, =0b00001000000000000001000000000000 @ Mask for forcing 1
	and r1,r1,r4
	orr    r1,r1,r5 
        str   r1, [r0, #GPFSEL0]  		@GPIO4&9 as output, GPIO2&3 as input
@ Configure of GPSEL1 (address 0x3F200004) for  GPIO 10,11,17
        ldr   r1, [r0, #GPFSEL1] 
	ldr r4, =0b11111111001111111111111111001001  @ Mask for forcing 0
	ldr r5, =0b00000000001000000000000000001001  @ Mask for forcing 1
	and r1,r1,r4
	orr    r1,r1,r5
        str   r1, [r0, #GPFSEL1] 		@GPIO10&11&17 as output
@ Configure of GPSEL2 (address 0x3F200008) for  GPIO 22,27
        ldr   r1, [r0, #GPFSEL2]
	ldr r4, =0b11111111001111111111111001111111  @ Mask for forcing 0
	ldr r5, =0b00000000001000000000000001000000  @ Mask for forcing 1
	and r1,r1,r4
	orr    r1,r1,r5
        str   r1, [r0, #GPFSEL2] 		@GPIO22&27 as output

