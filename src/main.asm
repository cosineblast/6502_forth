
  ;; This is the main source file for this project, which is going to be a
  ;; FORTH implementation for 6502 systems.

  ;; The target machine is symon [1], which is a decent virtual 6502 system.

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

.org $0300

start:  

  ;; The first thing we do is to allow interrupts to get to the CPU
  cli

  ;; Then, we make a set settings to the ACIA by writing 
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

init:   ldx #$00       ; Initialize index


loop:   
  ;; Status Register read:
  ;; 
  ;; 76543210
  ;; ........
  ;;
  ;; 4: Transmitter Data Register Empty
  ;;    0 = Not Empty
  ;;    1 = Empty

        lda iostatus
        and #$10       ; Is the tx register empty?
        beq loop       ; if not, wait for it to empty

        lda string,x   ; Otherwise, load the string pointer
        beq init       ; If the char is 0, re-init
        sta iobase     ; Otherwise, transmit

        inx            ; Increment string pointer.
        jmp loop       ; Repeat write.

string: .byte "huh", 0
