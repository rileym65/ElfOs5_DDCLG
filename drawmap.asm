#include      macros.inc
#include      kernel.inc
#include      bios.inc

; ***************************
; ***** Draw the screen *****
; ***************************
              proc      drawmap

              extrn     dawake
              extrn     dmarkerX
              extrn     explored
              extrn     offset
              extrn     playerX
              extrn     secretX
              extrn     tfound
              extrn     tmarkerX

              call      o_inmsg        ; draw top
              db        10,13
              db        '    1   2   3   4   5   6   7   8',10,13
              db        '  +###+###+###+###+###+###+###+###+',10,13,0
              ldi       0              ; y loop starts at 0
              phi       rc
yloop:        ghi       rc             ; get Y value
              adi       'A'            ; convert to A-H
              call      o_type         ; and output it
              call      o_inmsg        ; rest of start of row
              db        ' #',0
              ldi       0              ; x loop starts at 0
              plo       rc
xloop:        ldi       ' '            ; cell starts as a space
              plo       rd
              mov       ra,tmarkerX    ; point to treasure marker
              glo       rc             ; see if x = tmarkerx
              str       r2
              lda       ra
              sm
              lbnz      nottmarker     ; jump if not tmarker
              ghi       rc             ; see if y = tmarkery
              str       r2
              ldn       ra
              sm
              lbnz      nottmarker     ; jump if not
              ldi       '$'            ; set current cell to treasure
              plo       rd
nottmarker:   mov       ra,secretX     ; point to secret room
              glo       rc             ; see if x = secretx
              str       r2
              lda       ra
              sm
              lbnz      notsecret      ; jump if not tmarker
              ghi       rc             ; see if y = secrety
              str       r2
              ldn       ra
              sm
              lbnz      notsecret      ; jump if not
              ldi       'S'            ; set current cell to treasure
              plo       rd
notsecret:    mov       ra,dmarkerX    ; point to dragon marker
              glo       rc             ; see if x = dmarkerx
              str       r2
              lda       ra
              sm
              lbnz      notdmarker     ; jump if not tmarker
              ghi       rc             ; see if y = dmarkery
              str       r2
              ldn       ra
              sm
              lbnz      notdmarker     ; jump if not
              ldi       'D'            ; set current cell to treasure
              plo       rd
notdmarker:   mov       ra,playerX     ; point to player
              glo       rc             ; see if x = playerX
              str       r2
              lda       ra
              sm
              lbnz      notplayer      ; jump if not tmarker
              ghi       rc             ; see if y = playerY
              str       r2
              ldn       ra
              sm
              lbnz      notplayer      ; jump if not
              ldi       '@'            ; set current cell to treasure
              plo       rd
notplayer:    ldi       ' '            ; draw cell
              call      o_type
              glo       rd
              call      o_type
              ldi       ' '
              call      o_type
              glo       rc             ; get x
              smi       7              ; check less than 7
              lbdf      drawwall       ; draw a wall
              push      rc             ; save coordinates
              ghi       rc             ; y*2
              shl
              phi       rc
              mov       rf,explored    ; point to explored array
              call      offset         ; find offset
              pop       rc             ; recover coordinates
              ldn       rf             ; get cell from explored
              smi       ' '            ; check for space
              lbz       drawcell       ; draw a space
drawwall:     ldi       '#'            ; draw a wall
              call      o_type
              lbr       nextx          ; then end loop
drawcell:     ldi       '|'            ; draw cell boundary
              call      o_type
nextx:        inc       rc             ; increment x
              glo       rc             ; see if done with loop
              smi       8
              lbnz      xloop          ; loop until all x cells drawn
              ghi       rc             ; get y
              smi       1              ; see if 1
              lbnz      not_1          ; jump if not
              call      o_inmsg        ; dispay message
              db        '    Dragon  : ',0
              mov       rf,dawake      ; see if dragon is awak
              ldn       rf
              lbz       sleeping       ; jump if sleeping
              call      o_inmsg        ; otherwise print awake message
              db        'Awake',0
              lbr       donelabels     ; jump to done with labels
sleeping:     call      o_inmsg        ; print sleping
              db        'Asleep',0
              lbr       donelabels     ; done with labels
not_1:        smi       1              ; see if 2
              lbnz      donelabels     ; done with labels
              call      o_inmsg        ; display label
              db        '    Treasure: ',0
              mov       rf,tfound      ; see if treasure found
              ldn       rf
              lbz       notfound       ; jump if not
              call      o_inmsg        ; display found
              db        'Found',0
              lbr       donelabels     ; done with labels
notfound:     call      o_inmsg        ; display not found
              db        'Not found',0
donelabels:   call      o_inmsg        ; display cr/lf
              db        10,13,0
              ghi       rc             ; get 7
              smi       7              ; check for final row
              lbz       finalrow       ; jump if so
              call      o_inmsg        ; print leader
              db        '  +',0
              push      rc             ; save main loop coordinates
              ghi       rc             ; get y
              shl                      ; multiply by 2
              adi       1              ; and add 1
              phi       rc             ; put it back
              ldi       0              ; x loop starts at zero
              plo       rc
xloop_2:      mov       rf,explored    ; point to explored array
              call      offset         ; get offset
              ldn       rf             ; get value of cell
              smi       ' '            ; check for space
              lbz       space_2        ; jump if so
              call      o_inmsg        ; display a wall
              db        '###+',0
              lbr       nextx_2        ; then check loop
space_2:      call      o_inmsg        ; display grid line
              db        '---+',0
nextx_2:      inc       rc             ; increment x
              glo       rc             ; see if done
              smi       8
              lbnz      xloop_2        ; loop until done
              call      o_inmsg        ; print crlf
              db        10,13,0
              pop       rc             ; recover original coordinates
              lbr       nexty          ; then next y
finalrow:     call      o_inmsg        ; print final row
              db        '  +###+###+###+###+###+###+###+###+',10,13,0
nexty:        ghi       rc             ; increment y
              adi       1
              phi       rc
              smi       8              ; check for end of loop
              lbnz      yloop          ; loop until done
              rtn                      ; then return to caller

              endp

