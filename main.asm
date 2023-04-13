.module main
.title "main code"

;Def file includes
.include "define.def"
.include "macro.def"

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

    mov P3M0, #0x00
    mov P3M1, #0x00
    .ifdef B_8G1K08A
        mov P5M0, #0x00
        mov P5M1, #0x00
    .endif

	mov V_LED_CNT, #1
	mov V_LED_MAX, #1
	.ifdef B_8G1K08A
        mov TL1, #0x01
        mov TH1, #0x00
        anl TMOD, #~0x30    ;T1 is 16 bit autoreload
        orl AUXR, #0x40     ;T1 is 1clk
        setb TR1
    .else
        mov T2L, #0x01
	    mov T2H, #0x00
	    orl AUXR, #0x14		;T2 enable || T2 is 1clk
	.endif
	ext_int_get_input, 0	;macro call - idle mode
	
	.ifdef B_8G1K08A
        clr TR1
        mov V_SEED_L, TL1
        mov V_SEED_H, TH1
    .else
        anl AUXR, #~0x10	;T2 disable
        mov V_SEED_L, T2L
        mov V_SEED_H, T2H
    .endif

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
	mov V_OVERLAP_LED, #P_OVERLAP_LED_NULL

	
	get_user_input_loop1:
		lcall get_led_color
		mov a, #P_OVERLAP_LED_NULL
		cjne a, V_OVERLAP_LED, get_user_input_overlapping_led
		ext_int_get_input, 1	;macro call - power down mode
		lcall get_overlap_buttons 
		;The get_overlap_buttons is here rather than in the release_button macro
		;to prevent a double overlap - which's usually wrong and unwanted.
		sjmp get_user_input_release
	get_user_input_overlapping_led:
		mov V_INTERRUPT_LED, V_OVERLAP_LED
		mov V_OVERLAP_LED, #P_OVERLAP_LED_NULL
		lcall get_pwm_led
		release_button
	get_user_input_release:
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
	orl a, #~P_LED_ALL
	mov P3, a
	lcall delay_display
	mov V_STATE, #S_INITIALIZE
	ret
