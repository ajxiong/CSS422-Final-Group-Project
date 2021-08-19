
    ;
opcode_subroutine:
    MOVEM.L D2-D4/A2-A4,-(SP)                   ; SAVE REGISTER INTO THE STACK

    MOVE.L  ADDRNEXT,A0                         ; LOAD INSTRUCTION POINTER
    MOVE.W  (A0),D0                             ; LOAD THE INSTRUCTION
    MOVE.W  D0,opvalue                          ; SAVE INSTRUCTION

    LEA     opcodestable,A0                     ; LOAD ADDRESS OP-CODES TABLE
opcode_subroutineLOOP:
    MOVE.W  opvalue,D0                          ; LOAD INSTRUCTION
    AND.L   OPCODFLDINTMSK(A0),D0               ; MASK INSTRUCTION
    CMP.L   OPCODFLDINTVAL(A0),D0               ; CHECK VALUE
    BEQ     opcode_subroutine_found             ; FOUND
    ADDA.L  #OPCODENTRYSIZE,A0                  ; INCREMENT POINTER BY 1 ENTRY SIZE
    CMPA    #opcodestableEND,A0                 ; COMPARE WITH END OF TABLE
    BLT     opcode_subroutineLOOP               ; IF NOT END THEN REPEAT
    
    MOVEM.L (SP)+,D2-D4/A2-A4                   ; RESTORE REGISTERS FROM THE STACK
    MOVE.B  #0,D0                               ; RETURN NOT VALID OPCODE FOUND
    RTS
opcode_subroutine_found:
    ADDQ.L  #2,(addrnext)                       ; MOVE READ POINTER
    MOVE.L  A0,opcodtptr                        ; SAVE OP CODE ENTRY POINTER
    
    LEA     str1tmpop, A1                       ; STRING 1 OPERAND
    MOVE.B  #0,(A1)                             ; INITIALLY EMPTY BY MARK END OF STRING
    MOVE.L  A1,ptrstrop1                        ; SET POINTER TO STRING 1 OPERAND
    
    LEA     str2tmpop, A1                       ; STRING 2 OPERAND
    MOVE.B  #0,(A1)                             ; INITIALLY EMPTY BY MARK END OF STRING
    MOVE.L  A1,ptrstrop2                        ; SET POINTER TO STRING 2 OPERAND
    
    LEA     strStmpop, A1                       ; STRING OPERAND SEPARATOR
    MOVE.B  #0,(A1)+                            ; INITIALLY EMPTY BY MARK END OF STRING
    MOVE.B  #0,(A1)+                            ; INITIALLY EMPTY BY MARK END OF STRING
    
    LEA     strtmpdis01,A2                      ; POINTER TO TEMPORAL STRING FOR BUILD THE DECODED INSTRUCTION
    MOVE.B  #' ',(A2)+                          ; INSERT SPACE
    MOVE.B  #' ',(A2)+                          ; INSERT SPACE
    MOVE.L  opcodtptr,A0                        ; LOAD OP CODE ENTRY POINTER
    MOVE.L  OPCODFLDMNMNC(A0),A1                ; LOAD OP CODE MNEMONIC
    JSR     STRCOPYA1TOA2                       ; APPEND TO TEMPORAL STRING
    
    MOVE.L  opcodtptr,A0                        ; LOAD OP CODE ENTRY POINTER
    MOVE.L  OPCODFLDCC(A0),A0                   ; LOAD OP CODE CC EXTRACT
    JSR     (A0)                                ; COPY TO TEMPORAL STRING
    
    MOVE.L  opcodtptr,A0                        ; LOAD OP CODE ENTRY POINTER
    MOVE.L  OPCODFLDSZ(A0),A0                   ; LOAD OP CODE SIZE  EXTRACT
    JSR     (A0)                                ; COPY TO TEMPORAL STRING
    
    ;INSERT SPACES TO ALIGN OPERAND COLUMN
