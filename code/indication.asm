radix 16
.model tiny
.stack 1000
data segment 
	flags db 00
	ml        db 00 ; счётчик младшей части минут
	hl     	  db 00 ; счётчик младшей части часов
	mh  	  db 00 ; счётчик старшей части минут
	hh  	  db 00 ; счётчик старшей части часов
	; таблица перекодировки чисел: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, точки, без точек
	tab db 03Fh, 006h, 05Bh, 04Fh, 066h, 06Dh, 07Dh, 007h, 07Fh, 06Fh, 080h, 00h
	scan db 10h 
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
	mov di, 00h
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
	jnz indication
	jmp fon
timer_int:
	or flag, 01h 	   ; установили флаг
	inc di
	and di, 64h
	; инициализация таймера
	mov al, 01h
	nop ;out port, al
	mov al, 02h
	nop ;out port, al
	mov al, 03h
	nop ;out port, al
	jmp fon ; iret
indication:
	and flag, 0FEh     ; сбрасываем флаг
	mov al, 00h        
	nop ;out port, al  ; тушим индикатор
	cmp si, 00h
	je update_hh
	cmp si, 01h
	je update_hl
	cmp si, 02h
	je update_dots
	cmp si, 03h
	je update_mh
	cmp si, 04h
	je update_ml
recode:
	mov bx, offset tab ; получаем код числа из таблицы перекодировки
	xlat               ; записываем текущую позицию
	nop ;out port, al  
	mov al, scan       ; счётчик текущей позиции
	nop ;out port, al  ; зажигаем индикатор
	ror scan, 01h      ; сдвиг циклический правый
	inc si
	and si, 04h 	   ; получаем следующую позицию
	jmp fon
update_hh:
	mov al, hh
	jmp recode
update_hl:
	mov al, hl
	jmp recode
update_dots:
	cmp di, 32h 	   ; 50 (точки должны моргать раз в 0.5 секунды)
	jnae dots_off
	mov al, 0Ah 	   ; 10 (на 10 позиции код точек)
	jmp recode
dots_off:
	mov al, 0Bh        ; 11 (на 11 позиции код без точек)
	jmp recode
update_mh:
	mov al, mh
	jmp recode
update_ml:
	mov al, hh
	jmp recode
code ends
end Start