(*
   LsProp v2.2
   Author: Chris Brine [Moose/Van]
   v2.2: Modified so it no longer needs ProtoLook.
   v2.1: Modified to accept the EXAMINE_OK flag.
 *)
 
$author Moose
$version 2.2
 
: Ansi-UnparseObj[ ref:ref -- str:STRname ]
   ref @ unparseobj ref @ name strlen strcut "^^" "^" subst "^YELLOW^" swap strcat swap "^^" "^" subst swap strcat
   ref @ program? if
      "^RED^"
   else
      ref @ player? if
         "^GREEN^"
      else
         ref @ room? if
            "^CYAN^"
         else
            ref @ exit? if
               "^BLUE^"
            else
               ref @ ok? if
                  "^PURPLE^"
               else
                  "^NORMAL^"
               then
            then
         then
      then
   then
   swap strcat
;
 
: FixProp ( str:STRprop -- str:STRprop' )
   BEGIN
      dup "/" rinstr over strlen = WHILE
      dup strlen 1 - strcut pop
   REPEAT
   BEGIN
      dup "/" instr 1 = WHILE
      1 strcut swap pop
   REPEAT
   BEGIN
      dup "//" instr WHILE
      "/" "//" subst
   REPEAT
   "" ":" subst
   "" "\r" subst
   "" "\[" subst
   "/" swap strcat
;
 
: HasPerm? ( ref:ref str:STRdir -- int:BOLperm? )
   "/@" instr not swap "ARCHWIZARD" flag? or
;
 
: PropMsg[ ref:ref str:STRdir -- str:STRmsg ]
   ref @ STRdir @ getprop dup if
      BEGIN
         dup string? if
            "^^" "^" subst "^CYAN^" swap strcat "^AQUA^str " break
         then
         dup int? if
            intostr "^YELLOW^" swap strcat "^FOREST^int " break
         then
         dup float? if
            ftostr "^BROWN^" swap strcat "^NAVY^flt " break
         then
         dup lock? if
            unparselock "^^" "^" subst
            "^PURPLE^" swap strcat "^CRIMSON^lok " break
         then
         dup dbref? if
            Ansi-UnparseObj "^BROWN^ref " break
         then
         pop "" "^WHITE^dir "
      1 UNTIL
   else
      pop ref @ STRdir @ propdir? if
         "" "^WHITE^dir "
      else
         "" "^RED^unk "
      then
   then
   STRdir @ ref @ STRdir @ propdir? if "/" strcat then
   "^^" "^" subst "^GREEN^" swap strcat "^RED^:" strcat
   strcat swap strcat
;
 
: ListPropDir[ ref:ref str:STRdir str:STRmatch str:STRpre -- idx ]
   VAR idx
   BEGIN
      ref @ STRdir @ NEXTPROP dup STRdir ! WHILE
      ref @ owner STRdir @ HasPerm? not if
         CONTINUE
      then
      STRdir @ STRmatch @ smatch if
         ref @ STRdir @ PropMsg STRpre @ swap strcat
         me @ swap ansi_notify idx ++
         ref @ STRdir @ propdir? if
            ref @ STRdir @ "/" strcat
            STRmatch @ STRpre @ " " strcat ListPropDir
            idx @ + idx !
         then
      else
         ref @ STRdir @ propdir? if
            ref @ STRdir @ "/" strcat
            STRmatch @ STRpre @ ListPropDir
            idx @ + idx !
         then
      then
   REPEAT
   idx @
;
 
: main ( str:Args -- )
   strip dup not if
      pop me @ "^CYAN^Syntax: ^AQUA^lsprop <object>" ansi_notify
      me @ "        ^AQUA^lsprop <object>=<prop or dir pre-match>"
      ansi_notify exit
   then
   "=" split swap match dup ok? not if
      #-2 dbcmp if
         "^CINFO^I don't know which one you mean!"
      else
         "^CINFO^I don't see that here."
      then
      me @ swap ansi_notify exit
   then
   me @ over controls over "EXAMINE_OK" flag? or not if
      pop me @ "^CFAIL^Permission denied." ansi_notify exit
   then
   swap strip dup if
      FixProp dup "*" instr not if
         "*" strcat
      then
   else
      pop "*"
   then
   "/" swap "" ListPropDir dup if
      dup intostr swap 1 = if " property" else " properties" then
      " listed." strcat strcat me @ "^CINFO^" rot strcat ansi_notify
   else
      pop me @ "^CINFO^No properties listed." ansi_notify
   then
;
