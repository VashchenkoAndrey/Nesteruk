.radix 16
.model tiny
.stack 1000
dat segment
	flags db 00 		  ; регистр флагов
	BS1 db 00   		  ; буфер сканирования
	BS2 db 00   		  ; буфер позиции
	CPS db 1    		  ; счётчик горизонтального сканирования позиций
	RS db 0DDh  		  ; регистр горизонтального сканирования
	CV db 00    		  ; счётчик вертикального сканирования позиций
	RKC db 00   		  ; регистр вертикального сканирования
	RKK db 00   		  ; код клавиши
	RC db 00    		  ; регистр команд
	BD db 0,0,0,0,0,0,0,0 ; буфер данных
	OBD dw 00 			  ; буфер смещения данных
	AB dw 00			  ; буфер адреса
dat ends
Code segment
	Assume cs : Code, ds : dat, es : dat
Start: 	
	mov ax, dat
	mov ds, ax
	mov es, ax
fon: 	
	test flags, 01	  ; смотрим флаг прерывания
	jnz PROCI
f1:	
	test flags, 02 	  ; смотрим флаг дребезга
	jnz PROCK
f2: 
	test flags, 10    ; смотрим флаг оператора
	jnz INTOPT
	jmp fon
INTK: 	
	or flags, 01  	  ; ставим флаг нажатия кнопки
	mov al, RS        ; сохраняем регистр горизонтального сканирования
	mov BS1, al
	mov al, CPS       ; сохраняем счётчик позиций сканирования
	mov BS2, al
	nop; mov al, xxh  ; запрещаем прерывания
	; out port X
	jmp fon
INTTIME: 
	or flags, 02      ; ставим флаг прерывания таймера дребезга
	jmp fon
INTOPT: 
	nop; mov al, zzh  ; разрешаем прерывания
	; out port X
	jmp fon
PROCI:
	; инициализация таймера
	mov al, 01h
	nop ;out port, al
	mov al, 02h
	nop ;out port, al  
	mov al, 03h       
	nop ;out port, al
	and flags, 0FEh   ; сбрасываем флаг нажатия кнопки
	jmp f1
PROCK:		
	mov al, BS1
	nop; out port X, BS1
	nop; in al, PA
	mov al, BS2
	mov CPS, al
	mov RKC, al 	  ; перезаписываем регистр вертикального сканирования
	mov CV, 00h       ; сбрасываем счётчик вертикального сканирования позиций	
SRV:  	
	;test RKC, 01h
	;jz NXT
	inc CV
	shr RKC,1         ; правый сдвиг на 1
	jc SRV
NXT:		
	shl BS2, 2   	  ; левый сдвиг на 2
	mov al, BS2
	mov RKK, al 	  ; запихиваем вертикальный код кнопки в регистр кода клавиши
	or al, CV
	mov RKK,al		  ; запихиваем горизонтальный код кнопки в регистр кода клавиши
	cmp al, 09h 	  ; сравниваем полученный код
	jg M2 
	mov bx, offset BD
	mov AB, bx
	add bx, OBD
	mov byte ptr [bx],al
	inc OBD           ; прибавляем смещение буфера данных
	cmp OBD, 08h   	  ; если смещение = 8
	jnz M
	mov OBD, 00h	  ; смещение = 0
M:		
	and flags, 0FDh
	or flags, 08      ; данные получены
	jmp FINAL         
M2: 		
	mov al,RKK
	mov RC, al
	and flags, 0EFh   ; сбрасываем флаг дребезга
	or flags, 04      ; команда получена
FINAL:
	; инициализация таймера
	mov al, 01h
	nop ;out port, al
	mov al, 02h
	nop ;out port, al  
	mov al, 03h       
	nop ;out port, al
	jmp fon
Code ends
end Start