( @Paste 3.52 By Akari                                              )
(                  Nakoruru08@hotmail.com                           )
( Version 1.0  - By crysaliq                                        )
( Version 2.0  - By Deedlit                                         )
( Version 3.0  - By Akari, completed 6/29/00                        )
( Version 3.1  - By Akari, completed 1/15/01                        )
( Version 3.5  - By Akari, completed 2/01/01                        )
( Version 3.51 - By Akari, completed 3/13/01                        )
( VErsion 3.52 - By Moose, completed 1/07/03                        )
(                                                                   )
( Paste-1.0 introduced the idea of @paste, allowed remote @pastes,  )
(           pastes to rooms if owned, and paste #on/#off.           )
( Paste-2.0 worked lsedit support into @paste, though removed room  )
(           pasting, added pasting to puppets.                      )
( Paste-3.0 re-added room and remote-room pasting. Added several    )
(           more preferences and restrictions such as blocking      )
(           pastes in rooms, blocking remote pastes, wizzes banning )
(           players from using paste, and others, removed           )
(           room-ownership requirement for room-pasting,            )
(           added multi-player pasting, message footers to identify )
(           who the paste was sent to, and ANSI color.              )
( Paste-3.1 Nothing major. Mostly just minor bug fixes and changes  )
(           in information outputted. These changes have been made  )
(           over time, I just decided to finally make the version   )
(           change official.                                        )
( Paste-3.5 Changed the input and output routines to use arrays in  )
(           place of a temp prop list. Much cleaner this way, but it)
(           requires the array version of lib-editor by Van now.    )
( Paste-3.51 Added respect for p #ignore due to repeated abuses.    )
( Paste-3.52 Added support for $lib/standard                        )
(                                                                   )
( Paste3 is a ProtoMUCK exclusive only. It is not intended to work  )
( on any other MUCK server. For information regarding ProtoMUCK, see)
( http://protomuck.sourceforge.net/                                 )
$version 3.52
( ** Change the following value to 0 if you do not want to allow    )
(    players to @paste remotely to rooms they do not own. **        )
$def allow_remote PASTE_allow_remote?
(**Program include**)
$include $lib/standard
$include $lib/editor
$include $lib/page
(**Program $def**)
$def atell me @ swap ansi_notify
(**Program's variables**)
lvar target ( dbref that is being pasted to, either room or player )
lvar numlines ( Counts the # of lines. )
lvar is_room? ( 1 if target is a room, otherwise 0 )
lvar exclude_list ( array containing dbrefs not to @paste to )
lvar count ( used to print back the lists )
lvar temp ( lazy programmer's tool, used in the printout-loops )
lvar message ( An array that stores the @paste message )
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
: unparse-names ( x -- s, x may be d or a )
  dup dbref? if name exit then
  dup array? if
    "" swap foreach
      swap pop name strcat " " strcat
  repeat strip exit
  then
;
: see-pastes? ( d -- i, 1 for yes, 0 for no )
  dup "_prefs/paste_ok" getpropstr "no" stringcmp
  over "h" flag? not and
  over "_prefs/paste/" me @ owner intostr strcat getpropstr not and
  swap ignored? not and
;
: see-room-pastes? ( d -- i, 1 for yes, 0 for no )
  "_prefs/room_pastes" getpropstr "no" stringcmp
;
: room-paste? ( d -- i, 1 for yes, 0 for no )
  dup "_prefs/room_pastes" getpropstr "no" stringcmp
  swap "h" flag? not and
;
: remote-paste? ( d -- i, 1 for yes, 0 for no )
  dup "_prefs/room_pastes" getpropstr "no" stringcmp
  over "h" flag? not and
  swap "_prefs/remote_pastes" getpropstr "no" stringcmp and
;
: paste-off ( -- )
  me @ "_prefs/paste_ok" "no" setprop
  "^RED^Non-wizzes will not be able to @paste to you." atell
;
: paste-on ( -- )
  me @ "_prefs/paste_ok" "yes" setprop
  "^GREEN^You will now see @paste messages." atell
;
: seeroom-toggle ( -- )
  me @ "_prefs/room_pastes" getpropstr "no" stringcmp not if
    me @ "_prefs/room_pastes" "yes" setprop
    "^GREEN^You will now see room-pastes." atell
  else
    me @ "_prefs/room_pastes" "no" setprop
    "^RED^You will no longer see room-pastes." atell
  then
;
: room-toggle ( -- )
  me @ loc @ controls if
    loc @ "_prefs/room_pastes" getpropstr "no" stringcmp not if
      loc @ "_prefs/room_pastes" "yes" setprop
      "^GREEN^" loc @ unparseobj strcat " accepts room-pastes." strcat atell
    else
      loc @ "_prefs/room_pastes" "no" setprop
      "^RED^" loc @ unparseobj strcat " is blocked for room-pasting." strcat atell
    then
  else
    "^RED^Permission denied." atell
  then
;
: remote-toggle ( -- )
  me @ loc @ controls if
    loc @ "_prefs/remote_pastes" getpropstr "no" stringcmp not if
      loc @ "_prefs/remote_pastes" "yes" setprop
      "^GREEN^" loc @ unparseobj strcat " accepts remote-pastes." strcat atell
    else
      loc @ "_prefs/remote_pastes" "no" setprop
      "^RED^" loc @ unparseobj strcat " is blocked for remote-pasting."
      strcat atell
    then
  else
    "^RED^Permission denied." atell
  then
;
: block-player ( s -- )
  pmatch dup not if pop "^YELLOW^Could not find that player." atell exit then
  me @ over "_prefs/paste/" swap intostr strcat "blocked" setprop
  "^RED^" swap name strcat " now blocked from pasting to you." strcat atell
;
: unblock-player ( s -- )
  pmatch dup not if pop "^YELLOW^Could not find that player." atell exit then
  me @ over "_prefs/paste/" swap intostr strcat remove_prop
  "^GREEN^" swap name strcat " can now paste to you." strcat atell
;
: ban-player ( s -- )
  pmatch dup not if pop "^YELLOW^Could not find that player." atell exit then
  dup "@prefs/can_paste" "no" setprop
  name "^RED^" swap strcat " can no longer @paste to players." strcat atell
;
: unban-player ( s -- )
  pmatch dup not if pop "^YELLOW^Could not find that player." atell exit then
  dup "@prefs/can_paste" remove_prop
  name "^GREEN^" swap strcat " can now @paste to players." strcat atell
;
: multi-paste ( s1 .. sn -- a, returns array of valid dbrefs )
  0 array_make
  begin depth 1 > while
    swap pmatch dup ok? if
      dup see-pastes? if
        swap array_appenditem
      else name "^RED^" swap strcat " is not accepting pastes." strcat atell
      then
    else pop
    then
  repeat
;
: get-target ( s -- d or a, single dbref or array, or #-1 )
  me @ "@prefs/can_paste" getpropstr "no" stringcmp not if
    "^RED^You have been banned from @pasting." atell #-1 exit
  then
  0 is_room? !
  " " explode 1 > if multi-paste exit then
  dup pmatch dup not if
    pop match else swap pop
  then
  dup not if "^YELLOW^Could not find that." atell #-1 exit then
  dup player? if
    me @ "WIZARD" flag? if exit then
    dup see-pastes? not if
      name "^RED^" swap strcat " is not receiving @pastes."
      strcat atell #-1 exit
    else exit
    then
  then
  dup room? if
    1 is_room? !
    me @ "WIZARD" flag? if exit then
    dup me @ location dbcmp if
      dup room-paste? not if pop
        "^RED^Room pasting blocked in this room." atell #-1 exit
      else exit
      then
    then
    me @ over controls if
      exit
    else
      allow_remote not if pop
        "^RED^Cannot remote paste to unowned rooms." atell
      else
        dup remote-paste? not if pop
          "^RED^That room is blocked from remote pasting." atell #-1 exit
        else exit
        then
      then
    then
  then
  pop "^YELLOW^Cannot @paste to that." atell #-1
;
: get-excludes ( d -- a, returns array of blocked players. )
  0 array_make swap contents
  begin dup while
    dup see-pastes? not if swap over swap array_appenditem swap next continue then
    dup see-room-pastes? not if swap over swap array_appenditem swap next continue then
    next
  repeat pop exclude_list !
;
: player-notify ( d -- )
  0 count !
  dup temp !
  "<^WHITE^Paste from " me @ name strcat "^BLUE^>" strcat 1 parse_ansi
  dup ansi_strlen 75 swap - 2 / "" "-" rot strlenset swap strcat
  "-" 75 strlenset "^BLUE^" swap strcat
  ansi_notify
  message @ foreach swap pop temp @ swap notify repeat
  temp @
  "<^WHITE^Paste to " target @ unparse-names strcat "^GREEN^>" strcat 1 parse_ansi
  dup ansi_strlen 75 < if
    dup ansi_strlen 75 swap - 2 / "" "-" rot strlenset swap strcat
    "-" 75 strlenset "^GREEN^" swap strcat
  else "^GREEN^" swap strcat
  then
  ansi_notify
;
: room-notify ( -- )
  0 count !
  target @ exclude_list @ array_vals
  "<^WHITE^Paste from " me @ name strcat "^BLUE^>" strcat 1 parse_ansi
  dup ansi_strlen 75 swap - 2 / "" "-" rot strlenset swap strcat
  "-" 75 strlenset "^BLUE^" swap strcat
  ansi_notify_exclude
  message @ foreach swap pop
    target @ exclude_list @ array_vals depth rotate notify_exclude
  repeat
  target @ exclude_list @ array_vals
  "<^WHITE^Paste to " target @ name strcat "^GREEN^>" strcat 1 parse_ansi
  dup ansi_strlen 75 < if
    dup ansi_strlen 75 swap - 2 / "" "-" rot strlenset swap strcat
    "-" 75 strlenset "^GREEN^" swap strcat
  else "^GREEN^" swap strcat
  then
  ansi_notify_exclude
;
: multi-notify ( -- )
  target @
  foreach
    swap pop player-notify
  repeat
;
: get-oldpastelist ( -- , affixes the list to the prog under user dir )
  "^CPURPLE^Pasting to: ^PURPLE^" target @ unparse-names strcat atell
  "^CCYAN^--> Enter a period by itself to send the paste. <--" atell
  "^CGREEN^<<Paste list beginning..>>" atell
  0 array_make message !
  begin
    read dup "." strcmp not if pop break then
    message @ array_appenditem message !
  repeat
  "^GREEN^Paste Complete. Sending ^YELLOW^" message @ array_count intostr strcat
  " ^GREEN^lines..." strcat atell
;
: old-paste
  get-oldpastelist
  message @ array_count 0 = if "^BLUE^Empty paste. Cancelled." atell exit then
  BACKGROUND
  target @ dbref? if
    target @ room? if target @ get-excludes room-notify exit then
    target @ player? if target @ player-notify exit then
  then
  target @ array? if multi-notify exit then
  "Invalid target type?" abort
;
: new-paste
  "^CPURPLE^Pasting to: ^PURPLE^" target @ unparse-names strcat atell
  "^CCYAN^<Enter the text that you want sent. '.h' for list editor help.>" atell
  "^CCYAN^< .end/.done to send, .abort to abort >" atell
  0 array_make dup 1 ".i" 1 ArrayEDITORloop
  "abort" stringcmp not if "^RED^<Aborted. No paste sent.>" atell exit then
  3 popn message !
  message @ array_count 0 = if
    "^BLUE^Empty buffer, cancelling paste." atell exit then
  "^GREEN^Paste Complete. Sending ^YELLOW^" message @ array_count intostr strcat
  " ^GREEN^lines..." strcat atell
  target @ dbref? if
    target @ room? if target @ get-excludes room-notify exit then
    target @ player? if target @ player-notify exit then
  then
  target @ array? if multi-notify exit then
  "Invalid target type?" abort
;
: do-help
"^BLUE^-----------------------------------------------------------" atell
"^BLUE^- = - = - = ^WHITE^@Paste 3.5  By Akari@Distant Shores^BLUE^ = - = - = -" atell
"^BLUE^-----------------------------------------------------------" atell
"@paste is designed to allow players to send text to each other   " .tell
"without being limited to sending them via page, spoof, or say.   " .tell
"There are two versions supported in this program, non-lsedit and " .tell
"lsedit-supported. This version of paste allows for pasting to    " .tell
"single players, multiple players, and rooms.                     " .tell
"                                                                 " .tell
" @paste <name(s)> - To paste a message to players.               " .tell
" @paste dbref#    - To paste to a room remotely if allowed.      " .tell
" @paste #oldpaste - To use the non-lsedit version of @paste.     " .tell
" @paste #lsedit   - To use the lsedit version of @paste.         " .tell
" @paste #off      - To disable receiving any @pastes.            " .tell
" @paste #on       - To enable seeing @pastes.                    " .tell
" @paste #seeroom  - To toggle receiving room-pastes.             " .tell
" @paste #room     - To toggle allowing pastes in a room.         " .tell
" @paste #remote   - To prevent remote pastes into a room.        " .tell
" @paste #block <name> - To block a player from @pasting to you.  " .tell
" @paste #unblock <name> - To allow that player to @paste to you. " .tell
" @paste will not paste to players or rooms set = H.              " .tell
me @ "WIZARD" flag? if
"                         *Wiz-Only*                              " .tell
" @paste #ban <name>   - To ban that player from using @paste.    " .tell
" @paste #unban <name> - To allow that player to use @paste again." .tell
then
"^YELLOW^~Done~" atell
;
: main
  strip
  dup "" strcmp not if pop "here" then
  dup "#off" instring if
    paste-off exit
  then
  dup "#on" instring if
    paste-on exit
  then
  dup "#seeroom" instring if
    seeroom-toggle exit
  then
  dup "#room" instring if
    room-toggle exit
  then
  dup "#remote" instring if
    remote-toggle exit
  then
  dup "#block" instring if
    " " "=" subst " " explode 2 = not if
      depth popn "^YELLOW^Enter player to block: " atell read
    else pop
    then
    block-player exit
  then
  dup "#unblock" instring if
    " " "=" subst " " explode 2 = not if
      depth popn "^GREEN^Enter player to unblock: " atell read
    else pop
    then
    unblock-player exit
  then
  dup "#ban" instring if
    me @ "WIZARD" flag? not if "^RED^Wiz-Only." atell exit then
    " " "=" subst " " explode 2 = not if
      depth popn "^YELLOW^Enter player to ban: " atell read
    else pop
    then
    ban-player exit
  then
  dup "#unban" instring if
    me @ "WIZARD" flag? not if "^RED^Wiz-Only." atell exit then
    " " "=" subst " " explode 2 = not if
      depth popn "^GREEN^Enter player to unban: " atell read
    else pop
    then
    unban-player exit
  then
  dup "#oldpaste" instring if
    me @ "_prefs/oldpaste" "yes" setprop
    "^GREEN^You will now use the non-lsedit version of @paste." atell exit
  then
  dup "#newpaste" instring over "#lsedit" instring or if
    me @ "_prefs/oldpaste" remove_prop
    "^GREEN^You will now use the lsedit version of @paste." atell exit
  then
  dup "#help" instring if
    do-help exit
  then
  get-target dup not if exit then
  target !
  prog "paste/" me @ name strcat remove_prop
  me @ "_prefs/oldpaste" getpropstr "yes" stringcmp not if
    old-paste
  else
    new-paste
  then
;
