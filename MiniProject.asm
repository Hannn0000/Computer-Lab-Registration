
;-----------------------------------------------------------
;					     DEFINE PIN
;-----------------------------------------------------------

RS EQU P2.7	;assign P2.7 to RS pin (symbol RS)
RW EQU P2.6	;assign P2.6 to RW pin (symbol RW)
E  EQU P2.5	;assign P2.5 to E pin (symbol E)
SEL EQU 41H	;assign 41H to SEL pin


;-----------------------------------------------------------
;					   MAIN PROGRAM
;-----------------------------------------------------------
		ORG 000H 
		
		MOV TMOD,#00100001B		;select timer mode 1 (16-bit timer)
		MOV TH1,#253D
		MOV SCON,#50H			;load 01010000 so that serial port function in mode 1
		SETB TR1				;start timer
		ACALL LCD_INIT			;call LCD_INIT subroutine
		MOV DPTR,#WEL_MSG1
		ACALL LCD_OUT			;call LCD_OUT subroutine
		MOV A, #3CH				
		ACALL LINE2				;call LINE2 subroutine
		MOV DPTR,#WEL_MSG2
		ACALL LCD_OUT			;call LCD_OUT subroutine

MAIN:	SETB P2.0
		SETB P2.1
		MOV P3, #0FFH
		ACALL SENSOR
		ACALL LCD_INIT			;call LCD_INIT subroutine
		MOV DPTR,#WEL_MSG1
		ACALL LCD_OUT			;call LCD_OUT subroutine
		ACALL LINE2				;call LINE2 subroutine
		MOV DPTR,#WEL_MSG2
		
		ACALL LCD_OUT			;call LCD_OUT subroutine
		ACALL DELAY1			;call DELAY1 subroutine
		
		
		ACALL SELECT_DIS
		ACALL SELECT
		ACALL CHECK_SE
		
		

		
		SJMP MAIN


;-----------------------------------------------------------
;				     WELCOMING MESSAGE
;-----------------------------------------------------------

WEL_MSG1: DB "   WELCOME TO ",0 
WEL_MSG2: DB "  USM COMP LAB=) ",0 

;-----------------------------------------------------------
;				     IR SENSOR
;-----------------------------------------------------------
SENSOR: SETB P2.2
SENSE: 	JB P2.2, SENSE
		RET
;-----------------------------------------------------------
;				     STAFF OR STUDENT
;-----------------------------------------------------------
SELECT_DIS: ACALL CLRSCR
			ACALL LINE1
			MOV DPTR,#SELECT_M1
			ACALL LCD_OUT
			ACALL LINE2				;call LINE2 subroutine
			MOV DPTR,#SELECT_M2
			ACALL LCD_OUT			;call LCD_OUT subroutine
			ACALL DELAY1
			RET
		
SELECT:  	ACALL CLRSCR
			ACALL LINE1
			MOV DPTR,#PLS_CHOOSE
			ACALL LCD_OUT
			ACALL LINE2
			MOV R0,#1D
			MOV R1,#160D
			ACALL ROTATE
			ACALL DELAY2
			RET
		
SELECT_M1: 	DB "1 - STAFF",0
SELECT_M2: 	DB "2 - STUDENT",0
PLS_CHOOSE:	DB "CHOOSE 1 OR 2",0
	
CHECK_SE: MOV R0,#1D
		  MOV R1,#160D
		  MOV DPTR, #C_STAFF
		  
SE_RPT1:	CLR A
			MOVC A,@A+DPTR
			XRL A,@R1
			JNZ SELOOP1				
			INC R1
			INC DPTR
			DJNZ R0,SE_RPT1
			ACALL STAFF
			RET
			
SELOOP1:
		MOV R0, #1D
		MOV R1, #160D
		MOV DPTR, #C_STUDENT

SE_RPT2:	CLR A
		MOVC A,@A+DPTR
		XRL A,@R1
		JNZ FAIL			
		INC R1
		INC DPTR
		DJNZ R0,SE_RPT2
		ACALL STUDENT
		RET
		  
C_STAFF:   DB 49D
C_STUDENT: DB 50D

	
	
FAIL: 	ACALL CLRSCR 
		ACALL LINE1
		MOV DPTR,#FAIL_1
		ACALL LCD_OUT
		ACALL DELAY1
		JMP MAIN

PASS_1: DB "PROCESSING...",0
FAIL_1: DB "INVALID INPUT!",0
	
STAFF:  ACALL CLRSCR
		ACALL LINE1
		MOV DPTR,#PASS_1
		ACALL CLRSCR
		ACALL LCD_OUT
		ACALL DELAY1
		ACALL READ_ID
		ACALL LINE1
		MOV DPTR,#CHK_MSG3
		ACALL LCD_OUT			;call LCD_OUT subroutine
		ACALL LINE2				;call LINE2 subroutine
		MOV DPTR,#CHK_MSG4
		ACALL LCD_OUT			;call LCD_OUT subroutine
		ACALL DELAY1			;call DELAY1 subroutine
		ACALL CHECK_ID
	
