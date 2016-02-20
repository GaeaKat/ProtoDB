$def PROGNAME  "@Archive"
$def VERSION   "6.600"
$def COPYRIGHT "Copyright by Revar (ProtoMUCK changes by Moose/Van and Alynna)"
 
$version 6.6
 
: show-help
 {
  COPYRIGHT VERSION PROGNAME "^CYAN^%s v%s ^AQUA^%s" fmtstring
  "^CYAN^Syntax: ^AQUA^@archive <object>[=1acefil]"
  " ^WHITE^@archive <object>=1    ^NORMAL^Archive only that object."
  " ^WHITE^@archive <object>=a    ^NORMAL^Archive all, regardless of owner.  (wizards only)."
  " ^WHITE^@archive <object>=c    ^NORMAL^Don't archive contents."
  " ^WHITE^@archive <object>=e    ^NORMAL^Archive objects not in this room's environment."
  " ^WHITE^@archive <object>=f    ^NORMAL^Don't archive floater child rooms unless linked to."
  " ^WHITE^@archive <object>=i    ^NORMAL^Archive, including even globally registered objects."
  " ^WHITE^@archive <object>=l    ^NORMAL^Don't follow links or droptos in archiving."
  " ^WHITE^@archive <object>=p    ^NORMAL^Don't archive programs at all."
  "^CNOTE^NOTE: Turn off your client's wordwrap before logging an @archive output."
  "^CINFO^Done."
 }list
 { me @ }list ARRAY_ansi_NOTIFY
;
lvar originalobj
lvar here?
lvar owned?
lvar one?
lvar nofloater?
lvar nocontents?
lvar nolinks?
lvar noprogs?
lvar playercnt
lvar roomcnt
lvar exitcnt
lvar thingcnt
lvar progcnt
: clear-refnames ( -- )
  me @ "_tempreg" remove_prop
;
: get-refname (d -- s)
  me @ over dbcmp if pop "me" exit then
  #0 over dbcmp if pop "#0" exit then
  me @ "_tempreg/" rot int intostr strcat getpropstr
  dup if "$" swap strcat then
;
: is-refname (d -- s)
  me @ "_tempreg/" rot int intostr strcat getpropstr
  not not
;
: set-refname (d s -- )
  me @ "_tempreg/" 4 rotate int intostr strcat rot 0 addprop
;
: in-environ? (d -- i)
  begin
    dup while
    dup originalobj @ dbcmp if pop 1 exit then
    location
  repeat pop 0
;
: dump-registration-loop ( d d s -- )
  begin
    over swap nextprop
    dup while
    over over getpropstr
    dup "#" 1 strncmp not if 1 strcut swap pop then
    dup not if pop "-1" then
    atoi dbref 4 pick dbcmp if
      "@register "
      3 pick me @ dbcmp if "#me " strcat then
      4 pick name strcat "=" strcat
      over 6 strcut swap pop strcat
      me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
    then
    over over propdir? if
      3 pick 3 pick 3 pick "/" strcat
      dump-registration-loop
    then
  repeat
  pop pop pop
;
: dump-registration ( d d -- )
  (searchforobj propsobj )
  "/_reg/" dump-registration-loop
;
: get-globalrefs-loop (d s -- )
  begin
    over swap nextprop dup while
    over over getpropstr dup if
      dup "#" 1 strncmp not if 1 strcut swap pop then
      dup number? if
        atoi dbref over dup "/" instr
        strcut swap pop set-refname
      else pop
      then
    else pop
    then
    over over propdir? if
      over over "/" strcat get-globalrefs-loop
    then
  repeat pop pop
;
: get-globrefs ( -- )
  #0 "_reg/" get-globalrefs-loop
;
: translate-lockstr (s -- s)
  "" swap
  dup "*UNLOCKED*" stringcmp not if pop pop "" exit then
  begin
    dup "#" instr over or while
    "#" .split
    rot rot strcat swap
    dup atoi intostr strlen
    strcut swap atoi dbref
    get-refname dup not if pop "(me&!me)" then
    rot swap strcat swap
  repeat
  strcat
;
: dump-lock (d -- )
  me @ "wizard" flag? if pop exit then
  dup "@/flk" getprop
  dup lock? not if pop pop exit then
  unparselock
  translate-lockstr
  "@flock " rot get-refname strcat
  "=" strcat swap strcat
  me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
  descr descrflush
