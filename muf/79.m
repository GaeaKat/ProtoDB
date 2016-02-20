(*
   Cmd-LastOn v2.03
   Author: Chris Brine [Moose/Van]
 
   v2.03: [Moose]
      - Added $lib/standard support
   v2.02: [Akari]
      - Cleaned up to 80 column format, added directives.
   v2.01:
      - Made the alias matches go a tad faster.
 *)
 
$author Moose
$version 2.03
$include $lib/arrays
$include $lib/strings
$include $lib/time
$include $lib/standard
 
(* $undef this to have ANSI off by default, $def it to have it on *)
$def Default-AnsiOn
 
$def PROP-ANSI      "/_LastOn/UseAnsi?"
$def PROP-TEMPTIME  "/@/LSTTempTime"
$def PROP-CONNTIME  "/@/ConnectTime"
$def PROP-DISCTIME  "/@/DisconnTime"
$def PROP-AWAKEFMT  "/_LastOn/AwakeFMT"
$def PROP-ASLEEPFMT "/_LastOn/AsleepFMT"
 
$def DIR-AWAKEFMTS  "/_LastOn/AwakeFMTs"
$def DIR-ASLEEPFMTS "/_LastOn/AwakeFMTs" ( LSedit proplists )
 
$def DEF-AWAKEFMT   "^CSUCC^LASTON: ^FOREST^%n is awake.\r^CYAN^Conn: ^AQUA^%c  ^CYAN^On For: ^AQUA^%to[-3]"
$def DEF-ASLEEPFMT  "^CSUCC^LASTON: ^FOREST^%n is asleep.\r^CYAN^Last: ^AQUA^%d  ^CYAN^On For: ^AQUA^%to[-3]\r^CYAN^Diff: ^AQUA^%td[-3]"
$def DEFT-TIMEFMT   "%A %B %e %H:%M:%S %Z %Y"
$def DEF-PARSEFMT   4
 
$define FMTS-AWAKE
   {
      "^GREEN^%n ^FOREST^has been online for ^GREEN^%to[4] ^FOREST^and connected on ^GREEN^%c[%A %B %e, %Y at %I:%M:%S %p]^FOREST^."
      "^CYAN^Conn: ^AQUA^%c  ^CYAN^On For: ^AQUA^%to[-3]"
      "^GREEN^%n ^FOREST^is awake."
      "^GREEN^%n ^FOREST^is awake."
   }list
   #0 DIR-AWAKEFMTS array_get_proplist array_combine
$enddef
 
$define FMTS-ASLEEP
   {
      "^GREEN^%n ^FOREST^has been asleep for ^GREEN^%td[4] ^FOREST^and last disconnected on ^GREEN^%d[%A %B %e, %Y at %I:%M:%S %p]^FOREST^, and was online for ^GREEN^%to[4]^FOREST^."
      "^CYAN^Conn: ^AQUA^%c  ^CYAN^On For: ^AQUA^%to[-3]\r^CYAN^Diff: ^AQUA^%td[-3]"
      "^GREEN^%n ^FOREST^is asleep.\r^CYAN^Conn: ^AQUA^%c  ^CYAN^On For: ^AQUA^%to[-3]\r^CYAN^Diff: ^AQUA^%td[-3]"
      "^CYAN^Conn: ^AQUA^%c  ^CYAN^On For: ^AQUA^%to[-3]\r^CYAN^Diff: ^AQUA^%td[-3]"
   }list
   #0 DIR-ASLEEPFMTS array_get_proplist array_combine
$enddef
 
$define DEF-TIMEFMT
   me @ "_LastOn/Format" getpropstr dup not if pop DEFT-TIMEFMT then
$enddef
 
VAR GBLmulti?
 
