        B main

; Our board:
; 0, represents an empty space
; 1-8 represents the number of bombs around us
; 66 represents there is a bomb at this location
; No more than 8 bombs
board   DEFW     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
boardMask
        DEFW    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
seed    DEFW    0xC0FFEE
mult    DEFW    65539
mask    DEFW    0x7FFFFFFF
clear   DEFW    0x2EE
winMsg  DEFB    "You successfully uncovered all the squares while avoiding all the mines...\n",0
space   DEFB    "    " ,0
remain  DEFB    "There are ",0
prompt  DEFB    "Enter square to reveal: ",0
remain2 DEFB    " squares remaining.",0
already DEFB    "That square has already been revealed...",0
loseMsg DEFB    "You stepped on a mine, you lose!\n",0

        ALIGN

main    MOV R13, #0x10000
        
        ADR R8, board
        ADR R9, boardMask
        BL generateBoard
        
revA    BL clearScreen
        BL printMaskedBoard

        MOV R0, #10
        SWI 0
        ADR R0, remain
        SWI 3

        MOV R0, #0
        MOV R5, #0                      ;Reg for Iterating through board mask & looping

revC    LDR R7, [R9, R5, LSL #2]        ;Iterate through board mask to count unrevealed elements
        CMP R7, #-1                     ;If element is equal to 1 (unrevealed)
        ADDEQ R0, R0, #1                ;Add one to the counter

        ADD R5, R5, #1
        CMP R5, #63
        BLE revC
        MOV R4, R0                      ;Save unrevealed element count for the revA loop
        SUB R0, R0, #8
        SWI 4

        ADR R0, remain2
        SWI 3

        MOV R0, #10
        SWI 0
        ADR R0, prompt                  ;Ask the user to chose an element on the board
        SWI 3

tryA    BL boardSquareInput             ;Take the users chose element
        LDR R7, [R9, R0, LSL #2]        ;Load the chosen element
        CMP R7, #0                      ;Check if its unrevealed
        MOVEQ R0, #10
        SWIEQ 0
        ADREQ R0, already               ;If true, ask for another value
        SWIEQ 3
        BEQ tryA
        MOV R5, R0
            
        MOV R6, #0                      ;Reg for putting the value of zero in board mask to reveal
        STR R6, [R9, R5, LSL #2]        ;Change value of x element in board mask to 0

        LDR R7, [R8, R5, LSL #2]        ;Load the revealed element
        CMP R7, #66                     ;Check if its a mine
        MOVEQ R0, #10
        SWIEQ 0
        ADREQ R0, loseMsg               ;If true, you lose
        SWIEQ 3
        SWIEQ 2

        CMP R4, #9                      ;Check if all non mine elements have been revealed
        BGT revA                        ;If false, loop back

        MOV R0, #10
        SWI 0
        ADR R0, winMsg                  ;You win
        SWI 3

        SWI 2

; clearScreen : Clear the screen
; Input:  none
; Output: none

clearScreen
        LDR R1, clear

loopD   MOV R0, #8
        SWI 0

        SUB R1, R1, #1
        CMP R1, #0
        BGE loopD

        MOV PC, R14

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

; printMaskedBoard -- print the board 
; Input: R0 <-- Address of board
;        R1 <-- Address of board Mask

printMaskedBoard
        STMFD R13!, {R4-R6, R14}

        MOV R5, R9
        MOV R1, R8       
        MOV R2, #0
        MOV R3, #0
        MOV R4, #0

        MOV R0, #' '
        SWI 0
loopT   ADR R0, space
        SWI 3

        ADD R4, R4, #1
        MOV R0, R4
        SWI 4
        CMP R4, #8
        BLT loopT

        MOV R0, #0
        MOV R4, #64

loopP   AND R3, R3, #7
        CMP R3, #0
        MOVEQ R0, #10
        SWIEQ 0
        SWIEQ 0
        ADDEQ R4, R4, #1
        MOVEQ R0, R4
        SWIEQ 0

        ADR R0, space
        SWI 3

        LDR R0, [R1, R2, LSL #2]
        LDR R6, [R5, R2, LSL #2]
        CMP R6, #-1
        MOVEQ R0, #'*'
        ADD R2, R2, #1

        ADD R0, R0, #48
        CMP R0, #48
        SUBEQ R0, R0, #16
        CMP R0, #114
        SUBEQ R0, R0, #37
        CMP R0, #90
        SUBEQ R0, R0, #48

        SWI 0
        
        MOV R3, R2
        CMP R2, #63
        BLE loopP

        LDMFD R13!, {R4-R6, PC}

; generateBoard
; Input R0 -- array to generate board in

generateBoard
        STMFD R13!, {R4-R7, R10, R14}

        MOV R6, R8                      ;Putting board (array) address into register
        LDR R1, seed                    ;Seed for generating random number
        LDR R2, mult                    ;Used for random number
        LDR R3, mask                    ;Used for random
        MOV R4, #0                      ;Loop iteration variable
        MOV R5, #66                     ;Mine

ranL    BL randu
        MOV R0, R0 ASR #8               ; shift R0 right by 8 bits
        AND R0, R0, #0x3f               ; take the modulo by 64
        
        LDR R7, [R6, R0, LSL #2]        ;Check for double values
        CMP R7, #66
        BEQ ranL
        
        STR R5, [R6, R0, LSL #2]        ;Store the value 66 into random array position respectively

        ADD R4, R4, #1
        CMP R4, #7
        BLE ranL

        MOV R10, #0                     ;Loop iteration variable

aryL    LDR R1, [R6, R10, LSL #2]       ;Load element x into R1
        CMP R1, #66                     ;Check if its not a mine
        BNE skipC

gRN     ADD R5, R10, #1                ;Right Neighbour
        LDR R1, [R6, R5, LSL #2]
        AND R2, R10, #7
        CMP R2, #7                     ;Check if its on the last column
        BEQ gLN                        ;If true skip section
        CMP R1, #66                    ;Check if there is a mine in that location
        BEQ gLN                        ;If true skip section
        ADD R1, R1, #1                 ;Add the value of 1
        STR R1, [R6, R5, LSL #2]       ;And store in that element

gLN     SUB R5, R10, #1                ;Left Neighbour
        LDR R1, [R6, R5, LSL #2]
        AND R2, R10, #7                ;Check if its on the first column
        CMP R2, #0                     ;If true skip section
        BEQ gTR
        CMP R1, #66
        BEQ gTR
        ADD R1, R1, #1
        STR R1, [R6, R5, LSL #2]

gTR     SUB R5, R10, #7                ;Top 3 Neighbours (Top Right)
        LDR R1, [R6, R5, LSL #2]
        CMP R10, #8                    ;Check if its on the top row
        BLE gBL                        ;If true skip section
        AND R2, R10, #7
        CMP R2, #7
        BEQ gTM
        CMP R1, #66
        BEQ gTM
        ADD R1, R1, #1
        STR R1, [R6, R5, LSL #2]

gTM     SUB R5, R10, #8                ;Top 3 Neighbours (Top Mid)
        LDR R1, [R6, R5, LSL #2]
        CMP R10, #8
        BLE gTL
        CMP R1, #66
        BEQ gTL
        ADD R1, R1, #1
        STR R1, [R6, R5, LSL #2]

gTL     SUB R5, R10, #9                ;Top 3 Neighbours (Top Left)
        LDR R1, [R6, R5, LSL #2]
        CMP R10, #8
        BLE gBL
        AND R2, R10, #7
        CMP R2, #0
        BEQ gBL
        CMP R1, #66
        BEQ gBL
        ADD R1, R1, #1
        STR R1, [R6, R5, LSL #2]

gBL     ADD R5, R10, #7                ;Bottom 3 Neighbours (Bottom Left)
        LDR R1, [R6, R5, LSL #2]
        CMP R10, #56                   ;Check if its on the bottom row
        BGE gBM                        ;If true skip section
        AND R2, R10, #7
        CMP R2, #0
        BEQ gBM
        CMP R1, #66
        BEQ gBM
        ADD R1, R1, #1
        STR R1, [R6, R5, LSL #2]

gBM     ADD R5, R10, #8                ;Bottom 3 Neighbours (Bottom Mid)
        LDR R1, [R6, R5, LSL #2]
        CMP R10, #56
        BGE gBR
        CMP R1, #66
        BEQ gBR
        ADD R1, R1, #1
        STR R1, [R6, R5, LSL #2]

gBR     ADD R5, R10, #9                ;Bottom 3 Neighbours (Bottom Right)
        LDR R1, [R6, R5, LSL #2]
        CMP R10, #56
        BGE skipC
        AND R2, R10, #7
        CMP R2, #7
        BEQ skipC
        CMP R1, #66
        BEQ skipC
        ADD R1, R1, #1
        STR R1, [R6, R5, LSL #2]

skipC   ADD R10, R10, #1
        CMP R10, #63
        BLE aryL

        LDMFD R13!, {R4-R7, R10, PC}

; randu -- Generates a random number
; Input: None
; Ouptut: R0 -> Random number

randu   
        MUL R1, R1, R2
        AND R1, R1, R3
        MOV R0, R1
        
        MOV PC, R14