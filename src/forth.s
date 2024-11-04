  ;;
.include "locals.h.s"


  .import  put_byte
  .import format_byte

  .export forth_main

  ;; Two-byte value
  esi = $20


  ;; One-byte value, offset into SP_PAGE
  ;; in the future, we might make this two values,
  ;; for multi-page stacks, but that might make things slow.
  stack_offset = $22
  DATA_STACK = $2300



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
  .byte $03
  .byte "ADD"
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
  .byte $03
  .byte "SUB"
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
  .word LIT
  .word $0004
  .word LIT
  .word $0002
  .word ADD
  .word DOUBLE
  .word DOUBLE
  .word DUP
  .word DOT
  .word DOT
  .word CR
  .word RETURN

RETURN:
  .word RETURN_code
RETURN_code:
  rts

forth_main:

  lda #$ff
  sta stack_offset

  lda #00
  sta DATA_STACK+$ff

  lda #<MAIN_words
  sta esi

  lda #>MAIN_words
  sta esi+1

  jmp next


  ;; <--- DICTIONARY ENTRY (HEADER) ----------------------->
  ;; +------------------------+--------+---------- - - - - +----------- - - - -
	;; | LINK POINTER           | LENGTH/| NAME	      | DEFINITION
	;; |			                  | FLAGS  |     	      |
	;; +--- (2 bytes) ----------+- byte -+- n bytes  - - - - +----------- - - - -