opcode_subroutineLAOCS:
    LEA     strtmpdis01+14,A1                   ; OPERAND START IN COLUMN 14
    CMPA    A1,A2                               ; OPERAND START IN COLUMN 14
    BGE     opcode_subroutineLAOCE              ;
    MOVE.B  #' ',(A2)+                          ; FILL WITH SPACES
    BRA     opcode_subroutineLAOCS              ; REPEAT
opcode_subroutineLAOCE:
    
    MOVE.L  opcodtptr,A0                        ; LOAD OP CODE ENTRY POINTER
    MOVE.L  OPCODFLDOP1(A0),A0                  ; LOAD OP CODE OPERAND 1 EXTRACT
    JSR     (A0)                                ; COPY TO TEMPORAL STRING
    
    MOVE.L  opcodtptr,A0                        ; LOAD OP CODE ENTRY POINTER
    MOVE.L  OPCODFLDOPS(A0),A0                  ; LOAD OP CODE OPERAND SEPARATOR
    JSR     (A0)                                ; COPY TO TEMPORAL STRING
    
    MOVE.L  opcodtptr,A0                        ; LOAD OP CODE ENTRY POINTER
    MOVE.L  OPCODFLDOP2(A0),A0                  ; LOAD OP CODE OPERAND 2 EXTRACT
    JSR     (A0)                                ; COPY TO TEMPORAL STRING
    
    MOVE.L  opcodtptr,A0                        ; LOAD OP CODE ENTRY POINTER
    MOVE.L  OPCODFLDOPR(A0),A0                  ; LOAD OP CODE OPERAND REORDER
    JSR     (A0)                                ; COPY TO TEMPORAL STRING    

    MOVE.L  ptrstrop1,A1                        ; OPERAND 1
    JSR     STRCOPYA1TOA2                       ; APPEND TO TEMPORAL STRING  

    LEA     strstmpop,A1                        ; OPERAND SEPARATOR
    JSR     STRCOPYA1TOA2                       ; APPEND TO TEMPORAL STRING

    MOVE.L  ptrstrop2,A1                        ; OPERAND 2
    JSR     STRCOPYA1TOA2                       ; APPEND TO TEMPORAL STRING

    
    MOVE.B  #0,(A2)                             ; MARK END OF STRING
    
    LEA     strtmpdis01,A1                      ; POINTER TO TEMPORAL STRING FOR BUILD THE DECODED INSTRUCTION
    MOVE    #14,D0                              ; PRINT STRING
    TRAP    #15                                 ; TRAP 15
    
    MOVEM.L (SP)+,D2-D4/A2-A4                   ; RESTORE REGISTERS FROM THE STACK
    MOVE.B  #1,D0                               ; RETURN OPCODE FOUND
    RTS
    
    ;COPY STRING POINTER BY A1 TO STRING POINTED BY A2, INCREMENT BOTH POINTERS
STRCOPYA1TOA2:
    CMP.B   #0,(A1)
    BEQ     STRCOPYA1TOA2RET
    MOVE.B  (A1)+,(A2)+
    BRA     STRCOPYA1TOA2
STRCOPYA1TOA2RET:
    RTS
    
    ;CONVERT VALUE TO HEX, A1 = TEMPORAL STRING, D1 VALUE TO CONVER
opcode_tohexOLD:
    MOVE.W  4(SP),D0            ; LOAD DIGIT COUNT
    EXT.L   D0                  ; MAKE LONGWORD
    ADDA    D0,A1               ; ADD TO TEMPORAL STRING POINTER
    MOVE.B  #0,0(A1)            ; MARK END OF STRING

opcode_tohexLOOPOLD:    
    MOVE.L  D1,D0               ;
    ANDI.L  #15,D0              ;
    MOVE.L  D0,A0               ;
    MOVE.B  HEXDIGITS(A0),-(A1) ;
    LSR.L   #4,D1               ;
    SUBI.W  #1,4(SP)            ;
    BNE     opcode_tohexLOOP      ;    
    RTS                         ; RETURN
    
    ;CONVERT VALUE TO HEX WITH PREFIX $, A1 = TEMPORAL STRING, D1 VALUE TO CONVER
