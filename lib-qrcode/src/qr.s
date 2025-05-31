; ===========================================================================
; qr-code generator
; parameters:
; - reads the location of the string to be encoded from a zeropage location (eg $fb/$fc)
;   the string must be zero-terminated (that saves us the need to provide string-length as a parameter)
; - bank of the string address
; returns: location of
; ===========================================================================

; ---------------------------------------------------------------------------
#include "compat.h"
#include "xa.h"

; ---------------------------------------------------------------------------
#define nr_patterns 1
#define max_version 2

; undef and move working space
; required $05E0 bytes
; #define _qr_data    $4000

; ---------------------------------------------------------------------------
.zero
; ---------------------------------------------------------------------------
z_location    dsb   2
z_location2   dsb   2
z_location3   dsb   2

z_temp        dsb   1
z_counter1    dsb   1                   ; ENDCHR
z_counter2    dsb   1                   ; VERCK

; ---------------------------------------------------------------------------
.data
; ---------------------------------------------------------------------------
__qr_str      wrd   0
__qr_ptr      wrd   0

; ---------------------------------------------------------------------------
.text
; ---------------------------------------------------------------------------
__qr          .(

#if 0
              trace_on
#else
              nop
              nop
              nop
#endif
;           @ input address for petscii-to-ascii conversion
              lda   __qr_str
              sta   z_location
              lda   __qr_str+1
              sta   z_location+1

              lda   #<_qr_data
              sta   z_location2
              lda   #>_qr_data
              sta   z_location2+1

              ldy   #0
              sty   __qr_str            ; for return code
              sty   __qr_str+1

@loop         lda   (z_location),y
              sta   (z_location2),y
              beq   @cont
              iny
              bne   @loop
              beq   @fin
@cont         sty   contentLen

              jsr   init_data
              bcs   @fin
              lda   matrixSz
              sta   __qr_str            ; return matrix size

              jsr   bytes_to_stream
              jsr   calc_xor_masks
              jsr   rs
              jsr   write_patterns
              jsr   stream_to_module

;           @ load screen-ram location into z_location2
              lda   __qr_ptr
              sta   z_location2
              lda   __qr_ptr+1
              sta   z_location2+1
              ldx   #40
              stx   rsDivisorOfs
              jmp   render
@fin          rts
              .)

; ---------------------------------------------------------------------------
; "common.s" - common methods
; ---------------------------------------------------------------------------
set_location_datastream .(
              clc
              lda   #<_qr_data
              adc   matrixLen
              sta   z_location
              lda   #>_qr_data
              adc   matrixLen+1
              sta   z_location+1
              rts
              .)

set_location_to_data .(
              lda   #<_qr_data
              sta   z_location
              lda   #>_qr_data
              sta   z_location+1
              rts
              .)

inc_line      .(
              clc
              lda   z_location
              adc   matrixSz
              sta   z_location
              bcc   @fin
              inc   z_location+1
@fin          rts
              .)

dec_line      .(
              sec
              lda   z_location
              sbc   matrixSz
              sta   z_location
              bcs   @fin
              dec   z_location+1
@fin          rts
              .)

inc_location_by_1 .(
              clc
              lda   z_location
              adc   #1
              sta   z_location
              bcc   @fin
              inc   z_location+1
@fin          rts
              .)

dec_location_by_1 .(
              sec
              lda   z_location
              sbc   #1
              sta   z_location
              bcs   @fin
              dec   z_location+1
@fin          rts
              .)