: LASTON-format[ ref:REF -- str:AwakeFmt str:AsleepFmt ]
   GBLmulti? @ not if
      REF @ PROP-AWAKEFMT getpropstr dup strip not if
         pop #0 PROP-AWAKEFMT getpropstr dup strip not if
            pop DEF-AWAKEFMT
         then
      then
      REF @ PROP-ASLEEPFMT getpropstr dup strip not if
         pop #0 PROP-ASLEEPFMT getpropstr dup strip not if
            pop DEF-ASLEEPFMT
         then
      then
   else
      "^FOREST^%n:17L ^BROWN^%s{--- ONLINE ---}:18L ^AQUA^%c[%I:%M%p %m/%d/%y]  ^NAVY^%d[%I:%M%p %m/%d/%y]"
      "^FOREST^%n:17L ^BROWN^%s{( %td[1] ago )}:18L ^AQUA^%c[%I:%M%p %m/%d/%y]  ^NAVY^%d[%I:%M%p %m/%d/%y]"
   then
;
 
: LASTON-conninfo[ ref:REF -- int:INTdisconn int:INTconn ]
   REF @ PROP-DISCTIME getpropval dup not if
      pop REF @ "/@/LastDis/1" getpropstr atoi dup not if
         pop REF @ timestamps pop rot rot pop pop
      then
   then
   REF @ dup awake? swap dup "D" flag? not swap "LIGHT" flag?
   or me @ "WIZARD" flag? or and if
      systime REF @ descrleastidle descrtime -
   else
      REF @ PROP-CONNTIME getpropval dup not if
         pop REF @ "/@/LastOn/1" getpropstr atoi dup not if
            pop REF @ timestamps pop rot rot pop pop
         then
      then
   then
;
 
: LASTON-getalias[ ref:REF -- str:STRname ]
   REF @ "%n" getpropstr dup strip if
      "*" over strcat match ok? if
         pop ""
      then
   else
      pop ""
   then
;
 
: UseAnsi?[ ref:REF -- int:BOLansi? ]
   REF @ PROP-ANSI getpropstr
$ifdef Default-AnsiOn
   "no" stringcmp not not
$else
   "yes" stringcmp not
$endif
;
 
$define ansi_notify ( ref str -- )
   over UseAnsi? if
      \ansi_notify
   else
      1 unparse_ansi notify
   then
$enddef
 
: LASTON-parse[ int:INTfmt int:INTtime -- str:STRtime ]
   INTfmt @ INTtime @ ParseTime
;
 
