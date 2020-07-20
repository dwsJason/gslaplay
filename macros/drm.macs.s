_ADBStartUp MAC 
         Tool  $209       
         <<<   
_ADBShutDown MAC 
         Tool  $309       
         <<<   
~CtlStartUp MAC 
         PxW   ]1;]2      
         Tool  $210       
         <<<   
_CtlShutDown MAC 
         Tool  $310       
         <<<   
_DeskStartUp MAC 
         Tool  $205       
         <<<   
_DeskShutDown MAC 
         Tool  $305       
         <<<   
_FixAppleMenu MAC 
         Tool  $1E05      
         <<<   
~DialogStartUp MAC 
         PHW   ]1         
         Tool  $215       
         <<<   
_DialogShutDown MAC 
         Tool  $315       
         <<<   
_DialogStatus MAC 
         Tool  $615       
         <<<   
~StopAlert MAC 
         PHA   
         PxL   ]1;]2      
         Tool  $1815      
         <<<   
~NoteAlert MAC 
         PHA   
         PxL   ]1;]2      
         Tool  $1915      
         <<<   
~EMStartUp MAC 
         PxW   ]1;]2;]3;]4 
         PxW   ]5;]6;]7   
         Tool  $206       
         <<<   
_EMShutDown MAC 
         Tool  $306       
         <<<   
~FMStartUp MAC 
         PxW   ]1;]2      
         Tool  $21B       
         <<<   
_FMShutDown MAC 
         Tool  $31B       
         <<<   
_IMStartUp MAC 
         Tool  $20B       
         <<<   
_IMShutDown MAC 
         Tool  $30B       
         <<<   
~LEStartUp MAC 
         PxW   ]1;]2      
         Tool  $214       
         <<<   
_LEShutDown MAC 
         Tool  $314       
         <<<   
_TLStartUp MAC 
         Tool  $201       
         <<<   
_TLShutDown MAC 
         Tool  $301       
         <<<   
~TLVersion MAC 
         PHA   
         Tool  $401       
         <<<   
~LoadTools MAC 
         PHL   ]1         
         Tool  $E01       
         <<<   
~TLMountVolume MAC 
         PHA   
         PxW   ]1;]2      
         PxL   ]3;]4;]5;]6 
         Tool  $1101      
         <<<   
_TLTextMountVol MAC 
         Tool  $1201      
         <<<   
~MMStartUp MAC 
         PHA   
         Tool  $202       
         <<<   
~MMShutDown MAC 
         PHW   ]1         
         Tool  $302       
         <<<   
~MMVersion MAC 
         PHA   
         Tool  $402       
         <<<   
~NewHandle MAC 
         P2SL  ]1         
         PxW   ]2;]3      
         PHL   ]4         
         Tool  $902       
         <<<   
~DisposeHandle MAC 
         PHL   ]1         
         Tool  $1002      
         <<<   
~GetHandleSize MAC 
         P2SL  ]1         
         Tool  $1802      
         <<<   
~MenuStartUp MAC 
         PxW   ]1;]2      
         Tool  $20F       
         <<<   
_MenuShutDown MAC 
         Tool  $30F       
         <<<   
_InsertMenu MAC 
         Tool  $D0F       
         <<<   
_FixMenuBar MAC 
         Tool  $130F      
         <<<   
_DrawMenuBar MAC 
         Tool  $2A0F      
         <<<   
_HiliteMenu MAC 
         Tool  $2C0F      
         <<<   
_NewMenu MAC   
         Tool  $2D0F      
         <<<   
_MTStartUp MAC 
         Tool  $203       
         <<<   
_MTShutDown MAC 
         Tool  $303       
         <<<   
~MTVersion MAC 
         PHA   
         Tool  $403       
         <<<   
~QDStartUp MAC 
         PxW   ]1;]2;]3;]4 
         Tool  $204       
         <<<   
_QDShutDown MAC 
         Tool  $304       
         <<<   
~QDVersion MAC 
         PHA   
         Tool  $404       
         <<<   
~MoveTo  MAC   
         PxW   ]1;]2      
         Tool  $3A04      
         <<<   
_ShowCursor MAC 
         Tool  $9104      
         <<<   
~DrawString MAC 
         PHL   ]1         
         Tool  $A504      
         <<<   
_InitCursor MAC 
         Tool  $CA04      
         <<<   
_QDAuxStartUp MAC 
         Tool  $212       
         <<<   
_QDAuxShutDown MAC 
         Tool  $312       
         <<<   
_ScrapStartUp MAC 
         Tool  $216       
         <<<   
_ScrapShutDown MAC 
         Tool  $316       
         <<<   
~WindStartUp MAC 
         PHW   ]1         
         Tool  $20E       
         <<<   
_WindShutDown MAC 
         Tool  $30E       
         <<<   
_TaskMaster MAC 
         Tool  $1D0E      
         <<<   
~RefreshDesktop MAC 
         PHL   ]1         
         Tool  $390E      
         <<<   
_GET_BOOT_VOL MAC 
         DOS16 $28;]1     
         <<<   