; ---------------------------------------------------------------------------
; "init.s" - calculates all sizes according to the length of the content
; ---------------------------------------------------------------------------
; decreasing the version boundaries by one byte,
; because of mode and length bits (eg lower than 108)
; max supported version is 5 -> 108 bytes -2=106
init_data     .(
              lda   contentLen

              cmp   #18
              bcs   @sk1
              lda   #21
              sta   matrixSz
              lda   #<441
              sta   matrixLen
              lda   #>441
              sta   matrixLen+1
              lda   #7
              sta   eccLength
              lda   #26
              sta   streamLength
              lda   #0
              sta   rsDivisorOfs
              jmp   @fin

@sk1          cmp   #33
              bcs   @sk2
              lda   #25
              sta   matrixSz
              lda   #<625
              sta   matrixLen
              lda   #>625
              sta   matrixLen+1
              lda   #10
              sta   eccLength
              lda   #44
              sta   streamLength
              lda   #7
              sta   rsDivisorOfs
              jmp   @fin

@sk2
#if max_version > 2
              cmp   #54
              bcs   @sk3
              lda   #29
              sta   matrixSz
              lda   #<841
              sta   matrixLen
              lda   #>841
              sta   matrixLen+1
              lda   #15
              sta   eccLength
              lda   #70
              sta   streamLength
              lda   #17
              sta   rsDivisorOfs
              jmp   @fin
#endif

@sk3
#if max_version > 3
              cmp   #79
              bcs   @sk4
              lda   #33
              sta   matrixSz
              lda   #<1089
              sta   matrixLen
              lda   #>1089
              sta   matrixLen+1
              lda   #20
              sta   eccLength
              lda   #100
              sta   streamLength
              lda   #32
              sta   rsDivisorOfs
              jmp   @fin
#endif

@sk4
#if max_version > 4
              cmp   #107
              bcs   @fin
              lda   #37
              sta   matrixSz
              lda   #<1369
              sta   matrixLen
              lda   #>1369
              sta   matrixLen+1
              lda   #26
              sta   eccLength
              lda   #134
              sta   streamLength
              lda   #52
              sta   rsDivisorOfs
              jmp   @fin
#endif

@fin          rts
              .)

; ---------------------------------------------------------------------------
; "bytes2stream.s"
; ---------------------------------------------------------------------------
; reads ascii from z_location2 and writes into datastream at z_location (=data+matrix_size)
; z_counter1 holds the right offset for rs.a to continue using it.
bytes_to_stream .(
; calculate start address of datastream (matrix end)
              jsr   set_location_datastream

; write mode byte and first nybble of length byte
              ldy   #0
              sty   z_counter1          ; counter1 holds the datastream index (ie write index)
              sty   z_counter2          ; counter2 holds the input index (ie read index) (stop-condition: cmp contentLen)

              lda   #64
              sta   z_temp
              sta   (z_location),y

              lda   contentLen
              jsr   writeToStream
              inc   contentLen          ; increase to make stop-condition easier to check

; write content bytes
@bk1          ldy   z_counter2
              lda   (z_location2),y
              jsr   writeToStream       ; increases y to next write index (z_counter1)
              cpy   contentLen
              beq   @sk1                ; all content written to stream. continue
              inc   z_counter2          ; else: increase read index and continue with next character
              jmp   @bk1

; write last byte. lower nybble is left to zero
@sk1          ldy   z_counter1
              sta   (z_location),y
              iny
              sty   z_counter1

; write padding bytes 0xEF 0x11.
; length is streamlength - contentlength - ecclength (eg 134-98-26=10)

              dec   contentLen          ; revert the increase from the beginning of this routine
              sec
              lda   streamLength
              sbc   contentLen
              sbc   eccLength
              sbc   #2                  ; minus 2 because of mode-byte and length-byte
              beq   @sk2                ; if length of padding bytes is zero, skip this part.
              sta   z_counter2          ; store padding length in counter

@bk2          lda   #$ec                ; FIXME: EF or EC ???
              sta   (z_location),y
              iny
              dec   z_counter2
              beq   @sk2
              lda   #$11
              sta   (z_location),y
              iny
              dec   z_counter2
              bne   @bk2

;           @ finally, write one zero byte
@sk2          lda   #0
              sta   (z_location),y
;           @ iny NOTE: not needed?
              sta   z_counter1          ; z_counter1 is used by the next routine (ecc-calculation) to have the right write-offset
              rts
              .)

; write upper nybble of current value to lower nybble of current stream-byte
; so we need to OR  the current value with the current stream-byte
writeToStream .(
              pha
              lsr
              lsr
              lsr
              lsr
              ora   z_temp
              ldy   z_counter1
              sta   (z_location),y
              iny
              sty   z_counter1
              pla
              asl
              asl
              asl
              asl
              sta   z_temp
              rts
              .)

