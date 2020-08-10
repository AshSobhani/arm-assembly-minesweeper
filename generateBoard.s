        B main

; Our board 
; 0, represents an empty space
; 1-8 represents the number of bombs around us
; 66 represents there is a bomb at this location
; No more than 8 bombs
board   DEFW  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
space   DEFB    "    " ,0
seed    DEFW    0xC0FFEE
magic   DEFW    65539
mask    DEFW    0x7FFFFFFF

        ALIGN
main    MOV R13, #0x10000
        ADR R0, board 
        BL generateBoard

        ADR R0, board
        BL printBoard
        SWI 2

; generateBoard
; Input R0 -- array to generate board in
generateBoard
        MOV R6, R0                      ;Putting board (array) address into register
        LDR R1, seed                    ;Seed for generating random number
        LDR R2, magic                   ;Used for random number
        LDR R3, mask                    ;Used for random
        MOV R4, #0                      ;Loop iteration variable
        MOV R5, #66                     ;Mine

        STMFD R13!, {R14}

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

        LDMFD R13!, {PC}

; printBoard -- print the board 
; Input: R0 <-- Address of board
printBoard
        MOV R1, R0
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
        ADD R2, R2, #1

        ADD R0, R0, #48
        CMP R0, #48
        SUBEQ R0, R0, #16
        CMP R0, #114
        SUBEQ R0, R0, #37

        SWI 0
        
        MOV R3, R2
        CMP R2, #63
        BLE loopP

        MOV PC, R14

; randu -- Generates a random number
; Input: None
; Ouptut: R0 -> Random number
randu
        MUL R1, R1, R2
        AND R1, R1, R3
        MOV R0, R1
        
        MOV PC, R14