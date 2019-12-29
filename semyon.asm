.module semyon

;SFRs
PCON2 = 0x97

;Parameter values
P_LEDLOC = 0x400

P_LFSRMASK_L = 0x11
P_LFSRMASK_H = 0xa0

P_LED_ALL = ~0x3c
P_LED_R = 0x20
P_LED_Y = 0x10
P_LED_G = 0x04
P_LED_B = 0x08

;State values
S_INITIALIZE = 0x00
S_DISPLAY_SEQUENCE = 0x01
S_GET_USER_INPUT = 0x02
S_GAME_OVER = 0x03
S_INVALID = 0xff

;Variable addresses
V_LED_CNT = 0x30
V_LED_MAX = 0x31
V_STATE = 0x40
V_SEED_L = 0x20
V_SEED_H = 0x21

;Bool variables bit-addresses
RLED = P3.5
YLED = P3.4
GLED = P3.2
BLED = P3.3


;Code
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
	
	initialize_seed_loop:
		mov a, P3
		orl a, #P_LED_ALL
		cjne a, #0xff, initialize_ret
		;This is a fast and easy way to increment the seed.
		inc r0
		cjne r0, #0x00, initialize_seed_loop
		inc r1
		sjmp initialize_seed_loop
		
	initialize_ret:
		mov a, P3
		orl a, #P_LED_ALL
		cpl a
		cjne a, #0x00, initialize_ret
	
	mov V_SEED_L, r0
	mov V_SEED_H, r1
	lcall delay_display
	mov V_STATE, #S_DISPLAY_SEQUENCE
	ret
		
		
		
display_sequence:
	mov r0, V_SEED_L
	mov r1, V_SEED_H
	mov a, V_LED_MAX
	mov V_LED_CNT, a
	
	display_sequence_loop1:
		lcall get_led_color
		lcall display_led
		djnz V_LED_CNT, display_sequence_loop1
	
	mov V_STATE, #S_GET_USER_INPUT
	ret

	
	
get_user_input:
	mov r0, V_SEED_L
	mov r1, V_SEED_H
	mov a, V_LED_MAX
	mov V_LED_CNT, a
	
	get_user_input_loop1:
		lcall get_led_color
		lcall poll_user_input
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
	mov a, P3
	anl a, #P_LED_ALL
	mov P3, a
	lcall delay_display
	mov a, P3
	orl a, #~P_LED_ALL	;#~P_LED_ALL is refered to as iram rather than immediate.
	mov P3, a
	lcall delay_display
	lcall delay_display
	mov V_STATE, #S_INITIALIZE
	ret

	
poll_user_input:
		mov a, P3
		orl a, #P_LED_ALL
		cpl a
		jz poll_user_input
	lcall delay_debounce
	
	clr a
	jnb RLED, poll_user_input_2
	inc a
	jnb YLED, poll_user_input_2
	inc a
	jnb GLED, poll_user_input_2
	inc a
	jnb BLED, poll_user_input_2
	sjmp poll_user_input
	
	poll_user_input_2:
	mov r4, a
	poll_user_input_3:
		mov a, P3
		orl a, #P_LED_ALL
		cjne a, #0xff, poll_user_input_3
	lcall delay_debounce
	mov a, r4
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
	xrl 0x00, #P_LFSRMASK_L
	xrl 0x01, #P_LFSRMASK_H
inc_lfsr_ret:	
	ret
	
	
display_led:
	mov dptr, #P_LEDLOC
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


.area DSEG (ABS)
.org P_LEDLOC

.db P_LED_R, P_LED_Y, P_LED_G, P_LED_B