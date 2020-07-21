         lst   off
*
*     DreamWorld Software Generic Shell
*
*     v .02    10/8/90
*
*  Updated for Merlin 32  07/11/2020
*

*   OA-F  "damnmenu" to find menu definitions
*

         rel
         dsk   shell.l
         use   drm.macs

         ext   player


;
; Defines, for the list of allocated memory banks
;
banks_count equ $80
banks_data  equ $82



vidmode  =     $8080      ;Video mode for QD II (320) ($8000)
                          ;640 mode  ($8080)

*   startup tools, begin program

tool     equ   $e10000

iobuff   equ   $80

textlength equ 38         ;max length of text

startup  ent
         phk
         plb              ;make the program bank = data bank

SetRes   sep   $30        ; 8-bit mode
         lda   #$5C       ; jml
         stal  $3F8       ; ctrl-y vector
         rep   $30        ; 16-bit mode
         lda   #Resume
         stal  $3F9       ; $3f9,3fa
         lda   #^Resume   ; bank byte
         stal  $3FB       ; $3fb,3fc

         _TLStartUp       ;Gotta start this baby

         ~MMStartUp       ;start the Memory manager
                          ; CheckToolError

         pla              ;retrieve our program ID
         sta   ProgID

;-------------------------------------------------------------------------------
;
; Initialize List of memory Banks
;
         stz <banks_count



         PushLong #0      ;result space
         lda   ProgID     ;user ID
         pha
         pea   #$0        ;reference by handle
         PushLong #startref
         ldx   #$1801     ;startuptools
         jsl   $e10000
         PullLong stref

;-------------------------------------------------------------------------------
         PushLong  #0                   ; Compact Memory
         PushLong  #$8fffff
         PushWord  ProgID
         PushWord  #%11000000_00000000
         PushLong  #0
         ldx   #$0902
         jsl   tool       ; NewHandle
         ldx   #$1002
         jsl   tool       ; DisposeHandle
         ldx   #$1F02
         jsl   tool       ; CompactMem
;-------------------------------------------------------------------------------
; I'm pretty sure one of the tools is allocating this out from under me
;
;         PushLong  #0                   ; Ask Shadowing Screen ($8000 bytes from $01/2000)
;         PushLong  #$8000
;         PushWord  ProgID
;         PushWord  #%11000000_00000011
;         PushLong  #$012000
;         ldx   #$0902
;         jsl   tool       ; NewHandle
;         pla
;         pla
;         bcc :NoError
;
;         lda #0
;         pha
;         pha
;         pha
;         pha
;         PushLong #:shadow_error
;         Tool $590e ; AlertWindow
;         pla
;         brl ShutDown
;
;;-------------------------------------------------------------------------------
;
;:shadow_error asc '40\GSLA Player requires the Super Hires shadow'
;        asc ' memory to function properly.\^#5',00
;
;*-----------------------------
:NoError
         jmp   DoMenu

:trouble
         pha
         PushLong #0
         ldx   #$1503
         jsl   $e10000
         rtl

backhandle dw  0,0

*
*  Draw the desktop
*

DoMenu
         ldx   #$0001
         lda   #$0000
         jsr   getmem
         bcc   :ov3
         brl   ShutDown
:ov3                      ;handle in a and x
         jsl   dereference

         sta   p:rbuf     ; set up Disk I/O buffer
         sta   iobuff
         txa
         sta   p:rbuf+2
         sta   iobuff+2

         ; A contains bank address to add
         jsr   AddBank


* PushLong #0
* PushPtr ExampleM
* _NewMenu
* PushWord #0
* _InsertMenu

         PushLong #0
         PushPtr EditM
         _NewMenu
         PushWord #0
         _InsertMenu

         PushLong #0
         PushPtr FileM
         _NewMenu
         PushWord #0
         _InsertMenu

         PushLong #0
         PushPtr AppleM
         _NewMenu
         PushWord #0
         _InsertMenu

         PushLong #1
         _FixAppleMenu

         PHA
         _FixMenuBar
         PLA

         _DrawMenuBar

         _InitCursor

         ;JSR    DoAbout    ; Show this to the user before we get going...
         JSR    DoOpen   

