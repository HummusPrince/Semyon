.module semyon

LEDLEN = 5
LEDLOC = 0x300
PCON = 0x97

.area INTV (ABS)
.org 0x0000
_int_reset:
	ljmp main
	
.area CSEG (ABS, CON)
.org 0x0090

main:
	mov r0, #LEDLEN
	mov DPH, #(LEDLOC >> 8)
	mov DPL, #(LEDLOC & 0xff)
main_loop:
	mov r1, #0x04
	mov a, r0
	movc a, @a+DPTR
	mov r2, a
main_loop2:
	;red = P3.5
	;yellow = P3.4
	;green = P3.2
	;blue = P3.3
	mov a, r2
	;add a, 0x01
	anl a, #0x03
blue:
	cjne a, #0x03, green
	;clr P3.2
	clr P3.3
	acall delay
	setb P3.3
	sjmp read_next_led
green:
	cjne a, #0x02, yellow
	clr P3.2
	acall delay
	setb P3.2
	sjmp read_next_led
yellow:
	cjne a, #0x01, red
	clr P3.4
	acall delay
	setb P3.4
	sjmp read_next_led
red:
	clr P3.5
	acall delay
	setb P3.5
	
read_next_led:
	;acall delay
	mov a, r2
	rr a
	rr a
	mov r2, a
	;cpl P3.4
	djnz r1, main_loop2
	djnz r0, main_loop
	sjmp main


delay:
	;cpl P3.5
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