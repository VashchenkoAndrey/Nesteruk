.radix 16
.model tiny
.stack 1000
dat segment
	flags db 00
	cleaning_flags db 00
	;какие-то переменные
dat ends
Code segment
	Assume cs : Code, ds : dat, es : dat
Start: 	
	mov ax, dat
	mov ds, ax
	mov es, ax
	; инициализация таймера
	mov al, 01h
	nop ;out port, al
	mov al, 02h
	nop ;out port, al  
	mov al, 03h       
	nop ;out port, al
fon:
	test flags, 01h ; смотрим флаг о запросе состояния батареи
	jnz bat_test
	
	test flags, 02h ; смотрим флаг о обноовлении дисплея
	jnz display_update
	
	test flags, 04h ; смотрим флаг прерывания клавиатуры
	jnz keyb_int
	
	test flags, 08h ; смотрим флаг уборки
	jnz cleaning
	
	jmp fon
	
bat_test:
	nop; in port, al - запрашиваем бит состояния батареи
	test al, 80h
	jnz low_chrg_not
	jmp fon

	
	
low_chrg_not:
	; звуковое оповещение о севшей батарее
	jmp fon

	
	
display_update:
	; обновляем 7-сегментный дисплей
	jmp fon
	
	
	
keyb_int:
	; включаем таймер дребезга, ждём 20 мс, и начинаем опрашивать порты
	jmp fon
	
	
cleaning:
	; выставить флаг для опроса переднего дальномера
	; получить расстояние до препятствия спереди и отдать его алгоритму движения
	; 
	
Code ends
end Start