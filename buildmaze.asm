#include      macros.inc
#include      kernel.inc
#include      bios.inc

; *************************************
; ***** Build maze                *****
; ***** Uses: RC.0 - X-coordinate *****
; *****       RC.1 - Y-coordinate *****
; *****       RA.0 - Wall counter *****
; *************************************
              proc      buildmaze

              extrn     map
              extrn     mazecheck
              extrn     offset
              extrn     rnd

              call      rnd            ; get random number
              ani       7              ; want 0-7
              str       r2             ; store for subtraction
              ldi       50             ; walls are 50 - random
              sm
              plo       ra             ; ra will track wals
loop:         call      rnd            ; get random x
              ani       7              ; 0-7
              plo       rc             ; set x coordinate
              call      rnd            ; get random for y
              ani       0fh            ; 0-15
              phi       rc             ; set y coordinate
              smi       15             ; check less than 15
              lbdf      good           ; jump if not less than 15
              mov       rf,map         ; need offset into map array
              call      offset         ; get offset for coordinates
              ldn       rf             ; retrieve map byte
              smi       ' '            ; check for space
              lbnz      loop           ; if not a space, need a new cell
good:         mov       rf,map         ; need offset into map array
              call      offset         ; get offset for coordinates
              ldi       '#'            ; set to wall
              str       rf
              push      rc             ; save coordinates
              push      ra             ; save counter
              ldi       0              ; set to level 0
              plo       ra
              phi       rc             ; start at 0,0
              plo       rc
              call      mazecheck      ; check the maze
              pop       ra             ; recover counter
              pop       rc             ; recover coordinates
              lbdf      valid          ; jump if valid wall
              mov       rf,map         ; need offset into map array
              call      offset         ; get offset for coordinates
              ldi       ' '            ; reset to a space
              str       rf
              lbr       loop           ; then attempt to place another wall
valid:        dec       ra             ; decrement wall counter
              glo       ra             ; see if done placing walls
              lbnz      loop           ; loop back if more to place
              rtn                      ; otherwise return to caller

              endp

