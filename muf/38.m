(*
   Cmd-Whisper v1.2.3
   Author: Chris Brine [Moose/Van]
   Version 1.1 by Akari - Just minor modifications:
       Fixed #who bug.
       Made it so that a space won't be added in whispers if
         there's already a space.
       Commented out the room blocks for now.
       Added a note to #help about p #ignore settings working for whisper.
   Version 1.2 by Moose - A few more changes:
       Removed the room blocks completly.
       Made it so that your own player name is replaced with 'you'.
       You can no longer whisper nor mumble to sleeping players.
       Whispers and mumbles to yourself are now blocked to lessen the spam.
   Version 1.2.1 by Moose
       Changed the 'whisp' blank argument message show as ANSI, and
         mention about whisper #help.
   Version 1.2.2 by Moose
       Odd. Commenting out array_reverse for mumble makes the words
         go forward.  With how explode_array works it should of worked
         before. Oh well.
       Made it so that you could whisper and mumble to yourself again.
         I heard that is a sign of going insane though... Nothing new there.
   Version 1.2.3 by Akasri
       Just cleaned up the formatting to be 80 column friendly.
 *)
 
$author Moose
$version 1.23
$include $lib/standard
 
$def BLOCKCHANCE MUMBLE-blockchance
 
: Puppet?[ ref:REF -- int:BOLpup? ]
   ref @ thing? ref @ "ZOMBIE" flag?
   ref @ "_Listen" propdir? or ref @ "~Listen" propdir? or
   ref @ "@Listen" propdir? or ref @ "_Listen" getprop  or
   ref @ "~Listen" getprop  or ref @ "@Listen" getprop  or
   ref @ "@/NotifyFwd" getprop or and
;
 
: plyrmatch[ str:STRmatch -- ref:REFmatch ]
   STRmatch @ "me" stringcmp not if
      me @ exit
   then
   STRmatch @ pmatch dup ok? if
      dup location loc @ dbcmp if
         exit
      then
   then
   pop STRmatch @ match
;
 
: Do-Match[ str:STRplyrs int:BOLwhisp? -- arr:ARRplyrs ]
   VAR STRprop1 VAR STRprop2
   { }list VAR! ARRplyrs
   { }list VAR! ARRignore
   { }list VAR! ARRhaven
   { }list VAR! ARRsanct
   { }list VAR! ARRaway
   { }list VAR! ARRnothere
   { }list VAR! ARRnotplayer
   { }list VAR! ARRnomatch
   { }list VAR! ARRasleep
   { }list VAR! ARRyou
   me @ "WIZARD" flag? not if
      STRplyrs @ "" "*" subst STRplyrs !
   then
   BOLwhisp? @ if
      "_Whisp/LastWhisperer" STRprop1 !
      "_Whisp/LastWhispered" STRprop2 !
   else
      "_Mumble/LastMumbler" STRprop1 !
      "_Mumble/LastMumbled" STRprop2 !
   then
   " " STRplyrs @ strcat " " strcat STRplyrs !
   STRplyrs @ " " me @ STRprop1 @ getpropstr strip strcat " " strcat
   swap over " #R " subst swap " #r " subst STRplyrs !
   STRplyrs @ " " me @ STRprop2 @ getpropstr strip strcat " " strcat
   swap over " #W " subst swap " #w " subst strip STRplyrs !
   STRplyrs @ " " explode_array
   FOREACH
      swap pop strip dup not if
         pop CONTINUE
      then
      dup plyrmatch dup ok? not if
         pop ARRnomatch @ array_appenditem ARRnomatch ! CONTINUE
      then
      swap pop dup Player? over Puppet? or not if
         name ARRnotplayer @ array_appenditem ARRnotplayer ! CONTINUE
      then
      dup location loc @ dbcmp me @ "WIZARD" flag? or not if
         name ARRnothere @ array_appenditem ARRnothere ! CONTINUE
      then
      ARRplyrs @ over array_findval array_count if
         pop CONTINUE
      then
      dup owner awake? not if
         name ARRasleep @ array_appenditem ARRasleep ! CONTINUE
      then