STUDENT:ACALL CLRSCR
		ACALL LINE1
		MOV DPTR,#PASS_1
		ACALL LCD_OUT
		ACALL DELAY1
		ACALL READ_MATR
		ACALL LINE1
		MOV DPTR,#CHK_MSG1
		ACALL LCD_OUT			;call LCD_OUT subroutine
		ACALL LINE2				;call LINE2 subroutine
		MOV DPTR,#CHK_MSG2
		ACALL LCD_OUT			;call LCD_OUT subroutine
		ACALL DELAY1			;call DELAY1 subroutine
		ACALL CHECK_MATR
;-----------------------------------------------------------
;			         KEY-IN STAFF ID
;-----------------------------------------------------------

	
READ_ID:    ACALL CLRSCR
		    ACALL LINE1
			MOV DPTR,#INP_ID1
			ACALL LCD_OUT
			ACALL LINE2
			MOV R0,#5D
			MOV R1,#160D
			ACALL ROTATE ;to type more than one digit
			ACALL DELAY2
			RET
	
INP_ID1: DB "KEY-IN STAFF ID", 0


;-----------------------------------------------------------
;			         KEY-IN MATRIX NO.
;-----------------------------------------------------------
	
READ_MATR:  ACALL CLRSCR
			ACALL LINE1
			MOV DPTR,#INP_MATR1
			ACALL LCD_OUT
			ACALL LINE2
			MOV R0,#6D
			MOV R1,#160D
			ACALL ROTATE ;to type more than one digit
			ACALL DELAY2
			
			RET
	
INP_MATR1: DB "KEY-IN MATRIX NO.", 0
				
ROTATE: ACALL KEY_SCAN
		MOV @R1,A
		ACALL DATA_WRITE
		ACALL DELAY2
		INC R1
		DJNZ R0,ROTATE
		RET
	
DATA_WRITE: MOV P0,A
			SETB RS
			CLR RW
			SETB E
			CLR E
			ACALL DELAY
			RET

;-----------------------------------------------------------
;				      CHECK STAFF ID
;-----------------------------------------------------------
			
CHECK_ID:   MOV R0,#3D
			MOV R1,#160D
			MOV DPTR, #ID1 

IDRPT1:	CLR A
		MOVC A,@A+DPTR
		XRL A,@R1
		JNZ LOOP1				
		INC R1
		INC DPTR
		DJNZ R0,IDRPT1
		ACALL VALID
		RET
			
IDLOOP1:
		MOV R0, #5D
		MOV R1, #160D
		MOV DPTR, #ID2

IDRPT2:	CLR A
		MOVC A,@A+DPTR
		XRL A,@R1
		JNZ INVALID		
		INC R1
		INC DPTR
		DJNZ R0,IDRPT2
		ACALL VALID
		RET
		

	
		
ID1: DB 65D, 49D, 48D, 48D, 49D
ID2: DB 65D, 49D, 49D, 48D, 48D
;-----------------------------------------------------------
;				       CHECK MATRIC NO.
;-----------------------------------------------------------

CHECK_MATR: MOV R0,#3D
			MOV R1,#160D
			MOV DPTR, #MATR1 

RPT1:	CLR A
		MOVC A,@A+DPTR
		XRL A,@R1
		JNZ LOOP1				
		INC R1
		INC DPTR
		DJNZ R0,RPT1
		ACALL VALID
		RET
			
LOOP1:
		MOV R0, #6D
		MOV R1, #160D
		MOV DPTR, #MATR2

RPT2:	CLR A
		MOVC A,@A+DPTR
		XRL A,@R1
		JNZ INVALID				
		INC R1
		INC DPTR
		DJNZ R0,RPT2
		ACALL VALID
		RET
		

	
VALID:	ACALL CLRSCR
		ACALL LINE1
		MOV DPTR,#TEXT_P1
		ACALL LCD_OUT
		ACALL LINE2
		MOV DPTR,#TEXT_P2
		ACALL LCD_OUT
		MOV P3, #10001100B
	    CLR P2.0
		
		ACALL DELAY1
	
		JMP MAIN
	 
INVALID:ACALL CLRSCR 
		ACALL LINE1
		MOV DPTR,#TEXT_F1
		ACALL LCD_OUT
		ACALL LINE2
		MOV DPTR,#TEXT_F2
		ACALL LCD_OUT
		MOV P3, #10001110B
		CLR P2.1
		ACALL DELAY1
		JMP MAIN
		


;-----------------------------------------------------------
;					         LCD
;-----------------------------------------------------------

;initial command for LCD
INIT_COMMANDS:  DB 0CH,01H,06H,80H,3CH,0  ;cursor off and display on, clear screen, increment cursor, force cursor to beginning of 1st line,activate second line  


