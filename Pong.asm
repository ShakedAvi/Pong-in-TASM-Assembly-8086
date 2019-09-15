;********************
;	Pong Project	*
;     Shaked		*
;********************

MODEL small
STACK 100h


DATASEG

; -----------------
; Variables Here
; -----------------

include PongAsc.asm			;Including ASCII Art File

xCoor equ [bp + 6]
yCoor equ [bp + 4]

firstScore equ [bp + 6]
secondScore equ [bp + 4]

UP equ 1
DOWN equ 2

player1X equ 20
player2X equ 300

ballUp equ -5
ballDown equ 5
ballRight equ 5
ballLeft equ -5

paddle struc
	x dw ?
	y dw ?
	score dw ?
paddle ends

direction dw 0

paddleLen dw 35
paddleColor db 15

player1 paddle <0>
player2 paddle <0>

xBall dw 160
yBall dw 100
ballRunX dw 0
ballRunY dw 0

msg1 db 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9, 9, 9, 9, "   You Lost!$"
msg2 db 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9, 9, 9, 9, "   You Won!$"

Clock equ es:6Ch

CODESEG

; -----------------
; Code Here
; -----------------

‏‏include PongPro.asm			;Including Procedures File

start:
	mov ax, @data
	mov ds, ax
	
	mov [player1.y], 75
	
	mov [player1.x], player1X
	mov [player2.x], player2X
	
	mov [player1.score], 0
	mov [player2.score], 0
	
	call clearScreen
	call startPrint
	
	mov ax, 13h ; Graphic Mode Set
	int 10h ; BIOS Graphic Mode Interrupt
	
	mov [ballRunX], ballRight
	mov [ballRunY], ballUp
	
	gameLoop:
		WaitForData:
			in al, 64h ; Read keyboard status port
			cmp al, 10b ; Data in buffer ?
			
			call waitMilliseconds
			call clearScreen
			
			push [player1.x]
			push [player1.y]
			call drawPaddle
			
			push [player2.x]
			push [player2.y]
			call drawPaddle
			
			mov ax, [yBall]
			cmp ax, 185
			ja continue
			cmp ax, 15
			jb continue
			mov [player2.y], ax
			sub [player2.y], 17
			
			continue:
				mov ax, [ballRunX]
				add [xBall], ax
				mov ax, [ballRunY]
				add [yBall], ax
				
				push xBall
				push yBall
				call drawBall
			
				cmp [xBall], player1X+1
				jbe ballOn1X
				
				cmp [xBall], player2X-5
				jae ballOn2X
				
				jmp continueCheck
				
				ballOn2X:
					mov ax, [player2.y]
					cmp [yBall], ax
					jae ballOn2Y
					mov [xBall], 160
					mov [yBall], 100
					inc [player1.score]
					cmp [player1.score], 3
					push [player1.score]
					push [player2.score]
					call printScore
					je dontContinueCheck
					jmp continueCheck
					dontContinueCheck:
						jmp player2Lost
						
						ballOn2Y:
							add ax, 35
							cmp [yBall], ax
							ja oneGotPoint
							jmp ballOnPlayer2
							oneGotPoint:
								mov [xBall], 160
								mov [yBall], 100
								mov ax, [player1.score]
								inc ax
								mov [player1.score], ax
								cmp [player1.score], 3
								push [player1.score]
								push [player2.score]
								call printScore
								jne continueCheck
								jmp player2Lost
							
				ballOn1X:
					mov ax, [player1.y]
					cmp [yBall], ax
					jae ballOn1Y
					mov [xBall], 160
					mov [yBall], 100
					mov [player1.x], 20
					mov [player1.y], 75
					inc [player2.score]
					push [player1.score]
					push [player2.score]
					call printScore
					cmp [player2.score], 3
					jne continueCheck
					jmp player1Lost
						ballOn1Y:
							add ax, 35
							cmp [yBall], ax
							jbe ballOnPlayer1
							mov [xBall], 160
							mov [yBall], 100
							mov [player1.x], 20
							mov [player1.y], 75
							inc [player2.score]
							push [player1.score]
							push [player2.score]
							call printScore
							cmp [player2.score], 3
							jne continueCheck
							jmp player1Lost
							
				continueCheck:
					cmp [yBall], 4
					jbe ballOnTop
					
					cmp [yBall], 195
					jae ballOnGround
					
					jmp getKeyboard
				
				ballOnPlayer1:
					mov [ballRunX], ballRight
					cmp [ballRunY], ballDown
					je getBallDown
					jmp getBallUp
				
				ballOnPlayer2:
					mov [ballRunX], ballLeft
					cmp [ballRunY], ballDown
					je getBallDown
					jmp getBallUp
					
				ballOnTop:
					mov [ballRunY], ballDown
					cmp [ballRunX], ballRight
					je getBallRight
					jmp getBallLeft
					
				ballOnGround:
					mov [ballRunY], ballUp
					cmp [ballRunX], ballRight
					je getBallRight
					jmp getBallLeft
					
				getBallUp:
					mov [ballRunY], ballUp
					jmp getKeyboard
				
				getBallDown:
					mov [ballRunY], ballDown
					jmp getKeyboard
					
				getBallLeft:
					mov [ballRunX], ballLeft
					jmp getKeyboard
				
				getBallRight:
					mov [ballRunX], ballRight
					jmp getKeyboard
				
			getKeyboard:
					in al, 60h ; Get keyboard data
					
					cmp al, 48h ; Is it the up Key ?
					je upMove
					
					cmp al, 50h ; Is it the down Key ?
					je downMove
			
					cmp al, 1h ; Is it the ESC key ?
					jne continueWaiting
					jmp exit
					
					continueWaiting:
						jmp WaitForData
					
					upMove:
						cmp [player1.y], 0
						ja doDownMove
						jmp WaitForData
						
						doDownMove:
							sub [player1.y], 5
							jmp gameLoop
						
					downMove:
						cmp [player1.y], 165
						jb doMoveUp
						jmp WaitForData
						
						doMoveUp:
							add [player1.y], 5
							jmp gameLoop

player1Lost:
	mov ah, 0
	mov al, 2
	int 10h
	
	push seg msg1
	pop ds
	mov dx, offset msg1
	mov ah, 9h
	int 21h
	
	mov si, 9
	wait5SecondsA:
		dec si
		call waitHalfASecond
		cmp si, 0
		jne wait5SecondsA
	jmp exit
	
player2Lost:
	mov ah, 0
	mov al, 2
	int 10h
	
	push seg msg2
	pop ds
	mov dx, offset msg2
	mov ah, 9h
	int 21h
	
	mov si, 9
	
	wait5SecondsB:
		dec si
		call waitHalfASecond
		cmp si, 0
		jne wait5SecondsB
	jmp exit
	
exit:
	mov ah, 0
	mov al, 2
	int 10h
	
	mov ax, 4c00h
	int 21h
END start