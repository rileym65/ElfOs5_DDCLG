#include      macros.inc
#include      kernel.inc
#include      bios.inc

; ******************************************
; ***** Check step events              *****
; ***** Returns: DF=1 - end of turn    *****
; *****          DF=0 - turn continues *****
; ******************************************
              proc      checkstep

              extrn     abs
              extrn     allowed
              extrn     buffer
              extrn     carrying
              extrn     convertcoord
              extrn     dawake
              extrn     dmarkerX
              extrn     dragonX
              extrn     drawmap
              extrn     playerX
              extrn     secretX
              extrn     tfound
              extrn     tmarkerX
              extrn     treasureX

              mov       rf,dawake      ; check if dragon is sleeping
              ldn       rf
              lbnz      awake          ; jump if the dragon is awake
              mov       r7,playerX     ; point to player coordinates
              mov       r8,treasureX   ; and treasure room
              lda       r8             ; need playerX-treasureX
              str       r2
              lda       r7
              sm
              call      abs            ; get absolute value
              smi       3              ; see if 3 or greater
              lbdf      awake          ; jump if so
              lda       r8             ; need playerY-treasureY
              str       r2
              lda       r7
              sm
              call      abs            ; get absolute value
              smi       3              ; see if 3 or greater
              lbdf      awake          ; jump if so
              call      o_inmsg        ; display dragon awakes
              db        'Dragon awakes!!!',10,13,0
              mov       rf,dawake      ; point to dragon awake flag
              ldi       0ffh           ; and set it
              str       rf
loop:         call      o_inmsg        ; display prompt
              db        'Select room you believe dragon is in: ',0
              mov       rf,buffer      ; point to buffer
              call      o_input        ; and get input
              call      o_inmsg
              db        10,13,0
              mov       rf,buffer
              call      convertcoord   ; convert coordinates
              lbdf      loop           ; jump if invalid coordinates
              mov       rf,dmarkerX    ; point to dragon marker
              glo       rc             ; and set its coordinates
              str       rf
              inc       rf
              ghi       rc
              str       rf
              mov       rf,tmarkerX    ; point to treasure marker
              glo       rc             ; and set its coordinates
              str       rf
              inc       rf
              ghi       rc
              str       rf
              call      drawmap        ; redraw the map
awake:        mov       r7,playerX     ; point to player coordinates
              mov       r8,dragonX     ; point to dragon coordinates
              lda       r7             ; check if playerX = dragonX
              str       r2
              lda       r8
              sm
              lbnz      noattack       ; jump if not the same
              lda       r7             ; check if playerY = dragonY
              str       r2
              lda       r8
              sm
              lbnz      noattack       ; jump if not in dragon's room
              call      o_inmsg        ; display dragon attacks
              db        10,13,'Dragon attacks!!!',10,13,10,13,0
              mov       rf,allowed     ; steps allowed -= 2
              ldn       rf
              smi       2
              str       rf
              mov       r7,dragonX     ; point to dragon coordinates
              mov       r8,dmarkerX    ; point to dragon marker
              lda       r7             ; set marker equal to draon
              str       r8
              inc       r8
              lda       r7
              str       r8
              mov       rf,carrying    ; mark treasure not carried
              ldi       0
              str       rf
              mov       r7,playerX     ; point to player coordinates
              mov       r8,treasureX   ; and treasure room coordinates
              lda       r7             ; see if found treasure room
              str       r2
              lda       r8
              sm
              lbnz      notreasure     ; jump if not
              lda       r7
              str       r2
              lda       r8
              sm
              lbnz      notreasure     ; jump if not
              call      o_inmsg        ; display treasure found
              db        'Treasure found!!!',10,13,0
              mov       rf,tfound      ; mark treasure found
              ldi       0ffh
              str       rf
              mov       r7,playerX     ; point to player coordinates
              mov       r8,tmarkerX    ; and treasure marker
              lda       r7             ; set treasure maker to player coordinates
              str       r8
              inc       r8
              lda       r7
              str       r8
notreasure:   mov       r7,secretX     ; point to secret room coordinates
              mov       r8,playerX     ; and player
              lda       r7             ; move player to secret room
              str       r8
              inc       r8
              lda       r7
              str       r8
              call      drawmap        ; draw the map
              smi       0              ; set DF to end trun
              rtn                      ; and return to caller
noattack:     mov       rf,carrying    ; need to see if carrying treasure
              ldn       rf
              lbnz      checkend       ; jump if carrying treasure
              mov       r7,playerX     ; point to player coordinates
              mov       r8,treasureX   ; and treasure room
              lda       r7             ; see if in treasure room
              str       r2
              lda       r8
              sm
              lbnz      checkend       ; jump if not in treasure room
              lda       r7             ; see if in treasure room
              str       r2
              lda       r8
              sm
              lbnz      checkend       ; jump if not in treasure room
              call      o_inmsg        ; show found treasure
              db        'Treasure found!!!',10,13,0
              mov       rf,tfound      ; flag treasure found
              ldi       0ffh
              str       rf
              mov       rf,carrying    ; now carrying treasure
              ldi       0ffh
              str       rf
              mov       r7,playerX     ; point to player coordinates
              mov       r8,tmarkerX    ; and treasure marker
              lda       r7             ; set tresure marker to player position
              str       r8
              inc       r8
              lda       r7
              str       r8
              mov       rf,allowed     ; set steps per turn to 4
              ldi       4
              str       rf
              call      drawmap        ; draw the map
              smi       0              ; signal end of turn
              rtn                      ; and return to caller
checkend:     mov       rf,carrying    ; need to see if carrying treasure
              ldn       rf
              lbz       endturn        ; end turn if not
              mov       r7,playerX     ; point to player coordinates
              mov       r8,secretX     ; and secret room
              lda       r7             ; see if player in secret room
              str       r2
              lda       r8
              sm
              lbnz      endturn        ; jump if not
              lda       r7
              str       r2
              lda       r8
              sm
              lbnz      endturn        ; jump if not
              smi       0              ; indicate end of turn
              rtn                      ; and return to caller
endturn:      adi       0              ; signal not end of turn
              rtn                      ; and return to caller

              endp

