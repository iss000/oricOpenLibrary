; ---------------------------------------------------------------------------
; this renders the qr-code to a 64-pixel wide vic-iv sprite.
; z_location contains the pointer to read from
; z_location2 is the pointer to write the sprite pixels to.
; ---------------------------------------------------------------------------

#define z_sprite_bit       z_counter1
#define z_sprite_byte      z_counter1+1
#define z_sprite_offset    z_counter2

; ---------------------------------------------------------------------------
.text
; ---------------------------------------------------------------------------
render        .(
              jsr   set_location_to_data
              ldy   #0                  ;y holds the column (reset to zero after eol is reached)
              sty   z_sprite_offset

              lda   #%00100000
              jsr   reset_sprite_byte

;           @ z_location3 is used for rendering sprites
              clc
              lda   #<_qr_data
              adc   matrixSz
              sta   z_location3
              lda   #>_qr_data
              adc   matrixSz+1
              sta   z_location3+1

;           @ increase z_location3 to the next 64-byte increment ($40, $80, or $c0)
              lda   #%00111111
              bit   z_location3
              beq   @sk1                ; if zero, we are at a 64-byte increment already

              clc
              lda   #$40
              cmp   z_location3         ; is LB lower than 64? set it to 64
              bcs   @sk2
              sta   z_location3
              bcc   @sk1                ; is really JMP, so read as unconditional branch

@sk2          clc
              lda   #$80
              cmp   z_location3
              bcs   @sk3
              sta   z_location3
              bcc   @sk1

@sk3          clc
              lda   #$c0
              cmp   z_location3
              bcs   @sk4
              sta   z_location3
              bcc   @sk1

@sk4          lda   #0
              sta   z_location3
              inc   z_location3+1

; store z_location3 for later return to caller. current value will be changed.
@sk1          lda   z_location3
              sta   m_l3
              lda   z_location3+1
              sta   m_l3+1

              lda   #0
@lp           sta   (z_location3),y
              dey
              bne   @lp

; start writing pixels after two rows (8 bytes for each row)
              clc
              lda   z_location3
              adc   #16
              sta   z_location3
              bcc   @handle_col
              inc   z_location3+1

@handle_col
              lda   (z_location),y
              bit   m_64                ;is xor-bit set?
              bvc   @write_value        ;branch if this bit is not xored

              pha
              and   #1
              sta   z_temp
              pla
              and   m_maskbit
              bne   @sk5
              lda   #0
              jmp   @sk6
@sk5          lda   #1
@sk6          eor   z_temp

@write_value
              bit   m_one
              bne   @sk7

              ldx   #32                 ; black module (prints space)
;           @ don`t need to do anything for sprite here (as bits are 0 already)
              jmp   @sk8

@sk7          ldx   #160                ; white module (prints inverse space)
              lda   z_sprite_byte
              ora   z_sprite_bit
              sta   z_sprite_byte       ; collect module for sprite byte

@sk8          lda   z_sprite_bit        ; shift bit to the right
              clc
              lsr
              sta   z_sprite_bit
              bcc   @sk9                ; carry flag not set (ie sprite byte not full)

;           @ if sprite bit is zero (carry flag set), sprite byte is full
              jsr   write_sprite_byte
              lda   #%10000000
              jsr   reset_sprite_byte

@sk9          txa
              sta   (z_location2),y

;           @ move on
              iny
              cpy   matrixLen
              bne   @handle_col

;           @ finish line
              ldy   #0
              jsr   inc_line_rspr
              jsr   inc_line
              cmp   m_endAdr            ; needs to have z_location in accumulator
              beq   @fin
              jmp   @handle_col
@fin          rts
              .)

inc_line_rspr .(
              lda   z_location2
              clc
              adc   rsDivisorOfs
              sta   z_location2
              bcc   @sk1
              inc   z_location2+1

@sk1          jsr   write_sprite_byte
              lda   #0
              sta   z_sprite_offset
              lda   #%00100000
              jsr   reset_sprite_byte
              clc
              lda   z_location3
              adc   #8
              sta   z_location3
              bcc   @fin
              inc   z_location3+1
@fin          rts
              .)

reset_sprite_byte .(
              sta   z_sprite_bit        ;used to keep track of bit
              lda   #0
              sta   z_sprite_byte       ;used to collect the byte value for 8 modules each
              rts
              .)

write_sprite_byte .(
              sty   z_temp
              ldy   z_sprite_offset
              lda   z_sprite_byte
              sta   (z_location3),y
              inc   z_sprite_offset
              ldy   z_temp
              rts
              .)
