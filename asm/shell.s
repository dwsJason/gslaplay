         lst   off
*
*     DreamWorld Software Generic Shell
*
*     v .02    10/8/90
*

*   OA-F  "damnmenu" to find menu definitions
*

         rel
         dsk   shell.l
         use   drm.macs


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

         PushLong #0      ;result space
         lda   ProgID     ;user ID
         pha
         pea   #$0        ;reference by handle
         PushLong #startref
         ldx   #$1801     ;startuptools
         jsl   $e10000
         PullLong stref
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

         JSR    DoAbout    ; Show this to the user before we get going...
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
         pea   #%1100000000011100 ; Attributes
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
         str   '(C)2020 DreamWorld Software'

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
         bcs   :trouble

         lda   p:open
         sta   p:read
         sta   p:setmark
         _SetMark p:setmark
         bcs   :trouble

         _Read p:read
         bcs   :trouble

         _Close p:close
         bcs   :trouble
         brl   changestats

:temp    dw    0

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
         adrl  $8000      ;number requested  32k
         adrl  0          ;number transfered

p:setmark
         dw    0          ;ref number
p:where  adrl  $1c000     ;about 108k into file


DoSave
         rts

changestats
         lda   iobuff
         sta   :modify+1
         lda   iobuff+1
         sta   :modify+2

         ldx   #0
:modify  ldal  $030000,x
         cmp   text+1
         beq   :cont
         cpx   #$ffff
         beq   :nope
         inx
         bra   :modify
:nope
         rts
:cont
         lda   text
         and   #$00ff
                          ; dec
         sta   :temp

         stx   offset
         txy
         iny
         ldx   #0
:lup     lda   [iobuff],y
         inx
         iny
         cmp   text+1,x
         bne   :goback
         cpx   :temp
         cpx   #6
         bcc   :lup
         bra   :dodialog

:temp    dw    0

:goback
         ldx   offset
         inx
         brl   :modify

:dodialog
         PushLong #0
         PushLong #:getinfo
         Tool  $3215      ;new dialog
         PullLong :pointer

         brl   :initialize

]lp
         pea   #0
         PushLong #0
         Tool  $0f15      ;modal dialog

         pla
         beq   ]lp
         cmp   #1
         beq   :okay
         cmp   #2
         beq   :cancel
         cmp   #7
         bcs   ]lp
         brl   :toggle

:cancel
         PushLong :pointer
         Tool  $0c15      ;close dialog
         rts

:initnew
         ldx   #0
         sep   #$20
         lda   #' '
]dup     sta   newname,x
         inx
         cpx   #textlength+1
         bcc   ]dup
         rep   #$30
         rts

:okay

         jsr   :initnew   ;initialize newname area

         PushLong :pointer
         pea   #8         ;name of user
         PushLong #newname ;place to put the name
         Tool  $1f15      ;GetIText

         PushLong :pointer
         pea   #9         ;new serial number
         PushLong #newser ;place to put the name
         Tool  $1f15      ;GetIText

         jsr   :putser
         bcs   ]lp

         lda   vernum
         asl
         tax
         jsr   (:encode,x)

         PushLong :pointer
         Tool  $0c15      ;close dialog

         jmp   DoSave     ;it's over

:putser                   ;low word
         sep   #$20
         ldy   #0
:lloop
         lda   rserial,y  ;location of serial string
         ldx   #0
:bloop   cmp   :ascii,x
         beq   :okay2
         inx
         cpx   #17
         bcc   :bloop
         rep   #$30
         sec
         rts

         sep   #$20
:okay2
         txa
         sta   :teeem,y
         iny
         cpy   #8
         bcc   :lloop

         lda   :teeem
         asl
         asl
         asl
         asl
         ora   :teeem+1
         sta   :value+3

         lda   :teeem+2
         asl
         asl
         asl
         asl
         ora   :teeem+3
         sta   :value+2

         lda   :teeem+4
         asl
         asl
         asl
         asl
         ora   :teeem+5
         sta   :value+1

         lda   :teeem+6
         asl
         asl
         asl
         asl
         ora   :teeem+7
         sta   :value

         rep   #$30

         ldy   serloc
         lda   :value
         sta   [iobuff],y
         lda   :value+2
         iny
         iny
         sta   [iobuff],y

         clc
         rts


:teeem   dw    0,0,0,0    ;8 bit mode
         asc   'shit'
:value   dw    0,0


:encode
         da    :sc1
         da    :sc2
         da    :sc3
         da    :sc4

:sc1
         sep   #$20
         ldx   #0
         ldy   texloc
:her0
         lda   newname+1,x
         sec
         sbc   maskval
         sta   [iobuff],y
         inx
         dey
         cpx   #textlength+1
         bcc   :her0
         rep   #$30
         rts

