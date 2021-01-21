[org 0x0100]

call ClearScreen
push 160
push 4
push num
Call PrintNum

push 240
push 26
push string
Call PrintString

push 320
push 26
push Hello
Call PrintString

push 480
push 32
push multiplier
Call PrintNum

mov ax, 0x4c00 		; terminate program
int 0x21


;;clearing screen;;;;;;;;;;;;
ClearScreen:
push es
push ax

mov ax, 0xb800 					; load video base in ax
mov es, ax 						; point es to video base
mov di, 0 						; point di to top left column
nextchar:
 mov word [es:di], 0x0720 		; clear next char on screen
add di, 2 						; move to next screen location
cmp di, 4000 					; has the whole screen cleared
jne nextchar 					; if no clear next position

pop ax
pop es
ret


;;;;;;Sub Routine to print number of any size;;;;;;;;
;Param 1 = address of num  
;Param 2 = size of number in words
;Param 3 = location of screen
PrintNum:
push bp
mov bp,sp
pusha

jmp skip
ACode: db '0123456789ABCDEF'
skip:

mov ax,0xb800
mov es,ax		;moving ES to video memory
mov ah,0x07		;setting attribute for words

xor bx,bx
mov si,[bp+4]	;adress of number
mov cx,[bp+6]
;Pushing every word onto stack
numtrav:
	mov di,4
	mov bx,[si]
	wordpush:			;spliting word into 4 bit parts and converting them into Hex and pushing
		push bx
		and bx,0x000F
		mov al,[ACode+bx]
		pop bx
		push ax
		shr bx,4
		dec di
	jnz wordpush
	add si,2
loop numtrav

mov bx,[bp+8]	;location of screen
mov cx,[bp+6]	;number of bytes of number

nextnum:								
	mov di,4		;poping every word and placing into video memory
	popword:
		pop ax
		mov [es:bx],ax
		add bx,2
		dec di
	jnz popword
	mov word[es:bx],0x0720		;placing a space after every word
	add bx,2
loop nextnum

popa
pop bp
ret 6

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Param 1 = adress of string
;Param 2 = lenght of string
;Param 3 = location of screen
PrintString:
push bp
mov bp,sp
pusha
mov ax,0xB800
mov es,ax

mov ah,0x07

mov bx,[bp+8]	;location of screen
mov si,[bp+4]	;adress of string
mov cx,[bp+6]	;lenght of string
stringtrav:
	mov al,[si]
	mov [es:bx],ax
	inc si
	add bx,2
loop stringtrav

popa
pop bp
ret 6


num: dw 0x1234,0x5678,0x9ABC,0xDEF0
string: db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
Hello: db 'Hello World!. How are you?'
multiplier: dw   0xFFFF,0x0238,0xADE9,0x67EE,0x7675,0xF1E2,0x1D11,0x161C,0xB65C,0x201A,0x6519,0x7237,0x3790,0x6502,0x2013,0x10BA,0x1938,0x1202,0x8362,0xAC72,0x8390,0xCD92,0x2213,0x6675,0x8778,0x4AB9,0xF765,0xD738,0x26AB,0x0000,0x0000,0x0000    
