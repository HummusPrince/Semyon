.module inth
.title "interrupt handles"

;Def file includes
.include "define.def"
.include "macro.def"

.area CODE

reset_handler:
	mov SP, #P_STACK_BASE - 1 	;P_STACK_BASE == value + 1
	ljmp main

ext_interrupt_handler:
	ext_int_disable
	reti
	
t2_interrupt_handler:
	t2_int_disable
	reti