; ---------------------------------------------------------------------------
; reed-solomon error correction calculation for use in qr-codes
; writes the resulting ecc bytes directly into the right memory position
; ---------------------------------------------------------------------------
; "qr/rs.s"
; ---------------------------------------------------------------------------
; reads content bytes from datastream (z_location) and writes ecc bytes to
; z_location2(=z_location + z_counter1)
rs            .(
              jsr   set_location_datastream

              clc
              lda   z_location          ; z_location is where we`re reading from (start of datastream)
              adc   streamLength
              sta   z_location2         ; z_location2 is where we`re writing to (ecc position in datastream)

              lda   z_location+1
              adc   #0
              sta   z_location2+1

              sec
              lda   z_location2
              sbc   eccLength
              sta   z_location2
              bcs   @sk1

              dec   z_location2

;           @ clear result area
@sk1          ldy   eccLength
              lda   #0
@lp1          sta   (z_location2),y
              dey
              bpl   @lp1

;           @ ldy #datastream_end-datastream
              sec
              lda   streamLength
              sbc   eccLength
              sta   z_counter2

              ldy   #0
              sty   z_counter1

rsremainder
              ldy   z_counter1
              lda   (z_location),y

              ldx   #0
              eor   (z_location2,x)
              sta   rsfactor

              ldy   #0
;           @ remove first element from result-array
              ldx   eccLength
              dex
@lp2          iny
              lda   (z_location2),y
              dey
              sta   (z_location2),y
              iny

              dex
              bpl   @lp2

;           @ add zero to last position
              lda   #0
              sta   (z_location2),y

              ldx   eccLength
              stx   loopc

              ldy   #0
              ldx   rsDivisorOfs

@lp3          lda   rsdivisors,x
              sta   divisor

              jsr   rsmultiply

              eor   (z_location2),y
              sta   (z_location2),y

              inx
              iny
              dec   loopc
              bne   @lp3

              dec   z_counter2
              beq   @fin

              inc   z_counter1
              jmp   rsremainder

@fin          rts
              .)

;           @ xreg=factor, acc=divisor (y in basic)
rsmultiply    .(
              stx   rsmulx
              sty   rsmuly
              lda   #0
              sta   rsmulres
              ldy   #7
@loop         clc
              asl
              sta   rsmul1              ; B in the Basic implementation
              bcc   @sk1
              inc   rsmul1+1
@sk1          lda   rsmulres            ; R in the Basic implementation
              and   #128
              cmp   #128                ; C=INT(R/128)
              bne   @sk2
;           @ c=c*285
              lda   #$1d
              sta   rsmul2
              lda   #$01
              sta   rsmul2+1
              jmp   @sk3
@sk2          sta   rsmul2
              sta   rsmul2+1
;           @ r=xor(b,c)
@sk3          lda   rsmul1
              eor   rsmul2
              sta   rsmulres
;           @ factor >>> i
              tya
              tax
              lda   rsfactor
              cpx   #0
              beq   @sk4
@bk1          lsr
              dex
              bne   @bk1
;           @ B=B AND 1
@sk4          and   #1
              sta   rsmul1
              beq   @sk5
              lda   divisor
;           @ B=B*X
@sk5          sta   rsmul1
;           @ R=XOR(R,B) AND 255
              eor   rsmulres
              sta   rsmulres
              dey
              bpl   @loop
              ldx   rsmulx
              ldy   rsmuly
              rts
              .)