: LASTON-parsefmt[ ref:REF str:STRfmt -- str:STRreturn ]
   "" STRfmt @
   BEGIN
      dup "%" instr WHILE
      "%" split rot rot strcat swap 1 strcut swap
      dup "%" stringcmp not if
         pop swap "%" strcat swap CONTINUE
      then
      dup "s" stringcmp not if
         pop dup "{" instr 1 = if
            1 strcut swap pop "}" split swap
         else
            ""
         then
         REF @ swap LASTON-parsefmt
         over ":" instr 1 = if
            swap 1 strcut swap pop "" swap
            BEGIN
               dup 1 strcut pop number? WHILE
               1 strcut rot rot strcat swap
            REPEAT
            swap atoi swap 1 strcut -4 rotate dup "r" stringcmp not if
               pop swap 1 parse_ansi swap STRaright
            else
               "c" stringcmp not if
                  swap 1 parse_ansi swap STRacenter
               else
                  swap 1 parse_ansi swap STRleft
               then
            then
         then
         rot swap strcat swap CONTINUE
      then
      dup "n" stringcmp not if
         pop REF @ name
         rot swap 3 pick 1 strcut pop ":" stringcmp not if
            rot 1 strcut swap pop "" swap
            BEGIN
               dup 1 strcut pop number? WHILE
               1 strcut rot rot strcat swap
            REPEAT
            swap atoi swap 1 strcut -5 rotate dup "r" stringcmp not if
               pop swap 1 parse_ansi swap STRaright
            else
               "c" stringcmp not if
                  swap 1 parse_ansi swap STRacenter
               else
                  swap 1 parse_ansi swap STRleft
               then
            then
         then
         strcat swap CONTINUE
      then
      dup "a" stringcmp not if
         pop dup 1 strcut pop "[" instr if
            1 strcut swap pop "]" split swap
         else
            "^WHITE^(^AQUA^%a^WHITE^)^CMOVE^"
         then
         REF @ LASTON-getalias dup strip if
            "%a" subst rot
         else
            pop ""
         then
         rot swap 3 pick 1 strcut pop ":" stringcmp not if
            rot 1 strcut swap pop "" swap
            BEGIN
               dup 1 strcut pop number? WHILE
               1 strcut rot rot strcat swap
            REPEAT
            swap atoi swap 1 strcut -5 rotate dup "r" stringcmp not if
               pop swap 1 parse_ansi swap STRaright
            else
               "c" stringcmp not if
                  swap 1 parse_ansi swap STRacenter
               else
                  swap 1 parse_ansi swap STRleft
               then
            then
         then
         strcat swap CONTINUE
      then
      dup "c" stringcmp not if
         pop dup 1 strcut pop "[" instr if
            1 strcut swap pop "]" split swap
         else
            DEF-TIMEFMT
         then
         REF @ LASTON-conninfo swap pop timefmt rot swap
         3 pick 1 strcut pop ":" stringcmp not if
            rot 1 strcut swap pop "" swap
            BEGIN
               dup 1 strcut pop number? WHILE
               1 strcut rot rot strcat swap
            REPEAT
            swap atoi swap 1 strcut -5 rotate dup "r" stringcmp not if
               pop swap 1 parse_ansi swap STRaright
            else
               "c" stringcmp not if
                  swap 1 parse_ansi swap STRacenter
               else
                  swap 1 parse_ansi swap STRleft
               then
            then
         then
         strcat swap CONTINUE
      then
      dup "d" stringcmp not if
         pop dup 1 strcut pop "[" instr if
            1 strcut swap pop "]" split swap
         else
            DEF-TIMEFMT
         then
         REF @ LASTON-conninfo pop timefmt rot swap
         3 pick 1 strcut pop ":" stringcmp not if
            rot 1 strcut swap pop "" swap
            BEGIN
               dup 1 strcut pop number? WHILE
               1 strcut rot rot strcat swap
            REPEAT
            swap atoi swap 1 strcut -5 rotate dup "r" stringcmp not if
               pop swap 1 parse_ansi swap STRaright
            else
               "c" stringcmp not if
                  swap 1 parse_ansi swap STRacenter
               else
                  swap 1 parse_ansi swap STRleft
               then
            then
         then
         strcat swap CONTINUE
      then
      dup "t" stringcmp not if
         pop 1 strcut swap
         dup "c" stringcmp not if
            pop dup 1 strcut pop "[" instr if
               1 strcut swap pop "]" split swap atoi
            else
               DEF-PARSEFMT
            then
            systime REF @ LASTON-conninfo swap pop -
            LASTON-parse rot swap 3 pick 1 strcut pop ":" stringcmp not if
               rot 1 strcut swap pop "" swap
               BEGIN
                  dup 1 strcut pop number? WHILE
                  1 strcut rot rot strcat swap
               REPEAT
               swap atoi swap 1 strcut -5 rotate dup "r" stringcmp not if
                  pop swap 1 parse_ansi swap STRaright
               else
                  "c" stringcmp not if
                     swap 1 parse_ansi swap STRacenter
                  else
                     swap 1 parse_ansi swap STRleft
                  then
               then
            then
            strcat swap CONTINUE
         then
         dup "d" stringcmp not if
            pop dup 1 strcut pop "[" instr if
               1 strcut swap pop "]" split swap atoi
            else
               DEF-PARSEFMT
            then
            systime REF @ LASTON-conninfo pop -
            LASTON-parse rot swap 3 pick 1 strcut pop ":" stringcmp not if
               rot 1 strcut swap pop "" swap
               BEGIN
                  dup 1 strcut pop number? WHILE
                  1 strcut rot rot strcat swap
               REPEAT
               swap atoi swap 1 strcut -5 rotate dup "r" stringcmp not if
                  pop swap 1 parse_ansi swap STRaright
               else
                  "c" stringcmp not if
                     swap 1 parse_ansi swap STRacenter
                  else
                     swap 1 parse_ansi swap STRleft
                  then
               then
            then
            strcat swap CONTINUE
         then
         dup "o" stringcmp not if
            pop dup 1 strcut pop "[" instr if
               1 strcut swap pop "]" split swap atoi
            else
               DEF-PARSEFMT
            then
            REF @ LASTON-conninfo
            REF @ dup awake? swap "D" flag? not me @ "WIZARD" flag? or and if
               pop pop REF @ descrleastidle descrtime
            else
               -
            then
            LASTON-parse rot swap 3 pick 1 strcut pop ":" stringcmp not if
               rot 1 strcut swap pop "" swap
               BEGIN
                  dup 1 strcut pop number? WHILE
                  1 strcut rot rot strcat swap
               REPEAT
               swap atoi swap 1 strcut -5 rotate dup "r" stringcmp not if
                  pop swap 1 parse_ansi swap STRaright
               else
                  "c" stringcmp not if
                     swap 1 parse_ansi swap STRacenter
                  else
                     swap 1 parse_ansi swap STRleft
                  then
               then
            then
            strcat swap CONTINUE
         then
         pop CONTINUE
      then
      pop
   REPEAT
   strcat "\r" "\\r" subst
