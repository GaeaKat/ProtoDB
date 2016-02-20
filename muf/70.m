(*
   Cmd-@Doing v1.01
   Author: Chris Brine [Moose/Van]
 *)
 
$author Moose
$version 1.01
$include $lib/standard
$include $lib/strings
 
: DOING-rotate[ ref:ref -- ]
   ref @ "/@/HeavyRotationProcess" getpropval ISpid? if
      ref @ "/@/HeavyRotationProcess" over over getpropval
      dup GETpidinfo "called_prog" array_getitem prog dbcmp not if
         kill pop remove_prop
         ref @ PROPS-heavyrotation getpropstr not if
            ref @ "/heavyrotation" getpropstr
            ref @ PROPS-heavyrotation rot setprop
            ref @ "/@/Do-Num" remove_prop
         then
         ref @ "/_connect/heavyrotation" remove_prop
         ref @ "/heavyrotation" remove_prop
      else
         pop
      then
   then
   ref @ "/@/IdleDo" getpropstr not if
      ref @ "/@/AwayDo" getpropstr not if
         ref @ PROPS-heavyrotation getpropstr not if
            EXIT
         then
      then
   then
   ref @ "IDLE" Flag? if
      ref @ "/@/IdleDo" getpropstr dup strlen 44 >= if
         dup dup ref @ "/@/IdleDo-Num" getpropval strcut swap pop
         dup strlen 40 < if
            dup strlen 40 swap - rot swap strcut pop strcat
         else
            swap pop 40 strcut pop
         then
         "[ " swap strcat " ]" strcat
         ref @ "/@/IdleDo-Num" getpropval 1 + rot strlen over swap > if
            pop 0
         then
         ref @ "/@/IdleDo-Num" rot setprop
         ref @ "/_/IdleDo" rot setprop EXIT
      else
         pop ref @ "/@/IdleDo" remove_prop
         ref @ "/@/IdleDo-Num" remove_prop
      then
   then
   ref @ "/_Page/Away" getpropstr "yes" stringcmp not if
      ref @ "/@/AwayDo" getpropstr dup strlen 44 >= if
         dup dup ref @ "/@/AwayDo-Num" getpropval strcut swap pop
         dup strlen 40 < if
            dup strlen 40 swap - rot swap strcut pop strcat
         else
            swap pop 40 strcut pop
         then
         "[ " swap strcat " ]" strcat
         ref @ "/@/AwayDo-Num" getpropval 1 + rot strlen over swap > if
            pop 0
         then
         ref @ "/@/AwayDo-Num" rot setprop
         ref @ "/_/AwayDo" rot setprop EXIT
      else
         pop ref @ "/@/AwayDo" remove_prop
         ref @ "/@/AwayDo-Num" remove_prop
      then
   then
   ref @ PROPS-heavyrotation getpropstr dup strlen 44 >= if
      dup dup ref @ "/@/Do-Num" getpropval strcut swap pop
      dup strlen 40 < if
         dup strlen 40 swap - rot swap strcut pop strcat
      else
         swap pop 40 strcut pop
      then
      "[ " swap strcat " ]" strcat
      ref @ "/@/Do-Num" getpropval 1 + rot strlen over swap > if
         pop 0
      then
      ref @ "/@/Do-Num" rot setprop
      ref @ "/_/Do" rot setprop EXIT
   else
      pop ref @ PROPS-heavyrotation remove_prop
      ref @ "/@/Do-Num" remove_prop
   then
;
 
: DOING-queue[ -- ]
   prog "/@PID" getpropval ISpid? if
      prog "/@PID" getpropval GETpidinfo "called_prog" array_getitem prog dbcmp if
         prog "/@PID" getpropval kill pop
      then
   then
   prog "/@PID" pid setprop
   BEGIN
      online_array 1 array_nunion
      FOREACH
         swap pop dup Player? if dup awake? else pop then if
            DOING-rotate
         else
            pop
         then
      REPEAT
      3 sleep
   REPEAT
;
 
: DOING-help[ -- ]
   me @ "^CNOTE^Cmd-@Doing v1.01 - by Moose" ansi_notify
   me @ "^CINFO^~~~~~~~~~~~~~~~~~~~~~~~~~~~~" ansi_notify
   me @ "@DOING        ^WHITE^- Clear your doing." ansi_notify
   me @ "@DOING <text> ^WHITE^- Set a doing." ansi_notify
   me @ "@DOING #help  ^WHITE^- This screen" ansi_notify
   me @ "@DOING #rand <doing1>;<doing2>;<doing3>;<etc.>" ansi_notify
   me @ "              ^WHITE^- Setup a set of random doing strings." ansi_notify
   me @ "@IDOING       ^WHITE^- For IDLE @doings, works like @doing." ansi_notify
   me @ "@ADOING       ^WHITE^- For AWAY @doings, works like @doing." ansi_notify
   me @ "              ^WHITE^- Uses the page #away for checking." ansi_notify
   me @ "hl            ^WHITE^- Look at your own doings." ansi_notify
   me @ "hl <player>   ^WHITE^- Look at all of the doings for <player>." ansi_notify
   me @ "All non-random doings over 45 characters will be setup as a" ansi_notify
   me @ "hyper rotation doing." ansi_notify
   me @ "^CINFO^Done." ansi_notify
