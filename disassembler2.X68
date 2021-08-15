*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
FIRSTNUM    LEA         INTRO,A1        ; load intro message into A1
            MOVE.B      #14,D0          ; move the number 14 to D0
            TRAP        #15             ; display the intro message in the console
            MOVE.B      #2,D0           ; move the number 2 to D0
            TRAP        #15             ; read a string from the keyboard and store at (A1)
            BRA         HEX             ; branch to part of code that converts string to hex
            
PRESECNUM   MOVE.L      D2,BEGIN        ; move converted input to BEGIN
            MOVE.L      D2,CURR         ; set curr to begin
            CLR.L       D2              ; clear out D2

SECONDNUM   LEA         INTRO2,A1       ; load message asking for second number into A1
            MOVE.B      #14,D0          ; move the number 14 to D0
            TRAP        #15             ; display the intro message in the console
            MOVE.B      #2,D0           ; move the number 2 to D0
            TRAP        #15             ; read a string from the keyboard and store at (A1)

HEX         ADD.B       #1,D3           ; add 1 to D3 - use to keep track of whether on first or second user input
            MOVE.B      #8,D4           ; set D4 to 8
            
LETTER      CMP.B       #0,D4           ; use D4 to keep track of where in input you're at
            BEQ         CHECK           ; branch to checking validity of input if entire input taken
            SUBI.B      #1,D4           ; subtract 1 from D4 to keep track of number of loops
            MOVE.B      (A1)+,D1        ; move next part of A1 to D1
            CMP.B       #$39,D1         ; compare $39 to D1 to see if 1-9
            BGT         HEXA            ; if greater branch to hexa
            ADD.B       #$D0,D1         ; add #$D0 to D1 to cancel out 30
            BRA         COMBINE         ; skip to combining step
            
HEXA        CMP.B       #$42,D1         ; compare 42 to D1
            BGE         HEXB
            MOVE.B      #$0A,D1         ; replace with 0A
            BRA         COMBINE         ; skip to combining step
            
HEXB        CMP.B       #$43,D1         ; compare 43 to D1
            BGE         HEXC
            MOVE.B      #$0B,D1         ; replace with 0B
            BRA         COMBINE
            
HEXC        CMP.B       #$44,D1         ; compare 44 to D1
            BGE         HEXD
            MOVE.B      #$0C,D1         ; replace with 0C
            BRA         COMBINE
            
HEXD        CMP.B       #$45,D1         ; compare 45 to D1
            BGE         HEXE
            MOVE.B      #$0D,D1         ;replace with 0D
            BRA         COMBINE
            
HEXE        CMP.B       #$46,D1         ; compare 46 to D1
            BGE         HEXF
            MOVE.B      #$0E,D1         ; replace with 0E
            BRA         COMBINE
            
HEXF        MOVE.B      #$0F,D1         ; replace with 0F
            BRA         COMBINE         ; branch back to beginning of loop to check if done
            
COMBINE     ASL.L       #4,D2           ; move D2 2 digits to the left
            ADD.B       D1,D2           ; add byte of data from D1 to D2
            
            BRA         LETTER          ; branch back to beginning of loop
            
ENDCHECK    CMP.B       #1,D3           ; compare D3 to 1 to see which number we're on
            BLE         PRESECNUM       ; branch back to get second user input
            MOVE.L      D2,END          ; move converted input to END
            BRA         NEXT            ; branch to next when done
            
CHECK       ; if time permits, code to check for bad input should go here
            BRA         ENDCHECK        ; if okay, go back to ENDCHECK
            ; else if time permits, should add specific error message to print if bad
            CMP.B       #1,D3           ; compare D1 to 1 to see which number we're on
            BEQ         FIRSTNUM        ; then go back to asking for first number if on that one
            BRA         SECONDNUM       ; or go back to asking for second number if on that one
            
NEXT        MOVE.L      CURR,D6         ; move curr to D6 in order to compare with end
            MOVE.L      END,D7          ; move end to D7 in order to compare with curr
            CMP.L       D7,D6           ; compare current address to end address
            BGT         DONE
            ; need to increment curr by opcode + EA - maybe save that amount in a variable or register since it changes each time
            CLR.L       D0              ; clear D0
            CLR.L       D1              ; clear D1
            CLR.L       D2              ; clear D2
            CLR.L       D3              ; clear D3
            CLR.L       D4              ; clear D4
            CLR.L       D5              ; clear D5
            CLR         (A2)+           ; clear (A2)+
            MOVE.L      CURR,A1         ; move curr to A1
            MOVE.L      (A1),D0         ; move A1's address's contents to D0
            MOVE.B      #4,D4           ; move #4 to D4 to keep track
            JSR         ASCII           ; translate to ASCII
            BRA         OPCODE          ; skip to opcode
            
ASCII       CMP.B       #0,D4           ; use D4 to keep track of where in input you're at
            BEQ         OPCODE          ; branch to translating opcode if all of address translated
            SUBI.B      #1,D4           ; subtract 1 from D4 to keep track of number of loops (need 8 - 1 for each hex digit)
            ROL.L       #4,D0           ; rotate D0 4 bits to the left to bring leftmost bits far right
            MOVE.B      D0,D1           ; move D0 to D1
            AND.B       #$0F,D1         ; get rid of 4/8 bits, leaving just four rightmost bits
            CMP.B       #$09,D1         ; compare $9 to D1 to see if 1-9
            BGT         ASCIIA          ; if greater branch to hexa
            ADD.B       #$30,D1         ; add #$30 to D1 to convert to ASCII
            BRA         TOBUFFER        ; skip to adding to buffer
            
