.radix 16
.model tiny
.stack 1000
dat segment
	flags db 00
	cleaning_flags db 00
	;какие-то переменные
dat ends
Code segment
	Assume cs : Code, ds : dat, es : dat
Start: 	
	mov ax, dat
	mov ds, ax
	mov es, ax
	; инициализация таймера
	mov al, 01h
	nop ;out port, al
	mov al, 02h
	nop ;out port, al  
	mov al, 03h       
	nop ;out port, al
	
Code ends
end Start