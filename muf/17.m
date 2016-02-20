(*
   Lib-ObjEditors v2.11
   Author: Chris Brine [Moose/Van]
 
 
   Version 2.11 [By Moose] 01/06/2003
       Made it work with $lib/standard
   Version 2.1  [by Akari] 12/10/2001
       Cleaned up the formatting to be 80 column friendly and added the
       $pubdefs to the program.
 
 
   This program only demands v1.50 of ProtoMUCK, but is still 100% stable
   with the old NeonLook.  However, the new $lib/fakes is required for this
   to work.  The new ProtoLook is also highly recommended.
 
 
   To setup replacements for object editors, type:
     @propset #0=dbref:_ObjEdit/Room:<program dbref for room editor>
      [ ref:REF  -- ]
     @propset #0=dbref:_ObjEdit/Player:<program dbref for player editor>
      [ ref:REF  -- ]
     @propset #0=dbref:_ObjEdit/Thing:<program dbref for thing editor>
      [ ref:REF  -- ]
     @propset #0=dbref:_ObjEdit/Exit:<program dbref for exit editor>
      [ ref:REF  -- ]
 
     @propset #0=dbref:_ObjEdit/Program:<program dbref for program editor>
      [ ref:REF  -- ]
     @propset #0=dbref:_ObjEdit/FakeObj:<program dbref for fake object editor>
      [ arr:FAKE -- ] NOTE: If the fake name is blank, then it is editing the
                            object.
 *)
 
 
$author      Moose
$lib-version 2.11
 
$include $lib/fakes (* Proto v1.1+ version *)
$include $lib/standard
 
$def atell me @ swap ansi_notify
 
 
: noisy_match[ str:Obj -- ref:Obj' ]
   Obj @ match dup ok? not if
      dup #-2 dbcmp if
         "^CINFO^I don't know which one you mean!"
      else
         "^CINFO^I cannot find that here."
      then
      me @ swap ansi_notify
   else
      me @ over controls not if
         pop #-1 "^CFAIL^" "noperm_mesg" sysparm "^^" "^" subst strcat atell
     then
   then
;
 
 
: EDIT-room[ ref:REF -- ]
   VAR Option
   REF @ Room? not if
      me @ "^CFAIL^Invalid object type." ansi_notify exit
   then
   #0 "_ObjEdit/Room" getprop dup int? if
      dbref
   else
      dup string? if
         stod
      else
         dup dbref? not if
            pop #-1
         then
      then
   then
   dup ok? if dup program? else 0 then if
      REF @ dtos swap call exit
   else
      pop
   then
   BEGIN
      me @ "^WHITE^** ^BLUE^Room Editor: ^CYAN^" REF @ unparseobj
      REF @ name strlen strcut "^^" "^" subst
      "^CINFO^" swap strcat swap "^^" "^" subst swap strcat strcat
      " ^WHITE^**" strcat ansi_notify
      me @ " " notify
      me @ "^YELLOW^1^WHITE^) ^AQUA^Current Name: ^CYAN^" REF @ unparseobj
      REF @ name strlen strcut "^^" "^" subst
      "^CINFO^" swap strcat swap "^^" "^" subst swap strcat strcat
      ansi_notify
      me @ "^YELLOW^2^WHITE^) ^AQUA^Description: ^NORMAL^" REF @ desc
      "^^" "^" subst dup
      not if pop "^CFAIL^None." then
      strcat ansi_notify
      me @ "^YELLOW^3^WHITE^) ^AQUA^ANSI Description: ^NORMAL^"
      REF @ ansidesc "^^" "^" subst dup
      not if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^4^WHITE^) ^AQUA^HTML Description: ^NORMAL^"
      REF @ htmldesc "^^" "^" subst dup
      not if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^5^WHITE^) ^AQUA^Arrive: ^NORMAL^"
      REF @ "_Arrive" getpropstr "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^6^WHITE^) ^AQUA^OArrive: ^NORMAL^"
      REF @ "_OArrive" getpropstr "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^7^WHITE^) ^AQUA^Depart: ^NORMAL^"
      REF @ "_Depart" getpropstr "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^8^WHITE^) ^AQUA^ODepart: ^NORMAL^"
      REF @ "_ODepart" getpropstr "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^RED^Q^WHITE^)^RED^uit the Editor." ansi_notify
      me @ " " notify
      me @ "^BROWN^Enter an option below [1-8,Q]:" ansi_notify
      BEGIN
         read "\r" over over strcat strcat "\r1\r2\r3\r4\r5\r6\r7\r8\rQ\r" swap
         instring not WHILE pop
         "^CFAIL^Invalid option.  Enter an option below [1-8,Q]:" atell
      REPEAT
      Option !
      Option @ "1" stringcmp not if
         me @ "^CYAN^Enter a value below:" ansi_notify
         READ strip dup NAME-OK? over and if
            REF @ swap setname me @ "^CSUCC^Set." ansi_notify
         else
            pop me @ "^CFAIL^Invalid name." ansi_notify
         then
      then
      Option @ "2" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip setdesc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "3" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip setansidesc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "4" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip sethtmldesc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "5" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ "_Arrive" read strip setprop me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "6" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ "_OArrive" read strip setprop me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "7" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ "_Depart" read strip setprop me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "8" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ "_ODepart" read strip setprop me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "Q" stringcmp not if
         me @ "^CSUCC^Finished.  Exiting the editor." ansi_notify break
      then
   REPEAT
