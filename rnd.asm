#include      macros.inc
#include      kernel.inc
#include      bios.inc

; *********************************************
; ***** Generate random number from 0-255 *****
; ***** Returns: D - random number        *****
; *********************************************
              proc      rnd

              extrn     seed

              mov       rf,seed        ; retrieve rng seed
              lda       rf
              phi       r8
              lda       rf
              plo       r8
              lda       rf
              phi       r7
              lda       rf
              plo       r7
              ldi       4              ; need to process 4 bits
              plo       re
loop:         glo       r7             ; t = seed & 810009h
              ani       09h
              str       r2             ; will reduce to single byte
              glo       r8
              ani       081h
              xor                      ; combine with first byte
              plo       r9             ; keep a copy
              ani       0fh            ; keep only low 4 bits
              str       r2             ; store for combination
              glo       r9             ; recover byte
              shr                      ; shift high nybble to low
              shr
              shr
              shr
              ani       0fh            ; be sure high bits are clear
              xor                      ; combine with low nybble
              plo       r9             ; save a copy
              ani       03h            ; keep only 2 lowest bits
              str       r2             ; store for combine
              glo       r9             ; get original number
              shr                      ; shift right two bits
              shr
              ani       03h            ; be sure to only have low 2 bits
              xor                      ; and combine with orignal low 2 bits
              plo       r9             ; keep a copy
              ani       1              ; keep only lowest bit
              str       r2             ; store for combine
              glo       r9             ; get original
              shr                      ; shift 1 bit
              ani       1              ; keep only lowest bit
              xor                      ; combine with low bit
              xri       1              ; now have parity bit
              shr                      ; shift it into DF
              ghi       r8             ; shift seed right 1 bit
              shrc
              phi       r8
              glo       r8
              shrc
              plo       r8
              ghi       r7
              shrc
              phi       r7
              glo       r7
              shrc
              plo       r7
              dec       re             ; decrement count
              glo       re             ; see if done
              lbnz      loop           ; loop until processed 4 times
              mov       rf,seed        ; need to write new seed
              ghi       r8
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
              rtn                      ; return lowest byte to caller

              endp
