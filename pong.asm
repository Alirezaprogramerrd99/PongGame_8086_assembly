;---------------------------------- pong game -------------------------------------   

    ;---------------------
    ;name: Alireza Rashidi
    ;---------------------
    
    ;*** hint(1): if you lose the game you have two options press (y) to play again or press (n) to exit the game.
    ;*** hint(2): if you win the game you have two options press (y) to play again or press (n) to exit the game.
    ;*** hint(3): for faster rocket movement hold your finger on (w) or (s) to accelerate movement. 

;--------------------------------------------------------------------------------------------------------------------
 

title (exe) Graphics System Calls
#start=led_display.exe#
  


    .MODEL SMALL
    .STACK 64
;----------------------------- Data Segment --------------------------------------------
    .DATA
    
;-----------------------------------------------------------------
BALL_posStartX	DW 70D
BALL_posStartY	DW 70D
BALL_posEndX DW 76D
BALL_posEndY DW 76D
BALL_color	DB  0EH
;-----------------------------------------------------------------

BALL_velocityX DW 4D
BALL_velocityY DW 4D

LastPosX DW 00H
LastPosY DW 00H
LastPosEndX  DW 00H
LastPosEndY   DW 00H

screen_height DW 0C8H    	; graphical mode height and width declaration. 
screen_width DW 320D   		; number of columns
speedLimit DW 9FFFH  		; this is for limitation of speed in screen.

boundW	DW 5D         		

;-----------------------values to draw rectangels------------------------------------------------------
value_startX  DW  ?
value_startY  DW  ?
value_endX  DW  ?
value_endY  DW  ?
;------------------------------------ rocket values ------------------------------------------------------------------

ROCKET_StartX DW 285D
ROCKET_StartY DW 100D
ROCKET_EndX   DW 288D
ROCKET_EndY	  DW 132D

;----------------------------------- Game blocks -------------------------------------------------------
horizontalBlock1_startX  DW  15D
horizontalBlock1_startY  DW  24D
horizontalBlock1_EndX	 DW  285D
horizontalBlock1_EndY	 DW  27D

VerticalBlock_startX  DW  15D			
VerticalBlock_startY  DW  24D
VerticalBlock_EndX	 DW  18D
VerticalBlock_EndY	 DW  190D


horizontalBlock2_startX  DW  15D
horizontalBlock2_startY  DW  190D
horizontalBlock2_EndX	 DW  285D
horizontalBlock2_EndY	 DW  193D


;--------------------------------------------------------------------------------------------------------

player_score	DB  00H		        ; variable to store score of player.
player_print    DB '0',' ', '$'     ; for printing score in screen.
isGameOver		DB   0
gameOverMsg     DB  'Game Over!$'
isCollided_With_Rocket	DB  0 
winGameMsg      DB  'You Win :)$'

;----------------------------- Code Segment--------------------------------------------
    
    .CODE
    
MAIN    PROC FAR
    
        MOV AX, @DATA
        MOV DS, AX
		
		mov ax, 00      ; set the LED.
		out 199, ax
		
        set:		; setting the initial values of the pong game.
		CALL setGameParameters

    	while_GameisOn:
		    
		    CMP player_score, 1EH
		    JZ win_game
		     
			CMP isGameOver, 1
			JZ game_over
		
			CALL showScoreOfPlayer
			CALL setScoreOnLED  ; setting score in LED in every itration.
			
			XOR CX, CX
			 	
        	; move ball part------
						 
			CALL DrawBall 				 ; calling the drawBall on screen proc   
			CALL DrawRocket
			
			;-----setting last postions of previous cordinates of the ball for compareing to clean the last positons.
			MOV AX, BALL_posStartX     ; saveing the last postion of the ball in every itration to clean the pervios ball location.
			MOV LastPosX, AX
			MOV AX, BALL_posStartY     
			MOV LastPosY, AX
			
		    MOV AX, BALL_posEndX    
			MOV LastPosEndX, AX
			MOV AX, BALL_posEndY
			MOV LastPosEndY, AX
 
			CALL MoveBallProc
			CALL insertDelay
			CALL cleanBall

			CALL MoveRocketProc
			
			JMP while_GameisOn
        	
        	game_over:
			
    			CALL gameOverProc  ; if the user lose the round we come here 
    			XOR AX, AX
    			MOV AH, 01H
    			INT 21H
    			
    			CMP AL, 'n'  ; if not want to play again.
    			JZ outt
    			
    			CMP AL, 'y'  ; if user want to play again.
    			JZ set	
    					
			JMP game_over
			
			win_game:        ; if the user wins the round we come here 
			
    			CALL PrintWinGame
    			XOR AX, AX
    			MOV AH, 01H
    			INT 21H
    			
    			CMP AL, 'n'  ; if not want to play again.
    			JZ outt
    			
    			CMP AL, 'y'  ; if user want to play again.
    			JZ set
    			
			JMP win_game 	
		
		outt:
    	
    	MOV AH, 4CH
        INT 21H
      
         ret 
         