*  Command Processor
*
*  Use TaskMaster to handle any and all events.
*  We only check for events within the menus
*  currently. The 'wInSpecial' ensures that we
*  get events 250-255.
*

GetEvent
         pha
         PushWord #$FFFF
         PushPtr TaskRecord
         _TaskMaster
         pla

         cmp   #25        ;wInSpecial
         beq   :DoEvent
         cmp   #17        ;wInMenuBar
         bne   GetEvent

:DoEvent
         sec
         lda   TaskData
         sbc   #250       ;Reduce to 0 and
         asl              ;  double to find
         tax              ;  index into table.
         jsr   (Cmds,X)

         PushWord #0
         PushWord TaskData+2
         _HiliteMenu

         bra   GetEvent

*  damnmenu
*
*  Menu definitions
*

*
*NOTE Currently setup for Merlin32
*for Merlin 16, adjust the ]mnum, and ]inum definitions down by 1
*due to how merlin 16 will scope / evaluate them inside the macro
*

]mnum    =     1          ; "1" - 1 = 0
AppleM   Menu  '@';'X'
]inum    =     256
         Item  'About GSLA...';Divide;'';Kybd;'?/'

FileM    Menu  ' File '
                          ; Item 'New';Kybd;'Nn'
         Item  'Open...';Divide;'';Kybd;'Oo'
]OpenItem =     ]inum
]inum    =     255
         Item  'Close';Divide;'' ; (#255)
]inum    =     ]OpenItem
         Item  'Quit';Kybd;'Qq'
]QuitItem =     ]inum