;
 
 
: EDIT-player[ ref:REF -- ]
   VAR Option
   REF @ Player? not if
      me @ "^CFAIL^Invalid object type." ansi_notify exit
   then
   #0 "_ObjEdit/Player" getprop dup int? if
      dbref
   else
      dup string? if
         stod
      else
         dup dbref? not if
            pop #-1
         then
      then
   then
   dup ok? if dup program? else 0 then if
      REF @ dtos swap call exit
   else
      pop
   then
   BEGIN
      me @ "^WHITE^** ^BLUE^Player Editor: ^GREEN^" REF @ unparseobj REF @ name
      strlen strcut "^^" "^" subst
           "^CINFO^" swap strcat swap "^^" "^" subst swap strcat strcat
           " ^WHITE^**" strcat ansi_notify
      me @ " " notify
      me @ "^YELLOW^1^WHITE^) ^AQUA^Current Alias: ^GREEN^"
      REF @ "%n" getpropstr "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^2^WHITE^) ^AQUA^Description: ^NORMAL^"
      REF @ desc "^^" "^" subst dup
      not if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^3^WHITE^) ^AQUA^ANSI Description: ^NORMAL^"
      REF @ ansidesc "^^" "^" subst dup
      not if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^4^WHITE^) ^AQUA^HTML Description: ^NORMAL^"
      REF @ htmldesc "^^" "^" subst dup
      not if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^5^WHITE^) ^AQUA^Gender: ^NORMAL^"
      REF @ PROPS-gender getpropstr "^^" "^" subst dup
      not if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^6^WHITE^) ^AQUA^Species: ^NORMAL^"
      REF @ PROPS-species getpropstr "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^7^WHITE^) ^AQUA^Age: ^NORMAL^"
      REF @ PROPS-age getpropstr "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^8^WHITE^) ^AQUA^Looked Notify (notifies you): ^NORMAL^"
      REF @ SETTING-look_notify getpropstr "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^9^WHITE^) ^AQUA^Looker Notify (notifies looker): ^NORMAL^"
      REF @ SETTING-looker_notify getpropstr "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^RED^Q^WHITE^)^RED^uit the Editor." ansi_notify
      me @ " " notify
      me @ "^BROWN^Enter an option below [1-9,Q]:" ansi_notify
      BEGIN
         read "\r" over over strcat strcat "\r1\r2\r3\r4\r5\r6\r7\r8\r9\rQ\r"
         swap instring not WHILE pop
         "^CFAIL^Invalid option.  Enter an option below [1-9,Q]:" atell
      REPEAT
      Option !
      Option @ "1" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ "%n" read strip setprop me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "2" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip setdesc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "3" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip setansidesc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "4" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip sethtmldesc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "5" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ PROPS-gender read strip setprop me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "6" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ PROPS-species read strip setprop me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "7" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ PROPS-age read strip setprop me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "8" stringcmp not if
         me @ "^BROWN^%n = Player's name" ansi_notify
         me @ "^CNOTE^This accepts MPI code." ansi_notify
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ SETTING-look_notify read strip setprop "^CSUCC^Done." atell
      then
      Option @ "9" stringcmp not if
         me @ "^BROWN^%n = Player looked at's name" ansi_notify
         me @ "^CNOTE^This accepts MPI code." ansi_notify
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ SETTING-looker_notify read strip setprop "^CSUCC^Done." atell
      then
      Option @ "Q" stringcmp not if
         me @ "^CSUCC^Finished.  Exiting the editor." ansi_notify break
      then
   REPEAT
