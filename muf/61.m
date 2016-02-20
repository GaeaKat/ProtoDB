(*
   Con-Announce v3.15
   Author: Chris Brine [Moose/Van]
   * v3.15: Added a #whoall command to list ALL users with you in their
            watchfor list. [Moose]
   * v3.14: Added $lib/standard support [Moose]
   * v3.13: Cleaned up formatting to 80 colums for readability and added new
            Proto1.7 directives.
   * v3.12: Whoops. I forgot to add the '%n is currently online' message
           when recoding con-announce. The old one had it, so.
   * v3.11: A bug with watchfor always being on is fixed.
            Eventually I'll do a bit of code clean up to fix a few other
            bugs that are still lieing around.  None of the bugs are a
            real big deal, so I'm in no rush, but it'll be done eventually.
   * v3.10: '#hidefrom' now lists the names instead of the dbrefs.  Whoops.
            Also made it so that listed names are unparsed if the running
            player has the proper permissions.
            Cleared up all of the rest of the old pmatch primitives so that
            they all do full-name player matches.
   * v3.09: Old bug from even the original con-announce: Ryo in the list would
            match to Ryouga and mention his connections/disconnections.
   * v3.08: WF listing on connect no longer inteferes with other stuffs output.
   * v3.07: Empty WF lists are like WF #all for wizards only.
   * v3.06: Whoops.  Fixed WF so that, if, say 'Kentaro' is in your WF list,
            then it will not have 'Ken' match to it. [as an example]
   * v3.05: The lists #who, #list, etc. lists now sort the names.
   * v3.04: Fixed the bug where it notified connections or disconnections
            of players who disconnect before the grace_time is finished.
   * v3.03: Removed the idle/unidle feature and fixed a few bugs.
   Demands ProtoMUCK v1.50 or newer.  It is 100% compatible with the old legacy
   Watchfor, and it has multiple features added.
   To set Con-Announce up, just toss this in and type:
    @register con-announce=con/announce
    @set $con/announce=LINK_OK
    @propset #0=dbref:~Connect/Announce:con-announce
    @propset #0=dbref:~Disconnect/Announce:con-announce
 *)
 
$author Moose
$version 3.15
 
$define ANSI-Tell me @ swap ansi_notify $enddef
 
$def grace_time           SETTING-announce_grace
$def announce_prop        SETTING-announce
$def announce_fmt_prop    SETTING-announce_fmt
$def announce_list_prop   SETTING-announce_list
$def announce_once_prop   SETTING-announce_once
$def announce_hide_prop   SETTING-announce_hide
$def announce_allow_prop  SETTING-announce_allow
$def logintime_prop       SETTING-announce_time
 
$include $lib/standard
 
: isdbref? ( str:STRdbref? -- int:BOLref? )
   strip dup "#" instr 1 = if
      1 strcut swap pop strip number?
   else
      pop 0
   then
;
 
: get-pname[ ref:ref -- str:STRname ]
   me @ ref @ controls me @ "SEE_ALL" Power? or me @ "SILENT" Flag? not
   and me @ ref @ dbcmp not and if
      ref @ unparseobj
   else
      ref @ name
   then
;
 
