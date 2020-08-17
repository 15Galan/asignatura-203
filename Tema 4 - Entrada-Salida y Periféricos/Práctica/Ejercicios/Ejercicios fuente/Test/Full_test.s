/* This program turn on all leds. After pressing button 1, three leds
will turn off, and while the button 2 is pressed a sound is made*/

.include "configuration.inc" 
 	ldr  r0, =0x3F20001C  	/*r0 contents the port address for ON */
	ldr  r2, =0x3F200028  	/*r0 contents the port address for ON */
	ldr  r3, =0x3F200034  	/*r0 contents the port address for ON */
	ldr  r1, =0x08420E00		
	str  r1,[r0]
loop:
	ldr  r8,[r3]
	tst r8, #0b00100
	ldr  r1, =0x00E00		
	streq  r1,[r2]
	tst r8, #0b001000
	bleq  sonido
	b loop
sonido:
	ldr r1, =0x010 /* r1= 0x20= 00… 0001 0000 ? bit4=1*/
	str r1,[r0] /* HIGH */
	BL wait /* Routine for waiting 200 ms. */
	ldr r1, =0x010 /* r1= 0x20= 00… 0001 0000 ? bit4=1*/
	str r1,[r2] /* LOW */
	BL wait /* Routine for waiting 200 ms. */
	B loop
wait:
		ldr r5, =700
loop2: 	subs r5, #1
		bne loop2
		bx lr
END:	B END
