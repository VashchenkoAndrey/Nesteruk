.radix 16
.model tiny
.stack 1000
dat segment
	; частота таймера = 1 MHz = 1 такт за 1 микросекунду
	timers_flags     db 00 ; регистр флагов таймера
	mcs 	         db 00 ; счётчик микросекунд
	ms				 db 00 ; счётчик милисекунд
	s	  	 		 db 00 ; счётчик секунд
	m	  	 		 db 00 ; счётчик минут
	h	  	 		 db 00 ; счётчик часов
	sl      	     db 00 ; счётчик младшей части секунд
	ml      		 db 00 ; счётчик младшей части минут
	hl     	         db 00 ; счётчик младшей части часов
	sh 	 		     db 00 ; счётчик старшей части секунд
	mh  	 		 db 00 ; счётчик старшей части минут
	hh  		     db 00 ; счётчик старшей части часов
	mcs_comp 		 db 00 ; регистр сравнения микросекунд
	ms_comp 		 db 00 ; регистр сравнения милисекунд
	s_comp 		 	 db 00 ; регистр сравнения секунд
	m_comp 			 db 00 ; регистр сравнения минут
	h_comp 		 	 db 00 ; регистр сравнения часов
dat ends
Code segment
	Assume cs : Code, ds : dat, es : dat
	
Start:
	mov ax, dat
	mov ds, ax
	mov al, 01h          ; инициализация таймера
	mov es, ax
	nop ;out port, al
	mov al, 02h
	nop ;out port, al  
	mov al, 03h       
	nop ;out port, al
	
fon:
	test flags, 01h      ; проверяем флаг перезагрузки таймера
	jnz update_mcs
	jmp fon
	
tim_int:
	or timers_flags, 01h
	mov al, 01h          ; перезагрузка таймера
	nop ;out port, al
	mov al, 02h
	nop ;out port, al  
	mov al, 03h       
	nop ;out port, al
	jmp back
	
update_mcs: ; процедура накручивания микросекунд
	and flags, 0FEh 	   ; сбрасываем флаг
	inc mcs				   ; накручиваем счётчик микросекунд
	test timers_flags, 02h ; проверяем флаг для отсчёта микросекунд
	jnz test_mcs
	cmp mcs, 3E8h   	   ; сравниваем значение счётчика с 1000
	je ms_update
	jmp fon
	
test_mcs:
	dec mcs_comp 		   ; отсчитываем микросекунды
	cmp mcs_comp, 00h
	je dump_flag_mcs
ret
	
dump_flag_mcs:
	and timers_flags, 0FDh
ret
	
ms_update: ; процедура накручивания милисекунд
	mov mcs, 00h 		   ; сбрасываем счётчик микросекунд
	inc ms 		 		   ; накручиваем счётчик милисекунд
	test timers_flags, 10h ; проверяем флаг для отсчёта милисекунд
	jnz test_ms
	cmp ms, 3E8h 		   ; сравниваем значение счётчика с 1000
	je sl_update 
	jmp fon

test_ms:
	dec ms_comp
	cmp ms_comp, 00h
	je dump_flag_ms
ret

dump_flag_ms:
	and timers_flags, 0EFh
ret

sl_update: ; процедура накручивания младшей части секунд
	mov ms, 00h  		   ; сбрасываем счётчик милисекунд
	inc s        		   ; накручиваем счётчик секунд
	test timers_flags, 04h ; проверяем флаг для отсчёта секунд
	jnz test_s
	inc sl       		   ; накручиваем счётчик младшей части секунд
	cmp sl, 0Ah  		   ; сравниваем значение счётчика с 9
	je sh_update
	jmp fon
	
test_s:
	dec s_comp 			   ; отсчитываем секунды
	cmp s_comp, 00h
	je dump_flag_s
ret
	
dump_flag_s:
	and timers_flags, 0FBh
ret
	
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
	test timers_flags, 08h
	jnz test_m
	inc ml 	     ; накручиваем счётчик младшей части минут
	cmp ml, 0Ah  ; сравниваем значение счётчика с 9
	je mh_update
	jmp fon
	
test_m:
	mov al, m_comp
	cmp m, al
	je test_h
ret

test_h:
	mov al, h_comp
	cmp h, al
	je dump_flag_mh
ret

dump_flag_mh:
	and timers_flags, 0F7h
ret

mh_update: ; процедура накручивания старшей части минут
	mov ml, 00h ; сбрасываем счётчик младшей части минут
	inc mh 	    ; накручиваем счётчик старшей части минут
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
	
Code ends
end Start