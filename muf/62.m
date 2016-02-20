(*
   Cmd-Whois v2.61
   Author: Chris Brine [Moose]
   v2.61:[Moose] Added $lib/standard support
   v2.6: [Akari] 09/06/01
         Added new 1.7 directives and formatted the code to 80 colums.
   v2.5: Added '#users' to list all registered puppets and users in the
         database.
         Whois now shows how many puppets and players were listed.
         Every option now has filtering enabled that works like #users.
         Added a '#loc' option specificly for filtering the players in the room.
   v2.4: Now uses $Lib/IC for IC/OOC checks
   v2.3: Now include registered puppets in #all
         Now includes a +who replacement
   v2.2: Added a 'P' tag for puppets
   v2.1: Added #awake, #asleep, and #remote
         Fixed name-length section and added AI* tags.
   TO DO:
    Allow for multiple options.
      Ie.  WS #all #awake *PL*
 *)
$include $lib/arrays
$include $lib/IC
$include $lib/puppet
$include $lib/strings
$include $lib/standard
$author Moose
$version 2.61
: who-help ( -- )
   me @ "^CINFO^Whois v2.61 - by Moose" ansi_notify
   me @ "^CNOTE^~~~~~~~~~~~~~~~~~~~~~~~~~~" ansi_notify
   me @ "^CNOTE^WS #help       ^NORMAL^- This screen" ansi_notify
   me @ "^CNOTE^WS #awake <?>  ^NORMAL^- All awake users here" ansi_notify
   me @ "^CNOTE^WS #asleep <?> ^NORMAL^- All sleeping users here" ansi_notify
   me @ "^CNOTE^WS #all <?>    ^NORMAL^- All online users" ansi_notify
   me @ "^CNOTE^WS #wf <?>     ^NORMAL^- Your watchfor list" ansi_notify
   me @ "^CNOTE^WS #users <?>  ^NORMAL^- List all users matching to the smatch <?> string." ansi_notify
   me @ "^CNOTE^WS #loc <?>    ^NORMAL^- Works just like normal 'ws' except allows smatch matching." ansi_notify
   me @ "                 Defaults to '*' if none given." ansi_notify
   me @ "WIZARD" flag? if
      me @ "^CNOTE^WS #remote <?> ^NORMAL^- Sets the whois room to another players.  Wizards only." ansi_notify
      me @ "               - This can also be used with the other options." ansi_notify
   then
   me @ "^CNOTE^WS <plyrs>     ^NORMAL^- For specific player(s)" ansi_notify
   me @ "^CNOTE^WS             ^NORMAL^- Just this one room" ansi_notify
   me @ "^CNOTE^+WHO           ^NORMAL^- Works just like WS, but gives different info." ansi_notify
   me @ "<?> in all but #remote is an smatch routine (see 'man smatch'). If it isn't" ansi_notify
   me @ "passed, then it will default to *." ansi_notify
   me @ "^CINFO^NOTE: ^NORMAL^Eventually the parameters will be able to join with other options." ansi_notify
   me @        "      When that happens, the last parameter will be the smatch string." ansi_notify
   me @ "^BROWN^TAGS: ^WHITE^P = ^NORMAL^Puppet ^WHITE^A = ^NORMAL^Awake ^WHITE^I = ^NORMAL^Idle ^WHITE^* = ^NORMAL^In Editor" ansi_notify
   me @ "^CINFO^Done." ansi_notify
;
: ISawake?[ ref:ref -- int:BOLawake? ]
   ref @ Awake? ref @ "DARK" Flag? not
   ref @ "LIGHT" Flag? or me @ owner "WIZARD" Flag? or
   ref @ location "@hidden" getpropstr "yes" strcmp or and
;
: ISdark?[ ref:ref -- int:BOLdark? ]
   ref @ "DARK" Flag? ref @ location "@hidden" getpropstr "yes" strcmp not or
   ref @ "LIGHT" Flag?
   me @ owner "WIZARD" Flag? or me @ owner ref @ location controls or not and
