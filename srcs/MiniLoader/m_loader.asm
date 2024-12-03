;   m_loader.asm -- MiniLoader for Z80proto
;   (C)2024 yasunoxx▼Julia
;   assemble: zcc +embedded --no-crt m_loader.asm -o m_loader.bin

i8253_C0    EQU 10h
i8253_C1    EQU 11h
i8253_C1_LSB    EQU 40h
i8253_C1_MSB    EQU 9Ch
i8253_C2    EQU 12h
i8253_CC    EQU 13h
;
PO_0        EQU 00h
PO_1        EQU 01h
PO_2        EQU 02h
ROMSEL      EQU 08h
PAGE1       EQU 09h
PI_0        EQU 0Ch
;
CTC_Ch0     EQU 20h
CTC_Ch1     EQU 21h
CTC_Ch2     EQU 22h
CTC_Ch3     EQU 23h
SIO_Ch0_D   EQU 24h
SIO_Ch0_C   EQU 25h
SIO_Ch1_D   EQU 26h
SIO_Ch1_C   EQU 27h

SYSMEM_TOP  EQU 0F000h
PO_2_BUP    EQU 0F800h
PROG_PLACE  EQU 0F801h
V_CNT_16    EQU 0F802h
V_CNT_8A    EQU 0F804h
V_CNT_8B    EQU 0F805h
SPI_SELD_DEV    EQU 0F806h
;
SEG_STATE   EQU 0F810h
SEG_POS     EQU 0F811h
SEG_0       EQU 0F812h
SEG_1       EQU 0F813h
SEG_2       EQU 0F814h
SEG_3       EQU 0F815h
SEG_4       EQU 0F816h
SEG_5       EQU 0F817h
;
LOOP_SEQ    EQU 0F820h
BUF_ASC2BIN EQU 0F821h
;
F_STAT_SIO0 EQU 0F830h
F_STAT_SIO1 EQU 0F831h
PTR_BUF_SIO0_RX_READ    EQU 0F832h
PTR_BUF_SIO0_RX_WRITE   EQU 0F833h
PTR_BUF_SIO1_RX_READ    EQU 0F834h
PTR_BUF_SIO1_RX_WRITE   EQU 0F835h
PTR_BUF_SIO0_TX_READ    EQU 0F836h
PTR_BUF_SIO0_TX_WRITE   EQU 0F837h
PTR_BUF_SIO1_TX_READ    EQU 0F838h
PTR_BUF_SIO1_TX_WRITE   EQU 0F839h
BUF_GETCHAR_SIO0        EQU 0F83Ah
CNT_BUF_CON EQU 0F83Bh
;
BUF_SIO0RX  EQU 0F840h
BUF_SIO1RX  EQU 0F880h
BUF_CON EQU 0F8C0h
SIZE_BUF_CON    EQU 64
BUF_SIO0TX  EQU 0F900h
BUF_SIO1TX  EQU 0F940h
BUF_SPIDATA EQU 0F980h
;   Next    EQU 0FA80h

S_SEG_0     EQU 0
S_SEG_1     EQU 1
S_SEG_2     EQU 2
S_SEG_3     EQU 3
S_SEG_4     EQU 4
S_SEG_5     EQU 5

SEG_CHR_0   EQU 0
SEG_CHR_1   EQU 1
SEG_CHR_2   EQU 2
SEG_CHR_3   EQU 3
SEG_CHR_4   EQU 4
SEG_CHR_5   EQU 5
SEG_CHR_6   EQU 6
SEG_CHR_7   EQU 7
SEG_CHR_8   EQU 8
SEG_CHR_9   EQU 9
SEG_CHR_A   EQU 10
SEG_CHR_B   EQU 11
SEG_CHR_C   EQU 12
SEG_CHR_D   EQU 13
SEG_CHR_E   EQU 14
SEG_CHR_F   EQU 15
SEG_CHR_H   EQU 16
SEG_CHR_I   EQU 17
SEG_CHR_J   EQU 18
SEG_CHR_L   EQU 19
SEG_CHR_N   EQU 20
SEG_CHR_O   EQU 21
SEG_CHR_P   EQU 22
SEG_CHR_R   EQU 23
SEG_CHR_T   EQU 24
SEG_CHR_U   EQU 25
SEG_CHR_V   EQU 26
SEG_CHR_X   EQU 27
SEG_CHR_Y   EQU 28
SEG_CHR_Z   EQU 29
SEG_CHR_HYPEN   EQU 30
SEG_CHR_NOUN    EQU 31
SEG_CHR_VERB    EQU 32
SEG_CHR_BLANK   EQU 33

; SCI Control Characters
NULL    EQU 0
BELL    EQU 07h
CR      EQU 0Dh
LF      EQU 0Ah
DELETE  EQU 7Fh
BACKSPACE   EQU 08h

; SPI device addr.
SPI_DEVID_NULL  EQU 00000000b
SPI_DEVID_Ch0   EQU 00100000b
SPI_DEVID_Ch1   EQU 01000000b
SPI_DEVID_Ch2   EQU 01100000b
SPI_DEVID_Mask  EQU SPI_DEVID_NULL