;
 
 
: EDIT-thing[ ref:REF -- ]
   VAR Option
   REF @ Thing? not if
      me @ "^CFAIL^Invalid object type." ansi_notify exit
   then
   #0 "_ObjEdit/Thing" getprop dup int? if
      dbref
   else
      dup string? if
         stod
      else
         dup dbref? not if
            pop #-1
         then
      then
   then
   dup ok? if dup program? else 0 then if
      REF @ dtos swap call exit
   else
      pop
   then
   BEGIN
      me @ "^WHITE^** ^BLUE^Thing Editor: ^PURPLE^" REF @ unparseobj
      REF @ name strlen strcut "^^" "^" subst
           "^CINFO^" swap strcat swap "^^" "^" subst swap strcat strcat
           " ^WHITE^**" strcat ansi_notify
      me @ " " notify
      me @ "^YELLOW^1^WHITE^) ^AQUA^Current Name: ^PURPLE^" REF @ unparseobj
      REF @ name strlen strcut "^^" "^" subst
      "^CINFO^" swap strcat swap "^^" "^" subst swap strcat strcat
      ansi_notify
      me @ "^YELLOW^2^WHITE^) ^AQUA^Description: ^NORMAL^"
      REF @ desc "^^" "^" subst dup
      not if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^3^WHITE^) ^AQUA^ANSI Description: ^NORMAL^"
      REF @ ansidesc "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^4^WHITE^) ^AQUA^HTML Description: ^NORMAL^"
 
      REF @ htmldesc "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^5^WHITE^) ^AQUA^Container? "
      REF @ PROPS-container? getpropstr "yes" stringcmp not
      if "^CSUCC^Yes" else "^CFAIL^No" then strcat ansi_notify
      me @ "^YELLOW^6^WHITE^) ^AQUA^Puppet?    " REF @ "ZOMBIE" flag?
      if "^CSUCC^Yes" else "^CFAIL^No" then strcat ansi_notify
      me @ "^YELLOW^7^WHITE^) ^AQUA^Vehicle?   " REF @ "VEHICLE" flag?
      if "^CSUCC^Yes" else "^CFAIL^No" then strcat ansi_notify
      me @ "^RED^Q^WHITE^)^RED^uit the Editor." ansi_notify
      me @ " " notify
      me @ "^BROWN^Enter an option below [1-7,Q]:" ansi_notify
      BEGIN
         read "\r" over over strcat strcat "\r1\r2\r3\r4\r5\r6\r7\rQ\r" swap
         instring not WHILE pop
         "^CFAIL^Invalid option.  Enter an option below [1-7,Q]:" atell
      REPEAT
      Option !
      Option @ "1" stringcmp not if
         me @ "^CYAN^Enter a value below:" ansi_notify
         READ strip dup NAME-OK? over and if
            REF @ swap setname me @ "^CSUCC^Set." ansi_notify
         else
            pop me @ "^CFAIL^Invalid name." ansi_notify
         then
      then
      Option @ "2" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip setdesc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "3" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip setansidesc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "4" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip sethtmldesc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "5" stringcmp not if
         REF @ PROPS-container? over over getpropstr "yes" stringcmp not if
            remove_prop
         else
            "yes" setprop
         then
         me @ "^CSUCC^Toggled." ansi_notify
      then
      Option @ "6" stringcmp not if
         REF @ "ZOMBIE" flag? if
            REF @ "!ZOMBIE" set
         else
            REF @ "ZOMBIE" set
         then
         me @ "^CSUCC^Toggled." ansi_notify
      then
      Option @ "7" stringcmp not if
         REF @ "VEHICLE" flag? if
            REF @ "!VEHICLE" set
         else
            REF @ "VEHICLE" set
         then
         me @ "^CSUCC^Toggled." ansi_notify
      then
      Option @ "Q" stringcmp not if
         me @ "^CSUCC^Finished.  Exiting the editor." ansi_notify break
      then
   REPEAT
