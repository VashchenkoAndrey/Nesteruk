.radix 16
.model tiny
.stack 1000
dat segment
	flags    db 01h
	range_up db 00h
	range_dn db 00h
	range_lt db 00h
	range_rt db 00h
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
	jnz trig
	test flags, 04h
	jnz use_rangers
	jmp fon
trig:
	and flags, 0FEh
	; инициализация таймера на 10 мкс: 3 команды по 2 строчки на команду = 6 строчек
	nop ; out port x
	nop ; mov al, 02h
	nop ; out port x
	nop ; mov al, 03h
	nop ; out port x
	nop ; out port x ; выводим на порты trig дальномеров высокий уровень(1)
	jmp fon
timer_int:
	nop ; out port x ; выводим на порты trig дальномеров низкий уровень (0)
	; инициализация таймера на счёт времени: 3 команды по 2 строчки на команду = 6 строчек
	nop ; out port x
	nop ; mov al, 02h
	nop ; out port x
	nop ; mov al, 03h
	nop ; out port x
	jmp fon
range_up_int:
	nop ; in port x, ax ; считываем показания таймера
	mov cx, 3Ah ; 58
	div cx ; ax = ax/cx
	nop ; mov cx, const ; загружается какая-то константа для определения числа шагов движка
	nop ; div cx ; в ax получаем число шагов двигателя до препятствия
	mov range_up, ax
	inc di
	cmp di, 04h
	je end_echo
	jmp fon
range_dn_int:
	nop ; in port x, ax ; считываем показания таймера
	mov cx, 3Ah ; 58
	div cx ; ax = ax/cx
	nop ; mov cx, const ; загружается какая-то константа для определения числа шагов движка
	nop ; div cx ; в ax получаем число шагов двигателя до препятствия
	mov range_dn, ax
	inc di
	cmp di, 04h
	je end_echo
	jmp fon
range_lt_int:
	nop ; in port x, ax ; считываем показания таймера
	mov cx, 3Ah ; 58
	div cx ; ax = ax/cx
	nop ; mov cx, const ; загружается какая-то константа для определения числа шагов движка
	nop ; div cx ; в ax получаем число шагов двигателя до препятствия
	mov range_lt, ax
	inc di
	cmp di, 04h
	je end_echo
	jmp fon
range_rt_int:
	nop ; in port x, ax ; считываем показания таймера
	mov cx, 3Ah ; 58
	div cx ; ax = ax/cx
	nop ; mov cx, const ; загружается какая-то константа для определения числа шагов движка
	nop ; div cx ; в ax получаем число шагов двигателя до препятствия
	mov range_rt, ax
	inc di
	cmp di, 04h
	je end_echo
	jmp fon
end_echo
	; остановить таймер
	nop ; out port x
	or flags, 04h
use_rangers:
	nop ; расстояния до препятствий посчитаны, можно использовать
	and flags, 0FBh
Code ends
end Start