ENDP MAIN


MoveBallProc	PROC NEAR		; this PROC moves the ball in directions. and checks the collison of the ball.

	        MOV AX, BALL_velocityX
        	ADD BALL_posStartX, AX
			
			MOV AX, BALL_velocityX
        	ADD BALL_posEndX, AX
			
			MOV AX, BALL_velocityY
			ADD BALL_posStartY, AX
			
			MOV AX, BALL_velocityY
			ADD BALL_posEndY, AX
			
			
			;CMP BALL_posX, 00H     ; left screen collision.  **fixed**
			MOV AX, 00H
			ADD AX, VerticalBlock_EndX
			;INC AX
			CMP BALL_posStartX, AX
			JZ reflect_X
			
			MOV AX, BALL_posStartX   ; if the ball passess the game rocket.
			;MOV BX, screen_width
			MOV BX, ROCKET_StartX
			ADD BX, boundW           ; adding for that ball can passes the Rocket(game_over condition)		
			CMP AX, BX
			JG GameOver
			
			MOV AX, ROCKET_StartX
			;SUB AX, 5H
			;SUB AX, boundW
			
			CMP AX, BALL_posEndX   ; right screen collision.
			JNL label1       ; ****checkCollision with ROCKET****.
			CMP isCollided_With_Rocket, 00H
			JZ checkCollision
			

			label1:
			XOR AX, AX
			
			;CMP BALL_posY, 00H    ; up screen collision
			MOV AX, boundW
			ADD AX, 2H				;**** must fix it in data segment....
			ADD AX, horizontalBlock1_startY
			CMP BALL_posStartY, AX
			JL reflect_Y
			
			MOV AX, horizontalBlock2_startY  ; down screen collision
			SUB AX, 5H
			SUB AX, boundW			
			CMP BALL_posStartY, AX	
			
			JG reflect_Y			
			RET
			
			checkCollision:  ; checking collision with ROCKET.
				
				
				MOV AX, ROCKET_StartY
				;SUB AX, 02H
				CMP  BALL_posStartY, AX
				
				JNG end_checkCollision
				
				MOV AX, ROCKET_EndY
				;ADD AX, 02H
				CMP BALL_posStartY, AX
				
				JNL end_checkCollision
				
				MOV isCollided_With_Rocket, 01H
				
				CALL generateRandom
				MOV BALL_color, DL
				CALL updateScoreOfPlayer		; update the score of player that collided with rocket.
				
				NEG BALL_velocityX
				;JMP reflect_X
				
			RET
						
			GameOver:       ; setting the GameOver flag.
			
				MOV isGameOver, 1

			RET
			
			reflect_Y:
			MOV isCollided_With_Rocket, 00H
			NEG BALL_velocityY   ; reflecting y velocity.
			
			RET
				
			reflect_X:
			
			NEG BALL_velocityX
			MOV isCollided_With_Rocket, 00H	
			
			RET
						
			end_checkCollision:
			
			RET

ENDP MoveBallProc    



setGraphicsMode	   PROC NEAR
	
		MOV AL, 13h ; video mode chosen.
		MOV AH, 0
		INT 10h     ; set graphics video mode.
	RET
ENDP    setGraphicsMode


RestartBallPositionProc		PROC NEAR  	; here we update score of player.
	
		MOV AX, 70D  		 ; ******must be set in the sutibale place in screen
		MOV BALL_posStartX, AX
		MOV BALL_posStartY, AX
		MOV AX, 76D
		MOV BALL_posEndX, AX
		MOV BALL_posEndY, AX
	RET
ENDP    RestartBallPositionProc


DrawRocket	 PROC NEAR

	     MOV AH, 0CH
         MOV AL, 0EH
         MOV BH, 00         ; set page 1 to use. 
		 
		 MOV DX, ROCKET_StartY
		 
		 initialize_next_column3:
		 MOV CX, ROCKET_StartX
		 
		 loop3:
		 INT 10H
		 INC CX
		 CMP CX, ROCKET_EndX
		 JNZ loop3
		 INC DX
		 CMP DX, ROCKET_EndY
		 
		 JNZ initialize_next_column3

		RET
		