ASCIIA      CMP.B       #$0A,D1         ; compare $A to D1
            BGE         ASCIIB          ; go to ASCIIB if bigger
            MOVE.B      #$41,D1         ; replace $A with $41
            BRA         TOBUFFER        ; skip to adding to buffer
            
ASCIIB      CMP.B       #$0B,D1         ; compare $B to D1
            BGE         ASCIIC          ; go to ASCIIC if bigger
            MOVE.B      #$42,D1         ; replace $B with $42
            BRA         TOBUFFER        ; skip to adding to buffer
            
ASCIIC      CMP.B       #$0C,D1         ; compare $C to D1
            BGE         ASCIID          ; go to ASCIID if bigger
            MOVE.B      #$43,D1         ; replace $C with $43
            BRA         TOBUFFER        ; skip to adding to buffer
            
ASCIID      CMP.B       #$0D,D1         ; compare $D to D1
            BGE         ASCIIE          ; go to ASCIIE if bigger
            MOVE.B      #$44,D1         ; replace $D with $44
            BRA         TOBUFFER        ; skip to adding to buffer
            
ASCIIE      CMP.B       #$0E,D1         ; compare $E to D1
            BGE         ASCIIF          ; go to ASCIIF if bigger
            MOVE.B      #$45,D1         ; replace $E with $45
            BRA         TOBUFFER        ; skip to adding to buffer
            
ASCIIF      MOVE.B      #$46,D1         ; replace $F with $46
            BRA         TOBUFFER        ; skip to adding to buffer
            
; change this to print as you go instead of adding to buffer?
TOBUFFER    MOVE.B      D1,(A2)+        ; move to buffer
            BRA         ASCII           ; branch back to translate other hex digits if any
            
TRANSLATED  RTS                         ; RTS after everything translated to ASCII

OPCODE      ROL.L       #8,D0           ; rotate first 8 bits of op-code to far right
            MOVE.B      D0,D1           ; move right-most 8 bits of D0 to D1
            LSR.L       #4,D1           ; now D1 is the isolated first 4 bits of the opcode
            ROR.L       #8,D0           ; rotate D0 back to how it was originally
            
            CMP.B       #$0,D1          ; compare D1 to 0000
            BEQ         CODE0000        ; branch to code0000 if equal
            
            CMP.B       #$1,D1          ; compare D1 to 0001
            BEQ         CODE0001        ; branch to code0001 if equal
            
            CMP.B       #$2,D1          ; compare D1 to 0010
            BEQ         CODE0010        ; branch to code0010 if equal
            
            CMP.B       #$3,D1          ; compare D1 to 0011
            BEQ         CODE0011        ; branch to code0011 if equal
            
            CMP.B       #$4,D1          ; compare D1 to 0100
            BEQ         CODE0100        ; branch to code0100 if equal
            
            CMP.B       #$5,D1          ; compare D1 to 0101
            BEQ         CODE0101        ; branch to code0101 if equal
            
            CMP.B       #$6,D1          ; compare D1 to 0110
            BEQ         CODE0110        ; branch to code0110 if equal
            
            CMP.B       #$7,D1          ; compare D1 to 0111
            BEQ         CODE0111        ; branch to code0111 if equal
            
            CMP.B       #$8,D1          ; compare D1 to 1000
            BEQ         CODE1000        ; branch to code1000 if equal
            
            CMP.B       #$9,D1          ; compare D1 to 1001
            BEQ         CODE1001        ; branch to code1001 if equal
            
            CMP.B       #$A,D1          ; compare D1 to 1010
            BEQ         CODE1010        ; branch to code1010 if equal
            
            CMP.B       #$B,D1          ; compare D1 to 1011
            BEQ         CODE1011        ; branch to code1011 if equal
            
            CMP.B       #$C,D1          ; compare D1 to 1100
            BEQ         CODE1100        ; branch to code1100 if equal
            
            CMP.B       #$D,D1          ; compare D1 to 1101
            BEQ         CODE1101        ; branch to code1101 if equal
            
            CMP.B       #$E,D1          ; compare D1 to 1110
            BEQ         CODE1110        ; branch to code1110 if equal
            
            BRA         CODE1111        ; branch to code1111
            
CODE0000    BRA         UNKNOWN         ; not a known opcode

CODE0001    ; code is MOVE.B
            MOVE.L      D0,D1           ; move D0 to D1 to copy
            MOVE.L      D0,D2           ; move D0 to D2 to copy
            MOVE.L      D0,D3           ; move D0 to D3 to copy
            CLR.L       D5
            LEA         MOVEB_DISPLAY,A1
            JSR         PRINT
            LEA         PRINT_TAB,A1
            JSR         PRINT
            ROR.L       #$2,D1          ; rotate two bits right
            ROR.L       #$1,D1          ; rotate one more bit right
            AND.B       #$7,D1          ; mask leftmost bit of rightmost byte of D1
            CMP.B       #$0,D1          ; compare binary 000 to D1
            BEQ         MOVEB_DN_MODE     ; go to MOVEB_DN_MODE
            CMP.B       #$1,D1          ; compare binary 001 to D1
            BEQ         MOVEB_AN_MODE         ; go to MOVEB_AN_MODE
            CMP.B       #$2,D1          ; compare binary 010 to D1
            BEQ         MOVEB_AN_P_MODE       ; go to MOVEB_AN_P_MODE
            CMP.B       #$3,D1          ; compare binary 011 to D1
            BEQ         MOVEB_AN_P_P_MODE     ; go to MOVEB_AN_P_P_MODE
            CMP.B       #$4,D1          ; compare binary 100 to D1
            BEQ         MOVEB_AN_P_M_MODE     ; go to MOVEB_P_M_MODE
            BRA         MOVEB_OTHER_MODE      ; go to MOVEB_OTHER_MODE
