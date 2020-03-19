.title "IOs and sequence gen."

.area CODE
get_led_color:
	;Puts in r3 the value of the next LED to display.
	mov r3, #0
	lcall inc_lfsr
	jnc get_led_color_2
	inc r3
	inc r3
get_led_color_2: 
	lcall inc_lfsr
	jnc get_led_color_ret
	inc r3
get_led_color_ret:
	ret

	
inc_lfsr:
	;Now with Galois LFSR of 16 bits with polynomial x^16 + x^15 + x^13 + x^4 + 1 (mask 0xa011)
	clr c
	mov a, r0
	rlc a
	mov r0, a
	mov a, r1
	rlc a
	mov r1, a
	jnc inc_lfsr_ret
	xrl 0x00, #P_LFSRMASK_L 	;using absolute addresses of r0 and r1
	xrl 0x01, #P_LFSRMASK_H
inc_lfsr_ret:	
	ret
	
	
display_led:
	mov dptr, #D_LEDLOC
	mov a, r3
	anl a, #0x03
	movc a, @a+dptr
	xrl a, P3
	mov P3, a	
	lcall delay_display
	mov a, P3
	orl a, #~P_LED_ALL
	mov P3, a
	lcall delay_display2
	ret
