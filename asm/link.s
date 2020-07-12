;
; fun2gs Merlin32 linker file
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
;	asm dbgfnt.s
;	ds 0		; padding
;	knd #$1100  ; kind
;	ali None    ; alignment
;	lna fun2gs    ; load name
;	sna start  ; segment name, doesn't work to try and merge segments here
*----------------------------------------------	
;	asm lz4.s
;	ds 0		; padding
;	knd #$1100  ; kind
;	ali None	; alignment
;	lna fun2gs  ; load name
;	sna lz4code ; JSL only access
*----------------------------------------------	
;	asm blit.s
;	ds 0		; padding
;	knd #$1100  ; kind
;	ali None    ; alignment
;	lna	fun2gs  ; load name
;	sna blitcode ; segment name, JSL only access
*----------------------------------------------	
;	asm  penguin.s
;	ds 0 		; padding
;	knd #$1100  ; kind
;	ali None	; alignment
;	lna fun2gs	; load name
;	sna penguin ; segment name
*---------------------------------------------
;	asm sprdata0.s
;	ds 0		; padding
;	knd #$1100  ; kind
;	ali None	; alignment
;	lna fun2gs  ; load name
;	sna sprdata0 ; segment name
*----------------------------------------------
;	asm gng.tiles.s
;	ds 0		; padding
;	knd #$1100	; kind
;	ali None	; alignment
;	lna fun2gs	; load name
;	sna gngtiles	
*----------------------------------------------	
;	asm cat.s
;	ds 0		; padding
;	knd #$1100  ; kind
;	ali None	; alignment
;	lna fun2gs  ;
;	sna cat
*----------------------------------------------	
* Combined Stack and Direct Page
; $$JGA this works, but giving up all this space in the executable is stupid
; x65 assembler makes this much easier
;	asm stack.s
;	ds 0       ; padding, note changing the padding doesn't work
;	knd $0012  ; kind DP/Stack
;	ali None   ; alignment, note this doesn't work
;	lna fun2gs ; load name
;	sna stack  ; segment name	

