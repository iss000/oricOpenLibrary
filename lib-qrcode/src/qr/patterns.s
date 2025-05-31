; ---------------------------------------------------------------------------
; this writes the
; - timing patterns (horizontal and vertical).
;   starting at row and column 6 (zero-based), starting with dark
; - finder patterns (top left, top right, bottom left)
;   8 modules, starting with dark at the corners
; - alignment pattern (only version 2 and up)
;   5x5 modules. at matrixSz-9 pixels. (or rightmost col-8 pixels)
;   (eg 28 for 37 wide) (both, horizontal and vertical)
;
; format patterns are part of the xor-mask
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
.text
; ---------------------------------------------------------------------------

write_patterns .(
              jsr   set_location_to_data

;           @ --------------------
;           @ horizontal timing pattern
;           @ --------------------
;           @ add 6xsize to be in the row for writing the pattern
              ldy   #6
@bk1          jsr   inc_line
              dey
              bne   @bk1

;           @ write modules, starting with dark
              ldy   #0
@bk2          lda   #1
              sta   (z_location),y
              iny
              cpy   matrixSz            ; matrixSz is always an odd number, we only need to check for completeness here.
              beq   @do_vertical

              lda   #0
              sta   (z_location),y
              iny
              jmp   @bk2

;           @ ------------------
;           @ vertical timing pattern
;           @ ------------------

@do_vertical  jsr   set_location_to_data
              clc
              lda   z_location
              adc   #6
              sta   z_location
              bcc   @sk1
              inc   z_location+1

@sk1          ldy   #0
              sty   z_counter1
@bk3          ldy   #0
              lda   #1
              sta   (z_location),y
              ldy   z_counter1
              iny
              cpy   matrixSz
              beq   @do_finder
              sty   z_counter1          ; could do inc z_counter1 as well, but that takes 5 cycles (sty takes 3)
              jsr   inc_line

              ldy   #0
              lda   #0
              sta   (z_location),y
              inc   z_counter1          ; now inc makes sense. 5 cycles over (3 and 2 and 3 for ldy iny sty)
              jsr   inc_line
              jmp   @bk3

;           @ ---------------
;           @ Finder patterns
;           @ ---------------

@do_finder
;           @ top-left
              lda   #<modules_finder_left
              sta   z_location2
              lda   #>modules_finder_left
              sta   z_location2+1

              jsr   set_location_to_data
              jsr   do_finder_square
              jsr   dec_location_by_1
              ldy   #8
              jsr   do_horizontal_y_zeroes

;           @ bottom-left

;           @ calculate starting position of bottom-left pattern (=matrixLen-7*matrixSz)
;           @ subtracting 7 lines from end of matrix is faster than adding matrixSz-7 lines to the start of the matrix
;           @ start by storing end address of matrix in z_location
              jsr   set_location_datastream

;           @ now, subtract 7 lines from z_location

              ldy   #8
@bk4          jsr   dec_line

              dey
              bne   @bk4

              jsr   dec_location_by_1
              ldy   #8
              jsr   do_horizontal_y_zeroes

              jsr   inc_location_by_1
              jsr   inc_line
              jsr   do_finder_square

;           @ top-right
              lda   #<modules_finder_right
              sta   z_location2
              lda   #>modules_finder_right
              sta   z_location2+1

;           @ calculate starting position of top-right pattern(=matrixStart + matrixSz-8)
              jsr   set_location_to_data
              jsr   inc_line

              sec
              lda   z_location
              sbc   #8
              sta   z_location
              bcs   @sk2
              dec   z_location+1

@sk2          jsr   do_finder_square
              jsr   dec_location_by_1
              ldy   #8
              jsr   do_horizontal_y_zeroes

;           @ we`re done. if contentlength > 17, draw the alignment pattern. else, return
              lda   contentLen
              cmp   #18
              bcs   @sk3
              rts

@sk3          jmp   do_alignment_pattern
              .)

do_horizontal_y_zeroes .(

@lp           lda   #0
              sta   (z_location),y
              dey
              bne   @lp
              rts
              .)

; this prints the following pattern
; XXXXXXX
; X     X
; X XXX X
; X XXX X
; X XXX X
; X     X
; XXXXXXX

do_finder_square .(

              ldy   #0
              sty   z_counter1          ; which line are we writing (ie which .module_finder_x offset are we reading from?)

@loop         lda   #%10000000
              sta   z_temp

              ldy   #0                  ; which module of the line are we writing to?
              sty   z_counter2

@bk1          ldy   z_counter1
              lda   (z_location2),y

              bit   z_temp
              beq   @sk1
              lda   #%00000001          ;bit 0 set means dark module
              jmp   @sk2
@sk1          lda   #%00000000

@sk2          ldy   z_counter2
              sta   (z_location),y
              iny
              sty   z_counter2
              lda   z_temp
              lsr
              sta   z_temp
              bne   @bk1

              jsr   inc_line
              inc   z_counter1
              lda   z_counter1
              cmp   #7
              bne   @loop
              rts
              .)

; the alignment pattern is 5x5 and always at location 28x28 (matrixSz - 9)
; XXXXX
; X   X
; X X X
; X   X
; XXXXX
do_alignment_pattern .(

              jsr   set_location_datastream

;           @ now, subtract 8 lines from z_location
              ldy   #8
@bk1          jsr   dec_line

              dey
              bne   @bk1

;           @ finally, subtract 12 from z_location (usually 9, but we re-use another method)
              lda   z_location
              sec
              sbc   #12
              sta   z_location
              bcs   @sk1
              dec   z_location+1

;           @ ------------------------
;           @ draw the pattern
;           @ -----------------------

@sk1          ldx   #0
              stx   z_counter1          ; which line are we writing (ie which .module_alignment offset are we reading from?)

@loop         lda   #%00010000
              sta   z_temp
              ldy   #3                  ; which module of the line are we writing to?

@bk2          ldx   z_counter1
              lda   modules_alignment,x

              bit   z_temp
              beq   @sk2
              lda   #%00000001          ;bit 0 set means dark module
              jmp   @sk3
@sk2          lda   #%00000000
@sk3          sta   (z_location),y
              iny
              lsr   z_temp
              lda   z_temp
              bne   @bk2

              jsr   inc_line
              inc   z_counter1
              lda   z_counter1
              cmp   #5
              bne   @loop
              rts
              .)

; ---------------------------------------------------------------------------
.data
; ---------------------------------------------------------------------------
modules_finder_left
              byt   %11111110,%10000010,%10111010,%10111010,%10111010,%10000010,%11111110
modules_finder_right
              byt   %01111111,%01000001,%01011101,%01011101,%01011101,%01000001,%01111111
modules_alignment
              byt   %00011111,%00010001,%00010101,%00010001,%00011111
