;)              _
;)  ___ ___ _ _|_|___ ___
;) |  _| .'|_'_| |_ -|_ -|
;) |_| |__,|_,_|_|___|___|
;)         raxiss (c) 2021
;)
;) GNU General Public License v3.0
;) See https://github.com/iss000/oricOpenLibrary/blob/main/LICENSE
;)

; ======================================================================
; libbasic code
; ======================================================================


atmos_exec    =   $c4bd
oric1_exec    =   $c4cd

; ----------------------------------------------------------------------
; Change ROM addres fpr Oric-1
; ----------------------------------------------------------------------
_exec         =   atmos_exec

; ----------------------------------------------------------------------
__basic_r  .byt   0,0
__basic_s  .byt   0,0
; ----------------------------------------------------------------------
__basic     lda   $02f5
            sta   basic_next+1
            lda   $02f5+1
            sta   basic_next+2

            lda   $001b
            sta   __basic_r
            lda   $001b+1
            sta   __basic_r+1

            lda   #<basic_ret
            sta   $001b
            lda   #>basic_ret
            sta   $001b+1

            lda   __basic_s
            sta   $00
            lda   __basic_s+1
            sta   $00+1

            :.(
            ldy   #$00
loop        lda   ($00),y
            sta   $0035,y
            beq   fin
            iny
            cpy   #$50
            bcc   loop
fin         ldx   #<$0034
            ldy   #>$0034
            :.)

            jmp   _exec

; ----------------------------------------------------------------------
basic_next  jmp   $dead

; ----------------------------------------------------------------------
basic_ret   lda   basic_next+1
            sta   $02f5
            lda   basic_next+2
            sta   $02f5+1

            lda   __basic_r
            sta   $001b
            lda   __basic_r+1
            sta   $001b+1

            pla
            pla
            rts
