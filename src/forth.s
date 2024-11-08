  ;;
.include "locals.h.s"


  .import put_byte
  .import read_byte
  .import format_byte
  .import string__compare

  .export forth_main

  ;; Two-byte value
  esi = $20


  ;; One-byte value, offset into SP_PAGE
  ;; in the future, we might make this two values,
  ;; for multi-page stacks, but that might make things slow.
  stack_offset = $22
  DATA_STACK = $2300

  word_buffer = $24
  ;; 32-byte value
  ;; the buffer where we store words and stuff

  ;; two byte value
  latest = $44



.proc inc_esi_two
  lda esi
  clc
  adc #2
  sta esi
  lda esi+1
  adc #0
  sta esi+1
  rts
.endproc

.proc next

    ; tmp = esi
    lda esi+1
    sta local1
    lda esi
    sta local0

    jsr inc_esi_two

    ; tmp2 = *tmp
    ldy #0
    lda (local0),y
    sta local2
    iny
    lda (local0),y
    sta local3

    ; tmp3 = *tmp2
    ldy #0
    lda (local2),y
    sta local0
    iny
    lda (local2),y
    sta local1

    ; jmp *tmp3
    jmp (local0)

.endproc

  ;; DUP ( n -- n n )
DUP_header:
  .word $0000
  .byte $03
  .byte "DUP"
DUP:
  .word DUP_code
DUP_code:
  ldx stack_offset
  lda DATA_STACK, x
  dex
  stx stack_offset
  sta DATA_STACK, x
  jmp next

  ;; DROP ( n -- )
DROP_header:
  .word DUP_header
  .byte $04
  .byte "DROP"
  .byte $00
DROP:
  .word DROP_code
DROP_code:
  inc stack_offset
  jmp next

  ;; SWAP ( a b -- b a )
SWAP_header:
  .word DROP_header
  .byte $04
  .byte "SWAP"
  .byte $00
SWAP:
  .word SWAP_code
SWAP_code:

  ; tmp0 = stack[offset]
  ldx stack_offset
  lda DATA_STACK, x
  sta local0

  ; tmp1 = stack[offset+1]
  inx
  lda DATA_STACK, x
  sta local1

  ; stack[offset+1] = tmp0
  lda local0
  sta DATA_STACK, x

  ; stack[offset] = tmp1
  dex
  lda local1
  sta DATA_STACK, x

  jmp next

  ;; OVER ( a b -- a b a )
OVER_header:
  .word SWAP_header
  .byte $04
  .byte "OVER"
  .byte $00
OVER:
  .word OVER_code
OVER_code:
  ldx stack_offset
  inx
  lda DATA_STACK, x
  dex
  dex
  sta DATA_STACK, x
  stx stack_offset
  jmp next

  ;; ROT ( a b c -- c a b )
ROT_header:
  .word OVER_header
  .byte $03
  .byte "ROT"
ROT:
  .word ROT_code
ROT_code:

  ;; tmp0 = stack[offset]
  ldx stack_offset
  lda DATA_STACK, x
  sta local0

  ;; tmp1 = stack[offset+1]
  inx
  lda DATA_STACK, x
  sta local1

  ;; tmp2 = stack[offset+2]
  inx
  lda DATA_STACK, x
  sta local2

  ;; stack[offset+2] = tmp0
  lda local0
  sta DATA_STACK, x

  ;; stack[offset+1] = tmp2
  dex
  lda local2
  sta DATA_STACK, x

  ;; stack[offset] = tmp1
  dex
  lda local1
  sta DATA_STACK, x

  jmp next

  ;; NROT ( a b c -- b c a )
NROT_header:
  .word ROT_header
  .byte $04
  .byte "NROT"
  .byte $00
NROT:
  .word NROT_code
NROT_code:
  ;; tmp0 = stack[offset]
  ldx stack_offset
  lda DATA_STACK, x
  sta local0

  ;; tmp1 = stack[offset+1]
  inx
  lda DATA_STACK, x
  sta local1

  ;; tmp2 = stack[offset+2]
  inx
  lda DATA_STACK, x
  sta local2

  ;; stack[offset+2] = tmp1
  lda local1
  sta DATA_STACK, x

  ;; stack[offset+1] = tmp0
  dex
  lda local0
  sta DATA_STACK, x

  ;; stack[offset] = tmp2
  dex
  lda local2
  sta DATA_STACK, x
  jmp next

  ;; 2DROP ( a b -- )
