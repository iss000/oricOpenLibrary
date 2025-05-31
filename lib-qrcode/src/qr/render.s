; ---------------------------------------------------------------------------
; this renders 1 module per petscii-character
; so, output is limited to nr of lines on screen (23 on vic20, 25 on all the other machines)
; that leaves the vic20 with version 1 codes and all others with version 2 codes
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
.text
; ---------------------------------------------------------------------------

render        .(
              jsr   set_location_to_data
              ldy   #0                  ;y holds the column (reset to zero after eol is reached)

@handle_col   lda   (z_location),y
              bit   m_64                ;is xor-bit set?
              bvc   @write_value

              pha
              and   #1
              sta   z_temp
              pla
              and   m_maskbit
              bne   @sk1
              lda   #0
              beq   @sk2
@sk1          lda   #1
@sk2          eor   z_temp

@write_value  bit   m_one
              bne   @sk3
              lda   #32
              bne   @sk4
@sk3          lda   #160
@sk4          sta   (z_location2),y

;           @ move on
              iny
              cpy   matrixSz
              bne   @handle_col

              ldy   #0
              jsr   @inc_line_r
              jsr   inc_line
              cmp   m_endAdr
              beq   @fin
              jmp   @handle_col

@inc_line_r   lda   z_location2
              clc
              adc   rsDivisorOfs
              sta   z_location2
              bcc   @fin
              inc   z_location2+1
@fin          rts
              .)
