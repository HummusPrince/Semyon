.title "delay routines"

.area CODE
delay_debounce:
	t2_set_count, 0x400
	sjmp delay_activate	

delay_display2:
	t2_set_count, 0x2000
	sjmp delay_activate

delay_display:
	t2_set_count, 0x5000
	;sjmp delay_activate
	
delay_activate:
	t2_int_enable		;Enable T2 interrupt
	orl AUXR, #0x04		;T2 is 1clk
	orl PCON2, #0x07 	;clk/128
	interrupt_enable
		
	orl AUXR, #0x10 	;enable T2
	orl PCON, #0x01 	;IDL
	anl AUXR, #~0x10 	;disable T2
	
	interrupt_disable
	anl PCON2, #~0x07 	;clk/1
	ret
