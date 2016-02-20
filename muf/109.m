(*
   Cmd-@ProgError v1.0
   Author: Chris Brine [Moose/Van]
   This program is useful for tracking program errors on a MUCK. When programs
   abort, information about the last error is stored in a .debug/ directory
   on them. This program scans the various programs and reports any new
   abort errors since the last scan, so that the MUF wiz or whoever is
   responsible for the programs can try to debug and fix them.
 *)
 
$author Moose
$version 1.0
$include $Lib/Objects
$include $Lib/Time
 
: Show-Error[ ref:ref -- ]
   me @ "^CINFO^Last Crash Info (%p^CINFO^):"
   ref @ ANSIUNPARSE "%p" subst ansi_notify
   me @ "^CSUCC^|  Error Count: ^CINFO^"
   ref @ "/.Debug/ERRcount" getpropval intostr strcat ansi_notify
   me @ "^CSUCC^|   Last Crash: ^CINFO^"
   ref @ "/.Debug/LastCrash" getpropval
   "%A %B %e, %Y %I:%M:%S %p %Z" me @ rot PLYRfmt strcat ansi_notify
   me @ "^CSUCC^|   Last Error: ^CINFO^"
   ref @ "/.Debug/LastERR" getpropstr 1 escape_ansi strcat ansi_notify
   me @ "^CSUCC^| Last Command: ^CINFO^"
   ref @ "/.Debug/LastCMD" getpropstr 1 escape_ansi strcat ansi_notify
   me @ "^CSUCC^|    Last Args: ^CINFO^"
   ref @ "/.Debug/LastARG" getpropstr 1 escape_ansi strcat ansi_notify
   me @ "^CSUCC^|  Last Player: ^CINFO^"
   ref @ "/.Debug/LastPlayer" getpropval
   dbref dup ok? if ANSIUNPARSE else pop "^NORMAL^*Nothing*" then
   strcat ansi_notify
;
 
: Find-New-Errors[ ref:REFowner -- ]
   VAR ref
   #-1 ref !
   BEGIN
      ref @ REFowner @ "" "F" FINDNEXT dup ref ! Ok? WHILE
      me @ owner ref @ controls if
         ref @ "/.Debug/LastCrash" getpropval
         ref @ "/@Debug/Plyrs/" me @ dtos strcat getpropval = not if
            ref @ Show-Error
            ref @ "/.Debug/LastCrash" getpropval
            ref @ "/@Debug/Plyrs/" me @ dtos strcat rot setprop
         then
      then
   REPEAT
;
 
: Main[ str:Args -- ]
   Args @ strip dup not if
      pop "me"
   then
   dup "#all" stringcmp not if
      pop #-1
   else
      dup match dup Exit? if
         getlink
      then
      dup Program? not if
         pop pmatch
      else
         swap pop
      then
      dup ok? not if
         #-1 dbcmp if
            "^CINFO^I cannot find that player."
         else
            "^CINFO^I don't know which player you mean."
         then
         me @ swap ansi_notify EXIT
      then
      me @ owner over controls not if
         pop me @ "^CFAIL^" "noperm_mesg" sysparm
         1 escape_ansi strcat ansi_notify EXIT
      then
      dup Program? if
         dup "/.Debug/LastCrash" getpropval
         over "/@Debug/Plyrs/" me @ dtos strcat rot setprop
         Show-Error
         me @ "^CNOTE^[!] ^CINFO^Done." ansi_notify
         EXIT
      then
      owner
   then
   me @ "^CNOTE^[!] ^CINFO^Listing programs." ansi_notify
   Find-New-Errors
   me @ "^CNOTE^[!] ^CINFO^Done." ansi_notify
;
