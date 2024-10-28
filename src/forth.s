
.include "locals.h.s"

    ;; <--- DICTIONARY ENTRY (HEADER) ----------------------->
  ;; +------------------------+--------+---------- - - - - +----------- - - - -
	;; | LINK POINTER           | LENGTH/| NAME	      | DEFINITION
	;; |			                  | FLAGS  |     	      |
	;; +--- (2 bytes) ----------+- byte -+- n bytes  - - - - +----------- - - - -


  ;; Two values
  esi = $16

  ;; One value, offset into SP_PAGE
  ;; in the future, we might make this two values,
  ;; for multi-page stacks, but that might make things slow.
  sp = $18
  DATA_STACK_PAGE = $02

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

    ; jmp *tmp2
    jmp (local2)
    rts

.endproc


DUP:
  .word DUP_code

DUP_code:
  ldx sp
  lda DATA_STACK_PAGE, x
  dex
  dec sp
  sta DATA_STACK_PAGE, x
  jsr next







