  ;;
.segment "CODE"


  ;; The input/output system implemented by symon simulates the behavior of the
  ;; MOS Technology 6551 Asynchronous Communications Interface Adapter [2],
  ;; (aka ACIA) which is a known IO device for 6502 systems.

  ;; [1] https://github.com/sethm/symon
  ;; [2] https://en.wikipedia.org/wiki/MOS_Technology_6551

  ;; The 6551 has 3 main registers, known as the status register,
  ;; the command register, and the control register.
  ;; Using those and the data bus, it is possible to get most input/output things done.

  ;; In symon, these special memory locations are mapped to
  ;; the following memory addresses. Writing to those will affect the 6551.
iobase   = $8800
iostatus = $8801
iocmd    = $8802
ioctrl   = $8803


.include "locals.h.s"

.export setup_io
.export put_byte
.export put_str
.export read_byte
.export format_byte

.proc setup_io
  ;; We make a few settings to the ACIA by writing
  ;; to the command and control registers.

  ;; Command Register write:
  ;;
  ;; 76543210
  ;; 00001011
  ;;
  ;; 765 : Parity Disabled
  ;; 4   : Normal mode for receiver
  ;; 32  : Transmit interrupt disabled, RTS level low
  ;; 1   : IRQ interrupt disabled
  ;; 0   : Disabled Receiver/Transmitter


  lda #$0B
  sta iocmd

  ;; Control Register write:
  ;;
  ;; 76543210
  ;; 00011010
  ;;
  ;; 7: Stop bits is 1
  ;; 65: Data word length is 8
  ;; 4: Receiver clock source is baud rate generator
  ;; 3210: Baid rate generator is at 2400

  ;; Technically, to symon, some of these settings changes are actually unecessary:
  ;; > The parity, stop-bits and bits-per-character settings are ignored.
  ;; > The ACIA always sends and receives 8-bit characters, and parity errors
  ;; > do not occur.

  ;; but we do it anyway.

  lda #$1a
  sta ioctrl

  rts


.endproc

  ;; Writes the byte in the accumulator to the ACIA.
  ;; Clobbers: A
.proc put_byte
  pha
again:

  ;; Status Register read:
  ;;
  ;; 76543210
  ;; ........
  ;;
  ;; 4: Transmitter Data Register Empty
  ;;    0 = Not Empty
  ;;    1 = Empty
  lda iostatus
  and #$10       ; Is the transmit register empty?
  beq again      ; If not, wait for it to empty
  pla
  sta iobase
  rts
.endproc

  ;; Reads a byte from the ACIA into the accumulator.
  ;; Clobbers: A
.proc read_byte


  ;; Status Register read:
  ;;
  ;; 76543210
  ;; ........
  ;;
  ;; 3: Receiver Data Register Full
  ;;    0 = Not Full
  ;;    1 = Full

again:
  lda iostatus
  and #$08
  beq again
  lda iobase
  rts

.endproc

  ;; Saves the byte value in the accumlator as a base 10 string 
  ;; in local7, local8, local9, local10
  ;; Tiny ABI.
.proc byte_to_str

.endproc

  ;; Computes A/10 and A%10, saves the remainder in A and the 
  ;; quotient in local1.
  ;; Tiny ABI.
.proc div10

  ; quot = 0;
  ldx #0
  stx local0

  ; rem = A;
loop:

  ; while (rem >= 10) {
  cmp #10
  bcc loop_end

  ; rem -= 10;
  ; // carry flag is necessarily set here
  sbc #10

  ; quot += 1
  inc local0

  jmp loop
loop_end:
  rts

.endproc

  ;; local0, local1: address
  ;; local2: size
  ;; works with at most 255-sized strings
.proc put_str

  ; i = 0
  ldy #0
  ; j = size

  lda local2
  tax

loop:

  ; while (j != 0) {
  txa 
  beq end_loop

  ; put_byte(ptr[i])
  lda (local0), y
  jsr put_byte

  ; i++
  iny 
  ; j--
  dex
  jmp loop

end_loop:
  rts

.endproc

.proc format_byte
    
  jsr div10
  clc 
  adc #$30
  sta local7

  lda local0
  jsr div10
  clc 
  adc #$30
  sta local6

  lda local0
  clc
  adc #$30
  sta local5

  lda #<local5 
  sta local0 
  
  lda #>local5
  sta local1 

  lda #3
  sta local2 

  jmp put_str

.endproc