MOVEB_DEST  LEA         PRINT_COMMA,A1  ; print comma
            MOVE.B      #$1,D5          ; keep track of whether on source or destination
            JSR         PRINT
            MOVE.L      D3,D1           ; move D3 to D1 to copy
            MOVE.L      D3,D2           ; move D3 to D1 to copy
            ROR.L       #$4,D1          ; getting source mode
            ROR.L       #$2,D1
            AND.B       #$7,D1
            ROR.L       #$8,D2          ; getting source register
            ROR.L       #$1,D2 
            AND.B       #$7,D2
            CMP.B       #$0,D1          ; compare binary 000 to D1
            BEQ         MOVEB_DN_MODE     ; go to MOVEB_DN_MODE
            CMP.B       #$1,D1          ; compare binary 001 to D1
            BEQ         MOVEB_AN_MODE         ; go to MOVEB_AN_MODE
            CMP.B       #$2,D1          ; compare binary 010 to D1
            BEQ         MOVEB_AN_P_MODE       ; go to MOVEB_AN_P_MODE
            CMP.B       #$3,D1          ; compare binary 011 to D1
            BEQ         MOVEB_AN_P_P_MODE     ; go to MOVEB_AN_P_P_MODE
            CMP.B       #$4,D1          ; compare binary 100 to D1
            BEQ         MOVEB_AN_P_M_MODE     ; go to MOVEB_P_M_MODE
            BRA         MOVEB_OTHER_MODE      ; go to MOVEB_OTHER_MODE    

MOVEB_DN_MODE   JSR     DN_MODE
                CMP.B   #$1,D5
                BEQ     NEXT
                BRA     MOVEB_DEST

MOVEB_AN_MODE   JSR     AN_MODE
                CMP.B   #$1,D5
                BEQ     NEXT
                BRA     MOVEB_DEST

MOVEB_AN_P_MODE JSR     AN_P_MODE
                CMP.B   #$1,D5
                BEQ     NEXT
                BRA     MOVEB_DEST

MOVEB_AN_P_P_MODE   JSR AN_P_P_MODE
                    CMP.B   #$1,D5
                    BEQ     NEXT
                    BRA MOVEB_DEST

MOVEB_AN_P_M_MODE   JSR AN_P_M_MODE
                    CMP.B   #$1,D5
                    BEQ     NEXT
                    BRA MOVEB_DEST

MOVEB_OTHER_MODE    ; still need to do this part
            
            
DN_MODE     AND.B       #$7,D2          ; mask leftmost bit of rightmost byte of D2
            CMP.B       #$0,D2          ; compare binary 000 to D2
            BEQ         DN_0            ; go to DN_0
            CMP.B       #$1,D2          ; compare binary 001 to D2
            BEQ         DN_1            ; go to DN_1
            CMP.B       #$2,D2          ; compare binary 010 to D2
            BEQ         DN_2            ; go to DN_2
            CMP.B       #$3,D2          ; compare binary 011 to D2
            BEQ         DN_3            ; go to DN_3
            CMP.B       #$4,D2          ; compare binary 100 to D2
            BEQ         DN_4            ; go to DN_4
            CMP.B       #$5,D2          ; compare binary 101 to D2
            BEQ         DN_5            ; go to DN_5
            CMP.B       #$6,D2          ; compare binary 110 to D2
            BEQ         DN_6            ; go to DN_6
            CMP.B       #$7,D2          ; compare binary 111 to D2
            BEQ         DN_7            ; go to DN_7
            
DN_0        LEA         D0_DISPLAY,A1   ; load message
            JSR         PRINT
            RTS

DN_1        LEA         D1_DISPLAY,A1   ; load message
            JSR         PRINT
            RTS

DN_2        LEA         D2_DISPLAY,A1   ; load message
            JSR         PRINT
            RTS

DN_3        LEA         D3_DISPLAY,A1
            JSR         PRINT
            RTS

DN_4        LEA         D4_DISPLAY,A1
            JSR         PRINT
            RTS

DN_5        LEA         D5_DISPLAY,A1
            JSR         PRINT
            RTS

DN_6        LEA         D6_DISPLAY,A1
            JSR         PRINT
            RTS

DN_7        LEA         D7_DISPLAY,A1
            JSR         PRINT
            RTS

AN_MODE     AND.B       #$7,D2          ; mask leftmost bit of rightmost byte of D2
            CMP.B       #$0,D2          ; compare binary 000 to D2
            BEQ         AN_0            ; go to AN_0
            CMP.B       #$1,D2          ; compare binary 001 to D2
            BEQ         AN_1            ; go to AN_1
            CMP.B       #$2,D2          ; compare binary 010 to D2
            BEQ         AN_2            ; go to AN_2
            CMP.B       #$3,D2          ; compare binary 011 to D2
            BEQ         AN_3            ; go to AN_3
            CMP.B       #$4,D2          ; compare binary 100 to D2
            BEQ         AN_4            ; go to AN_4
            CMP.B       #$5,D2          ; compare binary 101 to D2
            BEQ         AN_5            ; go to AN_5
            CMP.B       #$6,D2          ; compare binary 110 to D2
            BEQ         AN_6            ; go to AN_6
            CMP.B       #$7,D2          ; compare binary 111 to D2
            BEQ         AN_7            ; go to AN_7
            
AN_0        LEA         A0_DISPLAY,A1   ; load message
            JSR         PRINT
            RTS

AN_1        LEA         A1_DISPLAY,A1   ; load message
            JSR         PRINT
            RTS

