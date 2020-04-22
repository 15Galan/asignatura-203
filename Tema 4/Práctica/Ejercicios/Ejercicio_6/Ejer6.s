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


configuracion_leds:
        /* Guia bits   __999888777666555444333222111000 */
		ldr	  	r2, =0b00001000000000000000000000000000
        str  	r2, [r4, #GPFSEL0]	                        @ Configura GPIO 9 (led rojo) como salida
		
		ldr  	r3, =0b00000000001000000000000000000000
        str  	r3, [r4, #GPFSEL1]	                        @ Configura GPIO 17 (led amarillo) como salida

configuracion_botones:
        /* Guia bits   ..987654321098765432109876543210 */
        mov     r6, #0b00000000000000000000000000000100     @ Mascara para el boton 1 (GPIO 2)
        mov     r7, #0b00000000000000000000000000001000     @ Mascara para el boton 2 (GPIO 3)

configuracion_altavoz:
        /* Guia bits   __999888777666555444333222111000 */
		ldr     r5, =0b00001000000000000001000000000000
        str     r5, [r4, #GPFSEL0]                          @ Configura GPIO 4 (altavoz) como salida -arrastra bit de GPIO 9-
        
        /* Guia bits   ..987654321098765432109876543210 */
        mov	    r5, #0b00000000000000000000000000010000     @ Mascara para el altavoz (GPIO 4)
        
        ldr	    r0, =STBASE         @ Parametro de sonido (dir. base ST)
        ldr     r1, =0              @ Establecer SILENCIO para el altavoz


sondeo:
        ldr     r8, [r4, #GPLEV0]   @ Registra una lectura en r8 (pulsacion)
        
        tst     r8, r6              @ Compara el valor en r8 con el de r6 (boton 1)
        beq     izq                 @ Si se ha pulsado el boton 1, salta a la rutina izq
        
        tst     r8, r7              @ Compara el valor en r8 con el de r7 (boton 2)
        beq     der                 @ Si se ha pulsado el boton 2, salta a la rutina der
        
        b       bucle               @ Si no cambia de rutina vuelve a comprobar

izq:
        /* Guia bits   ..987654321098765432109876543210 */
        mov	    r2, #0b00000000000000000000001000000000
        str     r2, [r4, #GPSET0]                           @ Encender el led rojo (GPIO 9)
        
        mov	    r2, #0b00000000000000100000000000000000
        str     r2, [r4, #GPCLR0]                           @ Apagar el led amarillo (GPIO 17)
        
        ldr r1, =1908               @ Establecer la nota DO para el altavoz
        
        b       bucle
        
der:
        /* Guia bits   ..987654321098765432109876543210 */
        mov	    r3, #0b00000000000000100000000000000000
        str     r3, [r4, #GPSET0]                           @ Encender el led amarillo (GPIO 17)
        
        mov	    r3, #0b00000000000000000000001000000000
        str     r3, [r4, #GPCLR0]                           @ Apagar el led rojo (GPIO 9)
        
        ldr r1, =1278               @ Establecer la nota SOL para el altavoz
        
        b       bucle

bucle:
        str     r5, [r4, #GPSET0]   @ Encender el altavoz (GPIO 4)
        bl      espera		        @ Saltar a la rutina de espera
        str     r5, [r4, #GPCLR0]   @ Apagar el altavoz (GPIO 4)
        bl      espera 		        @ Saltar a la rutina de espera
        
        b       sondeo

espera: 
        push    {r4, r5}            @ Almacena r4 y r5 en la pila
        
        ldr     r4, [r0, #STCLO]    @ Carga el contador en r4
        add     r4, r1    	        @ Añade tiempo de espera (periodo/2)
        
ret1: 	
        ldr     r5, [r0, #STCLO]    @ Carga el contador en r5
        cmp	    r5, r4              @ Compara el tiempo actual (r5) con el de fin (r4)
        
        blo     ret1                @ Si es menor, vuelve a leer el tiempo
        
        pop	    {r4, r5}            @ Recupera r4 y r5 de la pila
        bx      lr                  @ Regresa de la rutina
