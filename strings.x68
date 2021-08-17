; OpCodes
opcode_ADD          DC.B    'ADD',0
opcode_ADDA         DC.B    'ADDA',0
opcode_ADDQ         DC.B    'ADDQ',0
opcode_AND          DC.B    'AND',0
opcode_ASL          DC.B    'ASL',0
opcode_ASR          DC.B    'ASR',0
opcode_BEQ          DC.B    'BEQ',0
opcode_BGT          DC.B    'BGT',0
opcode_BLE          DC.B    'BLE',0
opcode_BRA          DC.B    'BRA',0
opcode_JSR          DC.B    'JSR',0
opcode_LEA          DC.B    'LEA',0
opcode_LSL          DC.B    'LSL',0
opcode_LSR          DC.B    'LSR',0
opcode_MOVE         DC.B    'MOVE',0
opcode_MOVEA        DC.B    'MOVEA',0
opcode_MOVEM        DC.B    'MOVEM',0
opcode_MOVEP        DC.B    'MOVEP',0
opcode_MOVEQ        DC.B    'MOVEQ',0
opcode_NOP          DC.B    'NOP',0
opcode_NOT          DC.B    'NOT',0
opcode_OR           DC.B    'OR',0
opcode_ROL          DC.B    'ROL',0
opcode_ROR          DC.B    'ROR',0
opcode_RTS          DC.B    'RTS',0
opcode_SUB          DC.B    'SUB',0

                    ;..........................INSTRUCTION TABLE........................
                    
                    ; EACH ENTRY FIELD IS LONG EVEN IF DATA IS WORD OR BYTE
                    ; THE FIELD 0 IS THE OPCODE
                    ; THE FIELD 1 IS THE VALUE (AFTER MASKED)
                    ; THE FIELD 2 IS THE INSTRUCTION MASK

opcodestable:
                    DC.L    opcode_MOVEP, $0108, $F138
opcodestableENTRY1:
                    DC.L    opcode_MOVEA, $0040, $C1C0
                    DC.L    opcode_MOVE, $0000, $C000
                    DC.L    opcode_NOT, $4600, $FF00
                    DC.L    opcode_NOP, $4E71, $FFFF
                    DC.L    opcode_RTS, $4E75, $FFFF
                    DC.L    opcode_JSR, $4E80, $FFC0
                    DC.L    opcode_MOVEM, $4880, $FB80
                    DC.L    opcode_LEA, $41C0, $F1C0
                    DC.L    opcode_ADDQ, $5000, $F100
                    DC.L    opcode_BRA, $6000, $FF00
                    DC.L    opcode_BGT, $6E00, $FF00
                    DC.L    opcode_BLE, $6F00, $FF00
                    DC.L    opcode_BEQ, $6700, $FF00
                    DC.L    opcode_MOVEQ, $7000, $F100
                    DC.L    opcode_OR, $8000, $F000
                    DC.L    opcode_SUB, $9000, $F000
                    DC.L    opcode_AND, $C000, $F000
                    DC.L    opcode_ADD, $D000, $F000
                    DC.L    opcode_ADDA, $D000, $F0C0
                    DC.L    opcode_ASR, $E0C0, $FFC0
                    DC.L    opcode_ASL, $E1C0, $FFC0
                    DC.L    opcode_LSR, $E2C0, $FFC0
                    DC.L    opcode_LSL, $E3C0, $FFC0
                    DC.L    opcode_ROR, $E6C0, $FFC0
                    DC.L    opcode_ROL, $E7C0, $FFC0
                    DC.L    opcode_ASR, $E000, $F118
                    DC.L    opcode_ASL, $E100, $F118
                    DC.L    opcode_LSR, $E008, $F118
                    DC.L    opcode_LSL, $E108, $F118
                    DC.L    opcode_ROR, $E018, $F118
                    DC.L    opcode_ROL, $E118, $F118
opcodestableEND:

OPCODFLDMNMNC       EQU     0
OPCODFLDINTVAL      EQU     4
OPCODFLDINTMSK      EQU     8


OPCODENTRYSIZE      EQU     opcodestableENTRY1-opcodestable

                    ;..........................MESSAGES........................

NEWLINE:            dc.b    13,10,0
SPACES4:            dc.b    '    ',0

HEXDIGITS:          dc.b    '0123456789ABCDEF'

msgwelcome01:       dc.b    'Welcome to the 68000 disassembler.', 13, 10, 0


msgpromptopc:       dc.b    13, 10, 13, 10
                    dc.b    '1 Disassemble', 13, 10
                    dc.b    '2 Quit the disassembler', 13, 10
                    dc.b    '            Your option:', 0
                    
msgbadopc:          dc.b    13, 10
                    DC.B    'Bad option!, please enter a valid option.', 13, 10, 0

msgbye:             dc.b    13, 10
                    DC.B    'Bye', 13, 10, 0

msghexbad:          DC.B    13, 10
                    DC.B    'Bad Hexadecimal digit  must be 0-9, A-F'
                    DC.B    13, 10, 0

msghexbadr:         DC.B    13, 10
                    DC.B    'you should enter between 1 and 8 digits'
                    DC.B    13, 10, 0

msgaskstart:        DC.B    13, 10
                    DC.B    'Enter start address (as a hexadecimal number, e.g. A9B800):'
                    DC.B    0

msgaskend:          DC.B    13, 10
                    DC.B    'Enter end address (inclusive as a hexadecimal number, e.g. A9B800):'
                    DC.B    0

msgbadorder:        DC.B    13, 10
                    DC.B    'Start address must be <= end address'
                    DC.B    0

msgbadaddr01:       DC.B    13, 10
                    DC.B    'Bad address, address must be even'
                    DC.B    0

msgdata01:
                    DC.B    '  DATA $'
                    DC.B    0


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
