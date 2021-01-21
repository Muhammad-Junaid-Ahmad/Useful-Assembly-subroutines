org 0x100 

xor eax,eax
xor edx,edx

cpuid
rdtsc
mov [time1],eax
mov [time1+4],edx

;calling subroutine
push result
push multiplicand
push multiplier
call ExtMUL
add sp,6



;storing clocks
rdtsc
clc
sub eax,[time1]
sbb edx,[time1+4]

mov [time2+4],edx
mov [time2],eax

mov ax,0x4c00
int 0x21


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; 	Mul Subroutine	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ExtMUL:

push bp
mov bp,sp
pusha

;;;;;	clearing result and copying multiplicand to temp
mov cx,16
xor bx,bx
loopc:
	mov si, [bp+6]					;si = adress of multiplicand
	mov eax,[si+bx]
	mov dword[temp+bx],eax		; copying 512 bits of multiplicand to temp
	mov dword[temp+bx+64],0			; making further 512 bits of temp to zero
	
	mov si,	[bp+8]					;si = adress of result
	mov dword[si+bx],0				; clearing the result to zero
	mov dword[si+bx+64],0
	add bx,4
	loop loopc
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mov dx,512

loop1:
	clc
	mov bx,64		;counter for shifting multiplier which consist of 32 words i.e 64 bytes
	mov si,[bp+4]
	shiftR:							;multiplier shifitng
		rcr word [si+bx-2],1		;multiplier base address + index
		dec bx
		dec bx
	jnz shiftR
	
	jnc skipadd
	mov si,[bp+8]		
	push si					;address of result is pushed while multiplcand is copied to temp which can be used by name
	call ADD_Subroutine
	skipadd:
	
	call LeftShift		;no arguments because temp conatins multiplicand and it can be used by name

dec dx
jnz loop1

popa
pop bp
ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;	Addition subroutine	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ADD_Subroutine:
	push bp
	mov bp,sp
	clc
	mov si,[bp+4]		;address of result 
	xor bx,bx
	mov cx,64
	adding:
		mov ax,[temp+bx]	;temp is the shifted multiplicand
		adc [si+bx],ax
		inc bx
		inc bx
	loop adding
	
	pop bp
	ret 2
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;	Multiplicand Shifting subroutine -> actual temp shifitng because mutliplicand is in temp
LeftShift:
	clc
	xor bx,bx
	mov cx,64
	shift2:
		rcl word [temp+bx],1
		inc bx
		inc bx
		loop shift2
ret

multiplier: dw   0xFFFF,0x0238,0xADE9,0x67EE,0x7675,0xF1E2,0x1D11,0x161C,0xB65C,0x201A,0x6519,0x7237,0x3790,0x6502,0x2013,0x10BA,0x1938,0x1202,0x8362,0xAC72,0x8390,0xCD92,0x2213,0x6675,0x8778,0x4AB9,0xF765,0xD738,0x26AB,0x0000,0x0000,0x0000    
multiplicand: dw 0x9120,0x7210,0x1521,0xEDD6,0x625E,0x6621,0xF723,0xFFFF,0x31FF,0x3726,0x4DE2,0x6125,0x3623,0xBC82,0x8273,0x8273,0x9374,0xBBCC,0x8162,0x9127,0x2830,0x2EF2,0x2517,0xAD71,0x8754,0x5712,0x9ABC,0x2362,0xEDA7,0x8162,0xBCD2,0xA128              
;multiplicandshift:times 32 dw 0x0 
result: times 64 dw 0
temp: times 64 dw 0		;space for shifting multiplicand
time1: dd 0,0
time2: dd 0,0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	PROFILE		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This Program takes 2.7 lac cycles on average to calculuate the result of multiplication of two 512 bit numbers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;