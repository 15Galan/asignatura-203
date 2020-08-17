.include "inter.inc"

.text
        ldr     r0, =GPBASE
        
        /* Guia bits   __999888777666555444333222111000 */
        ldr     r1,  =0b00000000001000000000000001000000
        str     r1, [r0, #GPFSEL2]                          @ Configura GPIO 22 y 27 (leds verdes) como salida

        /* Guia bits   ..987654321098765432109876543210 */
        mov     r2, #0b00000000000000000000000000000100     @ Mascara para GPIO 2 (boton 1)
        mov     r4, #0b00000000000000000000000000001000     @ Mascara para GPIO 3 (boton 2)
        
        /* Guia bits   ..987654321098765432109876543210 */
        mov     r1, #0b00001000010000000000000000000000
        str     r1, [r0, #GPSET0]                           @ Enciende los leds verdes (GPIO 22 y 27)
        
bucle:
        ldr     r3, [r0, #GPLEV0]   @ Registra una lectura en r3 (pulsacion)
        
        tst     r3, r2              @ Compara el valor en r3 con el de r2 (boton 1)
        beq     izq                 @ Si se ha pulsado el boton 1, salta a la rutina izq
        
        tst     r3, r4              @ Compara el valor en r3 con el de r4 (boton 2)
        beq     der                 @ Si se ha pulsado el boton 2, salta a la rutina der
        
        b       bucle               @ Si no cambia de rutina vuelve a comprobar
        
izq:               
        /* Guia bits   ..987654321098765432109876543210 */
        mov     r1, #0b00001000000000000000000000000000
        str     r1, [r0, #GPCLR0]                           @ Apaga el led verde (GPIO 27)
        
        mov     r1, #0b00000000010000000000000000000000
        str     r1, [r0, #GPSET0]                           @ Enciende el led verde (GPIO 22)
        
        b       bucle

der:
        /* Guia bits   ..987654321098765432109876543210 */
        mov     r1, #0b00000000010000000000000000000000
        str     r1, [r0, #GPCLR0]                           @ Apaga el led verde (GPIO 22)
        
        mov     r1, #0b00001000000000000000000000000000
        str     r1, [r0, #GPSET0]                           @ Enciende el led verde (GPIO 27)
        
        b      bucle
