radix 16
.model tiny
.stack 1000
data segment 
	flags db 00
	num db 0,1,2,3,4
	; таблица перекодировки чисел: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, точки
	tab db 03Fh, 006h, 05Bh, 04Fh, 066h, 06Dh, 07Dh, 007h, 07Fh, 06Fh, 080h
	scan db 001h 
data ends
code segment
assume cs:Code, ds:Data, es:data

Start:
	; инициализация регистров
	mov ax,data
	mov ds,ax
	mov es,ax
    ; настройка счётчика позиции символа
	mov si, 00h
	mov al, 00h
	nop ;out port, al
	; инициализация таймера
	mov al, 01h
	nop ;out port, al
	mov al, 02h
	nop ;out port, al  
	mov al, 03h       
	nop ;out port, al
	; инициализация контроллера прерываний
	mov al, 01h
	nop ;out port, al
	mov al, 02h
	nop ;out port, al
	mov al, 03h
	nop ;out port, al
	nop; sti ; включение аппаратных прерываний
fon:
	test flag, 01h
	jnz ind
	jmp fon
ind:
	and flag, 0FEh     ; сбрасываем флаг
	mov al, 00h        ; тушим индикатор
	nop ;out port, al
	mov bx, offset num ; получаем число
	mov al, [bx+si]
	mov bx, offset tab ; получаем код числа из таблицы перекодировки
	xlat               ; записываем текущую позицию
	nop ;out port, al 
	mov al, scan       ; счётчик текущей позиции
	nop ;out port, al 
	rol scan, 01h      ; сдвиг циклический левый
	inc si
	and si, 04h 	   ; получаем следующую позицию
	jmp fon
ind_int:
	or flag, 01h 	   ; установили флаг
	; инициализация таймера
	mov al, 01h
	nop ;out port, al
	mov al, 02h
	nop ;out port, al
	mov al, 03h
	nop ;out port, al
jmp fon ; iret

code ends
end Start