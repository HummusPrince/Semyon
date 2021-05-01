##Variables

AS = as8051
#AS = sdas8051
ASFLAGS = -losga

LD = aslink
#LD = sdld
LDFLAGS = -f

#FILES = main intv inth io delay dseg pwm
FILES = main.rel intv.rel inth.rel io.rel delay.rel dseg.rel pwm.rel
BIN = semyon


##Rules
%.rel: %.asm
	${AS} ${ASFLAGS} $^

%.hex: %.ihx
	packihx $^ > $@

#%.ihx: %{FILES:.asm=.rel}
%.ihx: ${FILES}
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
	rm -f *.ihx
	rm -f *.rel
	rm -f *.map
	rm -f *.lst
	rm -f *.rst
	rm -f *.sym
	rm -f *.hlr