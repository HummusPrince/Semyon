.title "interrupt handles"

.area CODE

ext_interrupt_handler:
	anl AUXR2, #~0x30	;EX3 | EX2
	anl IE, #~0x05	;EX1 | EX0
	reti
	
t2_interrupt_handler:
	anl IE2, #~0x04
	reti
