clearScreen proc
	mov ax, 0600h    ;06 TO SCROLL & 00 FOR FULLJ SCREEN
	mov cx, 0000h    ;STARTING COORDINATES
	mov dx, 184Fh    ;ENDING COORDINATES
	int 10h
	
	ret
clearScreen endp

startPrint proc
	mov ah, 0
	mov al, 2
	int 10h
	
	push seg startMsg
	pop ds
	mov dx, offset startMsg
	mov ah, 9h
	int 21h
	
	mov ah, 1 ; Wait for keyboard input
	int 21h
	
	ret
startPrint endp

drawPaddle proc
	push bp
	mov bp, sp
	
	mov si, [paddleLen]

	mov cx,[xCoor]
	mov dx,[yCoor]
	mov al,[paddleColor]
	
	printPaddleX:
		; Print dot
		mov bh,0h
		mov ah,0ch
		int 10h
		
		inc dx
		
		dec si
		
		cmp si, 0
		jne printPaddleX
		
	mov si, [paddleLen]
	dec dx
	dec cx
		
	printPaddleY:
		; Print dot
		mov bh,0h
		mov ah,0ch
		int 10h
		
		dec dx
		
		dec si
		
		cmp si, 0
		jne printPaddleY
	
	pop bp
	ret 4
drawPaddle endp

drawBall proc
	push bp
	mov bp, sp
	
	mov si, 3
	
	mov cx,[xCoor]
	mov dx,[yCoor]
	mov al,[paddleColor]

	printBallX:
		; Print dot
		mov bh,0h
		mov ah,0ch
		int 10h
		
		inc cx
		
		dec si
		
		cmp si, 0
		jne printBallX
		
	mov si, 3
	inc dx
	dec cx
	
	printBallY:
		; Print dot
		mov bh,0h
		mov ah,0ch
		int 10h
		
		dec cx
		
		dec si
		
		cmp si, 0
		jne printBallY
		
	mov si, 3
	inc dx
	add cx, 3
	
	printBallZ:
		; Print dot
		mov bh,0h
		mov ah,0ch
		int 10h
		
		dec cx
		dec si
		
		cmp si, 0
		jne printBallZ
	
	pop bp
	ret 4
drawBall endp

waitMilliseconds proc
	readClockQuarter:
		mov ax, 40h
		mov es, ax
		mov ax, [Clock]
		
		FirstTickQuarter:
			cmp ax, [Clock]
			je FirstTickQuarter
			; count 55/1000 sec
			mov cx, 1; 1x0.055sec = ~55/1000 sec
		
		DelayLoopQuarter:
			mov ax, [Clock]
		TickQuarter:
			cmp ax, [Clock]
			je TickQuarter
			loop DelayLoopQuarter
	
	ret
waitMilliseconds endp

waitHalfASecond proc
	readClock:
		mov ax, 40h
		mov es, ax
		mov ax, [Clock]
		
		FirstTick:
			cmp ax, [Clock]
			je FirstTick
			; count 1/2 sec
			mov cx, 9 ; 9x0.055sec = ~1/2 sec
		
		DelayLoop:
			mov ax, [Clock]
		Tick:
			cmp ax, [Clock]
			je Tick
			loop DelayLoop
	
	ret
waitHalfASecond endp

printScore proc
	push bp
	mov bp, sp
	
	mov ah, 0
	mov al, 2
	int 10h
	
	push seg tabbing
	pop ds
	mov dx, offset tabbing
	mov ah, 9h
	int 21h
	
	mov dl, firstScore
	add dl, 30h
	mov ah, 2
	int 21h
	
	mov dl, '-'
	mov ah, 2
	int 21h
	
	mov dl, secondScore
	add dl, 30h
	mov ah, 2
	int 21h
	
	call waitHalfASecond
	call waitHalfASecond
	call waitHalfASecond
	call waitHalfASecond
	call waitHalfASecond
	call waitHalfASecond
	
	
	mov ax, 13h ; Graphic Mode Set
	int 10h ; BIOS Graphic Mode Interrupt
	
	pop bp
	ret 4
printScore endp
