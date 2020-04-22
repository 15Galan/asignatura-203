.set    GPBASE,		0x3F200000
.set    GPFSEL1,	0x04
.set    GPSET0,		0x1c
.set    GPCLR0,		0x28
.set    STBASE,   	0x3F003000
.set    STCLO,		0x04

.include "inter.inc"

.text
// -------------------------------------------------------------
	mrs     r0, cpsr
	mov     r0, #0b11010011     @ Modo SVC, FIQ y IRQ desactivados
	msr     spsr_cxsf, r0
	add     r0, pc, #4
	msr     ELR_hyp, r0
	eret
// -------------------------------------------------------------
	
	mov     r0, #0b11010011     @ Modo SVC, FIQ y IRQ desactivados
	msr		cpsr_c, r0
	mov 	sp, #0x8000000		@ Inicialicion de la pila en modo SVC
	
	ldr     r4, =GPBASE
	
	/* Guia bits   __999888777666555444333222111000 */
	mov		r5, #0b00000000001000000000000000000000
	str		r5, [r4, #GPFSEL1] 							@ Configura GPIO 17 (led amarillo) como salida
	
	/* Guia bits   ..987654321098765432109876543210 */
	mov		r5, #0b00000000000000100000000000000000
	
	ldr   	r0, =STBASE    		@ Parametro de espera (dir. base ST)
	ldr		r1, =1000000		@ Parametro de espera (en msegundos)
	
bucle:	
	bl      espera        		@ Saltar a la rutina de espera
	str     r5, [r4, #GPSET0]	@ Encender el led amarillo (GPIO 17)
	bl      espera        		@ Saltar a la rutina de espera
	str     r5, [r4, #GPCLR0]	@ Apagar el led amarillo (GPIO 17)
	
	b       bucle

espera:	
	push	{r4, r5}            @ Almacena r4 y r5 en la pila
	
	ldr		r4, [r0, #STCLO]	@ Lee el contador en r4
	add		r4, r1            	@ Añade tiempo al contador
	
ret1: 	
	ldr		r5, [r0, #STCLO]
	cmp		r5, r4            	@ Leemos CLO hasta alcanzar
	blo		ret1           		@ el valor de r4 (contador)
	pop		{r4, r5}
	bx		lr
