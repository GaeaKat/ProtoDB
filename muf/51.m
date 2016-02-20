(*
   cmd-@WHO v1.0.4
   Author: Chris Brine [Moose/Van]
   Version 1.0.5 [Alynna]
    - Taught it about SSL ports
 
   Version 1.0.4
    - Fixed a bug or two
 
   Version 1.0.3 [Akari]
    - Cleaned it up to be 80 column friendly and expanded the #help.
 
   Some neat features:
    - All players can see themselves listed under wizard who, but
      nobody else [unless he or she is a wizard].
    - IC tags with a + [IC] or - [OOC] after the * INTERACTIVE
      tag can be shown, if the option is turned on.
    - Alias' can be shown in the WHO listing, if the option is on.
    - 3WHO and WHO displays can have the commands switched around
      by users by setting: /_Prefs/Def3WHO?:yes
    - Smatch routines can be used in the listing.
    - Support for idle doings /_/IdleDo
    - Support for away doings /_/AwayDo [when page #away is set]
    - Random doings supported if the /_/Do listprop is set.
    - Random topics supported if the _poll listprop is set.
    - It displays properly for Pueblo users!
    - It is speedier than the previous incarnation
    - It shows all descriptors associated to the descriptor
      or player listing it.  You should have access to see that
      info anyways, dark or not.
    - Shows all connecting, web, and dark players in 3WHO and
      the normal WHO to wizards.
    - Can view who is online in your watchfor list.
    - Maybe a few other cookies that I forgot to document? :>
 
   Properties:
     /_Prefs/ExtWHO?:yes
       --> Turns on the extra WHO options if the site doesn't have them on by
           default.
     /_Prefs/ShowAlias?:yes
       --> Show the alias for the players instead of the actual name.
     /_Prefs/Def3WHO?:yes
       --> Switches around the displays for 3WHO and WHO.
 
   TODO: Add in ProtoNet support whenever that is redone.
     * NOTE: $Lib/ProtoNet will be rewritten to allow for any
             datatype to be sent over it.
 *)
 
$author Moose
$version 1.04
 
$include $Lib/Strings
 
$define descrdbref
    dup dbref? not if descrcon dup if condbref else pop #-1 then then
$enddef
$def a_dtell INTdescr @ descrdbref dup Ok? IF swap ansi_notify ELSE pop descr swap 1 unparse_ansi notify_descriptor THEN
 
$def CT_MUCK   0
$def CT_HTML   1
$def CT_PUEBLO 2
$def CT_MUF    3
$def CT_SSL    7
 
$def MinLEVEL   "WIZARD"
($undef if you want the true name in WHO or $def if you want the alias)
$undef WHO-alias
(**$def if you want to tag a + [IC] or - [OOC] after the * INTERACTIVE tag,
 $undef if not, Only works with 3WHO and normal WHO **)
$def ICWHO
($def this if you want to force +, _, and I tags, or $undef it if you
 want them optional-- This also effects whether or not you see unconnected
 descriptors on the normal WHO / 3WHO)
$undef ExtWHO
 
$ifdef ICWHO
   $include $Lib/IC
$endif
 
VAR sme
 
$define DEF-SHOW
   INTdescr @ dup dbref? if
      swap ansi_notify
   else
      dup int? if dup descr? else 0 then if
         dup descrdbref dup ok? if
            rot over dup "PUEBLO" Flag? swap "HTML" Flag? or if
               "<CODE>" swap strcat "</CODE>" strcat
            then
            "\[[0m" parse_neon
         else
            pop swap 1 unparse_ansi over dup descr_pueblo? swap descr_html?
            or if
               "<CODE>" swap strcat "</CODE><BR>" strcat
            then
         then
         notify_descriptor
      else
         0 = if
            ARRlist @ array_appenditem ARRlist !
         then
      then
   then
$enddef
 
: Dark?[ ref:ref -- int:BOLdark? ]
    ref @ location "@hidden" getpropstr "yes" strcmp not if 1 exit then
   ref @ "DARK" Flag? ref @ "LIGHT" Flag? not and
;
 
: get-name[ int:INTdescr int:Expand? -- str:STRname ]
   INTdescr @ descrdbref dup ok? if
      dup Expand? @ if
         dup unparseobj over name strlen strcut
         rot dtos split strcat strcat
      else
$ifdef WHO-alias
         truename
$else
         me @ ok? if
            me @ "/_Prefs/ShowAlias?" getpropstr "yes" stringcmp not
         else 0 then
         if
            truename
         else
            name
         then
$endif
      then
      swap Dark? if
         "[" swap strcat "]" strcat
      then
   else
      pop INTdescr @ GETdescrinfo "type" array_getitem dup CT_MUCK = over
      CT_PUEBLO = or if
         pop "[Connecting]"
      else
         dup CT_HTML = if
            pop "[WWW]"
         else
            dup CT_MUF = if
               pop "[MUF]"
            else
               pop "[Unknown]"
            then
         then
      then
   then
;
 
: get-time[ int:INTtime int:INTstop? -- str:STRtime ]
   INTtime @ dup 31536000 / if
      31536000 over over / rot rot % swap
      intostr INTstop? @ if
         swap pop "y" strcat EXIT
      else
         "y " strcat
      then
   else
      dup 604800 / if
         604800 over over / rot rot % swap
         intostr INTstop? @ if
            swap pop "w" strcat EXIT
         else
            "w " strcat
         then
      else
         dup 86400 / if
            86400 over over / rot rot % swap
            intostr INTstop? @ if
               swap pop "d" strcat EXIT
            else
               "d " strcat
            then
         else
            INTstop? @ 1 <= if
               ""
            then
         then
      then
   then
   dup String? if
      swap
   then
   dup 3600 / if
      3600
      INTstop? @ 2 >= if
         / intostr "h" strcat EXIT
      else
         over over / rot rot % swap dup intostr swap 10 < if
            "0" swap strcat
         then
         ":" strcat
         rot swap strcat swap
      then
   else
      INTstop? @ 1 <= if
         swap "00:" strcat swap
      then
   then
   dup 60 / if
      60
      INTstop? @ 2 >= if
         / intostr "m" strcat EXIT
      else
         over over / rot rot % swap dup intostr swap 10 < if
            "0" swap strcat
         then
         rot swap strcat swap pop EXIT
      then
   else
      INTstop? @ 1 <= if
         pop "00" strcat EXIT
      then
   then
   intostr "s" strcat
;
 
: grab-doing-prop[ ref:ref str:STRprop -- str:STRreturn ]
   ref @ STRprop @ array_get_proplist dup array_count if
      dup array_count random swap % array_getitem
   else
      pop ref @ STRprop @ getpropstr
   then
;
 
: get-doing[ int:ExtWHO? int:INTdescr -- str:STRdoing ]
   INTdescr @ descrdbref dup ok? if
      dup "IDLE" Flag? if
         dup "/_/IdleDo" grab-doing-prop dup if
            44 STRleft 44 strcut pop
            swap "/@/IdleDo" getpropstr
            over "[ " instr 1 = and ExtWHO? @ and if
               "^BLUE^" swap 2 strcut "^CYAN^" swap 1 escape_ansi strcat strcat
               strcat
               dup strlen 1 - strcut "^BLUE^" swap strcat strcat
            else
               1 escape_ansi
            then
            EXIT
         else
            pop
         then
      then
      dup "/_Page/Away" getpropstr "yes" stringcmp not if
         dup "/_/AwayDo" grab-doing-prop dup if
            44 STRleft 44 strcut pop
            swap "/@/AwayDo" getpropstr
            over "[ " instr 1 = and ExtWHO? @ and if
               "^BLUE^" swap 2 strcut "^CYAN^" swap 1 escape_ansi strcat strcat
               strcat
               dup strlen 1 - strcut "^BLUE^" swap strcat strcat
            else
               1 escape_ansi
            then
            EXIT
         else
            pop
         then
      then
      dup "/_/Do" grab-doing-prop
      44 STRleft 44 strcut pop
      swap "/@/Do" getpropstr
      over "[ " instr 1 = and ExtWHO? @ and if
         "^BLUE^" swap 2 strcut "^CYAN^" swap 1 escape_ansi strcat strcat strcat
         dup strlen 1 - strcut "^BLUE^" swap strcat strcat
      else
         1 escape_ansi
      then
   else
      pop "<Unconnected>"
   then
;
 
: ISEQ?[ int:dr INTdescr -- int:BOLeq? ]
   INTdescr @ dbref? if
      dr @ descrdbref INTdescr @ owner dbcmp
   else
      dr @ INTdescr @ =
   then
;
 
: DOING-title ( -- str:STRtitle )
   #0 "_poll" array_get_proplist dup array_count if
      dup array_count random swap % array_getitem
   else
      pop #0 "_poll" getpropstr dup strip not if
         pop "Doing..."
      then
   then
;
 
: explode_pmatch[ str:STRlist -- arr:ARRreflist ]
   { }list STRlist @ " " explode_array
   FOREACH
      swap pop "*" swap strcat match dup ok? if
         swap array_appenditem
      else
         pop
      then
   REPEAT
;
 
: WHO-normal ( int/dbref:INTdescr str:STRmatch int:INTwhotype -- [ arr:ARRlist ] )
   VAR! INTwhotype VAR! STRmatch 0 VAR! count 0 VAR! idlecount
   VAR ARRlist VAR dr VAR HASperm? VAR STRname VAR ISidle?
   VAR! INTdescr { }list ARRlist ! VAR ExtWHO? { }list VAR! ARRreflist
   INTdescr @ dup int? if dup descr? else 0 then if descrdbref then dup dbref?
   if dup ok? then if
      owner dup "/_Prefs/Con_Announce_List" getpropstr " " strcat
      over "/_Prefs/Con_Announce_Once" getpropstr strcat strip " " over over
      strcat strcat " #all " instring if
         pop
      else
         explode_pmatch ARRreflist !
      then
      dup MINlevel Flag? swap "EXPANDED_WHO" Power? or
   else
      pop 0
   then
   HASperm? !
$ifndef ExtWHO
   INTdescr @ descrdbref dup ok? if
      "/_Prefs/ExtWHO?" getpropstr "yes" stringcmp not
   else
      pop 0
   then
$else
   1
$endif
   ExtWHO? !
   "^GREEN^Player Name          ^PURPLE^On For ^YELLOW^Idle  ^CYAN^" DOING-title
   1 escape_ansi strcat DEF-SHOW
   #-1 DESCR_ARRAY
   FOREACH
      swap pop dr !
      HASperm? @ if
         1
      else
         dr @ INTdescr @ ISEQ? if
            dr @ descrdbref ok? ExtWHO? @ or
         else
            dr @ descrdbref dup ok? if
               "who_hides_dark" sysparm "yes" stringcmp not if
                  Dark? not
               else
                  pop 1
               then
            else
               pop 0
            then
         then
      then
      if
         count ++
         dr @ descrdbref dup ok? if
            "IDLE" Flag?
         else
            pop dr @ descridle "idletime" sysparm atoi >=
         then
         dup ISidle? ! if
            idlecount ++
         then
         dr @ 0 get-name dup STRname ! STRmatch @ smatch not if
            CONTINUE
         then
         INTwhotype @ dup if
            1 = if
               ARRreflist @ array_count if
                  dr @ descrdbref dup ok? if
                     ARRreflist @ swap array_findval array_count not if
                        CONTINUE
                     then
                  else
                     pop CONTINUE
                  then
               then
            then
         else
            pop
         then
         "^GREEN^" STRname @ 17 STRleft dup strlen 17 > if
            16 strcut pop dup "[" instr 1 = if
               15 strcut pop 1 escape_ansi "^FOREST^-^GREEN^]" strcat
            else
               1 escape_ansi "^FOREST^-" strcat
            then
         else
            1 escape_ansi
         then
         strcat
         dr @ descrtime 0 get-time "\[" swap strcat 11 STRright
         "^PURPLE^" "\[" subst strcat
         ISidle? @ ExtWHO? @ and if "I" else " " then strcat
         dr @ descridle 2 get-time "\[" swap strcat 5 STRright
         "^YELLOW^" "\[" subst strcat
         dr @ descrdbref
         dup ok? if "INTERACTIVE" Flag? else pop 0 then
         if "*" else " " then
$ifdef ICWHO
         dr @ descrdbref dup ok? ExtWHO? @ and if
            REF-IC-NOAFK? if
               "+"
            else
               "-"
            then
            "^BLUE^" swap strcat "^CYAN^" strcat
         else
            pop " ^CYAN^"
         then
$else
         " ^CYAN^"
$endif
         strcat strcat
         ExtWHO? @ dr @ get-doing strcat
         DEF-SHOW
      then
   REPEAT
   count @ dup intostr swap 1 = if
      " player is connected. "
   else
      " players are connected. "
   then
   strcat "^BLUE^" swap strcat "^YELLOW^(%a Active, %i Idle, Max was %m)" strcat
   count @ idlecount @ - intostr "%a" subst idlecount @ intostr "%i" subst
   #0 "/~Sys/Max_Connects" getpropval dup count @ < if
      pop count @ #0 "/~Sys/Max_Connects" 3 pick setprop
   then
   intostr "%m" subst DEF-SHOW
   ARRlist @ dup array_count not if
      pop
   then
;
 
: WHO-three ( int/dbref:INTdescr str:STRmatch int:INTwhotype -- arr:ARRlist )
   VAR! INTwhotype VAR! STRmatch 0 VAR! count 0 VAR! idlecount
   VAR ARRlist VAR dr VAR HASperm? VAR STRname VAR ISidle?
   "" VAR! STRshow 0 VAR! INTshow VAR ExtWHO? { }list VAR! ARRreflist
   VAR! INTdescr { }list ARRlist !
   INTdescr @ dup int? if dup descr? else 0 then if descrdbref then
   dup dbref? if dup ok? then if
      owner dup "/_Prefs/Con_Announce_List" getpropstr " " strcat
      over "/_Prefs/Con_Announce_Once" getpropstr strcat strip " " over over
      strcat strcat " #all " instring if
         pop
      else
         explode_pmatch ARRreflist !
      then
      dup MINlevel Flag? swap "EXPANDED_WHO" Power? or
   else
      pop 0
   then
   HASperm? !
$ifndef ExtWHO
   INTdescr @ descrdbref dup ok? if
      "/_Prefs/ExtWHO?" getpropstr "yes" stringcmp not
   else
      pop 0
   then
$else
   1
$endif
   ExtWHO? !
   "^GREEN^Name         ^PURPLE^OnTime ^YELLOW^Idle  ^GREEN^Name         ^PURPLE^OnTime ^YELLOW^Idle  ^GREEN^Name         ^PURPLE^Ontime ^YELLOW^Idle"
   DEF-SHOW
   #-1 DESCR_ARRAY
   FOREACH
      swap pop dr !
     0 TRY
      HASperm? @ if
         1
      else
         dr @ INTdescr @ ISEQ? if
            dr @ descrdbref ok? ExtWHO? @ or
         else
            dr @ descrdbref dup ok? if
               "who_hides_dark" sysparm "yes" stringcmp not if
                  Dark? not
               else
                  pop 1
               then
            else
               pop 0
            then
         then
      then
      if
         count ++
         dr @ descrdbref dup ok? if
            "IDLE" Flag?
         else
            pop dr @ descridle "idletime" sysparm atoi >=
         then
         dup ISidle? ! if
            idlecount ++
         then
         dr @ 0 get-name dup STRname ! STRmatch @ smatch not if
            CONTINUE
         then
         INTwhotype @ dup if
            1 = if
               ARRreflist @ array_count if
                  dr @ descrdbref dup ok? if
                     ARRreflist @ swap array_findval array_count not if
                        CONTINUE
                     then
                  else
                     pop CONTINUE
                  then
               then
            then
         else
            pop
         then
         "^GREEN^" STRname @ 14 STRleft dup strlen 14 > if
            13 strcut pop dup "[" instr 1 = if
               12 strcut pop 1 escape_ansi "^FOREST^-^GREEN^]" strcat
            else
               1 escape_ansi "^FOREST^-" strcat
            then
         else
            1 escape_ansi
         then
         strcat
         dr @ descrtime 1 get-time "\[" swap strcat 6 STRcenter
         "^PURPLE^" "\[" subst strcat
         ISidle? @ ExtWHO? @ and if "I" else " " then strcat
         dr @ descridle 2 get-time "\[" swap strcat 5 STRright
         "^YELLOW^" "\[" subst strcat
         dr @ descrdbref dup ok?
         if "INTERACTIVE" Flag? else pop 0 then
         if "*" else " " then
$ifdef ICWHO
         dr @ descrdbref dup ok? ExtWHO? @ and if
            REF-IC-NOAFK? if
               "+"
            else
               "-"
            then
            "^BLUE^" swap strcat
         else
            pop " "
         then
$else
         " "
$endif
         strcat strcat
         STRshow @ swap strcat STRshow ! INTshow dup ++ @ 3 >= if
            STRshow @ DEF-show "" STrshow ! 0 INTshow !
         then
      then
     CATCH
        pop
     ENDCATCH
   REPEAT
   INTshow @ if
      STRshow @ DEF-show
   then
   count @ dup intostr swap 1 = if
      " player is connected. "
   else
      " players are connected. "
   then
   strcat "^BLUE^" swap strcat "^YELLOW^(%a Active, %i Idle, Max was %m)" strcat
   count @ idlecount @ - intostr "%a" subst idlecount @ intostr "%i" subst
   #0 "/~Sys/Max_Connects" getpropval dup count @ < if
      pop count @ #0 "/~Sys/Max_Connects" 3 pick setprop
   then
   intostr "%m" subst DEF-SHOW
   ARRlist @ dup array_count not if
      pop
   then
;
 
: WHO-wiz-one ( int/dbref:INTdescr str:STRmatch int:INTwhotype -- arr:ARRlist )
   VAR! INTwhotype VAR! STRmatch 0 VAR! count 0 VAR! idlecount
   VAR ARRlist VAR dr VAR STRname VAR HASperm? VAR ISidle?
   VAR! INTdescr { }list ARRlist ! VAR ExtWHO? { }list VAR! ARRreflist
   INTdescr @ dup int? if dup descr? else 0 then
   if descrdbref then
   dup dbref? if dup ok? then if
      owner dup "/_Prefs/Con_Announce_List" getpropstr " " strcat
      over "/_Prefs/Con_Announce_Once" getpropstr strcat strip " " over over
      strcat strcat " #all " instring if
         pop
      else
         explode_pmatch ARRreflist !
      then
      dup MINlevel Flag? swap "EXPANDED_WHO" Power? or
   else
      pop 0
   then
   HASperm? !
$ifndef ExtWHO
   INTdescr @ descrdbref dup ok? if
      "/_Prefs/ExtWHO?" getpropstr "yes" stringcmp not
   else
      pop 0
   then
$else
   1
$endif
   ExtWHO? !
   "^RED^DS  ^GREEN^Player Name           ^CYAN^Port    ^PURPLE^On For ^YELLOW^Idle ^BLUE^Host" DEF-SHOW
   #-1 DESCR_ARRAY
   FOREACH
      swap pop dr !
     0 TRY
      HASperm? @ if
         1
      else
         dr @ INTdescr @ ISEQ? if
            dr @ descrdbref ok? ExtWHO? @ or
         else
            0
         then
      then
      not if
         dr @ descrdbref dup ok? if
            "who_hides_dark" sysparm "yes" stringcmp not if
               Dark? not
            else
               pop 1
            then
         else
            pop 0
         then
         if
            count ++
            dr @ descrdbref dup ok? if
               "IDLE" Flag?
            else
               pop dr @ descridle "idletime" sysparm atoi >=
            then
            if
               idlecount ++
            then
         then
         CONTINUE
      then
      count ++
      dr @ descrdbref dup ok? if
         "IDLE" Flag?
      else
         pop dr @ descridle "idletime" sysparm atoi >=
      then
      dup ISidle? ! if
         idlecount ++
      then
      dr @ 0 get-name dr @ 1 get-name STRname ! STRmatch @ smatch not if
         CONTINUE
      then
      INTwhotype @ dup if
         1 = if
            ARRreflist @ array_count if
               dr @ descrdbref dup ok? if
                  ARRreflist @ swap array_findval array_count not if
                     CONTINUE
                  then
               else
                  pop CONTINUE
               then
            then
         then
      else
         pop
      then
      dr @ intostr 4 STRleft "^RED^" swap strcat
      "^GREEN^" strcat STRname @ 18 STRleft dup strlen 18 > if
         17 strcut pop dup "[" instr 1 = if
            16 strcut pop 1 escape_ansi "^FOREST^-^GREEN^]" strcat
         else
            1 escape_ansi "^FOREST^-" strcat
         then
      else
         1 escape_ansi
      then
      strcat
      dr @ descrconport intostr "\[" swap strcat 9 STRright
      "^CYAN^" "\[" subst strcat
      dr @ descrtime 0 get-time "\[" swap strcat 11 STRright
      "^PURPLE^" "\[" subst strcat
      ISidle? @ ExtWHO? @ and if "I" else " " then strcat
      dr @ descridle 2 get-time "\[" swap strcat 5 STRright
      "^YELLOW^" "\[" subst strcat
      dr @ descrdbref dup ok?
      if "INTERACTIVE" Flag? else pop 0 then
      if "*^BLUE^" else " ^BLUE^" then strcat
      dr @ dup descruser strip 1 escape_ansi "@" strcat swap descrhost strip
      1 escape_ansi strcat strcat
      DEF-SHOW
     CATCH
        pop
     ENDCATCH
   REPEAT
   count @ dup intostr swap 1 = if
      " player is connected. "
   else
      " players are connected. "
   then
   strcat "^BLUE^" swap strcat "^YELLOW^(%a Active, %i Idle, Max was %m)" strcat
   count @ idlecount @ - intostr "%a" subst idlecount @ intostr "%i" subst
   #0 "/~Sys/Max_Connects" getpropval dup count @ < if
      pop count @ #0 "/~Sys/Max_Connects" 3 pick setprop
   then
   intostr "%m" subst DEF-SHOW
   ARRlist @ dup array_count not if
      pop
   then
;
 
: type-to-str[ int:type -- str:STRtype ]
   type @ CT_MUCK = if
      "Text port"
   else
      type @ CT_PUEBLO = if
         "Pueblo port"
      else
         type @ CT_HTML = if
            "Webserver"
         else
            type @ CT_MUF = if
               "MUF port"
            else
               type @ CT_SSL = if
                "SSL port"
               else
                "Unknown"
               then
            then
         then
      then
   then
;
 
: WHO-wiz-two ( int:INTdescr str:STRmatch int:INTwhotype -- [ str:STRline ] )
   VAR! INTwhotype VAR! STRmatch 0 VAR! count 0 VAR! idlecount
   VAR ARRlist VAR dr VAR STRname VAR HASperm? VAR ISidle?
   VAR! INTdescr { }list ARRlist ! VAR ExtWHO? { }list VAR! ARRreflist
   INTdescr @ dup int? if dup descr? else 0 then if descrdbref then
   dup dbref? if dup ok? then if
      owner dup "/_Prefs/Con_Announce_List" getpropstr " " strcat
      over "/_Prefs/Con_Announce_Once" getpropstr strcat strip " " over over
      strcat strcat " #all " instring if
         pop
      else
         explode_pmatch ARRreflist !
      then
      dup MINlevel Flag? swap "EXPANDED_WHO" Power? or
   else
      pop 0
   then
   HASperm? !
$ifndef ExtWHO
   INTdescr @ descrdbref dup ok? if
      "/_Prefs/ExtWHO?" getpropstr "yes" stringcmp not
   else
      pop 0
   then
$else
   1
$endif
   ExtWHO? !
   "^RED^DS  ^GREEN^Player Name       ^WHITE^Output[k]  ^YELLOW^Input[k]  ^BLUE^Commands Type" DEF-SHOW
   #-1 DESCR_ARRAY
   FOREACH
      swap pop dr !
     0 TRY
      HASperm? @ if
         1
      else
         dr @ INTdescr @ ISEQ? if
            dr @ descrdbref ok? ExtWHO? @ or
         else
            0
         then
      then
      not if
         dr @ descrdbref dup ok? if
            "who_hides_dark" sysparm "yes" stringcmp not if
               Dark? not
            else
               pop 1
            then
         else
            pop 0
         then
         if
            count ++
            dr @ descrdbref dup ok? if
               "IDLE" Flag?
            else
               pop dr @ descridle "idletime" sysparm atoi >=
            then
            if
               idlecount ++
            then
         then
         CONTINUE
      then
      count ++
      dr @ descrdbref dup ok? if
         "IDLE" Flag?
      else
         pop dr @ descridle "idletime" sysparm atoi >=
      then
      dup ISidle? ! if
         idlecount ++
      then
      dr @ 0 get-name dr @ 1 get-name STRname ! STRmatch @ smatch not if
         CONTINUE
      then
      INTwhotype @ dup if
         1 = if
            ARRreflist @ array_count if
               dr @ descrdbref dup ok? if
                  ARRreflist @ swap array_findval array_count not if
                     CONTINUE
                  then
               else
                  pop CONTINUE
               then
            then
         then
      else
         pop
      then
      dr @ intostr 4 STRleft "^RED^" swap strcat
      "^GREEN^" strcat STRname @ 18 STRleft dup strlen 18 > if
         17 strcut pop dup "[" instr 1 = if
            16 strcut pop 1 escape_ansi "^FOREST^-^GREEN^]" strcat
         else
            1 escape_ansi "^FOREST^-" strcat
         then
      else
         1 escape_ansi
      then
      strcat "^WHITE^[" strcat
      dr @ GETdescrinfo dup "output_len" array_getitem 1024 / intostr
      7 STRright "] ^YELLOW^[" strcat
      over "input_len" array_getitem 1024 / intostr 7 STRright strcat
      "] ^CYAN^[" strcat
      over "commands" array_getitem intostr 7 STRright strcat
      "] ^BLUE^" strcat
      swap "type" array_getitem type-to-str 1 escape_ansi strcat strcat
      DEF-SHOW
     CATCH
        pop
     ENDCATCH
   REPEAT
   count @ dup intostr swap 1 = if
      " player is connected. "
   else
      " players are connected. "
   then
   strcat "^BLUE^" swap strcat "^YELLOW^(%a Active, %i Idle, Max was %m)" strcat
   count @ idlecount @ - intostr "%a" subst idlecount @ intostr "%i" subst
   #0 "/~Sys/Max_Connects" getpropval dup count @ < if
      pop count @ #0 "/~Sys/Max_Connects" 3 pick setprop
   then
   intostr "%m" subst DEF-SHOW
   ARRlist @ dup array_count not if
      pop
   then
;
 
: WHO-grab ( int/d:INTdescr str:match int:whotype int:INTtype -- arr:ARRlist)
(***
   INTtype:
      0 = WHO
      1 = 3WHO
      2 = WHO !
      3 = WHO !!
   INTdescr:
      0 = Return ARRlist
     >0 = Do not return ARRlist and tell the descriptor.
    Ref = Tell a player/puppet instead of a descriptor.
 ***)
   dup 0 = if
      pop WHO-normal EXIT
   then
   dup 1 = if
      pop WHO-three EXIT
   then
   2 = if
      WHO-wiz-one EXIT
   then
   WHO-wiz-two
;
 
: WHO-help[ int:INTdescr -- ]
   "^CINFO^ProtoWHO v%1.2f - by Moose/Van" prog "_Version" getpropstr strtof swap FMTstring a_dtell
   "^CNOTE^---------------------------------------------------------------------------"
   a_dtell
   "^WHITE^WHO                  ^NORMAL^See all players that are online."
   a_dtell
   "^WHITE^WHO <smatch string>  ^NORMAL^See all players that are online matching properly."
   a_dtell
   "^WHITE^WHO #WF              ^NORMAL^See who is online in your watchfor list."
   a_dtell
   "^WHITE^3WHO                 ^NORMAL^Works much like WHO, except in three columns."
   a_dtell
   INTdescr @ descrdbref dup Ok? IF dup Player? IF MinLEVEL Flag? ELSE pop 0 THEN ELSE pop 0 THEN if
       "^WHITE^WHO !                ^NORMAL^Check the wizard who." a_dtell
       "^WHITE^WHO !!               ^NORMAL^Check the second wizard who screen."
   a_dtell
   then
   "^CYAN^Special Props: " a_dtell
   "    _prefs/Def3WHO?:yes   - Switches 3who and WHO as defaults." a_dtell
   "    _/IdleDo:<doing>      - An @doing that displays when idle." a_dtell
   "    _/AwayDo:<doing>      - An @doing that displays when p #away." a_dtell
   "    _/do#/                - A lsedit list of random @doings." a_dtell
   "    _poll#/               - Lsedit list of random polls on #0." a_dtell
   "    _prefs/ExtWHO?:yes    - Turns on extra WHO options." a_dtell
   "    _prefs/ShowAlias?:yes - Lists players by Alias instead of real name."
   a_dtell
   "^CINFO^Done." a_dtell
;
 
: main[ str:Args -- ]
   0 VAR! WizWHO? 0 VAR! INTwhotype
   "mortalwho" sysparm "no" stringcmp not if
      WizWHO? ++
   then
   descr dup descr? not if
      pop me @ dup sme !
   else
      dup descrdbref dup ok? not if
         pop #-1
      then
      sme !
   then
   Args @ strip dup "#help" stringcmp not if
      pop WHO-help EXIT
   then
   dup "#wf" stringcmp not over "#wf " instring 1 = or if
      3 strcut swap pop 1 INTwhotype !
   then
   BEGIN
      strip dup "!" instr 1 = WHILE
      1 strcut swap pop
      WizWHO? dup ++ @ 2 > if
         0 WizWHO? !
      then
   REPEAT
   strip dup "*" instr over "?" instr or not if
      "*" strcat
   then
   WizWHO? @ if
      WizWHO? @ 1 +
   else
      command @ "{3who|3w}" smatch
      me @ dup ok? if owner then Player? if
         me @ "/_Prefs/Def3WHO?" getpropstr "yes" stringcmp not if
            not
         then
      then
   then
   INTwhotype @ swap
   WHO-grab
;