EditM    Menu  ' Edit '
]inum    =     250
         Item  'Undo';Divide;'';Kybd;'Zz' ; (#250)
         Item  'Cut';Kybd;'Xx' ; (#251)
         Item  'Copy';Kybd;'Cc' ; (#252)
         Item  'Paste';Divide;'';Kybd;'Vv' ; (#253)
         Item  'Clear'    ; (#254)

*ExampleM Menu ' Example '
*]inum = QuitItem
* Item 'Bold';Disable;''
* Item 'Disable';Disable;''
* Item 'Italic';Disable;''
* Item 'Underline';Disable;''
* Item 'Divide';Disable;''
* Item 'Check';Disable;''
* Item 'Blank';Disable;''

         asc   '.'        ;End of menu.


TaskRecord
tType    ds    2          ;Event code
tMessage ds    4          ;Type of Event
tWhen    ds    4          ;Time since startup
tWhere   ds    4          ;Mouse Location
tMod     ds    2          ;Event modifier
TaskData ds    4          ;Taskmaster Data
TaskMask adrl  $00001FFF  ;Taskmaster Handle All

Fileinfo                  ;place for file info
Fopen    dw    0          ;good info?
Ftype    dw    0          ;file type
Atype    adrl  0          ;aux type
Nref     dw    0          ;Name reference type
Name     adrl  name       ;Where is the name? (pointer)
Pref     dw    0          ;Path reference type
Path     adrl  path       ;Where is the path? (pointer)

name     ds    256        ;space for filename
path     ds    512        ;space for pathname
fullp    ds    768

ProgID   dw    0


*  ShutDown Routine

ShutDown ent              ;a global label so other modules can die here.:)
         pea   #$0        ;ref is pointer
         PushLong stref   ;Reference to startstop record
         ldx   #$1901
         jsl   $e10000    ;Shut Down Tools

MMout    ~MMShutDown ProgID

TLout    _TLShutDown

:1       _QUIT QuitParms
         bra   :1         ;keep quitting if GS/OS is busy

QuitParms adrl $0
         ds    2

getmem   ent
         sta   :sizelo+1
         stx   :sizehi+1
         lda   #0
         pha
         pha              ; Space for Results
:sizehi  pea   #$0000
:sizelo  pea   #$ffff     ; Size in Bytes of Block 64k
         lda   ProgID
         pha
gm_atr   pea   #%1100000000011100 ; Attributes
         lda   #0
         pha
         pha              ; Ptr to where Block is to begin
         ldx   #$0902
         jsl   tool       ; NewHandle
         pla
         plx
         rts

dereference ent
         pei   0
         pei   2
         sta   0
         stx   2
         lda   [0]
         pha
         ldy   #2
         lda   [0],y
         tax
         ply
         pla
         sta   2
         pla
         sta   0
         tya
         rtl


*   Resume routine for Control-Y vector...

Resume   phk
         plb
         clc
         xce              ; set native mode
         rep   $30        ; 16-bit mode
         jmp   ShutDown   ; Let's get outta here!!

startref                  ;tool startup record
         dw    $0000      ;flags
         dw    vidmode    ;videoMode
         ds    6          ;resFileID & dPageHandle are set by the StartUpTools call
         dw    19         ;# of tools
                          ;tool number, version number
         dw    1,$0300    ;Tool Locator
         dw    2,$0300    ;Memory Manager
         dw    3,$0300    ;Miscellaneous Tools
         dw    4,$0301    ;QuickDraw II
         dw    5,$0302    ;Desk Manager
         dw    6,$0300    ;Event Manager
         dw    11,$0200   ;Integer Math
         dw    14,$0301   ;Window Manager
         dw    15,$0301   ;Menu Manager
         dw    16,$0301   ;Control Manager
         dw    18,$0301   ;QuickDraw II Aux.
         dw    19,$0300   ;Print Manager
         dw    20,$0301   ;LineEdit Tools
         dw    21,$0301   ;Dialog Manager
         dw    22,$0300   ;Scrap Manager
         dw    23,$0301   ;Standard File Tools
         dw    27,$0301   ;Font Manager
         dw    28,$0301   ;List Manager
         dw    34,$0101   ;TextEdit Manager

stref    adrl  0          ;reference to the startstop record

*
*  Look up table for event processor
*

Cmds
         da    DoUndo     ; These menu items are set as
         da    DoCut      ;  required by Apple for
         da    DoCopy     ;  NDA compatibility.
         da    DoPaste
         da    DoClear
         da    DoClose

         da    DoAbout    ;This starts OUR items. (#256)

         da    DoOpen
         da    ShutDown

*
*  Main code goes here...
*


DoAbout
         ~NoteAlert #AboutTemplate;#0
         pla
         rts

AboutTemplate
         dw    62,128,151,512 ;position
         dw    1
         dfb   128,128,128,128
         adrl  :Item1
         adrl  :Item2
         adrl  :Item3
         adrl  0

:Item3   da    3
         dw    33,76,43,291 ;rect
         da    StatTextItem+ItemDisable
         adrl  :Item3Txt
         da    0
         da    0
         adrl  0
:Item3Txt
         str   '(C) 2020 DreamWorld Software'

:Item2   dw    2
         dw    13,122,22,251 ;rect
         da    StatTextItem+ItemDisable
         adrl  :Item2Txt
         da    0
         da    0
         adrl  0
:Item2Txt str  'GSLA Player v1.0'

:Item1   da    1
         dw    66,272,78,350 ;rect
         da    ButtonItem
         adrl  :Item1Txt
         da    0
         da    1
         adrl  0
:Item1Txt str  ' Ok '

DoOpen
         pea   #30        ;x of upper left corner
         pea   #40        ;y of upper left corner
         pea   #0         ;type of reference
         PushLong #:message ;location of pascal string
         PushLong #0      ;Filter... none for now
         PushLong #:filter ;Pointer to type list record
         PushLong #Fileinfo ;Pointer to reply record

         ldx   #$0e17     ;SF Get File 2
         jsl   $e10000
         bcc   :cont
         brl   :trouble
:cont
         lda   Fopen      ;good?
         bne   :keepitup

:bye     rts

:keepitup
         lda   path+2     ;length of pathname
         sta   fullp

         ldx   #0
:lup
         lda   path+4,x   ;make this class 1 string a prodos string
         sta   fullp+1,x
         inx
         inx
         cpx   path+2
         bcc   :lup

         _Open p:open
         bcc   :read_filesize
         brl   :trouble
:read_filesize
         lda   p:open
         sta   p:read
         sta   p:get_eof

         _GET_EOF p:get_eof
         bcc   :eof_seems_good
:err_close
        jsr FreeBanks
         _Close p:close
         bra    :trouble

:eof_seems_good

*
*  Allocate memory for loading the animation
*  Will do an allocation per 64k required, since
*  this type of animation requires, the file be bank aligned
*  so will load in 64KB chunks
*
*
* I've decided that using Tools to spawn a dialog with a loading meter
* is actually more work (mentally), than just stomping on the frame buffer
*
		 
; need to allocate each bank separate, to guarantee
; the alignment for the player
; perhaps loop through, and store a list of allocated banks
; starting at $80 in the DP, so DP,x addressing can get at
; them in the player		 
	 
        ; while banks_count < required_banks
    
        lda p:eof+2
        inc
        sta :required_banks
                    
]loop
        lda <banks_count
        cmp :required_banks
        bcs :we_have_memory

        ; Ask for 64K
        lda #$0000
        ldx #$0001
        jsr getmem
        bcs :mem_failed

        jsl dereference

        txa
        jsr AddBank

        bra ]loop


:mem_failed
        jsr FreeBanks

        ; Pop up an Alert

        bra :err_close

:we_have_memory
              
        ; Read in the File

        ; Size 64k at a time
        stz p:rsize
        lda #$0001
        sta p:rsize+2

        ldx #0
        stx p:rbuf+0
]read_loop
        lda <banks_data,x
        and #$00FF
        sta p:rbuf+2

        phx
        _Read p:read
        plx
       
        bcs   :err_close

        inx
        cpx :required_banks
        bcc ]read_loop