;
 
 
: EDIT-exit[ ref:REF -- ]
   VAR Option
   REF @ Exit? not if
      me @ "^CFAIL^Invalid object type." ansi_notify exit
   then
   #0 "_ObjEdit/Exit" getprop dup int? if
      dbref
   else
      dup string? if
         stod
      else
         dup dbref? not if
            pop #-1
         then
      then
   then
   dup ok? if dup program? else 0 then if
      REF @ dtos swap call exit
   else
      pop
   then
   BEGIN
      me @ "^WHITE^** ^BLUE^Exit Editor: ^BLUE^" REF @ unparseobj
      REF @ name strlen strcut "^^" "^" subst
           "^CINFO^" swap strcat swap "^^" "^" subst swap strcat strcat
           " ^WHITE^**" strcat ansi_notify
      me @ " " notify
      me @ " ^YELLOW^1^WHITE^) ^AQUA^Current Name: ^BLUE^" REF @ unparseobj
      REF @ name strlen strcut "^^" "^" subst
           "^CINFO^" swap strcat swap "^^" "^" subst swap strcat strcat ansi_notify
      me @ " ^YELLOW^2^WHITE^) ^AQUA^Description: ^NORMAL^"
      REF @ desc "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ " ^YELLOW^3^WHITE^) ^AQUA^ANSI Description: ^NORMAL^"
      REF @ ansidesc "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ " ^YELLOW^4^WHITE^) ^AQUA^HTML Description: ^NORMAL^"
      REF @ htmldesc "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ " ^YELLOW^5^WHITE^) ^AQUA^Enter Other Room Msg (Drop): ^NORMAL^"
      REF @ drop "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ " ^YELLOW^6^WHITE^) ^AQUA^Enter Other Room Msg (ODrop): ^NORMAL^"
      REF @ odrop "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ " ^YELLOW^7^WHITE^) ^AQUA^Success Message: ^NORMAL^"
      REF @ succ "^^" "^" subst dup not
 
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ " ^YELLOW^8^WHITE^) ^AQUA^O-Success Message: ^NORMAL^"
      REF @ osucc "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ " ^YELLOW^9^WHITE^) ^AQUA^Failure Message: ^NORMAL^"
      REF @ fail "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^10^WHITE^) ^AQUA^O-Failure Message: ^NORMAL^"
      REF @ ofail "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^11^WHITE^) ^AQUA^Visible? ^NORMAL^"
      REF @ "LIGHT" flag? REF @ dup getlink room? swap "DARK" flag? not and or
      if "^CSUCC^Yes" else "^CFAIL^No" then strcat ansi_notify
      me @ "^YELLOW^12^WHITE^) ^AQUA^Exit Lookthru: ^NORMAL^"
      REF @ SETTING-exit_shown getpropstr "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^13^WHITE^) ^AQUA^Exit Lookthru Notify: ^NORMAL^"
      REF @ SETTING-exit_notify getpropstr "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^14^WHITE^) ^AQUA^Exit Lookthru Message: ^NORMAL^"
      REF @ SETTING-exit_lookthru getpropstr "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ " ^RED^Q^WHITE^)^RED^uit the Editor." ansi_notify
      me @ " " notify
      me @ "^BROWN^Enter an option below [1-14,Q]:" ansi_notify
      BEGIN
         read "\r" over over strcat strcat
         "\r1\r2\r3\r4\r5\r6\r7\r8\r9\r10\r11\r12\r13\r14\rQ\r" swap instring
         not WHILE pop
         "^CFAIL^Invalid option.  Enter an option below [1-14,Q]:" atell
      REPEAT
      Option !
      Option @ "1" stringcmp not if
         me @ "^CYAN^Enter a value below:" ansi_notify
         READ strip dup NAME-OK? over and if
            REF @ swap setname me @ "^CSUCC^Set." ansi_notify
         else
            pop me @ "^CFAIL^Invalid name." ansi_notify
         then
      then
      Option @ "2" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip setdesc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "3" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip setansidesc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "4" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip sethtmldesc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "5" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip setdrop me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "6" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip setodrop me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "7" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip setsucc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "8" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip setosucc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "9" stringcmp not if
 
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip setfail me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "10" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip setofail me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "11" stringcmp not if
         REF @ "LIGHT" flag? REF @ dup getlink room? swap "DARK" flag? not and
         or if
            REF @ "!LIGHT" set REF @ "DARK" set
         else
            REF @ "LIGHT" set REF @ "!DARK" set
         then
         me @ "^CSUCC^Toggled." ansi_notify
      then
      Option @ "12" stringcmp not if
         me @ "^BROWN^Yes  ^NORMAL^= LNDSEC" ansi_notify
         me @ "^BROWN^L    ^NORMAL^= Horizontal Line" ansi_notify
         me @ "^BROWN^N    ^NORMAL^= Room Name" ansi_notify
         me @ "^BROWN^D    ^NORMAL^= Description" ansi_notify
         me @ "^BROWN^S    ^NORMAL^= Success/Failure Messages" ansi_notify
         me @ "^BROWN^E    ^NORMAL^= Exit Listing" ansi_notify
         me @ "^BROWN^C    ^NORMAL^= Contents Listing" ansi_notify
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ SETTING-exit_shown read strip setprop
         me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "13" stringcmp not if
         me @ "^BROWN^%n = Player name" ansi_notify
         me @ "^CNOTE^This accepts MPI code." ansi_notify
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ SETTING-exit_notify read strip setprop
         me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "14" stringcmp not if
         me @ "^BROWN^%n = Exit owner name" ansi_notify
         me @ "^CNOTE^This accepts MPI code." ansi_notify
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ SETTING-exit_lookthru read strip setprop
         me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "Q" stringcmp not if
         me @ "^CSUCC^Finished.  Exiting the editor." ansi_notify break
      then
   REPEAT