:sc2
         sep   #$20
         ldx   #0
         ldy   texloc
:her1
         lda   newname+1,x
         sec
         sbc   maskval
         sta   [iobuff],y
         inx
         dey
         cpx   #textlength+1
         bcc   :her1
         rep   #$30
         rts

:sc3
:sc4
         rts

:toggle
         sec
         sbc   #3         ;make value 0-3
         sta   vernum     ;version number
         asl
         asl
         asl
         tax
         phx
         lda   :val,x
         pha
         PushLong :pointer
         pea   #3         ;item number
         Tool  $2f15      ;setditemvalue

         plx
         phx
         lda   :val+2,x
         pha
         PushLong :pointer
         pea   #4         ;item number
         Tool  $2f15      ;setditemvalue

         plx
         phx
         lda   :val+4,x
         pha
         PushLong :pointer
         pea   #5         ;item number
         Tool  $2f15      ;setditemvalue

         plx
         lda   :val+6,x
         pha
         PushLong :pointer
         pea   #6         ;item number
         Tool  $2f15      ;setditemvalue

         lda   vernum
         asl
         tax
         lda   :maskval,x
         sta   maskval
         and   #$f000
         xba
         lsr
         lsr
         lsr
         lsr
         tax
         sep   #$20
         lda   :ascii,x
         sta   maskstr+2
         rep   #$30
         lda   maskval
         and   #$0f00
         xba
         tax
         sep   #$20
         lda   :ascii,x
         sta   maskstr+3
         rep   #$30
         lda   maskval
         and   #$00f0
         lsr
         lsr
         lsr
         lsr
         tax
         sep   #$20
         lda   :ascii,x
         sta   maskstr+4
         rep   #$30
         lda   maskval
         and   #$000f
         tax
         sep   #$20
         lda   :ascii,x
         sta   maskstr+5
         rep   #$30

         PushLong :pointer
         pea   #10        ;mask value
         PushLong #maskstr
         Tool  $2015      ;setItext
         ldy   serloc

         lda   [iobuff],y
         sta   serval
         iny
         iny
         lda   [iobuff],y
         sta   serval+2

         and   #$f000
         xba
         lsr
         lsr
         lsr
         lsr
         tax
         sep   #$20
         lda   :ascii,x
         sta   serstr+2
         rep   #$30
         lda   serval+2
         and   #$0f00
         xba
         tax
         sep   #$20
         lda   :ascii,x
         sta   serstr+3
         rep   #$30
         lda   serval+2
         and   #$00f0
         lsr
         lsr
         lsr
         lsr
         tax
         sep   #$20
         lda   :ascii,x
         sta   serstr+4
         rep   #$30
         lda   serval+2
         and   #$000f
         tax
         sep   #$20
         lda   :ascii,x
         sta   serstr+5
         rep   #$30

         lda   serval
         and   #$f000
         xba
         lsr
         lsr
         lsr
         lsr
         tax
         sep   #$20
         lda   :ascii,x
         sta   serstr+6
         rep   #$30
         lda   serval
         and   #$0f00
         xba
         tax
         sep   #$20
         lda   :ascii,x
         sta   serstr+7
         rep   #$30
         lda   serval
         and   #$00f0
         lsr
         lsr
         lsr
         lsr
         tax
         sep   #$20
         lda   :ascii,x
         sta   serstr+8
         rep   #$30
         lda   serval
         and   #$000f
         tax
         sep   #$20
         lda   :ascii,x
         sta   serstr+9
         rep   #$30

         PushLong :pointer
         pea   #9         ;serial number
         PushLong #serstr
         Tool  $2015      ;setItext

         lda   vernum
         asl
         tax
         lda   offset
         clc
         adc   :wheret,x
         sta   texloc

         jsr   (:decode,x)

         PushLong :pointer
         pea   #7         ;serial number
         PushLong #oldname
         Tool  $2015      ;setItext

         brl   ]lp


:decode
         da    :scheme1
         da    :scheme2
         da    :scheme3
         da    :scheme4

:scheme1
         sep   #$20
         ldx   #0
         ldy   texloc
:here
         lda   [iobuff],y
         clc
         adc   maskval
         sta   oldname+1,x
         inx
         dey
         cpx   #textlength+1
         bcc   :here
         rep   #$30
         rts

:scheme2
         sep   #$20
         ldx   #0
         ldy   texloc
:here2
         lda   [iobuff],y
         clc
         adc   maskval
         sta   oldname+1,x
         inx
         dey
         cpx   #textlength+1
         bcc   :here2
         rep   #$30
         rts

:scheme3
         rts
:scheme4
         rts


:ascii   asc   '0123456789abcdef'

