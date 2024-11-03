.include "locals.h.s"
  ;; <--- DICTIONARY ENTRY (HEADER) ----------------------->
  ;; +------------------------+--------+---------- - - - - +----------- - - - -
	;; | LINK POINTER           | LENGTH/| NAME	      | DEFINITION
	;; |			                  | FLAGS  |     	      |
	;; +--- (2 bytes) ----------+- byte -+- n bytes  - - - - +----------- - - - -


  .import read_byte
  .import write_byte

  .export forth_main

  ;; Two-byte value
  esi = $10


  ;; One-byte value, offset into SP_PAGE
  ;; in the future, we might make this two values,
  ;; for multi-page stacks, but that might make things slow.
  stack_offset = $12
  DATA_STACK = $2300



.proc next

    ; tmp = esi
    lda esi+1
    sta local1
    lda esi
    sta local0

    ; esi += 2
    clc
    adc #2
    sta esi
    lda esi+1
    adc #0
    sta esi+1

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


DUP:
  .word DUP_code

DUP_code:
  ldx stack_offset
  lda DATA_STACK, x
  dex
  stx stack_offset
  sta DATA_STACK, x
  jmp next

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
  .word DOUBLE
  .word DOUBLE
  .word RETURN

RETURN:
  .word RETURN_code
RETURN_code:
  rts

forth_main:

  lda #$ff
  sta stack_offset

  lda #8
  sta DATA_STACK+$ff

  lda #<MAIN_words
  sta esi

  lda #>MAIN_words
  sta esi+1

  jmp next









