.module semyon

LEDLEN = 5
LEDLOC = 0x300
PCON = 0x97

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
	mov r0, #LEDLEN
main_loop:
	mov r1, #0x04
	mov a, r0
	mov dptr, #LEDLOC
	movc a, @a+dptr
	mov r2, a
main_loop2:
	mov a, r2
	anl a, #0x03
	mov r3, a
	lcall display_led_jumptable
read_next_led:
	mov a, r2
	rr a
	rr a
	mov r2, a
	djnz r1, main_loop2
	djnz r0, main_loop
	sjmp main

display_led_jumptable:
	mov dptr, #jumptable
	mov a, r3
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
	mov r5, #0x18
	mov r6, #0x00
	mov r7, #0x00
delay_loop:
	djnz r7, delay_loop
	djnz r6, delay_loop
	djnz r5, delay_loop
	ret


.area DSEG (ABS)
.org LEDLOC + 1
.db 0xfc, 0x99, 0x33, 0x1b, 0xe4