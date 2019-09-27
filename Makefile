

build:
	sdas8051 -los semyon.asm
	sdld -i semyon
	packihx semyon.ihx > semyon.hex