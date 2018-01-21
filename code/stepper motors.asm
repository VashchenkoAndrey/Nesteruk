.radix 16
.model tiny
.stack 1000
dat segment
	; моторы 200 шагов на оборот (1.8 градусов на шаг)
	flags             db 01
	left_motor_codes  db 01h, 02h, 04h, 08h
	right_motor_codes db 10h, 20h, 40h, 80h
	buf               db 00
	step_count        db 00
	left_motor_step   db 00
	right_motor_step  db 00
dat ends
Code segment
	Assume cs : Code, ds : dat, es : dat	
Start:
	mov ax, dat
	mov ds, ax
	mov es, ax
	jmp fon
fon:
	test flags, 01h
	jz fon
	test flags, 02h
	jnz step_up
	test flags, 04h
	jnz rotate_rt_sw
	test flags, 08h
	jnz rotate_lt_sw
	test flags, 10h
	jnz rotate_rt_ip
	test flags, 20h
	jnz rotate_lt_ip
	test flags, 40h
	jnz step_down
	jmp fon
step_up: ; ехать вперед
	mov buf, 00h
	mov ds, offset left_motor_codes
	mov si, left_motor_step
	mov al, byte ptr[ds+si]
	or al, buf
	inc si
	cmp si, 03h
	je step_up_zero_si_lt
	jmp con_step_up_rt
step_up_zero_si_lt:
	mov si, 00h
	mov left_motor_step, si
	jmp con_step_up_rt
con_step_up_rt:
	mov ds, offset right_motor_codes
	mov si, right_motor_step
	mov al, byte ptr[ds+si]
	or al, buf
	mov al, buf
	nop ; out port x, al
	inc si
	cmp si, 03h
	je step_up_zero_si_rt
	mov right_motor_step, si
	jmp test_continue
step_up_zero_si_rt:
	mov si, 00h
	mov right_motor_step, si
	jmp test_continue
test_continue: ; проверяет, прошёл ли нужное кол-во шагов
	dec step_count
	cmp step_count, 00h
	je stop_motor
	jmp start_timer
stop_motor:
	and flags, 0FFh
	jmp fon
start_timer:
	and flags, 0FEh
	; инициализируем таймер. Чем больше задержка - тем медленнее едет пылесос
	nop ; 2
	nop ; 3
	nop ; 4
	nop ; 5
	nop ; 6
	jmp fon
timer_int:
	or flags, 01h
	jmp fon
rotate_rt_sw: ; плавный поворот вправо
	mov buf, 00h
	mov ds, offset left_motor_codes
	mov si, left_motor_step
	mov al, byte ptr[ds+si]
	or al, buf
	mov al, buf
	nop ; out port
	inc si
	cmp si, 03h
	je rotate_rt_sw_zero_si_lt
	mov left_motor_step, si
	jmp test_continue
rotate_rt_sw_zero_si_lt:
	mov si, 00h
	mov left_motor_step, si
	jmp test_continue
rotate_lt_sw: ; плавный поворот влево
	mov buf, 00h
	mov ds, offset right_motor_codes
	mov si, right_motor_step
	mov al, byte ptr[ds+si]
	or al, buf
	mov al, buf
	nop ; out port
	inc si
	cmp si, 03h
	je rotate_lt_sw_zero_si_rt
	mov right_motor_step, si
	jmp test_continue
rotate_lt_sw_zero_si_rt:
	mov si, 00h
	mov right_motor_step, si
	jmp test_continue
rotate_rt_ip: ; поворот вправо на месте
	mov buf, 00h
	mov ds, offset left_motor_codes
	mov si, left_motor_step
	mov al, byte ptr[ds+si]
	or al, buf
	inc si
	cmp si, 03h
	je rotate_rt_ip_zero_si_lt
	jmp con_rotate_rt_ip_rt
rotate_rt_ip_zero_si_lt:
	mov si, 00h
	mov left_motor_step, si
	jmp con_rotate_rt_ip_rt
con_rotate_rt_ip_rt:
	mov ds, offset right_motor_codes
	mov si, right_motor_step
	mov al, byte ptr[ds+si]
	or al, buf
	mov al, buf
	nop ; out port x, al
	dec si
	cmp si, 00h
	je rotate_rt_ip_zero_si_rt
	mov right_motor_step, si
	jmp test_continue
rotate_rt_ip_zero_si_rt:
	mov si, 03h
	mov right_motor_step, si
	jmp test_continue
rotate_lt_ip: ; поворот влево на месте
mov buf, 00h
	mov ds, offset left_motor_codes
	mov si, left_motor_step
	mov al, byte ptr[ds+si]
	or al, buf
	dec si
	cmp si, 00h
	je rotate_lt_ip_zero_si_lt
	jmp con_rotate_lt_ip_rt
rotate_rt_ip_zero_si_lt:
	mov si, 03h
	mov left_motor_step, si
	jmp con_rotate_rt_ip_rt
con_rotate_lt_ip_rt:
	mov ds, offset right_motor_codes
	mov si, right_motor_step
	mov al, byte ptr[ds+si]
	or al, buf
	mov al, buf
	nop ; out port x, al
	inc si
	cmp si, 03h
	je rotate_lt_ip_zero_si_rt
	mov right_motor_step, si
	jmp test_continue
rotate_lt_ip_zero_si_rt:
	mov si, 00h
	mov right_motor_step, si
	jmp test_continue
step_down: ; ехать назад
	mov buf, 00h
	mov ds, offset left_motor_codes
	mov si, left_motor_step
	mov al, byte ptr[ds+si]
	or al, buf
	dec si
	cmp si, 00h
	je step_down_zero_si_lt
	jmp con_step_down_rt
step_down_zero_si_lt:
	mov si, 03h
	mov left_motor_step, si
	jmp con_step_down_rt
con_step_down_rt:
	mov ds, offset right_motor_codes
	mov si, right_motor_step
	mov al, byte ptr[ds+si]
	or al, buf
	mov al, buf
	nop ; out port x, al
	dec si
	cmp si, 00h
	je step_down_zero_si_rt
	mov right_motor_step, si
	jmp test_continue
step_down_zero_si_rt:
	mov si, 03h
	mov right_motor_step, si
	jmp test_continue
Code ends
end Start