AN_2        LEA         A2_DISPLAY,A1   ; load message
            JSR         PRINT
            RTS

AN_3        LEA         A3_DISPLAY,A1
            JSR         PRINT
            RTS

AN_4        LEA         A4_DISPLAY,A1
            JSR         PRINT
            RTS

AN_5        LEA         A5_DISPLAY,A1
            JSR         PRINT
            RTS

AN_6        LEA         A6_DISPLAY,A1
            JSR         PRINT
            RTS

AN_7        LEA         A7_DISPLAY,A1
            JSR         PRINT
            RTS          

AN_P_MODE   LEA     PRINT_LPAR,A1       ; load string to print left paren
            JSR     PRINT
            JSR     AN_MODE             ; print address register between parens
            LEA     PRINT_RPAR,A1       ; load string to print right paren
            JSR     PRINT
            RTS

AN_P_P_MODE LEA PRINT_LPAR,A1
            JSR PRINT
            JSR AN_MODE
            LEA PRINT_RPAR,A1
            JSR PRINT
            LEA PRINT_PLUS,A1
            JSR PRINT
            RTS

AN_P_M_MODE LEA PRINT_MINUS,A1
            JSR PRINT
            LEA PRINT_LPAR,A1
            JSR PRINT
            JSR AN_MODE
            LEA PRINT_RPAR,A1
            JSR PRINT
            RTS

OTHER_MODE  ; still need to do this part

CODE0010    ; code is MOVE.L or MOVEA.L
            ; need to distinguish between MOVE.L and MOVEA.L?! they're both 0010
            MOVE.W  D0,D5   ; move first half of opcode to D5
            LSL.W   #4,D5   ; logical shift left 4 values over 
            CMP.W   #$001,D5
            BEQ MOVEAL_BRA
            ; if not MOVEA.L, then it's MOVE.L?
            LEA MOVEL_DISPLAY,A6
            JSR PRINT
            ; use AN_MODE / DN_MODE / etc. subroutines up above to save time/effort
            
MOVEAL_BRA   ;MOVEA BRANCH
            CLR D5 ; clear D5
            LEA MOVEAL_DISPLAY,A6
            JSR PRINT
            ; use AN_MODE / DN_MODE / etc. subroutines up above to save time/effort

CODE0011    ; code is MOVE.W or MOVEA.W
            MOVE.W  D0,D5
            LSL.W   #4,D5
            CMP.W   #$001,D5
            BEQ MOVEAW_BRA
            LEA MOVEW_DISPLAY,A6
            JSR PRINT
            ; use AN_MODE / DN_MODE / etc. subroutines up above to save time/effort
            
MOVEAW_BRA  ; move.w branch
            CLR D5
            LEA MOVEAW_DISPLAY,A6
            JSR PRINT
            ; use AN_MODE / DN_MODE / etc. subroutines up above to save time/effort

CODE0100    ; code is LEA or NOT or RTS or JSR or NOP or MOVEM
            MOVE.W  D0,D5
            LSL.W   #4,D5
            CMP.W   #$111,D5
            BEQ LEA_BRA
            CMP.W   #$0110,D5
            BEQ NOT_BRA
            CMP.W   #$0101,D5
            BEQ RTS_BRA
            CMP.W   #$010,D5
            BEQ JSR_BRA
            CMP.W   #$0001,D5
            BEQ NOP_BRA
            ; if we reach the bottom, then we know opcode is MOVEM
            LSL #6,D5 ; want to compare size value of MOVEM
            CMP.B   #$00,D5
            BEQ MOVEM_W_BRA
            CMP.W   #$01,D5
            ; if we reach the bottom here, then we know opcdoe is MOVEM.L
            LEA MOVEM_L_DISPLAY,A6
            JSR PRINT
            ; use AN_MODE / DN_MODE / etc. subroutines up above to save time/effort
            
LEA_BRA     ; shouldn't these all be loaded into A1 instead of A6??
            LEA LEA_DISPLAY,A6
            JSR PRINT
            ; use AN_MODE / DN_MODE / etc. subroutines up above to save time/effort
            
NOT_BRA
            LEA NOT_DISPLAY,A6
            JSR PRINT
            
RTS_BRA     LEA RTS_DISPLAY,A6
            JSR PRINT

JSR_BRA
            LEA JSR_DISPLAY,A6
            JSR PRINT

NOP_BRA
            LEA NOP_DISPLAY,A6
            JSR PRINT

MOVEM_W_BRA
            LEA MOVEMW_DISPLAY,A6
            JSR PRINT 
            ; use AN_MODE / DN_MODE / etc. subroutines up above to save time/effort           

CODE0101    BRA         UNKNOWN         ; not a known opcode

CODE0110    ; code is BRA or BGT or BLE or BEQ
            MOVE.L  D0,D5
            LSL.L   #8,D5
            CMP.B   #$00,D5
            BEQ BRA_BRA
            CMP.W   #$1111,D5
            BEQ BLE_BRA
            CMP.W   #$1110,D5
            BEQ BGT_BRA
            ; if we make it all the way to the bottom, then we know that opcode is BEQ
            
BRA_BRA
            LEA BRA_DISPLAY,A6
            JSR PRINT

BLE_BRA
            LEA BLE_DISPLAY,A6
            JSR PRINT

BGT_BRA
            LEA BGT_DISPLAY,A6
            JSR PRINT

CODE0111    ; code is MOVEQ
            LEA MOVEQ_DISPLAY,A6
            JSR PRINT
            ; use AN_MODE / DN_MODE / etc. subroutines up above to save time/effort

CODE1000    ; code is OR
            LEA OR_DISPLAY,A6
            JSR PRINT