; 23LC512 command
SPIRAM_MODE_BYTE    EQU 00000000b
SPIRAM_MODE_PAGE    EQU 01000000b
SPIRAM_MODE_BURST   EQU 10000000b
SPIRAM_CMD_WRMR     EQU 00000001b
SPIRAM_CMD_WRITE    EQU 00000010b
SPIRAM_CMD_READ     EQU 00000011b
SPIRAM_CMD_RDMR     EQU 00000101b
SPIRAM_CMD_RSTIO    EQU 11111111b

; Flags F_STAT_SIOn
F_STAT_ALLSENT  EQU 0
F_STAT_BREAK    EQU 1
F_STAT_RECEIVE  EQU 2
F_STAT_TXEMPTY  EQU 3

;;
;;; Program
;;
;   Run on ROM
;    ORG 0h
;   Run on RAM with ipl0.bin
    ORG 0E000h
rst00:
;
    ld sp, 0h
;;  set Interrupt mode
;    im 1
    im  2
;
    jp main

rst08:
    jp  debug_rst08
;
    defs    5

rst10:
    jp  debug_rst10
;
    defs    5

rst18:
    jp  debug_rst18
;
    defs    5

rst20:
    nop
    ret
;
    defs    6

rst28:
    nop
    ret
;
    defs    6

rst30:
    nop
    ret
;
    defs    6

;
; im1 Interrupts
;
rst38:
isr:
;    ORG 0038h
;
    push    af
    push    bc
    push    de
    push    hl

;;  guess who?
    call    int_sci
    call    int_i8253

isr_end:
;;  end ISR
    pop hl
    pop de
    pop bc
    pop af
;
    ei
    reti


;    defs    29
    defs    7
;    ORG 0050h
Hexadecimal:
    defb    '0'
    defb    '1'
    defb    '2'
    defb    '3'
    defb    '4'
    defb    '5'
    defb    '6'
    defb    '7'
    defb    '8'
    defb    '9'
    defb    'A'
    defb    'B'
    defb    'C'
    defb    'D'
    defb    'E'
    defb    'F'
;
    defs    6

;   NMI
;    ORG 0066h
nmi:
;    retn
    jp  DEBUGSTOP
    halt

    defs    6

Vectors:
;   0070h~  CTC
INTCTC:
    defw    int_counter
    defw    int_void
    defw    int_void
    defw    int_void
;
;   0078h   SIO
INTSIO:
    defw    int_SIO
;
;   007Ah   DMA
INTDMA:
    defw    int_void
;
    defs    20

; ----------------------------------------------------------------------------
;;
;;;   Main routine ?
;;
; ----------------------------------------------------------------------------
;
main:
    xor a
    out (PO_0), a
    out (PO_1), a
    out (PO_2), a
    out (ROMSEL), a
    out (PAGE1), a
;
main1:
    ld  a, 00000100b    ; Initial PO_2 value
    call    out_PO_2

;    jr init ; on ROM

;;
;;; Evaluate: ROMKICK(for Z80proto2)
;;
    ld  a, 00000001b
    out (PO_0), a
    out (ROMSEL), a

    ld  bc, 0789h
    call    sloop
;;
;; copy Head block
PAYLOAD     EQU 0E000h
SIZE        EQU 90h
IPL0AREA    EQU 00000h
    ld  hl, PAYLOAD
    ld  de, IPL0AREA
    ld  bc, SIZE
    ldir

init:
;; initialize system devices
;    call    conf_timer1
;    call    conf_timer_other
    call    conf_CTC
    call    conf_sysmem
    call    conf_SIO
;
    call    spi_dev_unsel
;
    ei

;;
;;; Proto2 title
;;
    ; Proto2 title
    ld  hl, SEG_TITLE_PROTO2
    ld  de, SEG_0
    ld  bc, 6
    ldir

    call    loop
;
;; Jump to the Application
    jp  loader

;; or Halt stop
    nop
    halt


;;
;;; MiniLoader, a small loader
;;
loader:
    ; Loader title
    ld  hl, SEG_TITLE_LOADER
    ld  de, SEG_0
    ld  bc, 6
    ldir

;; Loader title to SIO0
    ld  hl, STR_loader_title
    call    puts_SIO0
    jr  loader_2
STR_loader_title:
    defm    "MiniLoader"
    defb    CR
    defb    LF
    defb    NULL
STR_loader_prompt:
    defm    ">>>"
    defb    NULL

loader_2:
    call    loop
; check AUTOLOAD switch
    in  a, (PI_0)
    bit 2, a
    jp  z, loader_spi_loop

;;
;;;
;;;; Console Mode
;;;
;;
loader_cons:
    ; Console title
    ld  hl, SEG_TITLE_CONS
    ld  de, SEG_0
    ld  bc, 6
    ldir
;
loader_cons_oneliner:
; Startup Console one line
;; Prompt to SIO0
    ld  hl, STR_loader_prompt
    call    puts_SIO0
;
    ld  ix, BUF_CON
    ld  hl, CNT_BUF_CON
    xor a
    ld  (hl), a
