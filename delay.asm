.module delay
.title "delay routines"

;Def file includes
.include "define.def"
.include "macro.def"

.area CODE
delay_debounce:
	t0_set_count, 0x0010
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
	
    set_clk_div, 7
	interrupt_enable
	setb TR0
	
	idl_mode

	clr TR0
	interrupt_disable
    set_clk_div, 0
	ret