: get-matchname[ str:STRname -- str:STRname' ]
   STRname @ dup if "*" swap strcat match dup ok? else 0 then if
      get-pname
   else
      pop STRname @
   then
;
 
: ARR2STR[ arr:ARRlist -- str:STRlist ]
   "" VAR! STRlist ARRlist @
   FOREACH
      swap pop STRlist @ dup if " " strcat then swap dup dbref? if
          get-pname
      else
          dup isdbref? if
              stod get-pname
          else
              get-matchname
      then then strcat STRlist !
   REPEAT
   STRlist @
;
 
: ARR2STR2[ arr:ARRlist -- str:STRlist ]
   "" VAR! STRlist ARRlist @
   FOREACH
      swap pop STRlist @ dup if " " strcat then swap dup dbref?
      if dtos then strcat STRlist !
   REPEAT
   STRlist @
;
 
: explode_the_array[ str:STRmesg str:STRpop -- arr:ARRlist ]
   STRmesg @ STRpop @ over if explode_array else pop pop { }list then
;
 
: do-pmatch[ str:STRmatch -- ref:Plyr ]
   STRmatch @ "*" swap strcat match dup me @ dbcmp if pop #-30 then
;
 
: wf-user-func-2[ ref:REFplyr str:STRprop str:STRlist str:STRname int:BOLrem?
                  int:BOLrefs? -- ]
   VAR ARRlist VAR REFnew
   STRname @ "#all" stringcmp if
      STRname @ do-pmatch dup ok? not if
         dup #-30 dbcmp if
            pop REFplyr @ "^CFAIL^You cannot add or remove yourself."
            ansi_notify exit
         then
         dup #-2 dbcmp if
            pop REFplyr @ "^CFAIL^I do not know which player you mean!"
            ansi_notify exit
         then
         pop REFplyr @ "^CFAIL^I can't find that player." ansi_notify exit
      then
   else
      #-1
   then
   REFnew ! REFplyr @ STRprop @ getpropstr " " explode_the_array ARRlist !
   REFnew @ dup Dbref? if dup Ok? if Player? else pop 0 then else pop 0 then if
      REFnew @ Awake? REFnew @ "DARK" Flag? not me @ "WIZARD" Flag? or and if
         REFplyr @ "^GREEN^" REFnew @ name 1 ESCAPE_ansi strcat
         " is currently online." strcat ansi_notify
      then
   then
   BOLrem? @ if
      ARRlist @ REFnew @ dup ok? if BOLrefs? @ not if name else dtos then else
      pop STRname @ then array_findval array_count
      ARRlist @ STRname @ array_findval array_count or not if
         REFplyr @ "^CFAIL^%s is not in your %s list." REFnew @ dup ok?
         if name else pop STRname @ then
         "^^" "^" subst STRlist @ "^^" "^" subst swap rot fmtstring ansi_notify
         exit
      then
      ARRlist @ { REFnew @ dup ok? if
          BOLrefs? @ not if
              name
          else
              dtos
          then
      else
          pop STRname @
      then STRname @ }list swap array_diff ARRlist !
      REFplyr @ "^CSUCC^Removing %s from your %s list." REFnew @ dup ok?
      if name else pop STRname @ then
      "^^" "^" subst STRlist @ "^^" "^" subst swap rot fmtstring ansi_notify
   else
      ARRlist @ REFnew @ dup ok? if BOLrefs? @ not
          if name else pop STRname @ then
      else pop STRname @
      then
      array_findval array_count
      ARRlist @ STRname @ array_findval array_count or if
         REFplyr @ "^CFAIL^%s is already in your %s list." REFnew @ dup ok?
         if name else pop STRname @ then
         "^^" "^" subst STRlist @ "^^" "^" subst swap rot fmtstring ansi_notify
         exit
      then
      REFnew @ dup ok? if
          BOLrefs? @ not if name else dtos then
      else
          pop STRname @
      then ARRlist @ array_appenditem ARRlist !
      REFplyr @ "^CSUCC^Adding %s to your %s list." REFnew @ dup ok?
      if name else pop STRname @ then
      "^^" "^" subst STRlist @ "^^" "^" subst swap rot fmtstring ansi_notify
   then
   REFplyr @ STRprop @ ARRlist @ ARR2STR2 setprop
;
 
: wf-get-bolrem[ str:STRname2 -- str:STRname2 @ int:BOLrem? ]
   0 VAR! BOLrem?
   BEGIN
      STRname2 @ "!" stringpfx WHILE
      BOLrem? @ not BOLrem? ! STRname2 @ 1 strcut swap pop STRname2 !
   REPEAT
   STRname2 @ BOLrem? @
;
 
: wf-user-func[ ref:REFplyr str:STRprop str:STRlist str:STRname
                int:BOLrefs? -- ]
   0 VAR! BOLrem? 0 VAR! BOLrun
   "" VAR! STRname2
   STRname @ " " explode_the_array
   FOREACH
      swap pop STRname2 ! 0 BOLrem? !
      STRname2 @ wf-get-bolrem BOLrem? ! STRname2 !
      STRname2 @ if
         REFplyr @ STRprop @ STRlist @ STRname2 @ BOLrem? @ BOLrefs? @
         wf-user-func-2 1 BOLrun !
      then
   REPEAT
   BOLrun @ not if
      REFplyr @ "^CFAIL^Nothing done." ansi_notify
   then
;
 
: wf-list-prop[ ref:REFplyr str:STRprop str:STRname -- ]
   VAR STRlist VAR ARRlist
   REFplyr @ STRprop @ getpropstr " " explode_the_array ARRlist !
   ARRlist @ SORTTYPE_NOCASE_ASCEND array_sort dup ARRlist ! array_count if
      ARRlist @ "#all" array_findval array_count not if
         ARRlist @ ARR2STR STRlist !
      else
         "*Everyone*" STRlist !
      then
   else
      "*Nobody*" STRlist !
   then
   REFplyr @ "^CINFO^%s: ^CNOTE^%s" STRname @ "^^" "^" subst
   STRlist @ "^^" "^" subst swap rot fmtstring ansi_notify
;
 
: wf-clean-prop[ ref:REFplyr str:STRprop -- ]
   "" VAR! STRlist
   REFplyr @ STRprop @ getpropstr " " explode_the_array
   FOREACH
      swap pop dup "#all" stringcmp not not if
          "*" swap strcat match dup ok?
      else 1 then if
         dup dbref? if name then STRlist @ dup if " " strcat then
         swap strcat STRlist !
      else
         pop
      then
   REPEAT
   REFplyr @ STRprop @ STRlist @ setprop
;
 
: wf-clean[ ref:REFplyr -- ]
   REFplyr @ announce_list_prop   wf-clean-prop
   REFplyr @ announce_once_prop   wf-clean-prop
   REFplyr @ announce_hide_prop   wf-clean-prop
   REFplyr @ announce_allow_prop  wf-clean-prop
   REFplyr @ "^CSUCC^Finished cleaning watchfor properties." ansi_notify
;
 
: wf-clear[ ref:REFplyr -- ]
   REFplyr @ "^CINFO^WARNING: All watchfor data will be removed." ansi_notify
   REFplyr @ "^CNOTE^Are you sure you wish to do this? (Type 'yes' and enter if you are sure)" ansi_notify
   read "yes" stringcmp if
      REFplyr @ "^CFAIL^Aborted." ansi_notify exit
   then
   REFplyr @ announce_list_prop   remove_prop
   REFplyr @ announce_once_prop   remove_prop
   REFplyr @ announce_hide_prop   remove_prop
   REFplyr @ announce_allow_prop  remove_prop
   REFplyr @ "^CSUCC^Finished cleaning watchfor properties." ansi_notify
;
 
: wf-hidefrom?[ ref:REFplyr ref:WFplyr -- int:BOLyes? ]
   WFplyr @ "WIZARD" flag? if 0 exit then
    REFplyr @ location "@hidden" getpropstr "yes" strcmp not if 1 exit then
   REFplyr @ "DARK" flag? REFplyr @ "LIGHT" flag? not and if 1 exit then
   REFplyr @ announce_allow_prop getpropstr " " explode_the_array
   dup "#all" array_findval array_count swap WFplyr @ dtos array_findval
   array_count or if 0 exit then
   REFplyr @ announce_hide_prop getpropstr " " explode_the_array
   dup "#all" array_findval array_count swap WFplyr @ dtos array_findval
   array_count or
;
 
: array_findval2[ arr:ARRlist ref:REFitem -- arr:Vals ]
   { }list ARRlist @
   FOREACH
      dup string? if
         strip dup if
            "*" swap strcat match
         else
            pop #-1
         then
      then
      REFitem @ dbcmp if
         swap array_appenditem
      else
         pop
      then
   REPEAT
;
 
: Announce_Connect?[ ref:REFplyr ref:WFplyr int:BOLall? -- int:BOLyes? ]
  0 TRY
   VAR BOLlocal? BOLall? @ 10 / if 1 else 0 then BOLlocal? !
   WFplyr @ announce_list_prop getpropstr " " explode_the_array
   BOLall? @ if dup "#all" array_findval array_count WFplyr @ "W" flag?
   if over array_count not or then
   else 0 then swap REFplyr @ array_findval2 array_count or
   WFplyr @ announce_once_prop getpropstr " " explode_the_array
   BOLall? @ if dup "#all" array_findval array_count
   else 0 then swap REFplyr @ array_findval2 array_count or or
   BOLlocal? @ if
      REFplyr @ location WFplyr @ location dbcmp
      REFplyr @ location "DARK" flag? not and not and
   then
  CATCH
   prog owner swap notify
  ENDCATCH
;
 
: Announce_Disconnect?[ ref:REFplyr ref:WFplyr int:BOLall? -- int:BOLyes? ]
   VAR BOLlocal? BOLall? @ 10 / if 1 else 0 then BOLlocal? !
   WFplyr @ announce_list_prop getpropstr " " explode_the_array
   BOLall? @ if dup "#all" array_findval array_count WFplyr @ "W" flag?
   if over array_count not or then
   else 0 then swap REFplyr @ array_findval2 array_count or
   WFplyr @ announce_once_prop getpropstr " " explode_the_array
   BOLall? @ if dup "#all" array_findval array_count
   else 0 then swap REFplyr @ array_findval2 array_count or or
   BOLlocal? @ if
      REFplyr @ location WFplyr @ location dbcmp
      REFplyr @ location "DARK" flag? not and not and
   then
   if 2 else 0 then
;
 
: getmesgprop[ ref:REFplyr str:STRmesgprop -- str:STRreturn ]
   REFplyr @ STRmesgprop @ getpropstr dup strip not if
      pop #0 STRmesgprop @ getpropstr dup strip not if
         pop "Somewhere on the muck, %n has %v."
      then
   then
;
 
: Event-Tell[ ref:REFplyr ref:WFplyr str:STRmesgprop str:STRverb -- ]
   WFplyr @ STRmesgprop @ getmesgprop "" swap
   BEGIN
      dup "%" instr WHILE
      dup "%" instr 1 - strcut 1 strcut swap pop rot rot strcat swap 1 strcut
      swap
      dup "%" stringcmp not if
         pop swap "%" strcat swap CONTINUE
      then
      dup "n" stringcmp not if
         pop swap REFplyr @ name "^^" "^" subst strcat swap CONTINUE
      then
      dup "v" stringcmp not if
         pop swap STRverb @ "^^" "^" subst strcat swap CONTINUE
      then
      dup "t" stringcmp not if
         pop swap "%X" systime timefmt strcat swap CONTINUE
      then
      dup "l" stringcmp not if
         pop WFplyr @ "WIZARD" flag? if
            swap REFplyr @ location name "^^" "^" subst strcat swap
         else
            swap "somewhere on the muck" strcat swap
         then
         CONTINUE
      then
      pop
   REPEAT
   strcat WFplyr @ "^CMOVE^" rot strcat ansi_notify
;
 
: Queued_Events[ addr:ADDRfunc ref:REFplyr str:STRmesgprop str:STRverb
                 int:WizOnly? -- ]
   { }list VAR! ARRwait VAR REF
   online_array BACKGROUND
   FOREACH
      REF ! pop
      REF @ REFplyr @ dbcmp if CONTINUE then
      REF @ announce_prop getpropstr "yes" stringcmp not not if
         CONTINUE
      then
      REFplyr @ REF @ wf-hidefrom? if CONTINUE then
      REFplyr @ REF @ 11 ADDRfunc @ EXECUTE (ref:REFplyr ref:WFplyr
                                             int:BOLall? -- int:BOLyes?)
      dup if
         2 = REF @ "WIZARD" flag? or if
            WizOnly? @ not REF @ "WIZARD" flag? or if
               REFplyr @ REF @ STRmesgprop @ STRverb @ Event-Tell
            then
         else
            REF @ ARRwait @ array_appenditem ARRwait !
         then
      else
         pop
      then
   REPEAT
   ARRwait @ array_count not if exit then
   grace_time sleep (--->) ARRwait @
   FOREACH
      swap pop dup awake? not if pop CONTINUE then
      REFplyr @ awake? REFplyr @ dup "DARK" Flag? not swap "LIGHT" Flag? or
      and not if
         pop BREAK
      then
      REFplyr @ swap STRmesgprop @ STRverb @ Event-Tell
   REPEAT
   me @ logintime_prop remove_prop
;
 
: CHECK-prop[ arr:ARRreflist str:STRprop ref:REFplyr int:INTblank? -- arr:ARRreflist' ]
   ARRreflist @ STRprop @
   over over REFplyr @ name ARRAY_filter_prop
   3 pick 3 pick REFplyr @ name " *" strcat ARRAY_filter_prop ARRAY_union
   3 pick 3 pick REFplyr @ name "* " swap strcat ARRAY_filter_prop ARRAY_union
   3 pick 3 pick REFplyr @ name "* " swap strcat " *" strcat ARRAY_filter_prop ARRAY_union
   3 pick 3 pick "#all" ARRAY_filter_prop ARRAY_union
   3 pick 3 pick "#all *" ARRAY_filter_prop ARRAY_union
   3 pick 3 pick "* #all" ARRAY_filter_prop ARRAY_union
   3 pick 3 pick "* #all *" ARRAY_filter_prop ARRAY_union
   rot rot
   INTblank? @ IF
      "" ARRAY_filter_prop { }list swap
      FOREACH
         swap pop dup "WIZARD" Flag? IF
            swap ARRAY_appenditem
         ELSE
            pop
         THEN
      REPEAT
      ARRAY_union
   ELSE
      pop pop
   THEN
;
 
: wf-who-all[ ref:REFplyr -- ]
           VAR  INTcount
   { }list VAR! ARRlist
   #-1 "" "P" FIND_ARRAY
   announce_prop "y*" ARRAY_filter_prop
   dup announce_list_prop REFplyr @ 1 CHECK-prop
   swap announce_once_prop REFplyr @ 0 CHECK-prop ARRAY_union
   "^CINFO^Players watching you: ^NORMAL^"
   swap SORTTYPE_NOCASE_ASCEND array_sort dup array_count dup -- INTcount ! not if
      pop "*Nobody*"
   ELSE
      "" swap
      FOREACH
         "^WHITE^" over name 1 escape_ansi strcat
         swap dup Awake? IF
            "DARK" Flag?
            REFplyr @ "MAGE" Flag? not and
         ELSE
            pop 1
         THEN
         IF
            " ^FOREST^[^GREEN^Z^FOREST^]" strcat
         THEN
         3 pick IF
            swap INTcount @ = IF
               "^NORMAL^, and "
            ELSE
               "^NORMAL^, "
            THEN
            swap strcat
         ELSE
            swap pop
         THEN
         strcat
      REPEAT
   THEN
   strcat REFplyr @ swap ANSI-Tell
;
 
: wf-who[ ref:REFplyr -- ]
   { }list VAR! ARRlist
   online_array
   FOREACH
      swap pop
      dup REFplyr @ dbcmp if pop CONTINUE then
      REFplyr @ over wf-hidefrom? if pop CONTINUE then
      REFplyr @ over 1 Announce_Disconnect? if
         ARRlist @ array_appenditem ARRlist !
      else
         pop
      then
   REPEAT
   REFplyr @ "^CINFO^Online players watching you: ^CNOTE^"
   ARRlist @ SORTTYPE_NOCASE_ASCEND array_sort dup array_count not if
      pop "*Nobody*"
   else
      dup array_count online_array array_count 1 - = if
         pop "*Everyone*"
      else
         ARR2STR
      then
   then
   "^^" "^" subst strcat ansi_notify
;
 
: ALIGNleft[ str:STRmesg int:Length -- ]
   STRmesg @
   BEGIN
      dup 1 parse_ansi ansi_strlen Length @ < WHILE
      " " strcat
   REPEAT
;
 
: wf-list[ ref:REFplyr -- ]
   { }list VAR! ARRmsg
   { }list VAR! ARRlist 0 VAR! INTplyrs "" VAR! STRlist
   online_array
   FOREACH
      swap pop dup REFplyr @ wf-hidefrom? if pop CONTINUE then
      dup REFplyr @ 0 Announce_Connect? if
         ARRlist @ array_appenditem ARRlist !
      else
         pop
      then
   REPEAT
   ARRlist @ array_count not if
      REFplyr @ "^CFAIL^Nobody that you are watching for is online."
      ansi_notify exit
   then
   "^CINFO^Players online who you are watching for:" ARRmsg @ array_appenditem
   ARRmsg !
   ARRlist @ 1 array_nunion SORTTYPE_NOCASE_ASCEND array_sort
   FOREACH
      swap pop
      dup name "^^" "^" subst "^CNOTE^" swap strcat
      over "INTERACTIVE" flag? if "^CINFO^*" else " " then swap strcat
      over        "IDLE" flag? if "^CINFO^I" else " " then swap strcat 19
      ALIGNleft
      STRlist @ swap strcat STRlist ! INTplyrs ++
      INTplyrs @ 3 > if
         STRlist @ ARRmsg @ array_appenditem ARRmsg ! 0 INTplyrs ! "" STRlist !
      then
   REPEAT
   STRlist @ if
      STRlist @ ARRmsg @ array_appenditem ARRmsg !
   then
   "^CINFO^Done." ARRmsg @ array_appenditem { REFplyr @ }list array_ansi_notify
;
 
: wf-help ( -- )
   prog "_Version" getpropstr strtof "^CINFO^Con-Announce v%1.2f - by Moose" FMTstring ANSI-Tell
   "^CNOTE^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" ANSI-Tell
   "^WHITE^wf #help               ^NORMAL^This screen" ANSI-Tell
   "^WHITE^wf #on                 ^NORMAL^Turn on login/logoff watching [#off to turn it off]" ANSI-Tell
   "^WHITE^wf [!]<plyr>           ^NORMAL^Add <plyr> (Put in a '!' to remove <plyr>)" ANSI-Tell
   "^WHITE^wf [!]#all             ^NORMAL^Same as above, except for all players" ANSI-Tell
   "^WHITE^wf #temp [!]<plyr>     ^NORMAL^Same as above, except for a temporary list" ANSI-Tell
   "^WHITE^wf #allow [!]<plyr>    ^NORMAL^Same as above, but allows <plyr> to see you when" ANSI-Tell
   "                       ^NORMAL^hiding" ANSI-Tell
   "^WHITE^wf #hidefrom [!]<plyr> ^NORMAL^Same as above, except for a hiding from <plyr> list" ANSI-Tell
   "^WHITE^wf #hidefrom [!]#all   ^NORMAL^Hide from all, or put in the ! to remove the #all" ANSI-Tell
   "                       ^NORMAL^option" ANSI-Tell
   "^WHITE^wf #allow              ^NORMAL^List who is in your allow list" ANSI-Tell
   "^WHITE^wf #hidefrom           ^NORMAL^List who is in your hidefrom list" ANSI-Tell
   "^WHITE^wf #temp               ^NORMAL^List who is in your temporary list" ANSI-Tell
   "^WHITE^wf #list               ^NORMAL^List who is in your list" ANSI-Tell
   "^WHITE^wf #clean              ^NORMAL^Cleans up the mess in your lists" ANSI-Tell
   "^WHITE^wf #clear              ^NORMAL^Clears all of your lists" ANSI-Tell
   "^WHITE^wf #who                ^NORMAL^List which online players are watching you" ANSI-Tell
   "^WHITE^wf #whoall             ^NORMAL^List all players that are watching you" ANSI-Tell
   "^WHITE^wf                     ^NORMAL^See who is online in your watchfor list" ANSI-Tell
   "Type '^WHITE^wf #help2^NORMAL^' for more information." ANSI-Tell
   "^CINFO^Done." ANSI-Tell
;
 
: wf-help2 ( -- )
   prog "_Version" getpropstr strtof "^CINFO^Con-Announce v%1.2f - by Moose" FMTstring ANSI-Tell
   "^CNOTE^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" ANSI-Tell
   " ^WHITE^How to change the watchfor connect/disconnect message:" ANSI-Tell
   "All you have to do is type: @set me=%s:<new message>" announce_fmt_prop
   "^^" "^" subst "%s" subst ANSI-Tell
   "The substitutions for the message are the following:" ANSI-Tell
   " - %n = player's name" ANSI-Tell
   " - %v = format's verb [ie. connected, disconnected]" ANSI-Tell
   " - %t = current time" ANSI-Tell
   " - %l = player's location [Only works for wizards]" ANSI-Tell
   "Default message string: Somewhere on the muck, %n has %v." ANSI-Tell
   "Oh, and for a little bonus: Neon ansi codes work fine in the messages."
   ANSI-Tell
   "Type '^WHITE^man neon ansi^NORMAL^' for help on the neon ansi codes."
   ANSI-Tell
   "^CINFO^Done." ANSI-Tell
;
 
: main[ str:Args -- ]
   VAR STRverb VAR STRmesgprop VAR ADDRfunc 0 VAR! INTtemp 0 VAR! WizOnly?
   command @ "Queued Event." stringcmp not if
      0 sleep
      Args @ "connect" stringcmp not if
         descr dup descr? if
            descrcon condbref
         else
            pop #-1
         then
         me @ dbcmp not if
            EXIT
         then
         me @ logintime_prop systime setprop
         me @ announce_once_prop remove_prop
         me @ awake? 1 > if "reconnected" else "connected" then STRverb !
         announce_fmt_prop STRmesgprop ! 'Announce_Connect? ADDRfunc !
         1 INTtemp !
      else
         Args @ "disconnect" stringcmp not if
            descr descr? if
               EXIT
            then
            me @ announce_once_prop remove_prop
            systime me @ logintime_prop getpropval - grace_time <= if
               1 WizOnly? !
            then
            me @ logintime_prop remove_prop
            me @ awake?  if "dropped a connection" else "disconnected" then
            STRverb ! announce_fmt_prop STRmesgprop !
            'Announce_Disconnect? ADDRfunc !
         else
           exit
         then
      then
      me @ announce_prop getpropstr "y" stringpfx if
         me @ announce_list_prop getpropstr INTtemp @ and if
            1 sleep me @ wf-list
         then
      then
      ADDRfunc @ me @ STRmesgprop @ STRverb @ WizOnly? @ Queued_Events EXIT
   then
   "wwf" command @ stringcmp not if
      pop "#who"
   then
   Args @ strip Args !
   Args @ "#" instr 1 = Args @ "#all" stringcmp and if
      Args @ " " split strip Args !
      dup "#help" stringcmp not if
         pop wf-help exit
      then
      dup "#help2" stringcmp not if
         pop wf-help2 exit
      then
      dup "#on" stringcmp not if
         me @ announce_prop "yes" setprop
         me @ "^CSUCC^Watchfor turned on." ansi_notify exit
      then
      dup "#off" stringcmp not if
         me @ announce_prop "no" setprop
         me @ "^CSUCC^Watchfor turned off." ansi_notify exit
      then
      dup "#who" stringcmp not if
         pop me @ wf-who exit
      then
      dup "#whoall" stringcmp not if
         pop me @ wf-who-all exit
      then
      dup "#clean" stringcmp not over "#update" stringcmp not or if
         pop me @ wf-clean exit
      then
      dup "#clear" stringcmp not if
         pop me @ wf-clear exit
      then
      dup "#list" stringcmp not if
         me @ announce_list_prop "Currently watching for" wf-list-prop exit
      then
      dup "#temp" stringcmp not if
         pop Args @ if
            me @ announce_once_prop "temporary watchfor" Args @ 0 wf-user-func
            exit
         then
         me @ announce_once_prop "Temporarily watching for" wf-list-prop exit
      then
      dup "#hide" stringcmp not over "#hidefrom" stringcmp not or if
         pop Args @ if
            me @ announce_hide_prop "hidefrom" Args @ 1 wf-user-func exit
         then
         me @ announce_hide_prop "Hiding from" wf-list-prop exit
      then
      dup "#allow" stringcmp not if
         pop Args @ if
            me @ announce_allow_prop "allow" Args @ 0 wf-user-func exit
         then
         me @ announce_allow_prop "Allowing" wf-list-prop exit
      then
   then
   Args @ not if
      me @ wf-list exit
   then
   me @ announce_list_prop "permanent watchfor" Args @ 0 wf-user-func exit
;