;
: do_the_match ( -- arr:ARRlist2 )
   { }list VAR! ARRlist2
   " " explode_array
   FOREACH
      swap pop strip dup if
         dup pmatch dup ok? if swap pop 1 else pop puppet_match dup ok? then if
            ARRlist2 @ over array_findval array_count not if
               dup ARRlist2 @ array_appenditem ARRlist2 !
            then
         then
      then
      pop
   REPEAT
   ARRlist2 @
;
: LEFT[ str:STRmsg int:Len str:Char -- ]
   STRmsg @ strip dup strlen Len @ > if
      Len @ 1 - strcut pop "\[" strcat
   then
   STRmsg !
   BEGIN
      STRmsg @ strlen Len @ < WHILE
      STRmsg @ Char @ strcat STRmsg !
   REPEAT
   STRmsg @ strlen Len @ > if
      STRmsg @ Len @ strcut pop STRmsg !
   then
   STRmsg @
;
: ParseTime[ int:INTtime -- str:STRtime ]
   INTtime @ 31536000 (years)   / if
      INTtime @ 31536000 / intostr "y" strcat exit
   then
   INTtime @ 2592000  (months)  / if
      INTtime @ 2592000  / intostr "M" strcat exit
   then
   INTtime @ 604800   (weeks)   / if
      INTtime @ 604800   / intostr "w" strcat exit
   then
   INTtime @ 86400    (days)    / if
      INTtime @ 86400    / intostr "d" strcat exit
   then
   INTtime @ 3600     (hours)   / if
      INTtime @ 3600     / intostr "h" strcat exit
   then
   INTtime @ 60       (minutes) / if
      INTtime @ 60       / intostr "m" strcat exit
   then
   (seconds)
   INTtime @ intostr "s" strcat exit
;
: IsPrivate?[ ref:ref -- int:BOLpriv? ]
   ref @ "_prefs/private?" getpropstr "yes" stringcmp not
;
: who-header[ int:INTtype? -- ]
   INTtype? @ if
      me @ "^PURPLE^+----------------+------+-------------------------+----------------+----+----+" ansi_notify
      me @ "^PURPLE^|^GREEN^Name            ^PURPLE^|^PURPLE^Class |^BLUE^Location                 ^PURPLE^|^GREEN^Alias           ^PURPLE^|^YELLOW^Conn^PURPLE^|^YELLOW^Idle^PURPLE^|" ansi_notify
      me @ "^PURPLE^+----------------+------+-------------------------+----------------+----+----+" ansi_notify
   else
      me @ "^BROWN^TAGS ^GREEN^Name             ^PURPLE^Gender  ^YELLOW^IC? ^BLUE^Short Description" ansi_notify
      me @ "^WHITE^----+----------------+-------+---+--------------------------------------------" ansi_notify
   then
