#include      macros.inc
#include      kernel.inc
#include      bios.inc

; *****************************************
; ***** Compute offset into array     *****
; *****   RF - Array base             *****
; ***** RC.1 - Y coordinate           *****
; ***** RC.0 - X coordinate           *****
; ***** Returns: RF - pointer to cell *****
; *****************************************
              proc      offset

              glo       rc             ; get x coordinate
              str       r2             ; and set aside
              ghi       rc             ; get y coordinate
              shl                      ; multiply by 2
              shl                      ; by 4
              shl                      ; by 8
              add                      ; add in x coordinate
              str       r2             ; store for adding to base
              glo       rf
              add
              plo       rf
              ghi       rf             ; propagate carry
              adci      0
              phi       rf
              rtn                      ; return to caller

              endp

