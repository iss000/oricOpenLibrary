;)              _
;)  ___ ___ _ _|_|___ ___
;) |  _| .'|_'_| |_ -|_ -|
;) |_| |__,|_,_|_|___|___|
;)         raxiss (c) 2021

; ======================================================================
; TTF render
; ======================================================================

; ======================================================================
#define _w(x) !x

; ======================================================================
.zero
; ----------------------------------------------------------------------

#define src      $00
#define dst      $02
#define srcdef   $04
#define idx      $06
#define lenw     $07
#define lenh     $08
#define shft     $09
#define buff     $0a

; ----------------------------------------------------------------------
#define ttf      $12
#define ttf_w    $12
#define ttf_h    $13
#define ttf_ws   $14
#define ttf_wbs  $16
#define ttf_olo  $18
#define ttf_ohi  $1a
#define ttf_end  $1c
#define ttf_len  (ttf_end-ttf)

; ======================================================================
.text
; ----------------------------------------------------------------------
#include "ttf-tabs.s"
#include "ttf-scrn.s"

; ----------------------------------------------------------------------
__ttf_ptr     .word 0
__ttf_x       .byte 0
__ttf_y       .byte 0
__ttf_space   .byte 0
__ttf_len     .byte 0

; ----------------------------------------------------------------------
__ttf_open    :.(
              lda   __ttf_ptr
              sta   src
              lda   __ttf_ptr+1
              sta   src+1
              lda   #<ttf
              sta   dst
              lda   #>ttf
              sta   dst+1

              ldy   #$00
loop          lda   (src),y
              sta   (dst),y
              iny
              cpy   #ttf_len
              bne   loop

              rts
              :.)

; ----------------------------------------------------------------------
__ttf_strlen  :.(
              lda   __ttf_ptr
              sta   src
              lda   __ttf_ptr+1
              sta   src+1

              ldy   #$00
              sty   lenw
              sty   idx

loop_str      lda   (src),y
              beq   fin

              sec
              sbc   #$20
              tay
              lda   (ttf_ws),y
              clc
              adc   lenw
              sta   lenw

              inc   idx
              ldy   idx
              bne   loop_str  ; bra

fin           lda   lenw
              sta   __ttf_len
              rts
              :.)

; ----------------------------------------------------------------------
__ttf_print   :.(
              lda   __ttf_ptr
              sta   src
              lda   __ttf_ptr+1
              sta   src+1

              lda   #$00
              sta   idx

loop_str      ldx   __ttf_x
              lda   tabXtoShift,x
              sta   shft

              lda   tabXtoByte,x
              clc
              ldx   __ttf_y
              adc   _w(_scrnlo),x
              sta   dst
              lda   _w(_scrnhi),x
              adc   #$00
              sta   dst+1

              ldy   idx
              lda   (src),y
              beq   fin
              sec
              sbc   #$20
              tay
              bne   nospace
              lda   __ttf_space
              bne   space1
nospace       tay
              lda   (ttf_ws),y
space1        clc
              adc   __ttf_x   ; TODO: spacing?
              sta   __ttf_x
              cpy   #$00
              beq   space2
              jsr   ttf_putc
space2        inc   idx
              bne   loop_str  ; bra
fin           rts
              :.)

; ----------------------------------------------------------------------
; Y = ascii-$20
ttf_putc      :.(
              lda   (ttf_olo),y ; char def low
              sta   srcdef
              lda   (ttf_ohi),y ; char def hi
              sta   srcdef+1

              lda   ttf_h
              sta   lenh

              lda   (ttf_wbs),y ; width bytes
              sta   lenw
              tax

loop_y        ldy   #$00
loop_xb       lda   (srcdef),y
              sta   buff,y
              iny
              dex
              bne   loop_xb
              txa               ; X=0
              sta   buff,y   ; clear shift byte

              ldy   shft
              beq   no_shft
              jsr   ttf_shift

no_shft     ; ldy   #$00        ; optimized
              ldx   lenw
              inx               ; +1 shifted byte
loop_xd       lda   buff,y
              ora   (dst),y
            ; ora   #$40
              sta   (dst),y
              iny
              dex
              bne   loop_xd

              clc
              lda   dst
              adc   #40
              sta   dst
              lda   dst+1
              adc   #0
              sta   dst+1

            ; clc   optimized
              ldx   lenw
              txa
              adc   srcdef
              sta   srcdef
              lda   #$00
              adc   srcdef+1
              sta   srcdef+1

              dec   lenh
              bne   loop_y
              rts
              :.)

; ----------------------------------------------------------------------
; Y=shift
ttf_shift     :.(
loop          ldx     lenw
              inx
              lsr     buff
              dex
              beq     fin
              bcc     skips1
              lda     #$40
              ora     buff+1
              sta     buff+1

skips1        lsr     buff+1
              dex
              beq     fin
              bcc     skips2
              lda     #$40
              ora     buff+2
              sta     buff+2

skips2        lsr     buff+2
              dex
              beq     fin
              bcc     skips3
              lda     #$40
              ora     buff+3
              sta     buff+3

skips3        lsr     buff+3
              dex
              beq     fin
              bcc     skips4
              lda     #$40
              ora     buff+4
              sta     buff+4

skips4        lsr     buff+4
              dex
              beq     fin
              bcc     skips5
              lda     #$40
              ora     buff+5
              sta     buff+5

skips5        lsr     buff+5
              dex
              beq     fin
              bcc     skips6
              lda     #$40
              ora     buff+6
              sta     buff+6

skips6        lsr     buff+6
              dex
              beq     fin
              bcc     skips7
              lda     #$40
              ora     buff+7
              sta     buff+7

skips7        lsr     buff+7
fin           dey
              bne     loop
              rts
              :.)
