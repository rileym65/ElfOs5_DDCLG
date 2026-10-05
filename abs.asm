#include      macros.inc
#include      kernel.inc
#include      bios.inc

; ******************************
; ***** Absolte value of D *****
; ******************************
              proc      abs

              shl                      ; shift high bit into DF
              lbnf      positive       ; jump if number was positive
              shrc                     ; restore number
              xri       0ffh           ; flip all the bits
              adi       1              ; and add 1
              rtn                      ; then return to caller
positive:     shrc                     ; restore number
              rtn                      ; and return to caller

              endp

