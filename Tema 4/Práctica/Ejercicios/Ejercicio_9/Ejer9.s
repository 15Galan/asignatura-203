.include "inter.inc"

.text

// -------------------------------------------------------------
	mrs     r0, cpsr
	mov     r0, #0b11010011     @ FIQ y IRQ desabilitados
	msr     spsr_cxsf, r0
	add     r0, pc, #4
	msr     ELR_hyp, r0
	eret
// -------------------------------------------------------------

	mov 	r0, #0
	ADDEXC 	0x18, irq_handler
	
	mov     r0, #0b11010011     @ FIQ y IRQ desabilitados
	msr     cpsr_c, r0          @ Modo SVC activado
	mov     sp, #0x8000000      @ Inicializar la pila en modo SVC
	
	mov     r0, #0b11010010     @ FIQ y IRQ desabilitados
	msr     cpsr_c, r0          @ Modo SVC activado
	mov     sp, #0x80000      	@ Inicializar la pila en modo IRQ

configurar_leds:
	ldr 	r0, =GPBASE
	
    /* Guia bits   __999888777666555444333222111000 */
	ldr 	r1, =0b00001000000000000000000000000000
	str 	r1, [r0, #GPFSEL0]							@ Configurar un led rojo (GPIO 9) como salida
	
	ldr 	r1, =0b00000000001000000000000000001001
	str 	r1, [r0, #GPFSEL1]							@ Configurar un led rojo y los amarillos (GPIO 10, 11 y 17) como salida
	
	ldr 	r1, =0b00000000001000000000000001000000
	str 	r1, [r0, #GPFSEL2]							@ Configurar los leds verdes (GPIO 22 y 27) como salida
	
configurar_contador:
	ldr 	r6, =STBASE
	
	ldr 	r1, [r6, #STCLO]	@ Configura el contador
	ldr 	r4, =500000			@ Tiempo (msegundos)
	add 	r1, r4				@ Añadir el tiempo al contador
	str 	r1, [r6, #STC1]		@ Habilitar el contador C1
	
configurar_interrupciones:	
	ldr 	r7, =INTBASE
	
	mov 	r1, #0b0010				@ Habilitar la fuente de interrupcion
	str 	r1, [r7, #INTENIRQ1]	@ Interrupcion local IRQ habilitada (canal 1)
	
	mov 	r7, #0b01010011			@ Interrupcion global habilitada
	msr 	cpsr_c, r7


	/* Guia bits   ..987654321098765432109876543210 */
	ldr		r2, =0b00001000010000100000111000000000		@ Mascara para apagar todos los leds

bucle:
	ldr		r10, =contador
	ldr		r11, [r10]		@ r11 con contenido de "contador"	
	
	cmp		r11, #0										@ Si el contador es 0, ejecuta:
	moveq	r1, #0b00000000000000000000001000000000		@ Mascara para el led rojo (GPIO 9)
	streq	r2, [r0, #GPCLR0]							@ Apagar todos los leds
	streq	r1, [r0, #GPSET0]							@ Encender el led rojo (GPIO 9)
	
	cmp		r11, #1
	moveq	r1, #0b00000000000000000000010000000000		@ Mascara para el led rojo (GPIO 10)
	streq	r2, [r0, #GPCLR0]							@ Apagar todos los leds
	streq	r1, [r0, #GPSET0]							@ Encender el led rojo (GPIO 10)
	
	cmp		r11, #2
	moveq 	r1, #0b00000000000000000000100000000000		@ Mascara para el led amarillo (GPIO 11)
	streq	r2, [r0, #GPCLR0]							@ Apagar todos los leds
	streq	r1, [r0, #GPSET0]							@ Encender el led amarillo (GPIO 11)
	
	cmp		r11, #3
	moveq 	r1, #0b00000000000000100000000000000000		@ Mascara para el led amarillo (GPIO 17)
	streq	r2, [r0, #GPCLR0]							@ Apagar todos los leds
	streq	r1, [r0, #GPSET0]							@ Encender el led amarillo (GPIO 17)
	
	cmp		r11, #4
	moveq 	r1, #0b00000000010000000000000000000000		@ Mascara para el led verde (GPIO 22)
	streq	r2, [r0, #GPCLR0]							@ Apagar todos los leds
	streq	r1, [r0, #GPSET0]							@ Encender el led verde (GPIO 22)
	
	cmp		r11, #5
	moveq 	r1, #0b00001000000000000000000000000000		@ Mascara para el led verde (GPIO 27)
	streq	r2, [r0, #GPCLR0]							@ Apagar todos los leds
	streq	r1, [r0, #GPSET0]							@ Encender el led verde (GPIO 27)
	
	b 		bucle


irq_handler:
	push 	{r0, r1, r4, r10, r11}
	
	ldr 	r0, =GPBASE
	
	ldr		r10, =contador
	ldr		r11, [r10]
	add		r11, #1
	
	cmp		r11, #6
	moveq	r11, #0
	
	str		r11, [r10]
	
	
	ldr		r0, =STBASE
	
	mov		r1, #0b0010
	str		r1, [r0, #STCS]
	
	ldr		r1,	[r0, #STCLO]	@
	ldr		r4, =500000
	add		r1,	r4
	str		r1, [r0, #STC1] 	@ 
	
	pop 	{r0, r1, r4, r10, r11}
	
	subs 	pc, lr, #4

contador:
	.word 0