TWODROP_header:
  .word NROT_header
  .byte $05
  .byte "2DROP"
TWODROP:
  .word TWODROP_code
TWODROP_code:
  inc stack_offset
  inc stack_offset
  jmp next

  ;; 2DUP ( a b -- a b a b )
TWODUP_header:
  .word TWODROP_header
  .byte $04
  .byte "2DUP"
  .byte $00
TWODUP:
  .word TWODUP_code
TWODUP_code:
  ldx stack_offset
  lda DATA_STACK, x
  sta local0

  inx
  lda DATA_STACK, x

  dex
  dex
  sta DATA_STACK, x
  dex
  lda local0
  sta DATA_STACK, x
  stx stack_offset
  jmp next

TWOSWAP_header:
  .word TWODUP_header
  .byte $05
  .byte "2SWAP"
TWOSWAP:
  .word TWOSWAP_code
TWOSWAP_code:
  ;; TODO
  jmp next

QDUP_header:
  .word TWOSWAP_header
  .byte $03
  .byte "?DUP"
QDUP:
  .word QDUP_code
QDUP_code:
  ;; TODO
  jmp next

ONEPLUS_header:
  .word QDUP_header
  .byte $02
  .byte "1+"
  .byte $00
ONEPLUS:
  .word ONEPLUS_code
ONEPLUS_code:
  ;; TODO
  jmp next

ONEMINUS_header:
  .word ONEPLUS_header
  .byte $02
  .byte "1-"
  .byte $00
ONEMINUS:
  .word ONEMINUS_code
ONEMINUS_code:
  ;; TODO
  jmp next

TWOPLUS_header:
  .word ONEMINUS_header
  .byte $02
  .byte "2+"
  .byte $00
TWOPLUS:
  .word TWOPLUS_code
TWOPLUS_code:
  ;; TODO
  jmp next

TWOMINUS_header:
  .word TWOPLUS_header
  .byte $02
  .byte "2-"
  .byte $00
TWOMINUS:
  .word TWOMINUS_code
TWOMINUS_code:
  ;; TODO
  jmp next

ADD_header:
  .word TWOMINUS_header
  .byte $01
  .byte "+"
ADD:
  .word ADD_code
ADD_code:
  ldx stack_offset
  lda DATA_STACK, x
  sta local0

  inx
  stx stack_offset
  lda DATA_STACK, x
  clc
  adc local0
  sta DATA_STACK, x
  jmp next

SUB_header:
  .word ADD_header
  .byte $01
  .byte "-"
SUB:
  .word SUB_code
SUB_code:
  ;; TODO
  jmp next

EQ_header:
  .word SUB_header
  .byte $01
  .byte "="
EQ:
  .word EQ_code
EQ_code:
  ;; TODO
  jmp next

NEQ_header:
  .word EQ_header
  .byte $02
  .byte "<>"
  .byte $00
NEQ:
  .word NEQ_code
NEQ_code:
  ;; TODO
  jmp next

LT_header:
  .word NEQ_header
  .byte $01
  .byte "<"
LT:
  .word LT_code
LT_code:
  ;; TODO
  jmp next

GT_header:
  .word LT_header
  .byte $01
  .byte ">"
GT:
  .word GT_code
GT_code:
  ;; TODO
  jmp next

ZEROEQ_header:
  .word GT_header
  .byte $02
  .byte "0="
  .byte $00
ZEROEQ:
  .word ZEROEQ_code
ZEROEQ_code:
  ;; TODO
  jmp next

LIT_header:
  .word ZEROEQ_header
  .byte $03
  .byte "LIT"
LIT:
  .word LIT_code
LIT_code:
  ldy #0
  lda (esi), y

  ldx stack_offset
  dex
  sta DATA_STACK, x
  stx stack_offset

  jsr inc_esi_two

  jmp next


  ;; STORE ( data address -- )
STORE_header:
  .word LIT_header
  .byte $01
  .byte "!"
STORE:
  .word STORE_code

