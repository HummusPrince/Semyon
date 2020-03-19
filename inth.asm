.title "interrupt handles"

.area CODE

ext_interrupt_handler:
	ext_int_disable
	reti
	
t2_interrupt_handler:
	t2_int_disable
	reti
