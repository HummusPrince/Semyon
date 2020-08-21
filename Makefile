all: table build

build:
	as8051 -losga main.asm
	as8051 -losga intv.asm
	as8051 -losga inth.asm
	as8051 -losga io.asm
	as8051 -losga delay.asm
	as8051 -losga dseg.asm
	as8051 -losga pwm.asm
	
	aslink -f semyon
	packihx semyon.ihx > semyon.hex
	
table: 
	python ./gen_pwm.py
	
clean:
	rm -f *.ihx
	rm -f *.rel
	rm -f *.map
	rm -f *.lst
	rm -f *.rst
	rm -f *.sym
	rm -f *.hlr