;
 
: LASTON-show[ ref:REF -- ]
   me @ LASTON-format
   REF @ dup awake? swap "D" flag? not me @ "WIZARD" flag? or and not if
      swap
   then
   pop REF @ swap LASTON-parsefmt
   me @ swap ansi_notify
;
 
: LASTON-match[ str:STRuser -- ref:REFplyr ]
   #-1 VAR! REFmatch
   STRuser @ pmatch dup #-1 dbcmp not if
      exit
   then
   pop #-1 "" "P!G" FIND_ARRAY
   dup "%n" STRuser @ array_filter_prop dup array_count if
      swap pop
   else
      pop "%n" STRuser @ "*" strcat array_filter_prop
   then
   dup array_count if
      dup array_count 1 = if
         0 array_getitem
      else
         pop #-2
      then
   else
      pop #-1
   then
;
 
: LASTON-fixplayers[ -- ]
   me @ PROP-TEMPTIME getpropval dup if
      me @ PROP-CONNTIME rot setprop
      me @ PROP-TEMPTIME remove_prop
      me @ PROP-DISCTIME #0 "/~Sys/StartupTime" getpropval setprop
   else
      pop
   then
   #0
   BEGIN
      NEXTPLAYER dup ok? WHILE
      dup awake? not if
         dup  PROP-TEMPTIME getpropval dup not if
            pop CONTINUE
         then
         over PROP-CONNTIME rot setprop
         dup  PROP-TEMPTIME remove_prop
         dup  PROP-DISCTIME #0 "/~Sys/StartupTime" getpropval setprop
      then
   REPEAT
   pop
;
 