CODE1001    ; code is SUB

CODE1010    BRA         UNKNOWN         ; not a known opcode

CODE1011    BRA         UNKNOWN         ; not a known opcode

CODE1100    ; code is AND

CODE1101    ; code is ADD

CODE1110    ; comments for reference - can delete later after code is all written and tested
            ; code is ROR or ROL or ASR or ASL or LSR or LSL
            ; register: LSL - ???1, LSR - ???0 (2 size) (1 i/r) (01) (3 register)
            ; memory: LSL - 0011, LSR - 0010 (11) (3 mode) (3 register)
            ; register: ASL - ???1, ASR - ???0 (2 size) (1 i/r) (00) (3 register)
            ; memory: ASL - 0001, ASR - 0000 (11) (3 mode) (3 register)
            ; register: ROL - ???1, ROR - ???0 (2 size - 00 byte, 01 word, 10 long) (1 i/r) (11) (3 register)
            ; memory: ROL - 0111, ROR - 0110 (11)(3 mode)(3 register)
            ; if i/r = 0 -> ??? = rotate count (1-7, 0 = 8), if i/r = 1 -> ??? = data register that contains rotate count
            
            ; check digits 9 - 10 _ _ _ _ _ _ _ _ x x - if 11 then memory mode, check 4-8 _ _ _ _ x x x x (001x = LSx, 000x = ASx, 011x = ROx)
            ; if not then check 12 - 13 _ _ _ _ _ _ _ _ _ _ _ x x _ _ _ - if 01 then LSx, if 00 then ASx, if 11 then ROx
            
            MOVE.L      D0,D1           ; copy D0 over to D1
            ROR.L       #4,D1           ; rotate D1 4 to the right so memory mode indicator in last byte
;            LSR.L       #2,D1           ; shift 2 bits right to get rid of 2 bits on end
;            LSL.L       #2,D1           ; shift 2 bits left to replace them with 0s
;            CMP.B       #$C,D1          ; compare binary 1100 to last byte to see if memory mode
;            BEQ         MEMORY          ; branch to memory if equal

            MOVE.L      D0,D1           ; copy D0 over to D1
            AND.W       #$18,D1         ; mask all of last word but bits 12 and 13
            CMP.W       #$18,D1         ; compare binary 00011000 to last word
            BEQ         REG_ROX         ; go to REG_ROX
            CMP.W       #$08,D1         ; compare binary 00001000 to last word
            BEQ         REG_LSX         ; go to REG_LSX
            CMP.W       #$00,D1         ; compare binary 00000000 to last word
            BEQ         REG_ASX         ; go to REG_ASX
            BRA         UNKNOWN         ; go to UNKNOWN
            
REG_ROX     MOVE.L      D0,D1
            ROL.L       #8,D1           ; rotate D1 8 left to get left/right bit on end
            AND.L       #$0001,D1       ; mask all bits except end bit
            CMP.B       #$0,D1          ; compare end bit to 0
            BEQ         REG_ROR         ; go to REG_ROR
            BRA         REG_ROL         ; go to REG_ROL
            
REG_ROR     MOVE.L      D0,D1           ; move D0 to D1
            MOVE.L      D0,D2           ; move D0 to D1
            ROR.L       #6,D1           ; rotate size field to rightmost bits
            AND.B       #$3,D1          ; mask 2/4 bits of last byte so it's just size field
            CMP.B       #$0,D1          ; compare binary 00 to last byte
            BEQ         REG_RORB        ; go to display byte if equal
            CMP.B       #$1,D1          ; compare binary 01 to last byte
            BEQ         REG_RORW        ; go to display word if equal
            BRA         REG_RORL        ; if not then it's a long

REG_REST    LEA         PRINT_TAB,A1    ; prepare to print tab
            JSR         PRINT           ; print
            MOVE.L      D2,D1           ; move D2 to D1
            MOVE.L      D2,D3           ; move D2 to D3
            ROR.L       #8,D1           ; rotate 8 bits right so count/reg in 3/4 rightmost bits
            ROR.L       #1,D1           ; rotate one more bit right to be 3 leftmost
            AND.B       #$7,D1          ; mask leftmost bit of rightmost byte of D1 so only count/register readable
            ROR.L       #4,D3           ; rotate 4 bits right to get 0 _ for i/r in 2 rightmost bits
            AND.B       #$3,D3          ; mask two leftmost bits of rightmost byte
            CMP.B       #$2,D3          ; compare binary 10 to to D3
            CLR.B       D5
            BEQ         REG_REG         ; go to reg_reg if i/r is 1
            BRA         REG_VAL         ; go to reg_val if i/r is 0
            
REG_REG     CMP.B       #$0,D1          ; compare D1 to 000
            BEQ         REG_0           ; go to reg_0
            CMP.B       #$1,D1          ; compare D1 to 001
            BEQ         REG_1           ; go to reg_1
            CMP.B       #$2,D1          ; compare D1 to 010
            BEQ         REG_2           ; go to reg_2
            CMP.B       #$3,D1          ; compare D1 to 011
            BEQ         REG_3           ; go to reg_3
            CMP.B       #$4,D1          ; compare D1 to 100
            BEQ         REG_4           ; go to reg_4
            CMP.B       #$5,D1          ; compare D1 to 101
            BEQ         REG_5           ; go to reg_5
            CMP.B       #$6,D1          ; compare D1 to 110
            BEQ         REG_6           ; go to reg_6
            BRA         REG_7           ; go to reg_7
    
REG_0       LEA         D0_DISPLAY,A1   ; load D0 display
            JSR         PRINT
            BRA         REG_END

