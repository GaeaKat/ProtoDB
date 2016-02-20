(*
   Cmd-@Bootme v2.2
   Author: Chris Brine [Moose/Van]
   Version 2.2 [Akari] Cleaned up to 80 column format and added new Proto
                       directives.
   Based on the original @bootme by Squirrelly.
 *)
$author Moose
$version 2.2
$include $lib/strings
$def atell me @ swap ansi_notify
VAR pme
 
: ParseIdle[ int:INTdescr int:BOLlong? -- str:time' ]
   VAR STRtag
   INTdescr @ descrdbref ok? if
      INTdescr @ descrdbref "INTERACTIVE" flag? if
         "*"
      else
         " "
      then
   else
      " "
   then
   STRtag !
   INTdescr @ descridle
   BEGIN
      dup 86400 / 365 > if
         pop BOLlong? @ if "365+ days" else "365d" then break
      then
      dup 86400 / if
         dup 86400 / intostr BOLlong? @ if swap 86400 / 1 = if " day"
         else " days" then else swap pop "d" then strcat break
      then
      dup 3600 / if
         dup 3600 / intostr BOLlong? @ if swap 3600 / 1 = if " hour"
         else " hours" then else swap pop "h" then strcat break
      then
      dup 60 / if
         dup 60 / intostr BOLlong? @ if swap 60 / 1 = if " minute"
         else " minutes" then else swap pop "m" then strcat break
         60 / intostr "m" strcat break
      then
      dup intostr BOLlong? @ if swap 1 = if " second"
      else " seconds" then else swap pop "s" then strcat break
   REPEAT
   "\[" swap strcat BOLlong? @ not if 5 STRright then "^YELLOW^" "\[" subst
   BOLlong? @ not if STRtag @ strcat then
;
 
: ParseTime[ int:INTdescr -- str:time' ]
   VAR STRtag
   INTdescr @ descrdbref ok? if
      INTdescr @ descrdbref "IDLE" flag? if
         "I"
      else
         " "
      then
   else
      " "
   then
   STRtag !
   INTdescr @ descrtime
   dup 86400 / 365 > if
      pop "  ^PURPLE^365d  " exit
   then
   dup 86400 / if
      86400 / intostr "d" strcat "\[" swap strcat 9 STRright
      "^PURPLE^" "\[" subst STRtag @ strcat exit
   else
      "^PURPLE^"
   then
   swap 86400 %
   dup 3600 / if
      dup 3600 / intostr dup strlen 1 = if "0" swap strcat then ":" strcat
   else
      "00:"
   then
   rot swap strcat swap 3600 %
   dup 60 / if
      dup 60 / intostr dup strlen 1 = if "0" swap strcat then ":" strcat
   else
      "00:"
   then
   rot swap strcat swap 60 % intostr dup strlen 1 = if "0" swap strcat then
   strcat STRtag @ strcat
;
 
: bm-boot ( arr:ARRboot -- )
   VAR idx
   FOREACH
      swap pop
         "^PURPLE^--> ^RED^Booted %n connection on descriptor #%d (^YELLOW^idle %s^RED^)."
         over 1 ParseIdle "%s" subst over intostr "%d" subst over descrcon
         dup if condbref name else pop "*Nobody*" then "^^" "^" subst "%n" subst
         me @ swap ansi_notify 0 sleep descrboot idx ++
   REPEAT
   me @ "^CINFO^Done.  %n connections dropped." idx @ intostr "%n" subst
   ansi_notify
;
 
: bm-old[ int:BOLopp? -- ]
   pme @ descr_array dup pme @ BOLopp? @ if lastdescr else firstdescr then
   array_findval 0 array_getitem array_delitem bm-boot
;
 
: bm-idle[ int:BOLopp? -- ]
   pme @ descr_array dup pme @ BOLopp? @
   if descrmostidle else descrleastidle then
   array_findval 0 array_getitem array_delitem bm-boot
;
 
: bm-list ( -- )
   me @ "^CINFO^Connections:" ansi_notify
   me @ "  ^RED^DS#   ^PURPLE^On-line  ^YELLOW^Idle  ^BLUE^Host" ansi_notify
   pme @ descr_array 3 array_sort
   FOREACH
      swap pop dup intostr "\[" swap strcat 6 STRright "^RED^" "\[" subst
      "  " strcat
      over ParseTime strcat " " strcat over 0 ParseIdle strcat " " strcat
      swap descrhost "^^" "^" subst "^BLUE^" swap strcat strcat me @ swap
      ansi_notify
   REPEAT
   me @ "^CINFO^Done." ansi_notify
;
 
: bm-help ( -- )
   me @ "^CINFO^Cmd-@BootMe v2.2 - by Moose/Van" ansi_notify
   me @ "^CNOTE^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" ansi_notify
   "^CNOTE^@BootMe [#Idle]    ^NORMAL^Drops all but the least idle descriptor. Default."
   atell
   "^CNOTE^@BootMe #unidle    ^NORMAL^Drops all but the most idle descriptor."
   atell
   "^CNOTE^@BootMe #old       ^NORMAL^Drops all but your most recent connection."
   atell
   "^CNOTE^@BootMe #new       ^NORMAL^Drops all but your oldest connection."
   atell
   "^CNOTE^@BootMe #list      ^NORMAL^List all of your connections." atell
   "^CNOTE^@BootMe <n>        ^NORMAL^Boots a descriptor number of yours from #list."
   atell
   me @ "WIZARD" flag? if
      "^CNOTE^@BootMe #u=<user>  ^NORMAL^Set the active user to <user>. ^CNOTE^(Wiz Only)"
      atell
   then
   me @ "^CINFO^Done." ansi_notify
;
 
: cmd-main ( str:Args -- )
   strip dup "#help" stringcmp not if
      pop bm-help exit
   then
   me @ pme !
   dup "#u=" instr 1 = me @ "WIZARD" flag? and if
      3 strcut swap pop strip " " split swap pmatch dup ok? not if
         swap pop #-1 dbcmp if
            "^CINFO^I cannot find that player."
         else
            "^CINFO^I don't know which player you mean!"
         then
         me @ swap ansi_notify exit
      then
      "^GREEN^Player set as: ^FOREST^" 3 pick name "^^" "^" subst strcat atell
      pme !
   then
   dup "#list" stringcmp not if
      pop bm-list exit
   then
   dup "#old" stringcmp not if
      pop 0 bm-old exit
   then
   dup "#new" stringcmp not if
      pop 1 bm-old exit
   then
   dup "#all" stringcmp not if
      pop me @ descr_array bm-boot exit
   then
   dup "#idle" stringcmp not over not or if
      pop 0 bm-idle exit
   then
   dup "#unidle" stringcmp not if
      pop 1 bm-idle exit
   then
   dup number? if
      { }list swap " " explode_array
      FOREACH
         swap pop atoi me @ "WIZARD" flag? if #-1 else pme @ then descr_array
         over array_findval array_count not if
            "^CFAIL Invalid descriptor (#%d)." rot intostr "%d" subst atell
         else
            swap array_appenditem
         then
      REPEAT
      bm-boot exit
   then
   pop bm-help
;