(      dup me @ dbcmp if
         name ARRyou @ array_appenditem ARRyou ! CONTINUE
      then )
      dup "_Page/@Priority" array_get_reflist me @ array_findval array_count
      not if
         dup "_Page/@Ignore" array_get_reflist me @ array_findval array_count if
            name ARRignore @ array_appenditem ARRignore ! CONTINUE
         then
         dup "HAVEN" flag? if
            name ARRhaven @ array_appenditem ARRhaven ! CONTINUE
         then
         dup "_Page/Away" getpropstr "yes" stringcmp not if
            name ARRaway @ array_appenditem ARRaway ! CONTINUE
         then
      then
      ARRplyrs @ array_appenditem ARRplyrs !
   REPEAT
   ARRnomatch @ array_count if
      me @ "^CFAIL^%s cannot be found." ARRnomatch @ ", "
      array_join "^^" "^" subst "%s" subst ansi_notify
   then
   ARRnotplayer @ array_count if
      me @ "^CFAIL^%s is not a player nor puppet." ARRnotplayer @ ", "
      array_join "^^" "^" subst "%s" subst ansi_notify
   then
   ARRnothere @ array_count if
      me @ "^CFAIL^%s is not here." ARRnothere @ ", "
      array_join "^^" "^" subst "%s" subst ansi_notify
   then
   ARRignore @ array_count if
      me @ "^CFAIL^%s is ignoring you." ARRignore @ ", "
      array_join "^^" "^" subst "%s" subst ansi_notify
   then
   ARRhaven @ array_count if
      me @ "^CFAIL^%s is haven." ARRhaven @ ", "
      array_join "^^" "^" subst "%s" subst ansi_notify
   then
   ARRsanct @ array_count if
      me @ "^CFAIL^%s is in sanctuary." ARRsanct @ ", "
      array_join "^^" "^" subst "%s" subst ansi_notify
   then
   ARRaway @ array_count if
      me @ "^CFAIL^%s is away." ARRaway @ ", "
      array_join "^^" "^" subst "%s" subst ansi_notify
   then
   ARRasleep @ array_count if
      me @ "^CFAIL^%s is asleep." ARRasleep @ ", "
      array_join "^^" "^" subst "%s" subst ansi_notify
   then
   ARRyou @ array_count if
      me @ "^CFAIL^You cannot whisper to yourself!" ansi_notify
   then
   ARRplyrs @
;
 
: do-join[ arr:ARRplyrs ref:REF -- str:STRplyrs ]
   "" VAR! STRplyrs
   ARRplyrs @
   FOREACH
      swap pop dup ref @ dbcmp if
         pop CONTINUE
      then
      name STRplyrs @ dup if
         " " strcat
      then
      swap strcat STRplyrs !
   REPEAT
   STRplyrs @
;
 
: do_send_notify[ str:Msg arr:ARRplyrs -- ]
   ARRplyrs @
   FOREACH
      swap pop Msg @ "you" "\[" 4 pick name strcat "\[" strcat subst
      "" "\[" subst ansi_notify
   REPEAT
;
 
: ansi_notify_exclude[ ref:REFloc int:ignorenum str:Msg -- ]
   REFloc @ Msg @ "you" "\[" 4 pick name strcat "\[" strcat subst
   "" "\[" subst ansi_notify
   REFloc @ contents
   BEGIN
      dup ok? WHILE
      dup Msg @ "you" "\[" 4 pick name strcat "\[" strcat subst ""
      "\[" subst ansi_notify
      NEXT
   REPEAT
   pop
;
 
: Send-Message[ arr:ARRplyrs ref:REFloc ref:REFplyr str:Message str:oMessage str:myMessage int:BOLwhisp? -- ]
   VAR STRprop1 VAR STRprop2
   REFplyr @ myMessage @ "you" "\[" REFplyr @ name strcat "\[" strcat subst ""
   "\[" subst ansi_notify
   Message @ ARRplyrs @ do_send_notify
   oMessage @ if
      REFloc @ 0 oMessage @ ansi_notify_exclude
   then
   BACKGROUND
   BOLwhisp? @ if
      "_Whisp/LastWhisperer" STRprop1 !
      "_Whisp/LastWhispered" STRprop2 !
   else
      "_Mumble/LastMumbler" STRprop1 !
      "_Mumble/LastMumbled" STRprop2 !
   then
   REFplyr @ STRprop2 @ ARRplyrs @ #-1 do-join setprop
   ARRplyrs @
   FOREACH
      swap pop STRprop1 @ REFplyr @ ARRplyrs @ array_appenditem
      3 pick do-join setprop
   REPEAT
;
 
: do-list[ arr:ARRplyrs -- str:STRplyrs ]
   "" VAR! STRplyrs
      VAR  idx
      VAR  cidx
   ARRplyrs @ array_count 1 - cidx !
   ARRplyrs @
   FOREACH
      swap idx ! name "\[" swap over strcat strcat
      STRplyrs @ dup if
         idx @ cidx @ = if
            ", and "
         else
            ", "
         then
         strcat
      then
      swap strcat STRplyrs !
   REPEAT
   STRplyrs @
;
 
: Do-Whisper[ arr:ARRplyrs str:Msg -- ]
   VAR MyMsg VAR oMsg VAR STRplyrs
   ARRplyrs @ do-list "^^" "^" subst STRplyrs !
   "^WHISPER/POSE^You whisper, ^WHISPER/QUOTE^\"^WHISPER/SAY^%m^WHISPER/QUOTE^\" ^WHISPER/POSE^to "
   Msg @ "^^" "^"
   subst "%m" subst STRplyrs @ strcat "." strcat myMsg !
   "^WHISPER/POSE^" me @ name "^^" "^" subst strcat
   " whispers, ^WHISPER/QUOTE^\"^WHISPER/SAY^%m^WHISPER/QUOTE^\" ^WHISPER/POSE^to "
   Msg @ "^^" "^" subst "%m" subst strcat STRplyrs @ strcat "." strcat Msg !
   "" oMsg !
   ARRplyrs @ loc @ me @ Msg @ oMsg @ myMsg @ 1 Send-Message