;
loader_cons_loop:
    call    getchar_SIO0
; receive anything ?
    cp  NULL
    jr  z, loader_cons_loop ; nothing
;
    cp  DELETE
    jr  z, del_cons
    cp  BACKSPACE
    jr  z, bs_cons
;
    call    putchar_SIO0    ; echo back
    cp  CR
    jr  z, parse_cons
;
; Other Characters
    cp  'a' - 1
    jr  c, loader_cons_loop_1
; Conversion UCASE
    sub 20h
loader_cons_loop_1:
    ld  (ix), a ;   A -> (BUF_CON)
;
    inc ix
    inc (hl)    ;   CNT_BUF_CON
;
    jr  loader_cons_loop

bs_cons:
;; BACKSPACE
del_cons:
;; DELETE
;
    ld  hl, CNT_BUF_CON
    ld  a, (hl)
    cp  0
    jr  nz, bs_cons_2
    ld  a, BELL
    call    putchar_SIO0
    jr  loader_cons_loop
;
bs_cons_2:
    dec (hl)
    dec ix
;
    ld  a, BACKSPACE
    call    putchar_SIO0    ; echo back
    jr  loader_cons_loop

parse_cons:
;; parse command
parse_cons_2:
    ld  hl, CNT_BUF_CON
    ld  a, (hl)
;
    ld  b, 0
    ld  c, a    ; BC = CNT_BUF_CON
    ld  hl, BUF_CON
    add hl, bc  ; HL = BUF_CON + CNT_BUF_CON
    ld  a, NULL
    ld  (hl), a ; NULL termination
;
;    ld  hl, BUF_CON
;    call    puts_SIO0
;    ld  a, CR
;    call    putchar_SIO0
;    ld  a, LF
;    call    putchar_SIO0
;
    ld  hl, BUF_CON
    ld  a, (hl)
;
parse_cons_3:
    cp  'L'
    jp  z, loader_spi_loop
    cp  'D'
    jp  z, dump_cons
;
;   cp  'M'
;   jp  z, modify_cons
;   cp  'S'
;   jp  z, select_spidev
;   cp  'R'
;   jp  z, read_spibuf
;   cp  'W'
;   jp  z, write_spibuf
;   cp  'I'
;   jp  z, in_port_cons
;   cp  'O'
;   jp  z, out_port_cons
;
    jp  loader_cons_oneliner

dump_cons:
;   get start addr.
    ld  ix, BUF_CON
    inc ix
    ld  hl, BUF_ASC2BIN ; for a2nibble/nibble2a
;
; BUF_CON+3 -> 4 nibbles
    call    a2nibble
    call    a2nibble
    ld  a, (BUF_ASC2BIN)    ; 2 nibbles
    ld  b, a
    call    a2nibble
    call    a2nibble
    ld  a, (BUF_ASC2BIN)    ; 2 nibbles
    ld  c, a
;
    ld  de, bc  ; dump start address
;
; dump 128 bytes, 16 bytes x 8 lines
    ld  b, 8
dump_cons_loop:
; Address
    call    dump_cons2
    push    hl
    ld  hl, BUF_SIO0TX
    call    puts_SIO0
    pop hl
;
    ld  a, ':'
    call    putchar_SIO0
; output 16 bytes and Increment
    call    dump_cons3
    push    hl
    ld  hl, 16
    add hl, de
    ex  de, hl
    pop hl
;
    djnz    dump_cons_loop
;
    jp  loader_cons_oneliner

dump_cons3:
; output 4bytes x 4
    push    bc
    push    de
    push    ix
;
dump_cons3_2:
    ld  b, 8
    ld  ix, de

dump_cons3_3:
    ld  a, (ix)
    ld  d, a
    inc ix
    ld  a, (ix)
    ld  e, a
    inc ix
;
    call    dump_cons2
    push    hl
    ld  hl, BUF_SIO0TX
    call    puts_SIO0
    pop hl
;
    ld  a, b
    cp  7
    jr  z, dump_cons3_4
    cp  5
    jr  z, dump_cons3_4
    cp  3
    jr  z, dump_cons3_4
    jr  dump_cons3_5
dump_cons3_4:
    ld  a, ' '
    call    putchar_SIO0
dump_cons3_5:
    djnz    dump_cons3_3
;
    ld  a, CR
    call    putchar_SIO0
    ld  a, LF
    call    putchar_SIO0
;
    pop ix
    pop de
    pop bc
;
    ret

dump_cons2:
de2buf_sio0tx:
;
; DE(4 nibbles) -> BUF_SIO0TX
;
    push    bc
    push    hl

    ld  hl, BUF_ASC2BIN
    ld  bc, BUF_SIO0TX
;
    ld  a, d
    ld  (BUF_ASC2BIN), a
    xor a
    call    nibble2a
    xor a
    call    nibble2a
    ld  a, e
    ld  (BUF_ASC2BIN), a
    xor a
    call    nibble2a
    xor a
    call    nibble2a
;
dump_cons2_end:
    ld  a, NULL
    ld  (bc), a
;
    pop hl
    pop bc
;
    ret

