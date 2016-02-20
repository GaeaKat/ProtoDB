(*
   Lib-Fakes v1.13 [Proto Version]
   Author: Chris Brine [Moose/Van]
   Demands ProtoMUCK v1.50 or newer.
 
   v1.12-v1.13: [ Akari ]
    - Cleaned up the code to 80 colums and added new directives and notes.
   v1.11-v1.12:
    - Fixed a bug for if a puppet was looking at a room.  Fake-controls
      will now get the owner of the dbref passed to it instead of
      demanding a player only.
    - Whoops. Fake descs didn't parse MPI and MUF @$ stuff. It does now.
   v1.10-v1.11:
    - Made FAKE-RMATCH return { #-2 } as a one item array if there are
      multiple part-matches, as it should return some sort of an ambiguous
      match.
    - Added FAKE-OWNER and FAKE-REMOVE_PROP
   v1.00-v1.10:
    - Many, many bug fixes.  All of the prims are now stable
    - Added FAKE-LOCATION, FAKE-GETPROPSTR, FAKE-GETPROPVAL, FAKE-GETPROPFVAL,
      and FAKE-VISIBLE?
    - FAKE-OK? [and others] now work with any fake object that exists, not just
      the visible ones.
    - FAKE-VISIBLE? will check if an existing fake object is visible or not.
   To do:
    - Add in smart descriptions for fake objects [for when looking at them]
    - Add lsedit description support for fake objects [for when looking at them]
 
   Functions:
       :FAKE-ANSINAME[ arr:ARRfakeobj -- str:STRname ]
       :FAKE-HTMLNAME[ ref:REFplyr arr:ARRfakeobj -- str:STRname ]
       :FAKE-UNPARSE[ arr:ARRfakeobj -- str:STRname ]
       :FAKE-NEARBY?[ ref:REFplyr arr:ARRfakeobj -- int:BOLnear? ]
       :FAKE-CONTROLS[ ref:REFplyr arr:ARRfakeobj -- int:BOLcontrols? ]
       :FAKE-NAME[ arr:ARRfakeobj -- str:STRname ]
       :FAKE-DONAME[ ref:REFplyr arr:ARRfakeobj -- str:STRname ]
       :FAKE-LOCATION[ arr:ARRfakeobj -- ref:REFlocation ]
       :FAKE-OWNER[ arr:ARRfakeobj -- ref:REFowner ]
       :FAKE-LOOK[ arr:ARRfakeobj -- ]
       :FAKE-NEW[ ref:REFplyr ref:ObjLoc str:STRname -- arr:ARRfakeobj ]
       :FAKE-RECYCLE[ arr:ARRfakeobj -- ]
       :FAKE-SETPROP[ arr:ARRfakeobj str:STRprop Prop -- ]
       :FAKE-REMOVE_PROP[ arr:ARRfakeobj str:STRprop -- ]
       :FAKE-GETPROP[ arr:ARRfakeobj str:STRprop -- Prop ]
       :FAKE-GETPROPSTR[ arr:ARRfakeobj str:STRprop -- str:STRprop ]
       :FAKE-GETPROPVAL[ arr:ARRfakeobj str:STRprop -- int:INTprop ]
       :FAKE-GETPROPFVAL[ arr:ARRfakeobj str:STRprop -- float:FLTprop ]
       :FAKE-PROPDIR?[ arr:ARRfakeobj str:STRprop -- int:BOLdir? ]
       :FAKE-NEXTPROP[ arr:ARRfakeobj str:STRprop -- str:STRnext ]
       :FAKE-OK?[ ARRfakeobj -- int:BOLfake? ]
       :FAKE-MATCH[ str:STRname -- arr:ARRfakeobj ]
       :FAKE-RMATCH[ ref:ObjLoc str:STRname -- arr:ARRfakeobj ]
       :FAKE-GETFAKES[ ref:ObjLoc -- arr:ARRfakes ]
       :FAKE-DIR[ -- str:STRdir ]
       :FAKE-VISIBLE?[ arr:ARRfakeobj -- int:BOLvisible? ]
   They do the obvious. :>
*)
 
$author      Moose
$lib-version 1.13
 
$include $Lib/Look
 
$def FAKE-DIR "/_Fake/"
 
: FAKE-OK?[ ARRfakeobj -- int:BOLfake? ]
   ARRfakeobj @ array? not if
      0 exit
   then
   ARRfakeobj @ array_count not if
      0 exit
   then
   ARRfakeobj @ 0 array_getitem ok? not if
      0 exit
   then
   ARRfakeobj @ 1 array_Getitem strip not if
      0 exit
   then
   1
;
 
: FAKE-VISIBLE?[ arr:ARRfakeobj -- int:BOLvisible? ]
   ARRfakeobj @ FAKE-OK? not if
      0 exit
   then
   ARRfakeobj @ array_vals pop FAKE-DIR swap strcat over over
   "/@Ok?" strcat getpropstr "yes" stringcmp not
   3 pick 3 pick "/Ok?" strcat getpropstr "yes" stringcmp not or
   rot rot "/Show" strcat getpropstr "yes" stringcmp not or
;
 
: FAKE-GETPROP[ arr:ARRfakeobj str:STRprop -- Prop ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-GETPROP: Invalid fake object." abort
   then
   STRprop @ strip dup STRprop ! not if
      "FAKE-GETPROP: Invalid string." abort
   then
   ARRfakeobj @ array_vals pop FAKE-DIR swap strcat "/" strcat
   STRprop @ strcat getprop
;
 
: FAKE-GETPROPSTR[ arr:ARRfakeobj str:STRprop -- str:STRprop ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-GETPROP: Invalid fake object." abort
   then
   STRprop @ strip dup STRprop ! not if
      "FAKE-GETPROP: Invalid string." abort
   then
   ARRfakeobj @ array_vals pop FAKE-DIR swap strcat "/" strcat
   STRprop @ strcat getpropstr
;
 
: FAKE-GETPROPVAL[ arr:ARRfakeobj str:STRprop -- int:INTprop ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-GETPROP: Invalid fake object." abort
   then
   STRprop @ strip dup STRprop ! not if
      "FAKE-GETPROP: Invalid string." abort
   then
   ARRfakeobj @ array_vals pop FAKE-DIR swap strcat "/" strcat
 
   STRprop @ strcat getpropval
;
 
: FAKE-GETPROPFVAL[ arr:ARRfakeobj str:STRprop -- float:FLTprop ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-GETPROP: Invalid fake object." abort
   then
   STRprop @ strip dup STRprop ! not if
      "FAKE-GETPROP: Invalid string." abort
   then
   ARRfakeobj @ array_vals pop FAKE-DIR swap strcat "/" strcat
   STRprop @ strcat getpropfval
;
 
: FAKE-NEXTPROP[ arr:ARRfakeobj str:STRprop -- str:STRnext ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-NEXTPROP: Invalid fake object." abort
   then
   STRprop @ strip dup STRprop ! not if
      "FAKE-NEXTPROP: Invalid string." abort
   then
   ARRfakeobj @ array_vals pop FAKE-DIR swap strcat "/" strcat
   STRprop @ strcat nextprop
;
 
: FAKE-PROPDIR?[ arr:ARRfakeobj str:STRprop -- int:BOLdir? ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-PROPDIR?: Invalid fake object." abort
   then
   STRprop @ strip dup STRprop ! not if
      "FAKE-PROPDIR?: Invalid string." abort
   then
   ARRfakeobj @ array_vals pop FAKE-DIR swap strcat "/" strcat
   STRprop @ strcat propdir?
;
 
: FAKE-SETPROP[ arr:ARRfakeobj str:STRprop Prop -- ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-SETPROP: Invalid fake object." abort
   then
   STRprop @ strip dup STRprop ! not if
      "FAKE-SETPROP: Invalid string." abort
   then
   STRprop @  "Show" stringcmp not    STRprop @  "/Show" stringcmp not or
   STRprop @  "Ok?"  stringcmp not or STRprop @  "@Ok?"  stringcmp not or
   STRprop @ "/Ok?"  stringcmp not or STRprop @ "/@Ok?"  stringcmp not or
   STRprop @  "name" stringcmp not or STRprop @  "@name" stringcmp not or
   STRprop @ "/name" stringcmp not or STRprop @ "/@name" stringcmp not or if
      "FAKE-SETPROP: Invalid property." abort
   then
   ARRfakeobj @ array_vals pop FAKE-DIR swap strcat "/" strcat
   STRprop @ strcat Prop @ setprop
;
 
: FAKE-REMOVE_PROP[ arr:ARRfakeobj str:STRprop -- ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-REMOVE_PROP: Invalid fake object." abort
   then
   STRprop @ strip dup STRprop ! not if
      "FAKE-REMOVE_PROP: Invalid string." abort
   then
   STRprop @  "Show" stringcmp not    STRprop @  "/Show" stringcmp not or
   STRprop @  "Ok?"  stringcmp not or STRprop @  "@Ok?"  stringcmp not or
   STRprop @ "/Ok?"  stringcmp not or STRprop @ "/@Ok?"  stringcmp not or
   STRprop @  "name" stringcmp not or STRprop @  "@name" stringcmp not or
   STRprop @ "/name" stringcmp not or STRprop @ "/@name" stringcmp not or if
      "FAKE-REMOVE_PROP: Invalid property." abort
   then
   ARRfakeobj @ array_vals pop FAKE-DIR swap strcat "/" strcat
   STRprop @ strcat remove_prop
;
 
: FAKE-LOCATION[ arr:ARRfakeobj -- ref:REFlocation ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-LOCATION: Invalid fake object." abort
   then
   ARRfakeobj @ 0 array_getitem
;
 
: FAKE-OWNER[ arr:ARRfakeobj -- ref:REFowner ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-OWNER: Invalid fake object." abort
   then
   ARRfakeobj @ 0 array_getitem owner
;
 
: FAKE-NAME[ arr:ARRfakeobj -- str:STRname ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-NAME: Invalid fake object." abort
   then
   ARRfakeobj @ "/@name" FAKE-GETPROPSTR dup not if
      pop ARRfakeobj @ "/name" FAKE-GETPROPSTR dup not if
         pop ARRfakeobj @ 1 array_getitem
      then
   then
;
 
: FAKE-UNPARSE[ arr:ARRfakeobj -- str:STRname ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-UNPARSE: Invalid fake object." abort
   then
   ARRfakeobj @ FAKE-NAME "(Fake)" strcat
;
 
: FAKE-GETFAKES[ ref:ObjLoc -- arr:ARRfakes ]
   { }list VAR! ARRfakes
   ObjLoc @ ok? not if
      "FAKE-GETFAKES: Invalid object." abort
   then
   FAKE-DIR
   BEGIN
      ObjLoc @ swap NEXTPROP dup WHILE dup FAKE-DIR split swap pop
      ObjLoc @ over 2 array_make FAKE-OK? if
         ObjLoc @ swap 2 array_make ARRfakes @ array_appenditem ARRfakes !
      else
         pop
      then
   REPEAT
   pop ARRfakes @
;
 
: FAKE-RMATCH[ ref:ObjLoc str:STRname -- arr:ARRfakeobj ]
   VAR curobj { }list VAR! fakeobj
   STRname @ strip dup STRname ! not if
      "FAKE-RMATCH: Invalid string." abort
   then
   ObjLoc @ ok? not if
      "FAKE-RMATCH: Invalid dbref." abort
   then
   ObjLoc @ FAKE-GETFAKES
   FOREACH
      swap pop dup curobj !
      FAKE-NAME
      dup STRname @ stringcmp not if
         pop curobj @ fakeobj ! BREAK
      then
      STRname @ instring 1 = if
         fakeobj @ array_count not if
            curobj @ fakeobj !
         else
            { #-2 }list fakeobj ! BREAK
         then
      then
   REPEAT
   fakeobj @
;
 
: FAKE-MATCH[ str:STRname -- arr:ARRfakeobj ]
   STRname @ strip dup STRname ! not if
      "FAKE-MATCH: Invalid string." abort
   then
   me @ STRname @ FAKE-RMATCH dup array_count not if
      pop loc @ STRname @ FAKE-RMATCH
   then
;
 
: FAKE-NEARBY?[ ref:REFplyr arr:ARRfakeobj -- int:BOLnear? ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-NEARBY?: Invalid fake object." abort
   then
   REFplyr @ ok? not if
      "FAKE-NEARBY?: Invalid player dbref." abort
   then
   REFplyr @ owner REFplyr !
   ARRfakeobj @ 0 array_getitem dup REFplyr @ dbcmp swap
   REFplyr @ location dbcmp or
;
 
: FAKE-CONTROLS[ ref:REFplyr arr:ARRfakeobj -- int:BOLcontrols? ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-CONTROLS: Invalid fake object." abort
   then
   REFplyr @ ok? not if
      "FAKE-CONTROLS: Invalid player dbref." abort
   then
   REFplyr @ owner REFplyr !
   REFplyr @ ARRfakeobj @ 0 array_getitem controls
;
 
: FAKE-ANSINAME[ arr:ARRfakeobj -- str:STRname ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-ANSINAME: Invalid fake object." abort
   then
   me @ ARRfakeobj @ FAKE-CONTROLS me @ "SILENT" flag? not and if
      "^PURPLE^" ARRfakeobj @ FAKE-UNPARSE ARRfakeobj @
      FAKE-NAME strlen strcut "^^" "^" subst
      "^CINFO^" swap strcat swap "^^" "^" subst swap strcat strcat
   else
      "^PURPLE^" ARRfakeobj @ FAKE-NAME "^^" "^" subst strcat
   then
;
 
: FAKE-HTMLNAME[ arr:ARRfakeobj -- str:STRname ]
   VAR STRname
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-HTMLNAME: Invalid fake object." abort
   then
   me @ ARRfakeobj @ FAKE-CONTROLS me @ "SILENT" flag? not and if
      ARRfakeobj @ FAKE-UNPARSE
   else
      ARRfakeobj @ FAKE-NAME
   then
   "&amp;"  "&"  subst
   "&quot;" "\"" subst
   "&lt;"   "<"  subst
   "&gt;"   ">"  subst
   "&#32;"  " "  subst STRname !
   me @ ARRfakeobj @ FAKE-NEARBY? if
      "<a xch_cmd=\"look " ARRfakeobj @ FAKE-NAME strcat
      "\" xch_hint=\"Look at " strcat
      STRname @ strcat "\">" strcat STRname @ strcat "</a>" strcat
   else
      STRname @
   then
;
 
: FAKE-DONAME[ arr:ARRfakeobj -- str:STRname ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-DONAME: Invalid fake object." abort
   then
   ARRfakeobj @ me @ "PUEBLO" flag? if
      FAKE-HTMLNAME
   else
      FAKE-ANSINAME
   then
;
 
: FAKE-NEW[ ref:REFplyr ref:ObjLoc str:STRname -- arr:ARRfakeobj ]
   REFplyr @ ObjLoc @ controls not if
      "FAKE-NEW: Permission denied." abort
   then
   STRname @ dup ":" instr over "/" instr or swap not or if
      "FAKE-NEW: That is a silly name for a fake object." abort
   then
   ObjLoc @ STRname @ 2 array_make FAKE-OK? if
      "FAKE-NEW: That fake object already exists there."
   then
   ObjLoc @ FAKE-DIR STRname @ strcat over over "/@Ok?" strcat "yes"
   setprop "/@Name" strcat STRname @ setprop
   ObjLoc @ STRname @ 2 array_make
;
 
: FAKE-RECYCLE[ arr:ARRfakeobj -- ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-RECYCLE: Invalid fake object." abort
   then
   trig owner ARRfakeobj @ FAKE-CONTROLS not if
      "FAKE-RECYCLE: Permission denied." abort
   then
   ARRfakeobj @ array_vals pop FAKE-DIR swap strcat remove_prop
;
 
: FAKE-GETDIR ( -- str:STRdir )
   FAKE-DIR
;
 
: FAKE-LOOK[ arr:ARRfakeobj -- ]
   ARRfakeobj @ FAKE-OK? not if
      "FAKE-LOOK: Invalid fake object." abort
   then
   ARRfakeobj @ FAKE-DONAME me @ "PUEBLO" flag? if
      "<H2>" swap strcat "</H2>" strcat me @ swap notify_html
   else
      me @ swap ansi_notify
   then
   ARRfakeobj @ "/htmldesc" FAKE-GETPROPSTR dup me @ "PUEBLO" flag? and if
      ARRfakeobj @ 0 array_getitem swap "(@desc)" 1 ParseMPI ParseMUF
      me @ swap notify_html exit
   then
   pop ARRfakeobj @ "/ansidesc" FAKE-GETPROPSTR dup me @ "COLOR" flag? and if
      ARRfakeobj @ 0 array_getitem swap "(@desc)" 1 ParseMPI ParseMUF
      me @ swap ansi_notify exit
   then
   ARRfakeobj @ "/desc" FAKE-GETPROPSTR dup if
      ARRfakeobj @ 0 array_getitem swap "(@desc)" 1 ParseMPI ParseMUF
      me @ swap notify exit
   then
   pop me @ "You see nothing special." notify
;
 
$pubdef :
$pubdef FAKE-ANSINAME "$Lib/Fakes" match "FAKE-ANSINAME" call
$pubdef FAKE-CONTROLS "$Lib/Fakes" match "FAKE-CONTROLS" call
$pubdef FAKE-DIR "$Lib/Fakes" match "FAKE-GETDIR" call
$pubdef FAKE-DONAME "$Lib/Fakes" match "FAKE-DONAME" call
$pubdef FAKE-GETFAKES "$Lib/Fakes" match "FAKE-GETFAKES" call
$pubdef FAKE-GETPROP "$Lib/Fakes" match "FAKE-GETPROP" call
$pubdef FAKE-GETPROPFVAL "$Lib/Fakes" match "FAKE-GETPROPFVAL" call
$pubdef FAKE-GETPROPSTR "$Lib/Fakes" match "FAKE-GETPROPSTR" call
$pubdef FAKE-GETPROPVAL "$Lib/Fakes" match "FAKE-GETPROPVAL" call
$pubdef FAKE-HTMLNAME "$Lib/Fakes" match "FAKE-HTMLNAME" call
$pubdef FAKE-LOCATION "$Lib/Fakes" match "FAKE-LOCATION" call
$pubdef FAKE-LOOK "$Lib/Fakes" match "FAKE-LOOK" call
$pubdef FAKE-MATCH "$Lib/Fakes" match "FAKE-MATCH" call
$pubdef FAKE-NAME "$Lib/Fakes" match "FAKE-NAME" call
$pubdef FAKE-NEARBY? "$Lib/Fakes" match "FAKE-NEARBY?" call
$pubdef FAKE-NEW "$Lib/Fakes" match "FAKE-NEW" call
$pubdef FAKE-NEXTPROP "$Lib/Fakes" match "FAKE-NEXTPROP" call
$pubdef FAKE-OK? "$Lib/Fakes" match "FAKE-OK?" call
$pubdef FAKE-OWNER "$Lib/Fakes" match "FAKE-OWNER" call
$pubdef FAKE-PROPDIR? "$Lib/Fakes" match "FAKE-PROPDIR?" call
$pubdef FAKE-RECYCLE "$Lib/Fakes" match "FAKE-RECYCLE" call
$pubdef FAKE-REMOVE_PROP "$Lib/Fakes" match "FAKE-REMOVE_PROP" call
$pubdef FAKE-RMATCH "$Lib/Fakes" match "FAKE-RMATCH" call
$pubdef FAKE-SETPROP "$Lib/Fakes" match "FAKE-SETPROP" call
$pubdef FAKE-UNPARSE "$Lib/Fakes" match "FAKE-UNPARSE" call
$pubdef FAKE-VISIBLE? "$Lib/Fakes" match "FAKE-VISIBLE?" call
WIZCALL FAKE-ANSINAME    ( arr:ARRfakeobj -- str:STRname )
WIZCALL FAKE-HTMLNAME    ( ref:REFplyr arr:ARRfakeobj -- str:STRname )
WIZCALL FAKE-UNPARSE     ( arr:ARRfakeobj -- str:STRname )
WIZCALL FAKE-NEARBY?     ( ref:REFplyr arr:ARRfakeobj -- int:BOLnear? )
WIZCALL FAKE-CONTROLS    ( ref:REFplyr arr:ARRfakeobj -- int:BOLcontrols? )
WIZCALL FAKE-NAME        ( arr:ARRfakeobj -- str:STRname )
WIZCALL FAKE-DONAME      ( ref:REFplyr arr:ARRfakeobj -- str:STRname )
WIZCALL FAKE-LOCATION    ( arr:ARRfakeobj -- ref:REFlocation )
WIZCALL FAKE-OWNER       ( arr:ARRfakeobj -- ref:REFowner )
WIZCALL FAKE-LOOK        ( arr:ARRfakeobj -- )
WIZCALL FAKE-NEW         ( ref:REFplyr ref:ObjLoc str:STRname -- arr:ARRfakeobj )
WIZCALL FAKE-RECYCLE     ( arr:ARRfakeobj -- )
WIZCALL FAKE-SETPROP     ( arr:ARRfakeobj str:STRprop Prop -- )
WIZCALL FAKE-REMOVE_PROP ( arr:ARRfakeobj str:STRprop -- )
WIZCALL FAKE-GETPROP     ( arr:ARRfakeobj str:STRprop -- Prop )
WIZCALL FAKE-GETPROPSTR  ( arr:ARRfakeobj str:STRprop -- str:STRprop )
WIZCALL FAKE-GETPROPVAL  ( arr:ARRfakeobj str:STRprop -- int:INTprop )
WIZCALL FAKE-GETPROPFVAL ( arr:ARRfakeobj str:STRprop -- float:FLTprop )
WIZCALL FAKE-PROPDIR?    ( arr:ARRfakeobj str:STRprop -- int:BOLdir? )
WIZCALL FAKE-NEXTPROP    ( arr:ARRfakeobj str:STRprop -- str:STRnext )
WIZCALL FAKE-OK?         ( ARRfakeobj -- int:BOLfake? )
WIZCALL FAKE-MATCH       ( str:STRname -- arr:ARRfakeobj )
WIZCALL FAKE-RMATCH      ( ref:ObjLoc str:STRname -- arr:ARRfakeobj )
WIZCALL FAKE-GETFAKES    ( ref:ObjLoc -- arr:ARRfakes )
WIZCALL FAKE-GETDIR      ( -- str:STRdir )
WIZCALL FAKE-VISIBLE?    ( arr:ARRfakeobj -- int:BOLvisible? )
