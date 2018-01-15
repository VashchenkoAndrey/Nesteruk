.radix 16
.model tiny
.stack 1000
dat segment
	flags db 00 		  ; flags register
	BS1 db 00   		  ; bufscan
	BS2 db 00   		  ; bufСPS
	CPS db 1    		  ; counter position scanning
	RS db 0DDh  		  ; horizontal scanning register
	CV db 00    		  ; counter position vertical
	RKC db 00   		  ; vertical scanning register
	RKK db 00   		  ; key code
	RC db 00    		  ; command gegister
	BD db 0,0,0,0,0,0,0,0 ; data buffer
	OBD dw 00 			  ; data buffer offset
	AB dw 00			  ; buffer address
dat ends
Code segment
	Assume cs : Code, ds : dat, es : dat
Start: 	
		mov ax, dat
		mov ds, ax
		mov es, ax
back: 	
		test flags, 01	  ; test keyboard interrupt flag
		jnz PROCI
f1:	
		test flags, 02 	  ; test rattling flag
		jnz PROCK
f2: 
		test flags, 10    ; test user flag
		jnz INTOPT
		jmp back
INTK: 	
		or flags, 01  	  ; key is pressed
		mov al, RS        ; save horizontal scan register
		mov BS1, al
		mov al, CPS       ; save counter position scanning
		mov BS2, al
		nop; mov al, xxh  ; denied INTK
		; out port X
		jmp back
INTTIME: 
		or flags, 02      ; rattling timer interrupt
		jmp back
INTOPT: 
		nop; mov al, zzh  ; granted INTK
		; out port X
		jmp back
PROCI:	
		mov al, 01h       ; begin timer initialize
		nop ;out port, al
		mov al, 02h
		nop ;out port, al  
		mov al, 03h       
		nop ;out port, al ; end timer initialize
		and flags, 0FEh   ; key is released
		jmp f1
PROCK:		
		mov al, BS1
		nop; out port X, BS1
		nop; in al, PA
		mov al, BS2
		mov CPS, al
		mov RKC, al 	  ; restore vertical scan register
		mov CV, 00h       ; reset counter position vertical 	
SRV:  	
		;test RKC, 01h
		;jz NXT
		inc CV
		shr RKC,1         ; shift right on 1 bit
		jc SRV
NXT:		
		shl BS2, 2   	  ; shift left on 2 bits
		mov al, BS2
		mov RKK, al 	  ; push horisontal code into key code register
		or al, CV
		mov RKK,al		  ; push horisontal code into key code register
		cmp al, 09h 	  ; test command code
		jg M2 
		mov bx, offset BD
		mov AB, bx
		add bx, OBD
		mov byte ptr [bx],al
		inc OBD           ; increment data buffer offset
		cmp OBD, 08h   	  ; if (offset == 8) 
		jnz M
		mov OBD, 00h	  ; offset = 0
M:		
		and flags, 0FDh
		or flags, 08      ; data is here
		jmp FINAL         
M2: 		
		mov al,RKK
		mov RC, al
		and flags, 0EFh   ; reset rettling flag
		or flags, 04      ; command is here
FINAL:	
		mov al, 01h       ; begin timer initialize
		nop ;out port, al
		mov al, 02h
		nop ;out port, al  
		mov al, 03h       
		nop ;out port, al ; end timer initialize; start user timer
		jmp back
Code ends
end Start