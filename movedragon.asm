#include      macros.inc
#include      kernel.inc
#include      bios.inc

; *********************************
; ***** Take the dragons turn *****
; *********************************
              proc      movedragon

              extrn     allowed
              extrn     carrying
              extrn     dawake
              extrn     dmarkerX
              extrn     dragonX
              extrn     drawmap
              extrn     playerX
              extrn     secretX
              extrn     tmarkerX
              extrn     treasureX

              mov       rf,dawake      ; need to see if dragon is awake
              ldn       rf
              lbnz      awake          ; jump if dragon is awake
              rtn                      ; dragon is asleep, so just return
awake:        mov       ra,playerX     ; point to player position
              mov       rb,secretX     ; and secret room location
              lda       ra             ; see if player in secret room
              str       r2
              lda       rb
              sm
              lbnz      notsecret      ; jump if not in secret room
              lda       ra             ; check y coordinates
              str       r2
              lda       rb
              sm
              lbnz      notsecret      ; jump if not in secret room
              mov       ra,dragonX     ; point to dragon coordinates
              mov       rb,treasureX   ; and treasure room
              call      checkpos       ; check position
              mov       ra,dmarkerX    ; point to dragon marker coordinates
              mov       rb,tmarkerX    ; and treasure marker x
              call      checkpos       ; and check position
              lbr       attack         ; then see if dragon attacks
notsecret:    mov       ra,dragonX     ; point to dragon coordinates
              mov       rb,playerX     ; point to player coordinates
              call      checkpos       ; and check position
              mov       ra,dmarkerX    ; point to dragon marker coordinates
              mov       rb,playerX     ; and player coordinates
              call      checkpos       ; and check position
attack:       mov       ra,dragonX     ; point to dragon coordinates
              mov       rb,playerX     ; and player coordinates
              lda       ra             ; compare dragon x to player x
              str       r2
              lda       rb
              sm                       ; compare
              lbnz      noattack       ; jump if not same x
              lda       ra             ; compare dragon y to player y
              str       r2
              lda       rb
              sm                       ; compare
              lbnz      noattack       ; jump if not same y
              call      o_inmsg        ; display attack message
              db        10,13,'Dragon attacks!!!',10,13,10,13,0
              mov       rf,allowed     ; point to steps allowed
              ldn       rf             ; minus 2
              smi       2
              str       rf
              mov       ra,playerX     ; point to player
              mov       rb,secretX     ; and secret room
              lda       rb             ; move player to secret room
              str       ra
              inc       ra
              lda       rb
              str       ra
              mov       ra,dmarkerX    ; point to dragon marker
              mov       rb,dragonX     ; and dragon
              lda       rb             ; move marker to dragon
              str       ra
              inc       ra
              lda       rb
              str       ra
              mov       rf,carrying    ; point to carrying flag
              ldi       0              ; and clear it
              str       rf
noattack:     call      drawmap        ; draw map
              rtn                      ; and return to caller

checkpos:     ldn       rb             ; get second X
              str       r2
              ldn       ra             ; get first X
              sm                       ; and cmpare
              lbz       checky         ; jump if x is equal
              lbdf      xgreater       ; jump if x is greater
              ldn       ra             ; x+1
              adi       1
              str       ra
              lbr       checky         ; then check y
xgreater:     ldn       ra             ; x-1
              smi       1
              str       ra
checky:       inc       ra             ; move to y coordinate
              inc       rb
              ldn       rb             ; get second y
              str       r2
              ldn       ra
              sm                       ; and compare
              lbz       done           ; jump if done
              lbdf      ygreater       ; jump if y is greater
              ldn       ra             ; y+1
              adi       1
              str       ra
done:         rtn                      ; then return
ygreater:     ldn       ra             ; y-1
              smi       1
              str       ra
              rtn                      ; then return


              endp

