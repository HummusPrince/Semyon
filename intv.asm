.title "interrupt vectors"

.area INTV (ABS)
.org 0x0000
_int_reset:
	ljmp main


.org 0x0003 	;ext0
_int_GLED:
	mov V_INTERRUPT_LED, #P_N_LED_G
	ljmp ext_interrupt_handler


.org 0x0013 	;ext1
_int_BLED:
	mov V_INTERRUPT_LED, #P_N_LED_B
	ljmp ext_interrupt_handler


.org 0x0053 	;ext2
_int_YLED:
	mov V_INTERRUPT_LED, #P_N_LED_Y
	ljmp ext_interrupt_handler


.org 0x005b 	;ext3
_int_RLED:
	mov V_INTERRUPT_LED, #P_N_LED_R
	ljmp ext_interrupt_handler
	

.org 0x0063 	;T2
_int_T2:
	ljmp t2_interrupt_handler
