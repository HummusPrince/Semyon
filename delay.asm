.title "delay routines"

.area CODE
delay_debounce:
	mov T2L, #0x00
	mov T2H, #0xfc
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
