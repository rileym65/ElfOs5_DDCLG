#include      macros.inc
#include      kernel.inc
#include      bios.inc

              org       02000h

              extrn     abs
              extrn     convertcoord
              extrn     drawmap
              extrn     init
              extrn     movedragon
              extrn     playerturn
              extrn     rnd

begin:        br        start
              eever
              db      'Written by Michael H. Riley',0

start:        mov       rf,0400h       ; get Elf/OS version
              ldn       rf
              smi       5              ; must be 5+
              lbdf      start2         ; jump if valid version
              call      o_inmsg        ; display error
              db        'Requires Elf/OS 5+',10,13,0
              ldi       014h           ; set return code to invalid version
              rtn                      ; return to caller

start2:       mov       rf,stack       ; point to stack storage
              ghi       r2             ; and save current stack
              str       rf
              inc       rf
              glo       r2
              str       rf
              mov       rf,K_HEAP      ; point to where heap is
              lda       rf             ; retrieve this address
              phi       r2             ; set stack below heap
              lda       rf
              plo       r2
              dec       r2
              mov       rf,treasureX   ; point to treasure X position
              ldi       0ffh;
              str       rf             ; treasureX = -1
              inc       rf
              str       rf             ; treasureY = -1
              inc       rf
              str       rf             ; tmarkerX = -1
              inc       rf
              str       rf             ; tmarkerY = -1
              inc       rf
              str       rf             ; dmarkerX = -1
              inc       rf
              str       rf             ; dmarkerY = -1
              inc       rf
              str       rf             ; secretX = -1
              inc       rf
              str       rf             ; secretY = -1
              inc       rf
              ldi       0
              str       rf             ; tfound = 0
              inc       rf
              str       rf             ; dawake = 0
              inc       rf
              str       rf             ; carrying = 0
              inc       rf
              call      o_inmsg        ; display prompt
              db        'Enter random string of characters: ',0
              mov       rf,buffer      ; point to buffer
              call      o_input        ; get string from user
              call      o_inmsg
              db        10,13,0
              mov       rf,K_MONTH     ; use kernel date/time as intial salt
              lda       rf
              phi       r8
              lda       rf
              plo       r8
              lda       rf
              phi       r7
              lda       rf
              plo       r7
              mov       rf,buffer      ; point to input buffer
              ldi       255            ; maximum count of 255
              plo       rc
seedloop:     ghi       r8             ; ring rotate r8:r7
              plo       re
              glo       r8
              phi       r8
              ghi       r7
              plo       r8
              glo       r7
              phi       r7
              lda       rf             ; get next byte from input
              lbz       seeddone       ; jump if terminator
              str       r2             ; store for combining with r7.0
              glo       re             ; get value for r7.0
              xor                      ; combine with byte from input
              plo       r7             ; and put into r7.0
              dec       rc             ; decrement max count
              glo       rc             ; see if maximum reached
              lbnz      seedloop       ; jump if not
seeddone:     mov       rf,seed        ; point to seed
              ghi       r8             ; and store randomized seed
              str       rf
              inc       rf
              glo       r8
              str       rf
              inc       rf
              ghi       r7
              str       rf
              inc       rf
              glo       r7
              str       rf
              call      init           ; initialize map
roomloop:     mov       rf,playerX     ; point to playerX
              ldi       0ffh
              str       rf             ; playerX = -1
              inc       rf
              str       rf             ; playerY = -1
              call      drawmap        ; draw the map
              call      o_inmsg        ; display prompt
              db        10,13,'Enter secret room coordinated: ',0
              mov       rf,buffer      ; where to receive input
              call      o_input        ; get input from user
              mov       rf,buffer      ; point back to buffer
              call      convertcoord   ; and convert coordinates
              lbdf      roomloop       ; loop back if invalid coordinates
              mov       rf,playerX     ; point to player coordinates
              glo       rc             ; save X coordinate
              str       rf
              inc       rf
              ghi       rc
              str       rf             ; save Y coordinate
              mov       rf,secretX     ; point to secret room coordinates
              glo       rc             ; save X coordinate
              str       rf
              inc       rf
              ghi       rc
              str       rf             ; save Y coordinate