nibble2a:
; 1 nibble -> 1 Hex Char.
; use HL(rld buffer), destroy IY, BC = char *
    rld

    push    bc
    ld  iy, Hexadecimal
    ld  b, 0
    ld  c, a
    add iy, bc
    pop bc
    ld  a, (iy)

    ld  (bc), a
    inc bc
;
    ret

a2nibble:
; 1 Hex char. -> 1 nibble
; use HL(rld buffer), IX = char *
    ld  a, (ix)
    call    asc2bin
; and store to BUF_ASC2BIN & rotate
    rld
    inc ix
;
    ret

asc2bin:
; A = Conversion ASCII Chr., return binary
    cp  'A' - 1
    jr  nc, asc2bin_A2F
; not A~F
    sub '0'
;
    ret
;
asc2bin_A2F:
    sub 'A'
    add 10
;
    ret

;;
;;;
;;;; SPI loader Mode
;;;
;;
loader_spi_loop:
    call    loader_spiram_init
    jr  loader_spi_loop2
;
loader_spiram_init:
; 23LC512 init
    ld  a, SPI_DEVID_Ch0
    ld  (SPI_SELD_DEV), a
    call    spi_dev_sel
;
    ld  a, SPIRAM_CMD_RSTIO
    call    spi_write_8bit
;
    call    spi_dev_unsel
;
;; enter a byte mode
    ld  a, SPI_DEVID_Ch0
    ld  (SPI_SELD_DEV), a
    call    spi_dev_sel
;
    ld  a, SPIRAM_CMD_WRMR
    call    spi_write_8bit
    ld  a, SPIRAM_MODE_BYTE
    call    spi_write_8bit
;
    call    spi_dev_unsel
;
    ret

loader_spi_loop2:
;; write
    ld  a, SPI_DEVID_Ch0
    ld  (SPI_SELD_DEV), a
    call    spi_dev_sel
;
    ld  a, SPIRAM_CMD_WRITE
    call    spi_write_8bit
    xor a   ;   Addr. MSB
    call    spi_write_8bit
    xor a   ;   Addr. LSB
    call    spi_write_8bit
    ld  a, (LOOP_SEQ)
    dec a
    ld  (LOOP_SEQ), a
    call    spi_write_8bit
;
    call    spi_dev_unsel
;
;
;; read
    ld  a, SPI_DEVID_Ch0
    ld  (SPI_SELD_DEV), a
    call    spi_dev_sel
;
    ld  a, SPIRAM_CMD_READ
    call    spi_write_8bit
    xor a   ;   Addr. MSB
    call    spi_write_8bit
    xor a   ;   Addr. LSB
    call    spi_write_8bit
    call    spi_read_8bit
;
    push    af
    call    spi_dev_unsel
    pop af
;
;; wait
    call    drv_7seg_sub_disp2
    ld  bc, 0765h
    call    sloop
;
    jr  loader_spi_loop2

;;
;;; Misc. Subroutines
;;
sloop:
;; simple short loop
; BC = loop counts, destroy AF 
	dec bc
	ld a,c
	or b
	jr nz,sloop
;
    ret

loop:
;; simple long loop, destroy AF, BC
sub_05e4h:
	ld bc,8765h
l05e8h:
	dec bc
	ld a,c
    and 00001111b
    cp  00001111b
    jr  nz, l05e8h_2
l05e8h_2:
	ld a,c
	or b
	jr nz,l05e8h
;
    ret

get_SEG_CHR:
; C = character code(SEG_CHR_?), destroy A, IX
    ld  b, 0
;   ld  c, SEG_CHR_?
    ld  ix, numbers
    add ix, bc
    ld  a, (ix)
;
    ret

numbers:
    defb    11111100b   ;   0
    defb    01100000b   ;   1
    defb    11011010b   ;   2
    defb    11110010b   ;   3
    defb    01100110b   ;   4
    defb    10110110b   ;   5
    defb    10111110b   ;   6
    defb    11100100b   ;   7
    defb    11111110b   ;   8
    defb    11110110b   ;   9
    defb    11101110b   ;   A
    defb    00111110b   ;   b
    defb    10011100b   ;   C
    defb    01111010b   ;   d
    defb    10011110b   ;   E
    defb    10001110b   ;   F
    defb    01101110b   ;   H
    defb    00100000b   ;   i
    defb    01110000b   ;   J
    defb    00011100b   ;   L
    defb    00101010b   ;   n
    defb    00111010b   ;   o
    defb    11001110b   ;   P
    defb    00001010b   ;   r
    defb    00011110b   ;   t
    defb    01111101b   ;   U
    defb    10111001b   ;   v
    defb    10101011b   ;   x
    defb    01110111b   ;   y
    defb    10010011b   ;   Z
    defb    00000010b   ;   -
    defb    11000101b   ;   noun
    defb    01000111b   ;   verb
    defb    0           ;   blank / null termination

;   --------------------------------------------------------------------------
;;
;;; Interrupt Service Routines
;;
;   --------------------------------------------------------------------------

;;
;;; im1 devices
;;
int_sci:
;;  check SCI
    nop
;
    ret ; to rst38

