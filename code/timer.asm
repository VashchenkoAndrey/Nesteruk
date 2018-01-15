.radix 16
.model tiny
.stack 1000
dat segment
	; частота таймера = 1 Hz = 1 такт за 1 секунду
	flags     db 00 ; регистр флагов 
	s	      db 00 ; счётчик секунд
	m	  	  db 00 ; счётчик минут
	h	  	  db 00 ; счётчик часов
	sl        db 00 ; счётчик младшей части секунд
	ml        db 00 ; счётчик младшей части минут
	hl     	  db 00 ; счётчик младшей части часов
	sh 	 	  db 00 ; счётчик старшей части секунд
	mh  	  db 00 ; счётчик старшей части минут
	hh  	  db 00 ; счётчик старшей части часов
	m_comp 	  db 00 ; регистр сравнения минут
	h_comp 	  db 00 ; регистр сравнения часов
dat ends
Code segment
	Assume cs : Code, ds : dat, es : dat
	
Start:
	; инициализация регистров
	mov ax, dat
	mov ds, ax
	mov es, ax
	; инициализация таймера: 3 операции * 2 строки на операцию = 6 строк
	nop ; 2
	nop ; 3
	nop ; 4
	nop ; 5
	nop ; 6
fon:
	test flags, 40h
	jnz clock_update
	jmp fon
tim_int:
	or timers_flags, 01h
	; инициализация таймера: 3 операции * 2 строки на операцию = 6 строк
	nop ; 2
	nop ; 3
	nop ; 4
	nop ; 5
	nop ; 6
	jmp fon

sl_update: ; процедура накручивания младшей части секунд
	inc s        		   ; накручиваем счётчик секунд
	inc sl       		   ; накручиваем счётчик младшей части секунд
	cmp sl, 0Ah  		   ; сравниваем значение счётчика с 9
	je sh_update
	jmp fon
	
sh_update: ; процедура накручивания старшей части секунд
	mov sl, 00h  ; сбрасываем счётчик младшей части секунд
	inc sh		 ; накручиваем счётчик старшей части секунд
	cmp sh, 6h   ; сравниваем значение счётчика с 6
	je ml_update
	jmp fon
	
ml_update: ; процедура накручивания младшей части минут
	mov sh, 00h  ; сбрасываем счётчик старшей части секунд
	mov s, 00h   ; сбрасываем счётчик секунд
	inc m   	 ; накручиваем счётчик минут
	inc ml 	     ; накручиваем счётчик младшей части минут
	test timers_flags, 80h
	jnz test_time
	cmp ml, 0Ah  ; сравниваем значение счётчика с 9
	je mh_update
	jmp fon
mh_update: ; процедура накручивания старшей части минут
	mov ml, 00h ; сбрасываем счётчик младшей части минут
	inc mh 	    ; накручиваем счётчик старшей части минут
	test timers_flags, 80h
	jnz test_time
	cmp mh, 6h  ; сравниваем значение счётчика с 6
	je h_update
	jmp fon
h_update: ; процедура накручивания часов
	mov mh, 00h  ; сбрасываем счётчик старшей части минут
	mov m, 00h   ; сбрасываем счётчик минут
	inc h		 ; накручиваем счётчик часов
	cmp h, 18h   ; сравниваем значение счётчика с 24
	je h_dump
	inc hl		 ; накручиваем счётчик младшей части часов
	cmp hl, 0Ah  ; сравниваем значение счётчика с 9
	je  hh_update
	jmp fon
h_dump: ; процедура сброса часов
	mov h, 00h
	mov hl, 00h
	mov hh, 00h
	jmp fon
hh_update: ; процедура накручивания старшей части часов
	mov hl, 00h ; сбрасываем счётчик младшей части часов
	inc hh      ; накручиваем счётчик старшей части часов
	jmp fon
test_time:
	mov al, m_comp
	cmp m, al
	je test_h
	jmp fon
test_h:
	mov al, h_comp
	cmp h, al
	je set_flag_cleaning
	jmp fon
dump_flag_mh:
	or flags, 100h
	jmp fon
Code ends
end Start