opcode_tohex:
    MOVE.B  #'$',(A1)+          ; SET THE PREFIX '$'
    MOVE.W  4(SP),D0            ; LOAD DIGIT COUNT
    EXT.L   D0                  ; MAKE LONGWORD
    ADDA    D0,A1               ; ADD TO TEMPORAL STRING POINTER
    MOVE.B  #0,0(A1)            ; MARK END OF STRING

opcode_tohexLOOP:    
    MOVE.L  D1,D0               ;
    ANDI.L  #15,D0              ;
    MOVE.L  D0,A0               ;
    MOVE.B  HEXDIGITS(A0),-(A1) ;
    LSR.L   #4,D1               ;
    SUBI.W  #1,4(SP)            ;
    BNE     opcode_tohexLOOP    ;    
    RTS                         ; RETURN


    ;DO NOTHING
opcode_empty01:
    RTS                                         ;RETURN
    ;SET OPERAND SEPARATOR
opcode_sep:
    MOVE.B  #',',(strstmpop)                    ; SET OPERAND SEPARATOR
    RTS                                         ;RETURN
    
    ;EXTRACT CC FROM BITS 11:8
opcode_cc:
    MOVE.W  opvalue,D0                          ; LOAD INSTRUCTION
    LSR.W   #8,D0                               ; EXTRACT CONDITION FIELD
    ANDI.L  #15,D0                              ; MASK
    LSL.L   #2,D0                               ;
    LEA     strcc,A1                            ;
    ADDA.L  D0,A1                               ;
    JSR     STRCOPYA1TOA2                       ;
    RTS                                         ;RETURN


    ;EXTRACT BRANCH DISPLACEMENT
opcode_qdataop2:
    MOVE.W  opvalue,D1                          ; LOAD INSTRUCTION
    ANDI.L  #255,D1                             ; MASK
    
    LEA     str2tmpop,A1                        ; STRING POINTER
    MOVE.B  #'#',(A1)+                          ; START #
    MOVE.W  #2,-(SP)                            ; NUMBER OF DIGIT TO SHOW
    JSR     opcode_tohex                        ;
    ADDA.L  #2,SP                               ; FREE PARAMETERS
    
    RTS                                         ;RETURN


    ;EXTRACT BRANCH DISPLACEMENT
opcode_bdisp:
    MOVE.W  opvalue,D1                          ; LOAD INSTRUCTION
    ANDI.L  #255,D1                             ; MASK
    BEQ     opcode_bdisp16bit                   ; IF 16BIT DISPLACEMENT

    EXT.W   D1                                  ; ABSOLUTE ADRESS
    EXT.L   D1                                  ; ABSOLUTE ADRESS
    ADD.L   addrnext,D1                         ; ABSOLUTE ADRESS
    
    LEA     str1tmpop,A1                        ; STRING POINTER
    MOVE.W  #8,-(SP)                            ; NUMBER OF DIGIT TO SHOW
    JSR     opcode_tohex                        ;
    ADDA.L  #2,SP                               ; FREE PARAMETERS
    
    RTS
opcode_bdisp16bit:
    MOVE.L  addrnext,A0                         ; LOAD POINTER TO NEXT DATA
    MOVE.W  (A0)+,D1                            ; LOAD 16 BIT DISPLACEMENT
    MOVE.L  A0,addrnext                         ; SAVE READ POINTER
    EXT.L   D1                                  ; ABSOLUTE ADDRESS
    ADD.L   addrnext,D1                         ; ABSOLUTE ADDRESS
    SUBQ.L  #2,D1                               ; ABSOLUTE ADDRESS
    
    LEA     str2tmpop,A1                        ; STRING POINTER
    MOVE.W  #8,-(SP)                            ; NUMBER OF DIGIT TO SHOW
    JSR     opcode_tohex                        ;
    ADDA.L  #2,SP                               ; FREE PARAMETERS
    
    RTS                                         ;RETURN

    
    ;EXTRACT SIZE FROM BITS 7 AND 6 (00=B, 01=W, 10=L), EXPECTED TEMPORAL STRING POINTER IN A2