;
: dump-props-loop (s d s -- ) (refname object propdir -- )
  begin
    descr descrflush
    (refname object propdir -- )
    begin
      over swap nextprop
      (refname object propname -- )
      dup not if pop pop pop exit then
      "/" over strcat "/@" instr not
      me @ "wizard" flag? or
    until
    (refname object propname -- )
    over over getprop
    (refname object propname propval -- )
    dup string? if
      "/_/de:/_/sc:/_/fl:/_/dr" 3 pick tolower instr if
        (refname object propname propval -- )
        dup "@" 1 strncmp not if
          (refname object propname propval -- )
          1 strcut dup number? if
            " " .split swap atoi dbref
            dup get-refname dup not if swap intostr then
            swap pop " " strcat swap strcat
          then
          strcat
        then
      then
      "@propset " 5 pick strcat
      "=str:" strcat 3 pick strcat
      ":" strcat swap strcat
      me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
    else (not a string)
      dup int? if
        dup if
          "@propset " 5 pick strcat
          "=int:" strcat 3 pick strcat
          ":" strcat swap intostr strcat
          me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
        else pop
        then
      else (not an int.)
        dup dbref? if
          dup get-refname
          dup not if "#" rot int intostr strcat then swap pop
          "@propset " 5 pick strcat
          "=dbref:" strcat 3 pick strcat
          ":" strcat swap strcat
          me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
        else
          dup float? if (A floating point number!  Joy!)
            ftostr
            "@propset " 5 pick strcat
            "=float:" strcat 3 pick strcat
            ":" strcat swap strcat me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
          else (not a dbref.  Must be a lock.  Fun fun parse time.)
            (refname object propname propval -- )
            unparselock translate-lockstr
            "@propset " 5 pick strcat
            "=lock:" strcat 3 pick strcat
            ":" strcat swap strcat
            me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
          then (float?)
        then (dbref?)
      then (int?)
    then (string?)
    over over propdir? if
      3 pick 3 pick 3 pick
      "/" strcat dump-props-loop
    then
  repeat
;
: dump-props (d -- )  (object -- )
  dup get-refname swap "/" dump-props-loop
;
lvar obj
: dump-flags (d -- )
  var iswiz? 0 iswiz? !
  var ismucker? 0 ismucker? !
  var refname dup get-refname refname ! dup unparseobj dup strlen 1 - strcut pop
  dup "(#" rinstr 1 + strcut swap pop swap int intostr strlen strcut swap pop
  dup strlen 1 swap over FOR
     pop 1 strcut swap
     "RPEF" over instring if
        pop continue
     then
     dup number? iswiz? @ and if
        dup atoi 4 > if pop "4" then
        "W" swap strcat "@set " refname @ strcat "=" strcat swap strcat me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify 0 iswiz? ! continue
     then
     dup number? ismucker? @ and if
        "M" swap strcat "@set " refname @ strcat "=" strcat swap strcat me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify 0 ismucker? ! continue
     then
     iswiz? @ if
        0 iswiz? ! "@set " refname @ strcat "=W" strcat me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
     then
     ismucker? @ if
        0 ismucker? ! "@set " refname @ strcat "=M" strcat me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
     then
     dup "W" stringcmp not if
        pop 1 iswiz? ! continue
     then
     dup "M" stringcmp not if
        pop 1 ismucker? ! continue
     then
     "@set " refname @ strcat "=" strcat swap strcat me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
  REPEAT
  pop descr descrflush
;
: dump-obj (d -- )
  descr descrflush
  dup ok? not if pop exit then
  one? @ if dup originalobj @ dbcmp not if pop exit then then
  owned? @ if dup owner originalobj @ owner dbcmp not if pop exit then then
  here? @ if dup in-environ? not if pop exit then then
  noprogs? @ if dup program? if pop exit then then
