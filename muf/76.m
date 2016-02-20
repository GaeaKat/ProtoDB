(*
   Cmd-ProtoSpoof v1.03
   Author: Chris Brine [Moose/Van]
 
   v1.03:  [Akari] 09/05/2001
     - Cleaned up the code to 80 columes, added new directives and notes.
     - Made it so that users with more than 1 puppet in a remote room don't
       get multi-spammed by each puppet.
     - Added an option for leaving out ANSI or quote parsing support a la the
       old spoof programs via a _prefs/oldspoof:yes prop.
   v1.02:  [Moose]
     - Non-zombie things in the same room as the owner never got notified.
       Now they will.
     - Made it so that the #0 custom colors can be set, since now it'll only
       set them if the propdir for the spoof colors does not exist.
     - Fixed the quote-crashing bug.
 *)
 
$author Moose
$version 1.03
 
$def atell me @ swap ansi_notify
$def ptell Plyr @ swap ansi_notify
 
$def COLOR-SAY    "SAY/SAY"
$def COLOR-QUOTE  "SAY/QUOTE"
$def COLOR-POSE   "SAY/POSE"
$def COLOR-PARENS "WHITE"
 
$define match-db ( str:STRing int:Plyrs? -- ref:REFobj )
    Plyrs? !
    strip dup if
       Plyrs? @ if
          pmatch
       else
          match
       then
    else
       pop #-1
    then
    dup ok? not if
       #-1 dbcmp if
          "^CINFO^I don't know which one you mean!"
       else
          "^CINFO^I cannot find that here."
       then
       me @ swap ansi_notify #-1
    then
    me @ over controls not if
       pop me @ "^CFAIL^" "noperm_mesg" sysparm
       "^^" "^" subst strcat ansi_notify #-1
    then
$enddef
 
$define do-match ( str:STRing -- ref:REFobj )
   strip dup if
      0 match-db
   else
      pop me @
   then
$enddef
 
: SPOOF-one[ ref:Plyr ref:REF str:STRmsg int:HasParens? int:HasName?
             int:NoExtras? -- ]
   STRmsg @
   NoExtras? @ not if
      REF @ owner "~Spoof/Parens?" getpropstr "yes" stringcmp not
      REF @ "~Spoof/Parens?" getpropstr "yes" stringcmp not or
      HasParens? @ not and if
         "^SPOOF/PARENS^( " swap strcat " ^SPOOF/PARENS^)" strcat
      then
      REF @ owner "~Spoof/Name?" getpropstr "yes" stringcmp not
      REF @ "~Spoof/Name?" getpropstr "yes" stringcmp not or
      HasName? @ not and if
         " [^SPOOF/POSE^Spoofed By: ^SPOOF/SAY^%n^SPOOF/PARENS^]"
         Plyr @ name "^^" "^" subst "%n" subst strcat
      then
   then
   REF @ swap ansi_notify
;
 