opcode_sz0:
    MOVE.B  #'.',(A2)+                          ; PUT '.'
    MOVE.W  opvalue,D0                          ; LOAD INSTRUCTION
    LSR.W   #6,D0                               ; EXTRACT SIZE FIELD
    ANDI.L  #3,D0                               ; MASK
    MOVE.L  D0,A1                               ; 
    MOVE.B  instfldsizec1(A1),(A2)+             ; SET SIZE
    ADDA    A1,A1                               ; LONGWORD SIZE
    ADDA    A1,A1                               ; LONGWORD SIZE
    MOVE.L  instfldsizecL1(A1),opsize01         ; SET SIZE
    RTS                                         ;RETURN

    
    ;EXTRACT SIZE FROM BIT 6(0=W, 1=L), EXPECTED TEMPORAL STRING POINTER IN A2
opcode_sz1:
    MOVE.B  #'.',(A2)+                          ; PUT '.'
    MOVE.W  opvalue,D0                          ; LOAD INSTRUCTION
    LSR.B   #6,D0                               ; EXTRACT SIZE FIELD
    ANDI.L  #1,D0                               ; MASK
    MOVE.L  D0,A1                               ; 
    MOVE.B  instfldsizec3(A1),(A2)+             ; SET SIZE
    ADDA    A1,A1                               ; LONGWORD SIZE
    ADDA    A1,A1                               ; LONGWORD SIZE
    MOVE.L  instfldsizecL3(A1),opsize01         ; SET SIZE
    RTS                                         ;RETURN

    
    ;EXTRACT SIZE FROM BITS 12 AND 13(01=B, 11=W, 10=L), EXPECTED TEMPORAL STRING POINTER IN A2
opcode_sz2:
    MOVE.B  #'.',(A2)+                          ; PUT '.'
    MOVE.W  opvalue,D0                          ; LOAD INSTRUCTION
    LSR.W   #6,D0                               ; EXTRACT SIZE FIELD
    LSR.W   #6,D0                               ; EXTRACT SIZE FIELD
    ANDI.L  #3,D0                               ; MASK
    MOVE.L  D0,A1                               ; 
    MOVE.B  instfldsizec2(A1),(A2)+             ; SET SIZE
    ADDA    A1,A1                               ; LONGWORD SIZE
    ADDA    A1,A1                               ; LONGWORD SIZE
    MOVE.L  instfldsizecL2(A1),opsize01         ; SET SIZE
    RTS                                         ;RETURN
    
    ;EXTRACT SIZE FROM BIT 8(0=W, 1=L), EXPECTED TEMPORAL STRING POINTER IN A2
opcode_sz3:
    MOVE.B  #'.',(A2)+                          ; PUT '.'
    MOVE.W  opvalue,D0                          ; LOAD INSTRUCTION
    LSR.L   #8,D0                               ; EXTRACT SIZE FIELD
    ANDI.L  #1,D0                               ; MASK
    MOVE.L  D0,A1                               ; 
    MOVE.B  instfldsizec3(A1),(A2)+             ; SET SIZE
    ADDA    A1,A1                               ; LONGWORD SIZE
    ADDA    A1,A1                               ; LONGWORD SIZE
    MOVE.L  instfldsizecL3(A1),opsize01         ; SET SIZE
    RTS                                         ;RETURN

    ; EXTRACT FIELD Dn FROM BITS 11:9 AND SET INTO OPERAND 1