(*  dup is-refname if pop exit then *)
  dup room? if
    nolinks? @ not if
      dup getlink dump-obj
    then
    dup location dump-obj
    roomcnt @ 1 + roomcnt !
    "tmp/room" roomcnt @ intostr strcat
    (dbref regname)
    "@dig " 3 pick name strcat
    "=" strcat 3 pick location get-refname strcat
    "=" strcat over strcat
    me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
    over swap set-refname
    dup getlink if
      "@link " over get-refname strcat
      "=" strcat over getlink get-refname dup strip not if pop pop "@unlink " over get-refname then strcat
      me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
    then
    dup dump-lock
    dup dump-flags
    dup dump-props
    nocontents? @ not if
      dup contents
      begin
        dup while
        nofloater? @ if
          dup room? if
            next continue
          then
        then
        dup dump-obj
        next
      repeat pop
    then
    dup exits
    begin
      dup while
      dup dump-obj (dump exit)
      next
    repeat pop
    pop exit
  then
  dup player? if
    ( showplayers? @ not if pop exit then )
    dup originalobj @ dbcmp if
      nolinks? @ not if
        dup getlink dump-obj (dump room or object linked to)
      then
      playercnt @ 1 + playercnt !
      "tmp/player" playercnt @ intostr strcat
      "@pcreate " 3 pick name strcat
      "=<password>" strcat
      me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
      "@register #me *" 3 pick name strcat
      "=" strcat over strcat
      me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
      over swap set-refname
      "@link " over get-refname strcat
      "=" strcat over getlink get-refname dup strip not if pop pop "@unlink " over get-refname then strcat
      me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
      dup dump-lock
      dup dump-flags
      dup dump-props
      nocontents? @ not if
        dup contents
        begin
          dup while
          dup dump-obj  (dump thing contents)
          next
        repeat pop
      then
      dup exits
      begin
        dup while
        dup dump-obj (dump exit)
        next
      repeat pop
    then
    pop exit
  then
  dup thing? if
    nolinks? @ not if
      dup getlink dump-obj (dump room or object linked to)
    then
    thingcnt @ 1 + thingcnt !
    "tmp/thing" thingcnt @ intostr strcat
    (dbref refname)
    "@create " 3 pick name strcat
    "=" strcat 3 pick pennies 1 + 5 * intostr strcat
    "=" strcat over strcat
    me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
    over swap set-refname
    "@tel " over get-refname strcat
    "=" strcat over location get-refname strcat
    me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
    "@link " over get-refname strcat
    "=" strcat over getlink get-refname dup strip not if pop pop "@unlink " over get-refname then strcat
    me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
    dup dump-lock
    dup dump-flags
    dup dump-props
    nocontents? @ not if
      dup contents
      begin
        dup while
        dup dump-obj  (dump thing contents)
        next
      repeat pop
    then
    dup exits
    begin
      dup while
      dup dump-obj (dump exit)
      next
    repeat pop
    pop exit
  then
  dup exit? if
    nolinks? @ not if
      dup getlink dump-obj (dump room or object linked to)
    then
    exitcnt @ 1 + exitcnt !
    "tmp/exit" exitcnt @ intostr strcat
    (dbref refname)
    "@action " 3 pick name strcat
    "=" strcat 3 pick location get-refname strcat
    "=" strcat over strcat
    me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
    over swap set-refname
    "@link " over get-refname strcat
    "=" strcat over getlink get-refname dup strip not if pop pop "@unlink " over get-refname then strcat
    me @ "^WHITE^" rot 1 escape_ANSI strcat ansi_notify
    dup dump-lock
    dup dump-flags
    dup dump-props
    pop exit
  then
  dup program? if
    progcnt @ 1 + progcnt !
    "tmp/prog" progcnt @ intostr strcat
    (dbref refname)
    "^WHITE^@program " 3 pick name strcat
    me @ swap ansi_notify
    me @ "^WHITE^1 99999 d" ansi_notify
    me @ "^WHITE^1 i" ansi_notify
    over 1 99999 program_getlines { me @ }array array_notify
    (dbref refname)
    me @ "^WHITE^." ansi_notify
    me @ "^WHITE^c" ansi_notify
    me @ "^WHITE^q" ansi_notify
    (dbref refname)
    over #0 dump-registration
    over me @ dump-registration
    over name "^WHITE^@register #me " swap 1 escape_ANSI strcat
    "=" strcat over 1 escape_ANSI strcat
    me @ swap ansi_notify
    over swap set-refname
    dup dump-lock
    dup dump-flags
    dup dump-props
    pop exit
  then
;
: match_controlled
   dup not if
      #-1
   else
      match
   then
   dup #-2 dbcmp if
      pop #-1 me @ "^CINFO^I don't know which one you mean!" ansi_notify exit
   then
   dup not if
      pop #-1 me @ "^CINFO^I don't see that here!" ansi_notify exit
   then
   me @ over controls not if
      pop #-1 me @ "^CFAIL^Permission denied." ansi_notify
   then
;
: archiver
  dup strip "#help" stringcmp not if
     pop show-help exit
  then
  clear-refnames
  "=" .split strip swap strip
  dup not if
     pop pop show-help exit
  then
  match_controlled
  dup not if
     pop pop exit
  then
  swap tolower
  me @ "wizard" flag? not if "" "a" subst then
  dup "e" instr not here? !
  dup "a" instr not owned? !
  dup "c" instr nocontents? !
  dup "f" instr nofloater? !
  dup "l" instr nolinks? !
  dup "1" instr one? !
  dup "p" instr noprogs? !
  "i" instr not if get-globrefs then
  dup originalobj !
  me @ "^CINFO^[Start Dump]" ansi_notify
  dump-obj
  me @ "^CINFO^[End Dump]" ansi_notify
  clear-refnames
;
