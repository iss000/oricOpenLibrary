; this renders 2x2 modules in a single petscii character
; this allows for the full size of the max supported size (version 5 with 37x37 modules) on all machines
; including the vic 20

; ---------------------------------------------------------------------------
.text
; ---------------------------------------------------------------------------

render        .(
              jsr   set_location_to_data
              ldy   #0                  ;y holds the readcolumn (reset to zero after eol is reached)

              ldx   #0
              stx   z_counter1          ;used for counting modules for display in a single character (used for bit shifting)
              stx   z_counter2          ;z_counter2 temporarily holds the value of the 4 modules (the bit-shifted values)
              stx   contentLen          ;in this context, this should be read as "write position"
              inc   contentLen

              lda   matrixSz
              sta   m_ypos              ;used to check whether we moved below the last line

              lda   #0
              sta   m_xpos              ;the column for writing the petscii character that holds 4 modules

@read_4_modules
              jsr   @handle_module
              inc   z_counter1
              iny
              cpy   matrixSz            ; check if we`re at the right border of the matrix
              beq   @sk1                ; if yes, read the module below

              jsr   @handle_module
@sk1          inc   z_counter1
              dey
              jsr   inc_line
              dec   m_ypos
              beq   @skip_bottom_row    ;we`re in the last line. go up and two to the right (dec_line once and iny twice)

              jsr   @handle_module
              inc   z_counter1
              iny
              cpy   matrixSz
              beq   @next_line

              jsr   @handle_module
              iny
              jsr   dec_line
              inc   m_ypos

              jsr   write_character

              jmp   @read_4_modules

@skip_bottom_row
              jsr   dec_line
              inc   m_ypos
              iny
              cpy   matrixSz
              beq   @fin
              iny
              jsr   write_character
              jmp   @read_4_modules

@fin          jsr   write_character
              rts

@next_line
              jsr   write_character

              ldy   #0
              jsr   inc_line
              dec   m_ypos
              jsr   inc_line_r2

              jmp   @read_4_modules

@handle_module
              lda   (z_location),y
              bit   m_64                ;is xor-bit set?
              bvc   @collect_value

              pha
              and   #1
              sta   z_temp
              pla
              and   m_maskbit
              bne   @sk2
              lda   #0
              jmp   @sk3
@sk2          lda   #1
@sk3          eor   z_temp

@collect_value
; store final value of module in bit5 (ready to be rendered)
; if module is dark, set bit 5 (if not, leave it untouched)

              ldx   z_counter1
@bk1          beq   @sk4
              asl
              dex
              jmp   @bk1
@sk4          ora   z_counter2
              sta   z_counter2
              rts
              .)

write_character .(
              sty   z_temp

              ldx   z_counter2
              lda   modulechars,x
              ldy   m_xpos
              sta   (z_location2),y

              ldx   #0
              stx   z_counter1
              stx   z_counter2

              inc   streamLength
              inc   m_xpos
              ldy   z_temp
              rts
              .)

inc_line_r2   .(
              lda   #0
              sta   m_xpos

              lda   z_location2
              clc
              adc   rsDivisorOfs
              sta   z_location2
              bcc   @fin
              inc   z_location2+1
@fin          rts
              .)

; ---------------------------------------------------------------------------
.data
; ---------------------------------------------------------------------------

modulechars   byt   32,126,124,226,123,97,255,236,108,127,225,251,98,252,254,160
