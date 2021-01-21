;org 0x100 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	MULTIPLICATION USING MUL Subroutine	;;
;; Printing result and cycles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mov cx,0x3E80
looping:
push cx
;stroing starting clocks
xor eax,eax
xor edx,edx
cpuid
rdtsc
mov [time],eax
mov [time+4],edx

push multiplicand
push multiplier 	;ExtMUL Subroutine call
call ExtMUL


;storing clocks ending clocks and counting difference
rdtsc
clc
sub eax,[time]
sbb edx,[time+4]
clc
add [avgtime],eax
adc [avgtime+4],edx
;mov [avgtime+4],edx
;mov [avgtime],eax
add [comulativetime],eax
adc [comulativetime+4],edx

pop cx
cmp cx ,0x3E80
je skipavg
	shr dword[avgtime+4],1
	rcr dword[avgtime],1
skipavg:
loop looping
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;printing result and clock time
call ClearScreen
push 160
push 64
push result
call PrintNum

;;Clock cycles printing
push 960
push 4
push avgtime
call PrintNum

;;commulative time
push 1120
push 4
push comulativetime
call PrintNum
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;terminating program
mov ax,0x4c00
int 0x21


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;	Clearing the result	;;;;;;;;;;;
ClearResult:
mov cx,32
xor bx,bx
loopc:
	mov dword[result+bx],0
	add bx,4
	loop loopc
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;;;;;;;;;;	512_bit extanded multiplication	;;;;;;;
ExtMUL:

call ClearResult

push bp
mov bp,sp

pusha			;pushing everything to retain original data

xor di,di		;DI will hold the offset for multiplier and result chunk

mov cx,16							;16x32 = 512 bits of multiplier

loop1:
	
	push cx
	
	xor bx,bx
	mov cx,16						;loop that holds one chunk of multiplier and multiplies it with all multiplicand chunks
	muladd:
		mov si,[bp+6]				;Getting multiplicand adddress
		mov eax, [si+bx]			;getting the chunk of multiplicand into eax
		
		mov si,[bp+4]				;Getting multiplier address
		add si,di					;getting address of current multiplier chunk which is in process of multiplication with multiplicand chunks
		mul dword[si]		
		
		push bx
		add bx,di
		add [result+bx],eax			;adding lower and upper bytes of MUL in result
		adc [result+bx+4],edx
		
		checkcarry:
			jnc skpcadd				;checking if there is a carry after adding edx:eax into result
			add bx,4				;increamenting bx to traverse upper bits of result to add carry
			adc dword[result+bx+4],1
		jmp checkcarry	
		skpcadd:
		
		pop bx
		add bx,4
	loop muladd
	
	add di,4	;keeping count of bytes of multiplier that has been multiplied
	pop cx	
loop loop1

popa
pop bp
ret 4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



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
ACode db '0123456789ABCDEF',0
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



multiplier dw   0xFFFF,0x0238,0xADE9,0x67EE,0x7675,0xF1E2,0x1D11,0x161C,0xB65C,0x201A,0x6519,0x7237,0x3790,0x6502,0x2013,0x10BA,0x1938,0x1202,0x8362,0xAC72,0x8390,0xCD92,0x2213,0x6675,0x8778,0x4AB9,0xF765,0xD738,0x26AB,0x0000,0x0000,0x0000    
multiplicand dw 0x9120,0x7210,0x1521,0xEDD6,0x625E,0x6621,0xF723,0xFFFF,0x31FF,0x3726,0x4DE2,0x6125,0x3623,0xBC82,0x8273,0x8273,0x9374,0xBBCC,0x8162,0x9127,0x2830,0x2EF2,0x2517,0xAD71,0x8754,0x5712,0x9ABC,0x2362,0xEDA7,0x8162,0xBCD2,0xA128              
result times 64 dw 0
time dd 0,0
avgtime dd 0,0
comulativetime dd 0,0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	PROFILE		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This Program takes 3710 cycles on average to calculuate the result of multiplication of two 512 bit numbers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;