STORE_code:

  ; tmp = stack[offset] merged with stack_offset[offset+1]
  ldx stack_offset
  lda DATA_STACK, x
  sta local0
  inx
  lda DATA_STACK, x
  sta local1

  inx
  lda DATA_STACK, x

  ; *tmp = stack_offset[offset+2]
  ldy #0
  sta (local0), y

  ;; offset += 3
  inx
  stx stack_offset
  jmp next


  ;; FETCH ( address -- value )
FETCH_header:
  .word STORE_header
  .byte $01
  .byte "@"
FETCH:
  .word FETCH_code
FETCH_code:
  ; tmp = stack[offset] merged with stack_offset[offset+1]
  ldx stack_offset
  lda DATA_STACK, x
  sta local0
  inx
  lda DATA_STACK, x
  sta local1

  ; stack_offset[offset+2] = tmp
  ldy #0
  lda (local0), y
  inx
  sta DATA_STACK, x

  ;; offset += 2
  stx stack_offset
  jmp next

DOT_header:
  .word FETCH_header
  .byte $01
  .byte "."
DOT:
  .word DOT_code
DOT_code:
  ldx stack_offset
  lda DATA_STACK, x
  inx
  stx stack_offset
  jsr format_byte

  lda #$20
  jsr put_byte

  jmp next

CR_header:
  .word DOT_header
  .byte $02
  .byte "CR"
  .byte $00
CR:
  .word CR_code
CR_code:
  lda #$0A
  jsr put_byte

  lda #$0D
  jsr put_byte
  jmp next

KEY_header:
  .word CR_header
  .byte $03
  .byte "KEY"
KEY:
  .word KEY_code
KEY_code:
  jsr read_byte

  ldx stack_offset
  dex
  stx stack_offset

  sta DATA_STACK, x

  jmp next

EMIT_header:
  .word KEY_header
  .byte $04
  .byte "EMIT"
  .byte $00
EMIT:
  .word EMIT_code
EMIT_code:
  ldx stack_offset
  lda DATA_STACK, x
  inx
  stx stack_offset

  jsr put_byte
  jmp next

WORD_header:
  .word EMIT_header
  .byte $04
  .byte "WORD"
  .byte $00
WORD:
  .word WORD_code

WORD_code:
  jsr read_word

  sta local0

  ldx stack_offset
  lda #>word_buffer
  sta DATA_STACK, x

  dex
  lda #<word_buffer
  sta DATA_STACK, x

  dex
  lda local0
  sta DATA_STACK, x

  stx stack_offset

  jmp next

  ;; reads characters from stdin into word_buffer
  ;; no bounds checking is performed.
  ;; the size of the string is kept in A
  ;; clobbers X
.proc read_word
  ;; 1. read stuff until not whitespace
ws_loop:
  jsr read_byte

  cmp #$0A ; '\n'
  beq ws_loop
  cmp #$20 ; ' '
  beq ws_loop
  cmp #$0D ; '\r'
  beq ws_loop
  cmp #$09 ; '\t'
  beq ws_loop

  ;; 2. copy characters until whitespace
  ldx #$00
char_loop:
  sta word_buffer, x
  jsr read_byte

  cmp #$0A ; '\n'
  beq end_char_loop
  cmp #$20 ; ' '
  beq end_char_loop
  cmp #$0D ; '\r'
  beq end_char_loop
  cmp #$09 ; '\t'
  beq end_char_loop

  inx
  jmp char_loop

end_char_loop:
  inx
  txa
  rts
.endproc

NUMBER_header:
  .word WORD_header
  .byte $06
  .byte "NUMBER"
  .byte $00
NUMBER:
  .word NUMBER_code
NUMBER_code:

  ldx stack_offset
  lda DATA_STACK, x

  sta local2

  inx
  lda DATA_STACK, x
  sta local0

  inx
  lda DATA_STACK, x
  sta local1

  jsr parse_number

  ldx stack_offset
  inx
  inx

  sta DATA_STACK, x
  dex

  lda local0
  sta DATA_STACK, x

  stx stack_offset

  jmp next

  ;; local0, local1: pointer to a string
  ;; local2: size of such string
  ;; saves the result number in A
  ;; saves the number of unprocessed characters in local0
  ;; todo: document this and WORD and stuff
.proc parse_number

  ;; if the string is empty then succeed with zero
  lda local2
  beq empty

  ; answer = 0
  lda #0
  sta local3

  ldy #00

