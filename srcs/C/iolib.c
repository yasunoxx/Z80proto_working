/*
	Z88DK - Rabbit Control Module examples

	Example I/O lib to use shadow registers in a unified way,
	in due time this should go into the rcmx000 library!

*/

#include "iolib.h"

static unsigned ioi_data;
static unsigned ioi_addr;


static void ioi_inb_impl()
{
#asm
  push hl;
  push af;

  ld hl,(_ioi_addr);
  defb 0d3h ; ioi ;
  ld a,(hl);
  ld (_ioi_data),a;

  pop af ;
  pop hl ;
#endasm
}

unsigned char iolib_inb(unsigned register)
{
  ioi_addr=iolib_physical(register);
  ioi_inb_impl();
  return ioi_data;
}

static void ioi_outb_impl()
{
#asm
  push hl ;
  push af ;
  
  ld hl,(_ioi_addr);
  ld a,(_ioi_data);

  defb 0d3h; ioi ;
  ld (hl),a ;
  
  pop af ;
  pop hl ;
#endasm
}

void iolib_outb(unsigned register, unsigned char data)
{
  ioi_addr=iolib_physical(register);
  ioi_data=data;
  ioi_outb_impl();
  shadow_value[register]=data;
}
