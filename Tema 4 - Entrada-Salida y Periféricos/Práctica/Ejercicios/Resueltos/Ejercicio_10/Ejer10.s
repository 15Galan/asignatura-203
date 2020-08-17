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

	mov		r0,	#0
	ADDEXC	0x18, manejador		@ Vector de interrupcion (IRQ - 0x18)

	mov     r0, #0b11010010     @ FIQ y IRQ desabilitados
	msr     cpsr_c, r0          @ Modo IRQ activado
	mov     sp, #0x80000      	@ Inicializar la pila en modo IRQ
	
	mov     r0, #0b11010011     @ FIQ y IRQ desabilitados
	msr     cpsr_c, r0          @ Modo SVC activado
	mov     sp, #0x8000000      @ Inicializar la pila en modo SVC

configurar_leds:
	ldr 	r0, =GPBASE

    /* Guia bits   __999888777666555444333222111000 */
    ldr 	r1, =0b00000000001000000000000001000000
	str 	r1, [r0, #GPFSEL2]							@ Configurar los leds verdes (GPIO 22 y 27) como salida

	/* Guia bits   ..987654321098765432109876543210 */
	mov 	r1, #0b00001000010000000000000000000000
	str 	r1, [r0, #GPSET0]							@ Encender los leds verdes (GPIO 22 y 27)
	
configurar_botones_interrupcion:
	/* Guia bits   ..987654321098765432109876543210 */
	mov 	r1, #0b00000000000000000000000000001100
	str 	r1, [r0, #GPFEN0]							@ Habilitar interrupcion de los botones
	

configurar_interrupciones:
	ldr 	r0, = INTBASE
	
	/* Guia bits   ..987654321098765432109876543210 */
	mov 	r1, #0b00000000000100000000000000000000		@ Configurar el GPIO 20 para expandir la interrupcion
	str 	r1, [r0, #INTENIRQ2]						@ Interrupcion local IRQ habilitada (cualquier GPIO)
	mov 	r0, #0b01010011								@ Modo SVC y IRQ activos
	msr 	cpsr_c, r0

fin:
	b	fin


manejador:
	push	{r0, r1}
	
	ldr 	r0, = GPBASE
	
	/* Guia bits   ..987654321098765432109876543210 */
	mov 	r1, #0b00001000010000000000000000000000
	str 	r1, [r0, #GPCLR0]
	
	/* Consultar si se ha pulsado el boton GPIO 2 */
	ldr 	r1, [r0, #GPEDS0]
	ands	r1, #0b00000000000000000000000000000100
	
	/* Si: Activo GPIO 22; No: Activo GPIO 27 */
	movne 	r1, #0b00000000010000000000000000000000
	moveq 	r1, #0b00001000000000000000000000000000
	str 	r1, [r0, #GPSET0]
	
	/* Desactivo los dos flags GPIO pendientes de atencion
	/* Guia bits   ..987654321098765432109876543210 */
	mov 	r1, #0b00000000000000000000000000001100
	str 	r1, [r0, #GPEDS0]

	pop 	{r0, r1}

	subs 	pc, lr, #4