treasurelp:   call      rnd            ; get random number
              ani       7              ; make 0-7
              plo       rd             ; save X
              call      rnd            ; get another random number
              ani       7              ; make 0-7
              phi       rd             ; save Yinto treasureY
              glo       rd             ; find playerX-treasureX
              str       r2
              glo       rc
              sm
              call      abs            ; get absolute value
              smi       3              ; must be 3 or more
              lbdf      treasuregd     ; Good if over 3 spaces away
              ghi       rd             ; find playerY-treasureY
              str       r2
              ghi       rd
              sm
              call      abs            ; get absolute value
              smi       3              ; must be 3 or more
              lbnf      treasurelp     ; find new location if too close
treasuregd:   mov       rf,treasureX   ; point to treasure location
              glo       rd             ; and save coordinates
              str       rf
              inc       rf
              ghi       rd
              str       rf
              mov       rf,dragonX     ; point to dragon location
              glo       rd             ; and save coordinates
              str       rf
              inc       rf
              ghi       rd
              str       rf
              call      o_inmsg        ; print a blank line
              db        10,13,0
              call      drawmap        ; draw the map
              mov       rf,allowed     ; point to steps allowed
              ldi       8              ; game starts with 8 per turn
              str       rf
gameloop:     call      playerturn     ; call player turn
              mov       rf,carrying    ; check if treasure being carried
              ldn       rf
              lbz       notcarrying    ; jump if not carrying treasure
              mov       ra,playerX     ; point to player coordinates
              mov       rb,secretX     ; point to secret room coordinates
              lda       ra             ; get player x
              str       r2             ; store for compare
              lda       rb             ; get secret room x
              sm                       ; and compare
              lbnz      notcarrying    ; nope, not in secret room
              ldn       ra             ; get player y
              str       r2             ; store for compare
              ldn       rb             ; get secret room y
              sm                       ; and compare
              lbnz      notcarrying    ; nope, not in secret room
              call      o_inmsg        ; display win
              db        10,13,'Congratulations!!! You have retrieved the treasure!'
              db        10,13,0
              lbr       exitgame
notcarrying:  mov       rf,allowed     ; point to steps allowed
              ldn       rf             ; and retrieve it
              smi       4              ; check for 4 or higher
              lbnf      nomove         ; already lost, do not move dragon
              call      movedragon     ; move the dragon
              mov       rf,allowed     ; need to see if dragon defeated us
              ldn       rf
              smi       4
              lbdf      gameloop       ; keep playing if not
nomove:       call      o_inmsg        ; display loss
              db        10,13,'You have been killed by the dragon!!!',10,13,0
exitgame:     mov       rf,stack       ; need to recover original stack
              lda       rf
              phi       r2
              lda       rf
              plo       r2
              ldi       0              ; set return code
              rtn                      ; and return to os

stack:        dw        0
playerX:      db        0
playerY:      db        0
treasureX:    db        0
treasureY:    db        0
tmarkerX:     db        0
tmarkerY:     db        0
dmarkerX:     db        0
dmarkerY:     db        0
secretX:      db        0
secretY:      db        0
tfound:       db        0
dawake:       db        0
carrying:     db        0
dragonX:      db        0
dragonY:      db        0
allowed:      db        0
buffer:       ds        256
map:          ds        128
explored:     ds        128
check:        ds        64
seed:         dw        0,0

              public    allowed
              public    buffer
              public    carrying
              public    check
              public    dawake
              public    dmarkerX
              public    dmarkerY
              public    dragonX
              public    dragonY
              public    explored
              public    map
              public    playerX
              public    playerY
              public    tfound
              public    tmarkerX
              public    tmarkerY
              public    treasureX
              public    treasureY
              public    secretX
              public    secretY
              public    seed

              end       begin