;
 
 
: EDIT-program[ ref:REF -- ]
   VAR Option
   REF @ Program? not if
      me @ "^CFAIL^Invalid object type." ansi_notify exit
   then
   #0 "_ObjEdit/Program" getprop dup int? if
      dbref
   else
      dup string? if
         stod
      else
         dup dbref? not if
            pop #-1
         then
      then
   then
   dup ok? if dup program? else 0 then if
      REF @ dtos swap call exit
   else
      pop
   then
   BEGIN
      me @ "^WHITE^** ^BLUE^Program Editor: ^RED^" REF @ unparseobj
      REF @ name strlen strcut "^^" "^" subst
           "^CINFO^" swap strcat swap "^^" "^" subst swap strcat strcat
           " ^WHITE^**" strcat ansi_notify
      me @ " " notify
      REF @ "/.Debug" propdir? if
         me @ "^CINFO^Last Crash Info:" ansi_notify
         me @ " ^CSUCC^-  Error Count: ^YELLOW^"
         REF @ "/.Debug/ERRcount" getpropval intostr strcat ansi_notify
         me @ " ^CSUCC^-   Last Crash: ^YELLOW^"
         REF @ "/.Debug/LastCrash" getpropval
         "%A %B %e, %Y %I:%M:%S %p %Z" swap timefmt "^^" "^" subst strcat
         ansi_notify
         me @ " ^CSUCC^-   Last Error: ^YELLOW^"
         REF @ "/.Debug/LastERR" getpropstr "^^" "^" subst strcat ansi_notify
         me @ " ^CSUCC^- Last Command: ^YELLOW^"
         REF @ "/.Debug/LastCMD" getpropstr "^^" "^" subst strcat ansi_notify
         me @ " ^CSUCC^-    Last Args: ^YELLOW^"
         REF @ "/.Debug/LastARG" getpropstr "^^" "^" subst strcat ansi_notify
         me @ " ^CSUCC^-  Last Player: ^YELLOW^"
         REF @ "/.Debug/LastPlayer" getpropval dbref unparseobj "^^" "^" subst
         strcat ansi_notify
         me @ " " notify
      then
      REF @ "/~MUF" propdir? if
         me @ "^CINFO^Last MUF Run info with MUFCOUNT set:" ansi_notify
         me @ " ^CSUCC^- Last Started: ^YELLOW^"
         REF @ "/~MUF/Start" getpropval "%A %B %e, %Y %I:%M:%S %p %Z"
         swap timefmt "^^" "^" subst strcat ansi_notify
         me @ " ^CSUCC^-     Ended At: ^YELLOW^"
         REF @ "/~MUF/End" getpropval "%A %B %e, %Y %I:%M:%S %p %Z"
         swap timefmt "^^" "^" subst strcat ansi_notify
         me @ " ^CSUCC^- Instructions: ^YELLOW^"
         REF @ "/~MUF/Count" getpropval intostr strcat
         me @ " ^CSUCC^-      Trigger: ^YELLOW^"
         REF @ "/~MUF/Trig" getpropval dbref unparseobj "^^" "^" subst
         strcat ansi_notify
         me @ " ^CSUCC^-       Player: ^YELLOW^"
         REF @ "/~MUF/Who" getpropval dbref unparseobj "^^" "^" subst strcat
         ansi_notify
         me @ " " notify
      then
      me @ "^YELLOW^1^WHITE^) ^AQUA^Current Name: ^RED^"
      REF @ unparseobj REF @ name strlen strcut "^^" "^" subst
      "^CINFO^" swap strcat swap "^^" "^" subst swap strcat strcat
      ansi_notify
      me @ "^YELLOW^2^WHITE^) ^AQUA^Description: ^NORMAL^"
      REF @ desc "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^3^WHITE^) ^AQUA^ANSI Description: ^NORMAL^"
      REF @ ansidesc "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^4^WHITE^) ^AQUA^HTML Description: ^NORMAL^"
      REF @ htmldesc "^^" "^" subst dup not
      if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^5^WHITE^) ^AQUA^MUFCOUNT set? ^NORMAL^"
      REF @ "MUFCOUNT" flag?
      if "^CSUCC^Yes" else "^CFAIL^No" then strcat ansi_notify
      me @ "^YELLOW^6^WHITE^) ^AQUA^Viewable?     ^NORMAL^"
      REF @ "VIEWABLE" flag?
      if "^CSUCC^Yes" else "^CFAIL^No" then strcat ansi_notify
      me @ "^YELLOW^7^WHITE^) ^AQUA^Linkable?     ^NORMAL^"
      REF @ "LINK_OK" flag?
      if "^CSUCC^Yes" else "^CFAIL^No" then strcat ansi_notify
      me @ "^RED^Q^WHITE^)^RED^uit the Editor." ansi_notify
      me @ " " notify
      me @ "^BROWN^Enter an option below [1-7,Q]:" ansi_notify
      BEGIN
         read "\r" over over strcat strcat "\r1\r2\r3\r4\r5\r6\r7\rQ\r" swap
         instring not WHILE pop
         "^CFAIL^Invalid option.  Enter an option below [1-7,Q]:" atell
      REPEAT
      Option !
      Option @ "1" stringcmp not if
         me @ "^CYAN^Enter a value below:" ansi_notify
         READ strip dup NAME-OK? over and if
            REF @ swap setname me @ "^CSUCC^Set." ansi_notify
         else
            pop me @ "^CFAIL^Invalid name." ansi_notify
         then
      then
      Option @ "2" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip setdesc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "3" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip setansidesc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "4" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         REF @ read strip sethtmldesc me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "5" stringcmp not if
         REF @ "MUFCOUNT" flag? if
            REF @ "!MUFCOUNT" set
         else
            REF @ "MUFCOUNT" set
         then
         me @ "^CSUCC^Toggled." ansi_notify
      then
      Option @ "6" stringcmp not if
         REF @ "VIEWABLE" flag? if
            REF @ "!VIEWABLE" set
         else
            REF @ "VIEWABLE" set
         then
         me @ "^CSUCC^Toggled." ansi_notify
      then
      Option @ "7" stringcmp not if
         REF @ "LINK_OK" flag? if
            REF @ "!LINK_OK" set
         else
            REF @ "LINK_OK" set
         then
         me @ "^CSUCC^Toggled." ansi_notify
      then
      Option @ "Q" stringcmp not if
         me @ "^CSUCC^Finished.  Exiting the editor." ansi_notify break
      then
   REPEAT
