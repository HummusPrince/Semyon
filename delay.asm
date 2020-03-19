.title "delay routines"

.area CODE
delay_debounce:
	t0_set_count, 0x400
	sjmp delay_activate	

delay_display2:
	t0_set_count, 0x2000
	sjmp delay_activate

delay_display:
	t0_set_count, 0x5000
	;sjmp delay_activate
	
delay_activate:
	anl TMOD, #~0x03
	orl TMOD, #0x01 	;mode 1 (16-bit one-time)
	orl AUXR, #0x80 	;T0 is 1clk
	t0_int_enable		;Enable T0 interrupt
	
	orl PCON2, #0x07 	;clk/128
	interrupt_enable
	setb TR0
	orl AUXR, #0x10 	;enable T2
	
	orl PCON, #0x01 	;IDL
	
	anl AUXR, #~0x10 	;disable T2
	clr TR0
	interrupt_disable
	anl PCON2, #~0x07 	;clk/1
	ret
