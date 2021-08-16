        
    ;SUBROUTINE: io_showdata -----------------------------------------
    ;   SHOW WELCOME MESSAGE
    ;-----------------------------------------------------------------
io_showdata:
    LEA     msgdata01, A1       ; LOAD STRING ADDRESS
    MOVE    #14,D0              ; PRINT STRING
    TRAP    #15                 ; TRAP 15
    
    MOVEA.L addrnext,A0                 ; LOAD POINTER
    MOVE.W  (A0),D0                     ; LOAD WORD VALUE
    MOVE.L  D0,-(SP)                    ; SET PARAMETER (VALUE)
    MOVE.W  #4,-(SP)                    ; NUMBER OF DIGIT TO SHOW
    JSR     io_printhexl                ; PRINT HEXADECIMAL WORD
    ADDA.L  #6,SP                       ; FREE PARAMETERS
    
    ADD.L   #2,(addrnext)               ; INCREMENT POINTER
    
    RTS                         ; RETURN

    ;SUBROUTINE: io_printwelcome -------------------------------------
    ;   SHOW WELCOME MESSAGE
    ;-----------------------------------------------------------------
io_printhexl:
    LEA     strtmp01,A1         ; TEMPORAL STRING
    MOVE.W  4(SP),D0            ; LOAD DIGIT COUNT
    EXT.L   D0                  ; MAKE LONGWORD
    ADDA    D0,A1               ; ADD TO TEMPORAL STRING POINTER
    MOVE.B  #0,0(A1)            ; MARK END OF STRING
    
    MOVE.L  6(SP),D1            ; LOAD VALUE TO SHOW

io_printhexlLOOP:    
    MOVE.L  D1,D0               ;
    ANDI.L  #15,D0              ;
    MOVE.L  D0,A0               ;
    MOVE.B  HEXDIGITS(A0),-(A1) ;
    LSR.L   #4,D1               ;
    SUBI.W  #1,4(SP)            ;
    BNE     io_printhexlLOOP    ;
    
    LEA     strtmp01,A1         ; TEMPORAL STRING
    MOVE    #14,D0              ; PRINT STRING
    TRAP    #15                 ; TRAP 15
    
    RTS                         ; RETURN
    
    ;SUBROUTINE: io_showmsgbadaddr01----------------------------------
    ;   SHOW WELCOME MESSAGE
    ;-----------------------------------------------------------------
io_showmsgbadaddr01:
    LEA     msgbadaddr01, A1    ; LOAD STRING ADDRESS
    MOVE    #14,D0              ; PRINT STRING
    TRAP    #15                 ; TRAP 15
   
    rts                         ; RETURN
        
    ;SUBROUTINE: io_printnewline--------------------------------------
    ;   SHOW WELCOME MESSAGE
    ;-----------------------------------------------------------------
io_printnewline:
    LEA     NEWLINE, A1         ; LOAD STRING ADDRESS
    MOVE    #14,D0              ; PRINT STRING
    TRAP    #15                 ; TRAP 15
    RTS                         ; RETURN
    
    ;SUBROUTINE: io_printwelcome -------------------------------------
    ;   SHOW WELCOME MESSAGE
    ;-----------------------------------------------------------------
io_printwelcome:
    LEA     msgwelcome01, A1    ; LOAD STRING ADDRESS
    MOVE    #14,D0              ; PRINT STRING
    TRAP    #15                 ; TRAP 15
    RTS                         ; RETURN
    
    ;SUBROUTINE: io_enterstart ---------------------------------------
    ;   SHOW WELCOME MESSAGE
    ;-----------------------------------------------------------------
io_enterstart:
    LEA     msgaskstart, A1     ; LOAD STRING ADDRESS
    MOVE    #14,D0              ; PRINT STRING
    TRAP    #15                 ; TRAP 15
    RTS                         ; RETURN
    
    ;SUBROUTINE: io_enterend -----------------------------------------
    ;   SHOW WELCOME MESSAGE
    ;-----------------------------------------------------------------
io_enterend:
    LEA     msgaskend, A1       ; LOAD STRING ADDRESS
    MOVE    #14,D0              ; PRINT STRING
    TRAP    #15                 ; TRAP 15
    RTS                         ; RETURN
     
    ;SUBROUTINE: io_enterend -----------------------------------------
    ;   SHOW WELCOME MESSAGE
    ;-----------------------------------------------------------------
io_badorder:
    LEA     msgbadorder, A1     ; LOAD STRING ADDRESS
    MOVE    #14,D0              ; PRINT STRING
    TRAP    #15                 ; TRAP 15
    RTS                         ; RETURN
    
    ;SUBROUTINE: io_askoption-----------------------------------------
    ;    ASK OPTION: DISASSEMBLE, QUIT
    ;    AND IF USER ASK TO QUIT THEN HALT
    ;-----------------------------------------------------------------
io_askoption:
    LEA     msgpromptopc, A1    ; LOAD STRING ADDRESS
    MOVE    #14,D0              ; PRINT STRING
    TRAP    #15                 ; TRAP 15
    
    MOVE    #5,D0               ; READ SINGLE ASCII CHARACTER
    TRAP    #15                 ; TRAP # 15
    CMP.B   #'2', D1            ; COMPARE WITH QUIT OPTION
    BEQ     io_askoption_halt   ; IF QUIT THEN HALT
    CMP.B   #'1', D1            ; COMPARE WITH DISASSEMBLE OPTION
    BEQ     io_askoption_ret    ; IF DISASSEMBLE THE RETURN
    
            ; NO VALID OPTION, THEN INFORM AND REPEAT
    LEA     msgbadopc, A1       ; LOAD STRING ADDRESS
    MOVE    #14, D0             ; PRINT STRING
    TRAP    #15                 ; TRAP 15
    
    JMP     io_askoption        ; REPEAT ASK OPTION