;
: who-char[ ref:ref int:INTtype? -- ]
   VAR TMCOLOR
   INTtype? @ if
      ref @ name 16 STRleft dup strlen 16 > if 13 strcut pop
      "^^" "^" subst "^FOREST^..." strcat else "^^" "^" subst then "^GREEN^" swap strcat
      "^PURPLE^|" strcat
      ref @ dup thing? swap "ZOMBIE" flag? and if
         "Puppet"
      else
         ref @ "WIZARD" flag? if
            "Wizard"
         else
            "Player"
         then
      then
      me @ "PUEBLO" flag? if "^PURPLE^" else "^VIOLET^" then swap strcat
      strcat "^PURPLE^|" strcat
      ref @ location dup IsPrivate? not if
         name
      else
         pop "<Private>"
      then
      25 STRleft dup strlen 25 > if 22 strcut pop "^^" "^" subst "^NAVY^..."
      strcat else "^^" "^" subst then "^BLUE^" swap strcat strcat
      "^PURPLE^|" strcat
      ref @ "%n" getpropstr strip dup not if
         pop ref @ name
      else
         "*" over strcat match dup ref @ dbcmp not and if
            pop ref @ name
         then
      then
      16 STRleft dup strlen 16 > if 13 strcut pop
          "^^" "^" subst "^GREEN^..." strcat
      else "^^" "^" subst
      then
      me @ "PUEBLO" flag? if
          "^YELLOW^" TMCOLOR ! "^GREEN^"
      else "^BROWN^" TMCOLOR ! "^FOREST^"
      then
      swap strcat strcat "^PURPLE^|" strcat
      ref @ dup player? swap dup thing? over "ZOMBIE" flag?
      and rot or swap owner awake? and if
         ref @ owner descrleastidle descrtime ParseTime "\[" swap strcat
         5 STRright TMCOLOR @ "\[" subst strcat "^PURPLE^|" strcat
         ref @ owner descrleastidle descridle ParseTime "\[" swap strcat
         5 STRright TMCOLOR @ "\[" subst strcat "^PURPLE^|" strcat
      else
         "^BROWN^ZzZz^PURPLE^|^BROWN^ZzZz^PURPLE^|" strcat
      then
      "^PURPLE^|" swap strcat
   else
      ref @ dup name 16 "." LEFT over name strlen dup 16 > if pop 16 then
      strcut swap "^^" "^" subst
      "^GREEN^=" "\[" subst swap "^WHITE^|" strcat "^VIOLET^" swap strcat
      strcat "^FOREST^" swap strcat
      over PROPS-gender getpropstr strip dup not if
         pop "Unknown"
      else
         1 strcut swap toupper swap strcat
      then
      7 "." LEFT "^^" "^" subst "^PURPLE^=" "\[" subst "^VIOLET^" swap strcat
      strcat "^WHITE^|" strcat
      over REF-IC? if
         over REF-IC? -1 = if
            "^BLUE^AFK"
         else
            "^GREEN^IC "
         then
      else
         "^CRIMSON^OOC"
      then
      strcat "^WHITE^|" strcat
      over PROPS-shortdesc getpropstr strip dup strlen 44 > if
         41 strcut pop "^^" "^" subst "^AQUA^..." strcat
      else
         "^^" "^" subst
      then
      dup not if
         pop "^RED^None Set."
      then
      "^NAVY^" swap strcat strcat "^WHITE^|" swap strcat
      over owner "INTERACTIVE" flag? if
         "^CINFO^*"
      else
         " "
      then
      swap strcat over owner "IDLE" flag? if
         "^CINFO^I"
      else
         " "
      then
      swap strcat over awake? if
         "^CINFO^A"
      else
         " "
      then
      swap strcat over dup thing? swap "ZOMBIE" flag? and if
         "^CINFO^P"
      else
         " "
      then
      swap strcat
      swap pop
   then
   me @ swap ansi_notify
;
: who-footer[ int:INTcount int:USERcount int:PUPPETcount int:AWAKEcount
              int:INTtype? -- ]
   INTtype? @ if
      me @ "^PURPLE^+----------------+------+-------------------------+----------------+----+----+" ansi_notify
      me @ "^CINFO^%d listed (Players: %u  Puppets: %p  Awake: %a).  You are currently in %s."
      INTcount @ intostr "%d" subst
      USERcount @ intostr "%u" subst PUPPETcount @ intostr "%p" subst
      AWAKEcount @ intostr "%a" subst
      me @ location name "^^" "^" subst "%s" subst ansi_notify
   else
      me @ "^CINFO^%d listed  (Players: %u  Puppets: %p  Awake: %a)."
      AWAKEcount @ intostr "%a" subst
      INTcount @ intostr "%d" subst USERcount @ intostr "%u" subst PUPPETcount @
      intostr "%p" subst ansi_notify
   then
;
: who-run[ arr:ARRlist2 int:INThidedark? int:INTtype? -- ]
   0 VAR! INTcount 0 VAR! USERcount 0 VAR! PUPPETcount 0 VAR! AWAKEcount
   ARRlist2 @ dup array_count not if
      pop me @ "^CFAIL^I can't find that player." ansi_notify exit
   then
   INTtype? @ who-header
   FOREACH
      swap pop INThidedark? @ if dup ISdark? not else 1 then if
         dup Player? if
            USERcount ++
         else
            PUPPETcount ++
         then
         dup owner ISawake? if
            AWAKEcount ++
         then
         INTtype? @ who-char INTcount ++
      else
         pop
      then
   REPEAT
   INTcount @ USERcount @ PUPPETcount @ AWAKEcount @ INTtype? @ who-footer
