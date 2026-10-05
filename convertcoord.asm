#include      macros.inc
#include      kernel.inc
#include      bios.inc

; *******************************************
; ***** Convert ASCII coordinate to X,Y *****
; ***** RF - Pointer to ascii           *****
; ***** Returns: RC.1 - Y coordinate    *****
; *****          RC.0 - X coordinate    *****
; *****          DF=0 - Successful      *****
; *****          DF=1 - Failed          *****
; *******************************************
              proc      convertcoord

              ldn       rf             ; get first character
              smi       'a'            ; check for lowercase
              lbnf      not_lc         ; jump if not lowercase
              ldn       rf             ; recover first character
              smi       'i'            ; check for a-h
              lbdf      not_lc         ; jump if not
              lda       rf             ; recover character
              smi       'a'            ; convert to 0-7
              phi       rc             ; set y of result
              lbr       now_x          ; now convert X
not_lc:       ldn       rf             ; get first character
              smi       'A'            ; check for uppercase
              lbnf      error          ; jump if not
              ldn       rf             ; get first character
              smi       'I'            ; check for A-H
              lbdf      error          ; jump if not
              lda       rf             ; recover character
              smi       'A'            ; convert to 0-7
              phi       rc             ; set y of result
now_x:        ldn       rf             ; get second byte
              smi       '1'            ; check for less than numbers
              lbnf      error          ; jump if not a number
              ldn       rf             ; recover second byte
              smi       '9'            ; check for 1-8
              lbdf      error          ; jump if not
              ldn       rf             ; recover second byte
              smi       '1'            ; conver to binary 0-7
              plo       rc             ; put into X of result
              adi       0              ; signal no error
              rtn                      ; and return
error:        smi       0              ; signal an error
              rtn                      ; and return

              endp