loop:
  ; digit = str[i]
  lda (local0), y

  ; while (digit >= '0' && digit <= '9') {
  cmp #'0'
  bcc the_end

  cmp #'9' + 1
  bcs the_end

  ; digit_value = digit - '0'
  sec
  sbc #'0'
  pha

  ; answer = answer * 10
  jsr mul_local3_10

  ; answer += diigit_value
  pla
  clc
  adc local3
  sta local3

  ; i++
  iny
  jmp loop
the_end:

  ; not_handled = str.size - i
  tya
  sta local4
  lda local2
  sec
  sbc local4

  sta local0
  lda local3
  rts

empty:
  lda #00
  sta local0
  rts

.endproc

.proc mul_local3_10

  ; result = 0
  lda #0

  ; n = 10
  ldx #10

loop:
  ; while (n != 0) {
  beq end

  ; result += local3
  clc
  adc local3

  ; n -= 1
  dex

  ; }
  bne loop
end:

  sta local3
  rts
.endproc


FIND_header:
  .word NUMBER_header
  .byte $04
  .byte "FIND"
  .byte $00
FIND:
  .word FIND_code
FIND_code:

  ldx stack_offset
  lda DATA_STACK, x

  sta local2 

  inx 
  lda DATA_STACK, x
  sta local0

  inx

  lda DATA_STACK, x
  sta local1 

  ; result = find_header_entry(str)
  jsr find_header_entry


  ldx stack_offset
  inx 

  lda local0
  sta DATA_STACK, x

  inx
  lda local1
  sta DATA_STACK, x

  dex
  stx stack_offset

  jmp next

  ;; Looks up a string in the dictionary
  ;; local0, local1: pointer to str 
  ;; local2: size of str
  ;; returns a nullable pointer to the entry in local0,local1
  ;; SmallABI
.proc find_header_entry


  ; ptr = latest
  lda latest
  sta local3 
  lda latest+1
  sta local4

loop: ; while (true) {

  lda local3  ; if (ptr == 0) {
  bne :+
  lda local4 
  bne :+

  lda #0 
  sta local0
  sta local1
  rts ; return NULL

  : ; }

  ; size = ptr[2]
  ldy #2
  lda (local3), y
  sta local5

  ; ptr += 3
  inc local3
  inc local3
  inc local3

  ; same = string__compare(str, ptr)
  jsr string__compare

  pha 

  ; ptr -= 3
  dec local3
  dec local3
  dec local3

  pla
  ; if (same) {
  bne :+

  lda local3 ; *result = ptr
  sta local0
  lda local4
  sta local1

  lda #1 
  rts
  : ; }

  ; ptr = * (u8*) ptr
  ldy #0
  lda (local3), y
  pha 
  iny
  lda (local3), y
  sta local4
  pla 
  sta local3


  jmp loop ; }

  brk
.endproc



  ;; end of core forth words

DOUBLE:
  .word docol
  .word DUP
  .word ADD
  .word EXIT

EXIT:
  .word EXIT_code
EXIT_code:
  ; esi = *return_stack
  ; return_stack += 2
  pla
  sta esi+1
  pla
  sta esi
  jmp next

docol:
  ; push esi
  lda esi
  pha
  lda esi+1
  pha

  ; entry = *(esi-2)
  ; // (implicit from next)

  ; esi = entry + 2
  lda local2
  clc
  adc #2
  sta esi
  lda local3
  adc #0
  sta esi+1

  ; NEXT
  jmp next

MAIN_words:
  .word WORD
  .word FIND
  .word DOT
  .word DOT
  .word RETURN

RETURN:
  .word RETURN_code
RETURN_code:
  rts

  LAST_BUILTIN = FIND_header

forth_main:

  lda #$ff
  sta stack_offset

  lda #00
  sta DATA_STACK+$ff

  lda #<MAIN_words
  sta esi

  lda #>MAIN_words
  sta esi+1

  lda #<LAST_BUILTIN
  sta latest

  lda #>LAST_BUILTIN
  sta latest+1

  jmp next


  ;; <--- DICTIONARY ENTRY (HEADER) ----------------------->
  ;; +------------------------+--------+---------- - - - - +----------- - - - -
	;; | LINK POINTER           | LENGTH/| NAME	      | DEFINITION
	;; |			                  | FLAGS  |     	      |
	;; +--- (2 bytes) ----------+- byte -+- n bytes  - - - - +----------- - - - -










