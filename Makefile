

build:
	sdas8051 -los semyon.asm
	sdas8051 -los inth.asm
	sdld -f semyon
	packihx semyon.ihx > semyon.hex