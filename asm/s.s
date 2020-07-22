         lkv   $02
         ver   $02
         nol

         do    pass
         else
         cmd   err.usr
         fin

         asm   shell

         lnk   shell.l
         save  dwshell
         do    pass
         cmd   purge.mem
         cmd   =dwshell
         fin

*  eof
