;
; GSLA Player Merlin32 linker file
;
	dsk play.sys16
	typ $b3				; filetype
	aux $db07			; auxtype
	;xpl					; Add ExpressLoad
	
*----------------------------------------------	
	asm shell.s
	ds 0	   	; padding
	knd #$1100  ; kind
	ali None	; alignment
	lna play	; load name
	sna start	; segment name
*----------------------------------------------	
	asm play.s
    ds 0		; padding
	knd #$1100  ; kind
	ali None    ; alignment
	lna play    ; load name
	sna start   ; segment name, doesn't work to try and merge segments here
*----------------------------------------------	

