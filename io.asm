.module io
.title "IOs and sequence gen."

;Def file includes
.include "define.def"
.include "macro.def"

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
	mov V_PWM_LED, a

    xrl P3, a
    .ifdef B_8G1K08A
        xrl P5, a
    .endif

	lcall delay_display
	lcall pwm_led
	ret


get_overlap_buttons:
	;This one gets buttons that were clicked DURING PWM sequence.
	;It helps get the buttons response better.
	;Right now it won't get fast clicks on the same button it used.
	
	mov a, V_PWM_LED
	orl V_LAST_P3, a
		
	get_overlap_buttons_red:
	jb VB_RED, get_overlap_buttons_yel
		mov V_OVERLAP_LED, #P_N_LED_R
		sjmp get_overlap_buttons_return
	get_overlap_buttons_yel:
	jb VB_YEL, get_overlap_buttons_gre
		mov V_OVERLAP_LED, #P_N_LED_Y
		sjmp get_overlap_buttons_return
	get_overlap_buttons_gre:
	jb VB_GRE, get_overlap_buttons_blu
		mov V_OVERLAP_LED, #P_N_LED_G
		sjmp get_overlap_buttons_return
	get_overlap_buttons_blu:
	jb VB_BLU, get_overlap_buttons_retnull
		mov V_OVERLAP_LED, #P_N_LED_B
		;sjmp get_overlap_buttons_return
	get_overlap_buttons_return:
		;get_pwm_led
		ret
	get_overlap_buttons_retnull:
	mov V_OVERLAP_LED, #P_OVERLAP_LED_NULL
	ret


get_pwm_led:
	mov dptr, #D_LEDLOC
	mov a, V_INTERRUPT_LED
	anl a, #0x03
	movc a, @a+dptr
	mov V_PWM_LED, a
	ret
