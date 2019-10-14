.module semyon

;SFRs
PCON = 0x97

;Parameters
P_LEDLEN = 16
P_LEDLOC = 0x300
P_LFSRMASK_L = 0x11
P_LFSRMASK_H = 0xa0
P_SEED_L = 0xff
P_SEED_H = 0xff

;Variables
V_LED_CNT = 0x30
V_LED_MAX = 0x31


RLED = P3.5
YLED = P3.4
GLED = P3.2
BLED = P3.3

.area INTV (ABS)
.org 0x0000
_int_reset:
	ljmp main
	
.area CSEG (ABS, CON)
.org 0x0090

main:
	mov r4, #0
	mov r0, #P_SEED_L
	mov r1, #P_SEED_H
	;mov V_LED_CNT, #0
main_loop:
	lcall get_led_color
	lcall display_led_jumptable
	sjmp main_loop

	
get_led_color:
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
	mov a, r0
	xrl a, #P_LFSRMASK_L
	mov r0, a
	mov a, r1
	xrl a, #P_LFSRMASK_H
	mov r1, a
inc_lfsr_ret:	
	ret
	
	
display_led_jumptable:
	mov dptr, #jumptable
	mov a, r3
	anl a, #0x03
	rl a 	;YOU BASTARD!!!!!!!
	jmp @a+dptr
jumptable:
	sjmp light_rled
	sjmp light_yled
	sjmp light_gled
	sjmp light_bled
	
	light_rled:
		clr RLED
		acall delay
		setb RLED
		ret
	light_yled:
		clr YLED
		acall delay
		setb YLED
		ret
	light_gled:
		clr GLED
		acall delay
		setb GLED
		ret
	light_bled:
		clr BLED
		acall delay
		setb BLED
		ret
		
		
		
delay:
	mov r5, #0x10
	mov r6, #0x00
	mov r7, #0x00
delay_loop:
	djnz r7, delay_loop
	djnz r6, delay_loop
	djnz r5, delay_loop
	ret


;.area DSEG (ABS)
;.org P_LEDLOC
;.db 0x00, 0x01, 0x03, 0x02, 0x00, 0x01, 0x03, 0x02, 0x00, 0x03, 0x01, 0x02, 0x00, 0x03, 0x01, 0x02