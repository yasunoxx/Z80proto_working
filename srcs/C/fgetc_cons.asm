;	fgetc_cons
	INCLUDE "serial.def"
	PUBLIC	fgetc_cons

.fgetc_cons
	ld      bc,UART_BASE + LSR
loop:
	in      a,(c)
	and     a,$1
	jr      z,loop
	ld      bc,UART_BASE
	in      a,(c)
	ld      l,a
	ret