;
 
 
: EDIT-fakeobject[ arr:FAKE -- ]
   VAR Option
   FAKE @ array_vals pop FAKE-DIR swap strcat propdir? not if
      FAKE @ array_vals pop me @ rot rot FAKE-NEW
   then
   FAKE @ array_vals pop FAKE-DIR swap strcat "/@Name" strcat over over
   getpropstr strip not if
       FAKE @ FAKE-NAME setprop
   else
       pop pop
   then
   #0 "_ObjEdit/FakeObj" getprop dup int? if
      dbref
   else
      dup string? if
         stod
      else
         dup dbref? not if
            pop #-1
         then
      then
   then
   dup ok? if dup program? else 0 then if
      FAKE @ swap call exit
   else
      pop
   then
   BEGIN
      me @ "^WHITE^** ^BLUE^Fake Object: " FAKE @ FAKE-ANSINAME strcat
      " ^NORMAL^on ^BROWN^" strcat
      FAKE @ FAKE-LOCATION dup unparseobj swap name strlen strcut "^^" "^" subst
      "^CINFO^" swap strcat swap "^^" "^" subst swap strcat
      strcat " ^WHITE^**" strcat ansi_notify
      me @ " " notify
      me @ "^YELLOW^1^WHITE^) ^AQUA^Visible? ^NORMAL^" FAKE @ FAKE-VISIBLE?
      if "^CSUCC^Yes" else "^CFAIL^No" then strcat ansi_notify
      me @ "^YELLOW^2^WHITE^) ^AQUA^Description: ^NORMAL^"
           FAKE @ "desc" FAKE-GETPROPSTR "^^" "^" subst dup not
           if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^3^WHITE^) ^AQUA^ANSI Description: ^NORMAL^"
           FAKE @ "ansidesc" FAKE-GETPROPSTR "^^" "^" subst dup not
           if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^YELLOW^4^WHITE^) ^AQUA^HTML Description: ^NORMAL^"
           FAKE @ "htmldesc" FAKE-GETPROPSTR "^^" "^" subst dup not
           if pop "^CFAIL^None." then strcat ansi_notify
      me @ "^RED^Q^WHITE^)^RED^uit the Editor." ansi_notify
      me @ " " notify
      me @ "^BROWN^Enter an option below [1-4,Q]:" ansi_notify
      BEGIN
         read "\r" over over strcat strcat "\r1\r2\r3\r4\rQ\r" swap instring
         not WHILE pop
         "^CFAIL^Invalid option.  Enter an option below [1-4,Q]:" atell
      REPEAT
      Option !
      Option @ "1" stringcmp not if
         FAKE @ FAKE-VISIBLE? if
            FAKE @ array_vals pop FAKE-DIR swap strcat
            over over "/Ok?" strcat remove_prop
            over over "/@Ok?" strcat remove_prop
            "/Show" strcat remove_prop
         else
            FAKE @ array_vals pop FAKE-DIR swap strcat
            "/@Ok?" strcat "yes" setprop
         then
         me @ "^CSUCC^Toggled." ansi_notify
      then
      Option @ "2" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         FAKE @ "desc" read strip FAKE-SETPROP me @ "^CSUCC^Done." ansi_notify
      then
      Option @ "3" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         FAKE @ "ansidesc" read strip FAKE-SETPROP "^CSUCC^Done." atell
      then
      Option @ "4" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         FAKE @ "htmldesc" read strip FAKE-SETPROP "^CSUCC^Done." atell
      then
      Option @ "Q" stringcmp not if
         me @ "^CSUCC^Finished.  Exiting the editor." ansi_notify break
      then
   REPEAT
