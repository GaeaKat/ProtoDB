(*
   CopyProp/MoveProp v2.0.3
   Author: Chris Brine [Moose/Van]
   v2.0.3: Formatting cleaned up and new directives added. 09/04/2001 [Akari]
   v2.0.2: Permission problems fixed, again. Hopefully for the last time.
   v2.0.1: Permission problem for archwizards fixed.  They now have access to
           any property, as they should.
 
   Install with an action such as: cp;mv;propcp;propmv;copyprop;moveprop
 *)
 
$author Moose
$version 2.03
$def atel me @ swap ansi_notify
 
: FixProp ( str:prop -- str:prop' )
   strip "/" swap strcat
   BEGIN
      dup "/" rinstr over strlen = over and WHILE
      dup strlen 1 - strcut pop
   REPEAT
   "" "\r" subst
   "" "\[" subst
   "" ":" subst
   BEGIN
      dup "//" instr WHILE
      "/" "//" subst
   REPEAT
;
 
: HasPerm? ( ref:Plyr str:Prop -- int:Perm? )
   dup "/@" instr swap "/~" instr or not swap "WIZARD" flag? or
;
 
: CP-PropDir[ ref:REFold str:DIRold ref:REFnew str:DIRnew int:BOLmove? -- ]
   DIRold @ VAR! OLDdir VAR NEWdir
   BEGIN
      REFold @ DIRold @ NEXTPROP dup DIRold ! WHILE
      me @ owner "ARCHWIZARD" Flag? not if
         me @ owner DIRold @ HasPerm? not if
            CONTINUE
         then
      then
      DIRold @ OLDdir @ split swap pop DIRnew @ swap strcat NEWdir !
      DIRold @ NEWdir @ and if
         REFold @ DIRold @ getprop REFnew @ NEWdir @ rot setprop
      then
      REFold @ DIRold @ "/" strcat REFnew @ NEWdir @ "/" strcat BOLmove? @
      CP-PropDir
      BOLmove? @ if
         REFold @ DIRold @ remove_prop
      then
   REPEAT
;
 
: CP-Main[ ref:REFold str:DIRold ref:REFnew str:DIRnew int:BOLmove? -- int:bol ]
   DIRold @ FixProp DIRold ! DIRnew @ FixProp DIRnew !
   me @ owner "ARCHWIZARD" Flag? not if
      me @ owner DIRold @ HasPerm? me @ owner DIRnew @ HasPerm? and not
      me @ owner REFold @ controls me @ owner REFnew @ controls and not or if
         me @ "^CFAIL^Permission denied." ansi_notify 0 exit
      then
   then
   DIRold @ DIRnew @ and if
      REFold @ DIRold @ getprop REFnew @ DIRnew @ rot setprop
   then
   REFold @ DIRold @ "/" strcat REFnew @ DIRnew @ "/" strcat BOLmove? @
   CP-PropDir 1
;
 
: CP-Prop ( d s d s -- i )
   0 CP-Main
;
ARCHCALL CP-Prop
 
: MV-Prop ( d s d s -- i )
   1 CP-Main
;
ARCHCALL MV-Prop
 
: main ( str:Args -- )
   VAR REFold VAR REFnew VAR DIRold VAR DIRnew
   me @ "^CINFO^command @ = ^CNOTE^" command @ strcat ansi_notify
   dup "#help" stringcmp not if
   "^CINFO^cp origobj=prop,destobj=destprop" atel
      "^CNOTE^  Copies prop from origobj to destobj, renaming it to destprop."
      atel
   "^CINFO^mv origobj=prop,destobj=destprop" atel
   "^CNOTE^  Moves prop from origobj to destobj, renaming it to destprop." atel
   " " atel
   "  If origobj is omitted, it assumes a property on the user." atel
   "  If destobj is omitted, it assumes destobj is the same as origobj." atel
   "  If destprop is omitted, it assumes it is the same name as prop." atel
   "  If prop is omitted, it asks the user for it." atel
   "  If both prop and origobj are omitted, it asks the user for both." atel
   "  If both destobj and destprop are omitted, it asks the user for them." atel
      exit
   then
   dup "=" instr if
      "=" split swap strip dup if
         match REFold !
      else
         pop me @ REFold !
      then
   else
      #-20 REFold !
   then
   dup "," instr if
      "," split swap strip dup if
         DIRold !
      else
         pop "" DIRold !
      then
      strip dup if
         dup "=" instr if
            "=" split swap strip dup if
               match REFnew !
            else
               pop REFold @ REFnew !
            then
            strip dup if
               DIRnew !
            else
               pop DIRold @ DIRnew !
            then
         else
            match REFnew !
         then
      else
         pop REFold @ REFnew !
      then
   else
      pop #-20 REFnew ! "" DIRnew ! "" DIRold !
   then
   REFold @ #-20 dbcmp if
      me @ "^CINFO^Please enter the name of the original object." ansi_notify
      read strip dup if
         match REFold !
      else
         pop me @ REFold !
      then
   then
   REFold @ ok? not if
      REFold @ #-2 dbcmp if
         "^CINFO^I don't know which one you mean!"
      else
         "^CINFO^I don't see that here."
      then
      me @ swap ansi_notify exit
   then
   BEGIN
      DIRold @ not WHILE
      me @ "^CINFO^Please enter the name of the original property."
      ansi_notify read strip DIRold !
   REPEAT
   REFnew @ #-20 dbcmp if
      me @ "^CINFO^Please enter the name of the destination object." ansi_notify
      read strip dup if
         match REFnew !
      else
         pop me @ REFnew !
      then
   then
   REFnew @ ok? not if
      REFnew @ #-2 dbcmp if
         "^CINFO^I don't know which one you mean!"
      else
         "^CINFO^I don't see that here."
      then
      me @ swap ansi_notify exit
   then
   BEGIN
      DIRnew @ not WHILE
      me @ "^CINFO^Please enter the name of the destination property."
      ansi_notify read strip DIRnew !
   REPEAT
   me @ REFold @ controls REFold @ me @ REFnew @ controls and not if
      me @ "^CFAIL^Permission denied." ansi_notify exit
   then
   REFold @ DIRold @ REFnew @ DIRnew @ command @ "c" instring not CP-Main if
      command @ "c" instring if
         "^CSUCC^Property copied."
      else
         "^CSUCC^Property moved."
      then
      me @ swap ansi_notify
   then
;