ENDP    DrawRocket


MoveRocketProc	 PROC NEAR
	
	MOV AH, 01H
	INT 16H   ; now (AL) will have ASCII value of user input character.
	
	JNZ keyPressed		  ; check that the keyboard pressed.
	RET  				; if no key pressed return.
	
	MOV AH, 00H
	INT 16H
	
	keyPressed: ; we must check if the Rocket control keys are pused
	MOV AH, 00H
	INT 16H
	
	CMP AL, 77H
	JE moveUp
	
	CMP AL, 73H
	JE moveDown
	
	moveUp: ; in this part can change speed of rocket movemnet.
	
		;CALL shift_up
		DEC ROCKET_StartY
		DEC ROCKET_EndY
		CALL shift_up
		
		DEC ROCKET_StartY
		DEC ROCKET_EndY
		CALL shift_up
		
	    DEC ROCKET_StartY
		DEC ROCKET_EndY
		CALL shift_up
		
		;DEC ROCKET_StartY		
		;DEC ROCKET_EndY
		;CALL shift_up	
		RET
		
	moveDown:   			 ; if the user inputs s buttten must go down.
		CALL shift_Down	
		INC ROCKET_StartY
		INC ROCKET_EndY
		
		CALL shift_Down	
		INC ROCKET_StartY
		INC ROCKET_EndY 
		
		CALL shift_Down	
		INC ROCKET_StartY
		INC ROCKET_EndY
		
		;INC ROCKET_StartY		
		;INC ROCKET_EndY
		;CALL shift_Down	
			
	RET
	
ENDP    MoveRocketProc


shift_up		PROC 	NEAR

		MOV AH, 0CH
		MOV AL, 00H
        MOV BH, 00         ; set page 1 to use.
		
		MOV CX, ROCKET_StartX
		MOV DX, ROCKET_EndY
		
		loop_shift_Up:
			INT 10H
			INC CX
			CMP CX, ROCKET_EndX
			
		JNZ loop_shift_Up
	RET
ENDP    shift_up


shift_Down		PROC 	NEAR

		MOV AH, 0CH
		MOV AL, 00H
        MOV BH, 00         ; set page 1 to use.
		
		MOV CX, ROCKET_StartX
		MOV DX, ROCKET_StartY
		
		loop_shift_Down:
		
			INT 10H
			INC CX
			CMP CX, ROCKET_EndX
			JNZ loop_shift_Down
		
		JNZ loop_shift_Down

	RET
ENDP    shift_Down 



setCursorProc 	PROC NEAR
		
		POP SI
		POP DX
		
		MOV AH, 02H
		MOV BH, 00H
		INT 10H
		
		PUSH SI
	RET

ENDP    setCursorProc



showScoreOfPlayer		PROC 	NEAR
		
		MOV CX, 013CH
		
		PUSH CX
		
		XOR CX, CX
		
		CALL setCursorProc		; for every showing of the score we need to set the cursers postion.
		
	    MOV DX, offset player_print   ; show part
		MOV AH, 9
		INT 21h
		
	RET
ENDP    showScoreOfPlayer


updateScoreOfPlayer		PROC	NEAR
	
		XOR AX, AX
        INC player_score
        MOV AL, player_score
		MOV SI, OFFSET player_print
        CMP AL, 09H
    	
        JA greaterThan9 
        	
			MOV SI, OFFSET player_print
			ADD AL, 48D
			MOV [SI], AL
        	
        JMP countinue
        	
        greaterThan9:
        	
			XOR AH, AH
			MOV DL, 0AH
			DIV DL
        	
			ADD AH, 48D
			ADD AL, 48D
			MOV [SI], AL
			MOV [SI+1], AH
		
		countinue:
		
		RET
ENDP    updateScoreOfPlayer


insertDelay		PROC NEAR

			XOR CX, CX
			limitSpeed:
			
				INC CX
				CMP CX, speedLimit 
				
			JNE limitSpeed
			
			RET

ENDP  insertDelay


cleanBall   PROC 	NEAR
    
    	 MOV AH, 0CH
         MOV AL, 00H        ; black
         MOV BH, 00         ; set page 1 to use. 
		 
		 MOV DX, LastPosY   ; using last position to clean perivous state ball.
		 
		 initialize_next_column2:
		 MOV CX, LastPosX
		 
		 loop2:
		 INT 10H
		 INC CX
		 CMP CX, LastPosEndX 
		 
		 JNZ loop2
		 INC DX
		 CMP DX, LastPosEndY
		 
		 JNZ initialize_next_column2
		 
		 RET
    
