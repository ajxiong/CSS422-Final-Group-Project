*-----------------------------------------------------------
* Title      : Final Project
* Written by : MysteryHuskies
* Date       : 7/28/21
* Description: Disassembler
*-----------------------------------------------------------
    
            ORG         $1000           ; start at $1000
    
START:                                  ; first instruction of the program 
   
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
            MOVE.B      #8,D4           ; set D4 to 7
            
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
            ; need to increment curr but not sure how to know how much to do that by each time
            CLR.L       D0              ; clear D0
            CLR.L       D1              ; clear D1
            CLR.L       D2              ; clear D2
            CLR.L       D3              ; clear D3
            CLR.L       D4              ; clear D4
            CLR.L       D5              ; clear D5
            
            MOVE.L      CURR,D0         ; move curr to D0
            ROL.L       #8,D0           ; rotate first 8 bits of op-code to far right
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
            
            CMP.B       #$10,D1         ; compare D1 to 1010
            BEQ         CODE1010        ; branch to code1010 if equal
            
            CMP.B       #$11,D1         ; compare D1 to 1011
            BEQ         CODE1011        ; branch to code1011 if equal
            
            CMP.B       #$12,D1         ; compare D1 to 1100
            BEQ         CODE1100        ; branch to code1100 if equal
            
            CMP.B       #$13,D1         ; compare D1 to 1101
            BEQ         CODE1101        ; branch to code1101 if equal
            
            CMP.B       #$14,D1         ; compare D1 to 1110
            BEQ         CODE1110        ; branch to code1110 if equal
            
            BRA         CODE1111        ; branch to code1111
            
CODE0000    BRA         UNKNOWN         ; not a known opcode

CODE0001    ; code is MOVE.B

CODE0010    ; code is MOVE.L or MOVEA.L

CODE0011    ; code is MOVE.W or MOVEA.W

CODE0100    ; code is LEA or NOT or RTS or JSR or NOP or MOVEM

CODE0101    BRA         UNKNOWN         ; not a known opcode

CODE0110    ; code is BRA or BGT or BLE or BEQ

CODE0111    ; code is MOVEQ

CODE1000    ; code is OR

CODE1001    ; code is SUB

CODE1010    BRA         UNKNOWN         ; not a known opcode

CODE1011    BRA         UNKNOWN         ; not a known opcode

CODE1100    ; code is AND

CODE1101    ; code is ADD

CODE1110    ; code is ROR or ROL or ASR or ASL or LSR or LSL

CODE1111    BRA         UNKNOWN         ; not a known opcode

UNKNOWN     ; print some type of placeholder message that says not a known code
            BRA         NEXT            ; go back up to next to translate next line of memory
            
; need to translate EA and print all results
            
DONE        ; end of code - need to add something here?

CR          EQU         $0D             ; carriage return
LF          EQU         $0A             ; line feed
BEGIN       DS.L        1               ; reserve long for starting location
CURR        DS.L        1               ; reserve long for current location
END         DS.L        1               ; reserve long for ending location 
INTRO       DC.B        'Welcome to the MysteryHuskies 68k Disassembler!',CR,LF
            DC.B        'Please enter your desired starting location in 8 digit, upper-case hexadecimal: ',CR,LF,0
INTRO2      DC.B        'Thank you. Now please enter your desired ending location in 8 digit, upper-case hexadecimal: ',CR,LF,0
; if time permits should add in some different error messages to display for various types of bad addresses

            END         START           ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
