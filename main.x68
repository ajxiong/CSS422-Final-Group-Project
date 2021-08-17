*-----------------------------------------------------------
* Title      : Main File
*-----------------------------------------------------------
    ORG $1000
    JMP     MAIN                        ; SKIP TEXT
    BHI     MAIN                        ; SKIP TEXT
    ASR.B   #1, D0
    ASR.W   #1, D0
    ASR.L   #1, D0
    ASR.L   D0
    NOP                                 ; TEST
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
    SUBA.L  #6,SP                       ; FREE PARAMETERS
    
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