opcode_rlmop1:
    MOVEM.L D2-D5,-(SP)                         ; SAVE REGISTERS
    
    MOVE.L  addrnext,A0                         ; LOAD POINTER TO NEXT DATA
    MOVE.W  (A0)+,D2                            ; LOAD 16 BIT REGISTER LIST
    MOVE.L  A0,addrnext                         ; SAVE READ POINTER
    
    MOVE.W  opvalue,D0                          ; LOAD INSTRUCTION
    ANDI.W  #$38,D0                             ; MASK M EA FIELD
    CMP.B   #$20,D0                             ; PREDECREMENT?
    BEQ     opcode_rlmop1PRDEC
    
    MOVE.L  #$0001,D3                           ;
    MOVE.L  #15,D4                              ;
    JMP     opcode_rlmop1BLD                    ;
    
opcode_rlmop1PRDEC:
    
    MOVE.L  #$8000,D3                           ;
    MOVE.L  #1,D4                               ;

opcode_rlmop1BLD:

    LEA     str1tmpop,A0                        ;    

    MOVE.B #8,D5                                ;
opcode_rlmop1PRDECLOOP1:
    MOVE.W  D2,D0                               ;
    AND.W   D3,D0                               ;
    BEQ     opcode_rlmop1PRDECLOOP1dec          ;
    MOVE.B  #'8',D0                             ;
    SUB.B   D5,D0                               ;
    MOVE.B   #'D',(A0)+                         ;
    MOVE.B   D0,(A0)+                           ;
    MOVE.B   #'/',(A0)+                         ;
opcode_rlmop1PRDECLOOP1dec:
    ROR.W   D4,D3                               ; ROTATE MASK
    SUBQ.B  #1,D5                               ; DECREMENT COUNTER
    BNE     opcode_rlmop1PRDECLOOP1             ; REPEAT IF NOT ZERO

    MOVE.B #8,D5                                ;
opcode_rlmop1PRDECLOOP2:
    MOVE.W  D2,D0                               ;
    AND.W   D3,D0                               ;
    BEQ     opcode_rlmop1PRDECLOOP2dec          ;
    MOVE.B  #'8',D0                             ;
    SUB.B   D5,D0                               ;
    MOVE.B   #'A',(A0)+                         ;
    MOVE.B   D0,(A0)+                           ;
    MOVE.B   #'/',(A0)+                         ;
opcode_rlmop1PRDECLOOP2dec:
    ROR.W   D4,D3                               ; ROTATE MASK
    SUBQ.B  #1,D5                               ; DECREMENT COUNTER
    BNE     opcode_rlmop1PRDECLOOP2             ; REPEAT IF NOT ZERO

    MOVE.B   #0,-1(A0)
    
    
    MOVEM.L (SP)+,D2-D5                         ; RESTORE REGISTERS
    RTS                                         ;RETURN
    

    ; EXTRACT FIELD Dn FROM BITS 11:9 AND SET INTO OPERAND 1
opcode_immdn1op1:
    MOVE.W  opvalue,D0                          ; LOAD INSTRUCTION
    ANDI.W  #$20,D0                             ; CHECK MODE IMMEDIATE/REGISTER
    BEQ     opcode_immdn1op1IMM                 ;
    JSR     opcode_dn1op1                       ;
    RTS                                         ;RETURN
opcode_immdn1op1IMM:
    MOVE.B  #'#',(str1tmpop)                    ; SET 'D'
    MOVE.W  opvalue,D0                          ; LOAD INSTRUCTION
    LSR.W   #8,D0                               ; EXTRACT BITS 11:9
    LSR.B   #1,D0                               ; EXTRACT BITS 11:9
    ANDI.L  #7,D0                               ; EXTRACT BITS 11:9
    ADDI.B  #'0',D0                             ; CONVERT TO ASCII
    CMP.B   #'0',D0                             ;
    BNE     opcode_immdn1op1IMML8               ;
    MOVE.B  #'8',D0                             ; REPLACE WITH 8
opcode_immdn1op1IMML8:
    MOVE.B  D0,(str1tmpop+1)                    ; SET NUMBER
    MOVE.B  #0,(str1tmpop+2)                    ; SET END OF STRING
    RTS                                         ;RETURN

    ; EXTRACT FIELD Dn FROM BITS 2:0 AND SET INTO OPERAND 2