: LASTON-choose-custom[ -- str:FMTasleep str:FMTawake int:Succ? ]
   VAR Option VAR TempINT
   me @ "^CINFO^ProtoLastOn v%1.2f ^CMOVE^-- CUSTOM FORMAT CHOOSER" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
   me @ "^CNOTE^---------------------------------------------------------------------------" ansi_notify
   me @ "  ^CINFO^1) ^CNOTE^Asleep Format: ^NORMAL^" DEF-ASLEEPFMT "\r                    " "\r" subst strcat ansi_notify
   me @        "     ^CNOTE^Awake  Format: ^NORMAL^" DEF-AWAKEFMT  "\r                    " "\r" subst strcat ansi_notify
   FMTS-ASLEEP
   FOREACH
      swap TempINT !
      TempINT @ 2 + intostr "\[" swap strcat 4 STRright
      "^CINFO^" "\[" subst ") ^CNOTE^Asleep Format: ^NORMAL^" strcat
      swap "\r                    " "\r" subst strcat me @ swap ansi_notify "     ^CNOTE^Awake  Format: ^NORMAL^"
      FMTS-AWAKE TempINT @ array_getitem
      "\r                    " "\r" subst strcat me @ swap ansi_notify
   REPEAT
   me @ "^CFAIL^A)bort the custom format chooser." ansi_notify
   BEGIN
      me @ "^CMOVE^Make your choice below [^NORMAL^1-%d,A^CMOVE^]:" FMTS-ASLEEP
      array_count 1 + intostr "%d" subst ansi_notify
      read "\r" over over strcat strcat "\r1\rA\r" swap
      instring over atoi 1 - dup FMTS-ASLEEP array_count <= swap 0 > and or not WHILE pop
   REPEAT
   Option !
   Option @ "1" stringcmp not if
      DEF-ASLEEPFMT DEF-AWAKEFMT 1 exit
   then
   Option @ "A" stringcmp not if
      "" "" 0 exit
   then
   Option @ atoi 2 -
   FMTS-ASLEEP over array_getitem
   FMTS-AWAKE rot array_getitem 1
;
 
