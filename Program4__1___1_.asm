;***********************************************************
; Programming Assignment 4
; Student Name: 
; UT Eid:
; -------------------Save Simba (Part II)---------------------
; This is the starter code. You are given the main program
; and some declarations. The subroutines you are responsible for
; are given as empty stubs at the bottom. Follow the contract. 
; You are free to rearrange your subroutines if the need were to 
; arise.

;***********************************************************

.ORIG x4000

;***********************************************************
; Main Program
;***********************************************************
        JSR   DISPLAY_JUNGLE
        LEA   R0, JUNGLE_INITIAL
        TRAP  x22 
        LDI   R0,BLOCKS
        JSR   LOAD_JUNGLE
        JSR   DISPLAY_JUNGLE
        LEA   R0, JUNGLE_LOADED
        TRAP  x22                        ; output end message
HOMEBOUND
        LEA   R0, LC_OUT_STRING
        TRAP  x22
        LDI   R0,LC_LOC
        LD    R4,ASCII_OFFSET_POS
        ADD   R0, R0, R4
        TRAP  x21
        LEA   R0,PROMPT
        TRAP  x22
        TRAP  x20                        ; get a character from keyboard into R0
        TRAP  x21                        ; echo character entered
        LD    R3, ASCII_Q_COMPLEMENT     ; load the 2's complement of ASCII 'Q'
        ADD   R3, R0, R3                 ; compare the first character with 'Q'
        BRz   EXIT                       ; if input was 'Q', exit
;; call a converter to convert i,j,k,l to up(0) left(1),down(2),right(3) respectively
        JSR   IS_INPUT_VALID      
        ADD   R2, R2, #0                 ; R2 will be zero if the move was valid
        BRz   VALID_INPUT
        LEA   R0, INVALID_MOVE_STRING    ; if the input was invalid, output corresponding
        TRAP  x22                        ; message and go back to prompt
        BRnzp    HOMEBOUND
VALID_INPUT                 
        JSR   APPLY_MOVE                 ; apply the move (Input in R0)
        JSR   DISPLAY_JUNGLE
        JSR   SIMBA_STATUS      
        ADD   R2, R2, #0                 ; R2 will be zero if reached Home or -1 if Dead
        BRp  HOMEBOUND                     ; otherwise, loop back
EXIT   
        LEA   R0, GOODBYE_STRING
        TRAP  x22                        ; output a goodbye message
        TRAP  x25                        ; halt
JUNGLE_LOADED       .STRINGZ "\nJungle Loaded\n"
JUNGLE_INITIAL      .STRINGZ "\nJungle Initial\n"
ASCII_Q_COMPLEMENT  .FILL    x-71    ; two's complement of ASCII code for 'q'
ASCII_OFFSET_POS        .FILL    x30
LC_OUT_STRING    .STRINGZ "\n LIFE_COUNT is "
LC_LOC  .FILL LIFE_COUNT
PROMPT .STRINGZ "\nEnter Move up(i) \n left(j),down(k),right(l): "
INVALID_MOVE_STRING .STRINGZ "\nInvalid Input (ijkl)\n"
GOODBYE_STRING      .STRINGZ "\n!Goodbye!\n"
BLOCKS               .FILL x5500

;***********************************************************
; Global constants used in program
;***********************************************************
;***********************************************************
; This is the data structure for the Jungle grid
;***********************************************************
GRID .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
  
;***********************************************************
; this data stores the state of current position of Simba and his Home
;***********************************************************
CURRENT_ROW        .BLKW   #1       ; row position of Simba
CURRENT_COL        .BLKW   #1       ; col position of Simba 
HOME_ROW           .BLKW   #1       ; Home coordinates (row and col)
HOME_COL           .BLKW   #1
LIFE_COUNT         .FILL   #1       ; Initial Life Count is One
                                    ; Count increases when Simba
                                    ; meets a Friend; decreases
                                    ; when Simba meets a Hyena
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
; The code above is provided for you. 
; DO NOT MODIFY THE CODE ABOVE THIS LINE.
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************

;***********************************************************
LOAD_JUNGLE

    ; Save registers R1 through R7
    ST R1, LSaveR1
    ST R2, LSaveR2
    ST R3, LSaveR3
    ST R4, LSaveR4
    ST R5, LSaveR5
    ST R6, LSaveR6
    ST R7, LSaveR7
    
    ; Assume R0 contains the address of the head of the linked list
    ADD R3, R0, #0          ; Set R3 to the head address

