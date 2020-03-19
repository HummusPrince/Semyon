.title "main code"

.area CODE(REL)

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
	mov TL0, #0x01 
	mov TH0, #0x00
	mov TMOD, #0x00 
	mov AUXR, #0x80
	mov TCON, #0x05
	setb TR0
	
	ext_int_get_input, 0		;macro call - idle mode
	
	clr TR0
	clr TF0
	mov V_SEED_L, TL0
	mov V_SEED_H, TH0		
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
		ext_int_get_input, 1		;macro call - power down mode
		mov a, V_INTERRUPT_LED
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
	mov V_STATE, #S_INITIALIZE
	ret
