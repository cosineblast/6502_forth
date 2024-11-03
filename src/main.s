  ;; This is the main source file for this project, which is going to be a
  ;; FORTH implementation for 6502 systems.
  ;; The target machine is symon [1], which is a decent virtual 6502 system.
.include "locals.h.s"

.segment "CODE"

.import read_byte
.import put_byte
.import setup_io

.import forth_main

start:
  ;; BEGIN SETUP

  ;; The first thing we do is to allow interrupts to get to the CPU
  cli

  ;; Then, we setup the ACIA
  jsr setup_io



  ;; END SETUP

  jsr forth_main
loop:
  jsr read_byte
  jsr put_byte
  jmp loop



string: .byte "hi there", $0D, $0A, 0