LOOP
    ; Load row, column, and character from current record
    LDR R1, R3, #1          ; Load row into R1
    LDR R2, R3, #2          ; Load column into R2
    LDR R5, R3, #3          ; Load character (type) into R5

    ; Convert (row, col) to grid address
    JSR GRID_ADDRESS        ; GRID_ADDRESS outputs address in R0

    ; Check and process character (I, H, F, or #)
    LD R4, H_Code23
    NOT R4, R4 
    ADD R4, R4, #1; Negate H_Code
    ADD R6, R5, R4
    BRz Set_Home           ; If R5 equals H_Code, go to Set_Home

    ; Compare with I_Code
    LD R4, I_Code45
    NOT R4, R4  
    ADD R4, R4, #1; Negate I_Code
    ADD R6, R5, R4
    BRz Set_Initial        ; If R5 equals I_Code, go to Set_Initial

    ; Compare with F_Code
    LD R4, F_Code23
    NOT R4, R4   
    ADD R4, R4, #1; Negate F_Code
    ADD R6, R5, R4
    BRz Set_Friend         ; If R5 equals F_Code, go to Set_Friend

    ; Compare with Hash_Code
    LD R4, Hash_Code23
    NOT R4, R4 
    ADD R4, R4, #1; Negate Hash_Code
    ADD R6, R5, R4
    BRz Set_Hyena          ; If R5 equals Hash_Code, go to Set_Hyena

next15
    ; Move to the next node after processing the current one
    LDR R4, R3, #0         ; Load next link address into R4
    BRz DONE               ; If R4 is zero, end the loop
    ADD R3, R4, #0         ; Update R3 to the next linked list node
    BR LOOP    
    ; Continue loop
            ; Go to next record
Set_Home
    STR R5, R0, #0         ; Store character in grid
    ST R1, HOME_ROW        ; Save row to HOME_ROW
    ST R2, HOME_COL        ; Save col to HOME_COL
    BR next15                ; Go to next record

  Set_Initial
    LD R5, Star_Code23       ; Set character to *
    STR R5, R0, #0         ; Store * in grid
    ST R1, CURRENT_ROW     ; Save row to CURRENT_ROW
    ST R2, CURRENT_COL     ; Save col to CURRENT_COL
    BR next15  

Set_Friend
    STR R5, R0, #0         ; Store character in grid
    BR next15                ; Go to next record

Set_Hyena
    STR R5, R0, #0         ; Store character in grid
    BR next15                ; Go to next record

DONE
    ; Restore registers R1 through R7
    LD R1, LSaveR1
    LD R2, LSaveR2
    LD R3, LSaveR3
    LD R4, LSaveR4
    LD R5, LSaveR5
    LD R6, LSaveR6
    LD R7, LSaveR7
    JMP R7                 ; Return to caller
I_Code45 .FILL #73
H_Code23 .FILL #72
F_Code23 .Fill #70
Star_Code23 .FILL #42
Hash_Code23 .Fill #35
LSaveR1 .BLKW #1
LSaveR2 .BLKW #1
LSaveR3 .BLKW #1
LSaveR4 .BLKW #1
LSaveR5 .BLKW #1
LSaveR6 .BLKW #1
LSaveR7 .BLKW #1
Life_CountL .Fill Life_Count
HOME_ROWL  .Fill HOME_ROW
HOME_COLL  .Fill HOME_COL



APPLY_MOVE   
ST R0, AValidR0
ST R1, AValidR1
ST R3, AValidR3
ST R4, AValidR4
ST R5, AValidR5
ST R6, AValidR6
ST R7, AValidR7
; Your New (Program4) code goes here
    JSR, CAN_MOVE 
    ADD R2, R1, #0
    Brn, Invalid1
    LD R3, I_CharN2
    ADD R4, R0, R3
    brnp, checkA
    LD R1, CURRENT_ROW
    LD R2, CURRENT_COL
    JSR, GRID_ADDRESS
    LD R3, SPACE
    STR R3, R0, #0
    
    ADD R0, R0, #-15
     ADD R0, R0, #-3
    
    STR R3, R0, #0
    ADD R0, R0, #-15
    ADD R0, R0, #-3
    ; check if we run into anything 
    LDR R5, R0, #0
    ; check for friend hienah
    ;if friend life count + 1
    ; if heinah life count - 1
    LD R3, H_Code222
    ADD R6, R5, R3
    brnp checkF
    LD R4, LIFE_COUNT
    ADD R4, R4, #-1
    ST R4, LIFE_COUNT
    LD R4, SPACE
    STR R4, R0, #0
    br, default 
    
     checkF LD R3, F_Code2
    ADD R6, R5, R3
    brnp default
    LD R4, LIFE_COUNT
    ADD R4, R4, #1
    ST R4, LIFE_COUNT
    LD R4, SPACE
    STR R4, R0, #0
    br, default 
    
    
   default LD R1, CURRENT_ROW
    ADD R1, R1, #-1
    ST R1, CURRENT_ROW
    JSR GRID_ADDRESS
    JSR, SIMBA_STATUS
    ADD R3, R2, #0
    Brn, Deadddd
    LD R3, Initials
    STR R3, R0, #0
    Br, ending
    
    ;J 
    
     checkA LD R3, J_CharN2
     ADD R4, R0, R3
     brnp, checkB
    LD R1, CURRENT_ROW
    LD R2, CURRENT_COL
     JSR, GRID_ADDRESS
     LD R3, SPACE
     STR R3, R0, #0
    
     ADD R0, R0, #-1
    
    
     STR R3, R0, #0
     ADD R0, R0, #-1
   
    ; ; check if we run into anything 
     LDR R5, R0, #0
    ; ; check for friend hienah
    ; ;if friend life count + 1
    ; ; if heinah life count - 1
     LD R3, H_Code222
     ADD R6, R5, R3
     brnp checkF1
     LD R4, LIFE_COUNT
     ADD R4, R4, #-1
     ST R4, LIFE_COUNT
     LD R4, SPACE
     STR R4, R0, #0
     br, default1
     
      checkF1 LD R3, F_Code2
    ADD R6, R5, R3
    brnp default1
    LD R4, LIFE_COUNT
    ADD R4, R4, #1
    ST R4, LIFE_COUNT
    LD R4, SPACE
    STR R4, R0, #0
    br, default1
     
     default1 LD R2, CURRENT_COL
    ADD R2, R2, #-1
     ST R2, CURRENT_COL
    JSR GRID_ADDRESS
    JSR, SIMBA_STATUS
     ADD R3, R2, #0
     Brn, Deadddd
    LD R3, Initials
    STR R3, R0, #0
    Br, ending
    
    ; ;K
    
    checkB LD R3, K_CharN2
     ADD R4, R0, R3
     brnp, checkC
    LD R1, CURRENT_ROW
    LD R2, CURRENT_COL
    JSR, GRID_ADDRESS
    LD R3, SPACE
    STR R3, R0, #0
    
    ADD R0, R0, #15
     ADD R0, R0, #3
    
    STR R3, R0, #0
    ADD R0, R0, #15
    ADD R0, R0, #3
    ; check if we run into anything 
    LDR R5, R0, #0
    ; check for friend hienah
    ;if friend life count + 1
    ; if heinah life count - 1
    LD R3, H_Code222
    ADD R6, R5, R3
    brnp checkF2
    LD R4, LIFE_COUNT
    ADD R4, R4, #-1
    ST R4, LIFE_COUNT
    LD R4, SPACE
    STR R4, R0, #0
    br, default 
    
     checkF2 LD R3, F_Code2
    ADD R6, R5, R3
    brnp default2
    LD R4, LIFE_COUNT
    ADD R4, R4, #1
    ST R4, LIFE_COUNT
    LD R4, SPACE
    STR R4, R0, #0
    br, default2
    
    
   default2 LD R1, CURRENT_ROW
    ADD R1, R1, #1
    ST R1, CURRENT_ROW
    JSR GRID_ADDRESS
    JSR, SIMBA_STATUS
    ADD R3, R2, #0
    Brn, Deadddd
    LD R3, Initials
    STR R3, R0, #0
    Br, ending
    
   ;L
     checkC 
     LD R1, CURRENT_ROW
    LD R2, CURRENT_COL
     JSR, GRID_ADDRESS
     LD R3, SPACE
     STR R3, R0, #0
    
     ADD R0, R0, #1
    
    
     STR R3, R0, #0
     ADD R0, R0, #1
   
    ; ; check if we run into anything 
     LDR R5, R0, #0
    ; ; check for friend hienah
    ; ;if friend life count + 1
    ; ; if heinah life count - 1
     LD R3, H_Code222
     ADD R6, R5, R3
     brnp checkF3
     LD R4, LIFE_COUNT
     ADD R4, R4, #-1
     ST R4, LIFE_COUNT
     LD R4, SPACE
     STR R4, R0, #0
     br, default3
     
      checkF3 LD R3, F_Code2
    ADD R6, R5, R3
    brnp default3
    LD R4, LIFE_COUNT
    ADD R4, R4, #1
    ST R4, LIFE_COUNT
    LD R4, SPACE
    STR R4, R0, #0
    br, default1
     
     default3 LD R2, CURRENT_COL
    ADD R2, R2, #1
     ST R2, CURRENT_COL
    JSR GRID_ADDRESS
    JSR, SIMBA_STATUS
     ADD R3, R2, #0
     Brn, Deadddd
    LD R3, Initials
    STR R3, R0, #0
    Br, ending
    
    
    
    ; Check diredction 
   
    Invalid1
  LEA R0,  Invalid_Message
  Trap x22
  Br, ending
  
  Deadddd
     LD R3, X_Code
    STR R3, R0, #0
    Br, ending
 
 ending LD R0, AValidR0
LD R1, AValidR1
LD R3, AValidR3
LD  R4, AValidR4
LD R5, AValidR5
LD R6, AValidR6
LD R7, AValidR7  
    
    
    
    JMP R7
     H_Code222 .Fill #-35
  F_Code2  .Fill #-70
 Invalid_Message .STRINGZ "Cannot Move"
 Initials .FILL #42
 SPACE .FILL #32
 H_Code2 .FILL #-72
 I_CharN2  .Fill #-105
 J_CharN2  .Fill #-106
 K_CharN2  .Fill #-107
 L_CharN2  .Fill #-108
 
AValidR0 .blkw #1
AValidR1 .blkw #1
AValidR3 .blkw #1
AValidR4 .blkw #1
AValidR5 .blkw #1
AValidR6 .blkw #1
AValidR7 .blkw #1


CURRENT_ROWL .Fill CURRENT_ROW
CURRENT_COLL .Fill CURRENT_COL

SIMBA_STATUS 
ST R0, SSaveR0
ST R1, SSaveR1
ST R3, SSaveR3
ST R4, SSaveR4
ST R5, SSaveR5
ST R6, SSaveR6
ST R7, SSaveR7
    ; Your code goes here
LD R5, Life_CountL
  LDR R1, R5, #0
  Brnp, checkEnd
  LD R2, Neg3
  LEA R0, Dead_Mes
  Trap x22
  
  br, finals
  checkEnd
   LD R1, HOME_ROWL
   LDR R1, R1, #0
   LD R2, HOME_COLL
    LDR R2, R2, #0
   LD R3, CURRENT_ROWL
   LDR R3, R3, #0
   LD R4, CURRENT_COLL
   LDR R4, R4, #0
   NOT R1,R1
   ADD R1, R1, #1
   ADD R5, R3, R1
   brnp, GameOn
   NOT R2, R2
   ADD R2, R2, #1
   brnp, GameOn
   AND R2, R2, #0
   LD R2, Zero_Vals
   LEA R0, Home_Mes
   Trap x22
   Br, finals
   GameOn
   LD R2, Positive
   br, finals
  
 finals LD R0, SSaveR0
LD R1, SSaveR1
LD R3, SSaveR3
LD R4, SSaveR4
LD R5, SSaveR5
LD R6, SSaveR6
LD R7, SSaveR7
    JMP R7
    H_Code1 .FILL #-72
    Zero_Vals .Fill #0
    X_Code .FILL #88
Positive .Fill #1
Neg3    .Fill #-1
Dead_Mes  .STRINGZ "Simba is Dead"
 Home_Mes .STRINGZ "Simba is Home"   
 SSaveR0 .blkw #1
 SSaveR1 .blkw #1
 SSaveR3 .blkw #1
 SSaveR4 .blkw #1
 SSaveR5 .blkw #1
 SSaveR6 .blkw #1
 SSaveR7 .blkw #1


; LOAD_JUNGLE
; Input:  R0  has the address of the head of a linked list of
;         gridblock records. Each record has four fields:
;       0. Address of the next gridblock in the list
;       1. row # (0-7)
;       2. col # (0-7)
;       3. Symbol (can be I->Initial,H->Home, F->Friend or #->Hyena)
;    The list is guaranteed to: 
;               * have only one Inital and one Home gridblock
;               * have zero or more gridboxes with Hyenas/Friends
;               * be terminated by a gridblock whose next address 
;                 field is a zero
; Output: None
;   This function loads the JUNGLE from a linked list by inserting 
;   the appropriate characters in boxes (I(*),#,F,H)
;   You must also change the contents of these
;   locations: 
;        1.  (CURRENT_ROW, CURRENT_COL) to hold the (row, col) 
;            numbers of Simba's Initial gridblock
;        2.  (HOME_ROW, HOME_COL) to hold the (row, col) 
;            numbers of the Home gridblock
;       
;***********************************************************


;***********************************************************
; CAN_MOVE
; This subroutine checks if a move can be made and returns 
; the new position where Simba would go to if the move is made. 
; To be able to make a move is to ensure that movement 
; does not take Simba off the grid; this can happen in any direction.
; In coding this routine you will need to translate a move to 
; coordinates (row and column). 
; Your APPLY_MOVE subroutine calls this subroutine to check 
; whether a move can be made before applying it to the GRID.
; Inputs: R0 - a move represented by 'i', 'j', 'k', or 'l'
; Outputs: R1, R2 - the new row and new col, respectively 
;              if the move is possible; 
;          if the move cannot be made (outside the GRID), 
;              R1 = -1 and R2 is untouched.
; Note: This subroutine does not check if the input (R0) is valid. 
;       You will implement this functionality in IS_INPUT_VALID. 
;       Also, this routine does not make any updates to the GRID 
;       or Simba's position, as that is the job of the APPLY_MOVE function.
;***********************************************************
CAN_MOVE      
; Your New (Program4) code goes here
ST R0, CValidR0
ST R2, CValidR2
ST R3, CValidR3
ST R4, CValidR4
ST R5, CValidR5
ST R6, CValidR6
ST R7, CValidR7

; have one register for checking R0 R1, R2, unavalible
;use R7

; JSR, IS_INPUT_VALID
; ADD  R4, R2, #0
; Brn, invalid
LD R7, I_Char1
LD R3, Seven_Val
NOT R3, R3
ADD R3, R3, #1
LD R1, CURRENT_ROWL
LDR R1, R1, #0
LD R2, CURRENT_COLL
LDR R2, R2, #0


LD R5, I_CharN  
ADD R6, R0, R5
brz, Icase
br, check
Icase
; row value decreaces by 1 check for negative after you decrement

ADD R4, R1, #-1
Brn, Invalid
ADD R1, R4, #0
Br, next11

check LD R7, J_Char1
LD R5, J_CharN
ADD R6, R0, R5
brz, Jcase
br, next12
JCase
; check for col negative
ADD R2, R2, #-1
Brn, invalid
br, next11


next12 LD R7, K_Char1
LD R5, K_CharN

ADD R6, R0, R5
brz, Kcase
br, next2
Kcase
ADD R1, R1, #1
ADD R6, R1, R3
brp, Invalid
br, next11

next2 LD R7, L_Char1
LD R5, L_CharN
ADD R6, R0, R5
brz, Lcase
LCase
ADD R2, R2, #1
ADD R6, R2, R3
brp, Invalid
br, next11

Invalid
LD R1, Neg1
LD R2, CValidR2
Br, next11

next11 LD R0, CValidR0
LD R3, CValidR3
LD R4, CValidR4
LD R5, CValidR5
LD R6, CValidR6
LD R7, CValidR7
JMP R7
Seven_Val .Fill #7
Neg1     .Fill #-1
I_Char1  .Fill #105
I_CharN  .Fill #-105
J_Char1  .Fill #106
J_CharN  .Fill #-106
K_Char1  .Fill #107
K_CharN  .Fill #-107
L_Char1  .Fill #108
L_CharN  .Fill #-108
CValidR0 .blkw #1
CValidR2 .blkw #1
CValidR3 .blkw #1
CValidR4 .blkw #1
CValidR5 .blkw #1
CValidR6 .blkw #1
CValidR7 .blkw #1
;***********************************************************
  ; SIMBA_STATUS
; Checks to see if the Simba has reached Home; Dead or still
; Alive
; Input:  None
; Output: R2 is ZERO if Simba is Home; Also Output "Simba is Home"
;         R2 is +1 if Simba is Alive but not home yet
;         R2 is -1 if Simba is Dead (i.e., LIFE_COUNT =0); Also Output"Simba is Dead"
; 
;***********************************************************
;***********************************************************
; APPLY_MOVE
; This subroutine makes the move if it can be completed. 
; It checks to see if the movement is possible by calling 
; CAN_MOVE which returns the coordinates of where the move 
; takes Simba (or -1 if movement is not possible as detailed above). 
; If the move is possible then this routine moves Simba
; symbol (*) to the new coordinates and clears any walls (|'s and -'s) 
; as necessary for the movement to take place. 
; In addition,
;   If the movement is off the grid - Output "Cannot Move" to Console
;   If the move is to a Friend's location then you increment the
;     LIFE_COUNT variable; 
;   If the move is to a Hyena's location then you decrement the
;     LIFE_COUNT variable; IF this decrement causes LIFE_COUNT
;     to become Zero then Simba's Symbol changes to X (dead)
; Input:  
;         R0 has move (i or j or k or l)
; Output: None; However yous must update the GRID and 
;               change CURRENT_ROW and CURRENT_COL 
;               if move can be successfully applied.
;               appropriate messages are output to the console 
; Notes:  Calls CAN_MOVE and GRID_ADDRESS
;***********************************************************





;***********************************************************
; DISPLAY_JUNGLE
;   Displays the current state of the Jungle Grid 
;   This can be called initially to display the un-populated jungle
;   OR after populating it, to indicate where Simba is (*), any 
;   Friends (F) and Hyenas(#) are, and Simba's Home (H).
; Input: None
; Output: None
; Notes: The displayed grid must have the row and column numbers
;***********************************************************
  GRID_BASE   .FILL GRID
H_Code      .FILL #72      
I_Code      .FILL #73
F_Code      .FILL #70
Hash_Code   .FILL #35      
Star_Code    .FILL #42 
DISPLAY_JUNGLE
  ST R0, SaveR0
    ST R1, SaveR1
    ST R2, SaveR2
    ST R3, SaveR3
    ST R4, SaveR4
    ST R5, SaveR5
    ST R6, SaveR6
    ST R7, SaveR7
    LEA R0, DISP_COLNUMS
    Trap x22
    LEA R0, DISP_NEWLINE
    Trap x22
   LEA R0, DISP_PLUSLINE
    Trap x22
    LEA R0, DISP_NEWLINE
    Trap x22
    LD R1, DISP_8
    ADD R1, R1, R1
    LD R2, GRID_BASE
    ADD R2, R2, #15
    ADD R2, R2, #3
    Display_Loop
    LEA R0, DISP_SPACE
    Trap x22
    LEA R0, DISP_SPACE
    Trap x22
    ADD R0, R2, #0
    Trap x22
    LEA R0, DISP_NEWLINE
    Trap x22
    ADD R2, R2, #15
    ADD R2, R2, #3
    ADD R1, R1, #-1
    Brp, Display_Loop
    br, end
    
    
    
  
  
  
  end
    LD R0, SaveR0
    LD R1, SaveR1
    LD R2, SaveR2
    LD R3, SaveR3
    LD R4, SaveR4
    LD R5, SaveR5
    LD R6, SaveR6
    LD R7, SaveR7
    JMP R7
    

DISP_18         .FILL #18 ; we use this to jump lines in memory make 2 copies one will be decremented (brp)
DISP_8          .FILL #8  ; this register gets decremented after every row is printed (brp)
DISP_48         .FILL #48 ; this is the starting character for columns 
; STRINGZ Declarations
DISP_COLNUMS    .STRINGZ "   0 1 2 3 4 5 6 7 "
DISP_PLUSLINE   .STRINGZ "  +-+-+-+-+-+-+-+-+"
DISP_NEWLINE    .STRINGZ "\n"
DISP_SPACE      .STRINGZ " "
     SaveR0  .BLKW #1
    SaveR1  .BLKW #1
    SaveR2  .BLKW #1
    SaveR3  .BLKW #1
    SaveR4  .BLKW #1
    SaveR5  .BLKW #1
    SaveR6  .BLKW #1
    SaveR7  .BLKW #1
  
  

IS_INPUT_VALID
ST R0, IValidR0
ST R1, IValidR1
ST R3, IValidR3
ST R4, IValidR4
ST R5, IValidR5
ST R6, IValidR6
ST R7, IValidR7
; Your New (Program4) code goes here
LD R1, I_CharN1
LD R3, J_CharN1
LD R4, K_CharN1
LD R5, L_CharN1
; I check

ADD R6, R0, R1
brz, outputValid
;J check

ADD R6, R0, R3
brz, outputValid
;K check 

ADD R6, R0, R4
brz, outputValid
;L check

ADD R6, R0, R5
brz, outputValid
Br, outputInvalid
outputValid
LD R2, Zero_Val;
br, next

outputInvalid
LD R2, Neg
br, next
 next LD R0, IValidR0
LD R1, IValidR1
LD R3, IValidR3
LD R4, IValidR4
LD R5, IValidR5
LD R6, IValidR6
LD R7, IValidR7
JMP R7
;Calle Saves
Zero_Val .Fill #0
Neg      .Fill #-1
I_CharN1 .Fill #-105
J_CharN1  .Fill #-106
K_CharN1  .Fill  #-107
L_CharN1  .Fill   #-108 
IValidR0 .blkw #1
IValidR1 .blkw #1
IValidR3 .blkw #1
IValidR4 .blkw #1
IValidR5 .blkw #1
IValidR6 .blkw #1
IValidR7 .blkw #1

 

;***********************************************************
; GRID_ADDRESS
; Input:  R1 has the row number (0-7)
;         R2 has the column number (0-7)
; Output: R0 has the corresponding address of the space in the GRID
; Notes: This is a key routine.  It translates the (row, col) logical 
;        GRID coordinates of a gridblock to the physical address in 
;        the GRID memory.
;***********************************************************
GRID_ADDRESS     
; Your Program 3 code goes here
     ST R3, AddSaveR3
    ST R4, AddSaveR4
    ST R5, AddSaveR5
    ST R7, AddSaveR7
; this has to be correct 
    ; Inputs: R1 = row (0-7), R2 = column (0-7)
    ; Output: R0 = address of the specified grid cell in the 8x8 jungle grid
      LEA R0,GRID_BASE      ; Load base address of GRID
      LDR R0, R0, #0
      ADD R3, R1, #0
      ADD R4, R2, #0
    ADD R3, R3, R3
    ADD R3, R3, #1
    AND R5, R5, #0
    next1 ADD R5, R5, #15
    ADD R5, R5, #3
    ADD R3, R3, #-1
    brp, next1
    ADD R4, R4, R4
    ADD R4, R4, #1
    ADD R5, R4, R5
    ADD R0, R5, R0
    
    ; column offset
   
   LD R3, AddSaveR3
    LD R4, AddSaveR4
    LD R5, AddSaveR5
    LD R7, AddSaveR7
     JMP R7
     
    
    AddSaveR3  .BLKW #1
    AddSaveR4  .BLKW #1
    AddSaveR5  .BLKW #1
    AddSaveR7  .BLKW #1
    ;***********************************************************

;***********************************************************
; IS_INPUT_VALID
; Input: R0 has the move (character i,j,k,l)
; Output:  R2  zero if valid; -1 if invalid
; Notes: Validates move to make sure it is one of i,j,k,l
;        Only checks if a valid character is entered
;***********************************************************






.end
; This section has the linked list for the
; Jungle's layout: #(0,1)->H(4,7)->I(2,1)->#(1,1)->#(6,3)->F(3,5)->F(4,4)->#(5,6)
	.ORIG	x5500
	.FILL	Head   ; Holds the address of the first record in the linked-list (Head)
blk2
	.FILL   blk4
	.FILL   #1
    .FILL   #1
	.FILL   x23

Head
	.FILL	blk1
    .FILL   #0
	.FILL   #1
	.FILL   x23

blk1
	.FILL   blk3
	.FILL   #4
	.FILL   #7
	.FILL   x48

blk3
	.FILL   blk2
	.FILL   #2
	.FILL   #1
	.FILL   x49

blk4
	.FILL   blk5
	.FILL   #6
	.FILL   #3
	.FILL   x23

blk7
	.FILL   #0
	.FILL   #5
	.FILL   #6
	.FILL   x23
blk6
	.FILL   blk7
	.FILL   #4
	.FILL   #4
	.FILL   x46
blk5
	.FILL   blk6
	.FILL   #3
	.FILL   #5
	.FILL   x46
	.END
