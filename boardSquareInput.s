        B main

prompt  DEFB "Enter square to reveal: ",0
mesg    DEFB "You entered the index ",0

    ALIGN

main    ADR R0, prompt
        SWI 3
        BL boardSquareInput

        MOV R1, R0
        MOV R0, #10
        SWI 0
        ADR R0, mesg
        SWI 3
        MOV R0,R1
        SWI 4
        MOV R0,#10
        SWI 0
        SWI 2


; boardSquareInput -- read board position from keyboard
; Input:  R0 ---> prompt string address
; Ouptut: R0 <--- index

boardSquareInput
        MOV R1, #0
        B inp

error   MOV R1, #0
        MOV R0, #10
        SWI 0
        ADR R0, prompt
        SWI 3
        
inp     ADD R1, R1, #1
        SWI 1 ; Take the users input
        CMP R1, #1
        BEQ let
        CMP R1, #2
        BEQ num
        CMP R1, #3
        BEQ ret

        ADD R1, R1, #1
        CMP R1, #3
        BLT inp
        
        B boardSquareInput    

let     CMP R0, #65
        BLT error
        CMP R0, #104
        BGT error
        CMP R0, #72
        BLE cor
        CMP R0, #97
        BLT error
cor     SWI 0
        MOV R2, R0
        B inp

num     CMP R0, #49
        BLT error
        CMP R0, #56
        BGT error
        SWI 0
        MOV R3, R0
        B inp

ret     CMP R0, #10
        BEQ return
        B error

return  MOV R0, #8

        CMP R2, #72
        SUBLE R2, R2, #65
        SUBGT R2, R2, #97

        SUB R3, R3, #49
        MUL R2, R2, R0

        ADD R0, R2, R3
        MOV PC, R14