int_i8253:
;;  time is up(maybe), re-set counter
    call    conf_timer1
;
    ret ; to rst38

;;
;;; im2 devices
;;
int_counter:    ; im2
;;
    push    af
    push    bc
    push    hl
    push    ix
;
int_counter_16:
;;  decrement 16bit value
    ld  hl, (V_CNT_16)
    dec hl
    jr  nc, int_counter_16_end
    ld  hl, 0
int_counter_16_end:
    ld  (V_CNT_16), hl
;
int_counter_8:
;;  decrement 8bit value
    ld  a, (V_CNT_8A)
    dec a
    jr  nc, int_counter_8B
    xor a
int_counter_8B:
    ld  (V_CNT_8A), a
;
    ld  a, (V_CNT_8B)
    dec a
    jr  nc, int_counter_8_end
    xor a
int_counter_8_end:
    ld  (V_CNT_8B), a
;
;; and drive 7seg
    call    drv_7seg
;
;; exit
    pop ix
    pop hl
    pop bc
    pop af
;
    ei
    reti

int_SIO:
    push    af
    call    analyze_SIO0    ; Get stat and Error Recovery
;
    push    ix
    ld  ix, F_STAT_SIO0
    bit F_STAT_RECEIVE, (ix)
    jr  nz, int_SIO_Ch0_RCA
    jr  int_SIO_exit
;
int_SIO_Ch0_RCA:
    res F_STAT_RECEIVE, (ix)
    push    bc
;
    ld  ix, BUF_SIO0RX
    ld  b, 0
    ld  a, (PTR_BUF_SIO0_RX_WRITE)
    ld  c, a
    add ix, bc
;
    in  a, (SIO_Ch0_D)
    ld  (ix), a
;
    ld  a, c
    inc a
    and 00111111b
    ld  (PTR_BUF_SIO0_RX_WRITE), a
;
    pop bc
    jr  int_SIO_exit

int_SIO_Ch1:
    jr  int_SIO_exit

int_SIO_exit:
    pop ix
    pop af
;
    ei
    reti

int_void:   ; im2
;; do nothing
    nop
;
    ei
    reti

;   --------------------------------------------------------------------------
;;
;;; configure I/O devices, Memory, etc
;;
;   --------------------------------------------------------------------------

;;
;;; Config i8253
;;
conf_timer1:
    ld a, 01110000b
                ; Counter #1
                ; Read/Write LSB before MSB
                ; Counter Mode 0
                ; Hexadecimal count
    out (i8253_CC), a
;
    ld a, i8253_C1_LSB
    out (i8253_C1), a
    ld a, i8253_C1_MSB
    out (i8253_C1), a
;
    ret

conf_timer_other:
    ld a, 00110000b
                ; Counter #0
                ; Read/Write LSB before MSB
                ; Counter Mode 0
                ; Hexadecimal count
    out (i8253_CC), a
;
    xor a
    out (i8253_C0), a
    out (i8253_C0), a
;
    ld a, 10110000b
                ; Counter #2
                ; Read/Write LSB before MSB
                ; Counter Mode 0
                ; Hexadecimal count
    out (i8253_CC), a
;
    xor a
    out (i8253_C2), a
    out (i8253_C2), a
;
    ret

;;
;;; configure System Memory
;;
conf_sysmem:
    ld  a, 10000000b
                ; set anode line 5(Magic!)
    call    out_PO_2
;
;;  config SEG memories
    ld  a, S_SEG_0
    ld  (SEG_STATE), a
    ld  a, 0            ; Position 0 start
    ld  (SEG_POS), a    ; POSition 0 to 5
    ld  a, 00000010b    ; 7seg display data
    ld  (SEG_0), a
    ld  (SEG_1), a
    ld  (SEG_2), a
    ld  (SEG_3), a
    ld  (SEG_4), a
    ld  (SEG_5), a
;;  config SIO Status flag
    xor a
    ld  (F_STAT_SIO0), a
    ld  (F_STAT_SIO1), a
;
;;  config SIO buffers
    call    init_SIO_buffers
;
    ret


;;
;;; configure Peripherals
;;
out_PO_2:
    out (PO_2), a
                ; OUTPUT anode line
    ld  (PO_2_BUP), a
                ; BACKUP PO_2
;
    ret

conf_CTC:
    ld  a, 3    ; Ch. Reset
    out(CTC_Ch0), a
    out(CTC_Ch1), a
    out(CTC_Ch2), a
    out(CTC_Ch3), a
;
    xor a       ; Interrupt Vector MSB
    ld  i, a
    ld  a, INTCTC - rst00  ; Interrupt Vector LSB
    out(CTC_Ch0), a
;
conf_CTC_Ch0:
    ld  a, 10000111b
                ; Ch0
                ; Interrupt Enable
                ; Timer Mode
                ; Prescaler 1/16φ
                ; Down Edge
                ; No Trigger Start
                ; Next: Time Constant
                ; Reset Enable, Timer start when write Time Constant
                ; This is configuration, not Interrupt Vector
    out(CTC_Ch0), a
    ld  a, 250  ; (16*250)/4000000 = 4000, 1msec/Interrupt
    out(CTC_Ch0), a
