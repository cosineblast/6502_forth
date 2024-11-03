  ;; I like to have a lot of local variable registers 
  ;; when writing assembly code.


  ;; Most assembly routines follow the convention of not 
  ;; cobbling registers local8 to local15

  ;; LargeABI: You can clobber A,X,Y,local0-local15, but should not 
  ;; clobber local16-local31

  ;; TinyABI: You can clobber A,X,Y,local0-local7, but should not clobber
  ;; local8-local31 

  ;; Any routine is allowed to clobber A and the status flags.
  ;; Routines that are not marked with an ABI identifier should
  ;; document whether they clobber X and Y.



local0 = $00
local1 = $01
local2 = $02
local3 = $03
local4 = $04
local5 = $05
local6 = $06
local7 = $07
local8 = $08
local9 = $09
local10 = $0A
local11 = $0B
local12 = $0C
local13 = $0D
local14 = $0E
local15 = $0F
local16 = $10
local17 = $11
local18 = $12
local19 = $13
local20 = $14
local21 = $15
local22 = $16
local23 = $17
local24 = $18
local25 = $19
local26 = $1A
local27 = $1B
local28 = $1C
local29 = $1D
local30 = $1E
local31 = $1F
