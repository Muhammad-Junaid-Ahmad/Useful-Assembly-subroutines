org 100h

;;;;;;;;;;;;;;;Scrolling UP/Down Sub routines

call ScrollDown
call ScrollDown
call Delay
call ScrollUp

mov ax,4c00h
int 21


;;Scroll Up one line
ScrollUp:
push ds
push es
pusha

mov ax,0xb800
mov es,ax
mov ds,ax

mov si,160
xor di,di
mov cx,1920
cld
rep movsw

xor ax,ax
mov cx,80
rep stosw

popa
pop es
pop ds
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Scroll Down one line
ScrollDown:
push ds
push es
pusha

mov ax,0xb800
mov es,ax
mov ds,ax

mov si,3840
mov di,4000
mov cx,1920
std
rep movsw

xor ax,ax
mov cx,80
rep stosw

popa
pop es
pop ds
ret

;;;;;Just Delaying
Delay:
	push ax
	push cx
	mov cx,0x0f00
	l1:
		push cx
		mov cx,0x00ff
		l2:
			mov ax,cx
		loop l2
		pop cx
	loop l1
	
	pop cx
	pop ax
	
ret