:close_exit
         _Close p:close
         bcs   :trouble
         brl   PlayAnimation

:required_banks
:temp
         dw    0

:trouble
         pha
         PushLong #0
         ldx   #$1503
         jsl   $e10000
         rtl

:message str   'Open GS Lzb Anim:'

:filter  dw    0          ; (count 0/no filter), set to 1 for only show s16 files

*         dw    1          ; (count 1) Show only s16 files
*         dw    0,$b3,0,0  ;flags, filetype, auxtype

p:close
p:open   dw    1          ;ref number
         adrl  fullp      ;pathname
         adrl  0          ;io buffer, doesn't reallymatter

p:write
p:read   dw    0
p:rbuf   adrl  0
p:rsize  adrl  $10000     ;number requested  64k
         adrl  0          ;number transfered

p:get_eof dw 0     ; reference number
p:eof     adrl 0   ; end of file

p:setmark
         dw    0          ;ref number
p:where  adrl  $1c000     ;about 108k into file



PlayAnimation mx %00
		
		; ha, this has to parse the headers
		; before it can play the animation

		; copy player to the Direct Page
		
	lda #127  ; player is less than 128 bytes
	ldx #player
	phd
	ply
	sty :play+1
	sty :init+1
		
	mvn ^player,$00	

	phk
	plb
		
	; Pointer to the INITial Frame Data
        lda <banks_data
        and #$00FF
        sta $FE

	ldx #28    ; Header of file + Header of INIT Frame

        ; X = Low
        ; A = High
		
:init	jsl $000000 ; for the first frame

		; load up a pointer to data
:loop
	stz  $FC
		
	ldy  #24
	lda [$FC],y
	clc
	adc #28  ; 20 byte header + 8 bytes skip into the ANIM Block
        tax
		 
        lda $FE

	; play the animation
        ; X = Low
        ; A = High
			
:play   jsl $000000

	bra :loop

        rts


DoUndo
DoCut
DoCopy
DoPaste
DoClear
DoClose
         RTS

text
         str   "Written By:  Jason Andersen and Steven Chiang"

********************************************************************************
*
* Append a Bank to the list
*
AddBank mx %00
        ldx <banks_count
        sta <banks_data,x
        inx
        stx <banks_count
        rts

********************************************************************************
*
* Free Memory, and Clear Bank List
*
FreeBanks mx %00

]loop
        ldx <banks_count
        dex
        bmi :done
        stx <banks_count

        ldy #0
        phy     ; space for result
        phy

        lda <banks_data,x
        and #$00FF
        phy     ; memory address high
        phy     ; memory address low

        ldx #$1A02 ; FindHandle
        jsl tool

        ldx #$1002 ; DisposeHandle
        jsl tool

        bra ]loop

:done
        rts

        rts
