.module semyon

;SFRs
PCON = 0x97

;Parameters
;P_LEDLEN = 16
;P_LEDLOC = 0x300
P_LFSRMASK_L = 0x11
P_LFSRMASK_H = 0xa0
P_SEED_L = 0xff
P_SEED_H = 0xff

;States
S_INITIALIZE = 0x00
S_DISPLAY_SEQUENCE = 0x01
S_GET_USER_INPUT = 0x02
S_GAME_OVER = 0x03

S_INVALID = 0xff

;Variables
V_LED_CNT = 0x30
V_LED_MAX = 0x31
V_STATE = 0x40


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
	;This is the state machine that controls Semyon's logic.
	mov a, V_STATE
	s_initialize:
		cjne a, #S_INITIALIZE, s_display_sequence
		lcall initialize
		sjmp main
	s_display_sequence:
		cjne a, #S_DISPLAY_SEQUENCE, s_get_user_input
		lcall display_sequence
		sjmp main
	s_get_user_input:
		cjne a, #S_GET_USER_INPUT, s_game_over
		lcall get_user_input
		sjmp main
	s_game_over:
		cjne a, #S_GAME_OVER, s_invalid
		lcall game_over
		sjmp main
	
	s_invalid:
		mov V_STATE, #S_INITIALIZE
		ljmp main
		;lcall reset


initialize:
	;This is the initialization phase of semyon.
	;It should also generate the seed value for PRNG.
	mov V_LED_CNT, #1
	mov V_LED_MAX, #1
	mov V_STATE, #S_DISPLAY_SEQUENCE
	ret

display_sequence:
	mov r0, #P_SEED_L
	mov r1, #P_SEED_H
	mov a, V_LED_MAX
	mov V_LED_CNT, a
	
	display_sequence_loop1:
		lcall get_led_color
		lcall display_led
		djnz V_LED_CNT, display_sequence_loop1
	
	mov V_STATE, #S_GET_USER_INPUT
	ret

get_user_input:
	mov r0, #P_SEED_L
	mov r1, #P_SEED_H
	mov a, V_LED_MAX
	mov V_LED_CNT, a
	get_user_input_loop1:
		lcall get_led_color
		lcall poll_user_input_debounce
		xrl a, r3
		jnz get_user_input_game_over
		djnz V_LED_CNT, get_user_input_loop1
	lcall delay_display
	inc V_LED_MAX
	mov V_STATE, #S_DISPLAY_SEQUENCE
	ret
	get_user_input_game_over:
		mov V_STATE, #S_GAME_OVER
		ret
		
game_over:
	lcall delay_display
	clr RLED
	clr YLED
	clr GLED
	clr BLED
	lcall delay_display
	setb RLED
	setb YLED
	setb GLED
	setb BLED
	lcall delay_display
	lcall delay_display
	lcall delay_display
	mov V_STATE, #S_INITIALIZE
	ret

	
poll_user_input_debounce:
	jnb RLED, poll_user_input_debounce_r
	jnb YLED, poll_user_input_debounce_y
	jnb GLED, poll_user_input_debounce_g
	jnb BLED, poll_user_input_debounce_b
	sjmp poll_user_input_debounce
	poll_user_input_debounce_r:
		lcall delay_debounce
		jb RLED, poll_user_input_debounce
		mov a, #0x00
		sjmp poll_user_input_debounce_delay
	poll_user_input_debounce_y:
		lcall delay_debounce
		jb YLED, poll_user_input_debounce
		mov a, #0x01
		sjmp poll_user_input_debounce_delay
	poll_user_input_debounce_g:
		lcall delay_debounce
		jb GLED, poll_user_input_debounce
		mov a, #0x02
		sjmp poll_user_input_debounce_delay
	poll_user_input_debounce_b:
		lcall delay_debounce
		jb BLED, poll_user_input_debounce
		mov a, #0x03
		;sjmp poll_user_input_debounce_delay
		
	poll_user_input_debounce_delay:
	lcall delay_debounce
	jnb RLED, poll_user_input_debounce_delay
	jnb YLED, poll_user_input_debounce_delay
	jnb GLED, poll_user_input_debounce_delay
	jnb BLED, poll_user_input_debounce_delay
	ret


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
	mov a, r0
	xrl a, #P_LFSRMASK_L
	mov r0, a
	mov a, r1
	xrl a, #P_LFSRMASK_H
	mov r1, a
inc_lfsr_ret:	
	ret
	
	
display_led:
	mov dptr, #led_jumptable
	mov a, r3
	anl a, #0x03
	rl a 	;YOU BASTARD!!!!!!!
	jmp @a+dptr
led_jumptable:
	sjmp light_rled
	sjmp light_yled
	sjmp light_gled
	sjmp light_bled
	
	light_rled:
		clr RLED
		lcall delay_display
		setb RLED
		lcall delay_display2
		ret
	light_yled:
		clr YLED
		lcall delay_display
		setb YLED
		lcall delay_display2
		ret
	light_gled:
		clr GLED
		lcall delay_display
		setb GLED
		lcall delay_display2
		ret
	light_bled:
		clr BLED
		lcall delay_display
		setb BLED
		lcall delay_display2
		ret

delay_debounce:
	mov r5, #0x01
	mov r6, #0x00
	mov r7, #0x00
	sjmp delay_loop		

delay_display2:
	mov r5, #0x04
	mov r6, #0x00
	mov r7, #0x00
	sjmp delay_loop

delay_display:
	mov r5, #0x10
	mov r6, #0x00
	mov r7, #0x00
	sjmp delay_loop
	
delay_loop:
	djnz r7, delay_loop
	djnz r6, delay_loop
	djnz r5, delay_loop
	ret


;.area DSEG (ABS)
;.org P_LEDLOC
;.db 0x00, 0x01, 0x03, 0x02, 0x00, 0x01, 0x03, 0x02, 0x00, 0x03, 0x01, 0x02, 0x00, 0x03, 0x01, 0x02