;
 
: DOING-look[ ref:ref -- ]
   me @ "Idle Doing: ^WHITE^"
   ref @ "/_/IdleDo" array_get_proplist dup array_count if
      rot rot ansi_notify
      FOREACH
         swap 1 + intostr 10 STRright ": ^WHITE^" strcat swap 1 escape_ansi strcat
         me @ swap ansi_notify
      REPEAT
   else
      pop ref @ "/@/IdleDo" getpropstr 1 escape_ansi dup not if
         pop ref @ "/_/IdleDo" getpropstr 1 escape_ansi dup not if
            pop "^CFAIL^None set."
         then
      then
      strcat ansi_notify
   then
   me @ "Away Doing: ^WHITE^"
   ref @ "/_/AwayDo" array_get_proplist dup array_count if
      rot rot ansi_notify
      FOREACH
         swap 1 + intostr 10 STRright ": ^WHITE^" strcat swap 1 escape_ansi strcat
         me @ swap ansi_notify
      REPEAT
   else
      pop ref @ "/@/AwayDo" getpropstr 1 escape_ansi dup not if
         pop ref @ "/_/AwayDo" getpropstr 1 escape_ansi dup not if
            pop "^CFAIL^None set."
         then
      then
      strcat ansi_notify
   then
   me @ "     Doing: ^WHITE^"
   ref @ "/_/Do" array_get_proplist dup array_count if
      rot rot ansi_notify
      FOREACH
         swap 1 + intostr 10 STRright ": ^WHITE^" strcat swap 1 escape_ansi strcat
         me @ swap ansi_notify
      REPEAT
   else
      pop ref @ PROPS-heavyrotation getpropstr 1 escape_ansi dup not if
         pop ref @ "/_/Do" getpropstr 1 escape_ansi dup not if
            pop "^CFAIL^None set."
         then
      then
      strcat ansi_notify
   then
   me @ "^CINFO^Done." ansi_notify
;
 
: main[ str:Args -- ]
   VAR STRprop VAR STRtype VAR ref
   command @ dup "@" instring 1 = not swap "h" instring 1 = not and if
      BACKGROUND
      DOING-queue EXIT
   then
   command @ "h" instring 1 = Args @ strip "#help" stringcmp not not and if
      Args @ strip dup not if
         pop me @
      else
         pmatch
      then
      dup ok? not if
         #-1 dbcmp if
            "^CINFO^I cannot find that player."
         else
            "^CINFO^I don't know which player you mean."
         then
         me @ swap ansi_notify EXIT
      then
      DOING-look EXIT
   then
   command @ "@a" instring 1 = if
      me @ "Away Doing" "/_/AwayDo"
   else
      command @ "@i" instring 1 = if
         me @ "Idle Doing" "/_/IdleDo"
      else
         me @ "Doing" "/_/Do"
      then
   then
   STRprop ! STRtype ! ref !
   Args @ strip dup not if
      me @ STRprop @ "/@/" "/_/" subst remove_prop
      me @ STRprop @ "/@/" "/_/" subst "-Num" strcat remove_prop
      pop ref @ STRprop @ remove_prop ref @ STRprop @ "#" strcat remove_prop
      me @ "^CSUCC^" STRtype @ strcat " cleared." strcat ansi_notify EXIT
   then
   dup "#help" stringcmp not if
      DOING-help EXIT
   then
   dup "#rand " instring 1 = over "#rand" stringcmp not or
   over "#random " instring 1 = or over "#random" stringcmp not or if
      me @ STRprop @ "/@/" "/_/" subst remove_prop
      me @ STRprop @ "/@/" "/_/" subst "-Num" strcat remove_prop
      " " split swap pop strip dup not if
         pop ref @ STRprop @ remove_prop ref @ STRprop @ "#" strcat remove_prop
         me @ "^CSUCC^Random " STRtype @ strcat " cleared." strcat ansi_notify
      else
         ";" explode_array
         ref @ STRprop @ rot array_put_proplist ref @ STRprop @ remove_prop
         me @ "^CSUCC^Random " STRtype @ strcat " set." strcat ansi_notify
      then
      EXIT
   then
   dup strlen 44 > if
      dup strlen 44 - intostr
      "^CFAIL^Your %s is %n characters too long.  Setting up a doing-rotation."
      swap "%n" subst STRtype @ "%s" subst me @ swap ansi_notify
      me @ STRprop @ "/@/" "/_/" subst 3 pick " " strcat setprop
      me @ STRprop @ "/@/" "/_/" subst "-Num" strcat remove_prop
      me @ STRprop @ "[ " 4 rotate 40 strcut pop strcat " ]" strcat setprop
   else
      me @ STRprop @ "/@/" "/_/" subst remove_prop
      me @ STRprop @ "/@/" "/_/" subst "-Num" strcat remove_prop
      me @ STRprop @ rot setprop
      me @ "^CSUCC^" STRtype @ strcat " set." strcat ansi_notify
   then
;
