; Program5.asm
; Name(s):
; UTEid(s): 
; Continuously reads from x3500 making sure its not reading duplicate
; symbols. Processes the symbol based on the program description
; of mRNA processing.
    .ORIG x3000
; set up the keyboard interrupt vector table entry
;M[x0180] <- x2500
LD  R0, KBISR
	STI R0, KBINTVec

; enable keyboard interrupts
; KBSR[14] <- 1 ==== M[xFE00] = x4000
  	LDI R0, KBSR
	LD  R1, KBINTEN  ; R0 <- R0 OR R1
	NOT R0,R0
	NOT R1,R1
	AND R0,R0,R1
	NOT R0,R0
	STI R0,KBSR

; This loop is the proper way to read an input
; before every itteration we need to reset the global variable to 0 because if we have an invalid input this value has to be 0,
; pre loop set up.
; I will also need to set the initial starting point for my Start Codon detecor
 	AND R0,R0,#0
    STI R0, GLOB
    LD R2, Start_Check
Loop
    LDI R0,GLOB ; these 2 lines allow us to keep waiting till an input that we can actually process is entered 
    BRz Loop             
; Process it
    LD R0, GLOB
    Trap x22
    ; I will use a simple sequence detection 
    ; once we check for stop codon if we don't need to halt we have to reset x3500 to 0 so that we can wait for the next input 
    
; Repeat until Stop Codon detected
    HALT
    
 ; Start sequence detection sub routine 
  Start_Codon
  ;inputs R0 which holds the character ; 
  ; R2 will not be call saved this is because i need it to store in sucessive locations 
  ; output R3 this will be a signal to trigger the end codon sub routine 
  STR R0, R2, #0
  ADD R2, R2, #1
  ; now I will check if R2 has hit x4403
  LD R5, Start_Checkneg
  LDR R5, R5, #0
  ADD R4, R2
  ; this sub routine will read a string of 3 inputs once the start codon has been detected 
  End_Codon
  
  
KBINTVec  .FILL x0180
KBSR   .FILL xFE00
KBISR  .FILL x2500
KBINTEN  .FILL x4000
GLOB   .FILL x3500
Zer    .Fill x0000
Start_Check .Fill x4400
Start_Checkneg .Fill #-17411

	.END

; Interrupt Service Routine
; Keyboard ISR runs when a key is struck
; Checks for a valid RNA symbol and places it at x3500
        .ORIG x2500
          ST R0, IValidR0
ST R1, IValidR1
ST R3, IValidR3
ST R4, IValidR4
ST R5, IValidR5
ST R6, IValidR6
ST R7, IValidR7
; Your New (Program4) code goes here
LD R1, A_CharN1
LD R3, C_CharN1
LD R4, U_CharN1
LD R5, G_CharN1
LD R0, KBDR


ADD R6, R0, R1
brz, outputValid
;A check

ADD R6, R0, R3
brz, outputValid
;C check 

ADD R6, R0, R4
brz, outputValid
;U check

ADD R6, R0, R5
brz, outputValid
;G check

Br, outputInvalid
outputValid
LD R0, IGLOB ;
br, next

outputInvalid
br, next
 next LD R0, IValidR0
LD R1, IValidR1
LD R3, IValidR3
LD R4, IValidR4
LD R5, IValidR5
LD R6, IValidR6
LD R7, IValidR7
  RTI
;Calle Saves
Zero_Val .Fill #0
Neg      .Fill #-1
A_CharN1 .Fill #-65
C_CharN1  .Fill #-106
U_CharN1  .Fill  #-107
G_CharN1  .Fill   #-108 
IValidR0 .blkw #1
IValidR1 .blkw #1
IValidR3 .blkw #1
IValidR4 .blkw #1
IValidR5 .blkw #1
IValidR6 .blkw #1
IValidR7 .blkw #1

 
      
        
KBDR  .FILL xFE02
IGLOB  .FILL x3500

		.END
