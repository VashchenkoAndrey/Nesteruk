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
	test flags, 10h	  ; смотрим флаг прерывания
	jnz rettling_tim_enable
	test flags, 20h 	  ; смотрим флаг дребезга
	jnz PROCK
	test flags, 40h    ; смотрим флаг оператора
	jnz INTOPT
	jmp fon
press_but: 	
	or flags, 10h  	  ; ставим флаг нажатия кнопки
	mov al, RS        ; сохраняем регистр горизонтального сканирования
	mov BS1, al
	mov al, CPS       ; сохраняем счётчик позиций сканирования
	mov BS2, al
	nop ; запрещаем прерывания
	; out port X
	jmp fon
rettling_flag_set: 
	or flags, 20h      ; ставим флаг прерывания таймера дребезга
	jmp fon
INTOPT: 
	nop ; разрешаем прерывания
	; out port X
	jmp fon
rettling_tim_enable:
	; инициализация таймера: 3 операции * 2 строки на операцию = 6 строк
	nop ; 2
	nop ; 3
	nop ; 4
	nop ; 5
	nop ; 6
	and flags, 0EFh   ; сбрасываем флаг нажатия кнопки
	jmp fon
PROCK:		
	mov al, BS1
	nop; out port X, BS1
	nop; in al, PA
	mov al, BS2
	mov CPS, al
	mov RKC, al 	  ; перезаписываем регистр вертикального сканирования
	mov CV, 00h       ; сбрасываем счётчик вертикального сканирования позиций	
SRV:  	
	inc CV
	shr RKC,1         ; правый сдвиг на 1
	jc SRV	
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
	and flags, 0DFh   ; сбрасываем флаг дребезга
	or flags, 40h      ; команда получена
FINAL:
	; инициализация таймера: 3 операции * 2 строки на операцию = 6 строк
	nop ; 2
	nop ; 3
	nop ; 4
	nop ; 5
	nop ; 6
	jmp fon
Code ends
end Start