;
    ret
;
conf_CTC_Ch1:
;; call from conf_SIO_Ch0
    ld  a, 01000111b
                ; Ch1
                ; Interrupt Disable
                ; Counter Mode
                ; Down Edge
                ; Next: Time Constant
                ; Reset Enable, Counter start when write Time Constant
                ; This is configuration, not Interrupt Vector
    out(CTC_Ch1), a
    ld  a, 13  ; 13/2000000
    out(CTC_Ch1), a
;
    ret

conf_CTC_Ch2:
;; call from conf_SIO_Ch1
    ld  a, 01000111b
                ; Ch2
                ; same as Ch1
    out(CTC_Ch2), a
    ld  a, 13  ; 13/2000000
    out(CTC_Ch2), a
;
    ret

conf_SIO:
;;  Ch0 configure
;   Set CTC_Ch1
    call    conf_CTC_Ch1
    ;   13 counts, SIO prescale is 16, (13*16)/2000000 = 9615.38bps
;
    ld  b, 12
    ld  c, SIO_Ch0_C
    ld  hl, SIO0_CONF
    otir
;
;;  
;
;;  Ch1 configure
;   Set CTC_Ch2
    call    conf_CTC_Ch2
    ;   13 counts, SIO prescale is 16, (13*16)/2000000 = 9615.38bps
;
    ld  b, 6
    ld  c, SIO_Ch1_C
    ld  hl, SIO1_CONF
    otir
;
    ret

SIO1_CONF:
;   WR0, channel reset
    defb    0
    defb    00011000b
;   WR2, Interrupt Vector
    defb    2
    defb    INTSIO - rst00
;   WR1, Wait/Ready functions and Interrupt behavior
    defb    1
    defb    0           ; disable all(TORIAEZU)

SIO0_CONF:
;   WR0, channel reset
    defb    0
    defb    00011000b
;   WR2, Interrupt Vector(but Ch0 is not effect)
    defb    2
    defb    0
;   WR4, Rx and Tx control
    defb    4
    defb    01000100b    ; x16 clock, Async. Mode 1 stop bit, non parity
;   WR3, Receiver Logic control
    defb    3
    defb    11000001b    ; Rx 8bit, not Auto Enables, Rx enable
;    defb    11100001b    ; Rx 8bit, Auto Enables, Rx enable
;   WR5, Transmit control
    defb    5
    defb    01101000b    ; Tx 8bit, Tx enable
;   WR1, Wait/Ready functions and Interrupt behavior
    defb    1
    defb    00011100b    ; Wait/Ready disable, Rx INT on All receive character,
                        ; but parity error is not sp. condx., use Status Affects Vector,
                        ; Tx INT & Ext./Stat. INT disable
;    defb    00001100b    ; Wait/Ready disable, Rx INT on First receive character,
;                        ; set Status Affects Vector(but ignore it),
;                        ; Tx INT & Ext./Stat. INT disable


;   --------------------------------------------------------------------------
;;
;;; I/O subroutines
;;
;   --------------------------------------------------------------------------

;;
;;; SIO subroutines
;;
analyze_SIO0:
    push    af
    push    bc
    push    ix
    ld  ix, F_STAT_SIO0
;
    xor a
    out (SIO_Ch0_C), a
    ld  a, 00000000b    ; Select RR0
    out (SIO_Ch0_C), a
;
    in  a, (SIO_Ch0_C)
    ld  c, a
analyze_SIO0_RR0_bit0:
;;　read status and error recovery
    bit 0, c    ; Receive Character Available
    jr  z, analyze_SIO0_RR0_bit1
;
    ; Receiver Flag Set
    set F_STAT_RECEIVE, (ix)
;
analyze_SIO0_RR0_bit1:
    bit 1, c
    jr  z, analyze_SIO0_RR0_bit2
;
    xor a
    out (SIO_Ch0_C), a
    ld  a, 00101000b    ; Reset TxINT Pending
    out (SIO_Ch0_C), a
;
analyze_SIO0_RR0_bit2:
    bit 2, c
    jr  z, analyze_SIO0_RR0_bit6
;
    ; TxBuf Empty Flag Set
    set F_STAT_TXEMPTY, (ix)
;
analyze_SIO0_RR0_bit6:
    bit 6, c
    jr  z, analyze_SIO0_RR0_bit7
;
    xor a
    out (SIO_Ch0_C), a
    ld  a, 11010000b    ; Reset Transmit Underrun and Ext/Stat. Int.
    out (SIO_Ch0_C), a
;
analyze_SIO0_RR0_bit7:
    bit 7, c
    jr  z, analyze_SIO0_RR1
;
    ; Receive Break
    xor a
    out (SIO_Ch0_C), a
    ld  a, 00010000b    ; Reset Ext/Stat. Int.(see manual p296)
    out (SIO_Ch0_C), a
    set F_STAT_BREAK, (ix)
;
analyze_SIO0_RR1:
    xor a
    out (SIO_Ch0_C), a
    ld  a, 00000001b    ; Select RR1
    out (SIO_Ch0_C), a
