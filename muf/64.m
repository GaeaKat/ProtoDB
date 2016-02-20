(*
   cmd-who v2.3
   Author: Chris Brine [Moose/Van]
 
   v2.3: Cleaned up to 30 column format. [Akari]
   v2.2: Added '#remote <player>' for wizards
 *)
 
$author Moose
$version 2.3
 
$def MIN_IDLE 3 (minutes)
 
: doname[ ref:ref -- str:name ]
   me @ ref @ dbcmp if
      "you" exit
   then
   me @ "WIZARD" flag? me @ owner "SEE_ALL" power? or me @ ref @ controls
   or me @ "SILENT" flag? not and if
      ref @ unparseobj ref @ name strlen strcut "^^" "^" subst swap
      ref @ me @ dbcmp if pop "you" then "^^" "^" subst swap "^CINFO^" swap
      strcat strcat
   else
      ref @ me @ dbcmp if "you" else ref @ name then "^^" "^" subst
   then
;
 
: Show-Who[ ref:REFloc -- ]
   "" dup VAR! STRidle dup VAR! STRpuppet dup VAR! STRplayer VAR! STRsleeper
   0 dup VAR! idleidx dup VAR! pupidx dup VAR! playidx VAR! sleepidx
   REFloc @ contents_array
   FOREACH
      swap pop
      BEGIN
         dup player? over "DARK" flag? not me @ "WIZARD" flag? or 3 pick
         me @ dbcmp or and if
            dup awake? if
               dup me @ dbcmp if dup doname else dup doname "\[" "," subst then
               over owner descrleastidle descridle 60 / MIN_IDLE > if
                  over owner descrleastidle descridle 60 / dup 60 > if
                     60 / dup 24 > if
                        24 / intostr "d" strcat
                     else
                        intostr "h" strcat
                     then
                  else
                     intostr "m" strcat
                  then
                  "^NORMAL^[^BROWN^" swap strcat "^NORMAL^]" strcat strcat
                  STRidle @ dup if "^NORMAL^, \n%c\n" strcat then swap strcat
                  STRidle ! idleidx ++
               else
                  STRplayer @ dup if "^NORMAL^, \n%c\n" strcat then swap strcat
                  STRplayer ! playidx ++
               then
            else
               dup doname "\[" "," subst STRsleeper @
               dup if "^NORMAL^, \n%c\n" strcat then
               swap strcat STRsleeper ! sleepidx ++
            then
         BREAK then
         dup thing? over "ZOMBIE" flag? and over "DARK" flag? not
         me @ "WIZARD" flag? or 3 pick me @ dbcmp or and if
            dup me @ dbcmp if dup doname else dup doname "\[" "," subst then
            over awake? if
               over owner descrleastidle descridle 60 / MIN_IDLE > if
                  over owner descrleastidle descridle 60 / dup 60 > if
                     60 / dup 24 > if
                        24 / intostr "d" strcat
                     else
                        intostr "h" strcat
                     then
                  else
                     intostr "m" strcat
                  then
                  "^NORMAL^[^BROWN^" swap strcat "^NORMAL^]" strcat strcat
               then
            else
               "^NORMAL^[^BROWN^Asleep^NORMAL^]" strcat
            then
            STRpuppet @ dup if "^NORMAL^, \n%c\n" strcat then swap
            strcat STRpuppet ! pupidx ++
         BREAK then
         BREAK
      REPEAT
      pop
   REPEAT
   STRplayer @ dup ", " rinstr if
      dup ", " rinstr strcut " \n%c\nand" swap strcat strcat
   then
   "," "\[" subst STRplayer !
   STRidle @ dup ", " rinstr if
      dup ", " rinstr strcut " \n%c\nand" swap strcat strcat
   then
   "," "\[" subst STRidle !
   STRsleeper @ dup ", " rinstr if
      dup ", " rinstr strcut " \n%c\nand" swap strcat strcat
   then
   "," "\[" subst STRsleeper !
   STRpuppet @ dup ", " rinstr if
      dup ", " rinstr strcut " \n%c\nand" swap strcat strcat
   then
   "," "\[" subst STRpuppet !
   playidx @ if
      playidx @ 1 = if
         me @ player? loc @ REFloc @ dbcmp and if
            "^CYAN^You ^AQUA^are the only one awake here."
         else
            "^AQUA^The only one awake here is ^CYAN^%s^AQUA^."
         then
      else
         "^AQUA^The players awake here are ^CYAN^%s^AQUA^."
      then
      STRplayer @ "%s" subst "^CYAN^" "\n%c\n" subst me @ swap ansi_notify
   then
   idleidx @ if
      idleidx @ 1 = if
         "^AQUA^Only ^CYAN^%s ^AQUA^is idle here."
      else
         "^AQUA^The idlers here are ^CYAN^%s^AQUA^."
      then
      STRidle @ "%s" subst "^CYAN^" "\n%c\n" subst me @ swap ansi_notify
   then
   me @ location "DARK" flag? "dark_sleepers" sysparm "yes" stringcmp not
   or not if
      sleepidx @ if
         sleepidx @ 1 = if
            "^AQUA^Only ^CYAN^%s ^AQUA^is asleep here."
         else
            "^AQUA^The sleepers here are ^CYAN^%s^AQUA^."
         then
         STRsleeper @ "%s" subst "^CYAN^" "\n%c\n" subst
      else
         "^AQUA^There are no sleepers here."
      then
      me @ swap ansi_notify
   then
   pupidx @ if
      pupidx @ 1 = if
         "^AQUA^The only puppet here is ^CYAN^%s^AQUA^."
      else
         "^AQUA^The puppets here are ^CYAN^%s^AQUA^."
      then
      STRpuppet @ "%s" subst "^CYAN^" "\n%c\n" subst me @ swap ansi_notify
   then
;
 
: main ( str:Args -- )
   dup "#remote " instring 1 = me @ "WIZARD" flag? and if
      "#remote" split strip " " split rot swap strcat swap pmatch dup ok?
      not if
         swap pop #-1 dbcmp if
            "^CINFO^I cannot find that player."
         else
            "^CINFO^I don't know which player you mean!"
         then
         me @ swap ansi_notify exit
      then
      location
   else
      pop loc @
   then
   Show-Who
;