: LASTON-custom-menu[ ref:REF -- str:STRoptions ]
   VAR FMTasleep VAR FMTawake VAR GBLasleep VAR GBLawake
   #0 PROP-ASLEEPFMT getpropstr strip dup not if
      pop DEF-ASLEEPFMT
   then
   "\r" "\\r" subst GBLasleep !
   #0 PROP-AWAKEFMT getpropstr strip dup not if
      pop DEF-AWAKEFMT
   then
   "\r" "\\r" subst GBLawake !
   me @ PROP-ASLEEPFMT getpropstr strip dup not if
      pop GBLasleep @
   then
   "\r" "\\r" subst FMTasleep !
   me @ PROP-AWAKEFMT getpropstr strip dup not if
      pop GBLawake @
   then
   "\r" "\\r" subst FMTawake !
   me @ "^CINFO^ProtoLastOn v%1.2f ^CMOVE^-- CUSTOM FORMAT EDITOR: ^GREEN^" prog "_Version" getpropstr strtof swap FMTstring
   REF @ dup unparseobj swap name strlen strcut "^CINFO^" swap "^^" "^" subst
   strcat swap "^^" "^" subst swap strcat strcat ansi_notify
   me @ "^CNOTE^---------------------------------------------------------------------------" ansi_notify
   me @ "^CINFO^Substitutions:" ansi_notify
   me @ " ^CNOTE^%c  ^NORMAL^-- Connection time          ^CINFO^%d  ^NORMAL^-- Disconnection time" ansi_notify
   me @ " ^CNOTE^%to ^NORMAL^-- Time online              ^CINFO^%td ^NORMAL^-- Time since last disconnect" ansi_notify
   me @ " ^CNOTE^%tc ^NORMAL^-- Time since last connect  ^CINFO^%s  ^NORMAL^-- Parse string in {} brackets" ansi_notify
   me @ " ^CNOTE^%n  ^NORMAL^-- Player name              ^CINFO^%a  ^NORMAL^-- Player alias" ansi_notify
   me @ "Each substitution can have parameters (inside of [] brackets) to change" ansi_notify
   me @ "the format it is in.  For %c and %d, you change the timefmt string." ansi_notify
   me @ "^CNOTE^(Type 'man timefmt' outside of the editor for more help)" ansi_notify
   me @ "However, for %to, %tc, and %tc, it is the type of time list. ^CINFO^Examples:" ansi_notify
   me @ "  ^CNOTE^%to[1] = ^NORMAL^1 hour  %to[3] = 1 hour, 2 minutes  ^CNOTE^%to[-1] = ^NORMAL^1h  ^CNOTE^%to[-2] = ^NORMAL^1h 2m" ansi_notify
   me @ "  ^CNOTE^%c[%A %b %e, %Y %I:%M:%S %p %Z]" ansi_notify
   me @ "%s is a special acception.  It allows you to parse its parameters before" ansi_notify
   me @ "the rest that comes after.  Except the paramters for this is in {} brackets." ansi_notify
   me @ "For justifying: (eg. ^CNOTE^%to[3]:13R^NORMAL^, justifies the string 13 spaces to the right." ansi_notify
   me @ "^CINFO^Codes: ^CNOTE^R ^NORMAL^= Right justify  ^CNOTE^L ^NORMAL^= Left justify  ^CNOTE^C ^NORMAL^= Center justify" ansi_notify
   me @ "^CNOTE^Note: ^NORMAL^%a also accept parameters in [] brackets for how to show the alias (if there)." ansi_notify
   me @ " " notify
   me @ "^YELLOW^1^PURPLE^) ^WHITE^Asleep format: ^NORMAL^" FMTasleep @ "\r                  " "\r" subst strcat ansi_notify
   me @ "^YELLOW^2^PURPLE^) ^WHITE^Awake  format: ^NORMAL^" FMTawake  @ "\r                  " "\r" subst strcat ansi_notify
   me @ "^YELLOW^3^PURPLE^) ^WHITE^Global Asleep format: ^NORMAL^"
   me @ "ARCHWIZARD" flag? not if
      "-" "3" subst 1 unparse_ansi
   then
   GBLasleep @ "\r                         " "\r" subst strcat ansi_notify
   me @ "^YELLOW^4^PURPLE^) ^WHITE^Global Awake  format: ^NORMAL^"
   me @ "ARCHWIZARD" flag? not if
      "-" "4" subst 1 unparse_ansi
   then
   GBLawake  @ "\r                         " "\r" subst strcat ansi_notify
   me @ "^YELLOW^5^PURPLE^) ^CSUCC^Choose a default custom asleep/awake format."
   ansi_notify
   me @ "^YELLOW^6^PURPLE^) ^CSUCC^Choose a default custom global asleep/awake format."
   me @ "ARCHWIZARD" flag? not if
      "-" "6" subst 1 unparse_ansi
   then
   ansi_notify
   me @ "^YELLOW^7^PURPLE^) ^CSUCC^Parse all ANSI codes in all laston calls? ^FOREST^"
   REF @ UseAnsi? if "Yes" else "No" then strcat ansi_notify
   me @ "^YELLOW^Q^PURPLE^) ^BROWN^Quit the editor." ansi_notify
   me @ " " notify
   me @ "ARCHWIZARD" flag? if
      "\r1\r2\r3\r4\r5\r6\r7\rQ\r"
   else
      "\r1\r2\r5\r7\rQ\r"
   then
   me @ "^CMOVE^Make your choice below [^NORMAL^%s^CMOVE^]:"
   3 pick 1 strcut swap pop dup strlen 1 - strcut pop "," "\r" subst "%s" subst
   ansi_notify
;
 
