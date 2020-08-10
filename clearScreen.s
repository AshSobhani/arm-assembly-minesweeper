    B main

test    DEFB "A message to fill the screen\n",0
prompt  DEFB "Press any key to clear the screen...\n",0
numC    DEFW 0x1D7

    ALIGN
main    MOV R7,#15
mLoop   ADR R0, test
        SWI 3
        SUBS R7,R7, #1
        BNE mLoop

        ADR R0, prompt
        SWI 3
        SWI 1
        BL clearScreen
        SWI 2

; clearScreen : Clear the screen
; Input:  none
; Output: none
clearScreen
        
        LDR R1, numC

loopD   MOV R0, #8
        SWI 0

        SUB R1, R1, #1
        CMP R1, #0
        BGE loopD

        MOV PC, R14