_QUIT    MAC   
         DOS16 $29;]1     
         <<<   
_Close   mac
         DOS16 $14;]1
         eom

_Open    mac
         DOS16 $10;]1
         eom

_Read    mac
         DOS16 $12;]1
         eom

_Write   mac
         DOS16 $13;]1
         eom

_SetMark mac
         DOS16 $16;]1
         eom

_GET_EOF	MAC
	DOS16	$19;]1
	<<<

DOS16    MAC   
         JSL   $E100A8    
         DA    ]1         
         ADRL  ]2         
         <<<   
PxW      MAC   
         DO    ]0/1       
         PHW   ]1         
         DO    ]0/2       
         PHW   ]2         
         DO    ]0/3       
         PHW   ]3         
         DO    ]0/4       
         PHW   ]4         
         FIN   
         FIN   
         FIN   
         FIN   
         <<<   
PxL      MAC   
         DO    ]0/1       
         PHL   ]1         
         DO    ]0/2       
         PHL   ]2         
         DO    ]0/3       
         PHL   ]3         
         DO    ]0/4       
         PHL   ]4         
         FIN   
         FIN   
         FIN   
         FIN   
         <<<   
P2SL     MAC   
         PHA   
         PHA   
         IF    #=]1       
         PEA   ^]1        
         ELSE  
         PHW   ]1+2       
         FIN   
         PHW   ]1         
         <<<   
PHL      MAC   
         IF    #=]1       
         PEA   ^]1        
         ELSE  
         PHW   ]1+2       
         FIN   
         PHW   ]1         
         <<<   
PHW      MAC   
         IF    #=]1       
         PEA   ]1         
         ELSE  
         IF    MX/2       
         LDA   ]1+1       
         PHA   
         FIN   
         LDA   ]1         
         PHA   
         FIN   
         <<<   
PushPtr  MAC   
         PEA   ^]1        
         PEA   ]1         
         <<<   
PushLong MAC   
         IF    #=]1       
         PushWord #^]1    
         ELSE  
         PushWord ]1+2    
         FIN   
         PushWord ]1      
         <<<   
PushWord MAC   
         IF    #=]1       
         PEA   ]1         
         ELSE  
         IF    MX/2       
         LDA   ]1+1       
         PHA   
         FIN   
         LDA   ]1         
         PHA   
         FIN   
         <<<   
PullLong MAC   
         DO    ]0         
         PullWord ]1      
         PullWord ]1+2    
         ELSE  
         PullWord 
         PullWord 
         FIN   
         <<<   
PullWord MAC   
         PLA   
         DO    ]0         
         STA   ]1         
         FIN   
         IF    MX/2       
         PLA   
         DO    ]0         
         STA   ]1+1       
         FIN   
         FIN   
         <<<   
Tool     MAC   
         LDX   #]1        
         JSL   $E10000    
         <<<   
Item     MAC   
         ASC   '--'       
         ASC   ]1         
         ASC   '\H'       
         DA    ]inum      
         DO    ]0/2
         DO    ]2-Check-1/$FFFF
         DA    ]2         
         ELSE  
         DO    ]2-Blank-1/$FFFF
         DA    ]2         
         ELSE  
         DB    ]2         
         ASC   ]3         
         FIN   
         FIN   
         FIN   
         DO    ]0/4       
         DO    ]4-Check-1/$FFFF
         DA    ]4         
         ELSE  
         DO    ]4-Blank-1/$FFFF
         DA    ]4         
         ELSE  
         DB    ]4         
         ASC   ]5         
         FIN   
         FIN   
         FIN   
         DO    ]0/6       
         DO    ]6-Check-1/$FFFF
         DA    ]6         
         ELSE  
         DO    ]6-Blank-1/$FFFF
         DA    ]6         
         ELSE  
         DB    ]6         
         ASC   ]7         
         FIN   
         FIN   
         FIN   
         DB    $00        
]inum    =     ]inum+1    
         <<<   
Menu     MAC   
         ASC   '>>'       
         ASC   ]1         
         ASC   '\H'       
         DA    ]mnum      
         DO    ]0>1       
         ASC   ]2         
         FIN   
         DB    0          
]mnum    =     ]mnum+1    
         <<<   

*  Menu Contents and Equates

Bold     =     'B'        ; bold menu item
Disable  =     'D'        ; disabled menu item
Italic   =     'I'        ; italic menu item
Underline =    'U'        ; underlined menu item
Divide   =     'V'        ; menu dividing line
ColorHi  =     'X'        ; color hilite menu item
Kybd     =     '*'        ; keyboard menu equivalent
Check    =     $1243      ; menu item with checkmark
Blank    =     $2043      ; menu item with blank

*  Dialog Equates

CheckItem =    11
RadioItem =    12
ScrollBarItem = 13
PicItem  =     19
UserItem =     20
ButtonItem EQU $0A
EditLine equ   $11
StatText EQU   $0F
StatTextItem = $f
ItemDisable EQU $8000

*  macros

test     mac
         sep   #$30
         ldal  $e1c034
         inc
         stal  $e1c034
         rep   #$30
         eom