opcode_dn2op2:
    MOVE.B  #'D',(str2tmpop)                    ; SET 'D'
    MOVE.W  opvalue,D0                          ; LOAD INSTRUCTION
    ANDI.L  #7,D0                               ; EXTRACT BITS 11:9
    ADDI.B  #'0',D0                             ; CONVERT TO ASCII
    MOVE.B  D0,(str2tmpop+1)                    ; SET NUMBER
    MOVE.B  #0,(str2tmpop+2)                    ; SET END OF STRING
    RTS                                         ;RETURN

    ; EXTRACT FIELD Dn FROM BITS 11:9 AND SET INTO OPERAND 1
opcode_dn1op1:
    MOVE.B  #'D',(str1tmpop)                    ; SET 'D'
    MOVE.W  opvalue,D0                          ; LOAD INSTRUCTION
    LSR.W   #8,D0                               ; EXTRACT BITS 11:9
    LSR.B   #1,D0                               ; EXTRACT BITS 11:9
    ANDI.L  #7,D0                               ; EXTRACT BITS 11:9
    ADDI.B  #'0',D0                             ; CONVERT TO ASCII
    MOVE.B  D0,(str1tmpop+1)                    ; SET NUMBER
    MOVE.B  #0,(str1tmpop+2)                    ; SET END OF STRING
    RTS                                         ;RETURN

    ; EXTRACT FIELD Dn FROM BITS 11:9 AND SET INTO OPERAND 1
opcode_an1op1:
    MOVE.B  #'A',(str1tmpop)                    ; SET 'D'
    MOVE.W  opvalue,D0                          ; LOAD INSTRUCTION
    LSR.W   #8,D0                               ; EXTRACT BITS 11:9
    LSR.B   #1,D0                               ; EXTRACT BITS 11:9
    ANDI.L  #7,D0                               ; EXTRACT BITS 11:9
    ADDI.B  #'0',D0                             ; CONVERT TO ASCII
    MOVE.B  D0,(str1tmpop+1)                    ; SET NUMBER
    MOVE.B  #0,(str1tmpop+2)                    ; SET END OF STRING
    RTS                                         ;RETURN

    ; EXTRACT FIELD Dn FROM BITS 11:9 AND SET INTO OPERAND 1
opcode_qval:
    MOVE.B  #'#',(str1tmpop)                    ; SET 'D'
    MOVE.W  opvalue,D0                          ; LOAD INSTRUCTION
    LSR.W   #8,D0                               ; EXTRACT BITS 11:9
    LSR.B   #1,D0                               ; EXTRACT BITS 11:9
    ANDI.L  #7,D0                               ; EXTRACT BITS 11:9
    ADDI.B  #'0',D0                             ; CONVERT TO ASCII
    MOVE.B  D0,(str1tmpop+1)                    ; SET NUMBER
    MOVE.B  #0,(str1tmpop+2)                    ; SET END OF STRING
    RTS                                         ;RETURN
    
    ; EXTRACT 16BIT DISPLACEMENT, ADDRESS REGISTER AND SET IN TO OPERAND 2
opcode_d16a1o2:
    MOVE.L  addrnext,A0                         ; LOAD POINTER TO NEXT DATA
    MOVE.W  (A0)+,D1                            ; LOAD 16 BIT DISPLACEMENT
    MOVE.L  A0,addrnext                         ; SAVE READ POINTER
    
    LEA     str2tmpop,A1                        ; STRING POINTER
    MOVE.W  #4,-(SP)                            ; NUMBER OF DIGIT TO SHOW
    JSR     opcode_tohex                        ;
    ADDA.L  #2,SP                               ; FREE PARAMETERS

    LEA     str2tmpop+5,A1                        ; STRING POINTER
    MOVE.W  opvalue,D0                          ; LOAD INSTRUCTION
    JSR     opcode_PanP                         ; APPEND (An)
    JMP     opcode_ea1op2JMPEND                 ; BACK TO TABLE END

    RTS                                         ;RETURN

