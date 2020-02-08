.module semyon
;IRC freq = 11.0592MHz

;SFRs
PCON2 = 0x97
AUXR = 0x8e
AUXR2 = 0x8f
IE2 = 0xaf
T2L = 0xd7 	;non standard T2 timer, doh!
T2H = 0xd6

;Parameter values
P_LEDLOC = 0x400

P_LFSRMASK_L = 0x11
P_LFSRMASK_H = 0xa0

P_LED_ALL = ~0x3c 	;11000011
P_LED_R = 0x20
P_LED_Y = 0x10
P_LED_G = 0x04
P_LED_B = 0x08

P_N_LED_R = 0x00
P_N_LED_Y = 0x01
P_N_LED_G = 0x02
P_N_LED_B = 0x03

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
V_INTERRUPT_LED = 0x32

;Bool variables bit-addresses
RLED = P3.5		;INT3
YLED = P3.4 	;INT2
GLED = P3.2 	;INT0
BLED = P3.3		;INT1

B_BUTTON_FLAG = 0x40


;Code
.area INTV (ABS)
.org 0x0000
_int_reset:
	ljmp main


.org 0x0003 	;ext0
_int_GLED:
	mov V_INTERRUPT_LED, #P_N_LED_G
	ljmp ext_interrupt_handler


.org 0x0013 	;ext1
_int_BLED:
	mov V_INTERRUPT_LED, #P_N_LED_B
	ljmp ext_interrupt_handler


.org 0x0053 	;ext2
_int_YLED:
	mov V_INTERRUPT_LED, #P_N_LED_Y
	ljmp ext_interrupt_handler


.org 0x005b 	;ext3
_int_RLED:
	mov V_INTERRUPT_LED, #P_N_LED_R
	ljmp ext_interrupt_handler
	

.org 0x0063 	;T2
_int_T2:
	ljmp t2_interrupt_handler
	
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
	mov TL0, #0x01
	mov TH0, #0x00
	mov TMOD, #0x00
	mov AUXR, #0x80
	mov TCON, #0x05
	setb TR0
	
	initialize_debounce:
		mov IE, #0x05	;EX1 | EX0
		mov AUXR2, #0x30	;EX3 | EX2
		setb EA
		orl PCON, #0x01 	;IDL
		clr EA
	
		mov dptr, #P_LEDLOC
		mov a, V_INTERRUPT_LED
		anl a, #0x03
		movc a, @a+dptr
		
		lcall delay_debounce
		
		xrl a, P3
		orl a, #P_LED_ALL
		cpl a
		
		jnz initialize_debounce
		
	initialize_release:
		lcall delay_debounce
		mov a, P3
		orl a, #P_LED_ALL
		cpl a
		jnz initialize_release
	
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
	mov T2L, #0x00
	mov T2H, #0xf8
	sjmp delay_activate	

delay_display2:
	mov T2L, #0x00
	mov T2H, #0xe0
	sjmp delay_activate

delay_display:
	mov T2L, #0x00
	mov T2H, #0xb0
	;sjmp delay_activate
	
delay_activate:
	orl IE2, #0x04		;Enable T2 interrupt
	orl AUXR, #0x04		;T2 is 1clk
	orl PCON2, #0x07 	;clk/128
	setb EA
	
	orl AUXR, #0x10 	;enable T2
	orl PCON, #0x01 	;IDL
	anl AUXR, #~0x10 	;disable T2
	
	clr EA
	anl PCON2, #~0x07 	;clk/1
	ret


	
ext_interrupt_handler:
	anl AUXR2, #~0x30	;EX3 | EX2
	anl IE, #~0x05	;EX1 | EX0
	reti
	
	
	
t2_interrupt_handler:
	anl IE2, #~0x04
	reti
	
	
.area DSEG (ABS)
.org P_LEDLOC

.db P_LED_R, P_LED_Y, P_LED_G, P_LED_B