                    ;........................VARIABLES......................................
addrstart:          ds.l    1                       ; POINTER TO THE START DISASSEMBLE ADDRESS
addrend:            ds.l    1                       ; POINTER TO THE END DISASSEMBLE ADDRESS
addrnext:           ds.l    1                       ; POINTER TO NEXT DISASSEMBLE




strtmp01:           DS.B    81                      ; TEMPORAL STRING
linecnt0:           DS.W    1                       ; CURRENT SCREEN LINE COUNTER


opvalue:            DS.W    1                       ; CURRENT OPCODE
opcodtptr:          DS.L    1                       ; POINTER OPCODETABLE

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
