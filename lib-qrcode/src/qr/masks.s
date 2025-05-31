; ---------------------------------------------------------------------------
; 101 bytes of codesize
; generates a result of 684 bytes (in v5 codes)
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
.text
; ---------------------------------------------------------------------------

calc_xor_masks .(
              jsr   set_location_to_data
;           @ initialize matrix with value 128 (highest bit set)
              ldx   matrixSz            ; rows (x-axis)
              stx   z_temp
@lp0          lda   #128
              ldy   #0
@lp1          sta   (z_location),y
              iny
              cpy   matrixSz
              bne   @lp1
              dex
              beq   @sk0
              jsr   inc_line
              jmp   @lp0

;           @ calc xor masks. reset z_location to start of matrix
@sk0          jsr   set_location_to_data
              ldx   #0
              stx   m_xpos
              stx   m_ypos

; mask 100 (bit 1): y%2=0
@bk1          lda   m_ypos
              and   #%00000001
              bne   @sk1
              lda   #%00000010
              jsr   @write_to_mask

; mask 101 (bit 2): (y+x)%2=0
@sk1
#if nr_patterns > 1
              clc
              lda   m_xpos
              adc   m_ypos
              and   #%00000001          ; 1-bit at the end says it`s an odd number --> modulo by two is not zero
              bne   @sk2                ; if AND was zero, don`t change module
              lda   #%00000100
              jsr   @write_to_mask
#endif

; mask 110 (bit 3): (y+x)%3=0
@sk2
#if nr_patterns > 2
              clc
              lda   m_xpos
              adc   m_ypos
              jsr   @modulo_3_is_zero
              bne   @sk3
              lda   #%00001000
              jsr   @write_to_mask
#endif

; mask 111 (bit 4): x%3=0
@sk3
#if nr_patterns > 3
              lda   m_xpos
              jsr   @modulo_3_is_zero
              bne   @sk4                ; if not zero don`t write mask-bit to module
              lda   #%00010000
              jsr   @write_to_mask
#endif

@sk4          inc   m_xpos
              lda   m_xpos
              cmp   matrixSz
              bne   @bk1                ; last column not passed, continue with next module

;           @ last column passed
              lda   #0
              sta   m_xpos
              inc   m_ypos              ; increase row
              lda   m_ypos
              cmp   matrixSz            ; if passed last row, we`re done
              beq   draw_format_patterns
;           @ last row not passed
              jsr   inc_line
;           @ last column not passed
              jmp   @bk1

@write_to_mask
              ldy   m_xpos
              ora   (z_location),y
              sta   (z_location),y
              rts

;           @ does %3=0. acc contains the number in question. result will be stored in zero flag
@modulo_3_is_zero
              sec
@lp2          sbc   #3
              beq   @fin                ; Acc is Zero, so Modulo is zero
              bcs   @lp2                ; Acc not Zero, but we`re below zero. Modulo is not zero
@fin          rts
              .)