;
 
 
: EDIT-fakes[ arr:FAKE -- ]
   VAR Option VAR STRlist
   #0 "_ObjEdit/FakeObj" getprop dup int? if
      dbref
   else
      dup string? if
         stod
      else
         dup dbref? not if
            pop #-1
         then
      then
   then
   dup ok? if dup program? else 0 then if
      FAKE @ swap call exit
   else
      pop
   then
   FAKE @ 1 array_getitem strip if
      FAKE @ array_vals pop FAKE-RMATCH FAKE-OK? if
         FAKE @ array_vals pop FAKE-RMATCH FAKE !
      then
      FAKE @ EDIT-fakeobject exit
   then
   BEGIN
      FAKE @ 1 array_getitem strip if
         FAKE @ array_vals pop FAKE-RMATCH FAKE-OK? if
            FAKE @ array_vals pop FAKE-RMATCH FAKE !
         then
         FAKE @ EDIT-fakeobject "" FAKE @ 1 array_setitem FAKE !
      then
      me @ "^WHITE^** ^BLUE^Fake Object Editor on: "
      FAKE @ 0 array_getitem dup unparseobj swap name strlen strcut
      "^^" "^" subst "^CINFO^" swap strcat swap "^^" "^" subst swap strcat
      strcat " ^WHITE^**" strcat ansi_notify
      me @ " " notify "" STRlist !
      FAKE @ 0 array_getitem FAKE-GETFAKES
      FOREACH
         swap pop
         FAKE-ANSINAME STRlist @ dup if "^NORMAL^, " strcat then swap strcat
         STRlist !
 
      REPEAT
      STRlist @ if
         me @ "^CYAN^Fakes: " STRlist @ strcat ansi_notify
         me @ " " notify
      then
      me @ "^YELLOW^1^WHITE^) ^AQUA^Edit/Create a Fake Object." ansi_notify
      me @ "^YELLOW^2^WHITE^) ^AQUA^Remove a Fake Object." ansi_notify
      me @ "^RED^Q^WHITE^)^RED^uit the Editor." ansi_notify
      me @ " " notify
      me @ "^BROWN^Enter an option below [1-2,Q]:" ansi_notify
      BEGIN
         read "\r" over over strcat strcat "\r1\r2\rQ\r" swap instring not
         WHILE pop
         "^CFAIL^Invalid option.  Enter an option below [1-2,Q]:" atell
      REPEAT
      Option !
      Option @ "1" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         read strip dup ":" instr over "/" instr or not over and if
            FAKE @ 1 array_setitem FAKE ! me @ "^CSUCC^Editing." ansi_notify
         else
            pop "^CINFO^That is a silly name for a fake object!" atell
         then
      then
      Option @ "2" stringcmp not if
         me @ "^CYAN^Enter a value below [Or, blank for nothing]:" ansi_notify
         read strip dup if
            FAKE @ 0 array_getitem swap FAKE-RMATCH dup FAKE-OK? if
               FAKE-RECYCLE me @ "^CSUCC^Removed." ansi_notify
            else
               pop me @ "^CFAIL^That fake object does not exist!" ansi_notify
            then
         else
            pop me @ "^CFAIL^Nothing done." ansi_notify
         then
      then
      Option @ "Q" stringcmp not if
         me @ "^CSUCC^Finished.  Exiting the editor." ansi_notify break
      then
   REPEAT
