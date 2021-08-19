                    ;........................VARIABLES......................................
                    DS.L    0    ; Force longword alignment
addrstart:          ds.l    1                       ; POINTER TO THE START DISASSEMBLE ADDRESS
addrend:            ds.l    1                       ; POINTER TO THE END DISASSEMBLE ADDRESS
addrnext:           ds.l    1                       ; POINTER TO NEXT DISASSEMBLE




strtmp01:           DS.B    82                      ; TEMPORAL STRING

                    DS.L    0                       ; Force longword alignment
linecnt0:           DS.W    1                       ; CURRENT SCREEN LINE COUNTER


                    DS.L    0                       ; Force longword alignment
opvalue:            DS.W    1                       ; CURRENT OPCODE
opcodtptr:          DS.L    1                       ; POINTER OPCODETABLE

strtmpdis01:        DS.B    160                     ; TEMPORAL STRING

str1tmpop:          DS.B    80                      ; STRING 1 HOLDING OPERAND
str2tmpop:          DS.B    80                      ; STRING 2 HOLDING OPERAND
strstmpop:          DS.B    2                       ; STRING HOLDING OPERAND SEPARATOR

                    DS.L    0                       ; Force longword alignment
ptrstrop1:          DS.L    1                       ; POINTER TO STRING OPERAND
ptrstrop2:          DS.L    1                       ; POINTER TO STRING OPERAND

ptrstropX:          DS.L    1                       ; POINTER TO STRING OPERAND

opsize01:           DS.L    1                       ; OPERAND SIZE IN BYTES



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