; format patterns are 15 modules large. we use 15 bits for that, defined at the bottom of this file
; first (highest) 2 modules represent the error correction layer. we restrict ourselves to Low, so these are always 1
; next 3 modules represent the chosen xor mask
; the remaining 10 modules are pre-calculated, based on the first 5 modules
; if this program supported all error-correction-levels, we`d need these pre-calcs also per EC-level

; format patterns are drawn horizontally in row 8 (left to right), vertically in column 8 (bottom to top)
; they "extend" the area around the finder patterns and are interrupted by timing patterns and actual content modules
; this leads to segmented printing of these.
; horizontally: 6 modules, 1 spare, 1 module(not 2), the remaining 8 below the finder pattern on the right-hand side
; vertically: 7 modules, then 2 modules in rows 8 and 7, the rest in rows 5 to zero

; we just write these patterns as mask-bits (bit 6 set). as they are always in "read-only" areas (no content modules), xor should
; just bring these up correctly as part of the regular masking process

draw_format_patterns .(
              jsr   set_location_to_data
;           @ go to row 8 (0-based)
              ldy   #8
@lp0          jsr   inc_line
              dey
              bne   @lp0

              jsr   clean_format_modules_hor
              jsr   set_pattern_100
              jsr   write_format_modules_hor

#if nr_patterns > 1
              jsr   set_pattern_101
              jsr   write_format_modules_hor
#endif

#if nr_patterns > 2
              jsr   set_pattern_110
              jsr   write_format_modules_hor
#endif

#if nr_patterns > 3
              jsr   set_pattern_111
              jsr   write_format_modules_hor
#endif

              jsr   clean_format_modules_vert
              jsr   set_pattern_100
              jsr   write_format_modules_vert

#if nr_patterns > 1
              jsr   set_pattern_101
              jsr   write_format_modules_vert
#endif

#if nr_patterns > 2
              jsr   set_pattern_110
              jsr   write_format_modules_vert
#endif

#if nr_patterns > 3

              jsr   set_pattern_111
              jsr   write_format_modules_vert
#endif
              rts
              .)

set_pattern_100
              lda   pattern100
              sta   z_location2
              lda   pattern100+1
              sta   z_location2+1
              lda   #64
              sta   z_temp
              lda   bit1
              sta   m_bit
              rts

#if nr_patterns > 1
set_pattern_101
              lda   pattern101
              sta   z_location2
              lda   pattern101+1
              sta   z_location2+1
              lda   #64
              sta   z_temp
              lda   bit2
              sta   m_bit
              rts
#endif

#if nr_patterns > 2
set_pattern_110
              lda   pattern110
              sta   z_location2
              lda   pattern110+1
              sta   z_location2+1
              lda   #64
              sta   z_temp
              lda   bit3
              sta   m_bit
              rts
#endif

#if nr_patterns > 3
set_pattern_111
              lda   pattern111
              sta   z_location2
              lda   pattern111+1
              sta   z_location2+1
              lda   #64
              sta   z_temp
              lda   bit4
              sta   m_bit
              rts
#endif

write_format_modules_hor .(
              ldy   #0
@bk1          jsr   write_format_module
              iny
              jsr   shift_temp_right
              cmp   #1
              bne   @sk1
              iny
              jmp   @bk1
@sk1          cmp   #0
              bne   @bk1

;           @ write second byte to right-hand-side
;           @ increase y to right-border minus 8
              jsr   set_y_to_right_minus_8

;           @ initialize working variables
              lda   #128
              sta   z_temp

              lda   z_location2+1
              sta   z_location2
@bk2          jsr   write_format_module

              iny
              jsr   shift_temp_right
              bne   @bk2
              rts
              .)

set_y_to_right_minus_8 .(
              sec
              lda   matrixSz
              sbc   #8
              tay
              rts
              .)

shift_temp_right .(
              lsr   z_temp
              lda   z_temp
              rts
              .)

write_format_module .(
              lda   z_location2
              bit   z_temp
              beq   @sk1
              lda   m_bit               ; bit 6 set means data-module. bit 0 set means dark module
              jmp   @fin
@sk1          lda   #%01000000
;           @ load current value of matrix-field into Acc
@fin          ora   (z_location),y
              sta   (z_location),y
              rts
              .)

clean_format_modules_hor .(
              ldy   #0
@bk1          lda   #0
              sta   (z_location),y

              iny
              cpy   #6
              bne   @sk1
              lda   #1
              sta   (z_location),y
              iny
              jmp   @bk1

@sk1          cpy   #8
              bne   @bk1

;           @ write second byte to right-hand-side
;           @ increase y to right-border minus 8
              jsr   set_y_to_right_minus_8

              lda   #0
@bk2          sta   (z_location),y
              iny
              cpy   matrixSz
              bne   @bk2
              rts
              .)

; vertical modules start in the last row, column 8 (0-based) and go bottom up.
; 7 modules (first pattern byte) next to bottom finder pattern
; 8 modules (second pattern byte) next to top finder pattern (row 8, 0-based), starting. 2 modules, skip 1, 6 modules (ending in row 0)
clean_format_modules_vert .(
;           @ clear first pattern byte area (bottom)
              jsr   set_location_datastream; this equals end of matrix+1
              jsr   dec_line
              jsr   add_8_to_location

              ldy   #7
              ldx   #0
@bk1          lda   #0
              sta   (z_location,x)

              jsr   dec_line
              dey
              bne   @bk1

              lda   #1
              sta   (z_location,x)

;           @ clear 7 from top-down (that`s backwards to how we would write the modules)
              jsr   set_location_to_data
              jsr   add_8_to_location

;           @ read 2nd format pattern byte backwards, ie write from top to bottom
              ldy   #9

@bk2          lda   #0
              sta   (z_location,x)
              jsr   inc_line
              dey
              cpy   #3
              bne   @sk1

              lda   #1
              sta   (z_location,x)
              jsr   inc_line
              dey
              jmp   @bk2

@sk1          cpy   #0
              bne   @bk2
              rts
              .)

write_format_modules_vert .(
;           @ write first pattern byte area (bottom). write the module bottom up (this follow the bit order MSB-to-LSB)
              jsr   set_location_datastream; this equals end of matrix+1
              jsr   dec_line

              jsr   add_8_to_location

              ldy   #0
@lp1          jsr   write_format_module
              jsr   dec_line
              jsr   shift_temp_right
              bne   @lp1

;           @ write 7 from top-down (that`s backwards to the bit order of the pattern byte)
              jsr   set_location_to_data
              jsr   add_8_to_location

;           @ read 2nd format pattern byte backwards, ie write from top to bottom
              ldy   #9

              lda   #1
              sta   z_temp
              lda   z_location2+1
              sta   z_location2

@bk1          sty   z_counter1
              ldy   #0
              jsr   write_format_module
              ldy   z_counter1
              jsr   inc_line

              asl   z_temp
              dey
              cpy   #3
              bne   @sk1
              jsr   inc_line
              dey
              jmp   @bk1

@sk1          cpy   #0
              bne   @bk1
              rts
              .)

add_8_to_location .(
              clc
              lda   z_location
              adc   #8
              sta   z_location
              bcc   @fin
              inc   z_location+1
@fin          rts
              .)


; ---------------------------------------------------------------------------
.data
; ---------------------------------------------------------------------------

pattern100    byt   %01110010, %11110011

#if nr_patterns > 1
pattern101    byt   %01110111, %11000100
#endif

#if nr_patterns > 2
pattern110    byt   %01111000, %10011101
#endif

#if nr_patterns > 3
pattern111    byt   %01111101, %10101010
#endif

bit1          byt   %01000010

#if nr_patterns > 1
bit2          byt   %01000100
#endif

#if nr_patterns > 2
bit3          byt   %01001000
#endif

#if nr_patterns > 3
bit4          byt   %01010000
#endif
