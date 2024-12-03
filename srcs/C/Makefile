
all: embedded_clib2.lib hello.bin

embedded_clib2.lib: fputc_cons.asm fgetc_cons.asm
	z88dk-z80asm -d -DFORembedded -xembedded_clib2 @clib2.lst

hello.bin: embedded_clib2.lib hello.c
	zcc +embedded -vn hello.c -o hello.bin -L. -lembedded_clib2

clean:
	$(RM) *.bin *.i *.lib *.op* *.o *~ zcc_opt.def
