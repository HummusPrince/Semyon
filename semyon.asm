.module semyon

LEDLEN = 16
LEDLOC = 0x300
PCON = 0x97

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
	mov V_LED_MAX, #LEDLEN + 1
	mov V_LED_CNT, #0
main_loop:
	mov a, r4
	cjne a, V_LED_CNT, display_led
	mov r4, #0x00
	inc V_LED_CNT
wait_user:
	jb RLED, wait_user
	lcall delay
	mov a, V_LED_MAX
	cjne a, V_LED_CNT, display_led
	mov V_LED_CNT, #1
	
display_led:
	lcall get_led_val
	inc r4
	mov r3, a
	lcall display_led_jumptable
	sjmp main_loop

	
	
get_led_val:
	mov dptr, #LEDLOC
	mov a, r4
	movc a, @a+dptr
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
	mov r5, #0x0C
	mov r6, #0x00
	mov r7, #0x00
delay_loop:
	djnz r7, delay_loop
	djnz r6, delay_loop
	djnz r5, delay_loop
	ret


.area DSEG (ABS)
.org LEDLOC
.db 0x00, 0x01, 0x03, 0x02, 0x00, 0x01, 0x03, 0x02, 0x00, 0x03, 0x01, 0x02, 0x00, 0x03, 0x01, 0x02