REG_1       LEA         D1_DISPLAY,A1   ; load D1 display
            JSR         PRINT
            BRA         REG_END

REG_2       LEA         D2_DISPLAY,A1   ; load D2 display
            JSR         PRINT
            BRA         REG_END

REG_3       LEA         D3_DISPLAY,A1   ; load D3 display
            JSR         PRINT
            BRA         REG_END

REG_4       LEA         D4_DISPLAY,A1   ; load D4 display
            JSR         PRINT
            BRA         REG_END

REG_5       LEA         D5_DISPLAY,A1   ; load D5 display
            JSR         PRINT
            BRA         REG_END

REG_6       LEA         D6_DISPLAY,A1   ; load D6 display
            JSR         PRINT
            BRA         REG_END

REG_7       LEA         D7_DISPLAY,A1   ; load D7 display
            JSR         PRINT
            BRA         REG_END

REG_VAL

REG_END     LEA         PRINT_COMMA,A1  ; load comma display
            JSR         PRINT
            MOVE.L      D2,D4           ; copy D2 to D4
            AND.B       #$7,D4          ; mask leftmost bit of rightmost byte
            ADD.B       #$1,D5          ; add $1 to D5 to keep track of loop
            CMP.B       #$1,D5          ; check to see if gone through loop once or twice
            BEQ         REG_REG         ; go to reg_reg
            ; not sure whether should go to EA or next, chose next for now
            BRA         NEXT         
                 
REG_RORB    LEA         RORB_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST
            
REG_RORW    LEA         RORW_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST      
       
REG_RORL    LEA         RORL_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST

REG_ROL     MOVE.L      D0,D1           ; move D0 to D1
            MOVE.L      D0,D2           ; move D0 to D1
            ROR.L       #6,D1           ; rotate size field to rightmost bits
            AND.B       #$3,D1          ; mask 2/4 bits of last byte so it's just size field
            CMP.B       #$0,D1          ; compare binary 00 to last byte
            BEQ         REG_ROLB        ; go to display byte if equal
            CMP.B       #$1,D1          ; compare binary 01 to last byte
            BEQ         REG_ROLW        ; go to display word if equal
            BRA         REG_ROLL        ; if not then it's a long
            
REG_ROLB    LEA         ROLB_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST
            
REG_ROLW    LEA         ROLW_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST      
       
REG_ROLL    LEA         ROLL_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST

REG_LSX     MOVE.L      D0,D1
            ROL.L       #8,D1           ; rotate D1 8 left to get left/right bit on end
            AND.L       #$0001,D1       ; mask all bits except end bit
            CMP.B       #$0,D1          ; compare end bit to 0
            BEQ         REG_LSR         ; go to REG_LSR
            BRA         REG_LSL         ; go to REG_LSL
            
REG_LSR     MOVE.L      D0,D1           ; move D0 to D1
            MOVE.L      D0,D2           ; move D0 to D1
            ROR.L       #6,D1           ; rotate size field to rightmost bits
            AND.B       #$3,D1          ; mask 2/4 bits of last byte so it's just size field
            CMP.B       #$0,D1          ; compare binary 00 to last byte
            BEQ         REG_LSRB        ; go to display byte if equal
            CMP.B       #$1,D1          ; compare binary 01 to last byte
            BEQ         REG_LSRW        ; go to display word if equal
            BRA         REG_LSRL        ; if not then it's a long
            
REG_LSRB    LEA         LSRB_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST
            
REG_LSRW    LEA         LSRW_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST      
       
REG_LSRL    LEA         LSRL_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST
            
REG_LSL     MOVE.L      D0,D1           ; move D0 to D1
            MOVE.L      D0,D2           ; move D0 to D1
            ROR.L       #6,D1           ; rotate size field to rightmost bits
            AND.B       #$3,D1          ; mask 2/4 bits of last byte so it's just size field
            CMP.B       #$0,D1          ; compare binary 00 to last byte
            BEQ         REG_LSLB        ; go to display byte if equal
            CMP.B       #$1,D1          ; compare binary 01 to last byte
            BEQ         REG_LSLW        ; go to display word if equal
            BRA         REG_LSLL        ; if not then it's a long
            
REG_LSLB    LEA         LSLB_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST
            
REG_LSLW    LEA         LSLW_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST      
       
REG_LSLL    LEA         LSLL_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST            

REG_ASX     MOVE.L      D0,D1
            ROL.L       #8,D1           ; rotate D1 8 left to get left/right bit on end
            AND.L       #$0001,D1       ; mask all bits except end bit
            CMP.B       #$0,D1          ; compare end bit to 0
            BEQ         REG_ASR         ; go to REG_ASR
            BRA         REG_ASL         ; go to REG_ASL
            
REG_ASR     MOVE.L      D0,D1           ; move D0 to D1
            MOVE.L      D0,D2           ; move D0 to D1
            ROR.L       #6,D1           ; rotate size field to rightmost bits
            AND.B       #$3,D1          ; mask 2/4 bits of last byte so it's just size field
            CMP.B       #$0,D1          ; compare binary 00 to last byte
            BEQ         REG_ASRB        ; go to display byte if equal
            CMP.B       #$1,D1          ; compare binary 01 to last byte
            BEQ         REG_ASRW        ; go to display word if equal
            BRA         REG_ASRL        ; if not then it's a long
            
REG_ASRB    LEA         ASRB_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST
            
REG_ASRW    LEA         ASRW_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST      
       
REG_ASRL    LEA         ASRL_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST           
    
