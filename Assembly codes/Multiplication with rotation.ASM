org 0x100 

xor eax,eax
xor edx,edx

;db 0x0f,0xa2
;db 0x0f,0x31
cpuid				;same work done by above op code and the instructions
rdtsc
mov [time1],eax
mov [time1+4],edx

;;mov word[multiplier],2

mov dx,512

loop1:
	clc
	mov bx,64		;counter for shifting multiplier which consist of 32 words i.e 64 bytes
	
	shift1:
		rcr word [multiplier+bx-2],1		;multiplier base address + index
		dec bx
		dec bx
		jnz shift1
	
	jnc skipadd
	clc
	xor bx,bx
	mov cx,64
	adding:
		mov ax,[multiplicand+bx]
		adc [result+bx],ax
		inc bx
		inc bx
		loop adding
	skipadd:
	
	clc
	xor bx,bx
	mov cx,64
	shift2:
		rcl word [multiplicand+bx],1
		inc bx
		inc bx
		loop shift2

dec dx
jnz loop1

;storing clocks
rdtsc
clc
sub eax,[time1]
sbb edx,[time1+4]

mov [time2+4],edx
mov [time2],eax


mov ax,0x4c00
int 0x21


multiplier: dw   0xFFFF,0x0238,0xADE9,0x67EE,0x7675,0xF1E2,0x1D11,0x161C,0xB65C,0x201A,0x6519,0x7237,0x3790,0x6502,0x2013,0x10BA,0x1938,0x1202,0x8362,0xAC72,0x8390,0xCD92,0x2213,0x6675,0x8778,0x4AB9,0xF765,0xD738,0x26AB,0x0000,0x0000,0x0000    
multiplicand: dw 0x9120,0x7210,0x1521,0xEDD6,0x625E,0x6621,0xF723,0xFFFF,0x31FF,0x3726,0x4DE2,0x6125,0x3623,0xBC82,0x8273,0x8273,0x9374,0xBBCC,0x8162,0x9127,0x2830,0x2EF2,0x2517,0xAD71,0x8754,0x5712,0x9ABC,0x2362,0xEDA7,0x8162,0xBCD2,0xA128              
multiplicandshift:times 32 dw 0x0 
result: times 64 dw 0
time1: dd 0,0
time2: dd 0,0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	PROFILE		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This Program takes 2.7 lac cycles on average to calculuate the result of multiplication of two 512 bit numbers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;