: FixQuotes[ str:STRmsg -- str:STRmsg' ]
   0 VAR! inQuote 0 VAR! EndQuote?
   "" STRmsg @ 1 escape_ansi strip
   BEGIN
      dup "\"\"" instr WHILE
      "\"" "\"\"" subst
   REPEAT
   BEGIN
      dup "\"" rinstr over strlen = over and WHILE
      dup strlen 1 - strcut pop 1 EndQuote? ! striptail
   REPEAT
   BEGIN
      dup "\"" instr WHILE
      "\"" split rot rot strcat inQuote @ not if
         "^SPOOF/QUOTE^\"^SPOOF/SAY^" inQuote ++
      else
         "^SPOOF/QUOTE^\"^SPOOF/POSE^" inQuote --
      then
      strcat swap
   REPEAT
   strcat inQuote @ if
      "^SPOOF/QUOTE^\""
   else
      EndQuote? @ if
         "^SPOOF/QUOTE^\""
      else
         ""
      then
   then
   strcat "^SPOOF/POSE^" swap strcat
;
 
: pup-plyr-match[ str:STRname ref:REFloc -- ref:ref ]
   "*" STRname @ strcat match dup if
      EXIT
   then
   pop REFloc @ CONTENTS_ARRAY
   FOREACH
      swap pop dup name STRname @ stringcmp not over dup thing? swap
      "ZOMBIE" flag? and and if
         EXIT
      then
      pop
   REPEAT
   #-1
;
 
: SPOOF-all[ ref:Plyr ref:REFloc str:STRmsg int:NoExtras? -- ]
   0 VAR! HasName? 0 VAR! HasParens? VAR STRtempmsg { }list VAR! SPOOFsent
   STRmsg @ strip dup STRtempmsg !
   Plyr @ "_prefs/oldspoof" getpropstr "yes" stringcmp not if
      "^^" "^" subst
   else
      FixQuotes
   then STRmsg !
   Plyr @ location ok? NoExtras? @ not and if
      Plyr @ location "~Spoof/NoSpoofs?" getpropstr "yes" stringcmp not if
         "^CFAIL^SPOOF: Nobody is allowed to spoof here." ptell exit
      then
      Plyr @ location "~Spoof/BanList" array_get_reflist
      Plyr @ owner array_findval array_count if
         "^CFAIL^SPOOF: You are banned from spoofing here." ptell exit
      then
      Plyr @ owner "~Spoof/Wiz/Banned?" getpropstr "yes" stringcmp not if
         "^CFAIL^SPOOF: You are banned from spoofing globaly." ptell exit
      then
      Plyr @ location "~Spoof/Parens?" getpropstr "yes" stringcmp not
      Plyr @ "~Spoof/Wiz/Parens?" getpropstr "yes" stringcmp not or
      STRtempmsg @ strip " " split pop REFloc @ pup-plyr-match ok? or if
         "^SPOOF/PARENS^( " STRmsg @ strcat " ^SPOOF/PARENS^)"
         strcat STRmsg ! 1 HasParens? !
      then
      Plyr @ location "~Spoof/Name?" getpropstr "yes" stringcmp not
      Plyr @ "~Spoof/Wiz/Name?" getpropstr "yes" stringcmp not or
      STRtempmsg @ strip " " split pop REFloc @ pup-plyr-match ok? or if
         STRmsg @ " [^SPOOF/POSE^Spoofed By: ^SPOOF/SAY^%n^SPOOF/PARENS^]"
         Plyr @ name "^^" "^" subst "%n" subst strcat STRmsg ! 1 HasName? !
      then
   then
   Plyr @ REFloc @ STRmsg @ HasParens? @ HasName? @ NoExtras? @ SPOOF-one
   REFloc @ CONTENTS_ARRAY
   FOREACH
      swap pop SPOOFsent @ over dup "ZOMBIE" flag? if owner then
      array_findval array_count not if
         dup player? not if
            dup thing? over "ZOMBIE" flag? and over dup location swap
            owner location dbcmp and if
               pop continue
            then
            dup dup "ZOMBIE" flag? if owner then
            SPOOFsent @ array_appenditem SPOOFsent !
         then
         Plyr @ swap STRmsg @ HasParens? @ HasName? @ NoExtras? @ SPOOF-one
      else
         pop
      then
   REPEAT
;
 
: JoinUsers[ arr:REFlist -- str:PLYRlist ]
   "" REFlist @
   FOREACH
      swap pop dup ok? if
         owner name strcat " " strcat
      else
         pop
      then
   REPEAT
   strip dup not if
      pop "*Nobody*"
   then
;
 
: spoof-help[ -- ]
   me @ "^CINFO^ProtoSpoof v%1.2f - by Moose" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
   me @ "^CNOTE^~~~~~~~~~~~~~~~~~~~~~~~~~~~~" ansi_notify
   me @ "^WHITE^SPOOF    <message> ^NORMAL^- Send a message to the room." ansi_notify
   me @ "^WHITE^OSPOOF   <message> ^NORMAL^- Send an OOC message to the room." ansi_notify
   me @ "^WHITE^SPOOF #NAME        ^NORMAL^- Always show the player name. [#!name turns this off]" ansi_notify
   me @ "^WHITE^SPOOF #NAME here   ^NORMAL^- Always show the player name here. [#!name turns this off]" ansi_notify
   me @ "^WHITE^SPOOF #PARENS      ^NORMAL^- Always show parens. [#!parens turns this off]" ansi_notify
   me @ "^WHITE^SPOOF #PARENS here ^NORMAL^- Always show parens here. [#!parens turns this off]" ansi_notify
   me @ "^WHITE^SPOOF #BLOCK       ^NORMAL^- Block all spoofs in this room. [#!block turns this off]" ansi_notify
   me @ "^WHITE^SPOOF #BAN <plyr>  ^NORMAL^- Ban a user from spoofs here. [#!ban allows them]" ansi_notify
   me @ "^WHITE^SPOOF #BANLIST     ^NORMAL^- Show the banned users here." ansi_notify
   me @ "WIZARD" flag? if
      me @ "^WHITE^SPOOF #WIZPARENS p ^NORMAL^- Force parens on 'p' player. [#!wizparens turns this off]" ansi_notify
      me @ "^WHITE^SPOOF #WIZNAME   p ^NORMAL^- Force name showing on 'p' player. [#!wizname turns this off]" ansi_notify
      me @ "^WHITE^SPOOF #WIZBAN    p ^NORMAL^- Ban the 'p' player. [#!wizban allows them]" ansi_notify
      me @ "^WHITE^SPOOF #WIZBANLIST  ^NORMAL^- Show all players that are banned." ansi_notify
      me @ "^WHITE^WIZSPOOF <message> ^NORMAL^- Send a message to the room without parens nor spoofer name." ansi_notify
   then
   me @ "_prefs/oldspoof:yes   --> Disables ANSI and Quote Parsing." ansi_notify
   me @ "_/COLORS/SPOOF/SAY    --> SPOOF SAY MESSAGE COLOR" ansi_notify
   me @ "_/COLORS/SPOOF/QUOTE  --> SPOOF QUOTE CHARACTER COLOR" ansi_notify
   me @ "_/COLORS/SPOOF/POSE   --> SPOOF POSE MESSAGE COLOR" ansi_notify
   me @ "_/COLORS/SPOOF/PARENS --> SPOOF PARENS CHARACTER COLOR" ansi_notify
   me @ "^CINFO^Done." ansi_notify
;
 
: main[ str:Args -- ]
   VAR Option 0 VAR! DoNot 0 VAR! WizParens? VAR Plyrs?
   #0 "_/COLORS/SPOOF" propdir? not if
      #0 "_/COLORS/SPOOF/SAY" COLOR-SAY setprop
      #0 "_/COLORS/SPOOF/QUOTE" COLOR-QUOTE setprop
      #0 "_/COLORS/SPOOF/POSE" COLOR-POSE setprop
      #0 "_/COLORS/SPOOF/PARENS" COLOR-PARENS setprop
   then
   Args @ strip dup "#" instr 1 = swap not or if
      Args @ strip dup if
         " " split strip swap strip swap
      else
         "#help" ""
      then
      Args ! 1 strcut swap pop
      BEGIN
         dup "!" instr 1 = WHILE
         1 strcut swap pop DoNot @ not DoNot !
      REPEAT
      Option !
      Option @ "help" stringcmp not if
         spoof-help exit
      then
      Option @ "parens" stringcmp not if
         Args @ do-match dup ok? not if
            pop exit
         then
         DoNot @ if
            "~Spoof/Parens?" remove_prop
            me @ "^CSUCC^SPOOF: Parens will no longer be added." ansi_notify
         else
            "~Spoof/Parens?" "yes" setprop
            me @ "^CSUCC^SPOOF: Parens will now be added." ansi_notify
         then
         exit
      then
      Option @ "name" stringcmp not if
         Args @ do-match dup ok? not if
            pop exit
         then
         "~Spoof/Name?"
         DoNot @ if
            remove_prop
            "^CSUCC^SPOOF: The spoofer name will no longer be added." atell
         else
            "yes" setprop
            "^CSUCC^SPOOF: The spoofer name will now be added." atell
         then
         exit
      then
      Option @ "block" stringcmp not if
         loc @ "~Spoof/NoSpoofs?"
         DoNot @ if
            remove_prop
            "^CSUCC^SPOOF: Spoofs are no longer blocked here." atell
         else
            "yes" setprop
            "^CSUCC^SPOOF: Spoofs are now blocked here." atell
         then
         exit
      then
      Option @ "ban" stringcmp not if
         Args @ 1 match-db dup ok? not if
            pop exit
         then
         owner loc @ "~Spoof/BanList" array_get_reflist loc @ "~Spoof/BanList"
         rot 4 pick
         DoNot @ if
            array_excludeval me @ "^CSUCC^SPOOF: %n is no longer banned here."
            6 rotate name "^^" "^" subst "%n" subst ansi_notify
         else
            swap array_appenditem me @ "^CSUCC^SPOOF: %n is now banned here."
            6 rotate name "^^" "^" subst "%n" subst ansi_notify
         then
         array_put_reflist exit
      then
      Option @ "banlist" stringcmp not if
         loc @ "~Spoof/BanList" array_get_reflist JoinUsers
         me @ "^CYAN^Banned users here: ^AQUA^" rot strcat ansi_notify exit
      then
      me @ "WIZARD" flag? if
         Option @ "wizban" stringcmp not if
            Args @ 1 match-db dup ok? not if
               pop exit
            then
            owner dup "~Spoof/Wiz/Banned?"
            DoNot @ if
               remove_prop me @ "^CSUCC^SPOOF: %n is no longer banned globaly."
               rot name "^^" "^" subst "%n" subst ansi_notify
            else
               "yes" setprop me @ "^CSUCC^SPOOF: %n is now banned globaly."
               rot name "^^" "^" subst "%n" subst ansi_notify
            then
            exit
         then
         Option @ "wizparens" stringcmp not if
            Args @ 1 match-db dup ok? not if
               pop exit
            then
            owner dup "~Spoof/Wiz/Parens?"
            DoNot @ if
               remove_prop
               me @ "^CSUCC^SPOOF: %n is no longer having parens forced."
               rot name "^^" "^" subst "%n" subst ansi_notify
            else
               "yes" setprop me @
               "^CSUCC^SPOOF: %n is now having parens forced."
               rot name "^^" "^" subst "%n" subst ansi_notify
            then
            exit
         then
         Option @ "wizname" stringcmp not if
            Args @ 1 match-db dup ok? not if
               pop exit
            then
            owner dup "~Spoof/Wiz/Name?"
            DoNot @ if
               remove_prop me @
               "^CSUCC^SPOOF: %n is no longer having their name shown in spoofs."
               rot name "^^" "^" subst "%n" subst ansi_notify
            else
               "yes" setprop me @
               "^CSUCC^SPOOF: %n is now having their name shown in spoofs."
               rot name "^^" "^" subst "%n" subst ansi_notify
            then
            exit
         then
         Option @ "wizbanlist" stringcmp not if
            { }list #0
            BEGIN
               NEXTPLAYER dup ok? WHILE
               dup "~Spoof/Wiz/Banned?" getpropstr "yes" stringcmp not if
                  dup rot array_appenditem swap
               then
            REPEAT
            pop JoinUsers me @
            "^CYAN^Banned users globaly: ^AQUA^" rot strcat ansi_notify exit
         then
      then
      me @ "^CFAIL^SPOOF: Invalid option." ansi_notify exit
   else
      command @ "w" instring if
         1 WizParens? !
      then
      command @ "o" instring 1 = command @ "@o" instring 1 = or
      command @ "+o" instring 1 = or if
         "(OOC) " Args @ strcat Args !
      then
      me @ loc @ Args @ strip WizParens? @ SPOOF-all
   then
   BACKGROUND
   { }list loc @ "~Spoof/BanList" array_get_reflist
   FOREACH
      swap pop dup ok? if
         owner swap over array_excludeval array_appenditem
      else
         pop
      then
   REPEAT
   loc @ "~Spoof/BanList" rot array_put_reflist
;
