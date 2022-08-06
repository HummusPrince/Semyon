##Variables

AS = as8051
#AS = sdas8051
ASFLAGS = -losga

LD = aslink
#LD = sdld
LDFLAGS = -f

PRG = stcgal
PRGFLAGS = -P stc15 -b 1200

FILES = main intv inth io delay dseg pwm
BIN = semyon


##Rules
%.rel: %.asm
	${AS} ${ASFLAGS} $^

%.hex: %.ihx
	packihx $^ > $@

%.ihx: ${addsuffix .rel, ${FILES}}
	${LD} ${LDFLAGS} $@


##Targets
.PHONY: all
all: build clean

.PHONY: complete
complete: table build

.PHONY: build
build: ${BIN}.hex

.PHONY: table
table: 
	python ./gen_pwm.py

.PHONY: clean
clean:
	rm -f *.{ihx,rel,map,lst,sym,hlr,rst}
	
.PHONY: cleanall
cleanall: clean
	rm -f *.hex

.PHONY: flash
flash: ${BIN}.hex
	${PRG} ${PRGFLAGS} $^