;
    in  a, (SIO_Ch0_C)
    ld  a, c
analyze_SIO0_RR1_bit0:
    bit 0, c
    jr  z, analyze_SIO0_RR1_bit456
;
    ; Tx All sent flag set
    set F_STAT_ALLSENT, (ix)
;
analyze_SIO0_RR1_bit456:
    ld  a, c
    and  01110000b
    jr  z, analyze_SIO0_end
;
analyze_SIO0_RR1_bit456_e:
    ; Parity Error, Receive Overrun Error or Framing Error
    xor a
    out (SIO_Ch0_C), a
    ld  a, 00110000b    ; Reset Error
    out (SIO_Ch0_C), a
;
analyze_SIO0_end:
    pop ix
    pop bc
    pop af
;
    ret

putchar_SIO0:
;;  A = Transmit Character
    push    af
    push    ix
    ld  ix, F_STAT_SIO0
putchar_SIO0_1:
    call    analyze_SIO0
    bit F_STAT_TXEMPTY, (ix)
    jr  z, putchar_SIO0_1

putchar_SIO0_2:
    res F_STAT_TXEMPTY, (ix)
;
    pop ix
    pop af
;
    ; transmit
    out (SIO_Ch0_D), a
;
    ret

getchar_SIO0:
;;  A = Receive Character
    push    af
    push    bc
; Compare Read Pointer and Write Pointer
    ld  a, (PTR_BUF_SIO0_RX_READ)
    ld  b, 0
    ld  c, a
;
    ld  a, (PTR_BUF_SIO0_RX_WRITE)
    sub c
    jr  z, getchar_SIO0_norecv
; Get Receive Character from BUF_SIO0RX
    push    ix
    ld  ix, BUF_SIO0RX
    add ix, bc
    ld  bc, ix  ; BC = BUF_SIO0RX + (PTR_BUF_SIO0_RX_READ)
    pop ix
;
    ld  a, (bc)
    ld  (BUF_GETCHAR_SIO0), a
; Pointer Increment
    ld  a, (PTR_BUF_SIO0_RX_READ)
    inc a
    and 00111111b
    ld  (PTR_BUF_SIO0_RX_READ), a
;
    jr  getchar_SIO0_exit
;
getchar_SIO0_norecv:
    ld  a, NULL
    ld  (BUF_GETCHAR_SIO0), a
;
getchar_SIO0_exit:
    pop bc
    pop af
    ld  a, (BUF_GETCHAR_SIO0)
;
    ret

puts_SIO0:
;;  HL = String Addr.(NULL Term.)
    push    af
;
puts_SIO0_loop:
    ld  a, (hl)
    cp  0
    jr  z, puts_SIO0_end
;
    call    putchar_SIO0
    inc hl
    jr  puts_SIO0_loop
;
puts_SIO0_end:
    pop af
;
    ret

init_SIO_buffers:
    xor a
    ld  (PTR_BUF_SIO0_RX_READ), a
    ld  (PTR_BUF_SIO0_RX_WRITE), a
    ld  (PTR_BUF_SIO1_RX_READ), a
    ld  (PTR_BUF_SIO1_RX_WRITE), a
;
    ret

;;
;;; Proto2 7seg device drive
;;
drv_7seg:
;;  switch state ... ahh, dirty code.
    xor a
    ld  b, a
    ld  a, (SEG_STATE)
    ld  c, a
;
    cp  S_SEG_0
    jr  z, drv_7seg_S0
    cp  S_SEG_5
    jr  z, drv_7seg_S2
    jr  c, drv_7seg_S1

drv_7seg_S0:    ; output 7seg
;;  get 7seg anode line
    ld  a, (PO_2_BUP)
    call    out_PO_2
    and 11111100b
    sla a
    jr  nc, drv_7seg_S0_1
    ld  a, 00000100b
                ; set anode line 0
drv_7seg_S0_1:
;;  7seg anode line set(post)
    ld  c, a
    ld  a, (PO_2_BUP)
    and 00000011b
                ; erase anode line
    or  c       ; set new anode line
    call    out_PO_2
;
;;  getting cathode data ... get anode line,
    ld  a, (SEG_POS)
    ld  b, 0    ; already
    ld  c, a
;;  set display data pointer,
    ld  ix, SEG_0
    add ix, bc
;;  get cathode data, and output
    ld  a, (ix)
    out (PO_1), a
                ; OUTPUT cathode line

drv_7seg_S1:    ; do nothing
    ld  ix, SEG_STATE
    inc (ix)
    jr  drv_7seg_end

drv_7seg_S2:    ; 7seg blanking
    xor a
    out (PO_1), a
;
    ld  ix, SEG_STATE
    ld (ix), S_SEG_0

drv_7seg_exit:
;;  inclease anode line number
    ld  a, (SEG_POS)
    inc a
    cp  6
    jr  c, drv_7seg_S0_ex2
;;  reset anode line
    xor a
drv_7seg_S0_ex2:
    ld  (SEG_POS), a
;
drv_7seg_end:
    ret

