.radix 16
.model tiny
.stack 1000
dat segment
	flags db 00
dat ends
Code segment
	Assume cs : Code, ds : dat, es : dat
Start:
	; инициализация регистров
	mov ax, dat
	mov ds, ax
	mov es, ax
	; инициализация таймера 3 операции * 2 строчки на операцию = 6 строк кода
	nop ; 2
	nop ; 3
	nop ; 4
	nop ; 5
	nop ; 6
	; инициализация контроллеров прерываний
	nop ; первый ведущий, второй ведомый, адресация 4 байта
	nop ; после обаботки прерывания сбрасываются
	nop ; после обаботки прерывания сбрасываются
	nop ; приоритет фиксированный
	nop ; приоритет фиксированный
	nop ; начальный адрес
	nop ; конечный адрес
	jmp fon
fon:
	test flags, 01h
	jnz search_doc_station
	test flags, 02h
	jnz dump_search_doc_station
	test flags, 04h
	jnz notif_ovf_col
	test flags, 10h
	jnz rettling_tim_enable
	test flags, 20h
	jnz indication_update
	test flags, 40h
	jnz clock_update
	test flags, 100h
	jnz cleaning
	jmp fon
battery_flag_set: ; функция установки флага, обозначающего заряд батареи ниже 30%
	or flags, 01h
	jmp fon
charge_flag_set: ; функция установки флага, обозначающего зарядку батареи (постановка пылесоса на док-станцию)
	or flags, 02h
	jmp fon
dust_collector_flag_set: ; функция установки флага, обозначающего заполнение пылесборника
	or flags, 04h
	jmp fon
collision_flag_set: ; функция установки флага, обозначающего столкновение с препятствием
	or flags, 08h
	jmp fon
keyboard_flag_set: ; функция установки флага, обозначающего нажатие на кнопку клавиатуры
	or flags, 10h
	jmp fon
ind_update_flag_set: ; функция установки флага, обозначающего заряд батареи ниже 30%
	or flags, 20h
	jmp fon
clock_update_flag_set: ; функция установки флага, обозначающего заряд батареи ниже 30%
	or flags, 40h
	jmp fon
Code ends
end Start