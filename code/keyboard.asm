.radix 16
.model tiny
.stack 1000
dat segment
	flags 	 db 00
	bufscan  db 00
	keycode  db 00
	last_key db 00
	m	  	 db 00 ; счётчик минут
	h	  	 db 00 ; счётчик часов
	ml       db 00 ; счётчик младшей части минут
	hl     	 db 00 ; счётчик младшей части часов
	mh  	 db 00 ; счётчик старшей части минут
	hh  	 db 00 ; счётчик старшей части часов
	m_comp 	 db 00 ; регистр сравнения минут
	h_comp 	 db 00 ; регистр сравнения часов
dat ends
Code segment
	Assume cs : Code, ds : dat, es : dat
Start:
	mov ax, dat
	mov ds, ax
	mov es, ax
	; инициализация контроллера прерываний
	mov al, 01h
	nop ;out port, al
	mov al, 02h
	nop ;out port, al
	mov al, 03h
	nop ;out port, al
	nop; sti ; включение аппаратных прерываний
	jmp fon
ext_int_press_but:
	or flags, 01h
	jmp fon
fon:
	test flags, 01h
	jnz rettling_timer_enable
	test flags, 02h
	jnz scan_port
	test flags, 04h
	jnz search_function
	jmp fon
rettling_timer_enable:
	and flags, 0FEh
 	; инициализация таймера на 20 мкс
	mov al, 01h
	nop ;out port, al
	mov al, 02h
	nop ;out port, al  
	mov al, 03h       
	nop ;out port, al
	jmp fon
timer_int:
	test flags, 20h
	jnz stop_alarm_timer
	or flags, 02h
	nop; запрет прерываний
	jmp fon
stop_alarm_timer:
	and flags, 0DFh
	jmp fon
scan_port:
	and flags, 0FDh
	mov al, 0b01000010 ; in port x, al
	mov bufscan, al
	test bufscan, 40h
	jnz update_keycode_hz
	jmp test_bufscan_vt
test_bufscan_vt:
	test bufscan, 02h
	jnz update_keycode_vt_02
	jmp test_bufscan_vt_2
test_bufscan_vt_2:
	test bufscan, 01h
	jnz update_keycode_vt_01
	jmp set_function_flag ; получен код клавиши
update_keycode_hz:
	or keycode, 01h
	jmp test_bufscan_vt
update_keycode_vt_02:
	or keycode, 04h
	jmp test_bufscan_vt_2
update_keycode_vt_01:
	or keycode, 08h
	jmp set_function_flag ; получен код клавиши
set_function_flag:
	or flags, 04h
	jmp fon
search_function:
	and flags, 0FBh
	cmp keycode, 00h
	je update_cleaning_flag
	cmp keycode, 01h
	je update_alarm_cleaning
	cmp keycode, 04h
	je set_time_minutes
	cmp keycode, 05h
	je set_time_hours
	cmp keycode, 08h
	je update_cleaning_speed
	cmp keycode, 09h
	je update_mute
	jmp fon
update_cleaning_flag:
	test flags, 08h
	jnz dump_cleaning_flag
	jmp set_cleaning_flag
dump_cleaning_flag:
	and flags, 0F7h
	nop ; разрешить прерывания
	jmp fon
set_cleaning_flag:
	or flags, 08h
	nop ; разрешить прерывания
	jmp fon
update_alarm_cleaning:
	test flags, 10h
	jnz dump_alarm_flag
	jmp set_alarm_flag
dump_alarm_flag:
	and flags, 0EFh
	nop ; разрешить прерывания
	jmp fon
set_alarm_flag:
	or flags, 10h
	or flags, 20h
	mov al, keycode
	mov last_key, al
	mov al, h
	mov h_comp, al
	mov al, m
	mov m_comp, al
	jmp restart_alarm_timer
	jmp fon
; нужно написать прерывание таймера на 3 секунды для установки времени будильника
set_time_minutes:
	test flags, 20h
	jnz set_alarm_minutes
	jmp set_clock_minutes
set_alarm_minutes:
	inc m_comp
	cmp m_comp, 3Ch
	je zero_m_comp
	jmp restart_alarm_timer
zero_m_comp:
	mov m_comp, 00h
	jmp restart_alarm_timer
restart_alarm_timer:
	; инициализация таймера на 3 сек
	mov al, 01h
	nop ;out port, al
	mov al, 02h
	nop ;out port, al  
	mov al, 03h       
	nop ;out port, al
	nop ; разрешить прерывания
	jmp fon
set_clock_minutes:
	inc m
	inc ml
	cmp ml, 0Ah
	je update_mh
	nop ; разрешить прерывания
	jmp fon
update_mh:
	mov ml, 00h
	inc mh
	cmp mh, 06h
	je zero_mh
	nop ; разрешить прерывания
	jmp fon
zero_mh:
	mov mh, 00h
	mov m, 00h
	nop ; разрешить прерывания
	jmp fon	
set_time_hours:
	test flags, 20h
	jnz set_alarm_hours
	jmp set_clock_hours
set_alarm_hours:
	inc h_comp
	cmp h_comp, 18h
	je zero_h_comp
	jmp restart_alarm_timer
zero_h_comp:
	mov h_comp, 00h
	jmp restart_alarm_timer
set_clock_hours:
	inc h
	cmp h, 18h
	je dump_h
	inc hl
	cmp hl, 0Ah
	je  update_hh
	nop ; разрешить прерывания
	jmp fon
update_hh:
	mov hl, 00h
	inc hh
	nop ; разрешить прерывания
	jmp fon
zero_mh:
	mov hh, 00h
	mov hl, 00h
	mov h, 00h
	nop ; разрешить прерывания
	jmp fon
update_cleaning_speed:
	test flags, 40h
	jnz dump_speed_flag
	jmp set_speed_flag
dump_speed_flag:
	and flags, 0BFh
	nop ; разрешить прерывания
	jmp fon
set_speed_flag:
	or flags, 40h
	nop ; разрешить прерывания
	jmp fon
update_mute:
	test flags, 80h
	jnz dump_mute_flag
	jmp set_mute_flag
dump_mute_flag:
	and flags, 7Fh
	nop ; разрешить прерывания
	jmp fon
set_mute_flag:
	or flags, 80h
	nop ; разрешить прерывания
	jmp fon
Code ends
end Start