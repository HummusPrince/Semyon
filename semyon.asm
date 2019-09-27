.module semyon

.area INTV (ABS)
.org 0x0000
_int_reset:
	ljmp main
	
.area CSEG (ABS, CON)
.org 0x0090

main:
	jnb P3.5, clearg
	clr P3.2
	sjmp main

	
clearg:
	setb P3.2
	sjmp main
