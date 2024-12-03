/*
	Z88DK - Rabbit Control Module examples

	Example I/O lib to use shadow registers in a unified way,
	in due time this should go into the rcmx000 library!

*/

/** This is indices to shadow registers and address lookup tables,
    not actual addresses */

#ifndef IOLIB__H
#define IOLIB__H

/** Input one byte from reg */
extern unsigned char iolib_inb(unsigned register);

/** Output one byte to reg */
extern void iolib_outb(unsigned register, unsigned char data);

#endif


