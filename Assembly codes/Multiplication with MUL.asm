org 0x100 

;stroing starting clocks
xor eax,eax
xor edx,edx
cpuid
rdtsc
mov [time],eax
mov [time+4],edx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	MULTIPLICATION USING MUL	;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;mov word[multiplier],0x2000

mov bx,multiplier
mov word[count],0
mov cx,16							;16x32 = 512 bits of multiplier

loop1:
	push cx
	
	xor bx,bx
	mov cx,16						;loop that holds one chunk of multiplier and multiplies it with all multiplicand chunks
	muladd:
		mov eax, [multiplicand+bx]	;getting the chunk of multiplicand into eax
		
		push bx
		mov bx,[count]				;getting address of current multiplier chunk which is in process of multiplication with multiplicand chunks
		mul dword[multiplier+bx]		
		pop bx
		
		push bx
		add bx,[count]
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
	
	add word[count],4					;keeping count of bytes of multiplier that has been multiplied
	pop cx	
loop loop1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;storing clocks ending clocks and counting difference
rdtsc
clc
sub eax,[time]
sbb edx,[time+4]

mov [time+4],edx
mov [time],eax
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;terminating program
mov ax,0x4c00
int 0x21

multiplier: dw   0xFFFF,0x0238,0xADE9,0x67EE,0x7675,0xF1E2,0x1D11,0x161C,0xB65C,0x201A,0x6519,0x7237,0x3790,0x6502,0x2013,0x10BA,0x1938,0x1202,0x8362,0xAC72,0x8390,0xCD92,0x2213,0x6675,0x8778,0x4AB9,0xF765,0xD738,0x26AB,0x0000,0x0000,0x0000    
multiplicand: dw 0x9120,0x7210,0x1521,0xEDD6,0x625E,0x6621,0xF723,0xFFFF,0x31FF,0x3726,0x4DE2,0x6125,0x3623,0xBC82,0x8273,0x8273,0x9374,0xBBCC,0x8162,0x9127,0x2830,0x2EF2,0x2517,0xAD71,0x8754,0x5712,0x9ABC,0x2362,0xEDA7,0x8162,0xBCD2,0xA128              
result: times 64 dw 0
time: dd 0,0
count: dw 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	PROFILE		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This Program takes 3601 cycles on average to calculuate the result of multiplication of two 512 bit numbers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;