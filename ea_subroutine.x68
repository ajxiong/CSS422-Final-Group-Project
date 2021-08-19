    ; EXTRACT EA FROM BITS 5:0
opcode_ea:
    MOVE.W  8(SP),D0                            ; LOAD EA
    LSR.B   #3,D0                               ; EXTRACT M FIELD
    ANDI.L  #7,D0                               ; EXTRACT M FIELD
    MULU    #6,D0                               ; SIZE OF JMP XXXXXXX
    LEA     opcode_ea1op2JMPTBL,A0              ; LOAD JUMP TABLE BASE ADDRESS
    JMP     0(A0,D0)                            ; JUMP TO TABLE ENTRY
    
opcode_ea1op2JMPTBL:
    JMP     opcode_ea1op2JMP000
    JMP     opcode_ea1op2JMP001
    JMP     opcode_ea1op2JMP010
    JMP     opcode_ea1op2JMP011
    JMP     opcode_ea1op2JMP100
    JMP     opcode_ea1op2JMP101
    JMP     opcode_ea1op2JMP110
    JMP     opcode_ea1op2JMP111
opcode_ea1op2JMPEND:
    RTS                                         ;RETURN
    
    ; EA Dn
opcode_ea1op2JMP000:
    MOVE.L  4(SP),A1                            ; STRING POINTER
    MOVE.B  #'D',(A1)+                          ; SET 'A'
    MOVE.W  8(SP),D0                            ; LOAD EA
    ANDI.L  #7,D0                               ; EXTRACT BITS 2:0
    ADDI.B  #'0',D0                             ; CONVERT TO ASCII
    MOVE.B  D0,(A1)+                            ; SET NUMBER
    MOVE.B  #0,(A1)+                            ; SET END OF STRING
    JMP     opcode_ea1op2JMPEND                 ; BACK TO TABLE END

    ; EA An
opcode_ea1op2JMP001:
    MOVE.L  4(SP),A1                            ; STRING POINTER
    MOVE.B  #'A',(A1)+                          ; SET 'A'
    MOVE.W  8(SP),D0                            ; LOAD EA
    ANDI.L  #7,D0                               ; EXTRACT BITS 2:0
    ADDI.B  #'0',D0                             ; CONVERT TO ASCII
    MOVE.B  D0,(A1)+                            ; SET NUMBER
    MOVE.B  #0,(A1)+                            ; SET END OF STRING
    JMP     opcode_ea1op2JMPEND                 ; BACK TO TABLE END

    ; EA (An)
opcode_ea1op2JMP010:
    MOVE.L  4(SP),A1                            ; STRING POINTER
    MOVE.W  8(SP),D0                            ; LOAD EA
    JSR     opcode_PanP                         ; APPEND (An)
    JMP     opcode_ea1op2JMPEND                 ; BACK TO TABLE END

    ; EA (An)+
opcode_ea1op2JMP011:
    MOVE.L  4(SP),A1                            ; STRING POINTER
    MOVE.W  8(SP),D0                            ; LOAD EA
    JSR     opcode_PanP                         ; APPEND (An)
    MOVE.B  #'+',-1(A1)                         ; SET '+'
    MOVE.B  #0,(A1)+                            ; SET END OF STRING
    JMP     opcode_ea1op2JMPEND                 ; BACK TO TABLE END

    ; EA -(An)
opcode_ea1op2JMP100:
    MOVE.L  4(SP),A1                            ; STRING POINTER
    MOVE.W  8(SP),D0                            ; LOAD EA
    MOVE.B  #'-',(A1)+                          ; SET '-'
    JSR     opcode_PanP                         ; APPEND (An)
    JMP     opcode_ea1op2JMPEND                 ; BACK TO TABLE END

    ; EA $DISP(An)
opcode_ea1op2JMP101:
    MOVE.L  addrnext,A0                         ; LOAD POINTER TO NEXT DATA
    MOVE.W  (A0)+,D1                            ; LOAD 16 BIT DISPLACEMENT
    MOVE.L  A0,addrnext                         ; SAVE READ POINTER
    
    MOVE.L  4(SP),A1                            ; STRING POINTER
    MOVE.W  #4,-(SP)                            ; NUMBER OF DIGIT TO SHOW
    JSR     opcode_tohex                        ;
    ADDA.L  #2,SP                               ; FREE PARAMETERS

    MOVE.L  4(SP),A1                            ; STRING POINTER
    ADDA.L  #5,A1                               ; STRING POINTER
    MOVE.W  8(SP),D0                            ; LOAD EA
    JSR     opcode_PanP                         ; APPEND (An)
    JMP     opcode_ea1op2JMPEND                 ; BACK TO TABLE END

    ; EA (d8, An, Xn)
