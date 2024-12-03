;	fputc_cons
	INCLUDE "serial.def"
	PUBLIC  fputc_cons_native

.fputc_cons_native
	ld      bc,UART_BASE + LSR
loop:
	in      a,(c)
	and     a,$20
	jr      z,loop
	ld      hl,2
	add     hl,sp
	ld      a,(hl)
	ld      bc,UART_BASE
	out     (c),a
	ret
