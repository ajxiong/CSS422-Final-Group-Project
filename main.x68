*-----------------------------------------------------------
* Title      : Main File
*-----------------------------------------------------------
    ORG $1000
    ********************************************************
    JMP     MAIN                        ; SKIP TEST
    ***********************
    JMP     (A1)
    JMP     (PC)                        
    ***********************
    MOVEP   D0,0(A3)
    MOVEP   $AD(A3),D0
    MOVEP.L $2B(A2),D5
    ***********************
    MOVEA   #$45,A6
    MOVEA.L #$87456321,A6
    MOVEA   $5643(A0),A5
    MOVEA   D7,A5
    ***********************
    MOVE.B  #0,D3
    MOVE.B  D5,D0
    MOVE.B  D1,-(A0)
    MOVE.B  D4,(A0)+
    MOVE.B  -(A0),D6
    MOVE.B  (A0)+,D0
    MOVE.B  $5678,(A2)
    MOVE.W  $5678(A0),$1999(A3)
    MOVE.W  #0,D7
    MOVE.W  $80801010,D2
    MOVE.L  A3,D1
    MOVE.L  #$78768811,D1
    ***********************
    NOT.B   D1
    NOT.B   (A3)+
    NOT.B   $1012
    NOT.W   $55(SP)
    NOT.L   $80818283
    NOT.W   -(A7)
    ***********************
    NOP                      
    ***********************
    RTS                      
    ***********************
    JSR     $1000
    JSR     (A4)
    JSR     $88(A4)
    ***********************
    ***********************
    LEA     $6789,A0
    LEA     $28820012,A7
    LEA     $457C(A2),A0
    ***********************
    BEQ.B   $1050
    BEQ     $1000
    BLT     $1002
    ***********************
    MOVEQ   #$CC,D1
    ***********************
    OR.L    D1,D2
    OR.B    #3,D0
    OR.W    (A2)+,D5
    OR.W    D7,(A4)+
    ***********************
    SUB.B   $5679,D1
    *SUB.L   #257,D3
    *SUBI.L   #257,D3
    SUB.W   D0,-(A0)
    SUB.W   (A6),D7
    ***********************
    AND.B   $5679,D1
    AND.L   #9,D3
    AND.W   D0,-(A0)
    AND.W   (A6),D7
    ***********************
    ADD.B   $5679,D1
    *ADD.L   #9,D3
    *ADDI.L   #9,D3
    ADD.W   D0,-(A0)
    ADD.W   (A6),D7
    NOP                      
    ***********************
    ADDA.W  D1,A0
    ADDA.L  D3,A2
    ADDA.L  (A3),A1
    ADDA.L  (A7)+,A5
    ***********************
    ASR.B   #8,D0
    ASL.W   #1,D2
    ASR.L   #5,D7
    ASR.B   #7,D1
    ASR.W   D0,D3
    ASR.L   #8,D5
    ASL.W   D7,D3
    ASL.L   #8,D5
    ASR     (A0)  
    ASR     $55(A0)  
    ASL     $4513(A0)  
    LSL.B   #1,D0
    LSL.W   D1,D3
    LSR.L   #8,D2
    LSR.L   D5,D6
    LSL     (A7)
    LSR     $1067(A6)
    ROR.L   #4,D0
    ROL.B   #8,D7
    ROR.W   D3,D2
    ROL     (A4)
    ROR     $7456(A1)
    ********************************************************
MAIN:
    MOVEA.L #$00100000,SP
    
    JSR     io_printwelcome             ; SHOW WELCOME
MAINLOOP:
    JSR     io_askoption                ; SHOW OPTIONS AND HALT IF ASKED

    JSR     io_enterstart               ; PROMPT START
    JSR     io_read_address             ; READ ADDRESS
    CMP.B   #0,D0                       ; CHECK IF READ OK
    BEQ     MAINLOOP                    ; NOT READ THEN REPEAT
    BTST    #0,D1                       ; TEST IF EVEN
    BEQ     MAINOK0                     ; IF EVEN CONTINUE
    JSR     io_showmsgbadaddr01         ; ELSE SHOW MESSAGE
    JMP     MAINLOOP                    ; REPEAT
MAINOK0:
    MOVE.L  D1,(addrstart)              ; SAVE START ADDRRESS

    JSR     io_enterend                 ; PROMPT END
    JSR     io_read_address             ; READ ADDRESS
    CMP.B   #0,D0                       ; CHECK IF READ OK
    BEQ     MAINLOOP                    ; NOT READ THEN REPEAT
    CMP.L   (addrstart),D1              ; COMPARE WITH START
    BGE     MAINOK1                     ; IF START <= END CONTINUE
    JSR     io_badorder                 ; IF START > END SHOW MESSAGE AND REPEAT
    JMP     MAINLOOP
MAINOK1:

    MOVE.L  D1,(addrend)                ; SAVE START ADDRESS
    MOVE.L  (addrstart),(addrnext)      ; SET POINTER TO START ADDRESS
    MOVE.W  #30,(linecnt0)              ; SET linecnt0

    
MAINLOOP02:
    
    MOVE.L  (addrnext),-(SP)            ; SET PARAMETER (ADDRESS)
    MOVE.W  #8,-(SP)                    ; NUMBER OF DIGIT TO SHOW
    JSR     io_printhexl                ; PRINT HEXADECIMAL WORD
    ADDA.L  #6,SP                       ; FREE PARAMETERS
    
    JSR     opcode_subroutine           ; CALL TO DECODE NEXT OPCODE
    CMP.B   #0,D0                       ; CHECK RESULT
    BNE     MAINLOOP02NEXT              ; IF SUCEESSFULLY DECODE, NEXT
    
    JSR     io_showdata
    
MAINLOOP02NEXT:
    SUBI.W  #1,linecnt0
    BNE     MAINLOOP02NEXT2
    JSR     io_waitcr
    MOVE.W  #30,(linecnt0)              ; SET linecnt0
    
    
MAINLOOP02NEXT2:
    JSR     io_printnewline
    MOVE.L  (addrend),D0                ; LOAD CURRENT POINTER
    CMP.L   (addrnext),D0               ; CHECK FOR END
    BGE     MAINLOOP02                  ; IF ADDREND >= ADDRNEXT REPEAT
    BRA     MAINLOOP                    ; REPEAT DISASSEMBLE LOOP



    MOVE.L  D1,(addrend)                ; SAVE START ADDRRESS

    SIMHALT             ; halt simulator

    ; do some initial setup work
    ; call functions defined in subroutines

    ; you can define more subroutines
    INCLUDE 'opcode_subroutine.x68'
    INCLUDE 'ea_subroutine.x68'
    INCLUDE 'io_subroutine.x68'
    INCLUDE 'variables.x68'
    INCLUDE 'strings.x68'
STOP:
    END    MAIN






























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