opcode_PanP:
    MOVE.B  #'(',(A1)+                          ; SET '('
    MOVE.B  #'A',(A1)+                          ; SET 'A'
    ANDI.L  #7,D0                               ; EXTRACT BITS 2:0
    ADDI.B  #'0',D0                             ; CONVERT TO ASCII
    MOVE.B  D0,(A1)+                            ; SET NUMBER
    MOVE.B  #')',(A1)+                          ; SET ')'
    MOVE.B  #0,(A1)+                            ; SET END OF STRING
    RTS                                         ; RETURN
    
    ; EXTRACT OPERAND 2 EA FROM BITS 5:0 OF INSTRUCTION
opcode_ea1op2:
    MOVE.W  opvalue,-(SP)                       ; SET EA PARAMETER
    ANDI.W  #$3F,(SP)                           ; SET EA PARAMETER
    LEA     str2tmpop,A1                        ; STRING POINTER
    MOVE.L  A1,-(SP)                            ; SET STRING POINTER PARAMERTER
    JSR     opcode_ea                           ; DECODE EA
    ADDQ.L  #6,SP                               ; FREE SPACE PARAMETERS
    RTS
    
    ; EXTRACT OPERAND 1 EA FROM BITS 11:6 OF INSTRUCTION
opcode_ea2op1:
    MOVE.W  opvalue,D0                          ; LOAD CURRENT INSTRUCTION
    LSR.W   #3,D0                               ; BUILD EA
    MOVE.W  D0,D1                               ; BUILD EA
    LSR.W   #6,D1                               ; BUILD EA
    ANDI.W  #$38,D0                             ; BUILD EA
    ANDI.W  #$07,D1                             ; BUILD EA
    OR.W    D1,D0                               ; BUILD EA
    MOVE.W  D0,-(SP)                            ; SET EA PARAMETER
    ANDI.W  #$3F,(SP)                           ; SET EA PARAMETER
    LEA     str1tmpop,A1                        ; STRING POINTER
    MOVE.L  A1,-(SP)                            ; SET STRING POINTER PARAMERTER
    JSR     opcode_ea                           ; DECODE EA
    ADDQ.L  #6,SP                               ; FREE SPACE PARAMETERS
    RTS

    
    ; REORDER OPERAND USING BIT 7(1=Register to memory)
opcode_dir0:
    MOVE.W  opvalue,D0                          ; LOAD CURRENT INSTRUCTION
    ANDI.W  #128,D0                             ; TEST BIT 7
    BEQ     opcode_dir0_rev                     ; IF 0 REVERT
    RTS                                         ;RETURN
opcode_dir0_rev:
    JSR     opcode_oprev                        ;
    RTS                                         ;RETURN
    
    ; REORDER OPERAND USING BIT 8(1=<ea> ♦ Dn → <ea>)
opcode_dir1:
    MOVE.W  opvalue,D0                          ; LOAD CURRENT INSTRUCTION
    ANDI.W  #256,D0                             ; TEST BIT 8
    BEQ     opcode_dir1_rev                     ; IF 0 REVERT
    RTS                                         ;RETURN
opcode_dir1_rev:
    JSR     opcode_oprev                        ;
    RTS                                         ;RETURN

    ; REORDER OPERAND USING BIT 10(1=<ea> ♦ Dn → <ea>)
opcode_dir2:
    MOVE.W  opvalue,D0                          ; LOAD CURRENT INSTRUCTION
    ANDI.W  #1024,D0                            ; TEST BIT 10
    BNE     opcode_dir2_rev                     ; IF 0 REVERT
    RTS                                         ;RETURN
opcode_dir2_rev:
    JSR     opcode_oprev                        ;
    RTS                                         ;RETURN
    
    ; reverse the operand order
opcode_oprev:
    MOVE.L  ptrstrop1,D0                        ;
    MOVE.L ptrstrop2,ptrstrop1                  ;
    MOVE.L  D0, ptrstrop2                       ;
    RTS                                         ;RETURN
    



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
