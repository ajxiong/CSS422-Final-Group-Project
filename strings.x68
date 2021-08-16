; OpCodes
opcode_MOVE	DC.B	'MOVE',0
opcode_MOVEM	DC.B	'MOVEM',0


                    ;..........................MESSAGES........................

NEWLINE:            dc.b    13,10,0

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