; ---------------------------------------------------------------------------
; "stream2module.s" - writes the bytes of the datastream into the matrix
; ---------------------------------------------------------------------------
; procedure:
; - read bit by bit from datastream bytes
; - after each written bit (1=dark, 0=light), advance the write index
;   in a zig-zag pattern
; - column 6 is always excluded and holds no information, as it only holds
;   the administrative patterns
; variables needed:
; - writeIndex. starts at right-bottom corner (eg 1368 in a 0-based array).
;   each module is a full byte
; - current write direction. can be up or down
; - current column index
; ---------------------------------------------------------------------------
; z_location is matrix
; z_location2 is datastream
stream_to_module .(
;             lda   #0          NOTE: optimized
;             sta   m_endAdr    NOTE: optimized
;             sta   m_endAdr+1  NOTE: optimized

              lda   #>_qr_data
              sta   m_startAdr+1
              sta   z_location2+1
              lda   #<_qr_data
              sta   m_startAdr
              sta   z_location2

              clc
;             lda   z_location2 NOTE: optimized
              adc   matrixLen
              sta   z_location2
              sta   z_location
              sta   m_endAdr

; FIXME: why?
;               bcc   @sk1
;               inc   z_location2+1
;               clc
; @sk1

              lda   z_location2+1
              adc   matrixLen+1
              sta   z_location2+1
              sta   z_location+1
              sta   m_endAdr+1

              jsr   dec_location_by_1
              ldx   matrixSz
              dex
              stx   m_curCol

              lda   #1                  ; direction 1=up, 0=down
              sta   m_writeDir

; walk over bytes of datastream,
; split them into bits and write these as modules
              ldy   #0
              sty   z_counter1

@lpo          ldx   #128
              stx   z_temp              ; use for bit-comparison and shift left
@lpi          ldy   z_counter1

              lda   (z_location2),y
              bit   z_temp
              beq   @sk2
              lda   #%01000001          ; bit 6 set means data-module. bit 0 set means dark module
              jmp   @sk3
@sk2          lda   #%01000000          ; bit 6 means data-module. bit 0 clear means light module
@sk3          jsr   writeAndAdvance
              lsr   z_temp
              bne   @lpi
              ldy   z_counter1
              iny
              sty   z_counter1
              cpy   streamLength
              bne   @lpo
              rts
              .)

; writes the accumulator to the current write offset and then calculates the next offset position
writeAndAdvance .(
;           @ temp-store new value of matrix-field
              sta   z_counter2
;           @ load current value of matrix-field into Acc
              ldy   #0
              lda   (z_location),y
;           @ OR the values
              ora   z_counter2
              and   #$7f
;           @ store the value in the matrix
              sta   (z_location),y
;           @ where are we in relation to column 6? (col 6 is skipped and it changes even-odd behavior of offset pos calc)
              lda   m_curCol
              cmp   #6
              bcc   @advLt6             ; else: col is lower than 6

; do we advance in a column > 6 or <= 6?

@advGt6       bit   m_one
              beq   advWriteIdx1        ; even columns go left first
              bne   advWriteIdx2        ; odd columns go diagonal up or down next

@advLt6       bit   m_one
              beq   advWriteIdx2        ; even columns go left first
              bne   advWriteIdx1        ; odd columns go diagonal up or down next
              .)

do_indfet     .(
              ldy   #0
              lda   (z_location),y
              bit   m_128
              rts
              .)

; go one column to the left. that`s -1 in the matrix and -1 for col
advWriteIdx1  .(
              jsr   dec_location_by_1
              dec   m_curCol

; check value of the new output location.
; if it`s not 128, it`s occupied already and we need to keep advancing
              jsr   do_indfet
;             bit   m_128 NOTE: moved above optimized
              beq   advWriteIdx2
              rts
              .)

; advance diagonal. makes a difference whether we go up or down
advWriteIdx2  .(
              lda   m_writeDir
              bit   m_one
              bne   advUp
              jmp   advDown
              .)

advUp         .(
;           @ move one row up and one module to the right
;           @ z_location2=z_location2-matrixSz+1
              jsr   dec_line
              jsr   inc_location_by_1

; check if we moved outside of the matrix (ie went to before the first row).
; if output < m_startAdr: change direction
              lda   z_location+1
              cmp   m_startAdr+1
              bcc   changeDirectionToDown; WARNING: NOTE: was beq only
              beq   @sk1
              jmp   endAdvWriteIdx2
@sk1          lda   z_location
              cmp   m_startAdr
              bcc   changeDirectionToDown
              .)

;           @ not changing direction. update col and check if new location is occupied

endAdvWriteIdx2 .(
              inc   m_curCol
              jsr   do_indfet
;           @ 128 means, new location is free to write
;             bit   m_128 NOTE: moved above optimized
              beq   advWriteIdx1
;           @ new location not occupied. we`re done.
              rts
              .)

changeDirectionToDown .(
;           @ W=W+L-2:D=0:C=C-2
              jsr   inc_line
              sec
              sbc   #2
              sta   z_location
              bcs   @sk1
              dec   z_location+1
;           @ write new direction
@sk1          lda   #0
              sta   m_writeDir
;           @ update column information
              dec   m_curCol
              dec   m_curCol
              jmp   endAdvWriteIdx2
              .)