io_askoption_halt:
    ; show byte before halt
    LEA     msgbye,A1           ; LOAD STRING ADDRESS
    MOVE    #14, D0             ; PRINT STRING
    TRAP    #15                 ; TRAP 15
    
    
    SIMHALT                     ; halt simulator
    
io_askoption_ret:
    RTS                         ; RETURN
    

    ;SUBROUTINE: io_read_address-----------------------------------------
    ;   READ A ADDRESS UP TO 8 HEXADECIMAL DIGITS (LONG WORD)
    ;   RETURN D0.B = 1 READ OK, 0 NOT READ, D1 = VALUE IF READ OK
    ;-----------------------------------------------------------------
io_read_address:
    MOVE.L  D4,-(SP)            ; SAVE D4
    MOVE.L  D5,-(SP)            ; SAVE D5
    
    LEA     strtmp01,A1         ; TEMPORAL STRING ADDRESS
    MOVE    #2,D0               ; READ ASCII STRING
    TRAP    #15                 ; TRAP #15
    
    CMP.W   #0,D1               ; MAX 8 DIGITS
    BEQ     io_read_address_badr ; SHOULD BE AT LEAST 1 DIGIT
    
    CMP.W   #8,D1               ; MAX 8 DIGITS
    BGT     io_read_address_badr ; SHOULD BE UP TO 8 DIGITS

    LEA     strtmp01,A1         ; TEMPORAL STRING ADDRESS
    MOVE.B  #0,D4               ; DIGIT COUNTER
    MOVE.L  #0,D5               ; ADDRESS VALUE = 0
io_rdaddr_loop1:
    MOVE.B  (A1)+,D1            ; LOAD CHARACTER FROM TEMPORAL STRING
    CMP.B   #0,D1               ; COMPARE WITH 0 (END OF STRING)
    BNE     io_rdaddr_ckdec     ; IF NOT CR CHECK FOR DECIMAL DIGITS 0 TO 9

    CMP.B   #0,D4               ; COMPARE DIGIT COUNTER WITH ZERO
    BEQ     io_read_address_badr    ; ENDED WITH NO INPUT
    JMP     io_read_address_ok  ; ENDED WITH SOME DIGITS

io_rdaddr_ckdec:
    CMP.B   #'0',D1             ; COMPARE WITH 0
    BLT     io_read_address_bad ; IF < 0 THEN BAD DIGIT
    CMP.B   #'9',D1             ; COMPARE WITH 9
    BGT     io_rdaddr_ckhex1    ; IF > 9 CHECK HEX A-F
    SUB.B   #48,D1              ; MAKE NUMBER 0-9
    LSL.L   #4,D5               ; MAKE SPACE IN THE LOWER 4 BITS TO INSERT THE NEW HEX DIGITS
    OR.B    D1,D5               ; SET BITS
    BRA     io_rdaddr_next      ; GO TO NEXT

io_rdaddr_ckhex1:
    CMP.B   #'A',D1             ; COMPARE WITH A
    BLT     io_read_address_bad ; IF < A THEN BAD DIGIT
    CMP.B   #'F',D1             ; COMPARE WITH F
    BGT     io_rdaddr_ckhex2    ; IF > F CHECK HEX a-f
    SUB.B   #55,D1              ; MAKE NUMBER 10-15
    LSL.L   #4,D5               ; MAKE SPACE IN THE LOWER 4 BITS TO INSERT THE NEW HEX DIGITS
    OR.B    D1,D5               ; SET BITS
    BRA     io_rdaddr_next      ; GO TO NEXT

io_rdaddr_ckhex2:
    CMP.B   #'a',D1             ; COMPARE WITH A
    BLT     io_read_address_bad ; IF < a THEN BAD DIGIT
    CMP.B   #'f',D1             ; COMPARE WITH F
    BGT     io_read_address_bad ; IF > f CHECK BAD DIGIT
    SUB.B   #87,D1              ; MAKE NUMBER 10-15
    LSL.L   #4,D5               ; MAKE SPACE IN THE LOWER 4 BITS TO INSERT THE NEW HEX DIGITS
    OR.B    D1,D5               ; SET BITS
    
io_rdaddr_next:
    ADD.B   #1,D4               ; INCRMENT DIGIT COUNTER
    CMP.B   #8,D4               ; COMPARE WITH MAX DIGITS
    BNE     io_rdaddr_loop1     ; IF NOT MAX DIGIT, REPEAT
    JMP     io_read_address_ok  ; IF MAX DIGIT RETURN READ OK
    
    
io_read_address_bad:
    LEA     msghexbad,A1        ; LOAD STRING ADDRESS
    MOVE    #14,D0              ; PRINT STRING
    TRAP    #15                 ; TRAP 15
    
    MOVE.B  #0,D0               ; NOT READ
    MOVE.L  (SP)+,D5            ; RESTORE D5
    MOVE.L  (SP)+,D4            ; RESTORE D4
    RTS                         ; RETURN
io_read_address_badr:
    LEA     msghexbadr,A1       ; LOAD STRING ADDRESS
    MOVE    #14,D0              ; PRINT STRING
    TRAP    #15                 ; TRAP 15
    
    MOVE.B  #0,D0               ; RETURN NOT READ
    MOVE.L  (SP)+,D5            ; RESTORE D5
    MOVE.L  (SP)+,D4            ; RESTORE D4
    RTS
io_read_address_ok:
    MOVE.B  #1,D0               ; RETURN READ OK
    MOVE.L  D5,D1               ; RETURN READ ADDRESS
    MOVE.L  (SP)+,D5            ; RESTORE D5
    MOVE.L  (SP)+,D4            ; RESTORE D4
    RTS                         ; RETURN







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
