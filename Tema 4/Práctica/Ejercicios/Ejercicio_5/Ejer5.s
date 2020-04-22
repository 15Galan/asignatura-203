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
        msr     cpsr_c, r0          @ Modo SVC activado
        mov     sp, #0x8000000      @ Inicializar la pila en modo SVC
	
        ldr     r4, =GPBASE
        
        /* Guia bits   __999888777666555444333222111000 */
        mov     r5, #0b00000000000000000001000000000000
        str     r5, [r4, #GPFSEL0]  @ Configurar GPIO 4
        
        /* Guia bits   ..987654321098765432109876543210 */
        mov	    r5, #0b00000000000000000000000000010000
        
        ldr	    r0, =STBASE         @ Parametro de sonido (dir. base ST)
        ldr     r1, =956	        @ Parametro de sonido (periodo / 2)
        
        // ldr     r2, =STBASE      @ Parametro de espera (dir. base ST)
       	// ldr     r3, =1000000		@ Parametro de espera (en msegundos)

bucle:	
        bl      espera		        @ Salta a la rutina de espera
        str     r5, [r4, #GPSET0]   @ Encender el altavoz
        bl      espera 		        @ Salta a la rutina de espera
        str     r5, [r4, #GPCLR0]   @ Apagar el altavoz
        
        b       bucle

espera: 
        push    {r4, r5}            @ Almacena r4 y r5 en la pila
        
        ldr     r4, [r0, #STCLO]    @ Carga el contador en r4
        add     r4, r1    	        @ Añade tiempo de espera (tiempo de fin)
        
ret1: 	
        ldr     r5, [r0, #STCLO]    @ Carga el contador en r5
        cmp	    r5, r4              @ Compara el tiempo actual (r5) con el de fin (r4)
        
        blo     ret1                @ Si es menor, vuelve a leer el tiempo
        
        pop	    {r4, r5}            @ Recupera r4 y r5 de la pila
        bx      lr                  @ Regresa de la rutina
