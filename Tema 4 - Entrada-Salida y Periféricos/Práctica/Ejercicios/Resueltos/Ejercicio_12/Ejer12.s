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
	ADDEXC 	0x18, manejador_IRQ
	ADDEXC	0x1c, manejador_FIQ
	
	mov     r0, #0b11010001     @ FIQ y IRQ desabilitados
	msr     cpsr_c, r0          @ Modo FIQ activado
	mov     sp, #0x4000      	@ Inicializar la pila en modo FIQ
	
	mov     r0, #0b11010010     @ FIQ y IRQ desabilitados
	msr     cpsr_c, r0          @ Modo IRQ activado
	mov     sp, #0x80000      	@ Inicializar la pila en modo IRQ
	
	mov     r0, #0b11010011     @ FIQ y IRQ desabilitados
	msr     cpsr_c, r0          @ Modo SVC activado
	mov     sp, #0x8000000      @ Inicializar la pila en modo SVC

configurar_leds:
	ldr 	r0, =GPBASE
	
    /* Guia bits   __999888777666555444333222111000 */
	ldr 	r1, =0b00001000000000000001000000000000
	str 	r1, [r0, #GPFSEL0]							@ Configurar un led rojo (GPIO 9) y el altavoz (GPIO 4) como salida
	
	ldr 	r1, =0b00000000001000000000000000001001
	str 	r1, [r0, #GPFSEL1]							@ Configurar un led rojo y los amarillos (GPIO 10, 11 y 17) como salida
	
	ldr 	r1, =0b00000000001000000000000001000000
	str 	r1, [r0, #GPFSEL2]							@ Configurar los leds verdes (GPIO 22 y 27) como salida
	
configurar_botones:
	mov		r1, #0b0b00000000000000000000000000001100
	str		r1, [r0, #GPFEN0]

configurar_contador:
	ldr 	r0, =STBASE
	
	ldr 	r1, [r0, #STCLO]	@ Configura el contador
	ldr 	r4, =200000			@ Tiempo (msegundos)
	add 	r1, r4				@ A�adir el tiempo al contador
	str 	r1, [r0, #STC3]		@ Habilitar el contador C3 (para los leds)
	str		r1, [r0, #STC1]		@ Habilitar el contador C1 (para el altavoz)
	
configurar_interrupciones:	
	// Interrupciones de los contadores
	ldr 	r0, =INTBASE
	
	mov 	r1, #0b0010				@ Habilitar la fuente de interrupcion (contador C1)
	str 	r1, [r0, #INTENIRQ1]	@ Interrupcion local IRQ habilitada
	
	
	// Interrupcion de los botones
	ldr		r0, =INTBASE
	
	/* Guia bits   ..987654321098765432109876543210 */
	mov 	r1, #0b00000000000100000000000000000000
	str 	r1, [r0, #INTENIRQ2]						@ Interrupcion local IRQ habilitada (botones)
	
	mov 	r0, #0b00010011			@ Interrupciones globales IRQ y FIQ habilitada
	msr 	cpsr_c, r0
	

bucle:
	b 		bucle


manejador:
	push   {r0, r1, r2, r3}
	
	ldr		r0, =STBASE
	ldr		r1, =GPBASE
	
	ldr		r2, [r0, #STCS]		@ Configura el contador
	ands	r2,	#0b0010			@ Contador C1
	beq		sonido
	
	// Si es C1 ejecuto los LEDs - - - - - - - - - - - - - - - - -
	ldr 	r2, =contador
	
	/* Guia bits   ..987654321098765432109876543210 */
	ldr		r3, =0b00001000010000100000111000000000
	str		r3, [r1, #GPCLR0]							@ Apagar todos los leds
	
	ldr		r3,	[r2]				@ Lee el valor de "contador"
	subs	r3,	#1					@ �?
	moveq	r3,	#6					@ �?
	
	str		r3,	[r2]				@ Almacena en r3 el contenido de r2
	ldr		r3, [r2, +r3, LSL #2]	@ ��!?
	str		r3, [r1, #GPSET0]		@ Enciende el led correspondiente
	
	mov		r3,	#0b0010			@ Contador C1
	str		r3, [r0, #STCS]		@ Habilita el contador (C1)
	
	ldr 	r3, [r0, #STCLO]	@ Configura el contador
	ldr 	r4, =200000			@ Tiempo (msegundos)
	add 	r3, r4				@ A�adir el tiempo al contador
	str 	r3, [r0, #STC1]		@ Habilitar el contador C3
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	ldr		r3, [r0, #STCS]		@ Habilita el contador
	ands	r3, #0b0100
	beq		final
	
sonido:
	ldr		r2, =sonido_bit		@ Almacena en r2 la dir. mem de "sonido_bit"
	ldr		r3,	[r2]			@ Almacena en r3 el contenido de r2
	eors	r3, #1				@ �?
	
	str		r3, [r2]
	mov		r3,	#0b10000		@ Altavoz
	streq	r3,	[r1, #GPSET0]	@ �?
	strne	r3, [r1, #GPCLR0]	@ �?
	
	mov		r3, #0b1000			@ Contador C3
	str		r3, [r0, #STCS]		@ Habilita el contador
	ldr		r3, [r0, #STCLO]	@ Configura el contador
	ldr		r2, =1136			@ Frecuencia (msegundos)
	add		r3,	r2				@ A�adir la frecuencia al contador
	str		r3,	[r0, #STC3]		@ Habilitar el contador C3

final:
	pop 	{r0, r1, r2, r3}
	
	subs	pc,	lr,	#4


sonido_bit:
	.word	0

contador:
	.word	1

secuencia:
	.word 	0b1000000000000000000000000000	@ Mascara para el led verde (GPIO 27)
	.word 	0b0000010000000000000000000000	@ Mascara para el led verde (GPIO 22)
	.word 	0b0000000000100000000000000000	@ Mascara para el led amarillo (GPIO 17)
	.word 	0b0000000000000000100000000000	@ Mascara para el led amarillo (GPIO 11)
	.word 	0b0000000000000000010000000000	@ Mascara para el led rojo (GPIO 10)
	.word 	0b0000000000000000001000000000	@ Mascara para el led rojo (GPIO 9)

notas:
	.word 	1136	@ Nota La	(440 Hz)
	.word	1012	@ Nota Si	(494 Hz)
	.word	1515	@ Nota Mi	(330 Hz)
	.word	1275	@ Nota Sol	(392 Hz)
	.word	1706	@ Nota Re	(293 Hz)
	.word	1351	@ Nota Fa#	(370 Hz)
	.word	0851	@ Nota Re�	(587 Hz)
	.word	0956	@ Nota Do�	(523 Hz)
	