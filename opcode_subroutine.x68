
    ;
opcode_subroutine:
    LEA     opcodestable,A0                     ; LOAD ADDRESS OP-CODES TABLE

opcode_subroutineLOOP:
    MOVE.L     ADDRNEXT,A1                         ; LOAD INSTRUCTION POINTER
    MOVE.W   (A1),D0                             ;
    AND.L   OPCODFLDINTMSK(A0),D0               ; MASK INSTRUCTION
    CMP.L   OPCODFLDINTVAL(A0),D0               ; CHECK VALUE
    BEQ     opcode_subroutine_found             ; FOUND
    ADDA.L  #OPCODENTRYSIZE,A0                  ; INCREMENT POINTER BY 1 ENTRY SIZE
    CMPA    #opcodestableEND,A0                 ; COMPARE WITH END OF TABLE
    BLT     opcode_subroutineLOOP               ; IF NOT END THEN REPEAT
    
    MOVE.B  #0,D0                               ; RETURN NOT VALID OPCODE FOUND
    RTS
opcode_subroutine_found:
    ADDQ.L  #2,(addrnext)                         ; MOVE READ POINTER
    MOVE.W  addrnext,opvalue                    ; SAVE OP CODE
    MOVE.L  A0,opcodtptr                        ; SAVE OP CODE ENTRY POINTER
    
    JSR     io_printspaces4                     ; SHOW 4 SPACES
    MOVE.L  OPCODFLDMNMNC(A0),A1                ; LOAD OP CODE MNEMONIC
    MOVE    #14,D1                              ; PRINT STRING
    TRAP    #15                                 ; TRAP 15
    MOVE.B  #1,D0                               ; RETURN OPCODE FOUND
    RTS
    

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