:val
         dw    1,0,0,0
         dw    0,1,0,0
         dw    0,0,1,0
         dw    0,0,0,1

:maskval dw    $30,$28,0,0 ;different encoding values for each ver number

:wheret  dw    $128,$128,0,0 ;offset to text from end of 'Written by'

:initialize

         lda   text
         and   #$00ff
         clc
         adc   offset
         sta   offset
         sta   serloc

         lda   #3         ;version 1
         brl   :toggle

:pointer adrl  0

:getinfo
         dw    27,82,185,558 ;position
         dw    -1         ;visible
         adrl  0          ;reserved
         adrl  :item1
         adrl  :item2
         adrl  :item3
         adrl  :item4
         adrl  :item5
         adrl  :item6
         adrl  :item7
         adrl  :item10
         adrl  :item9
         adrl  :item8
         adrl  :item11
         adrl  :item12
         adrl  :item13
         adrl  :item14
         adrl  :item15
         adrl  0          ;terminator

:item1   DA    1
         dw    137,340,150,430 ;rect
         DA    ButtonItem
         adrl  :Item1Txt
         da    0
         da    1
         adrl  0
:Item1Txt str  'Save'

:item2   DA    2
         dw    137,210,150,300 ;rect
         DA    ButtonItem
         ADRL  :Item2Txt
         DA    0
         DA    0
         ADRL  0
:Item2Txt STR  'Cancel'

:item3   dw    3
         dw    23,52,32,160 ;rect
         dw    CheckItem
         adrl  :i3text
:i3val   dw    0,0,0,0
:i3text  str   ' Version 1'

:item4   dw    4
         dw    34,52,43,162 ;rect
         dw    CheckItem
         adrl  :i5text
:i5val   dw    0,0,0,0
:i5text  str   ' Version 2'

:item5   dw    5
         dw    23,210,32,320 ;rect
         dw    CheckItem
         adrl  :i4text
:i4val   dw    0,0,0,0
:i4text  str   ' Version 3'

:item6   DA    6
         dw    34,210,43,322 ;rect
         dw    CheckItem
         adrl  :i6text
:i6val   dw    0,0,0,0
:i6text  str   ' Version 4'

:item7   dw    7
         dw    59,125,72,503 ;rect
         dw    StatTextItem+ItemDisable
         adrl  oldname
         dw    0,0
         adrl  0

:item8   dw    8
         dw    90,50,103,426 ;rect
         DA    EditLine+ItemDisable
         adrl  defname
         dw    textlength
         dw    0
         adrl  0

:item9   dw    9
         dw    119,52,131,150 ;rect
         DA    EditLine+ItemDisable
         adrl  serstr
         dw    9
         dw    0
         adrl  0

:item10  dw    10
         dw    119,200,131,264 ;rect
         DA    EditLine+ItemDisable
         adrl  maskstr
         dw    5
         dw    0
         adrl  0

:item11  dw    11
         dw    8,180,17,287 ;rect
         dw    StatTextItem+ItemDisable
         adrl  :item11txt
         dw    0,0
         adrl  0
:item11txt
         dfb   11
         asc   'DreamStamp'
         dfb   $AA

:item12  dw    12
         dw    48,50,57,125 ;rect
         dw    StatTextItem+ItemDisable
         adrl  :item12txt
         dw    0,0
         adrl  0
:item12txt
         str   'Current:'

:item13  dw    13
         dw    79,50,88,91 ;rect
         dw    StatTextItem+ItemDisable
         adrl  :item13txt
         dw    0,0
         adrl  0
:item13txt
         str   'New:'

:item14  dw    14
         dw    108,50,117,161 ;rect
         dw    StatTextItem+ItemDisable
         adrl  :item14txt
         dw    0,0
         adrl  0
:item14txt
         str   'Serial Number:'

:item15  dw    15
         dw    108,200,117,275 ;rect
         dw    StatTextItem+ItemDisable
         adrl  :item15txt
         dw    0,0
         adrl  0
:item15txt
         str   'Mask:'

vernum   dw    0          ;version number 0 - 3

DoUndo
DoCut
DoCopy
DoPaste
DoClear
DoClose
         RTS

oldname                   ;name in the program
         dfb   textlength
         ds    textlength
         dw    0

defname
         str   'Joe Hack and The Mercenary'

newser   dfb   0
         dfb   0
rserial  ds    8


newname  ds    textlength+1
         dw    0

maskloc  dw    0          ;offset to mask
maskval  dw    0
maskstr  str   '$0000'

offset   dw    0

serloc   dw    0          ;offset to serial number
serstr   str   '$00000000'
serval   adrl  0

texloc   dw    0          ;offset to beginning of text

text
         str   "Written By:  Jason Andersen and Steven Chiang"
