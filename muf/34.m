(*
   Comsys v2.1.4
   Author: Chris Brine [Moose/Van]
           Akari [ As of 2.1 and newer ]
 
   @Register this as $Lib/Comsys and %Cmd/Comsys
 
   Warning: This requires ProtoMUCK v1.50 or later.
   How to install:
     - Toss in the program, then type:
        @register <program>=Lib/Comsys
        @action comsys;addcom;allcom;comtitle;clearcom;delcom;comlist;@ccreate;
                @cboot;@cchown;@cdestroy;@clist;@cedit;@cwho;@cemit;@cemi;@cem;
                @ce;help comsys;alias;@comlist;@addcom;@delcom;@comlist;@cban;
                @cgag;@cunban;@cungag=#0
        @link comsys=$lib/comsys
        @propset #0=dbref:_Connect/Comsys:$Lib/Comsys
        @propset #0=dbref:_Disconnect/Comsys:$Lib/Comsys
     - If you have ProtoNet installed, then type the following:
        @netreg $Lib/Comsys=Comsys
     Then, that is it!  Comsys is fully installed, and will work perfectly.
 
   What is New?
    v2.1.4: [Moose]
     - Bugfixes in @cedit
    v2.1.3: [Cutey_Honey]
     - ToDbref now uses 'match' to resolve '$lib/comsys'.  This means
       that getpropref works.  While I don't know yet if the 'random
       dropped from channel' bug is gone, at least the victim can get
       right back on.
    v2.1.2: [Akari]
     - Fixed a rare abort error due to an invalid descriptor.
    v2.1.1: [ Akari ]
     - Made it so that if the channel owner is invalid, the channel gets turned
       over to the owner of the program.
     - Added Channel timeout support. The global timeout is set via '@cedit'.
     - A wiz can set individual channels as being immune to timing out by
       using '@cedit <channel>'.
    v2.1.0: [ Akari ]
     - Cleaned up to mostly 80 column width.
     - Added new directives.
     - Beginning designs for fixing some of the remaining issues.
    v2.0.4: [In the works]
     - Fixed a bug with comtitles replacing the name--the pose got underlined.
       Fixed.
    v2.0.3:
     - Colors work in comtitle's again, and comtitles are now underlined for
       ansi users.
     - Fixed a security bug from the last version where anybody could join any
       channel.
     - Fixed another security bug where wizards didn't gain special permissions
       to join a channel and avoid being gagged, not being able to transmit,
       etc.
    v2.0.2:
     - <alias> |^_^ will now work. The | method of spoofing now does not parse
       colours.
       However, the @cemit method does.  But @cemit is limited to wizards only.
     - Made sure that the | method of spoofing always has the channel prefix,
       and also always adds the { } brackets around it.  However, @cemit does
       not do either.
     - Temporary gagging is now removed upon connection and disconnect.
     - @cwho now says if a player is offline when used by a wizard.
     - Added MPI locks for many options.
     - Changed @cchown around so that it works better and more securely.
    v2.0.1:
     - A few bug fixes.  A lot of past problems should be fixed.
    v2.0.0 [Moose/Van]
     - Full ProtoNet support!  Only supports two channels: WizNet and ProtoNet
     - Full recoding for cleaner and better to understand code.  Oh, and cleaner
       code.
     - Enhanced interface.  Just looks better, and adds a little more.
     - Better public function support.  Now your programs can do a hell of a lot
       more.
       [Note: @register this program as "$lib/comsys"]
     - No longer uses huh_command in @tune.  Huh_command will be removed in
       later versions of ProtoMUCK, thus comsys switched to the @Command propdir
     - Colour customization support.  Now people can finally have his or her own
       colours.
     - @cemit now accepts colour codes so that it'll be easier to make a custom
       @cemit/channel spoofer.
     - You can use multiple alias' with addcom and delcom now using a semicolon.
     - Better checking for if a player is on a channel or not.
     - 'Comlist' is organized a little better.
     - Admin can now set/remove others comtitles in case of profanity, etc.
 
   To do or consider:
     - Add better checking to see if an alias is in use. Ie. If it is set in
       the aliasref directory, but the channel isn't even joined... remove it.
     - A new MPI lock for autojoins was added.  It'll only force an autojoin if
       the user passes the MPI lock.  Useful for newbie channels with guest
       characters.
     - A @cmotd that shows a special MOTD for channels that are settable by
       channel admin.
     - Need to fix the 'random dropped from channel' bug.
 
   Public Functions [All are ARCHCALL]:
    CHAN-chancreate [ str:Channel                             -- int:Succ      ]
    CHAN-chandelete [ str:Channel                             -- int:Succ      ]
    CHAN-chanlist   [ ref:Plyr                                -- int:Succ      ]
    CHAN-comlist    [ ref:Plyr                                -- int:Succ      ]
    CHAN-numusers   [ str:Channel                             -- int:NumUsers  ]
    CHAN-send       [ str:Chan str:Msg                        -- int:Succ      ]
    CHAN-users      [ str:Channel                             -- arr:ARRusers  ]
    CHAN-who        [ ref:Plyr str:SRCmuck str:Channel int:ShowAll? -- int:Succ]
    COMM-help       [                                         --               ]
    USER-addcom     [ ref:Plyr str:Chan str:Alias int:Force? int:Quiet?  -- int:Succ      ]
    USER-aliases    [ ref:Plyr str:Channel                    -- arr:Alias'    ]
    USER-allcom     [ ref:Plyr str:Text                       -- int:Succ      ]
    USER-ban        [ ref:Plyr str:Channel int:BOLban?        -- int:Succ      ]
    USER-boot       [ ref:Plyr str:Channel                    -- int:Succ      ]
    USER-cemit      [ ref:Plyr str:Chan str:Text int:ForceTitle? -- int:Succ   ]
    USER-channels   [ ref:Plyr                                -- dict:Channels ]
    USER-chown      [ ref:Plyr str:Channel                    -- int:Succ      ]
    USER-clearcom   [ ref:Plyr int:Quiet?                     -- int:Succ      ]
    USER-comtitle   [ ref:Plyr str:Chan str:Title int:Quiet?  -- int:Succ      ]
    USER-delcom     [ ref:Plyr str:Alias int:Quiet?           -- int:Succ      ]
    USER-gag        [ ref:Plyr str:Channel int:BOLgag?        -- int:Succ      ]
    USER-send       [ ref:Plyr str:Chan str:Text              -- int:Succ      ]
*)
 
$author Moose Akari
$lib-version 2.14
$version 2.14
 
$include $lib/strings
 
$def atell me @ swap ansi_notify
 
: ToInt ( Arg -- int:Num )
   dup variable? if
      @
   then
   dup array? if
      0 array_getitem
   then
   dup int? if
      exit
   then
   dup string? if
      strip atoi exit
   then
   dup dbref? over float? or if
      int exit
   then
   pop 0
;
: ToDbref ( Arg -- int:Num )
   dup variable? if
      @
   then
   dup array? if
      0 array_getitem
   then
   dup dbref? if
      exit
   then
   dup int? if
      dbref exit
   then
   dup string? if
      dup match dup if swap pop exit then
      pop stod exit
   then
   dup float? or if
      int dbref exit
   then
   pop #-1
;
 
: ToStr ( Arg -- int:Num )
   dup variable? if
      @
   then
   dup array? if
      0 array_getitem
   then
   dup string? if
      exit
   then
   dup dbref? if
      dtos exit
   then
   dup int? if
      intostr exit
   then
   dup float? or if
      ftostr exit
   then
   pop ""
;
 
: ANSINAME ( ref:Object -- str:Name' )
   me @ over controls if
      dup unparseobj over name strlen strcut "^CINFO^" swap "^^" "^" subst
      strcat swap "^^" "^" subst swap strcat
   else
      dup name "^^" "^" subst
   then
   over exit? if
      "^BLUE^"
   else
      over program? if
         "^RED^"
      else
         over room? if
            "^CYAN^"
         else
            over player? if
               "^GREEN^"
            else
               "^PURPLE^"
            then
         then
      then
   then
   swap strcat swap pop
;
 
: array_put_propvals[ ref:REFobj str:STRdir arr:ARRprops -- ]
   ARRprops @
   FOREACH
      REFobj @ STRdir @ 4 rotate strcat rot setprop
   REPEAT
;
 
: array_get_propdirs[ ref:REFobj str:STRdir -- arr:ARRdirs ]
   { }list VAR! ARRdirs
   BEGIN
      REFobj @ STRdir @ NEXTPROP dup STRdir ! WHILE
      REFobj @ STRdir @ propdir? if
         STRdir @ "/" rsplit swap pop ARRdirs @ array_appenditem ARRdirs !
      then
   REPEAT
   ARRdirs @
;
 
$define ANSI-Tell  me @ swap ansi_notify                 $enddef
$define DTOS       int intostr                           $enddef
$define GETPROPVAL getprop ToInt                         $enddef
$define GETPROPREF getprop ToDBref                       $enddef
$define GETPROPSTR getprop dup if ToStr else pop "" then $enddef
 
$define CH-OBJ        prog                                    $enddef (          -- ref:dir         )
$define CHG-PCreate?  CH-OBJ "@Channel/PCreate?"              $enddef (          -- ref:dir str:prop)
$define CHG-Banned    CH-OBJ "@Config/Banned/"                $enddef (          -- ref:dir str:prop)
$define CHG-Timeout   CH-OBJ "@Config/Timeout"                $enddef (          -- ref:obj str:prop)
$define CHG-AutoBan?  CH-OBJ "@Config/AutoBan?"               $enddef (          -- ref:dir str:prop)
$define CHC-DIR       CH-OBJ "@Channel/Chan/" rot strcat      $enddef (str:chan  -- ref:dir str:prop)
$define CHC-Timeout?  CHC-DIR "/Timeout?" strcat              $enddef (str:chan  -- ref:dir str:prop)
$define CHC-LastMsg   CHC-DIR "/LastMSG" strcat               $enddef (str:chann -- ref:dir str:prop)
$define CHC-Mesgs     CHC-DIR "/Mesgs" strcat                 $enddef (str:chann -- ref:dir str:prop)
$define CHC-Name      CHC-DIR "/Name" strcat                  $enddef (str:chann -- ref:dir str:prop)
$define CHC-Owner     CHC-DIR "/Owner" strcat                 $enddef (str:chann -- ref:dir str:prop)
$define CHC-DefAlias  CHC-DIR "/DAlias" strcat                $enddef (str:chann -- ref:dir str:prop)
$define CHC-ProtoNet? CHC-DIR "/ProtoNet?" strcat             $enddef (str:chann -- ref:dir str:prop)
$define CHC-Private?  CHC-DIR "/Private?" strcat              $enddef (str:chann -- ref:dir str:prop)
$define CHC-Announce? CHC-DIR "/Announces?" strcat            $enddef (str:chann -- ref:dir str:prop)
$define CHC-Auto-On?  CHC-DIR "/Auto-On?" strcat              $enddef (str:chann -- ref:dir str:prop)
$define CHC-AutoJoin? CHC-DIR "/Auto-Join?" strcat            $enddef (str:chann -- ref:dir str:prop)
$define CHC-Cemit?    CHC-DIR "/AllowCemit?" strcat           $enddef (str:chann -- ref:dir str:prop)
$define CHC-Transmit? CHC-DIR "/Transmit?" strcat             $enddef (str:chann -- ref:dir str:prop)
$define CHC-Names?    CHC-DIR "/ShowNames?" strcat            $enddef (str:chann -- ref:dir str:prop)
$define CHC-Prefix?   CHC-DIR "/Prefix?" strcat               $enddef (str:chann -- ref:dir str:prop)
$define CHC-Title?    CHC-DIR "/ComTitles?" strcat            $enddef (str:chann -- ref:dir str:prop)
$define CHC-PermProp  CHC-DIR "/AllowedProp" strcat           $enddef (str:chann -- ref:dir str:prop)
$define CHC-TranProp  CHC-DIR "/AllowTransmitProp" strcat     $enddef (str:chann -- ref:dir str:prop)
$define CHC-PermMPI   CHC-DIR "/PermMPI" strcat               $enddef (str:chann -- ref:dir str:prop)
$define CHC-TransMPI  CHC-DIR "/TransMPI" strcat              $enddef (str:chann -- ref:dir str:prop)
$define CHC-CemitMPI  CHC-DIR "/CemitMPI" strcat              $enddef (str:chann -- ref:dir str:prop)
$define CHC-UserDIR   CHC-DIR "/Users/" strcat                $enddef (str:chann -- ref:dir str:prop)
$define CHC-AllowDIR  CHC-DIR "/Allowed/" strcat              $enddef (str:chann -- ref:dir str:prop)
$define CHC-CemitDIR  CHC-DIR "/CEmitters/" strcat            $enddef (str:chann -- ref:dir str:prop)
$define CHC-BanDIR    CHC-DIR "/Banned/" strcat               $enddef (str:chann -- ref:dir str:prop)
$define CHC-GagDIR    CHC-DIR "/Gagged/" strcat               $enddef (str:chann -- ref:dir str:prop)
$define CHC-TransDIR  CHC-DIR "/AllowTransmit/" strcat        $enddef (str:chann -- ref:dir str:prop)
$define CHC-ChownOk?  CHC-DIR "/Chown-OK" strcat              $enddef (str:chann -- ref:dir str:prop)
$define CHU-OBJ       me @                                    $enddef (          -- ref:dir         )
$define CHU-Alias     CHU-OBJ "@Channel/AliasRef/" rot strcat $enddef (str:alias -- ref:dir str:prop)
$define CHU-REF       CHU-Alias getpropstr                    $enddef (str:alias -- str:chan        )
$define CHU-AliasREF  CHU-REF                                 $enddef (str:alias -- str:chan        )
$define CHU-OBJREF    CHU-OBJ swap CHU-REF                    $enddef (str:alias -- str:dir str:chan)
$define CHU-DIR       CHU-OBJREF "@Channel/Chan/" rot strcat  $enddef (str:alias -- ref:dir str:prop)
$define CHU-Aliases   CHU-DIR "/Aliases" strcat               $enddef (str:alias -- ref:dir str:prop)
$define CHU-Comtitle  CHU-DIR "/ComTitle" strcat              $enddef (str:alias -- ref:dir str:prop)
$define CHU-Joined?   CHU-DIR "/Joined?" strcat               $enddef (str:alias -- ref:dir str:prop)
$define CHU-On?       CHU-DIR "/On?" strcat                   $enddef (str:alias -- ref:dir str:prop)
$define CHU-Gagged?   CHU-DIR "/TempGagged?" strcat           $enddef (str:alias -- ref:dir str:prop)
$define CHU-Tried?    CHU-OBJREF "@Channel/Tried?/" rot strcat $enddef (str:alias -- ref:dir str:prop)
$define CH2-DIR       CHU-OBJ "@Channel/Chan/" rot strcat     $enddef (str:chann -- ref:dir str:prop)
$define CH2-Aliases   CH2-DIR "/Aliases" strcat               $enddef (str:chann -- ref:dir str:prop)
$define CH2-ComTitle  CH2-DIR "/ComTitle" strcat              $enddef (str:chann -- ref:dir str:prop)
$define CH2-Joined?   CH2-DIR "/Joined?" strcat               $enddef (str:chann -- ref:dir str:prop)
$define CH2-On?       CH2-DIR "/On?" strcat                   $enddef (str:chann -- ref:dir str:prop)
$define CH2-Gagged?   CH2-DIR "/TempGagged?" strcat           $enddef (str:chann -- ref:dir str:prop)
$define CH2-Tried?    CHU-OBJ "@Channel/Tried?/" rot strcat   $enddef (str:chann -- ref:dir str:prop)
 
$def CH-Text        "AQUA"
$def CH-Mesg        "COMSYS/TEXT"
$def CH-Quote       "COMSYS/TEXT"
$def CH-Border      "CYAN"
$def CH-Title       "FOREST"
 
$def CHM-JoinMsg     ":has joined the channel."
$def CHM-LeaveMsg    ":has left the channel."
$def CHM-Connect     ":has connected."
$def CHM-Reconnect   ":has reconnected."
$def CHM-Disconnect  ":has disconnected."
 
$def CHAN-version    prog "_Version" getpropstr strtof "Comsys v%1.2f by Moose/Van and Akari" FMTstring
 
: USER-channels[ ref:Plyr -- dict:Channels ]
   VAR PropDIR VAR STRdir { }dict VAR! Channels VAR sme VAR STRchann
   VAR STRalias
   me @ sme ! Plyr @ me !
   "" CHU-Alias swap pop dup STRdir ! PropDIR !
   BEGIN
      CHU-OBJ PropDIR @ nextprop dup PropDIR ! WHILE
      CHU-OBJ PropDIR @ getpropstr STRchann !
      PropDIR @ STRdir @ strlen strcut swap pop STRalias !
      Channels @ array_keys array_make STRchann @ array_findval array_count if
         Channels @ STRchann @ array_getitem
      else
         { }list
      then
      STRalias @ swap array_appenditem Channels @ STRchann @ array_setitem
      Channels !
   REPEAT
   Channels @ sme @ me !
;
 
: USER-aliases[ ref:Plyr str:Channel -- arr:Alias' ]
   Plyr @ USER-Channels dup array_keys array_make Channel @ array_findval
   array_count if
      Channel @ array_getitem
   else
      pop { }list
   then
;
 
: USER-banned?[ ref:Plyr str:Channel -- int:Bol ]
   Plyr @ ok? not if
      0 exit
   then
   Plyr @ owner Plyr !
   CHG-Banned Plyr @ dtos strcat getprop dup ToStr "yes" stringcmp not
   over ToDBref Plyr @ dbcmp or
   swap ToInt Plyr @ timestamps pop pop pop = or
   Channel @ CHC-BanDIR Plyr @ dtos strcat getprop dup ToStr "yes" stringcmp not
   over ToDBref Plyr @ dbcmp or
   swap ToInt Plyr @ timestamps pop pop pop = or or
   Plyr @ "WIZARD" flag? not and
;
 
: USER-joined?[ ref:Plyr str:Channel -- int:Bol ]
   VAR sme
   Plyr @ ok? not if
      0 exit
   then
   me @ sme ! Plyr @ me !
   Channel @ CH2-Joined? getpropstr "yes" stringcmp not
   Channel @ CHC-UserDIR Plyr @ dtos strcat getprop dup ToStr "yes"
   stringcmp not
   over ToDBref Plyr @ dbcmp or
   swap ToInt Plyr @ timestamps pop pop pop = or and dup not if
      Channel @ CHC-UserDIR Plyr @ dtos strcat remove_prop
      Channel @ CH2-DIR remove_prop
   then
   sme @ me !
;
 
: CHAN-users[ str:Channel -- arr:ARRusers ]
   Channel @ CHC-UserDIR array_get_propvals { }dict swap
   FOREACH
      pop stod dup Channel @ USER-joined? if
         dup timestamps pop pop pop swap dtos rot swap array_setitem
      else
         pop
      then
   REPEAT
   Channel @ CHC-UserDIR "/" rsplit pop remove_prop
   Channel @ CHC-UserDIR "/" rsplit pop 3 pick array_count setprop
   Channel @ CHC-UserDIR 3 pick array_put_propvals
   array_keys array_make
;
 
: CHAN-numusers ( str:Channel -- int:NumUsers )
   CHAN-Users array_count
;
 
: USER-on?[ ref:Plyr str:Channel -- int:Bol ]
   VAR sme
   Plyr @ ok? not if
      0 exit
   then
   Plyr @ Channel @ USER-joined? not if
      0 exit
   then
   me @ sme ! Plyr @ me !
   Channel @ CH2-On? getpropstr "yes" stringcmp not
   sme @ me !
;
 
: FUNC-getbol[ str:STRbol -- int:INTbol ]
   STRbol @ strip dup if
      dup number? if
         atoi not not
      else
         dup "yes" stringcmp not swap "okay" stringcmp not or
      then
   else
      pop 0
   then
;
 
: USER-cancemit?[ ref:Plyr str:Channel -- int:Bol ]
   Plyr @ ok? not if
      0 exit
   then
   Plyr @ "GUEST" flag? if
      0 exit
   then
   Channel @ CHC-Cemit? getpropstr "yes" stringcmp not
   Channel @ CHC-CemitDIR Plyr @ dtos strcat getprop dup ToStr "yes"
   stringcmp not
   over ToDBref Plyr @ dbcmp or
   swap ToInt Plyr @ timestamps pop pop pop = or or
   Channel @ CHC-Owner getpropref Channel @ CHC-CemitMPI getpropstr
   "(comsys)" 1 parsempi FUNC-getbol or
   Plyr @ "WIZARD" flag? or Channel @ CHC-Owner getpropref Plyr @ dbcmp or
   Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not not and
;
 
: USER-canjoin?[ ref:Plyr str:Channel -- int:Bol ]
   Plyr @ ok? not if
      0 exit
   then
   Plyr @ Channel @ USER-banned? if
      0 exit
   then
   Plyr @ "GUEST" flag? if
      0 exit
   then
   Channel @ "WizNet" stringcmp not Channel @ CHC-ProtoNet? getpropstr
   "yes" stringcmp not and Plyr @ "WIZARD" flag? not and if
      0 exit
   then
   Channel @ "ProtoNet" stringcmp not Channel @ CHC-ProtoNet? getpropstr
   "yes" stringcmp not and if
      1 exit
   then
   Plyr @ Channel @ USER-joined? if
      1 exit
   then
   Channel @ CHC-Private? getpropstr "yes" stringcmp not if
      Plyr @ "WIZARD" flag? Channel @ CHC-Owner getpropref Plyr @ dbcmp or if
         1 exit
      then
      Channel @ CHC-AllowDIR Plyr @ dtos strcat getprop dup ToStr
      "yes" stringcmp not
      swap ToInt Plyr @ timestamps pop pop pop = or
      Channel @ CHC-PermProp getpropstr strip dup if
         ":" split swap strip dup if
            Plyr @ swap getpropstr over strip dup
            not if pop "yes" then stringcmp not
         else
            pop pop 0
         then
      else
         pop 0
      then
      or Channel @ CHC-Owner getpropref Channel @ CHC-PermMPI getpropstr
      "(comsys)" 1 parsempi FUNC-getbol or
   else
      1
   then
;
 
: USER-transmit?[ ref:Plyr str:Channel -- int:Bol ]
   Plyr @ ok? not if
      0 exit
   then
   Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not
   Channel @ CHC-Transmit? getpropstr "no" stringcmp not if
      Plyr @ "WIZARD" flag? Channel @ CHC-Owner getpropref Plyr @ dbcmp or if
         1 exit
      then
      Channel @ CHC-TransDIR Plyr @ dtos strcat getprop dup
      ToStr "yes" stringcmp not
      over ToDBref Plyr @ dbcmp or
      swap ToInt Plyr @ timestamps pop pop pop = or
      Channel @ CHC-TranProp getpropstr strip dup if
         ":" split swap strip dup if
            Plyr @ swap getpropstr over strip
            dup not if pop "yes" then stringcmp not
         else
            pop pop 0
         then
      else
         pop 0
      then
      or Channel @ CHC-Owner getpropref Channel @ CHC-TransMPI getpropstr
      "(comsys)" 1 parsempi FUNC-getbol or
   else
      1
   then
   or
;
 
: USER-gagged?[ ref:Plyr str:Channel -- int:Bol ]
   VAR sme
   Plyr @ ok? not if
      0 exit
   then
   Plyr @ owner Plyr !
   me @ sme ! Plyr @ me !
   Channel @ CHC-GagDIR Plyr @ dtos strcat getprop dup ToStr "yes" stringcmp not
   over ToDBref Plyr @ dbcmp or
   swap ToInt Plyr @ timestamps pop pop pop = or
   Plyr @ "WIZARD" flag? not Channel @ CHC-Owner getpropref Plyr @ dbcmp or and
   Channel @ CH2-Gagged? getpropstr "yes" stringcmp not or
   sme @ me !
;
 
( Added by Akari -- Checks to see if a channel should time out or not )
: CHAN-Timeout?[ str:Chan -- int:timeout? ]
    var idleTime
    Chan @ CHG-Timeout getprop not if 0 exit then ( no timeout set )
    Chan @ CHC-Lastmsg getprop not if 0 exit then ( no last use set )
    Chan @ CHC-Timeout? getpropstr "no" stringcmp not if 0 exit then (immune)
    systime Chan @ CHC-Lastmsg getprop - idleTime !
    Chan @ CHG-Timeout getprop 86400 * idleTime @ swap >
;
 
( Added by Akari -- Checks to see if the channel is owned by a valid
                    player. If not, gives the channel to the program
                    owner )
: CHAN-Checkowner[ str:Chan -- ]
    var theRef
    Chan @ CHC-Owner getpropstr stod player? if exit then ( valid player )
    Chan @ CHC-Owner CH-OBJ owner intostr setprop ( gave to program owner )
;
 
: CHAN-notify[ str:Chan str:Msg -- ]
   VAR Plyr { }list VAR! ARRlist
   Chan @ CHAN-users pop
   Chan @ CHC-UserDIR array_get_propvals
   FOREACH
      swap stod swap dup ToStr "yes" stringcmp not swap ToInt 3 pick
      dup ok? if timestamps pop pop pop = or else pop pop then
      not if
         pop CONTINUE
      then
      ARRlist @ over array_findval array_count if
         pop CONTINUE
      then
      dup ARRlist @ array_appenditem ARRlist !
      dup ok? if
         Plyr !
         Plyr @ Chan @ USER-joined? Plyr @ Chan @ USER-on? and Plyr @
         Chan @ CH2-Gagged? swap pop getpropstr "yes" stringcmp not not and
         Chan @ CHC-Auto-On? getpropstr "yes" stringcmp not
         Chan @ CHC-ProtoNet? getpropstr "yes" stringcmp not not and or if
            Plyr @ "PUEBLO" flag? if
               Msg @ " ^NORMAL^" "^NORMAL^\[" subst
            else
               Msg @ "^NORMAL^ " "^NORMAL^\[" subst
            then
            Plyr @ swap ansi_notify
         then
      else
         pop
      then
   REPEAT
   Msg @ 1 unparse_ansi Msg !
   #-1 descr_array
   FOREACH
      swap pop
      dup descr? not if pop continue then
      dup descrdbref ok? if
         pop
      else
         Chan @ CHC-Auto-On? getpropstr "yes" stringcmp not
         Chan @ CHC-ProtoNet? getpropstr "yes" stringcmp not not and if
            Msg @ notify_descriptor
         else
            pop
         then
      then
   REPEAT
   Chan @ CHC-Mesgs over over getpropval 1 + setprop
;
 
: CHAN-who[ ref:Plyr str:SRCmuck str:Channel int:ShowAll? -- int:Succ ]
   "" VAR! STRtemp VAR SRCplyr { }list dup VAR! ARRplyrs VAR! ARRobjs
   0 VAR! HasPerms? VAR muckname
   SRCmuck @ if
      Channel @ "|" split Channel ! SRCplyr !
      Channel @ not if
         0 exit
      then
      Channel @ CHC-DIR propdir? not if
         0 exit
      then
      Channel @ "ProtoNet" stringcmp not Channel @ "WizNet" stringcmp not
      or not if
         0 exit
      then
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not not if
         0 exit
      then
      "$Lib/ProtoNet" match "@Name" getpropstr muckname !
      "^COMSYS/BORDER^[^COMSYS/TITLE^%s^COMSYS/BORDER^] ^CSUCC^"
      Channel @ CHC-Name getpropstr "^^" "^" subst "@" strcat
      muckname @ "^^" "^" subst strcat "%s" subst
      Channel @ CHC-UserDIR array_get_propvals
      FOREACH
         swap stod swap dup ToStr "yes" stringcmp not swap ToInt 3 pick dup
         ok? if timestamps pop pop pop = or else pop pop then if
            dup Channel @ USER-on? over Channel @ USER-joined? and over
            Channel @ CH2-Gagged? swap pop getpropstr "yes" stringcmp
            not not and if
               dup "DARK" flag? not me @ 3 pick controls or
               over "LIGHT" flag? or over awake? and if
                  STRtemp @ dup if
                      ", " strcat then swap dup ANSINAME swap
                      Channel @ USER-gagged?
                      if " ^CNOTE^(Gagged)" strcat then strcat STRtemp !
               else
                  pop
               then
            else
               pop
            then
         else
            pop
         then
      REPEAT
      STRtemp @ dup not if pop "^CFAIL^No listeners." then
      strcat SRCplyr @ "|" strcat swap strcat
      "muck." SRCmuck @ strcat ".comsys.who.recv" strcat swap
      "$Lib/ProtoNet" match "NNSendPacket" call exit
   else
      Channel @ dup if CHU-AliasREF dup not else 1 then if
         pop Channel @ dup if dup CHC-DIR propdir? not else 1 then if
            pop Plyr @ "^CFAIL^COMSYS: That channel does not exist." ANSI-Tell
            0 Plyr @ me ! exit
         then
      then
      Channel !
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not
      Channel @ "ProtoNet" stringcmp not Channel @ "WizNet" stringcmp
      not or and if
          "comsys.who" me @ dtos "|" strcat Channel @ strcat "$Lib/ProtoNet"
          match "NNSendPacket" call exit
      then
      Channel @ CHC-Owner getpropref dup ok? if owner then me @ dbcmp
      me @ "WIZARD" flag? or
      me @ "SEE_ALL" power? or me @ "EXPANDED_WHO" power? or not if
         0 ShowAll? !
      else
         1 HasPerms? !
      then
      Plyr @ Channel @ USER-on? Plyr @ Channel @ USER-joined? and
      me @ "WIZARD" flag? or
      Channel @ CHC-Owner getpropref dup ok? if owner then me @ dbcmp or not if
         Plyr @ "^CFAIL^COMSYS: You are not on that channel." ansi_notify 0 exit
      then
      Channel @ CHC-UserDIR array_get_propvals
      FOREACH
         swap stod swap dup ToStr "yes" stringcmp not swap ToInt 3 pick dup
         ok? if timestamps pop pop pop = or else pop pop then
         over player? and if
            dup Channel @ CH2-Gagged? swap pop getpropstr "yes" stringcmp
            not not
            over Channel @ USER-on? and over Channel @ USER-joined? and
            ShowAll? @ or if
               dup Player? if
                  dup "DARK" flag? not Plyr @ 3 pick controls or over
                  "LIGHT" flag? or HasPerms? @ or over awake? ShowAll? @
                  or and if
                     ARRplyrs @ array_appenditem ARRplyrs !
                  else
                     pop
                  then
               else
                  dup "DARK" flag? not Plyr @ 3 pick controls or over
                  "LIGHT" flag? or HasPerms? @ or over awake? ShowAll? @
                  or and if
                     ARRobjs @ array_appenditem ARRobjs !
                  else
                     pop
                  then
               then
            else
               pop
            then
         else
            pop
         then
      REPEAT
      ARRplyrs @ array_count if
         Plyr @ "^CNOTE^--- Players ---" ansi_notify
         ARRplyrs @ SORTTYPE_NOCASE_ASCEND array_sort
         FOREACH
            swap pop dup ANSINAME over Channel @ USER-gagged?
            if " ^CNOTE^(Gagged)" strcat then
            over owner awake? not if " ^NORMAL^[Z]" strcat then
            swap Channel @ CH2-on? swap pop getpropstr "yes" stringcmp
            not not if
               " ^RED^[Off-channel]" strcat
            then
            Plyr @ swap ansi_notify
         REPEAT
      then
      ARRobjs @ array_count if
         Plyr @ "^CNOTE^--- Objects ---" ansi_notify
         ARRobjs @ SORTTYPE_NOCASE_ASCEND array_sort
         FOREACH
            swap pop dup ANSINAME over Channel @ USER-gagged?
            if " ^CNOTE^(Gagged)" strcat then
            over owner awake? not if " ^NORMAL^[Z]" strcat then
            swap Channel @ CH2-on? swap pop getpropstr "yes" stringcmp
            not not if
               " ^RED^[Off-channel]" strcat
            then
            Plyr @ swap ansi_notify
         REPEAT
      then
      ARRplyrs @ array_count ARRobjs @ array_count or not if
         Plyr @ "^CFAIL^No players nor objects are on the channel." ansi_notify
      then
     Plyr @ "^CINFO^-- Finished! --" ansi_notify 1
   then
;
 
: HookPacket[ str:Packet str:SRCmuck str:PKT -- ]
   VAR Plyr
   Packet @ "comsys.send" stringcmp not if
      PKT @ "|" split over CHC-DIR propdir? not if
         pop pop exit
      then
      over CHC-ProtoNet? getpropstr "yes" stringcmp not not if
         pop pop exit
      then
      over "WizNet" stringcmp not 3 pick "ProtoNet" stringcmp not or if
         CHAN-notify
      else
         pop pop
      then
      exit
   then
   Packet @ "comsys.who" stringcmp not if
      "$Lib/ProtoNet" match "DAEMON_PLAYER" call SRCmuck @ PKT @ 0 CHAN-who
      pop exit
   then
   Packet @ "comsys.who.recv" stringcmp not if
      PKT @ "|" split swap stod swap ansi_notify exit
   then
;
 
: CHAN-send[ str:Chan str:Msg -- int:Succ ]
   Chan @ CHC-DIR propdir? not if
      0 exit
   then
   Chan @ CHC-ProtoNet? getpropstr "yes" stringcmp not if
      "comsys.send" Chan @ "|" strcat Msg @ strcat
      "$Lib/ProtoNet" match "NNSendPacket" call pop 1
   else
      Chan @ Msg @ CHAN-notify 1
   then
;
 
: CHAN-ParseMsg[ str:Msg -- str:Msg' ]
   "" Msg @ 0 VAR! idx
   BEGIN
      dup "\"\"" instr WHILE
      "\"" "\"\"" subst
   REPEAT
   BEGIN
      dup "\"" instr over strlen = WHILE
      dup strlen 1 - strcut pop
   REPEAT
   BEGIN
      dup "\"" instr WHILE
      "\"" split rot rot strcat idx @ if
         "^COMSYS/QUOTE^\"^COMSYS/TEXT^" strcat 0 idx !
      else
         "^COMSYS/QUOTE^\"^COMSYS/MESG^" strcat 1 idx !
      then
      swap
   REPEAT
   strcat idx @ if
      "^COMSYS/QUOTE^\"^COMSYS/TEXT^" strcat
   then
;
 
: USER-cemit[ ref:Plyr str:Chan str:Text int:ForceTitle? -- int:Succ ]
   me @ Plyr @ me ! Plyr !
   Text @ strip not if
      Plyr @ "^CFAIL^COMSYS: You need to say something." ansi_notify
      0 Plyr @ me ! exit
   then
   Chan @ dup if CHU-AliasREF dup not else 1 then if
      pop Chan @ dup if dup CHC-DIR propdir? not else 1 then if
         pop Plyr @ "^CFAIL^COMSYS: That channel does not exist." ANSI-Tell
         0 Plyr @ me ! exit
      then
   then
   Chan !
   Text @ strip Text !
   Plyr @ Chan @ USER-gagged? if
      Plyr @ "^CFAIL^COMSYS: You are gagged from that channel." ansi_notify
      0 Plyr @ me ! exit
   then
   Plyr @ Chan @ USER-joined? not if
      Plyr @ "^CFAIL^COMSYS: You have not joined that channel." ansi_notify
      0 Plyr @ me ! exit
   then
   Plyr @ Chan @ USER-on? not if
      Plyr @ "^CFAIL^COMSYS: You are not on that channel." ansi_notify
      0 Plyr @ me ! exit
   then
   Plyr @ Chan @ USER-transmit? not if
      Plyr @ "^CFAIL^COMSYS: You cannot transmit on that channel. Permission denied." ansi_notify
      0 Plyr @ me ! exit
   then
   Chan @ CHC-ProtoNet? getpropstr "yes" stringcmp not if
      Plyr @ "^CFAIL^COMSYS: Channel spoofing is not allowed on ProtoNet."
      ansi_notify 0 Plyr @ me ! exit
   then
   Plyr @ Chan @ USER-cancemit? not if
      Plyr @ "^CFAIL^COMSYS: You cannot emit to that channel. Permission denied."
      ansi_notify 0 Plyr @ me ! exit
   then
   Text @ strip " " split pop dup ForceTitle? @ and if
      "*" swap strcat match ok? if
         "^COMSYS/BORDER^( ^COMSYS/TEXT^" Text @ strcat
         " ^NORMAL^^COMSYS/BORDER^) [^COMSYS/TITLE^Spoofed By: ^BOLD^%s^COMSYS/BORDER^]"
         me @ name "^^" "^" subst "%s" subst strcat Text !
      else
         "^COMSYS/BORDER^( ^COMSYS/TEXT^%n ^COMSYS/BORDER^)" Text @ "%n" subst
         Text !
      then
   else
      pop "^COMSYS/TEXT^" Text @ strcat Text !
   then
   Chan @ CHC-Prefix? getpropstr "no" stringcmp not ForceTitle? @ not and if
      ""
   else
      "^COMSYS/BORDER^[^COMSYS/TITLE^^UNDERLINE^%s^NORMAL^^COMSYS/BORDER^] "
      Chan @ CHC-Name getpropstr "^^" "^" subst
      Chan @ CHC-ProtoNet? getpropstr "yes" stringcmp not if
         "$Lib/ProtoNet" match "@Name" getpropstr "^^" "^" subst "@"
         swap strcat strcat
      then
      "%s" subst
   then
   Text @ strcat
   Chan @ swap CHAN-send
   Plyr @ me !
;
 
: USER-send[ ref:Plyr str:Chan str:Text -- int:Succ ]
   VAR Comtitle 0 VAR! idx
   me @ Plyr @ me ! Plyr !
   Text @ strip not if
      Plyr @ "^CFAIL^COMSYS: You need to say something." ansi_notify
      0 Plyr @ me ! exit
   then
   Chan @ if Chan @ CHC-DIR propdir? not else 1 then if
      Plyr @ "^CFAIL^COMSYS: That channel does not exist." ansi_notify
      0 Plyr @ me ! exit
   then
   Chan @ CHC-DIR propdir? not if
      Plyr @ "^CFAIL^COMSYS: That channel does not exist." ansi_notify
      0 Plyr @ me ! exit
   then
   Chan @ dup if CHU-AliasREF dup not else 1 then if
      pop Chan @ dup if dup CHC-DIR propdir? not else 1 then if
         pop Plyr @ "^CFAIL^COMSYS: That alias is not in use." ansi_notify
         0 Plyr @ me ! exit
      then
   then
   Chan !
   Plyr @ Chan @ USER-gagged? if
      Plyr @ "^CFAIL^COMSYS: You are gagged from that channel." ansi_notify
      0 Plyr @ me ! exit
   then
   Plyr @ Chan @ USER-joined? not if
      Plyr @ "^CFAIL^COMSYS: You have not joined that channel." ansi_notify
      0 Plyr @ me ! exit
   then
   Plyr @ Chan @ USER-on? not if
      Plyr @ "^CFAIL^COMSYS: You are not on that channel." ansi_notify
      0 Plyr @ me ! exit
   then
   Plyr @ Chan @ USER-transmit? not if
      Plyr @ "^CFAIL^COMSYS: You cannot transmit on that channel. Permission denied." ANSI-Tell
      0 Plyr @ me ! exit
   then
   Chan @ CHC-LastMsg systime setprop
   Chan @ CHAN-checkowner ( check for valid owner of channel )
   Chan @ CH2-ComTitle getpropstr dup strip not
   Chan @ CHC-Title? getpropstr "no" stringcmp not
   Chan @ CHC-ProtoNet? getpropstr "yes" stringcmp not not and or if
      pop me @ name
   else
      "^UNDERLINE^" swap "\[NORMAL\[" "^^NORMAL^^" subst "^NORMAL^^UNDERLINE^" "^NORMAL^" subst "^^NORMAL^^" "\[NORMAL\["
      subst strcat
      me @ swap "\[[0m\[[4m" parse_neon "^^" "^" subst
      Chan @ CHC-Names? getpropstr "no" stringcmp not not
      Chan @ CHC-ProtoNet? getpropstr "yes" stringcmp not or if
         "^NORMAL^\[^COMSYS/TEXT^" strcat me @ name strcat
      else
         "^NORMAL^\[^COMSYS/TEXT^" strcat
      then
   then
   Comtitle !
   Text @ striptail Text !
   Text @ 1 strcut pop
   dup ":" strcmp not if
      pop Text @ 1 strcut swap pop Text !
      Text @ 1 strcut pop "!,.;\"-=_:'`" swap instr if
         ""
      else
         "^NORMAL^\[^COMSYS/TEXT^"
      then
      Comtitle @ swap strcat Text @ "^^" "^" subst striplead strcat idx ++
   else
      dup ";" strcmp not if
         pop Comtitle @ Text @ "^^" "^" subst 1 strcut swap pop dup " " instr
         1 = if striplead "^NORMAL^\[^COMSYS/TEXT^" swap strcat then strcat
         idx ++
      else
         dup "|" strcmp not if
            pop Text @ 1 strcut swap pop Plyr @ Chan @ rot "^^" "^" subst 1
            USER-cemit exit
         else
            pop Text @ dup strlen 1 - strcut swap pop
            dup "?" strcmp not if
               pop "asks"
            else
               "!" strcmp not if
                  "exclaims"
               else
                  "says"
               then
            then
            Comtitle @ "^NORMAL^\[^COMSYS/TEXT^" strcat swap strcat ", \""
            strcat Text @ "^^" "^" subst strcat
         then
      then
   then
   strip
   idx @ Text @ 1 strcut swap pop strip not and if
      pop Plyr @ "^CFAIL^COMSYS: You need to say something." ansi_notify
      0 Plyr @ me ! exit
   then
   CHAN-ParseMsg "^COMSYS/TEXT^" swap strcat
   "^COMSYS/BORDER^[^COMSYS/TITLE^^UNDERLINE^%s^NORMAL^^COMSYS/BORDER^] "
   Chan @ CHC-Name getpropstr "^^" "^" subst
   Chan @ CHC-ProtoNet? getpropstr "yes" stringcmp not if
      "$lib/ProtoNet" match "@Name" getpropstr "^^" "^" subst "@" swap strcat
      strcat
   then
   "%s" subst swap strcat
   Chan @ swap CHAN-send
   Plyr @ me !
;
 
: DO-addcom[ ref:Plyr str:Chan str:Alias int:Force? int:Quiet? -- int:Succ ]
   me @ Plyr @ me ! Plyr !
   Alias @ ":" instr Alias @ "/" instr or Alias @ "|" instr or Alias @ ";" instr
   or Alias @ "@" instr 1 = or Alias @ "=" instr or Alias @ "^" instr or Alias @ "%" instr or if
      Quiet? @ not if
          Plyr @
          "^CFAIL^COMSYS: '^CINFO^%a^CFAIL^' is a silly name for an alias."
          Alias @ "^^" "^" subst "%s" subst ansi_notify
      then
      0 Plyr @ me ! exit
   then
   Alias @ dup if CHU-AliasREF else pop 1 then if
      Quiet? @ not if
          Plyr @
          "^CFAIL^COMSYS: The '^CINFO^%s^CFAIL^' alias is already in use."
          Alias @ "^^" "^" subst "%s" subst ansi_notify
      then
      0 Plyr @ me ! exit
   then
   Chan @ if Chan @ CHC-DIR propdir? not else 1 then if
      Quiet? @ not if
          Plyr @ "^CFAIL^COMSYS: The '^CINFO^%s^CFAIL^' channel does not exist."
          Chan @ CHC-Name getpropstr "^^" "^" subst "%s" subst ansi_notify
      then
      0 Plyr @ me ! exit
   then
   me @ Chan @ USER-banned? if
      Quiet? @ not if
          Plyr @
          "^CFAIL^COMSYS: You have been banned from the '^CINFO^%s^CFAIL' channel!"
          Chan @ CHC-Name getpropstr "^^" "^" subst "%s" subst ansi_notify
      then
      0 Plyr @ me ! exit
   then
   me @ Chan @ USER-canjoin? Force? @ or me @ "WIZARD" flag? or not if
      Quiet? @ not if
          Plyr @ "^CFAIL^COMSYS: Permission denied for the '%s' channel."
          Chan @ CHC-Name getpropstr "^^" "^" subst "%s" subst ansi_notify
      then
      0 Plyr @ me ! exit
   then
   me @ Chan @ USER-joined? not if
      Chan @ CHC-UserDir me @ dtos strcat me @ timestamps pop pop pop setprop
      Chan @ CH2-Joined? "yes" setprop
      Chan @ CH2-On? "yes" setprop
      me @ Chan @ CHM-JoinMsg USER-send pop
   then
   Alias @ CHU-Alias Chan @ CHC-Name getpropstr setprop
   Chan @ CH2-Aliases over over getpropval 1 + setprop
   me @ "@Command/" Alias @ strcat "$Lib/Comsys" setprop
   Quiet? @ not if
       Plyr @
       "^CSUCC^COMSYS: Successfully joined the '^CINFO^%s^CSUCC^' channel with the '^CINFO^%a^CSUCC^' alias."
       Alias @ "^^" "^" subst "%a" subst Chan @ CHC-Name getpropstr
       "^^" "^" subst "%s" subst ansi_notify
   then 1
   Chan @ CHAN-NumUsers pop
   Plyr @ me !
;
 
: USER-addcom[ ref:Plyr str:Chan str:Alias int:Force? int:Quiet? -- int:Succ ]
   0 VAR! idx
   Alias @ ";" explode_array
   FOREACH
      swap pop Plyr @ Chan @ rot Force? @ Quiet? @ DO-addcom idx @ + idx !
   REPEAT
   idx @ not not
;
 
: DO-delcom[ ref:Plyr str:Alias int:Quiet? -- int:Succ ]
   VAR Chan
   me @ Plyr @ me ! Plyr !
   Alias @ not if
      Quiet? @ not if
          Plyr @ "^CFAIL^COMSYS: You need enter an alias to remove."
          ansi_notify
      then
      0 Plyr @ me ! exit
   then
   Alias @ dup if CHU-AliasREF dup not else 1 then if
      pop Alias @ dup if dup CHC-DIR propdir? not else 1 then if
         pop Quiet? @ not if
             Plyr @
             "^CFAIL^COMSYS: That '^CINFO^%s^CFAIL^' alias is not in use."
             Alias @ "^^" "^" subst "%s" subst ansi_notify
         then
         0 Plyr @ me ! exit
      then
   then
   Chan !
   me @ Chan @ USER-joined? not if
      Quiet? @ not if
          Plyr @
          "^CFAIL^COMSYS: You have not joined the '^CINFO^%s^CFAIL^' channel."
          Chan @ "^^" "^" subst "%s" subst ansi_notify
      then
      0 Plyr @ me ! exit
   then
   Chan @ Alias @ stringcmp not Chan @ CH2-Aliases getpropval 2 < or if
      me @ Chan @ USER-on? if
         me @ Chan @ CHM-LeaveMsg USER-send pop
      then
      me @ Chan @ USER-Aliases
      FOREACH
         swap pop dup CHU-Alias remove_prop
         me @ "@Command/" rot strcat over over getprop ToStr dup
         "$Lib/Comsys" stringcmp not swap ToDBref prog dbcmp or if
            remove_prop
         else
            pop
         then
      REPEAT
       Chan @ CH2-DIR .debug-on remove_prop .debug-off
      Chan @ CHC-UserDir me @ dtos strcat remove_prop
      Quiet? @ not if
          Plyr @ "^CSUCC^COMSYS: No longer on the '^CINFO^%s^CSUCC^' channel."
          Chan @ CHC-Name getpropstr "^^" "^" subst "%s" subst ansi_notify
      then 1
   else
      Alias @ CHU-Alias remove_prop
      me @ "@Command/" Alias @ strcat over over getprop ToStr dup
      "$Lib/Comsys" stringcmp not swap ToDBref prog dbcmp or if
         remove_prop
      else
         pop
      then
      Chan @ CH2-Aliases over over getpropval 1 - setprop
      Quiet? @ not if
          Plyr @ "^CSUCC^COMSYS: The '^CINFO^%s^CSUCC^' alias was removed."
          Alias @ "^^" "^" subst "%s" subst ansi_notify
      then 1
   then
   Chan @ CHAN-NumUsers pop
   Plyr @ me !
;
 
: USER-delcom[ ref:Plyr str:Alias int:Quiet? -- int:Succ ]
   0 VAR! idx
   Alias @ ";" explode_array
   FOREACH
      swap pop Plyr @ swap Quiet? @ DO-delcom idx @ + idx !
   REPEAT
   idx @ not not
;
 
(* Channel-WizCall*Com functions are only in here for compatability purposes *)
: Channel-WizCallAddCom[ str:Alias str:Chan ref:Plyr -- int:Succ ]
   Plyr @ Chan @ Alias @ 1 1 USER-addcom
;
ARCHCALL Channel-WizCallAddCom
 
: Channel-WizCallDelCom[ str:Alias ref:Plyr -- int:Succ ]
   Plyr @ Alias @ 1 USER-delcom
;
ARCHCALL Channel-WizCallDelCom
(* End of compatability functions *)
 
: USER-comtitle[ ref:Plyr str:Alias str:Title int:Quiet? -- int:Succ ]
   VAR Chan
   me @ Plyr @ me ! Plyr !
   Alias @ not if
      Quiet? @ not if
          Plyr @ "^CFAIL^COMSYS: You need enter an alias."
          ansi_notify
      then
      0 Plyr @ me ! exit
   then
   Alias @ dup if CHU-AliasREF dup not else 1 then if
      pop Alias @ dup if dup CHC-DIR propdir? not else 1 then if
         pop Quiet? @ not if
             Plyr @ "^CFAIL^COMSYS: That alias is not in use." ansi_notify
         then 0 Plyr @ me ! exit
      then
   then
   Chan !
   Plyr @ Chan @ USER-joined? not if
      Quiet? @ not if
          Plyr @ "^CFAIL^COMSYS: You have not joined that channel." ansi_notify
      then
      0 Plyr @ me ! exit
   then
   Chan @ CHC-Title? getpropstr "no" stringcmp not
   Chan @ CHC-ProtoNet? getpropstr "yes" stringcmp not not and if
      Quiet? @ not if
          Plyr @ "^CFAIL^COMSYS: Comtitles are not allowed on that channel."
          ansi_notify
      then
      0 Plyr @ me ! exit
   then
   Chan @ CH2-Comtitle Title @ strip setprop
   Title @ strip if
      Quiet? @ not if Plyr @ "^CSUCC^COMSYS: Comtitle set." ansi_notify then 1
   else
      Quiet? @ not if
          Plyr @ "^CSUCC^COMSYS: Comtitle cleared." ansi_notify
      then 1
   then
   Plyr @ me !
;
 
: USER-allcom[ ref:Plyr str:Text int:Quiet? -- int:Succ ]
   VAR STRchann VAR sme
   me @ sme ! Plyr @ me !
   Plyr @ USER-channels
   FOREACH
      pop STRchann !
      Text @ "on" stringcmp not Text @ "#on" stringcmp not or if
         Plyr @ STRchann @ CH2-On? getpropstr "yes" stringcmp not if
            Quiet? @ not if
                sme @
                "^CFAIL^COMSYS: You are already on the '^CINFO^%n^CFAIL^' channel."
                STRchann @ "^^" "^" subst "%n" subst ansi_notify
            then CONTINUE
         then
         STRchann @ CH2-On? "yes" setprop
         Plyr @ STRchann @ CHM-JoinMsg USER-send
      else
         Text @ "off" stringcmp not Text @ "#off" stringcmp not or if
            STRchann @ CH2-On? getpropstr "yes" stringcmp if
               Quiet? @ not if
                   sme @
                   "^CFAIL^COMSYS: You are already off of the '^CINFO^%n^CFAIL^' channel."
                   STRchann @ "^^" "^" subst "%n" subst ansi_notify
               then CONTINUE
            then
            Plyr @ STRchann @ CHM-LeaveMsg USER-send
            STRchann @ CH2-On? "no" setprop
                     else
            Text @ "who" stringcmp not Text @ "#who" stringcmp not or if
               Plyr @ "" STRchann @ 0 CHAN-who pop
            else
               Plyr @ STRchann @ Text @ USER-send pop
            then
         then
      then
   REPEAT
   Quiet? @ not if sme @ "^CSUCC^Finished." ansi_notify then sme @ me ! 1
;
 
: USER-clearcom[ ref:Plyr int:Quiet? -- int:Succ ]
   VAR idx
   Plyr @ USER-Channels
   FOREACH
      pop Plyr @ swap 1 DO-delcom idx @ + idx !
   REPEAT
   Quiet? @ not if
       me @ "^CSUCC^COMSYS: All channels are now cleared and removed."
       ansi_notify
   then
   idx @ not not
;
 
: USER-chown[ ref:Plyr str:Channel -- int:Succ ]
   Channel @ not if
      me @ "^CFAIL^COMSYS: You need enter an alias." ansi_notify 0 exit
   then
   Channel @ dup if CHU-AliasREF dup not else 1 then if
      pop Channel @ dup if dup CHC-DIR propdir? not else 1 then if
         pop me @ "^CFAIL^COMSYS: That alias is not in use." ansi_notify 0 exit
      then
   then
   Channel !
   Plyr @ me @ dbcmp me @ "WIZARD" flag? or me @ "CHOWN_ANYTHING" power? or if
      Channel @ CHC-ChownOk? getpropref me @ dbcmp me @ "WIZARD" flag? or not if
         me @ "^CFAIL^COMSYS: Permission denied." ansi_notify 0 exit
      then
      Channel @ CHC-ChownOk? remove_prop
      Channel @ CHC-Owner Plyr @ setprop
      Plyr @ "^CSUCC^COMSYS: %s was just chowned to you."
      Channel @ CHC-Name getpropstr
      "^^" "^" subst "%s" subst ansi_notify
      me @ "^CSUCC^COMSYS: Chowned to " Plyr @ unparseobj strcat "."
      strcat ansi_notify 1
   else
      Channel @ CHC-Owner getpropref
      dup ok? if dup player? not else 0 then
      swap me @ dbcmp or me @ "WIZARD" flag? or not if
         me @ "^CFAIL^COMSYS: Permission denied." ansi_notify 0 exit
      then
      Channel @ CHC-ChownOk? Plyr @ setprop
      me @ "^CSUCC^COMSYS: Set chown okay for the player." ansi_notify 1
   then
;
 
: USER-ban[ ref:Plyr str:Channel int:BOLban? -- int:Succ ]
   Plyr @ ok? not if
      Plyr @ #-2 dbcmp if
         "^CINFO^COMSYS: I don't know which one you mean!"
      else
         "^CINFO^COMSYS: I cannot find that player."
      then
      me @ swap ansi_notify 0 exit
   then
   Channel @ if
      Channel @ dup if CHU-AliasREF dup not else 1 then if
         pop Channel @ dup if dup CHC-DIR propdir? not else 1 then if
            pop me @ "^CFAIL^COMSYS: That alias is not in use." ansi_notify
            0 exit
         then
      then
      Channel !
      Channel @ CHC-Owner getpropref me @ dbcmp me @ "WIZARD" flag? or not if
         me @ "^CFAIL^COMSYS: Permission denied." ansi_notify 0 exit
      then
      BOLban? @ if
         Channel @ CHC-BanDIR Plyr @ dtos strcat Plyr @ timestamps pop pop pop
         setprop
         Plyr @ "^CINFO^You have been banned from the %s channel."
         Channel @ "^^" "^" subst "%s" subst ansi_notify
         "^CSUCC^COMSYS: Added user to the ban list."
      else
         Channel @ CHC-BanDIR Plyr @ dtos strcat remove_prop
         Plyr @ "^CINFO^You are no longer banned from the %s channel."
         Channel @ "^^" "^" subst "%s" subst ansi_notify
         "^CSUCC^COMSYS: Removed user from the ban list."
      then
      me @ swap ansi_notify 1
   else
      me @ "WIZARD" flag? not if
         me @ "^CFAIL^COMSYS: Permission denied." ansi_notify 0 exit
      then
      BOLban? @ if
         CHG-Banned Plyr @ dtos strcat Plyr @ timestamps pop pop pop setprop
         Plyr @ "^CINFO^COMSYS: You have been banned from comsys."
         Channel @ "^^" "^" subst "%s" subst ansi_notify
         "^CSUCC^COMSYS: Added user to the global ban list." ANSI-Tell 1
      else
         CHG-Banned Plyr @ dtos strcat remove_prop
         Plyr @ "^CINFO^COMSYS: You are no longer banned from comsys."
         Channel @ "^^" "^" subst "%s" subst ansi_notify
         "^CSUCC^COMSYS: Removed user from the global ban list." ANSI-Tell 1
      then
   then
;
 
: USER-gag[ ref:Plyr str:Channel int:BOLgag? -- int:Succ ]
   Channel @ not if
      me @ "^CFAIL^COMSYS: You need enter an alias." ansi_notify 0 exit
   then
   Channel @ dup if CHU-AliasREF dup not else 1 then if
      pop Channel @ dup if dup CHC-DIR propdir? not else 1 then if
         pop me @ "^CFAIL^COMSYS: That alias is not in use." ansi_notify 0 exit
      then
   then
   Channel !
   Plyr @ ok? not if
      Plyr @ #-2 dbcmp if
         "^CINFO^COMSYS: I don't know which one you mean!"
      else
         "^CINFO^COMSYS: I cannot find that player."
      then
      me @ swap ansi_notify 0 exit
   then
   Plyr @ me @ dbcmp if
      me @ Channel @ USER-joined? me @ Channel @ USER-on? and
      me @ "WIZARD" flag? or not if
         me @ "^CFAIL^COMSYS: Permission denied." ansi_notify 0 exit
      then
      me @ Plyr @ me ! Plyr !
      BOLgag? @ if
         Channel @ CH2-Gagged? "yes" setprop
         "^CSUCC^COMSYS: You temporarily gagged yourself from the channel."
      else
         Channel @ CH2-Gagged? remove_prop
         "^CSUCC^COMSYS: You are no longer gagged from the channel."
      then
      me @ Plyr ! me @ swap ansi_notify 1
   else
      Channel @ CHC-Owner getpropref me @ dbcmp me @ "WIZARD" flag? or not if
         me @ "^CFAIL^COMSYS: Permission denied." ansi_notify 0 exit
      then
      BOLgag? @ if
         Channel @ CHC-GagDIR Plyr @ dtos strcat Plyr @ timestamps pop pop pop
         setprop
         Plyr @ "You have been gagged from the %s channel."
         Channel @ "^^" "^" subst "%s" subst ansi_notify
         "^CSUCC^COMSYS: Added user to the gag list."
      else
         Channel @ CHC-GagDIR Plyr @ dtos strcat remove_prop
         Plyr @ "You are no longer gagged from the %s channel."
         Channel @ "^^" "^" subst "%s" subst ansi_notify
         "^CSUCC^COMSYS: Removed user from the gag list."
      then
      me @ swap ansi_notify 1
   then
;
 
: USER-boot[ ref:Plyr str:Channel -- int:Succ ]
   me @ Plyr @ me ! Plyr !
   me @ ok? if
      Channel @ if
         Channel @ dup if CHU-AliasREF else 0 then dup if
            Channel ! ""
         then pop
         Channel @ if Channel @ CHC-DIR propdir? not else 1 then if
            Plyr @ "^CFAIL^COMSYS: That channel name does not exist."
            ansi_notify 0 plyr @ me ! exit
         then
         Channel @ CHC-Owner getpropref Plyr @ dbcmp
         Plyr @ "WIZARD" flag? or not if
            Plyr @ "^CFAIL^COMSYS: Permission denied." ansi_notify
            0 Plyr @ me ! exit
         then
         me @ Channel @ 1 USER-delcom not if
            Plyr @
            "^CFAIL^COMSYS: Problem when trying to boot the user from the channel."
            ansi_notify 0 plyr @ me ! exit
         then
         "^CINFO^COMSYS: You have been booted off of %s!"
         Channel @ "%s" subst ANSI-Tell
         Plyr @ "^CSUCC^COMSYS: Booted the player from the channel." ansi_notify
         1 me @ Plyr @ me ! Plyr !
         CHG-AutoBan? getpropstr "no" stringcmp not not if
            Plyr @ Channel @ 1 USER-ban pop
         then
      else
         Plyr @ "WIZARD" flag? not if
            Plyr @ "^CFAIL^COMSYS: Permission denied." ansi_notify
            0 Plyr @ me ! exit
         then
         me @ 1 USER-clearcom not if
            Plyr @
            "^CFAIL^COMSYS: Problem when trying to boot the user from all channels."
            ansi_notify
         then
         "^CINFO^COMSYS: You have been booted from all of the channels."
         ANSI-Tell
         Plyr @ "^CSUCC^COMSYS: Booted the player from all channels."
         ansi_notify 1 me @ Plyr @ me ! Plyr !
         CHG-AutoBan? getpropstr "no" stringcmp not not if
            Plyr @ "" 1 USER-ban pop
         then
      then
   else
      Plyr @ #-2 dbcmp Plyr @ #-1 dbcmp or if
         Plyr @ #-2 dbcmp if
            "^CINFO^COMSYS: I don't know which one you mean!"
         else
            "^CINFO^COMSYS: I cannot find that player."
         then
         Plyr @ swap ansi_notify 0 Plyr @ me ! exit
      then
      Channel @ if Channel @ CHC-DIR propdir? not else 1 then if
         Plyr @ "^CFAIL^COMSYS: That channel name does not exist." ansi_notify
         0 plyr @ me ! exit
      then
      Channel @ CHC-Owner getpropref Plyr @ dbcmp Plyr @ "WIZARD" flag?
      or not if
         Plyr @ "^CFAIL^COMSYS: Permission denied." ansi_notify
         0 Plyr @ me ! exit
      then
      Channel @ "^CINFO^COMSYS: You have been booted from %s!"
      Channel @ "%s" subst CHAN-notify
      Channel @ CHC-UserDIR array_get_propvals Plyr @ me !
      FOREACH
         pop stod dup Channel @ USER-joined? if
            dup ok? if
               Channel @ 1 USER-delcom pop
            else
               pop
            then
         else
            pop
         then
      REPEAT
      Plyr @ "^CSUCC^COMSYS: Booted all players from the channel." ansi_notify 1
   then
   Plyr @ me !
;
 
: CHAN-match[ str:Chan -- int:BOLmatch? ]
   1 Chan @ CHU-REF not if
      pop 2 Chan @ CHC-DIR propdir? not if
         pop 0
      then
   then
;
 
: CHAN-chancreate[ str:Channel -- int:Succ ]
   Channel @ ":" instr Channel @ "/" instr or Channel @ "|" instr
   or Channel @ ";" instr or
   Channel @ "@" instr 1 = or Channel @ "=" instr or  Channel @ "^" instr
   or Channel @ "%" instr or if
      "^CFAIL^COMSYS: That is a silly name for a channel." ANSI-Tell 0 exit
   then
   Channel @ CHC-DIR propdir? if
      "^CFAIL^COMSYS: That channel name is in use." ANSI-Tell 0 exit
   then
   CH-OBJ owner me @ dbcmp CHG-PCreate? getpropstr "yes" stringcmp not or
   me @ "WIZARD" flag? or not if
      "^CFAIL^COMSYS: Permission denied." ANSI-Tell 0 exit
   then
   Channel @ CHC-Name Channel @ setprop
   Channel @ CHC-Owner me @ setprop
   me @ "^CSUCC^COMSYS: Channel created." ansi_notify 1
;
 
: CHAN-chandelete[ str:Channel -- int:Succ ]
   Channel @ ":" instr Channel @ "/" instr or Channel @ "|" instr
   or Channel @ ";" instr or
   Channel @ "@" instr 1 = or Channel @ "=" instr or  Channel @ "^" instr or
   Channel @ "%" instr or if
      "^CFAIL^COMSYS: That is a silly name for a channel." ANSI-Tell 0 exit
   then
   Channel @ CHAN-match not if
      "^CFAIL^COMSYS: That channel does not exist." ANSI-Tell 0 exit
   then
   Channel @ CHAN-match 1 = if
      Channel @ CHU-REF Channel !
   then
   CH-OBJ owner me @ dbcmp Channel @ CHC-Owner getpropref dup ok?
   if owner then me @ dbcmp or me @ "WIZARD" flag? or not if
      "^CFAIL^COMSYS: Permission denied." ANSI-Tell 0 exit
   then
   Channel @ CHC-DIR remove_prop
   me @ "^CSUCC^COMSYS: Channel removed." ANSI-Tell 1
;
 
: CHAN-comlist[ ref:Plyr -- ]
   VAR STRchann VAR STRalias VAR BOLshown?
   me @ Plyr @ me ! Plyr !
   Plyr @ "^YELLOW^---------------------------------------------------------------------------" ansi_notify
   Plyr @ "^YELLOW^| ^AQUA^Channel Name         ^YELLOW^| ^CYAN^Channel Alias        ^YELLOW^| ^RED^On? ^YELLOW^| ^RED^Gagged? ^YELLOW^| ^RED^Transmit? ^YELLOW^|" ansi_notify
   Plyr @ "^YELLOW^---------------------------------------------------------------------------" ansi_notify
   me @ USER-channels dup array_count if
      FOREACH
         swap STRchann ! 0 BOLshown? !
         dup array? not if
            pop CONTINUE
         then
         dup array_count not if
            pop CONTINUE
         then
         1 array_sort
         FOREACH
            swap pop STRalias !
            STRchann @ CHC-Name getpropstr "^^" "^" subst
            BOLshown? @
            if pop "" then
            20 STRleft dup strlen 20 > if 20 strcut pop then
             "^^" "^" subst "^YELLOW^| ^AQUA^" swap strcat
             " ^YELLOW^| ^CYAN^" strcat
            STRalias @ 20 STRleft dup strlen 20 >
            if 20 strcut pop then
            "^^" "^" subst strcat " ^YELLOW^| " strcat
            me @ STRchann @ USER-On? if "Yes" else "No " then
            BOLshown? @ if pop "   " else "^RED^" swap strcat then
            strcat " ^YELLOW^|   " strcat
            me @ STRchann @ USER-Gagged?
            if "Yes" else "No " then
            BOLshown? @ if pop "   " else "^RED^" swap strcat then
            strcat "   ^YELLOW^|    ^RED^" strcat
            me @ STRchann @ USER-Transmit?
            if "Yes" else "No " then
            BOLshown? @ if pop "   " else "^RED^" swap strcat then
            strcat "    ^YELLOW^|" strcat Plyr @ swap ansi_notify
            1 BOLshown? !
         REPEAT
         STRchann @ CHC-Title? getpropstr "no" stringcmp not not
         STRchann @ CHC-ProtoNet? getpropstr "yes" stringcmp not or if
            STRchann @ CH2-ComTitle getpropstr strip dup if
               "^YELLOW^| ^WHITE^- Comtitle: ^GREEN^" swap
               59 STRleft dup strlen 59 >
               if 59 strcut pop then
               "^^" "^" subst strcat " ^YELLOW^|" strcat Plyr @ swap ansi_notify
            else
               pop
            then
         then
      REPEAT
   else
      pop
   then
   Plyr @ "^YELLOW^---------------------------------------------------------------------------" ansi_notify
   Plyr @ "^CYAN^For a list of all available channels, type: ^AQUA^@clist"
   ansi_notify
   Plyr @ me ! 1
;
 
: CHAN-chanlist[ ref:Plyr -- int:Succ ]
   VAR Channel VAR sme
   me @ sme ! Plyr @ me !
   Plyr @ "^YELLOW^---------------------------------------------------------------------------" ansi_notify
   Plyr @ "^YELLOW^|^GREEN^FLAGS^YELLOW^| ^CYAN^Channel Name      ^YELLOW^| ^WHITE^Messages ^YELLOW^| ^RED^Joined? ^YELLOW^| ^PURPLE^Owner            ^YELLOW^| ^BLUE^Users ^YELLOW^|" ansi_notify
   Plyr @ "^YELLOW^---------------------------------------------------------------------------" ansi_notify
   "" CHC-DIR array_get_propdirs
   FOREACH
      swap pop Channel !
      Channel @ CHC-Lastmsg getprop dup string? swap not or if
          Channel @ CHC-Lastmsg systime setprop (if none found, set systime )
      then
      Channel @ CHAN-Timeout? if (delete the channel )
          Channel @ CHC-DIR remove_prop continue
      then
      Channel @ CHAN-Checkowner
      Plyr @ Channel @ USER-canjoin? Plyr Channel @ USER-joined? or
      Plyr @ "SEE_ALL" power? or Plyr @ "SEARCH" power? or not if
         CONTINUE
      then
      "^YELLOW^|^FOREST^"
      Channel @ CHC-Private? getpropstr "yes" stringcmp not
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not if
      Channel @ "WizNet" stringcmp not if pop 1 else pop 0 then then if
         "-"
      else
         "P"
      then
      strcat
      Channel @ CHC-Announce? getpropstr "yes" stringcmp not
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not not and if
         "A"
      else
         "-"
      then
      strcat
      Channel @ CHC-Transmit? getpropstr "no" stringcmp not
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not not and if
         "-"
      else
         "T"
      then
      strcat
      Channel @ CHC-Owner getpropref me @ dbcmp me @ "WIZARD" flag? or if
         "O"
      else
         "-"
      then
      strcat
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not
      Channel @ "WizNet" stringcmp not Channel @ "ProtoNet" stringcmp not or
      and if
         "N"
      else
         "-"
      then
      strcat
      "^YELLOW^| ^AQUA^" strcat Channel @ CHC-Name getpropstr strip 18 STRleft
      "^^" "^" subst strcat "^YELLOW^|" strcat
      Channel @ CHC-Mesgs getpropval intostr "\[" swap strcat 11 STRcenter
      "^NORMAL^" "\[" subst strcat "^YELLOW^|   ^CRIMSON^" strcat
      Plyr @ Channel @ USER-joined? if
         "Yes"
      else
         "No "
      then
      strcat "   ^YELLOW^| ^VIOLET^" strcat
      Channel @ CHC-Owner getpropref dup name swap ok? not
      if pop "(Toaded Player)" then 17 STRleft "^^" "^" subst
      strcat "^YELLOW^|" strcat
      Channel @ CHAN-NumUsers intostr "\[" swap strcat 8 STRcenter
      "^NAVY^" "\[" subst strcat "^YELLOW^|" strcat
      Plyr @ swap ansi_notify
   REPEAT
   Plyr @ "^YELLOW^---------------------------------------------------------------------------" ansi_notify
   Plyr @ "^CYAN^Flags: ^BLUE^P = ^AQUA^Public Channel   ^BLUE^A = ^AQUA^Announce connects/disconnects" ansi_notify
   Plyr @ "       ^BLUE^T = ^AQUA^Anyone can transmit messages/poses   ^BLUE^O = ^AQUA^You control the channel" ansi_notify
   Plyr @ "       ^BLUE^N = ^AQUA^ProtoNet supported channel" ansi_notify
   sme @ me ! 1
;
 
: EDIT-plyr_dir[ ref:REFobj str:STRdir -- ]
   VAR STRtemp VAR STRrem VAR STRnook VAR ARRlist
   REFobj @ Ok? not IF
      EXIT
   THEN
   STRdir @ ":" instr IF
      EXIT
   THEN
   me @ "^CNOTE^Enter a user list below: ^NORMAL^[Put in !<user> to remove, or <user> to add. Spaces seperate each <user> and !<user>]" ansi_notify
   "" STRtemp ! "" STRrem ! "" STRnook ! { }dict ARRlist !
   REFobj @ STRdir @ array_get_propvals ARRlist !
   BEGIN
      read strip dup not WHILE pop
      me @ "^CFAIL^You have to type something in!  Try again." ansi_notify
   REPEAT
   " " explode_array SORTTYPE_NOCASE_ASCEND array_sort
   FOREACH
      swap pop dup "!" instr 1 = if
         1 strcut swap pop dup if
            dup pmatch dup ok? if
               swap pop STRrem @ dup if ", " strcat then over ANSINAME
               strcat STRrem !
               ARRlist @ array_keys array_make over dtos array_findval
               array_count if
                  ARRlist @ swap dtos array_delitem ARRlist !
               else
                  pop
               then
            else
               pop STRnook @ dup if "^CFAIL^, " strcat then
               swap "^^" "^" subst strcat STRnook !
            then
         else
            pop
         then
      else
         dup if
            dup pmatch dup ok? if
               swap pop STRtemp @ dup if ", " strcat then over
               ANSINAME strcat STRtemp !
               dup timestamps pop pop pop ARRlist @ rot dtos array_setitem
               ARRlist !
            else
               pop STRnook @ dup if "^CFAIL^, " strcat then
               swap "^^" "^" subst strcat STRnook !
            then
         else
            pop
         then
      then
   REPEAT
   REFobj @ STRdir @ over over "/" rsplit pop remove_prop
   ARRlist @ array_put_propvals
   STRtemp @ if
      me @ "^CYAN^Added: ^AQUA^" STRtemp @ strcat ansi_notify
   then
   STRrem @ if
      me @ "^CYAN^Removed: ^AQUA^" STRrem @ strcat ansi_notify
   then
   STRnook @ if
      me @ "^CYAN^Doesn't Exist: ^AQUA^" STRnook @ strcat ansi_notify
   then
   STRnook @ STRrem @ or STRtemp @ or not if
      me @ "^CFAIL^No action taken." ansi_notify
   then
;
 
: EDIT-do_option[ str:Channel -- int:BOLcontinue? ]
   VAR STRtemp VAR Options
   me @ "^WHITE^" CHAN-version strcat ansi_notify
   me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat
   ansi_notify
   Channel @ if
      me @ "^GREEN^Editing Channel:  ^FOREST^" Channel @ CHC-Name getpropstr
      "^^" "^" subst strcat
      " ^AQUA^owned by ^CYAN^" strcat
      Channel @ CHC-owner getpropstr stod name strcat
      ansi_notify
      me @
      " ^YELLOW^1^BROWN^) ^CYAN^Public?                                  ^AQUA^"
      Channel @ CHC-Private? getpropstr "yes" stringcmp not
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not if
      Channel @ "WizNet" stringcmp not if pop 1 else pop 0 then then
      if "No" else "Yes" then strcat
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not
      if 1 unparse_ansi "-" "1" subst then ansi_notify
      me @ " ^YELLOW^2^BROWN^) ^CYAN^Allowed Players: ^AQUA^"
      Channel @ CHC-AllowDIR array_get_propvals "" STRtemp !
      FOREACH
         swap stod swap dup ToStr "yes" stringcmp not swap ToInt 3 pick dup ok?
         if timestamps pop pop pop = else pop pop then or if
            dup Player? IF
               ANSINAME STRtemp @ dup if ", " strcat then swap strcat STRtemp !
            ELSE
               pop
            THEN
         else
            pop
         then
      REPEAT
      STRtemp @ dup not if pop "^CFAIL^None." then STRtemp !
      STRtemp @ strcat ansi_notify
      me @ " ^YELLOW^3^BROWN^) ^CYAN^Allow prop: ^AQUA^"
      Channel @ CHC-PermProp getpropstr
      dup not if
          pop "^CFAIL^None set."
      else "^^" "^" subst
      then strcat ansi_notify
            me @ " ^YELLOW^4^BROWN^) ^CYAN^Announce Connects?                       ^AQUA^"
      Channel @ CHC-Announce? getpropstr "yes" stringcmp not
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not not and
      if "Yes" else "No" then strcat
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not
      if 1 unparse_ansi "-" "4" subst then ansi_notify
      me @ " ^YELLOW^5^BROWN^) ^CYAN^Public Transmit?                         ^AQUA^"
      Channel @ CHC-Transmit? getpropstr "no" stringcmp not
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not not and
      if "No" else "Yes" then strcat
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not
      if 1 unparse_ansi "-" "5" subst then ansi_notify
      me @ " ^YELLOW^6^BROWN^) ^CYAN^Allowed Transmiters: ^AQUA^"
      Channel @ CHC-TransDIR array_get_propvals "" STRtemp !
      FOREACH
         swap stod swap dup ToStr "yes" stringcmp not swap ToInt 3 pick
         dup ok? if timestamps pop pop pop = else pop pop then
         or if
            dup Player? IF
               ANSINAME STRtemp @ dup if ", " strcat then swap strcat STRtemp !
            ELSE
               pop
            THEN
         else
            pop
         then
      REPEAT
      STRtemp @ dup not if pop "^CFAIL^None." then STRtemp !
      STRtemp @ strcat ansi_notify
      me @ " ^YELLOW^7^BROWN^) ^CYAN^Allowed Transmiters prop: ^AQUA^"
      Channel @ CHC-TranProp getpropstr dup not
      if pop "^CFAIL^None set." else "^^" "^" subst then strcat ansi_notify
      me @
      " ^YELLOW^8^BROWN^) ^CYAN^Player name attached (if comtitle used)? ^AQUA^"
      Channel @ CHC-Names? getpropstr "no" stringcmp not
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not not and
      if "No" else "Yes" then strcat
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not
      if 1 unparse_ansi "-" "8" subst then ansi_notify
      me @
      " ^YELLOW^9^BROWN^) ^CYAN^Allow comtitles?                         ^AQUA^"
      Channel @ CHC-Title? getpropstr "no" stringcmp not
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not not
      and if "No" else "Yes" then strcat
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp
      not if 1 unparse_ansi "-" "9" subst then ansi_notify
      me @
      "^YELLOW^10^BROWN^) ^CYAN^Channel prefix for cemit?                ^AQUA^"
      Channel @ CHC-Prefix? getpropstr "no"
      stringcmp not if "No" else "Yes" then strcat ansi_notify
      me @ "^YELLOW^11^BROWN^) ^CYAN^Gagged users: ^AQUA^"
      Channel @ CHC-GagDIR array_get_propvals "" STRtemp !
      FOREACH
         swap stod swap dup ToStr "yes" stringcmp not swap ToInt 3 pick dup
         ok? if timestamps pop pop pop = else pop pop then or if
            dup Player? IF
               ANSINAME STRtemp @ dup if ", " strcat then swap strcat STRtemp !
            ELSE
               pop
            THEN
         else
            pop
         then
      REPEAT
      STRtemp @ dup not if pop "^CFAIL^None." then STRtemp !
      STRtemp @ strcat ansi_notify
      me @ "^YELLOW^12^BROWN^) ^CYAN^Banned users: ^AQUA^"
      Channel @ CHC-BanDIR array_get_propvals "" STRtemp !
      FOREACH
         swap stod swap dup ToStr "yes" stringcmp not swap ToInt 3 pick
         dup ok? if timestamps pop pop pop = else pop pop then or if
            dup Player? IF
               ANSINAME STRtemp @ dup if ", " strcat then swap strcat STRtemp !
            ELSE
               pop
            THEN
         else
            pop
         then
      REPEAT
      STRtemp @ dup not if pop "^CFAIL^None." then STRtemp !
      STRtemp @ strcat ansi_notify
      me @
      "^YELLOW^13^BROWN^) ^CYAN^Public @Cemit?                           ^AQUA^"
      Channel @ CHC-Cemit? getpropstr "yes" stringcmp not
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp
      not not and if "Yes" else "No" then strcat
      Channel @ CHC-ProtoNet? getpropstr "yes"
      stringcmp not if 1 unparse_ansi " -" "13" subst then ansi_notify
      me @ "^YELLOW^14^BROWN^) ^CYAN^Allowed Cemitters: ^AQUA^"
      Channel @ CHC-CemitDIR array_get_propvals "" STRtemp !
      FOREACH
         swap stod swap dup ToStr "yes" stringcmp not swap ToInt 3 pick
         dup ok? if timestamps pop pop pop = else pop pop then or if
            dup Player? IF
               ANSINAME STRtemp @ dup if ", " strcat then swap strcat STRtemp !
            ELSE
               pop
            THEN
         else
            pop
         then
      REPEAT
      STRtemp @ dup not if pop "^CFAIL^None." then STRtemp !
      STRtemp @ strcat ansi_notify
      me @
      "^YELLOW^15^BROWN^) ^CYAN^ProtoNet Support?                        ^AQUA^"
      Channel @ CHC-ProtoNet? getpropstr "yes"
      stringcmp not if "Yes" else "No" then strcat
      Channel @ dup "WizNet" stringcmp not swap "ProtoNet" stringcmp not or
      Channel @ CHC-Owner getpropref
      dup ok? if "WIZARD" flag? else pop 0 then and not if
         "No" "Yes" subst " -" "15" subst 1 unparse_ansi
      then
      ansi_notify
      me @ "^YELLOW^16^BROWN^) ^CYAN^Allow MPI lock:    ^AQUA^"
      Channel @ CHC-PermMPI getpropstr
      dup not if pop "^CFAIL^None set." else "^^" "^" subst then
      strcat ansi_notify
      me @ "^YELLOW^17^BROWN^) ^CYAN^Transmit MPI lock: ^AQUA^"
      Channel @ CHC-TransMPI getpropstr dup not
      if pop "^CFAIL^None set." else "^^" "^" subst then strcat ansi_notify
      me @ "^YELLOW^18^BROWN^) ^CYAN^Cemit MPI lock:    ^AQUA^"
      Channel @ CHC-CemitMPI getpropstr dup not
      if pop "^CFAIL^None set." else "^^" "^" subst then strcat ansi_notify
      me @ " " ansi_notify
      me @ "WIZARD" flag? if
         me @ " ^YELLOW^S^BROWN^) ^CYAN^Show messages to all online players?     ^AQUA^"
         Channel @ CHC-Auto-On? getpropstr "yes" stringcmp not
         Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not not
         and if "Yes" else "No" then strcat
         Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not
         if 1 unparse_ansi "S" split "-" swap strcat strcat then ansi_notify
         me @
         " ^YELLOW^A^BROWN^) ^CYAN^Auto-join for first time users?          ^AQUA^"
         Channel @ CHC-AutoJoin? getpropstr "yes"
         stringcmp not if "Yes" else "No" then strcat ansi_notify
         me @ " ^YELLOW^D^BROWN^) ^CYAN^Default alias for auto-joins: ^AQUA^"
         Channel @ CHC-DefAlias getpropstr dup not
         if pop "^CFAIL^None set." else "^^" "^" subst then strcat ansi_notify
         " ^YELLOW^T^BROWN^) ^CYAN^Channel will timeout?                    ^AQUA^"
         Channel @ CHC-Timeout? getpropstr "no" stringcmp
         if "Yes" else "No" then strcat atell
      else
         me @ " -) Show messages to all online players?     "
         Channel @ CHC-Auto-On? getpropstr "yes" stringcmp not
         Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not not and
         if "Yes" else "No" then strcat
         Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not
         if 1 unparse_ansi then ansi_notify
         me @ " -) Auto-join for first time users?          "
         Channel @ CHC-AutoJoin? getpropstr "yes"
         stringcmp not if "Yes" else "No" then strcat ansi_notify
         me @ " -) Default alias for auto-joins: "
         Channel @ CHC-DefAlias getpropstr dup
         not if pop "^CFAIL^None set." else "^^" "^" subst then
         strcat ansi_notify
         " -) Channel will idle out?                   "
         Channel @ CHC-Timeout? getpropstr "no" stringcmp
         if "Yes" else "No" then strcat atell
      then
      me @ " " ansi_notify
      me @ " ^CRIMSON^Q^RED^) ^BROWN^Quit Editor" ansi_notify
      Channel @ CHC-ProtoNet? getpropstr "yes" stringcmp not
      Channel @ dup "WizNet" stringcmp not swap "ProtoNet" stringcmp not
      or and if
         me @ "WIZARD" flag? if
            "\r2\r3\r6\r7\r10\r11\r12\r14\r16\r17\r18\rA\rD\rQ\r"
         else
            "\r2\r3\r6\r7\r10\r11\r12\r14\r16\r17\r18\rQ\r"
         then
      else
         me @ "WIZARD" flag? if
            Channel @ dup "WizNet" stringcmp not swap "ProtoNet" stringcmp
            not or
            Channel @ CHC-Owner getpropref
            dup ok? if "WIZARD" flag? else pop 0 then and if
               "\r1\r2\r3\r4\r5\r6\r7\r8\r9\r10\r11\r12\r13\r14\r15\r16\r17\r18\rS\rA\rD\rT\rQ\r"
            else
               "\r1\r2\r3\r4\r5\r6\r7\r8\r9\r10\r11\r12\r13\r14\r16\r17\r18\rS\rA\rD\rT\rQ\r"
            then
         else
            "\r1\r2\r3\r4\r5\r6\r7\r8\r9\r10\r11\r12\r13\r14\r16\r17\r18\rQ\r"
         then
      then
      Options !
   else
      me @ "^YELLOW^1^BROWN^) ^CYAN^Globaly banned users: ^AQUA^"
      CHG-Banned array_get_propvals "" STRtemp !
      FOREACH
         swap stod swap dup ToStr "yes" stringcmp not swap ToInt 3 pick
         dup ok? if timestamps pop pop pop = else pop pop then or if
            dup Player? IF
               ANSINAME STRtemp @ dup if ", " strcat then swap strcat STRtemp !
            ELSE
               pop
            THEN
         else
            pop
         then
      REPEAT
      STRtemp @ dup not if pop "^CFAIL^None." then STRtemp !
      STRtemp @ strcat ansi_notify
      me @ "^YELLOW^2^BROWN^) ^CYAN^Auto-ban on @cboot?        ^AQUA^"
      CHG-AutoBan? getpropstr "no" stringcmp not
      if "No" else "Yes" then strcat ansi_notify
      me @ "^YELLOW^3^BROWN^) ^CYAN^Publicly created channels? ^AQUA^"
      CHG-PCreate? getpropstr "yes" stringcmp not
      if "Yes" else "No" then strcat ansi_notify
      "^YELLOW^4^BROWN^) ^CYAN^Days for channel timeout:  ^AQUA^"
      CHG-Timeout getprop dup not if pop "^RED^None" else intostr then
      strcat atell
      me @ " " ansi_notify
      me @ "^CRIMSON^Q^RED^) ^BROWN^Quit Editor" ansi_notify
      "\r1\r2\r3\r4\rQ\r" Options !
   then
   me @ "^GREEN^Enter an option below [%s]:" Options @ "," "\r" subst 1 strcut
   swap pop dup strlen 1 - strcut pop "%s" subst ansi_notify
   BEGIN
      read strip "\r" over over strcat strcat Options @ swap instring
      not WHILE pop
      me @ "^CFAIL^Invalid option.  Try again [%s]." Options @ "," "\r" subst 1
      strcut swap pop dup strlen 1 - strcut pop "%s" subst ansi_notify
   REPEAT
   Options !
   Options @ "1" stringcmp not if
      Channel @ if
         Channel @ CHC-Private? over over getpropstr "yes" stringcmp not if
            ""
         else
            "yes"
         then
         setprop me @ "^CSUCC^Toggled." ansi_notify 1 exit
      else
         CHG-Banned EDIT-plyr_dir 1 exit
      then
   then
   Options @ "2" stringcmp not if
      Channel @ if
         Channel @ CHC-AllowDIR EDIT-plyr_dir 1 exit
      else
         CHG-AutoBan? over over getpropstr "no" stringcmp not if
            ""
         else
            "no"
         then
         setprop me @ "^CSUCC^Toggled." ansi_notify 1 exit
      then
   then
   Options @ "3" stringcmp not if
      Channel @ if
         me @ "^CYAN^Syntax: ^AQUA^<prop>           ^NORMAL^[Checks if it is equal to 'yes']" ansi_notify
         me @ "        ^AQUA^<prop>:<setting> ^NORMAL^[Checks if it is equal to <setting>]" ansi_notify
         me @ "^CNOTE^Enter a new prop: ^NORMAL^[Or a space, then enter, for nothing]" ansi_notify
         read strip
         Channel @ CHC-PermProp rot setprop
         me @ "^CSUCC^Set." ansi_notify 1 exit
      else
         CHG-PCreate? over over getpropstr "yes" stringcmp not if
            ""
         else
            "yes"
         then
         setprop me @ "^CSUCC^Toggled." ansi_notify 1 exit
      then
   then
   Options @ "4" stringcmp not if
      Channel @ if
          Channel @ CHC-Announce? over over getpropstr "yes" stringcmp not if
             ""
          else
             "yes"
          then
          setprop me @ "^CSUCC^Toggled." ansi_notify 1 exit
      else
          "^FOREST^Enter the number of days before idle channels should be deleted."
          atell "^FOREST^Enter '0' for there to be no idle channel timeout."
          atell
          read strip dup number? not if ( didn't enter a number )
              pop "^BLUE^Invalid entry." atell 1 exit
          then
          CHG-Timeout rot atoi setprop
          "^GREEN^Set." atell 1 exit
      then
   then
   Options @ "5" stringcmp not if
      Channel @ CHC-Transmit? over over getpropstr "no" stringcmp not if
         ""
      else
         "no"
      then
      setprop me @ "^CSUCC^Toggled." ansi_notify 1 exit
   then
   Options @ "6" stringcmp not if
      Channel @ CHC-TransDIR EDIT-plyr_dir 1 exit
   then
   Options @ "7" stringcmp not if
      me @ "^CYAN^Syntax: ^AQUA^<prop>           ^NORMAL^[Checks if it is equal to 'yes']" ansi_notify
      me @ "        ^AQUA^<prop>:<setting> ^NORMAL^[Checks if it is equal to <setting>]" ansi_notify
      me @ "^CNOTE^Enter a new prop: ^NORMAL^[Or a space, then enter, for nothing]" ansi_notify
      read strip
      Channel @ CHC-TranProp rot setprop
      me @ "^CSUCC^Set." ansi_notify 1 exit
   then
   Options @ "8" stringcmp not if
      Channel @ CHC-Names? over over getpropstr "no" stringcmp not if
         ""
      else
         "no"
      then
      setprop me @ "^CSUCC^Toggled." ansi_notify 1 exit
   then
   Options @ "9" stringcmp not if
      Channel @ CHC-Title? over over getpropstr "no" stringcmp not if
         ""
      else
         "no"
      then
      setprop me @ "^CSUCC^Toggled." ansi_notify 1 exit
   then
   Options @ "10" stringcmp not if
      Channel @ CHC-Prefix? over over getpropstr "no" stringcmp not if
         ""
      else
         "no"
      then
      setprop me @ "^CSUCC^Toggled." ansi_notify 1 exit
   then
   Options @ "11" stringcmp not if
      Channel @ CHC-GagDIR EDIT-plyr_dir 1 exit
   then
   Options @ "12" stringcmp not if
      Channel @ CHC-BanDIR EDIT-plyr_dir 1 exit
   then
   Options @ "13" stringcmp not if
      Channel @ CHC-Cemit? over over getpropstr "yes" stringcmp not if
         ""
      else
         "yes"
      then
      setprop me @ "^CSUCC^Toggled." ansi_notify 1 exit
   then
   Options @ "14" stringcmp not if
      Channel @ CHC-CemitDIR EDIT-plyr_dir 1 exit
   then
   Options @ "15" stringcmp not if
      Channel @ CHC-ProtoNet? over over getpropstr "yes" stringcmp not if
         ""
      else
         "yes"
      then
      setprop me @ "^CSUCC^Toggled." ansi_notify 1 exit
   then
   Options @ "16" stringcmp not if
      me @ "Returning 'yes', 'okay', or a positive integer will pass the MPI lock." ansi_notify
      me @ "^CNOTE^Enter a new mpi lock: ^NORMAL^[Or a space, then enter, for nothing]" ansi_notify
      read strip
      Channel @ CHC-PermMPI rot setprop
      me @ "^CSUCC^Set." ansi_notify 1 exit
   then
   Options @ "17" stringcmp not if
      me @ "Returning 'yes', 'okay', or a positive integer will pass the MPI lock." ansi_notify
      me @ "^CNOTE^Enter a new mpi lock: ^NORMAL^[Or a space, then enter, for nothing]" ansi_notify
      read strip
      Channel @ CHC-TransMPI rot setprop
      me @ "^CSUCC^Set." ansi_notify 1 exit
   then
   Options @ "18" stringcmp not if
      me @ "Returning 'yes', 'okay', or a positive integer will pass the MPI lock." ansi_notify
      me @ "^CNOTE^Enter a new mpi lock: ^NORMAL^[Or a space, then enter, for nothing]" ansi_notify
      read strip
      Channel @ CHC-CemitMPI rot setprop
      me @ "^CSUCC^Set." ansi_notify 1 exit
   then
   Options @ "S" stringcmp not if
      Channel @ CHC-Auto-On? over over getpropstr "yes" stringcmp not if
         ""
      else
         "yes"
      then
      setprop me @ "^CSUCC^Toggled." ansi_notify 1 exit
   then
   Options @ "A" stringcmp not if
      Channel @ CHC-AutoJoin? over over getpropstr "yes" stringcmp not if
         ""
      else
         "yes"
         Channel @ CHC-DefAlias getpropstr strip not if
            me @ "^CNOTE^Enter a new default alias:" ansi_notify
            BEGIN
               read dup not WHILE pop
               me @ "^CFAIL^You have to enter in an alias.  Try again."
               ansi_notify
            REPEAT
            Channel @ CHC-DefAlias rot setprop
            me @ "^CSUCC^Set." ansi_notify
         then
      then
      setprop me @ "^CSUCC^Toggled." ansi_notify 1 exit
   then
   Options @ "D" stringcmp not if
      me @ "^CNOTE^Enter a new default alias:" ansi_notify
      BEGIN
         read dup not WHILE pop
         me @ "^CFAIL^You have to enter in an alias.  Try again." ansi_notify
      REPEAT
      Channel @ CHC-DefAlias rot setprop
      me @ "^CSUCC^Set." ansi_notify 1 exit
   then
   Options @ "T" stringcmp not if
      channel @ CHC-Timeout? getpropstr "no" stringcmp not if
          channel @ CHC-Timeout? remove_prop
      else
          channel @ CHC-Timeout? "no" setprop
      then "^GREEN^Toggled." atell 1 exit
   then
   Options @ "Q" stringcmp not if
      me @ "^CSUCC^Quiting editor." ansi_notify 0 exit
   then
;
 
: CHAN-edit[ str:Channel -- ]
   Channel @ if
      Channel @ dup if CHU-AliasREF else pop "" then dup not if
         pop Channel @
      then
      Channel !
      Channel @ CHC-DIR propdir? not if
         me @ "^CFAIL^COMSYS: That channel does not exist." ansi_notify exit
      then
   then
   me @ "WIZARD" flag? Channel @ if
      Channel @ CHC-Owner getpropref me @ dbcmp or
   then
   not if
      me @ "^CFAIL^COMSYS: Permission denied." ansi_notify exit
   then
   BEGIN
      Channel @ EDIT-do_option not if
         exit
      then
   REPEAT
;
 
: COMM-Queued[ str:STRtype -- ]
   VAR STRchann
   "$Lib/ProtoNet" match dup ok? if
      "DAEMON_PLAYER" call me @ dbcmp if
         exit
      then
   else
      pop
   then
   me @ USER-channels
   FOREACH
      pop STRchann !
      STRchann @ CH2-gagged? remove_prop
   REPEAT
   STRtype @ "Connect" stringcmp not if
      me @ USER-channels
      FOREACH
         pop dup CHC-Announce? getpropstr "yes" stringcmp not
         over CHC-ProtoNet? getpropstr "yes" stringcmp not not and if
            me @ swap me @ awake? 1 >
            if CHM-Reconnect else CHM-Connect then USER-send pop
         else
            pop
         then
      REPEAT
      me @ "@ChannelUsed?" getpropstr "yes" stringcmp not if
         me @ "@ChannelUsed?" remove_prop
         "" CHC-DIR array_get_propdirs
         FOREACH
            swap pop CH2-Tried? "yes" setprop
         REPEAT
      then
      "" CHC-DIR array_get_propdirs
      FOREACH
         swap pop STRchann !
         STRchann @ CHC-AutoJoin? getpropstr "yes" stringcmp not
         me @ STRchann @ USER-canjoin? and
         STRchann @ CH2-Tried? getpropstr "yes" stringcmp not not and if
            me @ STRchann @ STRchann @ CHC-DefAlias getpropstr
            dup not if pop STRchann @ then 0 0 USER-addcom pop
            STRchann @ CH2-Tried? "yes" setprop
         then
      REPEAT
      STRchann @ CH2-Tried? "yes" setprop
   else
      STRtype @ "Disconnect" stringcmp not if
         me @ USER-channels
         FOREACH
            pop dup CHC-Announce? getpropstr "yes" stringcmp not
            over CHC-ProtoNet? getpropstr "yes" stringcmp not not and if
               me @ swap CHM-Disconnect USER-send pop
            else
               pop
            then
         REPEAT
      then
   then
;
 
: COMM-help ( str:Help -- )
   strip BEGIN DUP
      not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat
         ansi_notify
         me @ "^GREEN^Common commands:" ansi_notify
         me @ "^FOREST^  alias        addcom       allcom" ansi_notify
         me @ "^FOREST^  comtitle     clearcom     delcom" ansi_notify
         me @ "^FOREST^  comlist" ansi_notify
         me @ "^GREEN^Administration/Channel owner commands:" ansi_notify
         me @ "^FOREST^  @ccreate     @cboot       @cchown" ansi_notify
         me @ "^FOREST^  @cdestroy    @clist       @cedit" ansi_notify
         me @ "^FOREST^  @cwho        @cemit       @addcom" ansi_notify
         me @ "^FOREST^  @delcom      @comlist     @cban" ansi_notify
         me @ "^FOREST^  @cgag        @cunban      @cungag" ansi_notify
         me @ "^GREEN^Topics:" ansi_notify
         me @ "^FOREST^  COLORS       NEW          CREDITS" ansi_notify
         me @ "^CYAN^Type '^AQUA^comsys <command>^BOLD^' to get more info on it."
         ansi_notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "credits" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ " Moose/Van - The creation of the ProtoMUCK comsys, reworking of ProtoNet," ansi_notify
         me @ "             and for his work on ProtoMUCK."
         me @ " Akari     - For all of the work on ProtoMUCK.  Deserves just as much credit" ansi_notify
         me @ "             as myself.  No less than that!  If it wasn't for Akari, then" ansi_notify
         me @ "             I'd of never of worked on the Proto Projects." ansi_notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "new" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^WHITE^v2.1.4: [Moose]" ansi_notify
         me @ " - Bugfixes in @cedit" ansi_notify
         me @ "^WHITE^v2.1.3: [Cutey_Honey]" ansi_notify
         me @ " - ToDbref now uses 'match' to resolve '$lib/comsys'.  This means" ansi_notify
         me @ "   that getpropref works.  While I don't know yet if the 'random" ansi_notify
         me @ "   dropped from channel' bug is gone, at least the victim can get" ansi_notify
         me @ "   right back on." ansi_notify
         me @ "^WHITE^v2.1.2: [ Akari ]" ansi_notify
         me @ " - Fixed a rare abort error due to an invalid descriptor." ansi_notify
         me @ "^WHITE^v2.1.1: [ Akari ]" ansi_notify
         me @ " - Made it so that if the channel owner is invalid, the channel gets turned" ansi_notify
         me @ "   over to the owner of the program." ansi_notify
         me @ " - Added Channel timeout support. The global timeout is set via '@cedit'." ansi_notify
         me @ " - A wiz can set individual channels as being immune to timing out by" ansi_notify
         me @ "   using '@cedit <channel>'." ansi_notify
         me @ "^WHITE^v2.1.0: [ Akari ]" ansi_notify
         me @ " - Cleaned up to mostly 80 column width." ansi_notify
         me @ " - Added new directives." ansi_notify
         me @ " - Beginning designs for fixing some of the remaining issues." ansi_notify
         me @ "^WHITE^v2.0.3:" ansi_notify
         me @ " - Colors work in comtitle's again, and comtitles are now underlined for ansi users." ansi_notify
         me @ " - Fixed a security bug from the last version where anybody could join any channel." ansi_notify
         me @ " - Fixed another security bug where wizards didn't gain special permissions to join" ansi_notify
         me @ "   a channel and avoid being gagged, not being able to transmit, etc." ansi_notify
         me @ "^WHITE^v2.0.2:" ansi_notify
         me @ " - <alias> |^^_^^ will now work. The | method of spoofing now does not parse colours." ansi_notify
         me @ "   However, the @cemit method does.  But @cemit is limited to wizards only." ansi_notify
         me @ " - Made sure that the | method of spoofing always has the channel prefix, and also" ansi_notify
         me @ "   always adds the ( ) brackets around it.  However, @cemit does not do either." ansi_notify
         me @ " - Temporary gagging is now removed upon connection and disconnect." ansi_notify
         me @ " - @cwho now says if a player is offline when used by a wizard." ansi_notify
         me @ " - Added MPI locks for many options." ansi_notify
         me @ " - Changed @cchown around so that it works better and more securely." ansi_notify
         me @ "^WHITE^v2.0.1:" ansi_notify
         me @ " - A few bug fixes.  A lot of past problems should be fixed." ansi_notify
         me @ "^WHITE^v2.0.0:" ansi_notify
         me @ " - Full ProtoNet support!  Only supports two channels: WizNet and ProtoNet" ansi_notify
         me @ " - Full recoding for cleaner and better to understand code.  Oh, and cleaner code." ansi_notify
         me @ " - Enhanced interface.  Just looks better, and adds a little more." ansi_notify
         me @ " - Better public function support.  Now your programs can do a hell of a lot more." ansi_notify
         me @ "   [Note: @register this program as \"$lib/comsys\"]" ansi_notify
         me @ " - No longer uses huh_command in @tune.  Huh_command will be removed in later" ansi_notify
         me @ "   versions of ProtoMUCK, thus comsys switched to the @Command propdir." ansi_notify
         me @ " - Colour customization support.  Now people can finally have his or her own colours." ansi_notify
         me @ " - @cemit now accepts colour codes so that it'll be easier to make a custom @cemit/channel spoofer." ansi_notify
         me @ " - You can use multiple alias' with addcom and delcom now using a semicolon." ansi_notify
         me @ " - Better checking for if a player is on a channel or not." ansi_notify
         me @ " - 'Comlist' is organized a little better." ansi_notify
         me @ " - Admin can now set/remove others comtitles in case of profanity, etc." ansi_notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "colors" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "There are ways to replace the colors in comsys messages now." notify
         me @ "The properties to set are the following:" notify
         me @ "  ^WHITE^/_/COMSYS/BORDER ^NORMAL^<Brackets Around Title>" ansi_notify
         me @ "  ^WHITE^/_/COMSYS/TITLE  ^NORMAL^<Channel Title>" ansi_notify
         me @ "  ^WHITE^/_/COMSYS/TEXT   ^NORMAL^<Pose Text>" ansi_notify
         me @ "  ^WHITE^/_/COMSYS/QUOTE  ^NORMAL^<Quotes>" ansi_notify
         me @ "  ^WHITE^/_/COMSYS/MESG   ^NORMAL^<Message Inside Quotes>" ansi_notify
         me @ "Set each of these to proper neon/glow colors without the ^^'s." notify
         me @ "To find out what colors there are, type '^WHITE^man neon ansi^NORMAL^'" ansi_notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "alias" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^alias" ansi_notify
         me @ "        ^CRIMSON^<alias> <on|off|who|[Text]>" ansi_notify
         me @ "Typing 'alias' on its own will give you a list of of alias' that you" notify
         me @ "have in the same sort of way as comlist." notify
         me @ "The alias' you have can then be ran with either the on paramater," notify
         me @ "which will go on the channel, or off, which will leave the channel," notify
         me @ "or who, which will show who is on the channel and online, or if text" notify
         me @ "is put in, then it will transmit the message across the channel." notify
         me @ "Using | for spoofing (Wizards only) and :, ; for poses is allowed." notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "addcom" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^addcom <alias>=<channel>" ansi_notify
         me @ "This will join the channel if the user has permission to join it," \notify
         me @ "but it will also allow the user to add multiple alias' for a channel." \notify
         me @ "^YELLOW^Note: ^BROWN^If a command already exists for the alias you chose then it will" ansi_notify
         me @ "^BROWN^      not work.  To get it to work, do these steps *after* you addcom:" ansi_notify
         me @ "    @action <alias>=me" ansi_notify
         me @ "    @link <alias>=" prog dtos strcat ansi_notify
         me @ "^BROWN^      Presto!  The alias will now work. But if you delete it then it" ansi_notify
         me @ "^BROWN^      will stop working even though the action still exists." ansi_notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "allcom" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^allcom <on|off|who>" ansi_notify
         me @ "This will allow you to either go on or off a channel, or see who" \notify
         me @ "is on every channel that you have an alias for." \notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "comtitle" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^comtitle <channel>=<text>" ansi_notify
         me @ "This will set a comtitle for a channel of your choice.  A comtitle" \notify
         me @ "is what goes before the players name.  Or, if the channel allows it," \notify
         me @ "what replaces the players name." \notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "clearcom" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^clearcom" ansi_notify
         me @ "This command will remove all channel information, alias', etc of yours." \notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "delcom" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^delcom <alias>" ansi_notify
         me @ "This command will remove a channel alias, but if you have no more alias'" \notify
         me @ "for that channel, then it removes you from it completly." \notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "comlist" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^comlist" ansi_notify
         me @ "This, like alias, will list all of your channels and the alias' for each" \notify
         me @ "one, along with a bunch of extra information." \notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "@addcom" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@addcom <player/object>=<alias>=<channel>" ansi_notify
         me @ "Forces a player or object to join a channel with the given alias.  Wizards only." notify
         me @ "but it will also allow the user to add multiple alias' for a channel." \notify
         me @ "^YELLOW^Note: ^BROWN^If a command already exists for the alias you chose then it will" ansi_notify
         me @ "^BROWN^      not work.  To get it to work, do these steps *after* you addcom:" ansi_notify
         me @ "    @action <alias>=<player/object>" ansi_notify
                  me @ "    @link <alias>=" prog dtos strcat ansi_notify
         me @ "^BROWN^      Presto!  The alias will now work. But if you delete it then it" ansi_notify
         me @ "^BROWN^      will stop working even though the action still exists." ansi_notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "@delcom" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@delcom <player/object>=<alias>" ansi_notify
         me @ "Forces a player or object to remove a given alias/channel.  Wizards only." notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "@comlist" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@comlist <player/object>" ansi_notify
         me @ "Get a com listing for any given player/object.  Wizards only." notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "@ccreate" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@ccreate <channel>" ansi_notify
         me @ "Creates a new channel with default settings." \notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "@cboot" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@cboot <channel>=<player/object>" ansi_notify
         me @ "        ^CRIMSON^@cboot <channel>=*" ansi_notify
         me @ "        ^CRIMSON^@cboot *=<player/object>" ansi_notify
         me @ "Boots another player off of the channel.  It will also allow for you to" \notify
         me @ "substitute a * for either channel or player, where * translates to 'all'." \notify
         me @ "This will also work for booting objects in place of players.  Be warned," \notify
         me @ "it will boot the player or object off completly!  Their alias' will be" \notify
         me @ "removed along with the boot." \notify
         CHG-AutoBan? getpropstr "no" stringcmp if
            me @ "^YELLOW^Note: ^BROWN^Booted users *will* be banned." ansi_notify
         then
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "@cchown" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@cchown <channel>=<player>" ansi_notify
         me @ "Allow a user to @cchown the cannel to themselves, or if ran by a wizard," \ansi_notify
         me @ "just hand it over." \ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@cchown <channel>" ansi_notify
         me @ "Take posession of a channel if it is set chown-okay to you." ansi_notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "@cdestroy" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@cdestroy <channel>" ansi_notify
         me @ "Completly remove a channel off of the muck.  It won't even exist anymore." \notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "@clist" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@clist" ansi_notify
         me @ "List all channels you have access to, plus a bit of extra information." \notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "@cedit" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@cedit" ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@cedit <channel>" ansi_notify
         me @ "Edit a channel's options to whatever settings you wish for them to be." \notify
         me @ "However, @cedit on its own will allow wizards to edit the global config." \notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "@cwho" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@cwho <channel>" ansi_notify
         me @ "Check to see who is on a channel, even of those who are asleep and dark," \notify
         me @ "but you must have access to the channel to do this." \notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "@cemit" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@cemit <channel>=<text>" ansi_notify
         me @ "Emit text to a channel.  You must own the channel, or be a wizard to be" \notify
         me @ "able to emit to the specific channel though." \notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "@cban" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@cban <user>" ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@cban <user>=<channel>" ansi_notify
         me @ "The @cban command will allow wizards to ban a user from comsys entirely, but" \notify
         me @ "channel owners and wizards can also ban the user from a specific channel instead." \notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "@cgag" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@cgag <channel>" ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@cgag <user>=<channel>" ansi_notify
         me @ "If a user wants to temporarily gag themselves off of a channel, then the" \notify
         me @ "first command will gag then from a channel until connect/disconnect." \notify
         me @ "The second command is for channel owners or wizards; it will allow the" \notify
         me @ "player who controls a channel to prevent a player from speaking on a channel." \notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "@cunban" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@cunban <user>" ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@cunban <user>=<channel>" ansi_notify
         me @ "This command basicly turns off the effects of @cban." \notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      "@cungag" stringcmp not IF POP
         me @ "^WHITE^" CHAN-version strcat ansi_notify
         me @ "" "~" CHAN-version strlen 1 + STRfillfield "^PURPLE^" swap strcat ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@cungag <channel>" ansi_notify
         me @ "^CYAN^Syntax: ^NORMAL^^CRIMSON^@cungag <user>=<channel>" ansi_notify
         me @ "This command basicly turns off the effects of @cgag." \notify
         me @ "^GREEN^*^FOREST^Done^BOLD^*" ansi_notify
      BREAK THEN DUP
      POP POP 1 IF me @ "^RED^Invalid topic for comsys." ansi_notify BREAK THEN DUP
   POP POP 1 UNTIL
;
 
: main ( str:Args -- )
  var TEMP ( temp var for debugging purposes )
  dup TEMP !
   #0 "/_/COLORS/COMSYS" propdir? not if
      #0 "/_/COLORS/COMSYS/QUOTE"  CH-Quote  setprop
      #0 "/_/COLORS/COMSYS/TEXT"   CH-Text   setprop
      #0 "/_/COLORS/COMSYS/MESG"   CH-Mesg   setprop
      #0 "/_/COLORS/COMSYS/BORDER" CH-Border setprop
      #0 "/_/COLORS/COMSYS/TITLE"  CH-Title  setprop
   then
   #0 "_Reg/Lib/Comsys" getprop ToDBref ok? if
      #0 "_Reg/Lib/Comsys" prog setprop
   then
   command @ "Queued Event." stringcmp not if
      COMM-Queued exit
   then
   dup strip "#help" stringcmp not over strip "#help " instring 1 = or if
      striplead 5 strcut swap pop strip COMM-help exit
   then
(   me @ "@Channel/Alias" propdir? if
      me @ "@Channel/Alias" array_get_propvals
      FOREACH
         over dup if CHU-AliasREF else pop 0 then if
            dup CHU-AliasREF CHC-DIR propdir? not if
               pop pop CONTINUE
            then
            me @ "@Command/" 4 rotate strcat rot pop "$lib/comsys" setprop
         else
            pop pop
         then
      REPEAT
   then )
   command @ "delcom" stringcmp not command @ "@delcom" stringcmp not or if
      command @ "@delcom" stringcmp not if "=" split dup else "" 0 then if
         swap dup match dup #-1 dbcmp if
            pop pmatch
         else
            swap pop
         then
      else
         pop me @
      then
      dup ok? not if
         swap pop #-2 dbcmp if
            "^CINFO^COMSYS: I don't know which one you mean!"
         else
            "^CINFO^COMSYS: I cannot find that player nor object."
         then
         ANSI-Tell exit
      then
      me @ over controls not if
         pop pop "^CFAIL^COMSYS: Permission deined." ANSI-Tell exit
      then
      swap strip 0 USER-delcom pop exit
   then
   command @ "addcom" stringcmp not command @ "@addcom" stringcmp not or if
      command @ "@addcom" stringcmp not if "=" split dup else "" 0 then if
         swap dup match dup #-1 dbcmp if
            pop pmatch
         else
            swap pop
         then
      else
         pop me @
      then
      dup ok? not if
         swap pop #-2 dbcmp if
            "^CINFO^COMSYS: I don't know which one you mean!"
         else
            "^CINFO^COMSYS: I cannot find that player nor object."
         then
         ANSI-Tell exit
      then
      me @ over controls not if
         pop pop "^CFAIL^COMSYS: Permission denied." ANSI-Tell exit
      then
      swap strip "=" split strip swap strip me @ "WIZARD" flag? 0 USER-addcom
      pop exit
   then
   ( Checks to see if the command is an alias on the player and if the player
     has the channel directory on themself )
   command @ CHU-AliasREF strip dup if
       dup CH2-DIR propdir? if 1 else pop 0 then
   else pop 0
   then
   ( either 0 or 'channel name' 1 )
   if dup strip ( if it is a channel, then )
       if dup CHC-DIR propdir? not else 0 then (is it an invalid channel? )
       if (it is an invalid channel now )
           strip dup if dup CH2-DIR .debug-on remove_prop .debug-off then
           command @ CHU-Alias remove_prop
           me @ "@command/" command @ strcat remove_prop
           pop pop "^CFAIL^COMSYS: That channel no longer exists." ANSI-Tell exit
       then
       dup strip if me @ over USER-joined? not else 0 then
       if (if not joined )
          strip dup if dup CH2-DIR .debug-on remove_prop .debug-off then
          command @ CHU-Alias remove_prop
          me @ "@command/" command @ strcat remove_prop
          pop pop "^CFAIL^COMSYS: You aren't on that channel." ANSI-Tell exit
       then
       me @ "@Command/" command @ strcat getpropstr "$lib/comsys" stringcmp not
       not if ( set the command prop if it isn't already there )
          me @ "@Command/" command @ strcat "$lib/comsys" setprop
       then
       over strip not if
          pop pop "^CYAN^Syntax: ^AQUA^<alias> <on|off|who|[text]>" ANSI-Tell
          exit
       then
       over strip "on" stringcmp not 3 pick strip "#on" stringcmp not or if
          swap pop me @ over USER-on? if
             pop "^CFAIL^COMSYS: You are already on that channel!" ANSI-Tell exit
          then
          dup CH2-on? "yes" setprop
          me @ swap strip CHM-JoinMsg USER-send pop
          "^CSUCC^COMSYS: Channel turned on." ANSI-Tell exit
       then
       over strip "off" stringcmp not 3 pick strip "#off" stringcmp not or if
          swap pop me @ over USER-on? not if
             pop "^CFAIL^COMSYS: You are already off that channel!" ANSI-Tell
             exit
          then
          me @ over strip CHM-LeaveMsg USER-send pop
          CH2-on? "no" setprop
          "^CSUCC^COMSYS: Channel turned off." ANSI-Tell exit
       then
       over strip "who" stringcmp not 3 pick strip "#who" stringcmp not or if
          swap pop me @ "" rot strip 0 CHAN-who pop exit
       then
       me @ swap rot USER-send pop exit
    else
       me @ "@Command/" command @ strcat getpropref prog dbcmp if
          me @ "@Command/" command @ strcat remove_prop pop
          command @ CHU-Alias remove_prop
          me @ "^CINFO^" "huh_mesg" sysparm "^^" "^" subst strcat ansi_notify
          exit
       then
    then
    command @ "comsys" stringcmp not command @ "help comsys" stringcmp not or if
      COMM-help exit
    then
    command @ "alias" stringcmp not command @ "comlist" stringcmp not or
    command @ "@comlist" stringcmp not or if
      strip dup if
         dup match dup #-1 dbcmp if
            pop pmatch
         else
            swap pop
         then
      else
         pop me @
      then
      dup ok? not if
         #-2 dbcmp if
            "^CINFO^COMSYS: I don't know which one you mean!"
         else
            "^CINFO^COMSYS: I cannot find that player nor object."
         then
         ANSI-Tell exit
      then
      me @ over controls not if
         pop "^CFAIL^COMSYS: Permission denied." ANSI-Tell exit
      then
      CHAN-comlist exit
   then
   command @ "@clist" stringcmp not if
      pop me @ CHAN-chanlist pop exit
   then
   command @ "clearcom" stringcmp not command @ "@clearcom" stringcmp not or if
      strip dup if
         dup match dup #-1 dbcmp if
            pop pmatch
         else
            swap pop
         then
      else
         pop me @
      then
      dup ok? not if
         #-2 dbcmp if
            "^CINFO^COMSYS: I don't know which one you mean!"
         else
            "^CINFO^COMSYS: I cannot find that player nor object."
         then
         ANSI-Tell exit
      then
      me @ over controls not if
         pop "^CFAIL^COMSYS: Permission denied." ANSI-Tell exit
      then
      0 USER-clearcom pop exit
   then
   command @ "comtitle" stringcmp not command @ "@comtitle" stringcmp not or if
      dup "=" split dup "=" instr if
         swap dup match dup #-1 dbcmp if
            pop pmatch
         else
            swap pop
         then
         dup ok? not if
            pop pop me @
         then
      else
         pop pop me @
      then
      me @ over controls not if
         pop "^CFAIL^COMSYS: Permission denied." ANSI-Tell exit
      then
      swap "=" split swap strip swap 0 USER-comtitle pop exit
   then
   command @ "allcom" stringcmp not if
      "=" split dup if
         swap dup match dup #-1 dbcmp if
            pop pmatch
         else
            swap pop
         then
      else
         pop me @
      then
      me @ over controls not if
         pop "^CFAIL^COMSYS: Permission denied." ANSI-Tell exit
      then
      swap 0 USER-allcom pop exit
   then
   command @ "@ccreate" stringcmp not if
      strip CHAN-chancreate pop exit
   then
   command @ "@cdestroy" stringcmp not if
      strip CHAN-chandelete pop exit
   then
   command @ "@cedit" stringcmp not if
      strip CHAN-edit exit
   then
   command @ "@cban" stringcmp not command @ "@cunban" stringcmp not or if
      "=" split
      swap dup match dup #-1 dbcmp if
         pop pmatch
      else
         swap pop
      then
      dup ok? if owner then
      swap strip command @ "@cban" stringcmp not USER-ban pop exit
   then
   command @ "@cgag" stringcmp not command @ "@cungag" stringcmp not or if
      "=" split dup if
         swap dup match dup #-1 dbcmp if
            pop pmatch
         else
            swap pop
         then
      else
         pop me @
      then
      dup ok? if owner then
      swap strip command @ "@cgag" stringcmp not USER-gag pop exit
   then
   command @ "@cchown" stringcmp not if
      "=" split dup if
         dup match dup #-1 dbcmp if
            pop pmatch
         else
            swap pop
         then
      else
         pop me @
      then
      swap strip USER-chown pop exit
   then
   command @ "@cboot" stringcmp not if
      "=" split dup if
         dup "*" strcmp not if
            pop #-4
         else
            dup match dup #-1 dbcmp if
               pop pmatch
            else
               swap pop
            then
         then
      else
         pop #-4
      then
      swap dup "*" strcmp not if
         pop ""
      then
      strip USER-boot pop exit
   then
   command @ "@cwho" stringcmp not if
      strip me @ "" rot strip 1 CHAN-WHO pop exit
   then
   command @ "@cemit" instring 1 = command @ strlen 3 >= and if
      me @ "WIZARD" flag?
      "CEMIT" ISpower? if
         me @ "CEMIT" power? or
      then
      not if
         "^CFAIL^COMSYS: Permission denied.  Only wizards can use @cemit."
         ANSI-Tell exit
      then
      me @ swap "=" split swap strip swap 0 USER-cemit pop exit
   then
   ( Shouldn't be getting here. x.x Getting here is the problem.
     It deletes the player's command prop alias, but leaves the rest
     hence the problems. So we need to know why it is getting here.
     Putting in an abort for now to hopefully track it down.
   )
   prog "D" set
   me @ name " entered " strcat command @ strcat " " strcat TEMP @ strcat
   prog owner swap notify
   prog "!D" set
   "Internal Error in Comsys. Please provide a detailed report of what you entered."
   abort
   me @ "@Command/" command @ strcat getprop ToStr dup "$Lib/Comsys"
   stringcmp not swap ToDBref prog dbcmp or if
      me @ "@Command/" command @ strcat remove_prop
   then
   me @ "^CFAIL^Invalid command." ansi_notify
;
$pubdef CHAN-chancreate "$Lib/Comsys" match "CHAN-chancreate" call
$pubdef CHAN-chandelete "$Lib/Comsys" match "CHAN-chandelete" call
$pubdef CHAN-chanlist "$Lib/Comsys" match "CHAN-chanlist" call
$pubdef CHAN-comlist "$Lib/Comsys" match "CHAN-comlist" call
$pubdef CHAN-numusers "$Lib/Comsys" match "CHAN-numusers" call
$pubdef CHAN-send "$Lib/Comsys" match "CHAN-send" call
$pubdef CHAN-users "$Lib/Comsys" match "CHAN-users" call
$pubdef CHAN-who "$Lib/Comsys" match "CHAN-who" call
$pubdef COMM-help "$Lib/Comsys" match "COMM-help" call
$pubdef USER-addcom "$Lib/Comsys" match "USER-addcom" call
$pubdef USER-aliases "$Lib/Comsys" match "USER-aliases" call
$pubdef USER-allcom "$Lib/Comsys" match "USER-allcom" call
$pubdef USER-ban "$Lib/Comsys" match "USER-ban" call
$pubdef USER-boot "$Lib/Comsys" match "USER-boot" call
$pubdef USER-cemit "$Lib/Comsys" match "USER-cemit" call
$pubdef USER-channels "$Lib/Comsys" match "USER-channels" call
$pubdef USER-chown "$Lib/Comsys" match "USER-chown" call
$pubdef USER-clearcom "$Lib/Comsys" match "USER-clearcom" call
$pubdef USER-comtitle "$Lib/Comsys" match "USER-comtitle" call
$pubdef USER-delcom "$Lib/Comsys" match "USER-delcom" call
$pubdef USER-gag "$Lib/Comsys" match "USER-gag" call
$pubdef USER-send "$Lib/Comsys" match "USER-send" call
ARCHCALL HookPacket
ARCHCALL CHAN-chancreate ( str:Channel                        -- int:Succ      )
ARCHCALL CHAN-chandelete ( str:Channel                        -- int:Succ      )
ARCHCALL CHAN-chanlist   ( ref:Plyr                           -- int:Succ      )
ARCHCALL CHAN-comlist    ( ref:Plyr                           -- int:Succ      )
ARCHCALL CHAN-numusers   ( str:Channel                        -- int:NumUsers  )
ARCHCALL CHAN-users      ( str:Channel                        -- arr:ARRusers  )
ARCHCALL CHAN-send       ( str:Chan str:Msg                   -- int:Succ      )
ARCHCALL CHAN-who        ( ref:Plyr str:SRCmuck str:Channel int:ShowAll?
                                                              -- int:Succ      )
ARCHCALL COMM-help       (                                    --               )
ARCHCALL USER-addcom     ( ref:Plyr str:Chan str:Alias int:Force? int:Quiet?
                                                     -- int:Succ      )
ARCHCALL USER-aliases    ( ref:Plyr str:Channel               -- arr:Alias'    )
ARCHCALL USER-allcom     ( ref:Plyr str:Text                  -- int:Succ      )
ARCHCALL USER-ban        ( ref:Plyr str:Channel int:BOLban?   -- int:Succ      )
ARCHCALL USER-boot       ( ref:Plyr str:Channel               -- int:Succ      )
ARCHCALL USER-cemit      ( ref:Plyr str:Chan str:Text int:ForceTitle?
                                                              -- int:Succ      )
ARCHCALL USER-channels   ( ref:Plyr                           -- dict:Channels )
ARCHCALL USER-chown      ( ref:Plyr str:Channel               -- int:Succ      )
ARCHCALL USER-clearcom   ( ref:Plyr int:Quiet?                -- int:Succ      )
ARCHCALL USER-comtitle   ( ref:Plyr str:Chan str:Title int:Quiet? -- int:Succ  )
ARCHCALL USER-delcom     ( ref:Plyr str:Alias int:Quiet?      -- int:Succ      )
ARCHCALL USER-gag        ( ref:Plyr str:Channel int:BOLgag?   -- int:Succ      )
ARCHCALL USER-send       ( ref:Plyr str:Chan str:Text         -- int:Succ      )
