        .set    GPBASE,   0x3F200000
        .set    GPFSEL0,        0x00
        .set    GPSET0,         0x1c
        .set    GPCLR0,         0x28
        .set    STBASE,   0x3F003000
        .set    STCLO,          0x04
.text
	mov 	r0, #0b11010011
	msr	cpsr_c, r0
	mov 	sp, #0x8000000	@ Inicializ. pila en modo SVC
	
        ldr     r4, =GPBASE
/* guia bits           xx999888777666555444333222111000*/
        mov   	r5, #0b00000000000000000001000000000000
        str	r5, [r4, #GPFSEL0]  @ Configura GPIO 4
/* guia bits           10987654321098765432109876543210*/
        mov	r5, #0b00000000000000000000000000010000
        ldr	r0, =STBASE	@ r0 es un parametro de sonido (dir base ST)
	ldr	r1, =1136	@ r1 es un parametro de sonido (periodo/2)

bucle:	bl     	sonido		@ Salta a rutina de sonido
        str    	r5, [r4, #GPSET0]
        bl     	sonido 		@ Salta a rutina de sonido
        str     r5, [r4, #GPCLR0]
        b       bucle

/* rutina que espera r1 microsegundos */
sonido: 
	push	{r4,r5}
        ldr     r4, [r0, #STCLO]  @ Lee contador en r4
        add    	r4, r1    	  @ r4= r4 + perido/2
ret1: 	ldr     r5, [r0, #STCLO]
        cmp	r5, r4            @ Leemos CLO hasta alcanzar
        blo     ret1              @ el valor de r4
	pop	{r4,r5}
        bx      lr
