*
* New Animated File Format
*
*
* xxx_xxxx_xxxx_xxx is the number of bytes 1-16384 to follow (0 == 1 byte)
*
* %0xxx_xxxx_xxxx_xxx1 - Copy Bytes - straight copy bytes
* %1xxx_xxxx_xxxx_xxx1 - Skip Bytes - skip bytes / move the cursor
* %1xxx_xxxx_xxxx_xxx0 - Dictionary Copy Bytes from  frame buffer to frame buffer
* 
* %0000_0000_0000_0000- Source Skip -> Source pointer skips to next bank of data
* %0000_0000_0000_0010- End of Frame - end of frame
* %0000_0000_0000_0110- End of Animation / End of File / no more frames
*
* other remaining codes, are reserved for future expansion
*
*
* 16 bit opcode
*
* %1 xxx xxxx xxxx xxx 0
* %0 xxx xxxx xxxx xxx 0
*
* X = SRC
* Y = DST
*
* Source Data Stream Copy
* Dictionary Copy
* xx xxxx xxxx xxxx // up to 16384 length of copy (0 is a copy length of 1 byte, so it's length-1)
*
* Copy this code to your direct page, please make sure it's aligned to a page
* The buffer is hardcoded to be at $012000, to take advantage of fast reads
*
* pass in a pointer to the start of the compressed stream
* ldx #offset in source bank
* lda #source bank
*  we assume all next bank data is sequential from this first bank, but it
* wouldn't be hard to work from a list of banks, to make the player more
* friendly

*---  this code sits at location $0 in the DP register
*---  DP may be anywhere in bank 0, but make sure it's PAGE aligned
*---- for performance reasons

;        rel
        dsk play.l

;
; Defines, for the list of allocated memory banks
;
banks_count equ $80
banks_data  equ $82


player  ent
        org $0
        mx %00
        phb
        sep #$20                 ; preserve X
        sta <srcbank+2           ; self modify the code for mvn
        sta <read_opcode+3       ; data stream reader
        sta <dictionary_offset+3 ; opcode stream reader
        rep #$31
        ldy #$2000               ; it's a new frame, cursor starts at beginning of SHR

        stz <banks_index
*        stz <frames

        bra     read_opcode
*frames dw 0

extended_command
        beq :source_skip_next_bank
        lsr
        lsr
        bcs :end_of_file

*        ; end of frame
        ldy #$2000
*        ; check elapsed ticks (need at least 1)
*        ; For now just inline vsync (preferable to check the number of
*        ; if jiffy that have elapsed, because if the animation uses more than
*        ; roughly 10% of the screen we don't want to sync here
*        lda <frames
*        inc
*        sta <frames
*        cmp #2
*        bge :end_of_file
*
        bra read_opcode

:end_of_file
        plb    ; restore bank
        rtl

:source_skip_next_bank
*
* If data is sequential in memory
*
*
*        ; source data, new bank
*        inc <read_opcode+3        ; 6
*        inc <dictionary_offset+3  ; 6
*        inc <srcbank+2            ; 6
*

*
* Our Banks of Data are in the order
* they were allocated, so this is a little
* more complicated
*
        sep #$20        ; preserve Y, by leaving X long
        ldx <banks_index
        inx
        stx <banks_index
        lda <banks_data,x
        sta <srcbank+2           ; self modify the code for mvn
        sta <read_opcode+3       ; data stream reader
        sta <dictionary_offset+3 ; opcode stream reader
        rep #$31

        ; start of new bank
        ldx #0

:not_new_bank
       
        ; currently reserved
        bra read_opcode

stream_copy
        inx
        inx
        lsr
        bcc extended_command
srcbank
        mvn $01,$01
read_opcode
        ldal $000000,x
        bpl stream_copy
        inx
        inx
dictionary_copy
        and #$7FFF
        lsr
        bcs cursor_skip

        sta <temp

        stx <dictionary_offset+1
dictionary_offset
        ldal $000000
        tax

        lda <temp
        ; dictionary copy
        mvn $01,$01

        ldx dictionary_offset+1
        inx
        inx

        bra read_opcode

cursor_skip
        sty <skip_amount+1
skip_amount
        adc #$0000
        tay
        bra read_opcode

banks_index dw 0
temp    dw 0