LINE1:  MOV A,#80H    
		ACALL CMD_WRITE
		RET

LINE2:	MOV A,#0C0H 
		ACALL CMD_WRITE
		RET 

;To clear screen
CLRSCR: MOV A,#01H
		ACALL CMD_WRITE
		RET
		
LCD_INIT: MOV DPTR,#INIT_COMMANDS
          SETB SEL
          ACALL LCD_OUT
          CLR SEL
          RET      

LCD_OUT:  CLR A
          MOVC A,@A+DPTR	 ;moves a byte which is the sum of Acc and DPTR into Acc
          JZ EXIT			 ;jump to EXIT if A=0
          INC DPTR			 ;increment DPTR pointer
          JB SEL,CMD  		 ;jump to next line if SEL = 1, or else proceed to CMD
		  ACALL DATA_WRITE
		  SJMP LCD_OUT
		 
CMD: ACALL CMD_WRITE
	 SJMP LCD_OUT
	
CMD_WRITE: 	MOV P0,A
			CLR RS
			CLR RW
			SETB E
			CLR E
			ACALL DELAY
			RET
			
EXIT:	RET  


;-----------------------------------------------------------
;					          DELAY 
;-----------------------------------------------------------

DELAY:  CLR E
		CLR RS
		SETB RW
		MOV P0,#0FFH
		SETB E
		MOV A,P0
		JB ACC.7,DELAY
		CLR E
		CLR RW
		RET
    
DELAY1:MOV R3,#40
BACK:  MOV TH0,#00000000B   
       MOV TL0,#00000000B   
       SETB TR0   
HERE1: JNB TF0,HERE1         
       CLR TR0             
       CLR TF0             
       DJNZ R3,BACK
       RET
       
DELAY2: MOV R3,#170
BACK2:  MOV TH0,#0FCH 
        MOV TL0,#018H 
        SETB TR0 
HERE2:  JNB TF0,HERE2 
        CLR TR0 
        CLR TF0 
        DJNZ R3,BACK2
        RET       

				
;-----------------------------------------------------------
;					      CHECK KEYPAD
;-----------------------------------------------------------
KEY_SCAN:	MOV P1,#11111111B 
			CLR P1.0 
			JB P1.4, NEXT1 
			MOV A,#49D		;1
			RET
			
NEXT1:	JB P1.5,NEXT2		;check whether column 2 is low and so on..
		MOV A,#50D			;2
		RET
		
NEXT2:  JB P1.6,NEXT3		;check whether column 3 is low and so on..
		MOV A,#51D			;3
		RET
		
NEXT3:  JB P1.7,NEXT4		;check whether column 4 is low and so on..
		MOV A,#65D			;A
		RET
		
NEXT4:	SETB P1.0
		CLR P1.1 
		JB P1.4, NEXT5 
		MOV A,#52D			;4
		RET
		
NEXT5:	JB P1.5,NEXT6
		MOV A,#53D			;5
		RET
		
NEXT6:  JB P1.6,NEXT7
		MOV A,#54D			;6
		RET
		
NEXT7:  JB P1.7,NEXT8
		MOV A,#66D			;B
		RET
		
NEXT8:	SETB P1.1
		CLR P1.2
		JB P1.4, NEXT9 
		MOV A,#55D			;7
		RET
		
NEXT9:	JB P1.5,NEXT10
		MOV A,#56D			;8
		RET
		
NEXT10: JB P1.6,NEXT11
		MOV A,#57D			;9
		RET
		
NEXT11: JB P1.7,NEXT12
		MOV A,#67D			;C
		RET
		
NEXT12: SETB P1.2
		CLR P1.3
		JB P1.4, NEXT13 
		MOV A,#42D			;*
		RET
		
NEXT13: JB P1.5,NEXT14
		MOV A,#48D			;0
		RET
		
NEXT14: JB P1.6,NEXT15	
		MOV A,#35D			;#
		RET
		
NEXT15: JB P1.7,NEXT16
		MOV A,#68D			;D
		RET
		
NEXT16:LJMP KEY_SCAN


;-----------------------------------------------------------
;						MATRIX NO. DATA
;-----------------------------------------------------------
CHK_MSG1: DB "    CHECKING    ",0
CHK_MSG2: DB " MATRIX NO. ... ", 0
	
CHK_MSG3: DB "    CHECKING    ",0
CHK_MSG4: DB " STAFF ID ... ", 0

MATR1: DB 50D, 49D, 48D, 48D, 48D, 49D
MATR2: DB 50D, 49D, 49D, 48D, 48D, 48D


	

;text displayed if temp = 36.5
TEXT_P1: DB " ENJOY YOUR TIME",0
TEXT_P2: DB "   -VALID ID-   ",0
	
;text displayed if temp != 36 or temp != 37
TEXT_F1: DB "  ID NOT FOUND  ",0
TEXT_F2: DB "  -INVALID ID-  ",0

END