advDown       .(
;           @ move one row down and one module to the right
;           @ W=W+L+1
              jsr   inc_line
              jsr   inc_location_by_1

; check if we moved outside of the matrix (ie went to past the last row).
; if output > m_endAdr: change direction

              lda   z_location+1
              cmp   m_endAdr+1
              beq   @sk1
              bcs   changeDirectionToUp ; WARNING: NOTE: was beq only
              jmp   endAdvWriteIdx2
@sk1          lda   z_location
              cmp   m_endAdr
              bcs   changeDirectionToUp
              jmp   endAdvWriteIdx2
              .)

changeDirectionToUp .(
;           @ W=W-L-2:D=-1:C=C-2
              jsr   dec_line
              sec
              sbc   #2
              sta   z_location
              bcs   @sk1
              dec   z_location+1
@sk1          lda   #1
              sta   m_writeDir
              dec   m_curCol
              dec   m_curCol
              jmp   endAdvWriteIdx2
              .)

; ---------------------------------------------------------------------------
; this writes timing, alignment, finder patterns etc.
#include "qr/patterns.s"

; ---------------------------------------------------------------------------
; this clears the matrix memory area and calculates all the xor-masks
#include "qr/masks.s"

; ---------------------------------------------------------------------------
#include "qr/render.s"
; #include "qr/render2.s"
; #include "qr/renderspr.s"

; ---------------------------------------------------------------------------
.data
; ---------------------------------------------------------------------------
contentLen    byt   0                   ; size of the provided URL
matrixSz      byt   0                   ; size of one axis-length of the final matrix
matrixLen     wrd   0                   ; size of the matrix in modules (1 byte per module)
eccLength     byt   0                   ; nr of ecc bytes to generate
streamLength  byt   0
rsDivisorOfs  byt   0

; ---------------------------------------------------------------------------
m_bit         byt   0
m_one         byt   1
m_maskbit     byt   2
m_64          byt   64
m_128         byt   128
m_l3          wrd   0
m_writeOfs    byt   0

; ; ---------------------------------------------------------------------------
m_writeDir    byt   0                   ; are we moving up or down when writing modules. 1=up, 0=down
m_startAdr    wrd   0                   ; absolute address of where the matrix starts. used for comparisons
m_endAdr      wrd   0                   ; absolute address of where the matrix ends. used for comparisons
m_curCol      byt   0                   ; current column to be written to

; ---------------------------------------------------------------------------
m_xpos        byt   0
m_ypos        byt   0

; ---------------------------------------------------------------------------
divisor       byt   0                   ; current divisor
rsfactor      byt   0
rsmulres      byt   0                   ; result of rs-multiply -5x
rsmul1        wrd   0                   ; rs-multiply temp var  -5xx
rsmul2        wrd   0                   ; rs-multiply temp var  - 5xx
loopc         byt   0                   ; loop counter in rsremainder for the loop that contains rsmultiply
rsmulx        byt   0                   ; store and recover x-reg here when calling rsmultiply
rsmuly        byt   0                   ; store and recover y-reg here when calling rsmultiply

; ---------------------------------------------------------------------------
; version 1
rsdivisors    byt   127,122,154,164,11,68,117

; version 2
              byt   216,194,159,111,199,94,95,113,157,193

; version 3
#if max_version > 2
              byt   29,196,111,163,112,74,10,105,105,139,132,151,32,134,26
#endif

; version 4
#if max_version > 3
              byt   $98,$B9,$F0,$05,$6F,$63,$06,$DC,$70,$96,$45,$24,$BB,$16,$E4,$C6
              byt   $79,$79,$A5,$AE
#endif

; version 5
#if max_version > 4
              byt   $F6,$33,$B7,$04,$88,$62,$C7,$98,$4D,$38,$CE,$18,$91,$28,$D1,$75
              byt   $E9,$2A,$87,$44,$46,$90,$92,$4D,$2B,$5E
#endif

; ---------------------------------------------------------------------------
.data
; ---------------------------------------------------------------------------
_qr_data      dsb   $05E0

