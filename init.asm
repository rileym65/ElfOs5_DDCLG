#include      macros.inc
#include      kernel.inc
#include      bios.inc

; ***************************
; ***** Initialize game *****
; ***************************
              proc      init

              extrn     buildmaze
              extrn     explored
              extrn     map

              ldi       128            ; 128 cells to clear
              plo       rc
              mov       ra,map         ; pointer to map
              mov       rb,explored    ; pointer to explored
loop:         ldi       ' '            ; want a space
              str       ra             ; into map
              str       rb             ; and explored
              inc       ra             ; increment pointers
              inc       rb
              dec       rc             ; decrement count
              glo       rc             ; see if done
              lbnz      loop           ; loop until all cells cleared
              call      buildmaze      ; then build the maze
              rtn                      ; return to caller

              endp