: LASTON-custom[ ref:REF -- ]
   VAR Option
   me @ REF @ controls not if
      me @ "^CFAIL^Permission denied." ansi_notify exit
   then
   BEGIN
      REF @ LASTON-custom-menu Option !
      BEGIN
         read "\r" over over strcat strcat Option @ swap instring not WHILE pop
         me @ "^CFAIL^Invalid option.  ^CMOVE^Make your choice below [^NORMAL^%s^CMOVE^]:"
         Option @ 1 strcut swap pop dup strlen 1 - strcut pop "," "\r"
         subst "%s" subst ansi_notify
      REPEAT
      Option !
      Option @ "1" stringcmp not if
         me @ "^CMOVE^Enter a new format below [or, space to use the default--or . to keep the default]:" ansi_notify
         read strip dup "." stringcmp if
            REF @ PROP-ASLEEPFMT rot "\\r" "\r" subst setprop "^CSUCC^Set."
         else
            pop "^CFAIL^Aborted."
         then
         me @ swap ansi_notify CONTINUE
      then
      Option @ "2" stringcmp not if
         me @ "^CMOVE^Enter a new format below [or, space to use the default--or . to keep the default]:" ansi_notify
         read strip dup "." stringcmp if
            REF @ PROP-AWAKEFMT rot "\\r" "\r" subst setprop "^CSUCC^Set."
         else
            pop "^CFAIL^Aborted."
         then
         me @ swap ansi_notify CONTINUE
      then
      Option @ "3" stringcmp not if
         me @ "^CMOVE^Enter a new format below [or, space to use the default--or . to keep the default]:" ansi_notify
         read strip dup "." stringcmp if
            #0 PROP-ASLEEPFMT rot "\\r" "\r" subst setprop "^CSUCC^Set."
         else
            pop "^CFAIL^Aborted."
         then
         me @ swap ansi_notify CONTINUE
      then
      Option @ "4" stringcmp not if
         me @ "^CMOVE^Enter a new format below [or, space to use the default--or . to keep the default]:" ansi_notify
         read strip dup "." stringcmp if
            #0 PROP-AWAKEFMT rot "\\r" "\r" subst setprop "^CSUCC^Set."
         else
            pop "^CFAIL^Aborted."
         then
         me @ swap ansi_notify CONTINUE
      then
      Option @ "5" stringcmp not if
         LASTON-choose-custom if
            REF @ PROP-AWAKEFMT rot "\\r" "\r" subst setprop
            REF @ PROP-ASLEEPFMT rot "\\r" "\r" subst setprop
            me @ "^CSUCC^Set." ansi_notify
         else
            pop pop me @ "^CFAIL^Aborted." ansi_notify
         then
         CONTINUE
      then
      Option @ "6" stringcmp not if
         LASTON-choose-custom if
            #0 PROP-AWAKEFMT rot "\\r" "\r" subst setprop
            #0 PROP-ASLEEPFMT rot "\\r" "\r" subst setprop
            me @ "^CSUCC^Set." ansi_notify
         else
            pop pop me @ "^CFAIL^Aborted." ansi_notify
         then
         CONTINUE
      then
      Option @ "7" stringcmp not if
         REF @ UseAnsi? if
            REF @ PROP-ANSI "no" setprop
         else
            REF @ PROP-ANSI "yes" setprop
         then
         me @ "^CSUCC^Toggled." ansi_notify
         CONTINUE
      then
      Option @ "Q" stringcmp not if
         me @ "^CINFO^Quitting the editor." ansi_notify BREAK
      then
   REPEAT
;
ARCHCALL LASTON-custom
 
: LASTON-help[ -- ]
   me @ "^CINFO^ProtoLastOn v%1.2f - by Moose/Van" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
   me @ "^CNOTE^---------------------------------------------------------------------------" ansi_notify
   me @ "^WHITE^LASTON <Players>  ^NORMAL^Laston list for a player list." ansi_notify
   me @ "^WHITE^LASTON <Player>   ^NORMAL^Laston (Or custom Laston) for one player." ansi_notify
   me @ "^WHITE^LASTON #HELP      ^NORMAL^This screen." ansi_notify
   me @ "^WHITE^LASTON #WF        ^NORMAL^Laston list for those in your watchfor list." ansi_notify
   me @ "^WHITE^LASTON #ALL       ^NORMAL^Laston list for all of the players on the MUCK." ansi_notify
   me @ "^WHITE^LASTON #CUSTOM    ^NORMAL^Setup a custom laston format." ansi_notify
   me @ "^CINFO^Done." ansi_notify
;
 
