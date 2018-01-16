.radix 16
.model tiny
.stack 1000
dat segment
	flags         db 00
	bat_low_sound db 0E2h, 0E2h, 0Fh, 0E2h, 0Fh, 0C2h, 0E2h, 0Fh, 0F2h, 0Fh, 0Fh, 0F1h, 0Fh, 0Fh
	ovf_col_sound db 0C2h, 0D2h, 0D2h ,0C2h, 0D2h, 0D2h, 0D2h, 0F2h, 0B2h, 0D2h, 0F2h, 0B2h, 0F2h, 0B2h
	count         db 00h
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
	test flags, 01h
	jnz notif_bat_low
	test flags, 02h
	jnz notif_ovf_col
	test flags, 08h
	jnz delay_sound
	test flags, 10h
	jnz next_note
	jmp fon
notif_bat_low:
	mov ds, offset bat_low_sound
	and flags,  0FEh
	jmp notif
notif_ovf_col:
	mov ds, offset ovf_col_sound
	and flags, 0FDh
	jmp notif
notif:
	inc count
	cmp count, 0Eh
	je end_sound
	or flags, 04h
	; запускаем таймер звуковой частоты
	mov al, byte ptr[ds+count]
	nop ; out port x, al ; помещаем элемент массива частот в регистр сравнения таймера
	nop ; 4
	nop ; 5
	nop ; 6
	mov al, 01h
	nop ; out port x, al ; выводим "1" на порт динамика
	jmp fon
delay_sound:
	and flags, 0FBh
	and flags, 0F7h
	mov al, 01h
	nop ; out port x, al ; выводим "0" на порт динамика
	; запускаем таймер задержки между уровнями
	mov al, 32h ; 50мкс
	nop ; out port x, al ; помещаем элемент массива частот в регистр сравнения таймера
	nop ; 4
	nop ; 5
	nop ; 6
next_note:
	and flags, 0E3h
	jmp notif
end_sound:
	mov flags, 00h
	jmp fon
timer_int:
	test flags, 04h
	jnz set_flag_delay
	jmp set_flag_sound
set_flag_delay:
	or flags, 08h
	jmp fon
set_flag_sound:
	or flags, 10h
	jmp fon
Code ends
end Start