;
 
: Do-Mumble[ arr:ARRplyrs str:Msg -- ]
   VAR myMsg VAR oMsg VAR STRplyrs VAR theMsg
   ARRplyrs @ do-list "^^" "^" subst STRplyrs !
   "^MUMBLE/POSE^You mumble, ^MUMBLE/QUOTE^\"^MUMBLE/SAY^%m^MUMBLE/QUOTE^\" ^MUMBLE/POSE^to "
   Msg @ "^^" "^" subst "%m" subst STRplyrs @ strcat "." strcat myMsg !
   "^MUMBLE/POSE^" me @ name "^^" "^" subst strcat
   " mumbles, ^MUMBLE/QUOTE^\"^MUMBLE/SAY^%m^MUMBLE/QUOTE^\" ^MUMBLE/POSE^to "
   Msg @ "^^" "^" subst "%m" subst strcat STRplyrs @ strcat "." strcat theMsg !
   Msg @ " " explode_array ( array_reverse ) "" Msg !
   FOREACH
      swap pop random 100 % BLOCKCHANCE < if
         pop "..."
      then
      Msg @ dup if
         " " strcat
      then
      swap strcat Msg !
   REPEAT
   "^MUMBLE/POSE^" me @ name "^^" "^" subst strcat
   " mumbles, ^MUMBLE/QUOTE^\"^MUMBLE/SAY^%m^MUMBLE/QUOTE^\" ^MUMBLE/POSE^to "
   Msg @ "^^" "^" subst "%m" subst strcat STRplyrs @ strcat "." strcat oMsg !
   ARRplyrs @ loc @ me @ theMsg @ oMsg @ myMsg @ 0 Send-Message
;
 
: Whisp-Help ( -- )
   me @ "^CINFO^Cmd-Whisper v1.2.3 - by Moose/Van" ansi_notify
   me @ "^CNOTE^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" ansi_notify
   me @ "^WHITE^Whisper to a list of players:                    ^NORMAL^Whisper <player-list>=<message>" ansi_notify
   me @ "^WHITE^Reply to those who last whispered to you:        ^NORMAL^Whisper #R=<message>" ansi_notify
   me @ "^WHITE^Resend a message to those you last whispered to: ^NORMAL^Whisper #W=<message>" ansi_notify
   me @ "^WHITE^List the last whisperer/whispered info:          ^NORMAL^Whisper #WHO" ansi_notify
   me @ " " notify
   me @ "^WHITE^Whisper will not notify to players set HAVEN or players that are page #ignoring you." ansi_notify
   me @ "^CINFO^NOTE: The 'mumble' command has the exact same parameters." ansi_notify
   me @ "^CINFO^Done." ansi_notify
;
 
: cmd-main[ str:Args -- ]
   Args @ strip dup Args ! dup not if
      command @ "w" instring if "whisper" else "mumble" then
      me @ "^CYAN^Syntax: ^AQUA^%c <player-list>=<message>" 3 pick "%c" subst
      ansi_notify
      me @ "        ^AQUA^%c #help" rot "%c" subst ansi_notify exit
   then
   "#help" stringcmp not if
      Whisp-Help exit
   then
   Args @ "#who" stringcmp not if
      me @ "_Whisp/LastWhisperer" getpropstr dup if
         me @ "^CINFO^Last Whisperer: ^NORMAL^"
         rot "^^" "^" subst strcat ansi_notify
      else
         pop
      then
      me @ "_Whisp/LastWhispered" getpropstr dup if
         me @ "^CINFO^Last Whispered to: ^NORMAL^"
         rot "^^" "^" subst strcat ansi_notify
      else
         pop
      then
      me @ "_Mumble/LastMumbler" getpropstr dup if
         me @ "^CINFO^Last Mumbler: ^NORMAL^"
         rot "^^" "^" subst strcat ansi_notify
      else
         pop
      then
      me @ "_Mumble/LastMumbled" getpropstr dup if
         me @ "^CINFO^Last Mumbled to: ^NORMAL^"
         rot "^^" "^" subst strcat ansi_notify
      else
         pop
      then
      me @ "^CINFO^Done." ansi_notify exit
   then
   Args @ "=" instr not if
      me @ "^CFAIL^What do you want to whisper?" ansi_notify exit
   then
   Args @ "=" split strip swap strip dup not if
      pop "#W"
   then
   command @ "w" instring 1 = Do-Match dup array_count not if
      pop pop me @ "^CFAIL^Who do you want to whisper to?" ansi_notify exit
   then
   swap dup ":" instr 1 = if
      1 strcut swap pop dup 1 strcut pop "[!?.,'\"- ]" smatch not if
        " " swap strcat
      then
      me @ name swap strcat
   then
   command @ "w" instring 1 = if
      Do-Whisper exit
   else
      Do-Mumble exit
   then
;
