.radix 16
.model tiny
.stack 1000
dat segment
	; какие-нибудь переменные
dat ends
Code segment
	Assume cs : Code, ds : dat, es : dat
	
Start:
	; инициализация (в т.ч. периферии)
	mov ax, dat
	mov ds, ax
	mov es, ax
	jmp fon
fon:
	; основной программный цикл
jmp fon
	; далее идёт описание функций и прерываний
Code ends
end Start