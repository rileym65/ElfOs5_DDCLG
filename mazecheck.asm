#include      macros.inc
#include      kernel.inc
#include      bios.inc

; *************************************
; ***** Check maze for valid path *****
; ***** RC.1 - Y coordinate       *****
; ***** RC.0 - X coordinate       *****
; ***** RA.0 - Level              *****
; ***** Returns: DF=1 good        *****
; *****          DF=0 bad         *****
; *************************************
              proc      mazecheck

              extrn     check
              extrn     map
              extrn     offset

              glo       ra             ; get level
              lbz       zero           ; jump if initial level
              mov       rf,check       ; point to check array
              call      offset         ; point to correct cell
              ldn       rf             ; retrieve cell value
              lbz       go
notvalid:     adi       0              ; signal not valid
              rtn                      ; and return
zero:         mov       rf,check       ; point to check array
              ldi       64             ; 64 bytes to zero out
              plo       re
loop:         ldi       0              ; store zero
              str       rf             ; into check array
              inc       rf             ; point to next cell
              dec       re             ; decrement count
              glo       re             ; see if done
              lbnz      loop           ; loop until all cells zeroed
go:           mov       rf,check       ; point to check array
              call      offset         ; point to correct cell
              ldi       1              ; set cell to 1
              str       rf

              ghi       rc             ; get y coordinate
              lbz       notnorth       ; do not check north
              push      rc             ; save coordinates
              ghi       rc             ; compute (y-1)*2+1
              smi       1              ; y-1
              shl                      ; *2
              adi       1              ; +1
              phi       rc             ; put back into y
              mov       rf,map         ; point to map array
              call      offset         ; point to correct cell
              pop       rc             ; recover coordinates
              ldn       rf             ; get map cell
              smi       ' '            ; is it a space
              lbnz      notnorth       ; do not check if not
              push      rc             ; save coordinates
              glo       ra             ; save level
              stxd
              ghi       rc             ; decrement y
              smi       1
              phi       rc
              inc       ra             ; increment level
              call      mazecheck      ; and check connected cell
              irx                      ; recover level
              ldx
              plo       ra
              pop       rc             ; recover coordinates

notnorth:     ghi       rc             ; get y coordinate
              smi       7              ; must be less than 7
              lbdf      notsouth       ; jump if not
              push      rc             ; save coordinates
              ghi       rc             ; compute y*2+1
              shl                      ; y*2
              adi       1              ; +1
              phi       rc             ; put it back
              mov       rf,map         ; point to map array
              call      offset         ; point to correct cell
              pop       rc             ; recover coordinates
              ldn       rf             ; get map cell
              smi       ' '            ; is it a space
              lbnz      notsouth       ; do not check if not
              push      rc             ; save coordinates
              glo       ra             ; save level
              stxd
              ghi       rc             ; increment y
              adi       1
              phi       rc
              inc       ra             ; increment level
              call      mazecheck      ; and check connected cell
              irx                      ; recover level
              ldx
              plo       ra
              pop       rc             ; recover coordinates

notsouth:     glo       rc             ; get x coordinate
              lbz       notwest        ; do not check north
              push      rc             ; save coordinates
              glo       rc             ; compute x-1
              smi       1              ; y-1
              plo       rc             ; put back into y
              ghi       rc             ; y*2
              shl
              phi       rc
              mov       rf,map         ; point to map array
              call      offset         ; point to correct cell
              pop       rc             ; recover coordinates
              ldn       rf             ; get map cell
              smi       ' '            ; is it a space
              lbnz      notwest        ; do not check if not
              push      rc             ; save coordinates
              glo       ra             ; save level
              stxd
              glo       rc             ; decrement x
              smi       1
              plo       rc
              inc       ra             ; increment level
              call      mazecheck      ; and check connected cell
              irx                      ; recover level
              ldx
              plo       ra
              pop       rc             ; recover coordinates

notwest:      glo       rc             ; get x coordinate
              smi       7              ; must be less than 7
              lbdf      noteast        ; jump if not
              push      rc             ; save coordinates
              ghi       rc             ; y*2
              shl
              phi       rc
              mov       rf,map         ; point to map array
              call      offset         ; point to correct cell
              pop       rc             ; recover coordinates
              ldn       rf             ; get map cell
              smi       ' '            ; is it a space
              lbnz      noteast        ; do not check if not
              push      rc             ; save coordinates
              glo       ra             ; save level
              stxd
              glo       rc             ; increment x
              adi       1
              plo       rc
              inc       ra             ; increment level
              call      mazecheck      ; and check connected cell
              irx                      ; recover level
              ldx
              plo       ra
              pop       rc             ; recover coordinates

noteast:      glo       ra             ; get level
              lbnz      notvalid       ; return if not level 0
              mov       rf,check       ; point to check array
              ldi       64             ; 64 bytes to check
              plo       re
checklp:      lda       rf             ; get next byte from check array
              lbz       notvalid       ; not valid if zero
              dec       re             ; decrement count
              glo       re             ; see if done
              lbnz      checklp        ; loop until all cells checked
              smi       0              ; signal valid cell
              rtn                      ; and return

              endp

