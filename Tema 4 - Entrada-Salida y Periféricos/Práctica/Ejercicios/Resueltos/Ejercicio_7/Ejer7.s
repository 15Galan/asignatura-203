.include "inter.inc"

.text
        ADDEXC  0x18, manejador     @ Vector de interrupcion (IRQ - 0x18)

// -------------------------------------------------------------
        mrs     r0, cpsr
        mov     r0, #0b11010011     @ Modo SVC, FIQ y IRQ desactivados
        msr     spsr_cxsf, r0
        add     r0, pc, #4
        msr     ELR_hyp, r0
        eret
// -------------------------------------------------------------

        mov     r0, #0b11010010     @ Modo SVC, FIQ y IRQ desactivados
        msr     cpsr_c, r0          @ Modo SVC activado
        mov     sp, #0x8000000      @ Inicializar la pila en modo SVC
        
        mov     r0, #0b11010011     @ Modo SVC, FIQ y IRQ desactivados
        msr     cpsr_c, r0          @ Modo IRQ activado
        mov     sp, #0x8000         @ Inicializar la pila en modo IRQ

        ldr     r0, =GPBASE
        
/* Configuracion de los leds */
        /* Guia bits   __999888777666555444333222111000 */
        mov     r1, #0b00001000000000000000000000000000
        str     r1, [r0, #GPFSEL0]                          @ Configura GPIO 9 (led rojo) como salida

/* Configuracion del contador C3 para futura interrupcion */
        ldr     r0, =STBASE
        ldr     r1, [r0, #STCLO]    @ Configurar el contador
        
        ldr     r6, =6000000        @ 6 segundos (msegundos)
        
        add     r1, r6              @ Establecer al contador
        str     r1, [r0, #STC3]     @ la cantidad de segundos

/* Habilitar interrupciones local y globalmente */
        ldr     r0, =INTBASE
        
        mov     r1, #0b1000             @ Contador C3
        
        str     r1, [r0, #INTENIRQ1]
        mov     r0, #0b01010011         @ Modo SVC y IRQ activos
        msr     cpsr_c, r0              @ Modo SVC activado

fin: 
        b       fin


/* Rutina de tratamiento de interrupcion */
manejador:
        push    {r0, r1}          @ Almacena r4 y r5 en la pila

        ldr     r0, =GPBASE
        
        /* Guia bits   ..987654321098765432109876543210 */
        ldr     r1, =0b00000000000000000000001000000000
        str     r1, [r0, #GPSET0]                           @ Encender el led rojo (GPIO 9)

        pop     {r0, r1}          @ Recupera r0 y r1 de la pila
        subs    pc, lr, #4        @ Salir de la RTI
