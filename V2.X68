*-----------------------------------------------------------
* Title      :
* Written by :  Alex Xiong
* Date       :  08/11/21
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
            LEA MOVEB_DISPLAY,A6
            MOVE.B  #14,D0
            TRAP    #15

CODE0010    ; code is MOVE.L or MOVEA.L
            ; need to distinguish between MOVE.L and MOVEA.L?! they're both 0010
            MOVE.W  D0,D5   ; move first half of opcode to D5
            LSL.W   #4,D5   ; logical shift left 4 values over 
            CMP.W   #$001,D5
            BEQ MOVEAL_BRA
            ; if not MOVEA.L, then it's MOVE.L?
            LEA MOVEL_DISPLAY,A6
            MOVE.B  #14,D0
            TRAP    #15
            
            
MOVEAL_BRA   ;MOVEA BRANCH
            CLR D5 ; clear D5
            LEA MOVEAL_DISP,A6
            MOVE.B  #14,D0
            TRAP    #15
        
    
CODE0011    ; code is MOVE.W or MOVEA.W
            MOVE.W  D0,D5
            LSL.W   #4,D5
            CMP.W   #$001,D5
            BEQ MOVEAW_BRA
            LEA MOVEW_DISPLAY,A6
            MOVE.B  #14,D0
            TRAP    #15
            
            
MOVEAW_BRA  ; move.w branch
            CLR D5
            LEA MOVEAW_DISPLAY,A6
            MOVE.B  #14,D0
            TRAP    #15

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
            MOVE.B  #14,D0
            TRAP    #15
            
   
LEA_BRA
            LEA LEA_DIPSLAY,A6
            MOVE.B  #14,D0
            TRAP    #15

NOT_BRA
            LEA NOT_DISPLAY,A6
            MOVE.B  #14,D0
            TRAP    #15

JSR_BRA
            LEA JSR_DISPLAY,A6
            MOVE.B  #14,D0
            TRAP    #15

NOP_BRA
            LEA NOP_DISPLAY,A6
            MOVE.B  #14,D0
            TRAP    #15

MOVEM_W_BRA
            LEA MOVEMW_DISPLAY,A6
            MOVE.B  #14,D0
            TRAP    #15



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
            MOVE.B  #14,D0
            TRAP    #15

BLE_BRA
            LEA BLE_DISPLAY,A6
            MOVE.B  #14,D0
            TRAP    #15

BGT_BRA
            LEA BGT_DISPLAY,A6
            MOVE.B  #14,D0
            TRAP    #15

CODE0111    ; code is MOVEQ
            LEA MOVEQ_DISPLAY,A6
            MOVE.B  #14,D0
            TRAP    #15

CODE1000    ; code is OR
            LEA OR_DISPLAY,A6
            MOVE.B  #14,D0
            TRAP    #15

CODE1001    ; code is SUB

CODE1010    BRA         UNKNOWN         ; not a known opcode

CODE1011    BRA         UNKNOWN         ; not a known opcode

CODE1100    ; code is AND

CODE1101    ; code is ADD

CODE1110    ; code is ROR or ROL or ASR or ASL or LSR or LSL

CODE1111    BRA         UNKNOWN         ; not a known opcode

UNKNOWN     MOVE.B      #'D',(A2)+      ; add D to (A2)+ for unknown DATA code
            MOVE.B      #'A',(A2)+      ; add A to (A2)+ for unknown DATA code
            MOVE.B      #'T',(A2)+      ; add T to (A2)+ for unknown DATA code
            MOVE.B      #'A',(A2)+      ; add A to (A2)+ for unknown DATA code
            MOVE.B      #' ',(A2)+      ; add some spaces for alignment
            MOVE.B      #' ',(A2)+
            MOVE.B      #' ',(A2)+
            MOVE.B      #' ',(A2)+
            MOVE.B      #4,D4           ; add 4 to D4 to go through ASCII loop 4x
            MOVE.L      CURR,A1         ; move curr to A1
            MOVE.L      (A1),D0         ; move data at A1's address to curr
            JSR         ASCII           ; go to ASCII loop to translate code to ASCII and add them to (A2)+
            ; possibly need to add newline (CR,LF) as well
            BRA         PRINT              ; branch to print unknown line

EA          ; need to find EA (if any, need to convert rest of memory if any to hex too), add to (A2)+ after converting back to ascii, increment CURR by corresponding amount for opcode + EA
            BRA         PRINT           ; branch to print results
            
            
PRINT       ; need to print (A2)+ which stores all the info but not sure how
            ; also not sure yet whether to use #13 or #14 FOR TRAP #15
            MOVE.B      #14,D0          ; move #14 to D0 to print A1
            TRAP        #15             ; print contents of A1 (the contents of one line of memory)
            BRA         NEXT            ; go back up to next to translate next line of instructions
            
DONE        ; end of code - need to add something here?

CR          EQU         $0D             ; carriage return
LF          EQU         $0A             ; line feed
BEGIN       DS.L        1               ; reserve long for starting location
CURR        DS.L        1               ; reserve long for current location
END         DS.L        1               ; reserve long for ending location 
INTRO       DC.B        'Welcome to the MysteryHuskies 68k Disassembler!',CR,LF
            DC.B        'Please enter your desired starting location in 8 digit, upper-case hexadecimal: ',CR,LF,0
INTRO2      DC.B        'Thank you. Now please enter your desired ending location in 8 digit, upper-case hexadecimal: ',CR,LF,0
PRINT_TAB   DC.B    '   ',0
MOVEB_DISPLAY   DC.B    'MOVE.B',0
MOVEW_DISPALY   DC.B    'MOVE.W',0
MOVEL_DISPLAY   DC.B    'MOVE.L',0
MOVEAW_DISPLAY  DC.B    'MOVE.W',0
MOVEAL_DISPLAY   DC.B    'MOVEA.L'0
OR_DISPLAY  DC.B    'OR',0
LEA_DISPLAY DC.B    'LEA',0
NOT_DISPLAY DC.B    'NOT',0
JSR_DISPLAY DC.B    'JSR',0
NOP_DISPLAY DC.B    'NOP',0
MOVEMW_DISPLAY  DC.B    'MOVEM.W',0
MOVEM_L_DISPLAY DC.B    'MOVEM.L',0
BRA_DISPLAY DC.B    'BRA',0
BLE_DISPLAY DC.B    'BLE',0
BGT_DISPLAY DC.B    'BGT',0
MOVEQ_DISPLAY   DC.B    'MOVEQ',0
; if time permits should add in some different error messages to display for various types of bad addresses

            END         START           ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
