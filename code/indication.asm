radix 16
.model tiny
.stack 1000
data segment 

	flag db 00
	num db 0,1,2,3
	tab db 03Fh, 006h, 05Bh, 04Fh, 066h, 06Dh, 07Dh, 007h, 07Fh, 06Fh 
	scan db 001h 

data ends
code segment
assume cs:Code, ds:Data, es:data

                           ;init segment registers	
strt:
	mov ax,data
	mov ds,ax
        mov es,ax
	                   ;setting a counter of symbol position
	mov si, 00h
	mov al, 00h
	nop ;out port, al
	                   ;begin timer initialize
	mov al, 01h
	nop ;out port, al
	mov al, 02h
	nop ;out port, al  
	mov al, 03h       
	nop ;out port, al  ;end timer initialize
	mov al, 01h
	nop ;out port, al
	mov al, 02h
	nop ;out port, al
	mov al, 03h        ;interrupt controller enable
	nop ;out port, al
	nop; sti ; enabled global interrupts

back:
	test flag, 01      ;get flag status
	jnz ind
	jmp back

ind:
	and flag, 0FEh     ;reset flag
	mov al, 00h        ;dump indicator
	nop ;out port, al  ;output into scan port of indicator
	mov bx, offset num ;get numbers
	mov al, [bx+si]
	mov bx, offset tab ;get tabs
	xlat               ;recoding current position
	nop ;out port, al 
	mov al, scan       ;counter of current position
	nop ;out port, al 
	rol scan, 01h      ;shift left cycle
	inc si 		   ;increment
	and si, 03h 	   ;mod4 for 5-position indicator's block
	jmp back

ind_int:
	or flag, 01h 	   ;set flag on
	mov al, 01h
	nop ;out port, al
	mov al, 02h
	nop ;out port, al
	mov al, 03h
	nop ;out port, al  ;end timer initialize
	jmp back
	;iret

code ends
end strt