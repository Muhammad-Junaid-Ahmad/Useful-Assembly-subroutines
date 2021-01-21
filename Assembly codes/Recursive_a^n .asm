[org 0x100]

push word[num]
push word[exp]
call PwrCal
mov word[result],ax

push word[num1]
push word[exp1]
call PwrCal
mov word[result1],ax

mov ax, 4c00h
int 21h


;;; Power Calculator;;;;;
PwrCal:

push bp 
mov bp,sp
push cx
push bx

mov bx,[bp+6]		;bx contains the number
mov cx,[bp+4]		;cx contains the exponent 

cmp cx,1
jne skip			;Base Condition 
mov ax,bx			;mov number into ax and then return when exponent becomes 1
jmp return

skip:
dec cx			;decreamenting the exponent to reach base case

push bx
push cx			;calling PwrCal Recursively
call PwrCal

mul bx			;multiplying current result in "ax" with given number stored in bx

return:
pop bx
pop cx			;clearing Stack from pushed registers 
pop bp
ret 4			;clearing parameters


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


num: dw 3
exp: dw 4
result: dw 0
num1: dw 9
exp1:dw 5
result1:dw 0