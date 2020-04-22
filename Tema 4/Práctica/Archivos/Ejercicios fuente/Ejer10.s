        .include  "inter.inc"
.text
/* Agrego vector interrupcion */
        ADDEXC  0x18, irq_handler

/* Inicializo la pila en modos IRQ y SVC */
        mov     r0, #0b11010010   @ Modo IRQ, FIQ&IRQ desact
        msr     cpsr_c, r0
        mov     sp, #0x8000
        mov     r0, #0b11010011   @ Modo SVC, FIQ&IRQ desact
        msr     cpsr_c, r0
        mov     sp, #0x8000000

/* Configuro GPIOs 9 como salida */
        ldr     r0, =GPBASE
        mov     r1, #0b00001000000000000000000000000000
        str     r1, [r0, #GPFSEL0]

/* Habilito pines GPIO 2 (boton) para interrupciones*/
        mov     r1, #0b00000000000000000000000000000100
        str     r1, [r0, #GPFEN0]
        ldr     r0, =INTBASE

/* Habilito interrupciones, local y globalmente */
        mov     r1, #0b00000000000100000000000000000000
/* guia bits           10987654321098765432109876543210*/
        str     r1, [r0, #INTENIRQ2]
        mov     r0, #0b01010011   @ Modo SVC, IRQ activo
        msr     cpsr_c, r0

/* Repetir para siempre */
bucle:  b       bucle

/* Rutina de tratamiento de interrupcion */
irq_handler:
        push    {r0, r1, r2}
        ldr     r0, =GPBASE
	
/* Consulto si se ha pulsado el boton GPIO2 */
        ldr     r2, [r0, #GPEDS0]
	mov	r3, r2 
        ands    r2, #0b00000000000000000000000000000100
/* Si: Activo GPIO 9*/
/*  guia bits                54321098765432109876543210*/
        movne   r1, #0b00000000000000000000001000000000
	strne   r1, [r0, #GPSET0]
	
/* Desactivo el flag GPIO pendiente de atencion
   guia bits                 54321098765432109876543210*/
        movne   r1, #0b00000000000000000000000000000100	
	strne   r1, [r0, #GPEDS0]
   
fin:	pop     {r0, r1, r2}
        subs    pc, lr, #4
