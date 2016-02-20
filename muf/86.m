( ProtoFind 2.37 by Akari                                           )
(                  Nakoruru08@hotmail.com                           )
(                                                                   )
( Version 1.0  completed 07/11/00                                   )
( Version 1.1  completed 07/30/00                                   )
( Version 1.2  completed 10/05/00                                   )
( Version 2.0  completed 02/25/01                                   )
( Version 2.1  completed 02/28/01                                   )
( Version 2.11 completed 03/06/01                                   )
( Version 2.2  completed 03/10/01                                   )
( Version 2.21 completed 03/12/01                                   )
( Version 2.3  completed 03/18/01                                   )
( Version 2.31 completed 03/19/01                                   )
( Version 2.32 completed 04/01/01                                   )
( Version 2.33 completed 04/04/01                                   )
( Version 2.34 completed 04/08/01                                   )
( Version 2.35 completed 04/15/01                                   )
( Version 2.36 completed 04/24/01 [Moose]                           )
( Version 2.37 completed 01/06/03 [Moose]                           )
(                                                                   )
( A find program to include some different formatting options.      )
( Normal 'find' list, with some configureable changes, time         )
(   listings, using mtimestr and stimestr borrowed from Deedlit,    )
(   and some other support.                                         )
( Traditional RWA screen, with additional flags and indicators being)
(   able to be set.                                                 )
( And admin and a player configuration menu to change the appearance)
(   and permissions settings, etc.                                  )
( Version 1.1 - Just a lot of minor bug fixes, mostly dealing with  )
(               players that are unfindable.                        )
( Version 1.2 - Added the timestamp option for the status footer.   )
( Version 2.0 - A total rewrite. Proto 1.6 compatible only, due to  )
(               some new array prims. No more messy temp prop lists,)
(               everything is handled in arrays now. Custom color   )
(               support was added, as well as some alternate formats)
(               for both find and rwa. Made all the searches work   )
(               for both find AND rwa instead of just find. All the )
(               features of the previous version were included,     )
(               except the 'time' version of 'find', which was      )
(               replaced with the 'tfind' format.                   )
( Version 2.1 - Added the [Z] flag to rwa #all for sleeping players,)
(               and the Status flag for 'find <player>'. Added more )
(               custom color choices than before. Made it so that in)
(               the player options menu, overriden options will be  )
(               marked by a '*'. Made cut off points at the end of  )
(               the screen match up correctly.                      )
( Version 2.11- Fixed a bug in 'wa #wf' that didn't remove dup rooms)
( Version 2.2 - Added 'wa <puppet>.                                 )
( Version 2.21- Fixed minor 'rwa <name>' bug for not-found players. )
( Version 2.3 - Added a preference for respecting the IDLE flag.    )
(               Added a lot of flexability in how parent rooms are  )
(               determined.                                         )
( Version 2.31- Tossed the puppet? define into the code as to not   )
(               rely on one being on #0.                            )
( Version 2.32- Made all the sorting case-insensitive.              )
( Version 2.33- Minor fix in prwa output for stupidly long pup names)
( Version 2.34- Made it so that the default action is 'find' again. )
( Version 2.35- Fixed 2 parent room bug.                            )
( Version 2.36- Allowed use of $lib/ic via $def or Moose's features )
(               also sped up the grabbing of the players in #all    )
( Version 2.37- Added some standardization with $lib/standard       )
(                                                                   )
( ProtoFind is a ProtoMUCK exclusive only. It is not intended to    )
( work on any other MUCK server. For information regarding          )
( ProtoMUCK, see http://protomuck.sourceforge.net/ or contact       )
(                     protomuck@bigfoot.com                         )
( ** Include Libs ** )
$include $lib/puppet
$include $lib/arrays
$include $lib/standard
$include $lib/ic
( ** Changeable $defs, though most are fairly standard ** )
$def PlayerCol 23
$def AreaCol 21
$def RWARoomCol 40
$def PublicRoomProp PROPS-publicroom?
$def ParentRoomProp "_prefs/parent?"
$def DefaultIdle "idletime" sysparm atoi
( ** Program $def. Not is for changing this! ** )
$def atell me @ swap ansi_notify
$define puppet? ( d -- i )
  dup ok? if dup thing? if dup "_listen"
  getpropstr over "_listen" propdir? or swap "Z" flag?
  or else pop 0 then else pop 0 then
$enddef
( **Either Boolian or counter variables ** )
lvar isFind      ( boolian variable that indicates 'find'   )
lvar NoStatus    ( boolian variable for status override     )
lvar findAll     ( boolian variable for rwa-all             )
lvar isRWA       ( boolian variable that indicates 'wa'     )
lvar findIdle    ( boolian variable for finding only idle   )
lvar findUnidle  ( boolian variable for finding only unidle )
lvar findIC      ( boolian variable for finding only IC     )
lvar findOOC     ( boolian variable for finding only OOC    )
lvar findAFK     ( boolian variable for finding only AFK    )
lvar findSeries  ( string/bool var for finding series casts )
lvar count       ( keeps track of total characters printed  )
lvar ICCount     ( keeps track of the IC characters printed )
lvar OOCCount    ( keeps track of the OOC characters printed)
lvar AFKCount    ( keeps track of the AFK characters printed)
lvar IdleCount   ( keeps track of the idle players printed  )
lvar PuppetCount ( keeps track of the puppets printed       )
( ** Utilities ** )
: pad-loop ( Used with strlenset to pad the text out with - marks )
   rot 3 pick strcat
   -3 rotate 1 -
   dup if
     pad-loop
   else
     pop pop
   then
 ;
: strlenset (s1 s2 i -- s1') (string padchar size-of-final-string -- pad/cutstr)
  3 pick ansi_strlen over swap - dup if
    dup 0 < if
      (s s i negative-of-number-of-chars-to-chop-off-of-string)
      pop swap pop strcut pop
    else
      (s s i number-of-padchars-to-add-to-string)
      swap pop
      pad-loop
    then
  else
    pop pop pop
  then
;
: mtimestr ( i -- s )
  ( Returns hh:mm:ss )
  "" over 3600 / intostr "00" swap strcat
  dup strlen 2 - strcut swap pop strcat ":" strcat
  over 3600 % 60 / intostr "00" swap strcat
  dup strlen 2 - strcut swap pop strcat ":" strcat
  over 3600 % 60 % intostr "00" swap strcat
  dup strlen 2 - strcut swap pop strcat swap pop
;
: rp-status ( d -- i, 0 for OOC, 1 for IC, 2 for AFK )
  REF-IC? dup -1 = if
     pop 2
  then
;
: can-parent? ( d<startloc> d<potential parent> -- i )
  ( Checks to see if startloc can be parented to d2. Default is no. )
  var! parent var! startLoc
  parent @ "PARENT" flag? if 1 exit then
  startLoc @ "TRUEWIZARD" flag? if 1 exit then
  startLoc @ owner parent @ controls if 1 exit then
  parent @ "_/plok" getprop if
    startLoc @ owner parent @ "_/plok" islocked? not if 1 exit then
  then
  0
;
: parent-mode ( -- i, parent room mode options, defaults to 3 )
  ( 0 = Just grab the 'location' and that's it! )
  ( 1 = Just search for PARENT, else 'location' )
  ( 2 = Just search for '_prefs/parent?:yes', else 'location' )
  ( 3 = Search for both PARENT and '_prefs/parent?:yes', else 'location' )
  ( 4 = Search for alt-parent prop, else #3 )
  prog "_prefs/parentmode" getpropstr strip dup not if pop "3" then atoi
;
: get-parent ( d<start> -- d<valid parent> )
  ( All searches for parent room have been changed to use this function. )
  dup var! startLoc var! curLoc var parentMode
  parent-mode parentMode !
  parentmode @ 4 = if
    startLoc @ "_prefs/parent" getprop dup if
      dup dbref? not if stod then curLoc !
      startLoc @ curLoc @ can-parent? if curLoc @ exit then
    else pop then 3 parentMode !
  then
  startLoc @ curLoc !
  begin curLoc @ location curLoc ! curLoc @ #-1 dbcmp not while
    parentMode @ dup 1 = swap 3 = or if
      curLoc @ "PARENT" flag? else 0
    then
    parentMode @ dup 1 = swap 3 = or if
      curLoc @ ParentRoomProp getpropstr "yes" stringcmp not else 0
    then or if curLoc @ exit then
  repeat
  startLoc @ location dup ok? not if pop #0 then
;
( **Preference and Permissions Checks** )
: check-idle-flag? ( -- i, 1 for yes, 0 for no )
  ( If admin set the default, player can override. Defaults to yes. )
  prog "_prefs/idleflag" getpropstr "no" stringcmp not if
    me @ "_prefs/find/idleflag" getpropstr "yes" stringcmp not
    if 1 else 0 then exit
  else
    me @ "_prefs/find/idleflag" getpropstr "no" stringcmp not
    if 0 else 1 then exit
  then
;
: idle? ( d -- i, 1 yes, 0 for no )
  ( Checks curent player's idle time against user player's preferences )
  var idlepref
  check-idle-flag? if dup "IDLE" flag? if pop 1 exit then then
  me @ "_prefs/find/idletime" getpropstr atoi dup if idlepref !
    else pop prog "_prefs/idletime" getpropstr atoi dup if idlepref !
      else pop defaultidle idlepref !
    then
  then
  idlepref @ 60 * idlepref !
  owner descrleastidle dup 0 > not if pop 0 exit then
  descridle idlepref @ >
;
: require-public? ( -- i, 1 for yes, 0 for no )
  ( Admin global pref. Prevents finding except in public rooms only )
  prog "_prefs/publicOnly" getpropstr "yes" stringcmp not
;
: public? ( d -- i, 1 for yes, 0 for no )
  ( for use with require-public? setting )
  me @ "MAGE" flag? if pop 1 exit then
  publicRoomProp envpropstr swap pop "yes" stringcmp not
;
: sort? ( -- i, 1 for yes, 0 for no )
  ( Sort the find list or not. Defaults to no )
  me @ "_prefs/find/sort" getpropstr "yes" stringcmp not
;
: show-puppets? ( -- i, 1 for yes, 0 for no )
  ( Include puppets in the output? Defaults to no )
  command @ "pfind" stringcmp not command @ "prwa" stringcmp not or if 1 exit then
  prog "_prefs/puppets" getpropstr "yes" stringcmp not if
    me @ "_prefs/find/puppets" getpropstr "no" stringcmp not if 0 else 1 then
  else
    me @ "_prefs/find/puppets" getpropstr "yes" stringcmp not if 1 else 0 then
  then
;
: show-areas? ( -- i, 1 for yes, 0 for no )
  ( Defaults to yes, but if admin say 'no', then player pref ignored. )
  prog ParentRoomProp getpropstr "no" stringcmp not if 0 exit then
  me @ "_prefs/find/parents" getpropstr "no" stringcmp if 1 else 0 then
;
: show-2parents? ( -- i, 1 for yes, 0 for no )
  ( Defaults to no, but if admin say 'yes', then player pref ignored )
  prog "_prefs/2parents" getpropstr "yes" stringcmp not if 1 exit then
  me @ "_prefs/find/2parents" getpropstr "yes" stringcmp not if 1 else 0 then
;
: rwa-parents? ( -- i, 1 for yes, 0 for no, defaults to 0 )
  ( defaults to no, but if admin say 'yes', player pref ignored )
  prog "_prefs/rwaparents" getpropstr "yes" stringcmp not if 1 exit then
  me @ "_prefs/find/rwaparents" getpropstr "yes" stringcmp not if 1 else 0 then
;
: show-status? ( -- i, 1 for yes, 0 for no )
  ( Admin set the default, but players can override )
  noStatus @ if 0 exit then
  prog "_prefs/status" getpropstr "yes" stringcmp not if
    me @ "_prefs/find/status" getpropstr "no" stringcmp not if 0 else 1 then
  else
    me @ "_prefs/find/status" getpropstr "yes" stringcmp not if 1 else 0 then
  then
;
: show-timestamps? ( -- i, 1 for yes, 0 for no )
  ( Player pref only )
  me @ "_prefs/find/timestamp" getpropstr "yes" stringcmp not
;
: findable? ( d -- i, 1 for yes, 0 for no )
  ( Edit this function to control who is findable or not )
  me @ "MAGE" flag? if pop 1 exit then
  require-public? if dup location public? not if pop 0 exit then then
  prog "_prefs/hidedark" getpropstr "no" stringcmp not if pop 1 exit then
  dup "D" flag? if pop 0 exit then
  dup "LIGHT" flag? if pop 1 exit then
  dup location "@hidden" getpropstr "yes" stringcmp not if pop 0 exit then
  prog "_prefs/hidden" getpropstr "yes" stringcmp if pop 1 exit then
  "_prefs/find/hidden" getpropstr "yes" stringcmp not if 0 else 1 then
;
: unparse-rnames? ( d -- i, d=room, 1 for yes, 0 for no )
  ( If admin set to no, then player pref is ignored. Defaults to yes otherwise )
  prog "_prefs/runparse" getpropstr "no" stringcmp not if pop 0 exit then
  me @ "_prefs/find/runparse" getpropstr "no" stringcmp not if pop 0 exit then
  me @ swap controls
;
( **Printing Helper Functions** )
: get-connect-fmt ( d -- s )
  ( Returns the formatted connect time )
  var maxTime
  owner descr_array foreach
    swap pop descrtime dup maxTime @ > if maxTime ! else pop then
  repeat
  maxTime @ mtimestr
;
: get-idle-fmt ( d -- s )
  ( Returns the formatted idle time )
  owner descrleastidle dup 0 > not if pop 0 else descridle then mtimestr
;
: parse-room ( d -- s )
  ( Changes to how room names appear should generally be made in here )
  dup dup unparse-rnames? if unparseobj else name then
  over PublicRoomProp getpropstr "yes" stringcmp not if
    "^PURPLE^+ ^FIND/ROOM^" swap strcat swap pop exit
  then
  prog PROPS-privateroom? getpropstr "no" stringcmp if
    over PROPS-privateroom? getpropstr "yes" stringcmp not if
      over me @ swap controls not if
       pop pop "^PURPLE^- ^FIND/ROOM^<Private>" exit else
       "^PURPLE^- ^FIND/ROOM^" swap strcat swap pop exit
      then
    then
  then
  swap pop "^FIND/FRAME^| ^FIND/ROOM^" swap strcat
;
: parse-player ( d -- s )
  ( Changes in how the player names appear should generally be made in here. )
  count ++ dup name
  isFind @ if
    over puppet? if puppetCount ++ "^PURPLE^* ^FIND/PLAYER^" swap strcat
    else over owner awake? not if "^PURPLE^Z ^FIND/PLAYER^" swap strcat
      else over idle? if IdleCount ++ "^PURPLE^I ^FIND/PLAYER^" swap strcat
        else over "INTERACTIVE" flag? if "^PURPLE^E ^FIND/PLAYER^" swap strcat
          else "  " swap strcat then
        then
      then
    then
  then
  isRWA @ if
    over puppet? if puppetCount ++ "(" swap strcat ")" strcat then
    over idle? if IdleCount ++ then
  then
  1 parse_ansi
  show-status? if
    over owner awake? not if swap pop "^WHITE^[^PURPLE^Z^WHITE^]^FIND/PLAYER^"
    else swap rp-status dup 2 = if AFKCount ++ pop "^WHITE^[^YELLOW^A^WHITE^]^FIND/PLAYER^"
      else dup 1 = if ICCount ++ pop "^WHITE^[^GREEN^I^WHITE^]^FIND/PLAYER^"
        else 0 = if OOCCount ++ "^WHITE^[^RED^O^WHITE^]^FIND/PLAYER^"
          else "   " then
        then
      then
    then
  else swap pop ""
  then
  isFind @ if
    swap "                      " strcat PlayerCol 4 - ansi_strcut pop swap
  then strcat 1 parse_ansi
;
( ** Find Printing Routines** )
: find-single ( s -- )
  ( Prints out the 'player is at' kind of output. )
  var target 0 isFind !
  dup pmatch dup ok? if target ! pop
  else pop dup puppet_match dup ok? if target ! pop
    else pop "^YELLOW^Could not find " swap strcat "." strcat atell exit then
  then
  target @ findable? not if
    "^YELLOW^That player cannot be found right now." atell exit then
  require-public? if target @ location public? not if pop
    "^YELLOW^That player is not in a public area." atell exit then
  then
  target @ parse-player " ^NORMAL^is currently in " strcat
  show-areas? if
    target @ location get-parent
    dup unparse-rnames? if unparseobj else name then "^FIND/PARENT^"
    swap strcat " ^NORMAL^world at " strcat strcat
  then
  target @ location dup unparse-rnames? if unparseobj else name then
  "^FIND/ROOM^" swap strcat "." strcat strcat
  target @ idle? if "^PURPLE^I-^FIND/PLAYER^" swap strcat then
  "^FIND/PLAYER^" swap strcat atell
;
: print-header ( -- )
  ( Header for standard find and rwa )
  prog "_prefs/title" getpropstr dup not if pop
"^FIND/FRAME^+----------------------------------------------------------------------------+"
  atell else
    "(^WHITE^" swap strcat "^FIND/FRAME^)" strcat 1 parse_ansi dup ansi_strlen
    76 swap - 2 / "" "-" rot strlenset swap strcat "-" 76 strlenset
    "^FIND/FRAME^+" swap strcat "+" strcat atell
  then
;
: print-footer ( -- )
  ( Prints out the footer for standard find and rwa )
  me @ "_prefs/find/findstats" getpropstr "yes" stringcmp if
"^FIND/FRAME^+----------------------------------------------------------------------------+"
  atell exit then
  "( ^PURPLE^" count @ intostr strcat "^WHITE^ players [^CYAN^" strcat
  IdleCount @ intostr strcat "^WHITE^ idle]^FIND/FRAME^" strcat show-status? if
    ": ^GREEN^" strcat ICCount @ intostr strcat " ^WHITE^IC ^RED^" strcat
    OOCCount @ intostr strcat " ^WHITE^OOC ^YELLOW^" strcat AFKCount @ intostr strcat
    " ^WHITE^AFK^FIND/FRAME^" strcat then " )" strcat
  me @ swap "\[[0m" parse_neon dup ansi_strlen 76 swap - 2 / "" "-" rot strlenset swap
  strcat me @ swap "\[[0m" parse_neon "-" 76 strlenset "^FIND/FRAME^+" swap strcat
  show-timestamps? if
    me @ swap "\[[0m" parse_neon 65 ansi_strcut pop "( ^WHITE^%l^YELLOW^:^WHITE^%M ^FIND/FRAME^)---"
    systime timefmt strcat
  then
  "+" strcat atell
;
: find-print-tfind ( arr<dbrefs of players> -- )
  var! farray var target
"^FIND/FRAME^[      ^WHITE^Name       ^FIND/FRAME^][^WHITE^IC?^FIND/FRAME^][           ^WHITE^Location             ^FIND/FRAME^][ ^WHITE^On for ^FIND/FRAME^][  ^WHITE^Idle  ^FIND/FRAME^]" atell
  farray @ foreach swap pop target !
    "^FIND/FRAME^[^FIND/PLAYER^" target @ name "                   " strcat 17 strcut pop strcat
    "^FIND/FRAME^][" strcat target @ rp-status dup 2 = if pop "^YELLOW^AFK" else
      1 = if "^GREEN^IC " else "^RED^OOC" then
    then strcat "^FIND/FRAME^][^FIND/ROOM^" strcat
    target @ location name "                               " strcat 32 strcut pop
    strcat "^FIND/FRAME^][^FIND/TIME^" strcat
    target @ get-connect-fmt strcat "^FIND/FRAME^][^FIND/TIME^" strcat
    target @ get-idle-fmt strcat "^FIND/FRAME^]" strcat atell
  repeat
  "^CINFO^~Done~" atell
;
: find-print-oldfind ( arr<dbrefs of players> -- )
  ( for those who just can't stand something new; Confu's old find format )
  var! farray var target
  "Name              Area                 Room" .tell
  "----------------+--------------------+----------------------------------------" .tell
  farray @ foreach swap pop dup findable? not if pop continue then
  dup target ! dup puppet? if "*" else "" then swap name swap strcat
  "                    " strcat 16 strcut pop
  "| " strcat
    target @ get-parent name
    "                        " strcat 19 strcut pop strcat
    target @ location parse-room 1 parse_ansi ansi_strip strcat
    "                                  " strcat 79 strcut pop .tell
  repeat
;
: find-print ( arr -- )
  ( Prints out the new find format, with 1 or 2 parent rooms per prefs )
  me @ "_prefs/find/findfmt" getpropstr dup if
    dup "oldfind" stringcmp not if pop find-print-oldfind exit then
    dup "tfind" stringcmp not if pop find-print-tfind exit then
  then pop
  command @ "oldfind" stringcmp not if find-print-oldfind exit then
  command @ "tfind" stringcmp not if find-print-tfind exit then
  var! farray var target
  show-2parents? if 1 noStatus ! then
  print-header
  farray @ foreach
    swap pop target !
    target @ findable? not if continue then
    me @ "^FIND/FRAME^|^FIND/PLAYER^" "\[[0m" parse_neon
    target @ parse-player dup not if pop pop continue then
    "                                                    " strcat
    PlayerCol show-status? not if 4 - then ansi_strcut pop strcat
    show-2parents? if me @ "^FIND/FRAME^|^FIND/PARENT^" "\[[0m" parse_neon strcat
      target @ location get-parent var! firstParent
      firstParent @ location ok? if firstParent @ else #0 then get-parent name
      var! secondParent
      secondParent @ "              " strcat 14 strcut pop strcat
      me @ "^FIND/FRAME^|^FIND/PARENT^" "\[[0m" parse_neon strcat
      firstParent @ name "              " strcat 14 strcut pop strcat
    else show-areas? if me @ "^FIND/FRAME^| ^FIND/PARENT^" "\[[0m" parse_neon strcat
        target @ location get-parent name "                          " strcat
        AreaCol 2 - strcut pop strcat
      then " " strcat
    then
    target @ location parse-room me @ swap "\[[0m" parse_neon strcat
    "                                                               "
    strcat 78 ansi_strcut pop atell
  repeat print-footer
;
( **Find search engines and player search filters** )
: find-wf ( -- arr<array of players> )
  ( Creates the find-array for players only in your WF list )
  var farray
  0 array_make farray !
  me @ "_prefs/con_announce_list" getpropstr dup not if pop farray @ exit then
  " " explode_array foreach swap pop
    pmatch dup if dup awake? if
      farray @ array_appenditem farray ! else pop then
    else pop then
  repeat
  farray @
;
: find-all ( -- arr<array of players> )
  ( Lists every blasted player on the muck! )
  var farray
  0 array_make farray !
  #-1 "" "P!G" FIND_ARRAY farray !
  sort? if farray @ 1 array_sort farray ! then
  show-puppets? if puppets_registered farray @ swap 2 array_combine farray ! then
  farray @
;
: find-idle ( arr<array of players> -- arr<array of players> )
  ( Filters out the unidle or the idle players depending on bool values )
  findAll @ if exit then
  dup var! farray
  findIdle @ if ( we want to remove non-idles )
    foreach swap pop dup idle? not if
        farray @ swap array_findval array_vals ( find player's dbrefs in array )
        1 swap 1 for pop
          farray @ swap array_delitem farray ! ( remove player from array )
        repeat
      else pop then
    repeat farray @ exit
  then
  findUnidle @ if ( we want to remove idles )
    foreach swap pop dup idle? if
        farray @ swap array_findval array_vals ( find player's dbrefs in array )
        1 swap 1 for pop
          farray @ swap array_delitem farray ! ( remove player from array )
        repeat
      else pop then
    repeat farray @ exit
  then
;
: find-search ( arr<array of players> -- arr<array of players> )
  ( Filters out RP-status and series searches depending on bool values )
  var! farray
  findSeries @ if
    findSeries @ "*" instr not if "*" findSeries @ "*" strcat strcat findSeries ! then
    farray @ "/series" findSeries @ array_filter_prop farray !
  then
  farray @ { }list
  findIC  @ if  1 swap array_appenditem then
  findOOC @ if  0 swap array_appenditem then
  findAFK @ if -1 swap array_appenditem then
  dup array_count if
     REF-FILTER-STATUS
  else
     pop
  then
;
: find-default ( -- s )
  ( This sets the player's default find filter )
  me @ "_prefs/find/deffilter" getpropstr dup not if exit then
  dup "wf" stringcmp not if "#wf" exit then
  dup "all" stringcmp not if "#all" exit then
  dup "active" stringcmp not if pop "#active" exit then
  dup "idle" stringcmp not if pop "#idle" exit then
  dup "unidle" stringcmp not if pop "#unidle" exit then
  dup "ic" stringcmp not if pop "#ic" exit then
  dup "ooc" stringcmp not if pop "#ooc" exit then
  dup "afk" stringcmp not if pop "#afk" exit then
  dup "series" instring if "=" split swap pop "#series " swap strcat exit then
;
: do-find ( s -- )
  ( The main find function. Sets bools and calls appropriate filter functions )
  1 isFind !
  online_array var! farray
  sort? if farray @ 1 array_sort farray ! then
  show-puppets? if farray @ puponline 1 array_sort 2 array_combine farray ! then
  dup not if pop find-default then tolower
  dup "#wf" instr if pop find-wf find-print exit then
  dup "#all" instr if pop find-all find-print exit then
  dup "#idle" instr if 1 findIdle ! "" "#idle" subst then
  dup "#unidle" instr if 1 findUnidle ! "" "#unidle" subst then
  dup "#active" instr if 1 findUnidle ! "" "#active" subst then
  ( If we are doing time based searches, we do so now )
  findIdle @ findUnidle @ or if
    farray @ find-idle farray !
  then
  dup "#ic" instr if 1 findIC ! "" "#ic" subst then
  dup "#ooc" instr if 1 findOOC ! "" "#ooc" subst then
  dup "#afk" instr if 1 findAFK ! "" "#afk" subst then
  dup "#series" instr if "" "#series" subst strip dup findSeries ! then
  findIC @ not findOOC @ not and findAFK @ not and findSeries @ not and over and
  if find-single exit then pop
  farray @ find-search find-print
;
( **RWA Print Functions** )
: rwa-room-print ( d<room> arr<array of contents> -- )
  ( This function handles the individual room print outs )
  var curLine var curPlayer
  var! playerlist parse-room
  "                                                             " strcat
  me @ swap "\[[0m" parse_neon RWARoomCol ansi_strcut pop "^FIND/FRAME^| ^FIND/PLAYER^" strcat
  curLine !
  playerList @ foreach swap pop
    parse-player dup not if pop continue then dup curPlayer !
    curLine @ swap strcat me @ swap "\[[0m" parse_neon dup ansi_strlen 78 <
    if ", " strcat curLine ! continue else pop then
    curLine @ dup "," rinstring dup if 1 - strcut pop else pop then atell
    "                                                              "
    RWARoomCol 1 - strcut pop "^FIND/FRAME^|^FIND/PLAYER^" swap
    strcat "^FIND/FRAME^|^FIND/PLAYER^ " strcat
    curPlayer @ strcat ", " strcat curLine !
  repeat curLine @ 1 parse_ansi ansi_strlen 3 - RWARoomCol = not if
    curLine @ dup "," rinstring dup if
      1 - strcut pop else pop then
    atell
  then
;
: rwa-contents ( d<room> -- arr<of players/puppets )
  ( Creates the array of players to print out for a room, calls filters )
  0 array_make var! pArray
  contents_array foreach swap pop
    dup player? if
      dup awake? findAll @ or if
        dup findable? if pArray @ array_appenditem pArray ! continue then
      then
    then
    dup puppet? show-puppets? and if
      dup owner awake? if
        dup findable? if pArray @ array_appenditem pArray ! continue then
      then
    then
    pop
  repeat parray @ find-idle find-search
;
: rwa-print ( arr<rooms to print out> -- )
  ( Manages the printing of the rwa format, now with optional parent rooms )
  var! roomArray var parentArray var indexArray var curLoc var curRoom
  var parentBar
  rwa-parents? if
    0 array_make_dict parentArray ! 0 array_make indexArray !
    roomArray @ foreach swap pop dup curRoom !
      dup get-parent curLoc !
      curLoc @ indexArray @ array_appenditem indexArray !
      parentArray @ curLoc @ int array_getitem dup not if pop 0 array_make then
      curRoom @ swap array_appenditem parentArray @ curLoc @ int array_setitem
      parentArray !
    repeat
    indexArray @ 1 array_nunion 1 array_sort foreach swap pop curLoc !
      parentArray @ curLoc @ int array_getitem array_count not if continue then
      "^FIND/FRAME^+---( ^WHITE^" curLoc @ name strcat " ^FIND/FRAME^)" strcat
      me @ swap "\[[0m" parse_neon "-" 76 strlenset "+" strcat parentBar !
      parentArray @ curLoc @ int array_getitem 1 array_sort foreach swap pop
        dup rwa-contents dup array_count not if pop else
        parentBar @ if parentBar @ atell "" parentBar ! then
        rwa-room-print then
      repeat
    repeat
    print-footer
  else
    print-header
    roomArray @ forEach
      swap pop dup rwa-contents dup array_count not if pop else rwa-room-print then
    repeat
    print-footer
  then
;
( **RWA Array generating functions**)
: rwa-wf ( -- arr<of rooms>)
  ( rwa for only those in your WF list. Others in their rooms are listed )
  var waArray
  0 array_make waArray !
  me @ "_prefs/con_announce_list" getpropstr dup not if pop waArray @ exit then
  " " explode_array foreach swap pop
    pmatch dup player? if dup awake? if
      location waArray @ array_appenditem waArray ! else pop then
    else pop then
  repeat waArray @ 1 array_nunion 1 array_sort
;
: rwa-all ( -- arr<of rooms> )
  ( rwa for every player on the MUCK )
  var waArray 1 findAll !
  0 array_make waArray !
  #0 begin nextplayer dup while
    dup location waArray @ array_appenditem waArray !
  repeat pop
  waArray @ 1 array_nunion 1 array_sort
;
: rwa-single ( s -- arr<of 1 room > )
  ( rwa for just a single room )
  dup pmatch dup ok? if swap pop
  else pop dup puppet_match dup ok? if swap pop
    else pop "^YELLOW^Could not find " swap strcat "." strcat atell 0 exit then
  then
  dup findable? not if
    "^YELLOW^That player is not findable right now." atell 0 exit then
  require-public? if dup location public? not if
    "^YELLOW^That player is not in a public location." atell 0 exit then then
  dup awake? not if
    "^YELLOW^That player is not awake right now." atell 0 exit then
  location 1 array_make
;
: rwa-online ( -- arr<of rooms> )
  ( The default rwa array, the players online )
  var waArray
  0 array_make waArray !
  online_array foreach swap pop
    location waArray @ array_appenditem waArray !
  repeat
  waArray @ 1 array_nunion 1 array_sort
;
: do-rwa ( s -- )
  ( the main RWA function, sets bools and calls other functions )
  1 isRWA !
  dup not if pop rwa-online rwa-print exit then tolower
  dup "#wf" instr if pop rwa-wf rwa-print exit then
  dup "#all" instr if pop rwa-all rwa-print exit then
  dup "#idle" instr if 1 findIdle ! "" "#idle" subst then
  dup "#unidle" instr if 1 findUnidle ! "" "#unidle" subst then
  dup "#active" instr if 1 findUnidle ! "" "#unidle" subst then
  dup "#ic" instr if 1 findIC ! "" "#ic" subst then
  dup "#ooc" instr if 1 findOOC ! "" "#ooc" subst then
  dup "#afk" instr if 1 findAFK ! "" "#afk" subst then
  dup "#series" instr if "" "#series" subst strip dup findSeries ! then
  findIdle @ not findUnidle @ not and findIC @ not findOOC @ not and and
  findAFK @ not findSeries @ not and and over and
  if rwa-single dup array? not if pop exit then rwa-print exit then pop
  rwa-online rwa-print
;
( **Preference toggles for rooms themselves and #hide** )
: toggle-public ( s -- )
  me @ loc @ controls not if "^RED^You do not own this room." atell exit then
  loc @ PROPS-publicroom? getpropstr "yes" stringcmp not if
    loc @ PROPS-publicroom? remove_prop
    loc @ unparseobj "^YELLOW^" swap strcat " is no longer public." strcat atell
  else
    loc @ PROPS-publicroom? "yes" setprop
    loc @ unparseobj "^GREEN^" swap strcat " is now set public." strcat atell
  then
;
: toggle-private ( s -- )
  me @ loc @ controls not if "^RED^You do not own this room." atell exit then
  prog PROPS-privateroom? getpropstr "no" stringcmp not if
    "^RED^Private Rooms not allowed on this MUCK." atell exit then
  loc @ PROPS-privateroom? getpropstr "yes" stringcmp not if
    loc @ PROPS-privateroom? remove_prop
    loc @ unparseobj "^GREEN^" swap strcat " is no longer private." strcat atell
  else
    loc @ PROPS-privateroom? "yes" setprop
    loc @ unparseobj "^YELLOW^" swap strcat " is now a private room." strcat atell
  then
;
: toggle-room-ooc ( -- )
  me @ loc @ controls not if "^RED^You do not own this room." atell exit then
  loc @ "_prefs/OOC" getpropstr "yes" stringcmp not if
    loc @ "_prefs/ooc" remove_prop
    loc @ unparseobj "^GREEN^" swap strcat " is no longer an OOC room." strcat atell
  else
    loc @ "_prefs/ooc" "yes" setprop
    loc @ unparseobj "^YELLOW^" swap strcat " is now set as being an OOC room." strcat atell
  then
;
: toggle-hidden ( -- )
  prog "_prefs/hidden" getpropstr "yes" stringcmp if
    "^YELLOW^Player hiding is not allowed on this MUCK." atell exit then
  me @ "_prefs/find/hidden" getpropstr "yes" stringcmp not if
    me @ "_prefs/find/hidden" remove_prop
    "^GREEN^You are no longer set hidden." atell
  else
    me @ "_prefs/find/hidden" "yes" setprop
    "^YELLOW^You are now set hidden." atell
  then
;
( **Editors and the help screen and main** )
: do-config ( -- )
  var mchoice ( menu selection variable )
  me @ "WIZARD" flag? not if "^CRIMSON^Permission denied." atell exit then
  begin
    "^PURPLE^ProtoFind 2 Admin Configuration Menu" atell
    "^AQUA^( See 'h' for help on which toggles override player preferences )" atell
    " " .tell
    prog "_prefs/title" getpropstr dup not if pop "No Title" then
    "  [^YELLOW^1^NORMAL^] Title to appear in header: " swap strcat atell
    prog "_prefs/parents" getpropstr "no" stringcmp not if "No" else "Yes" then
    "  [^YELLOW^2^NORMAL^] Show Area Rooms: " swap strcat atell
    prog "_prefs/puppets" getpropstr "yes" stringcmp not if "Yes" else "No" then
    "  [^YELLOW^3^NORMAL^] Include puppets by default: " swap strcat atell
    prog "_prefs/status" getpropstr "yes" stringcmp not if "Yes" else "No" then
    "  [^YELLOW^4^NORMAL^] Show IC/OOC flags by default: " swap strcat atell
    prog "_prefs/hidedark" getpropstr "no" stringcmp not if "No" else "Yes" then
    "  [^YELLOW^5^NORMAL^] Hide characters set DARK or HIDDEN: " swap strcat atell
    prog "_prefs/runparse" getpropstr "no" stringcmp not if "No" else "Yes" then
    "  [^YELLOW^6^NORMAL^] Include room dbrefs for owners/wizards: " swap strcat atell
    prog "_prefs/idletime" getpropstr dup not if pop DefaultIdle intostr then
    "  [^YELLOW^7^NORMAL^] Minutes before considered idle: " swap strcat atell
    prog PROPS-privateroom? getpropstr "no" stringcmp not if "No" else "Yes" then
    "  [^YELLOW^8^NORMAL^] Allow private rooms: " swap strcat atell
    prog "_prefs/publicOnly" getpropstr "yes" stringcmp not if "Yes" else "No" then
    "  [^YELLOW^9^NORMAL^] Require rooms to be set public to be findable: " swap strcat atell
    prog "_prefs/hidden" getpropstr "yes" stringcmp not if "Yes" else "No" then
    " [^YELLOW^10^NORMAL^] Allow players to set themselves hidden: " swap strcat atell
    prog "_prefs/options" getpropstr "no" stringcmp not if "No" else "Yes" then
    " [^YELLOW^11^NORMAL^] Allow players to configure their own settings: " swap strcat atell
    #0 "_/colors/find/frame" getpropstr dup not if pop "NONE" then
    " [^YELLOW^12^NORMAL^] Default frame color: " swap strcat atell
    #0 "_/colors/find/player" getpropstr dup not if pop "NONE" then
    " [^YELLOW^13^NORMAL^] Default player name text color: " swap strcat atell
    #0 "_/colors/find/room" getpropstr dup not if pop "NONE" then
    " [^YELLOW^14^NORMAL^] Default room name text color: " swap strcat atell
    #0 "_/colors/find/parent" getpropstr dup not if pop "NONE" then
    " [^YELLOW^15^NORMAL^] Default parent room text color: " swap strcat atell
    #0 "_/colors/find/time" getpropstr dup not if pop "NONE" then
    " [^YELLOW^16^NORMAL^] Default time colum color: " swap strcat atell
    prog "_prefs/2parents" getpropstr "yes" stringcmp not if "Yes" else "No" then
    " [^YELLOW^17^NORMAL^] Force 2 parents in 'find' printout: " swap strcat atell
    prog "_prefs/rwaparents" getpropstr "yes" stringcmp not if "Yes" else "No" then
    " [^YELLOW^18^NORMAL^] Force parents to be listed in 'rwa' output: " swap strcat atell
    prog "_prefs/idleflag" getpropstr "no" stringcmp not if "No" else "Yes" then
    " [^YELLOW^19^NORMAL^] Check IDLE flag when determining 'idle': " swap strcat atell
    prog "_prefs/parentmode" getpropstr strip dup not if pop "3" then
    " [^YELLOW^20^NORMAL^] Preference for determing Parent Rooms: " swap strcat atell
    " " .tell
    " ^GREEN^[^YELLOW^H^GREEN^]elp on the options." atell
    " ^BLUE^[^YELLOW^Q^BLUE^]uit the configuration menu." atell
    read mchoice !
    mchoice @ "1" stringcmp not if
      "^GREEN^Enter the title to appear in the header, or space for none: " atell read
      strip dup not if pop prog "_prefs/title" remove_prop else
        prog swap "_prefs/title" swap setprop then continue
    then
    mchoice @ "2" stringcmp not if
      prog "_prefs/parents" getpropstr "no" stringcmp not if
        prog "_prefs/parents" remove_prop else
        prog "_prefs/parents" "no" setprop then continue
    then
    mchoice @ "3" stringcmp not if
      prog "_prefs/puppets" getpropstr "yes" stringcmp not if
        prog "_prefs/puppets" remove_prop else
        prog "_prefs/puppets" "yes" setprop then continue
    then
    mchoice @ "4" stringcmp not if
      prog "_prefs/status" getpropstr "yes" stringcmp not if
        prog "_prefs/status" "no" setprop else
        prog "_prefs/status" "yes" setprop then continue
    then
    mchoice @ "5" stringcmp not if
      prog "_prefs/hidedark" getpropstr "no" stringcmp not if
        prog "_prefs/hidedark" remove_prop else
        prog "_prefs/hidedark" "no" setprop then continue
    then
    mchoice @ "6" stringcmp not if
      prog "_prefs/runparse" getpropstr "no" stringcmp not if
        prog "_prefs/runparse" "yes" setprop else
        prog "_prefs/runparse" "no" setprop then continue
    then
    mchoice @ "7" stringcmp not if
      "^GREEN^Enter the number of minutes to be considered idle: " atell read
      dup number? not if pop "^YELLOW^Invalid number." atell continue then
      prog swap "_prefs/idletime" swap setprop continue
    then
    mchoice @ "8" stringcmp not if
      prog PROPS-privateroom? getpropstr "no" stringcmp not if
        prog PROPS-privateroom? remove_prop else
        prog PROPS-privateroom? "no" setprop then continue
    then
    mchoice @ "9" stringcmp not if
      prog "_prefs/publicOnly" getpropstr "yes" stringcmp not if
        prog "_prefs/publicOnly" remove_prop else
        prog "_prefs/publicOnly" "yes" setprop then continue
    then
    mchoice @ "10" stringcmp not if
      prog "_prefs/hidden" getpropstr "yes" stringcmp not if
        prog "_prefs/hidden" remove_prop else
        prog "_prefs/hidden" "yes" setprop then continue
    then
    mchoice @ "11" stringcmp not if
      prog "_prefs/options" getpropstr "no" stringcmp not if
        prog "_prefs/options" remove_prop else
        prog "_prefs/options" "no" setprop then continue
    then
    mchoice @ "12" stringcmp not if
      "Enter default frame color for find, '.' to leave as-is, or a space to clear: "
      .tell read strip dup "." strcmp not if pop continue then
      #0 swap "_/colors/find/frame" swap setprop continue
    then
    mchoice @ "13" strcmp not if
      "Enter default player name color for find, '.' to leave as-is, or a space to clear: "
      .tell read strip dup "." strcmp not if pop continue then
      #0 swap "_/colors/find/player" swap setprop continue
    then
    mchoice @ "14" strcmp not if
      "Enter default room name color for find, '.' to leave as-is, or a space to clear: "
      .tell read strip dup "." strcmp not if pop continue then
      #0 swap "_/colors/find/room" swap setprop continue
    then
    mchoice @ "15" strcmp not if
      "Enter default parent room color for find, '.' to leave as-is, or a space to clear: "
      .tell read strip dup "." strcmp not if pop continue then
      #0 swap "_/colors/find/parent" swap setprop continue
    then
    mchoice @ "16" strcmp not if
      "Enter default time column color for find, '.' to leave as-is, or a space to clear: "
      .tell read strip dup "." strcmp not if pop continue then
      #0 swap "_/colors/find/time" swap setprop continue
    then
    mchoice @ "17" strcmp not if
      prog "_prefs/2parents" getpropstr "yes" stringcmp not if
        prog "_prefs/2parents" "no" setprop else
        prog "_prefs/2parents" "yes" setprop then continue
    then
    mchoice @ "18" strcmp not if
      prog "_prefs/rwaparents" getpropstr "yes" stringcmp not if
        prog "_prefs/rwaparents" "no" setprop else
        prog "_prefs/rwaparents" "yes" setprop then continue
    then
    mchoice @ "19" strcmp not if
      prog "_prefs/idleflag" getpropstr "no" stringcmp not if
        prog "_prefs/idleflag" "yes" setprop else
        prog "_prefs/idleflag" "no" setprop then continue
    then
    mchoice @ "20" strcmp not if
      "^CYAN^Enter a number between 0 and 4 to set how parent rooms are" atell
      "^CYAN^determined, or '.' to leave as: "
      prog "_prefs/parentmode" getpropstr dup not if pop "3" then strcat atell
      "    ^FOREST^0 = The 'location' of the room is always the parent room." atell
      "    ^FOREST^1 = Search only for rooms set PARENT." atell
      "    ^FOREST^2 = Search only for rooms set with the parent room prop." atell
      "    ^FOREST^3 = Search for first PARENT or prop determined parent room." atell
      "    ^FOREST^4 = Allow parent-redirection. See menu 'help' for details." atell
      read strip strip dup "." strcmp not if pop continue then
      dup number? not if pop continue then
      dup atoi dup 4 > swap 0 < or if pop continue then
      prog swap "_prefs/parentmode" swap setprop continue
    then
    mchoice @ "h" stringcmp not if
      "^BLUE^---------------------------------------------------------------------" atell
      "This is just some details on how the option toggles affect the players.  " .tell
      "#1 - Obviously just sets the title in the header for the find printout.  " .tell
      "#2 - Setting this to 'no' will keep players from seeing areas in find.   " .tell
      "     Setting it to 'yes' leaves it up to player preference.              " .tell
      "#3 - This just sets the default setting. Players can still set their own." .tell
      "#4 - This sets the default. Players can still set their own preference.  " .tell
      "#5 - Defaults to 'yes', setting to 'no' prevents all hiding with flags.  " .tell
      "#6 - 'No' prevents it all together. 'Yes' leaves it up to the player.    " .tell
      "#7 - This just sets the default idle time. If not set, defaults to 10.   " .tell
      "#8 - Setting this to 'no' prevents rooms from being set 'private'.       " .tell
      "#9 - Setting this to 'yes' allows only public rooms to show up in find.  " .tell
      "#10- Setting this to 'yes' allows players to use #hide.                  " .tell
      "#11- Setting this to 'no' blocks players from using the '#options' menu. " .tell
      "#12- This is the frame color. Be careful on what you set the defaults to," .tell
      "     as certain color combinations will screw up the format in Pueblo.   " .tell
      "     It is recommended to just leave it as nothing.                      " .tell
      "#13- Same as above, except for the the player names. Same warning applies." .tell
      "#14- Room name color.                                                    " .tell
      "#15- Parent room color.                                                  " .tell
      "#16- Time column color.                                                  " .tell
      "#17- Setting this to 'yes' forces 2 parents to be shown in 'find'.       " .tell
      "#18- Setting this to 'yes' forces 'rwa' to be sorted by parent room.     " .tell
      "#19- Setting this to 'no' makes it so that the IDLE flag is not checked  " .tell
      "     by default.                                                         " .tell
      "#20- This determines the mode used to search for parent rooms.           " .tell
      "     Modes 0 through 3 should be easy to understand. Mode 4 is a bit new." .tell
      "     By putting a '_prefs/parent:<dbref>' prop on a normal room, the     " .tell
      "     dbref becomes the new parent room as long as one of the following   " .tell
      "     apply:                                                              " .tell
      "     The dbref is set = PARENT, the dbref is controled by the room owner," .tell
      "     or the dbref has a lock under _/plok that the owner of the original " .tell
      "     room can pass.                                                      " .tell
      "^FOREST^Type any key and hit enter to continue." atell
      read pop continue
    then
    mchoice @ "q" stringcmp not if "^BLUE^Exiting editor." atell exit then
    "^RED^Invalid command" atell
  repeat
;
: do-options ( -- )
  var mchoice ( holds the choice )
  prog "_prefs/options" getpropstr "no" stringcmp not if
    "^RED^Unable to customize options." atell exit then
  begin
    "^PURPLE^ProtoFind 2 Player Options Menu" atell
    "^CYAN^**Options marked by ^CRIMSON^* ^CYAN^are overridden by admin settings.**" atell
    " " .tell
    me @ "_prefs/find/parents" getpropstr dup not if pop "<Not Set>" else
      "Yes" stringcmp not if "Yes" else "No" then then
    prog "_prefs/parents" getpropstr "no" stringcmp not if
      " ^CRIMSON^*^NORMAL^" else "  " then
    "[^YELLOW^1^NORMAL^] See parent rooms in find: " strcat swap strcat atell
    me @ "_prefs/find/puppets" getpropstr dup not if pop "<Not Set>" else
      "Yes" stringcmp not if "Yes" else "No" then then
    "  [^YELLOW^2^NORMAL^] Have puppets show up in find and rwa by default: "
    swap strcat atell
    me @ "_prefs/find/status" getpropstr dup not if pop "<Not Set>" else
      "Yes" stringcmp not if "Yes" else "No" then then
    "  [^YELLOW^3^NORMAL^] Show IC/OOC/AFK tags in find/rwa: " swap strcat atell
    me @ "_prefs/find/findstats" getpropstr "yes" stringcmp not if "Yes" else "No" then
    "  [^YELLOW^4^NORMAL^] Include summary stats in footer: " swap strcat atell
    me @ "_prefs/find/runparse" getpropstr dup not if pop "<Not Set>" else
      "Yes" stringcmp not if "Yes" else "No" then then
    prog "_prefs/runparse" getpropstr "no" stringcmp not if
      " ^CRIMSON^*^NORMAL^" else "  " then
    "[^YELLOW^5^NORMAL^] Show room dbrefs of rooms you own: " strcat swap strcat atell
    me @ "_prefs/find/idletime" getpropstr dup not if pop "<Not Set>" then
    "  [^YELLOW^6^NORMAL^] The time before a player is considered idle: " swap strcat atell
    me @ "_prefs/find/sort" getpropstr "yes" stringcmp not if "Yes" else "No" then
    "  [^YELLOW^7^NORMAL^] Sort the find listing: " swap strcat atell
    me @ "_prefs/find/timestamp" getpropstr "yes" stringcmp not if "Yes" else "No" then
    "  [^YELLOW^8^NORMAL^] Timestamp in the footer: " swap strcat atell
    me @ "_prefs/find/findfmt" getpropstr
    dup "oldfind" stringcmp not if pop "Old Standard Find" else
      dup "tfind" stringcmp not if pop "Time-Find Format" else
        pop "Standard Find" then then
    "  [^YELLOW^9^NORMAL^] Default find format: " swap strcat atell
    me @ "_prefs/find/deffilter" getpropstr dup not if pop "<None Set>" then
    " [^YELLOW^10^NORMAL^] Default filter to be applied to 'find': " swap strcat atell
    me @ "_prefs/find/2parents" getpropstr "yes" stringcmp not if "Yes" else "No" then
    prog "_prefs/2parents" getpropstr "yes" stringcmp not if
      "^CRIMSON^*^NORMAL^" else " " then
    "[^YELLOW^11^NORMAL^] See 2 levels of parent rooms in find: " strcat swap strcat atell
    me @ "_prefs/find/rwaparents" getpropstr "yes" stringcmp not if "Yes" else "No" then
    prog "_prefs/rwaparents" getpropstr "yes" stringcmp not if
      "^CRIMSON^*^NORMAL^" else " " then
    "[^YELLOW^12^NORMAL^] Have 'rwa' format sorted by parent rooms: " strcat swap strcat atell
    me @ "_/colors/find/frame" getpropstr dup not if pop "NONE" then
    " [^YELLOW^13^NORMAL^] Preferred color for the find frames and tables: " swap strcat atell
    me @ "_/colors/find/player" getpropstr dup not if pop "NONE" then
    " [^YELLOW^14^NORMAL^] Preferred color for player name output: " swap strcat atell
    me @ "_/colors/find/room" getpropstr dup not if pop "NONE" then
    " [^YELLOW^15^NORMAL^] Preferred color room names: " swap strcat atell
    me @ "_/colors/find/parent" getpropstr dup not if pop "NONE" then
    " [^YELLOW^16^NORMAL^] Preferred color for parent rooms: " swap strcat atell
    me @ "_/colors/find/time" getpropstr dup not if pop "NONE" then
    " [^YELLOW^17^NORMAL^] Preferred color for time columns: " swap strcat atell
    me @ "_prefs/find/idleflag" getpropstr strip dup not if pop "<None Set>" then
    " [^YELLOW^18^NORMAL^] Check for IDLE flag when determing 'idle': "
    swap strcat atell
    prog "_prefs/hidden" getpropstr "yes" stringcmp not if
      me @ "_prefs/find/hidden" getpropstr "yes" stringcmp not if "Yes" else "No" then
      " [^YELLOW^19^NORMAL^] Currently hidden: " swap strcat atell
    then
    " " .tell
    " ^GREEN^[^YELLOW^H^GREEN^]elp on the options." atell
    " ^BLUE^[^YELLOW^Q^BLUE^]uit the options menu." atell
    read mchoice !
    mchoice @ "1" stringcmp not if
      me @ "_prefs/find/parents" getpropstr "no" stringcmp not if
        me @ "_prefs/find/parents" "yes" setprop else
        me @ "_prefs/find/parents" "no" setprop then continue
    then
    mchoice @ "2" stringcmp not if
      me @ "_prefs/find/puppets" getpropstr "yes" stringcmp not if
        me @ "_prefs/find/puppets" "no" setprop else
        me @ "_prefs/find/puppets" "yes" setprop then continue
    then
    mchoice @ "3" stringcmp not if
      me @ "_prefs/find/status" getpropstr "yes" stringcmp not if
        me @ "_prefs/find/status" "no" setprop else
        me @ "_prefs/find/status" "yes" setprop then continue
    then
    mchoice @ "4" stringcmp not if
      me @ "_prefs/find/findstats" getpropstr "yes" stringcmp not if
        me @ "_prefs/find/findstats" "no" setprop else
        me @ "_prefs/find/findstats" "yes" setprop then continue
    then
    mchoice @ "5" stringcmp not if
      me @ "_prefs/find/runparse" getpropstr "no" stringcmp not if
        me @ "_prefs/find/runparse" "yes" setprop else
        me @ "_prefs/find/runparse" "no" setprop then continue
    then
    mchoice @ "6" stringcmp not if
      "^GREEN^Enter the time before players are considered idle: " atell read
      dup number? not if pop "^YELLOW^Invalid number." atell continue then
      me @ swap "_prefs/find/idletime" swap setprop continue
    then
    mchoice @ "7" stringcmp not if
      me @ "_prefs/find/sort" getpropstr "yes" stringcmp not if
        me @ "_prefs/find/sort" remove_prop else
        me @ "_prefs/find/sort" "yes" setprop then continue
    then
    mchoice @ "8" strcmp not if
      me @ "_prefs/find/timestamp" getpropstr "yes" stringcmp not if
        me @ "_prefs/find/timestamp" "no" setprop else
        me @ "_prefs/find/timestamp" "yes" setprop then continue
    then
    mchoice @ "9" stringcmp not if
      "^GREEN^Enter the default format you want for find or space for standard:" atell
      "Choices are: 'oldfind' or 'tfind'" .tell
      me @ "_prefs/find/findfmt" read strip setprop continue
    then
    mchoice @ "10" strcmp not if
      "^GREEN^Enter the default filters you want applied to your 'find' output:"     atell
      "^GREEN^A '.' will leave it as-is, and a space will clear it."                 atell
      "Choices are: 'wf', 'all', 'unidle', 'idle', 'ic', 'ooc', 'afk', and 'series'" .tell
      "^YELLOW^Realize that certain combinations may cause undesireable affects."    atell
      "    ^YELLOW^such as 'idle' and 'unidle' being used together." atell
      "    ^YELLOW^So sticking to just one is advisable. Also, if you use the"       atell
      "    ^YELLOW^series option, place an '=' followed by the keyword you"          atell
      "    ^YELLOW^want to search for. Eg: 'series=last blade'"                      atell
      read strip dup "." strcmp not if pop continue then
      me @ swap "_prefs/find/deffilter" swap setprop continue
    then
    mchoice @ "11" strcmp not if
      me @ "_prefs/find/2parents" getpropstr "yes" stringcmp not if
        me @ "_prefs/find/2parents" "no" setprop else
        me @ "_prefs/find/2parents" "yes" setprop then continue
    then
    mchoice @ "12" strcmp not if
      me @ "_prefs/find/rwaparents" getpropstr "yes" stringcmp not if
        me @ "_prefs/find/rwaparents" "no" setprop else
        me @ "_prefs/find/rwaparents" "yes" setprop then continue
    then
    mchoice @ "13" strcmp not if
      "^GREEN^Enter your preferred color for the frame, '.' to leave as is, or a space to clear: "
      atell me @ "PUEBLO" flag? if
        "^WHITE^Note that certain color combinations will cause problems in Pueblo."
        atell
      then
      read strip dup "." strcmp not if pop continue then
      me @ swap "_/colors/find/frame" swap setprop continue
    then
    mchoice @ "14" strcmp not if
      "^GREEN^Enter your preferred color for the players, '.' to leave as is, or a space to clear: "
      atell me @ "PUEBLO" flag? if
        "^WHITE^Note that certain color combinations will cause problems in Pueblo."
        atell
      then
      read strip dup "." strcmp not if pop continue then
      me @ swap "_/colors/find/player" swap setprop continue
    then
    mchoice @ "15" strcmp not if
      "^GREEN^Enter your preferred color for rooms, '.' to leave as is, or a space to clear: "
      atell me @ "PUEBLO" flag? if
        "^WHITE^Note that certain color combinations will cause problems in Pueblo."
        atell
      then
      read strip dup "." strcmp not if pop continue then
      me @ swap "_/colors/find/room" swap setprop continue
    then
    mchoice @ "16" strcmp not if
      "^GREEN^Enter your preferred color parent rooms, '.' to leave as is, or a space to clear: "
      atell me @ "PUEBLO" flag? if
        "^WHITE^Note that certain color combinations will cause problems in Pueblo."
        atell
      then
      read strip dup "." strcmp not if pop continue then
      me @ swap "_/colors/find/parent" swap setprop continue
    then
    mchoice @ "17" strcmp not if
      "^GREEN^Enter your preferred color for the times, '.' to leave as is, or a space to clear: "
      atell me @ "PUEBLO" flag? if
        "^WHITE^Note that certain color combinations will cause problems in Pueblo."
        atell
      then
      read strip dup "." strcmp not if pop continue then
      me @ swap "_/colors/find/time" swap setprop continue
    then
    mchoice @ "18" strcmp not if
      me @ "_prefs/find/idleflag" getpropstr "no" stringcmp not if
        me @ "_prefs/find/idleflag" "yes" setprop else
        me @ "_prefs/find/idleflag" "no" setprop then continue
    then
    prog "_prefs/hidden" getpropstr "yes" stringcmp not if
      mchoice @ "19" strcmp not if
        me @ "_prefs/find/hidden" getpropstr "yes" stringcmp not if
          me @ "_prefs/find/hidden" "no" setprop else
          me @ "_prefs/find/hidden" "yes" setprop then continue
      then
    then
    mchoice @ "h" stringcmp not if
      "^BLUE^---------------------------------------------------------------------" atell
      "This is just some notes on the options of the find #options menu.          " .tell
      "#1 -Turns off parent rooms. Admin may have disabled your choice on this.   " .tell
      "#2 -If 'no', use 'prwa' and 'pfind' to include puppets.                    " .tell
      "#3 -Show IC/OOC/AFK tags in the standard find and rwa printout.            " .tell
      "#4 -Include summary info in the footer.                                    " .tell
      "#5 -Show dbrefs of rooms you own. May have been disabled by admin.         " .tell
      "#6 -How many minutes you want a player to be idle before considered 'idle.'" .tell
      "#7 -Do you want the 'find' print out to be sorted alphabetically?          " .tell
      "#8 -Would you like a timestamp in the footer?                              " .tell
      "#9 -This is the default find format you prefer to see when typing 'find'.  " .tell
      "#10-Filters you want applied to your find search. Realize that when you use" .tell
      "    these filters, they make it so that it is what you -get-, not what gets" .tell
      "    removed. So setting a filter of 'ic' will make it so that only IC      " .tell
      "    players get listed. 'unidle' and 'ic' will only list unidle IC players." .tell
      "#11-If admin have turned on 2 parent room display, you don't have a choice." .tell
      "#12-If admin have turned on 'rwa' parenting, you don't have a choice.      " .tell
      "#13-Frame color. Pueblo users should be wary of using certain colors.      " .tell
      "#14-Player name color. Same warning applies to Pueblo users.               " .tell
      "#15-Room name color. Same warning applies...                               " .tell
      "#16-Parent room color. You're STILL using Pueblo!?                         " .tell
      "#17-Time column color. See above.                                          " .tell
      "#18-If set to 'yes', players that have the IDLE flag will be listed as idle" .tell
      "    even if their IDLE time might be less than the value in #6.            " .tell
      prog "_prefs/hidden" getpropstr "yes" stringcmp not if
      "#19-Set yourself hidden on 'find' so that you are not findable.            " .tell
      then
      "^FOREST^Type any key and hit enter to continue." atell read pop continue
    then
    mchoice @ "q" stringcmp not if "^BLUE^Exiting editor." atell exit then
    "^RED^Invalid command" atell
  repeat
;
: do-help
"^BLUE^-----------------------------------------------------------" atell
"^BLUE^- = - = - = ^WHITE^ProtoFind 2 By Akari@Distant Shores ^BLUE^= - = - = -" atell
"^BLUE^-----------------------------------------------------------" atell
 " " .tell
 "  find - Runs your default find check.                           " .tell
 "  find <name> - To find a single player.                          " .tell
 "  rwa  - The 'whereat' format.                                   " .tell
 "  rwa <name> - 'Whereat' on a single room.                       " .tell
 " " .tell
 "  rwa/find #series <series> - To search for only that series on. " .tell
 "  rwa/find #wf - To thin the list down to people in your WF list." .tell
 "  rwa/find #ic/#ooc/#afk - To only list players with that status." .tell
 "  rwa/find #idle/#unidle - To only see idle or unidle players.   " .tell
 "  rwa/find #all - To list every single player on the MUCK.       " .tell
 "  find #oocroom - Set a room as being OOC. Causes all players in " .tell
 "                  it to automatically be listed as OOC.          " .tell
 "  find #public/#private - To toggle room preferences.     " .tell
 prog "_prefs/hidden" getpropstr "yes" stringcmp not if
 "  find #hide - To set or unset yourself hidden.                  " .tell
 then
 "                                                                 " .tell
 "  find #options - To change your find display options.           " .tell
 me @ "WIZARD" flag? if
 "  find #config - To change the global configuration for the MUCK." .tell
 then
 " Player flags: Z - sleeping; * - Puppet; E - Editor; I - Idle    " .tell
 " Room flags: + - Public; - - Private                             " .tell
 " The parent room prop is: " ParentRoomProp ":yes" strcat strcat    .tell
 "^YELLOW^~Done~" atell
;
: main ( s -- )
 ( Our main! Not much happens here, actually )
(  #0 "/_/Colors/Find" PropDir? not if )
     #0 "/_/Colors/Find/Room" FIND-colors_room setprop
     #0 "/_/Colors/Find/Frame" FIND-colors_frame setprop
     #0 "/_/Colors/Find/Player" FIND-colors_player setprop
     #0 "/_/Colors/Find/Parent" FIND-colors_parents setprop
     #0 "/_/Colors/Find/Time" FIND-colors_time setprop
(  then )
  me @ "PUEBLO" flag? if
    me @ "_/colors/find/room" getpropstr not if
      me @ "_/colors/find/room" "WHITE" setprop then
    me @ "_/colors/find/frame" getpropstr not if
      me @ "_/colors/find/frame" "BLUE" setprop then
    me @ "_/colors/find/player" getpropstr not if
      me @ "_/colors/find/player" "WHITE" setprop then
    me @ "_/colors/find/parent" getpropstr not if
      me @ "_/colors/find/parent" "WHITE" setprop then
    me @ "_/colors/find/time" getpropstr not if
      me @ "_/colors/find/time" "WHITE" setprop then
  then
  strip dup not if
    command @ "find" instring if do-find exit then
    command @ "wa" instring if do-rwa exit then
    command @ "where" instring if do-rwa exit then
    do-find exit
  then
  dup "#help" stringpfx if pop do-help exit then
  dup "#config" stringpfx if pop do-config exit then
  dup "#options" stringpfx if pop do-options exit then
  dup "#public" stringpfx if pop toggle-public exit then
  dup "#private" stringpfx if pop toggle-private exit then
  dup "#oocroom" stringpfx if pop toggle-room-ooc exit then
  dup "#hide" stringpfx if pop toggle-hidden exit then
  command @ "find" instring if do-find exit then
  command @ "wa" instring if do-rwa exit then
  command @ "where" instring if do-rwa exit then
  do-find
;
WIZCALL do-options