;
: get_match_arr[ str:STRmatch -- arr:ARRreflist ]
   { }list #0
   BEGIN
      NEXTPLAYER dup ok? WHILE
      dup "GUEST" Flag? if
         CONTINUE
      then
      dup "player_prototype" sysparm stod dbcmp if
         CONTINUE
      then
      dup "www_surfer" sysparm stod dbcmp if
         CONTINUE
      then
      dup name STRmatch @ smatch if
         dup rot array_appenditem swap
      then
   REPEAT
   pop PUPPETS_registered
   FOREACH
      swap pop dup name STRmatch @ smatch if
         dup rot array_appenditem swap
      then
      pop
   REPEAT
;
: get_online_arr[ str:STRmatch -- arr:ARRreflist ]
   { }list ONLINE_ARRAY PUPPETS_ONLINE array_union 1 array_nunion
   FOREACH
      swap pop
      dup ISawake? if
         dup name STRmatch @ smatch if
            dup rot array_appenditem swap
         then
      then
      pop
   REPEAT
;
: get_wf_arr[ str:STRmatch -- arr:ARRlist2 ]
   { }list VAR! ARRlist2
   me @ "_Prefs/con_announce_list" getpropstr " " over strcat " " strcat
   " #all" instring not if
      do_the_match
   else
      pop #0 nextplayer
      BEGIN
         dup ok? not if
            pop BREAK
         then
         dup name STRmatch @ smatch if
            dup ARRlist2 @ array_appenditem ARRlist2 !
         then
         NEXTPLAYER
      REPEAT
      ARRlist2 @
   then
;
: get_loc_arr[ str:STRmatch int:AwakeOnly? -- arr:ARRlist2 ]
   { }list VAR! ARRlist2
   loc @ contents_array
   FOREACH
      dup thing? over "ZOMBIE" flag? and over player? or if
         dup owner ISawake? if AwakeOnly? @ -1 > else AwakeOnly? @ 1 < then if
            ARRlist2 @ over array_findval array_count not if
               dup name STRmatch @ smatch if
                  ARRlist2 @ array_appenditem ARRlist2 !
               else
                  pop
               then
            else
               pop
            then
         else
            pop
         then
      else
         pop
      then
   REPEAT
   ARRlist2 @
;
: CHECK-ARGS[ str:Args str:STRoption -- str:ArgMatch int:Matched? ]
(***
   If matched, it will return the parameter or '*' if none is given.
   If not matched, then it re-returns the arguments.
 ***)
   Args @ dup STRoption @ stringcmp not over
   STRoption @ " " strcat instring 1 = or if
      STRoption @ strlen strcut swap pop strip dup not if
         pop "*"
      else
         dup "*" instr over "?" instr or not if
            "*" swap over strcat strcat
         then
      then
      1
   else
      0
   then
;
: main ( str:Args -- )
   strip dup "#help" stringcmp not if
      pop who-help exit
   then
   dup "#remote" instring me @ "WIZARD" flag? and if
      "#remote" split strip " " split rot swap strcat swap pmatch dup ok? not if
         swap pop #-1 dbcmp if
            "^CINFO^I cannot find that player."
         else
            "^CINFO^I don't know which player you mean!"
         then
         me @ swap ansi_notify exit
      then
      location loc !
   then
   "#all" CHECK-ARGS if
      get_online_arr 1
   else
      "#wf" CHECK-ARGS if
         get_wf_arr 0
      else
         "#awake" CHECK-ARGS if
            1 get_loc_arr 1
         else
            "#asleep" CHECK-ARGS if
               -1 get_loc_arr 1
            else
               "#loc" CHECK-ARGS if
                  0 get_loc_arr 1
               else
                  "#users" CHECK-ARGS if
                     get_match_arr 0
                  else
                     dup if
                        do_the_match 1
                     else
                        pop "*" 0 get_loc_arr 1
                     then
                  then
               then
            then
         then
      then
   then
   swap SORTTYPE_NOCASE_ASCEND \array_sort swap
   "+who" command @ stringcmp not who-run
;
