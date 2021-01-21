org 100h

jmp start
counter: dw 0
Acode: db '0123456789ABCDEF'

timer:
push es
push ax
push cx
push bx
push di

inc word[cs:counter]

mov ax, 0xb800 					; load video base in ax
mov es, ax 						; point es to video base
mov di, 158 						; point di to top left column
mov ah,0x07
mov bx,[cs:counter]				;counter into bx
mov cx,4

nextchar
push bx							
and bx,0x000f
mov al,[cs:Acode+bx]
mov word[es:di], ax
pop bx
shr bx,4 		
sub di, 2 						; move to next screen location
loop nextchar 	

mov al,0x20
out 0x20,al

pop di
pop bx
pop cx
pop ax
pop es

iret


start:
mov ax,0
mov es,ax
cli
mov word[es:8*4],timer
mov word[es:8*4+2],cs
sti
mov dx,start
add dx,15		;rounding up
shr dx,4		;number of paras
mov ax,3100h
int 21h