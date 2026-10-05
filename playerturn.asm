#include      macros.inc
#include      kernel.inc
#include      bios.inc

; *********************************
; ***** Take a player turn    *****
; ***** Uses: RC.1 - Player Y *****
; *****       RC.0 - Player X *****
; *****       RB.0 - Turns    *****
; *********************************
              proc      playerturn

              extrn     allowed
              extrn     buffer
              extrn     checkstep
              extrn     drawmap
              extrn     explored
              extrn     map
              extrn     offset
              extrn     playerX
              extrn     playerY

              mov       rf,allowed     ; get allowed player turns
              ldn       rf             ; retrieve it
              plo       rb             ; set turns
loop:         glo       rb             ; get steps remaining
              lbz       done           ; jump if player out of steps
              adi       '0'            ; convert to ASCII
              call      o_type         ; display it
              ldi       '>'            ; and then prompt
              call      o_type         ; display it
              mov       rf,buffer      ; point to buffer
              call      o_input        ; get input from player
              call      o_inmsg        ; display crlf
              db        10,13,10,13,0
              mov       rf,playerX     ; get current player coordinates
              lda       rf
              plo       rc
              lda       rf
              phi       rc
              mov       rf,buffer      ; point back to input
              ldn       rf             ; retrieve first byte
              smi       '?'            ; check for question mark
              lbnz      not_qm         ; jump if not
              call      o_inmsg        ; display help
              db        'N       - Go north',10,13
              db        'S       - Go south',10,13
              db        'E       - Go east',10,13
              db        'W       - Go west',10,13
              db        '<space> - Skip to next turn',10,13,0
              lbr       loop           ; then request more input
not_qm:       ldn       rf             ; get input
              smi       ' '            ; check for space
              lbnz      not_sp         ; jump if not
              call      drawmap        ; draw map
              rtn                      ; and return to caller
; *****************
; ***** North *****
; *****************
not_sp:       ldn       rf             ; get input byte
              ori       20h            ; convert UC to LC
              smi       'n'            ; then check north
              lbnz      not_north      ; jump if not north
              ghi       rc             ; get Y
              lbz       wall           ; bumped into border wall
              ghi       rc             ; (y-1)*2+1
              smi       1              ; y-1
              shl                      ; *2
              adi       1              ; +1
              phi       rc             ; set Y
              mov       rf,map         ; point to map
              call      offset         ; offset into map
              ldn       rf             ; get map cell
              smi       ' '            ; check for space
              lbnz      wall_hit       ; jump if hit a wall
              mov       rf,playerY     ; need to subtract 1 from player Y
              ldn       rf
              smi       1
              str       rf
              glo       rb             ; save steps
              stxd
              call      drawmap        ; draw current map
              irx                      ; recover steps
              ldx
              plo       rb
              dec       rb             ; minus 1 step
              call      checkstep      ; check for events
              lbnf      loop           ; loop back for next move
              rtn                      ; return to caller
wall_hit:     mov       rf,explored    ; need to mark wall
              call      offset         ; point to correct cell
              ldi       '#'            ; mark wall
              str       rf
              lbr       wall           ; then bump into wall
; *****************
; ***** South *****
; *****************
not_north:    ldn       rf             ; get input byte
              ori       20h            ; convert UC to LC
              smi       's'            ; then check south
              lbnz      not_south      ; jump if not south
              ghi       rc             ; get Y
              smi       7              ; must be less than 7
              lbdf      wall           ; bumped into border wall
              ghi       rc             ; y*2+1
              shl                      ; *2
              adi       1              ; +1
              phi       rc             ; set Y
              mov       rf,map         ; point to map
              call      offset         ; offset into map
              ldn       rf             ; get map cell
              smi       ' '            ; check for space
              lbnz      wall_hit       ; jump if hit a wall
              mov       rf,playerY     ; need to add 1 from player Y
              ldn       rf
              adi       1
              str       rf
              glo       rb             ; save steps
              stxd
              call      drawmap        ; draw current map
              irx                      ; recover steps
              ldx
              plo       rb
              dec       rb             ; minus 1 step
              call      checkstep      ; check for events
              lbnf      loop           ; loop back for next move
              rtn                      ; return to caller
; *****************
; ***** West  *****
; *****************
not_south:    ldn       rf             ; get input byte
              ori       20h            ; convert UC to LC
              smi       'w'            ; then check west
              lbnz      not_west       ; jump if not west
              glo       rc             ; get X
              lbz       wall           ; bumped into border wall
              ghi       rc             ; y*2
              shl                      ; *2
              phi       rc             ; set Y
              dec       rc             ; x-1
              mov       rf,map         ; point to map
              call      offset         ; offset into map
              ldn       rf             ; get map cell
              smi       ' '            ; check for space
              lbnz      wall_hit       ; jump if hit a wall
              mov       rf,playerX     ; need to subtract 1 from player X
              ldn       rf
              smi       1
              str       rf
              glo       rb             ; save steps
              stxd
              call      drawmap        ; draw current map
              irx                      ; recover steps
              ldx
              plo       rb
              dec       rb             ; minus 1 step
              call      checkstep      ; check for events
              lbnf      loop           ; loop back for next move
              rtn                      ; return to caller
; *****************
; ***** East  *****
; *****************
not_west:     ldn       rf             ; get input byte
              ori       20h            ; convert UC to LC
              smi       'e'            ; then check east
              lbnz      loop           ; jump if not east
              glo       rc             ; get X
              smi       7              ; must be less than 7
              lbdf      wall           ; bumped into border wall
              ghi       rc             ; y*2
              shl                      ; *2
              phi       rc             ; set Y
              mov       rf,map         ; point to map
              call      offset         ; offset into map
              ldn       rf             ; get map cell
              smi       ' '            ; check for space
              lbnz      wall_hit       ; jump if hit a wall
              mov       rf,playerX     ; need to add 1 to player X
              ldn       rf
              adi       1
              str       rf
              glo       rb             ; save steps
              stxd
              call      drawmap        ; draw current map
              irx                      ; recover steps
              ldx
              plo       rb
              dec       rb             ; minus 1 step
              call      checkstep      ; check for events
              lbnf      loop           ; loop back for next move
              rtn                      ; return to caller

wall:         call      o_inmsg        ; display bumped into wall message
              db        10,13,'Bumped into a wall',10,13,10,13,0
              call      drawmap        ; draw the map
done:         rtn                      ; and return to caller

              endp