ENDP cleanBall


DrawRectangle	PROC 	NEAR

		 MOV AH, 0CH
         MOV AL, 0EH
         MOV BH, 00         ; set page 1 to use. 
		 POP SI  			; saveing the return address of PROC
		 
		 POP DX
		 POP value_startX
		 POP value_endY
		 POP value_endX
		 
		 set_column:
			MOV CX, value_startX
		 
		 loopRectangle:
		 
			 INT 10H
			 INC CX
			 CMP CX, value_endX
			 JNZ loopRectangle
			 
			 INC DX
			 CMP DX, value_endY
		 
		 JNZ set_column
		 
		 PUSH SI
	RET
ENDP    DrawRectangle


DrawBall    PROC NEAR

	     MOV AH, 0CH
         MOV AL, BALL_color
         MOV BH, 00         ; set page 1 to use. 
		 
		 MOV DX, BALL_posStartY
		 
		 initialize_next_column:
		 MOV CX, BALL_posStartX
		 
		 loop1:
		 INT 10H
		 INC CX
		 CMP CX, BALL_posEndX
		 JNZ loop1
		 INC DX
		 CMP DX, BALL_posEndY
		 
		 JNZ initialize_next_column
		 
		 RET
		 
    
ENDP    DrawBall



gameOverProc	PROC	NEAR

	CALL setGraphicsMode
	
	;MOV AH, 0Bh
	;MOV BH, 00H		; clear the screen
	;INT 10H
	
	MOV AH, 60D
	MOV AL, 160D
	PUSH AX
	
	CALL setCursorProc
	
	MOV DX, OFFSET gameOverMsg
	MOV AH, 09H
	INT 21H
	
	RET
	
ENDP gameOverProc


generateRandom		PROC	NEAR

	   MOV AH, 00h  ; interrupts to get system time        
	   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      

	   MOV  AX, DX
	   XOR  DX, DX
	   MOV  CX, 15D    
	   DIV  CX      ; here dx contains the remainder of the division - from 0 to 9
	   INC DL       ; we incremnet DL becuse this function can generate 00 hex code that is for color black and might set the ball color to black.
	   
	   
	RET
ENDP    generateRandom



setBlocks	PROC   NEAR
	
		PUSH horizontalBlock1_EndX		;loading the parameters of first block
		PUSH horizontalBlock1_EndY
		PUSH horizontalBlock1_startX
		PUSH horizontalBlock1_startY 
		
    	CALL DrawRectangle			; drawing the first block
		
		PUSH VerticalBlock_EndX		;loading the parameters of second block
		PUSH VerticalBlock_EndY
		PUSH VerticalBlock_startX
		PUSH VerticalBlock_startY
		
		CALL DrawRectangle		  ; drawing the second block
		
		PUSH horizontalBlock2_EndX		;loading the parameters of second block
		PUSH horizontalBlock2_EndY
		PUSH horizontalBlock2_startX
		PUSH horizontalBlock2_startY
		
		CALL DrawRectangle
	RET
ENDP  setBlocks



setGameParameters		PROC NEAR

		CALL setGraphicsMode
		CALL setBlocks
		CALL setRocketPosition
		CALL RestartBallPositionProc
		
		MOV isGameOver, 00H
		MOV player_score, 00H
		
		MOV SI, OFFSET player_print
		
		MOV AL, 30H  ;  '0'
		MOV AH, 20H	 ;  ' '
		MOV BL, 24H  ;  '$'
		
		MOV [SI], AL
		MOV [SI + 1], AH
		MOV [SI + 2], BL
		MOV BALL_color, 0EH

	RET
ENDP    setGameParameters

 
 
PrintWinGame    PROC    NEAR
    
    CALL setGraphicsMode
	
	MOV AH, 60D
	MOV AL, 160D
	PUSH AX
	
	CALL setCursorProc
	
	MOV DX, OFFSET winGameMsg
	MOV AH, 09H
	INT 21H
	
	RET
    
ENDP PrintWinGame


setRocketPosition   PROC    NEAR
    
    MOV ROCKET_StartX, 285D
    MOV ROCKET_StartY, 100D
    MOV ROCKET_EndX, 288D
    MOV ROCKET_EndY, 132D
    
    RET    

ENDP    setRocketPosition 



setScoreOnLED       PROC  NEAR
    
    MOV DX, 199     ; using the port 199 to work with LED. 
    MOV AL, player_score
    OUT DX, AL
        
    RET  
ENDP    setScoreOnLED
   
     END MAIN