: LASTON-main[ str:Args -- ]
   { }list VAR! REFlist
   ""      VAR! STRlist
   0 GBLmulti? !
   command @ "Queued Event." stringcmp not if
      BACKGROUND
      me @ descr_array array_count 1 > if
         exit (Block multi-connections from effecting laston)
      then
      Args @ "Connect" stringcmp not if
         me @ PROP-TEMPTIME getpropval if
             LASTON-fixplayers
         then
         me @ PROP-TEMPTIME systime setprop
      else
         me @ PROP-TEMPTIME getpropval dup not if
            pop descr descr? if
               descr dup descr? if
                  descrtime
               else
                  1
               then
            else
               me @ timestamps pop rot rot pop pop
            then
            systime swap -
         then
         me @ PROP-CONNTIME rot setprop
         me @ PROP-DISCTIME systime setprop
         me @ PROP-TEMPTIME remove_prop
      then
      exit
   then
   Args @ strip dup Args ! dup "#help" stringcmp not swap not or if
      LASTON-help exit
   then
   Args @ "#CUSTOM" stringcmp not Args @ "#CUSTOM " instring 1 = or if
      Args @ 7 strcut swap pop strip dup not if
         pop me @ dup name swap
      else
         dup LASTON-match
      then
      dup ok? not if
         #-2 dbcmp if
            "^CINFO^LASTON: %n: I do not know which player you mean!"
            swap "%n" subst
         else
            "^CINFO^LASTON: %n: I cannot find that player." swap "%n" subst
         then
         me @ swap ansi_notify
      else
         swap pop LASTON-custom
      then
      exit
   then
   Args @ " " swap over strcat strcat Args !
   Args @ " #WF " instring if
      BEGIN
         Args @ " #WF " instring WHILE
         Args @ " " " #WF " subst " " " #Wf " subst " " " #wF " subst
         " " " #wf " subst Args !
      REPEAT
      me @ SETTING-announce_list getpropstr strip " " strcat
      Args @ striplead strcat Args !
   then
   Args @ " #ALL " instring if
      BEGIN
         Args @ " #ALL " instring WHILE
         Args @ " " " #ALL " subst " " " #ALl " subst " " " #AlL "
         subst " " " #All " subst
         " " " #aLL " subst " " " #aLl" subst " " " #alL " subst
         " " " #all " subst Args !
      REPEAT
      #0 NEXTPLAYER
      BEGIN
         dup ok? WHILE
         dup "GUEST" flag? over "www_surfer" sysparm stod dbcmp or over
         "player_prototype" sysparm stod dbcmp or over me @ dbcmp or not if
            dup REFlist @ array_appenditem REFlist !
         then
         NEXTPLAYER
      REPEAT
      pop
   then
   Args @ strip stripspaces " " explode_array
   FOREACH
      swap pop dup not if
         pop CONTINUE
      then
      dup LASTON-match dup ok? not if
         #-2 dbcmp if
            "^CINFO^LASTON: %n: I do not know which player you mean!"
            swap "%n" subst
         else
            "^CINFO^LASTON: %n: I cannot find that player." swap "%n" subst
         then
         me @ swap ansi_notify CONTINUE
      then
      swap pop REFlist @ array_appenditem REFlist !
   REPEAT
   REFlist @ { }list REFlist !
   FOREACH
      swap pop REFlist @ over name array_findval array_count if
         pop
      else
         name REFlist @ array_appenditem REFlist !
      then
   REPEAT
   REFlist @ SORTTYPE_NOCASE_ASCEND array_sort { }list REFlist !
   FOREACH
      swap pop "*" swap strcat match REFlist @ array_appenditem REFlist !
   REPEAT
   REFlist @ array_count not if
      me @ "^CFAIL^LASTON: Nobody to check the laston of." ansi_notify exit
   then
   REFlist @ array_count 1 > if
      1 GBLmulti? !
      me @ "^GREEN^Name              ^YELLOW^Laston             ^CYAN^Last Connected    ^BLUE^Last Disconnected" ansi_notify
      me @ "^WHITE^---------------------------------------------------------------------------" ansi_notify
   then
   REFlist @
   FOREACH
      swap pop LASTON-show
   REPEAT
   GBLmulti? @ if
      me @ "^CINFO^Done." ansi_notify
   then
;