REG_ASL     MOVE.L      D0,D1           ; move D0 to D1
            MOVE.L      D0,D2           ; move D0 to D1
            ROR.L       #6,D1           ; rotate size field to rightmost bits
            AND.B       #$3,D1          ; mask 2/4 bits of last byte so it's just size field
            CMP.B       #$0,D1          ; compare binary 00 to last byte
            BEQ         REG_ASLB        ; go to display byte if equal
            CMP.B       #$1,D1          ; compare binary 01 to last byte
            BEQ         REG_ASLW        ; go to display word if equal
            BRA         REG_ASLL        ; if not then it's a long
            
REG_ASLB    LEA         ASLB_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST
            
REG_ASLW    LEA         ASLW_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST      
       
REG_ASLL    LEA         ASLL_DISPLAY,A1 ; load corresponding address
            JSR         PRINT
            BRA         REG_REST
            
; not sure if we actually need to do this part of ROX/LSX/ASX so going to comment it out for now and possibly work on it later
;MEMORY      MOVE.L      D0,D1           ; copy D0 over to D1
;            ROR.L       #8,D1           ; rotate 8 bits right to isolate bits 4-8 in last byte
;            CMP.B       #$0,D1          ; compare binary 0000 to D1
;            BEQ         MEM_ASR         ; go to MEM_ASR
;            CMP.B       #$1,D1          ; compare binary 0001 to D1
;            BEQ         MEM_ASL         ; go to MEM_ASL
;            CMP.B       #$2,D1          ; compare binary 0010 to D1
;            BEQ         MEM_LSR         ; go to MEM_LSR
;            CMP.B       #$3,D1          ; compare binary 0011 to D1
;            BEQ         MEM_LSL         ; go to MEM_LSL
;            CMP.B       #$6,D1          ; compare binary 0110 to D1
;            BEQ         MEM_ROR         ; go to MEM_ROR
;            CMP.B       #$7,D1          ; compare binary 0111 to D1
;            BEQ         MEM_ROL         ; go to MEM_ROL
;            BRA         UNKNOWN         ; if not equal to any of those then not a known opcode

;MEM_ASR     MOVE.L      D0,D1           ; move D0 to D1
            
;MEM_ASL     MOVE.L      D0,D1           ; move D0 to D1

;MEM_LSR     MOVE.L      D0,D1           ; move D0 to D1

;MEM_LSL     MOVE.L      D0,D1           ; move D0 to D1

;MEM_ROR     MOVE.L      D0,D1           ; move D0 to D1

;MEM_ROL     MOVE.L      D0,D1           ; move D0 to D1

CODE1111    BRA         UNKNOWN         ; not a known opcode

UNKNOWN     LEA         DATA_DISPLAY,A1 ; load DATA into A1
            JSR         PRINT
            ; print some kind of tab for spacing
            MOVE.B      #4,D4           ; add 4 to D4 to go through ASCII loop 4x
            MOVE.L      CURR,A1         ; move curr to A1
            MOVE.L      (A1),D0         ; move data at A1's address to curr
            JSR         ASCII           ; go to ASCII loop to translate code to ASCII and add them to (A2)+
            ; possibly need to add newline (CR,LF) as well
            JSR         PRINT              ; branch to print unknown line

EA          ; need to find EA (if any, need to convert rest of memory if any to hex too), add to (A2)+ after converting back to ascii, increment CURR by corresponding amount for opcode + EA
            MOVEM.L D0-D7/A0-A6,-(SP)   ; move registers to stack pointer
            MOVE.W      #00,-(SP)       ; move #00 to -(SP)
            MOVE.W      #$f0,D2         ; move #$f0 to D2
            AND.W       D1,D2           ; AND opcode on D1 and D2
            ASR.W       #4,D2           ; arithematic shift right 4 values on D2
            JSR         CHECK_NUM_ASCII ; jump subroutine to CHECK_NUM_ASCII
            ASL.W       #8,D2           ; arithematic shift left 8 values to D2
            AND.W       #$F,D1          ; AND opcdoe on #$F and D1
            MOVE.B      D1,D2           ; move register D1 to D2
            JSR         CHECK_NUM_ASCII ; jump subroutine to CHECK_NUM_ASCII
            MOVE.W      D2, -(SP)       ; move data register D2 to -(SP)
            MOVE.L      SP,A1           ; move stack pointer to A1
            MOVE.B      #14,D0          ; move #14 to D0
            TRAP        #15             ; trap task #14
            MOVE.L      (SP)+,D5        ; move stack pointer to D5
            JSR         PRINT           ; branch to print results
            BRA         NEXT

          
CHECK_NUM_ASCII         CMP.B   #9,D2               ; checks for number/ascii
                        BGT     TO_LETTERS
                        ADD.B   #$30,D2             ; reverts number
                        RTS

TO_LETTERS              ADD.B   #$37,D2             ; reverts to letter
                        RTS 
                        
; listed below are symbols to print

TAB_PRINT   LEA PRINT_TAB,A1
            MOVE.B  #14,D0
            TRAP    #15
            RTS
            
DOLLAR_PRINT    LEA DOLLAR_DISPLAY,A1
                MOVE.B  #14,D0
                TRAP    #15
                RTS
                
POUND_PRINT LEA POUND_DISPLAY,A1
            MOVE.B  #14,D0
            TRAP    $15
            RTS
            
COMMA_PRINT LEA COMMA_DISPLAY,A1
            MOVE.B  #14,D0
            TRAP    #15
            RTS

LEFT_PARANTHESES_PRINT  LEA    LEFT_PARANTHESES,A1
                        MOVE.B  #14,D0
                        TRAP    #15
                        RTS
                        
