  ;; This is the main source file for this project, which is going to be a
  ;; FORTH implementation for 6502 systems.
  ;; The target machine is symon [1], which is a decent virtual 6502 system.
.include "locals.h.s"

.segment "CODE"

.import read_byte
.import put_byte
.import put_str
.import setup_io
.import format_byte
.import string__compare

.import forth_main

start:
  ;; BEGIN SETUP

  ;; The first thing we do is to allow interrupts to get to the CPU
  cli

  ;; Then, we setup the ACIA
  jsr setup_io

  ;; END SETUP

  jsr forth_main

  lda #<done_string
  sta local0

  lda #>done_string
  sta local1

  lda #6
  sta local2

  jsr put_str
  
loop:
  jmp loop

done_string: .byte $0D, $0A, "done"
