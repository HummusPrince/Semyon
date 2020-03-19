

build:
	sdas8051 -los semyon.asm
	sdld -f semyon
	packihx semyon.ihx > semyon.hex
	
clean:
	rm -f *.ihx
	rm -f *.rel
	rm -f *.map
	rm -f *.lst
	rm -f *.rst
	rm -f *.sym