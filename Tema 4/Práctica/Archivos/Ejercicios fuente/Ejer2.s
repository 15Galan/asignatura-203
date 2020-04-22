        .set    GPBASE,   0x3F200000
        .set    GPFSEL0,        0x00
	.set    GPFSEL1,        0x04
        .set    GPSET0,         0x1c
        .set    GPCLR0,         0x28
	.set	GPLEV0,		0x34
 
.text	
        ldr     r0, =GPBASE
/* guia bits           xx999888777666555444333222111000*/
        mov   	r1, #0b00001000000000000000000000000000
        str	r1, [r0, #GPFSEL0]  @ Configura GPIO 9, 3 y 4
/* guia bits           xx999888777666555444333222111000*/
        mov   	r1, #0b00000000000000000000000000000001
        str	r1, [r0, #GPFSEL1]  @ Configura GPIO 10

/* guia bits           10987654321098765432109876543210*/
        mov   	r1, #0b00000000000000000000011000000000
        str     r1, [r0, #GPSET0]   @ Enciende GPIO 9 y GPI10

bucle:	
	ldr	r1, [r0, #GPLEV0]
	ands	r2, r1, #0b00000000000000000000000000000100
	beq	pulsador1
	ands	r2, r1, #0b00000000000000000000000000001000
	beq	pulsador2
	b 	bucle

pulsador1:	
/* guia bits           10987654321098765432109876543210*/
        mov   	r1, #0b00000000000000000000001000000000
        str     r1, [r0, #GPSET0]   @ Enciende GPIO 9
/* guia bits           10987654321098765432109876543210*/
        mov   	r1, #0b00000000000000000000010000000000
        str     r1, [r0, #GPCLR0]   @ Apaga GPIO 10
	b 	bucle
pulsador2:
/* guia bits           10987654321098765432109876543210*/
        mov   	r1, #0b00000000000000000000010000000000
        str     r1, [r0, #GPSET0]   @ Enciende GPIO 10
/* guia bits           10987654321098765432109876543210*/
        mov   	r1, #0b00000000000000000000001000000000
        str     r1, [r0, #GPCLR0]   @ Apaga GPIO 9
	b 	bucle