;
 
 
: Cmd-FakeEditor[ str:Args -- ]
   Args @ strip dup not if
      pop "me"
   then
   "=" split strip swap noisy_match dup ok? not if
      pop pop
   else
      swap 2 array_make EDIT-fakes exit
   then
;
 
 
: Cmd-Editor[ str:Args -- ]
   Args @ strip dup not if
      pop "me"
   then
   noisy_match dup ok? not if
      pop
   else
      dup Room? if
         EDIT-room
      else
         dup Player? if
            EDIT-player
         else
            dup Thing? if
               EDIT-thing
            else
               dup Exit? if
                  EDIT-exit
               else
                  dup Program? if
                     EDIT-program
 
                  else
                     me @ "^CFAIL^Unknown object type." ansi_notify exit
                  then
               then
            then
         then
      then
   then
;
 
 
: DoFakeEditor ( str|ref:Obj -- )
   dup dbref? not if
      noisy_match
   then
   dup ok? not if
      pop exit
   then
   "" 2 array_make EDIT-fakes
;
 
 
: DoObjEditor ( str|ref:Obj -- )
   dup dbref? if
      dtos
   then
   Cmd-Editor
;
 
$pubdef :
$pubdef Cmd-Editor "$Lib/ObjEditors" match "Cmd-Editor" call
$pubdef Cmd-FakeEditor "$Lib/ObjEditors" match "Cmd-FakeEditor" call
$pubdef DoFakeEditor "$Lib/ObjEditors" match "DoFakeEditor" call
$pubdef DoObjEditor "$Lib/ObjEditors" match "DoObjEditor" call
$pubdef EDIT-exit "$Lib/ObjEditors" match "EDIT-exit" call
$pubdef EDIT-fakeobject "$Lib/ObjEditors" match "EDIT-fakeobject" call
$pubdef EDIT-fakes "$Lib/ObjEditors" match "EDIT-fakes" call
$pubdef EDIT-player "$Lib/ObjEditors" match "EDIT-player" call
$pubdef EDIT-program "$Lib/ObjEditors" match "EDIT-program" call
$pubdef EDIT-room "$Lib/ObjEditors" match "EDIT-room" call
 
$pubdef EDIT-thing "$Lib/ObjEditors" match "EDIT-thing" call
WIZCALL EDIT-room       ( ref:REF  -- )
WIZCALL EDIT-player     ( ref:REF  -- )
WIZCALL EDIT-thing      ( ref:REF  -- )
WIZCALL EDIT-exit       ( ref:REF  -- )
WIZCALL EDIT-program    ( ref:REF  -- )
WIZCALL EDIT-fakeobject ( arr:FAKE -- )
WIZCALL EDIT-fakes      ( arr:FAKE -- )
WIZCALL Cmd-FakeEditor  ( str:Args -- )
WIZCALL Cmd-Editor      ( str:Args -- )
WIZCALL DoFakeEditor ( str|ref:Obj -- )
WIZCALL DoObjEditor  ( str|ref:Obj -- )