;;
;;; 7seg subroutines
;;
drv_7seg_sub_disp4:
;; HL = disp. "  hhll", destroy AF, BC, HL
    ld  a, h
    and 11110000b
    srl a
    srl a
    srl a
    srl a
    ld  c, a
    call    get_SEG_CHR
    ld  (SEG_2), a
;
    ld  a, h
    and 00001111b
    ld  c, a
    call    get_SEG_CHR
    ld  (SEG_3), a
;
    ld  a, l
;
;   falldown to drv_7seg_sub_disp2

drv_7seg_sub_disp2:
;; A = disp. "    aa", destroy AF, BC, HL
    ld  l, a
;
    and 11110000b
    srl a
    srl a
    srl a
    srl a
    ld  c, a
    call    get_SEG_CHR
    ld  (SEG_4), a
;
    ld  a, l
    and 00001111b
    ld  c, a
    call    get_SEG_CHR
    ld  (SEG_5), a
;
    ret

;;
;;; SPI routines
;;
SCLK    EQU 3
MISO    EQU 4
MOSI    EQU 4

spi_dev_sel:
    push    bc
;
    ld  a, (SPI_SELD_DEV)
    ld  c, a
;
    in  a, (PI_0)
    and 00000011b
    or  c
    OUT (PO_0), a
;
    pop bc
    ret

spi_dev_unsel:
    ld  a, SPI_DEVID_NULL
    ld  (SPI_SELD_DEV), a
    jr  spi_dev_sel

spi_read_8bit:
    call    spi_dev_sel
;
    push    bc
    push    de
;
;;  read sequence
    ld  b, 8
    ld  e, 0
;
spi_read_8bit_2:
    sla e
;;  clock 'H'
;;  A reg = (PI_0) AND 00000011b OR SPI_SELD_DEV
    set SCLK, a
    out (PO_0), a
    ld  c, a
;
;;  read MISO
    in  a, (PI_0)
    bit MISO, a
    jr  z, spi_read_8bit_L
spi_read_8bit_H:
    set 0, e
    jr  spi_read_8bit_3
spi_read_8bit_L:
    res 0, e
;;
spi_read_8bit_3:
;;  clock 'L'
    ld  a, c
    res SCLK, a
    out (PO_0), a
;
;;  repeat
    djnz    spi_read_8bit_2
;
spi_read_8bit_end:
    ld  a, e
;
    pop de
    pop bc
;
    ret


spi_write_8bit:
    push    de
    ld  e, a
;
    call    spi_dev_sel
;
    push    af
    push    bc
;
;;  write sequence
    ld  b, 8
spi_write_8bit_2:
;;  write MOSI
    bit 7, e
    jr  z, spi_write_8bit_L
spi_write_8bit_H:
    set MOSI, a
    jr  spi_write_8bit_3
spi_write_8bit_L:
    res MOSI, a
;;  
spi_write_8bit_3:
    out (PO_0), a
;;  clock 'H'
;;  A reg = (PI_0) AND 00000011b OR SPI_SELD_DEV
    set SCLK, a
;
    out (PO_0), a
    nop
;
;;  clock 'L'
    res SCLK, a
    out (PO_0), a
;;  repeat
    sla e
    djnz    spi_write_8bit_2
;
spi_write_8bit_end:
    pop bc
    pop af
    pop de
;
    ret

spi_read_16bit:
spi_write_16bit:

;;
;;; for debug routines
;;
debug_rst08:
    ld  a, 01100000b    ; 1
    out (PO_1), a
    ld  a, 00000100b    ; anode line 0
    out (PO_2), a
    halt
;
    ret

debug_rst10:
    ld  a, 11011010b    ; 2
    out (PO_1), a
    ld  a, 00001000b    ; anode line 1
    out (PO_2), a
    halt
;
    ret

debug_rst18:
    ld  a, 11110010b    ; 3
    out (PO_1), a
    ld  a, 00010000b    ; anode line 2
    out (PO_2), a
    halt
;
    ret

DEBUGSTOP:
    ; *** DEBUG ***
    ld  a, (SEG_STATE)
    out (PO_1), a
    ld  a, 00000100b
    out (PO_2), a
    halt
    ; *** DEBUG ***
    jr  DEBUGSTOP       ; ignore it.

get_PC:
    pop ix              ; IX = PC + 2
    push    ix          ; push back
    dec ix
    dec ix
;
    ret

SEG_TITLE_PROTO2:
    defb    11001110b   ;   P
    defb    00001010b   ;   r
    defb    00111010b   ;   o
    defb    00011110b   ;   t
    defb    00111010b   ;   o
    defb    11011010b   ;   2

SEG_TITLE_LOADER:
    defb    00011100b   ;   L
    defb    01111010b   ;   d
    defb    00001010b   ;   r
    defb    0           ;   blank / null termination
    defb    0           ;   blank / null termination
    defb    0           ;   blank / null termination

SEG_TITLE_CONS:
    defb    10011100b   ;   C
    defb    00111010b   ;   o
    defb    00101010b   ;   n
    defb    00000010b   ;   -
    defb    11111100b   ;   0
    defb    11111100b   ;   0
