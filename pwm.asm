.module pwm
.title "PWM routines"

;Def file includes
.include "define.def"
.include "macro.def"

.area CODE

;No 0x00 values for pwm allowed!
pwm_led:
	
	anl TMOD, #~0x03
	orl TMOD, #0x02 	;Autoreload 8-bit mode
	anl AUXR, #~0x80 	;Set T0 to sysclk/12
	
	mov V_LAST_P3, #0xff
	
	t0_int_enable
	interrupt_enable
	
	mov dptr, #D_LEDPWM - 1	;Base address for the data
	mov r5, #D_LEDPWM_LEN
	
	
pwm_led_loop:
	;get pwm duration
	mov a, r5
	movc a, @a+dptr
	mov r6, a
	
	;get pwm value
	dec r5
	mov a, r5
	movc a, @a+dptr
	mov TH0, a
	mov r7, a 
	
	pwm_led_cycle:	
		clr a
		clr c
		;orl PCON2, #0x04 	;clk/16
		setb TR0
		;subb a, TH0 	;For some mysterious reason this read fails miserably (0x00 returned probably)
		subb a, r7
		mov TH0, a
		mov a, V_PWM_LED
		idl_mode
		xrl P3, a
		idl_mode
		orl P3, a
		;anl PCON2, #~0x07 	;clk/1
		clr TR0
		mov TL0, #0x00
		djnz r6, pwm_led_cycle

	mov a, P3
	anl V_LAST_P3, a
		
	djnz r5, pwm_led_loop	
	interrupt_disable
	t0_int_disable

	;orl V_LAST_P3, #0xc3
	;mov P3, V_LAST_P3
	;sjmp .
	
	ret