RIGHT_PARANTHESES_PRINT LEA RIGHT_PARANTHESES,A1
                        MOVE.B  #14,D0
                        TRAP    #15
                        RTS

PLUS_PRINT  LEA PLUS_DISPLAY,A1
            MOVE.B  #14,D0
            TRAP    #15
            RTS
            
MINUS_PRINT LEA MINUS_DISPLAY,A1
            MOVE.B  #14,D0
            TRAP    #15
            RTS

            
PRINT       ; not sure yet whether to use #13 or #14 FOR TRAP #15
            MOVE.B      #14,D0          ; move #14 to D0 to print A1
            TRAP        #15             ; print contents of A1 (the contents of one line of memory)
            RTS
* Put program code here

    SIMHALT             ; halt simulator
CR          EQU         $0D             ; carriage return
LF          EQU         $0A             ; line feed
BEGIN       DS.L        1               ; reserve long for starting location
CURR        DS.L        1               ; reserve long for current location
END         DS.L        1               ; reserve long for ending location 
INTRO       DC.B        'Welcome to the MysteryHuskies 68k Disassembler!',CR,LF
            DC.B        'Please enter your desired starting location in 8 digit, upper-case hexadecimal: ',CR,LF,0
INTRO2      DC.B        'Thank you. Now please enter your desired ending location in 8 digit, upper-case hexadecimal: ',CR,LF,0

PRINT_TAB   DC.B    '   ',0
PRINT_COMMA DC.B    ',',0
PRINT_PLUS  DC.B    '+',0
PRINT_MINUS DC.B    '-',0
PRINT_LPAR  DC.B    '(',0
PRINT_RPAR  DC.B    ')',0
DATA_DISPLAY    DC.B    'DATA',0
MOVEB_DISPLAY   DC.B    'MOVE.B',0
MOVEW_DISPLAY   DC.B    'MOVE.W',0
MOVEL_DISPLAY   DC.B    'MOVE.L',0
MOVEAW_DISPLAY  DC.B    'MOVE.W',0
MOVEAL_DISPLAY   DC.B    'MOVEA.L',0
OR_DISPLAY  DC.B    'OR',0
LEA_DISPLAY DC.B    'LEA',0
NOT_DISPLAY DC.B    'NOT',0
RTS_DISPLAY DC.B    'RTS',0
JSR_DISPLAY DC.B    'JSR',0
NOP_DISPLAY DC.B    'NOP',0
MOVEMW_DISPLAY  DC.B    'MOVEM.W',0
MOVEM_L_DISPLAY DC.B    'MOVEM.L',0
BRA_DISPLAY DC.B    'BRA',0
BLE_DISPLAY DC.B    'BLE',0
BGT_DISPLAY DC.B    'BGT',0
MOVEQ_DISPLAY   DC.B    'MOVEQ',0
RORB_DISPLAY    DC.B    'ROR.B',0
ROLB_DISPLAY    DC.B    'ROL.B',0
RORW_DISPLAY    DC.B    'ROR.W',0
ROLW_DISPLAY    DC.B    'ROL.W',0
RORL_DISPLAY    DC.B    'ROR.L',0
ROLL_DISPLAY    DC.B    'ROL.L',0
LSRB_DISPLAY    DC.B    'LSR.B',0
LSLB_DISPLAY    DC.B    'LSL.B',0
LSRW_DISPLAY    DC.B    'LSR.W',0
LSLW_DISPLAY    DC.B    'LSL.W',0
LSRL_DISPLAY    DC.B    'LSR.L',0
LSLL_DISPLAY    DC.B    'LSL.L',0
ASRB_DISPLAY    DC.B    'ASR.B',0
ASLB_DISPLAY    DC.B    'ASL.B',0
ASRW_DISPLAY    DC.B    'ASR.W',0
ASLW_DISPLAY    DC.B    'ASL.W',0
ASRL_DISPLAY    DC.B    'ASR.L',0
ASLL_DISPLAY    DC.B    'ASL.L',0
D0_DISPLAY      DC.B    'D0',0
D1_DISPLAY      DC.B    'D1',0
D2_DISPLAY      DC.B    'D2',0
D3_DISPLAY      DC.B    'D3',0
D4_DISPLAY      DC.B    'D4',0
D5_DISPLAY      DC.B    'D5',0
D6_DISPLAY      DC.B    'D6',0
D7_DISPLAY      DC.B    'D7',0
A0_DISPLAY      DC.B    'A0',0
A1_DISPLAY      DC.B    'A1',0
A2_DISPLAY      DC.B    'A2',0
A3_DISPLAY      DC.B    'A3',0
A4_DISPLAY      DC.B    'A4',0
A5_DISPLAY      DC.B    'A5',0
A6_DISPLAY      DC.B    'A6',0
A7_DISPLAY      DC.B    'A7',0
DISPLAY_$1       DC.B    '#$1',0
DISPLAY_$2       DC.B    '#$2',0
DISPLAY_$3       DC.B    '#$3',0
DISPLAY_$4       DC.B    '#$4',0
DISPLAY_$5       DC.B    '#$5',0
DISPLAY_$6       DC.B    '#$6',0
DISPLAY_$7       DC.B    '#$7',0
DISPLAY_$8       DC.B    '#$8',0
DOLLAR_DISPLAY  DC.B    '$',0
SLASH_DISPLAY   DC.B    '\',0
POUND_DISPLAY   DC.B    '#',0
COMMA_DISPLAY   DC.B    ',',0
LEFT_PARANTHESES    DC.B    '(',0
RIGHT_PARANTHESES   DC.B    ')',0
PLUS_DISPLAY    DC.B    '+',0
MINUS_DISPLAY   DC.B    '-',0

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