opcode_ea1op2JMP110:
    ADDQ.L  #2,addrnext                         ; INCREMENT READ POINTER TO SKIP Brief Extension Word
    JMP     opcode_ea1op2JMPEND                 ; BACK TO TABLE END

    ; EA OTHERS
opcode_ea1op2JMP111:
    MOVE.W  8(SP),D0                            ; LOAD EA
    ANDI.L  #7,D0                               ; EXTRACT Xn FIELD
    MULU    #6,D0                               ; SIZE OF JMP XXXXXXX
    LEA     opcode_ea1op2JM2TBL,A0              ; LOAD JUMP TABLE BASE ADDRESS
    JMP     0(A0,D0)                            ; JUMP TO TABLE ENTRY
opcode_ea1op2JM2TBL:
    JMP     opcode_ea1op2JM2000
    JMP     opcode_ea1op2JM2001
    JMP     opcode_ea1op2JM2010
    JMP     opcode_ea1op2JM2011
    JMP     opcode_ea1op2JM2100
    JMP     opcode_ea1op2JM2101
    JMP     opcode_ea1op2JM2110
    JMP     opcode_ea1op2JM2111
opcode_ea1op2JM2END:
    JMP     opcode_ea1op2JMPEND                 ; BACK TO TABLE END

    ; EA Absolute Short
opcode_ea1op2JM2000:
    MOVE.L  addrnext,A0                         ; LOAD POINTER TO NEXT DATA
    MOVE.W  (A0)+,D1                            ; LOAD 16 BIT DISPLACEMENT
    MOVE.L  A0,addrnext                         ; SAVE READ POINTER
    
    MOVE.L  4(SP),A1                            ; STRING POINTER
    MOVE.W  #4,-(SP)                            ; NUMBER OF DIGIT TO SHOW
    JSR     opcode_tohex                        ;
    ADDA.L  #2,SP                               ; FREE PARAMETERS
    JMP     opcode_ea1op2JM2END                 ; BACK TO TABLE END

    ; EA Absolute Long
opcode_ea1op2JM2001:
    MOVE.L  addrnext,A0                         ; LOAD POINTER TO NEXT DATA
    MOVE.L  (A0)+,D1                            ; LOAD 32 BIT DISPLACEMENT
    MOVE.L  A0,addrnext                         ; SAVE READ POINTER
    
    MOVE.L  4(SP),A1                            ; STRING POINTER
    MOVE.W  #8,-(SP)                            ; NUMBER OF DIGIT TO SHOW
    JSR     opcode_tohex                        ;
    ADDA.L  #2,SP                               ; FREE PARAMETERS
    JMP     opcode_ea1op2JM2END                 ; BACK TO TABLE END

opcode_ea1op2JM2010:
    ADDQ.L  #2,addrnext                         ; INCREMENT READ POINTER TO SKIP Brief Extension Word
    JMP     opcode_ea1op2JM2END                 ; BACK TO TABLE END

opcode_ea1op2JM2011:
    ADDQ.L  #2,addrnext                         ; INCREMENT READ POINTER TO SKIP Brief Extension Word
    JMP     opcode_ea1op2JM2END                 ; BACK TO TABLE END

    ; EA #IMM
opcode_ea1op2JM2100:
    CMP.L   #2,opsize01
    BLE     LOAD_IMM16
    MOVE.L  addrnext,A0                         ; LOAD POINTER TO NEXT DATA
    MOVE.L  (A0)+,D1                            ; LOAD 32 BIT IMMEDIATE
    MOVE.L  A0,addrnext                         ; SAVE READ POINTER
    BRA     LOADED_IMM
LOAD_IMM16:
    MOVE.L  addrnext,A0                         ; LOAD POINTER TO NEXT DATA
    MOVE.W  (A0)+,D1                            ; LOAD 16 BIT IMMEDIATE
    MOVE.L  A0,addrnext                         ; SAVE READ POINTER
LOADED_IMM:
    MOVE.L  4(SP),A1                            ; STRING POINTER
    MOVE.B  #'#',(A1)+                          ; SET '+'
    MOVE.L  opsize01, D0                        ; LOAD OPERAND SIZE IN BYTE
    ADD.L   D0,D0                               ; MULTIPLY X 2 TO MAKE DIGIT COUNT
    MOVE.W  D0,-(SP)                            ; NUMBER OF DIGIT TO SHOW
    JSR     opcode_tohex                        ;
    ADDA.L  #2,SP                               ; FREE PARAMETERS
    JMP     opcode_ea1op2JM2END                 ; BACK TO TABLE END

opcode_ea1op2JM2101:
    JMP     opcode_ea1op2JM2END                 ; BACK TO TABLE END

opcode_ea1op2JM2110:
    JMP     opcode_ea1op2JM2END                 ; BACK TO TABLE END

opcode_ea1op2JM2111:
    JMP     opcode_ea1op2JM2END                 ; BACK TO TABLE END

