(*
   Cmd-BBoard v3.22
   Author: Chris Brine [Moose/Van]
 
   NOTE: Be sure to @register this as $Cmd/+BBoard
 
   Version 3.22 [Moose] 01/07/2003
    - Added support for $lib/standard.
    - Fixed some +bbedit bugs
 
   Version 3.21 [Akari] 12/15/2001
    - Fixed the +bbnext 'more messages' support.
 
   Version 3.2 [Akari] 12/10/2001
    - Cleaned this up to be 80 column friendly, except for the parts that were
      beyond hope.
    - Made it so that when +bbcatchup doesn't update any boards, it explains
      how to catchup on all boards.
    - Made it so that +bbnext will report if there are more unread messages
      or not.
 
   * Rewritten yet again to fix the old mess, and integrate many, many
     new features.
 
   Note: Unfortunatly, this version of BBoard, and any later versions,
         will require ProtoMUCK 1.50, or newer.
 
   To Do:
     - Add the AUTOSHOW feature so that +bboard can become its own
       advanced MOTD system. [Only settable by wizards]
        : Online players automaticly see *any* new posts
        : Logging in players automaticly see the posts on login
     - Make an auto-cleaner to make sure that all of the message
       properties are set and removed properly
   [ +bbconvert, +bbsetup ]
*)
 
$author  Moose Akari
$version 3.22
 
(* Required External Libraries *)
$include $lib/arrays  (v2.0.0 or newer)
$include $lib/editor  (v2.0.1 or newer)
$include $lib/strings
$include $lib/standard
 
$def atell me @ swap ansi_notify
 
(* Gobal Variables *)
VAR BB-Var
 
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
      stod exit
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
 
$define GETPROPVAL getprop ToInt                         $enddef
$define GETPROPREF getprop ToDBref                       $enddef
$define SETPROP    ToStr \setprop                        $enddef
 
: BB-Board2 ( -- ref:BoardObj )
   trig ok? if
      trig owner "TRUEWIZARD" flag?
      trig location #0 dbcmp trig "WIZARD" flag? or and if
         BB-Board
      else
         trig
      then
   else
      BB-Board
   then
;
 
: BBoard ( -- ref:BoardObj )
(*
   This will allow triggers to point to different objects for the +BBoard date
 *)
   BB-Var @ dup dbref? if dup ok? not else 0 then not if
      pop trig ok? if
         trig BBT-Object getprop dup if
            ToDBref dup ok? not if
               pop BB-Board2
            else
               trig owner over controls not if
                  pop BB-Board2
               then
            then
         else
            pop BB-Board2
         then
      else
         BB-Board2
      then
      dup BB-Var !
   then
;
 
: BB-GroupNum ( -- int:Num )
   BBoard BB-Board dbcmp if
      trig ok? if
         trig BBT-MsgGrp getprop ToInt
      else
         0
      then
   else
      1
   then
;
 
: isGuest? ( ref:Plyr -- int:Bol )
   "GUEST" flag?
;
 
: isPlayer? ( ref:Plyr -- int:Bol )
   BBoard BB-Board dbcmp if
      Player?
   else
      dup Player? swap dup thing? swap "Z" flag? and or
   then
;
 
: Board-MatchName[ str:STRname -- int:Board ]
   BB-GroupNum if
      BB-GroupNum exit
   then
   STRname @ strip dup ":" instr over "/" instr or swap not or if
      0 exit
   then
   STRname @ strip dup STRname ! number? not if
      BBoard BB-NamePath STRname @ strcat getprop ToInt dup not if
         exit
      then
      ToStr STRname !
   then
   BBoard BB-BoardDir STRname @ "%n" subst BB-Exist? strcat getpropstr
   "yes" stringcmp not if
      STRname @ atoi
   else
      0
   then
;
 
: BB-mpi-true? ( str:STRreturn -- int:bol )
   strip dup Number? if
      atoi not not
   else
      dup if
         "{yes|y|true|yup|yeah|yupper|yuppers|oui|hai}" smatch
      else
         pop 0
      then
   then
;
 
: BB-ReadPerm?[ ref:Plyr int:Board -- int:Bol ]
   Plyr @ "WIZARD" flag? if
      1 exit
   then
   BB-GroupNum if
      trig owner me @ owner dbcmp
   else
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-Owner strcat getprop
      ToDbref Plyr @ dbcmp BBoard owner Plyr @ dbcmp or
   then
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Restricted?
   strcat getpropstr "yes" stringcmp not not or
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Allow strcat
   "/" strcat Plyr @ int intostr strcat getprop
   dup string? if dup number? not else 0 then if "yes" stringcmp not else
   ToInt Plyr @ owner timestamps pop pop pop = then or
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Allow strcat "/"
   strcat Plyr @ dtos strcat getprop
   dup string? if dup number? not else 0 then if "yes" stringcmp not else
   ToInt Plyr @ owner timestamps pop pop pop = then or
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-AllowProp strcat getpropstr
   "|" explode_array
   FOREACH
      swap pop ":" split strip swap strip dup if
         BEGIN
            dup "/" rinstr over strlen = WHILE
            dup strlen 1 - strcut pop
         REPEAT
         Plyr @ swap "(+bboard)" 0 parseprop strip over not if
            swap pop "yes" swap
         then
         swap stringcmp not or
      else
         pop pop
      then
   REPEAT
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Owner strcat getprop ToDbref
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-AllowMPI strcat getpropstr
   "(+bboard)" 0 parsempi BB-mpi-true? or
;
 
: BB-WritePerm?[ ref:Plyr int:Board -- int:Bol ]
   0 VAR! idx
   Plyr @ "WIZARD" flag? if
      1 exit
   then
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-ReadOnly? strcat
   getpropstr "yes" stringcmp not if
      idx ++
   then
   BB-GroupNum if
      trig owner me @ owner dbcmp
   else
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-Owner strcat getprop
      ToDbref Plyr @ dbcmp BBoard owner Plyr @ dbcmp or
   then
   Plyr @ owner isGuest? BBoard BB-BoardDir Board @ intostr "%n" subst
   BB-GuestPost? strcat getpropstr "yes" stringcmp and or
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-AllowPost strcat "/" strcat
   Plyr @ int intostr strcat getprop
   dup string? if dup number? not else 0 then if "yes" stringcmp not else
   ToInt Plyr @ owner timestamps pop pop pop = then or
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-AllowPost strcat "/" strcat
   Plyr @ dtos strcat getprop
   dup string? if dup number? not else 0 then if "yes" stringcmp not else
   ToInt Plyr @ owner timestamps pop pop pop = then or
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-PosterProp strcat getpropstr
   "|" explode_array
   FOREACH
      swap pop ":" split strip swap strip dup if
         BEGIN
            dup "/" rinstr over strlen = WHILE
            dup strlen 1 - strcut pop
         REPEAT
         Plyr @ swap "(+bboard)" 0 parseprop strip over not if
            swap pop "yes" swap
         then
         swap stringcmp not or
      else
         pop pop
      then
   REPEAT
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Owner strcat getprop ToDbref
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-AllowPostMPI strcat
   getpropstr "(+bboard)" 0 parsempi BB-mpi-true? or
   idx @ if if 2 else 0 then else pop 1 then
;
 
: BB-Subscribed?[ ref:Plyr int:Board -- int:Bol ]
   BB-GroupNum if
      Plyr @ Board @ BB-ReadPerm? exit
   then
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-AutoSub? strcat
   getpropstr "yes" stringcmp not
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-UserDir strcat "/" strcat
   Plyr @ int intostr strcat getprop
   dup string? if dup number? not else 0 then if "yes" stringcmp not else
   ToInt Plyr @ owner timestamps pop pop pop = then or
   Board @ and
;
 
: Board-TimeOut[ int:Board int:RealMsgNum -- int:Time ]
(*
   Returns -1 if the message is protected, or no timeout is set.
 *)
   VAR MsgTimeOut VAR BoardTimeOut VAR GlobalTimeOut
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir RealMsgNum @
   intostr "%n" subst strcat BBM-Protected? strcat getpropstr "yes" stringcmp
   not if
      -1 exit
   then
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir RealMsgNum @
   intostr "%n" subst strcat BBM-Timeout strcat getprop ToInt MsgTimeOut !
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Timeout strcat getprop
   ToInt BoardTimeOut !
   BBoard BB-DefTimeout getprop ToInt GlobalTimeOut !
   GlobalTimeOut @ BoardTimeOut @ or MsgTimeOut @ or not if
      -1 exit
   then
   BoardTimeOut @ not if
      GlobalTimeOut @ BoardTimeOut !
   then
   MsgTimeOut @ not if
      BoardTimeOut @ MsgTimeOut !
   then
   GlobalTimeOut @ dup BoardTimeOut @ < and if
      GlobalTimeOut @ BoardTimeOut !
   then
   BoardTimeOut @ dup MsgTimeOut @ < and if
      BoardTimeOut @ MsgTimeOut !
   then
   MsgTimeOut @
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir
   RealMsgNum @ intostr "%n" subst strcat
   BBM-Date strcat getprop ToInt systime swap - 86400 / - dup 0 < if pop 0 then
;
 
: BB-UnreadMsgs[ ref:Plyr int:Board -- arr:Msgs ]
   { }list VAR! idx VAR path Plyr @ owner Plyr ! VAR REFtemp VAR MsgNum
   BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir strcat path !
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-MsgNums strcat
   array_get_propvals
   FOREACH
      ToInt swap ToInt MsgNum !
      BBoard path @ 3 pick intostr "%n" subst BBM-Exist? strcat
      getpropstr "yes" stringcmp not if
         BBoard path @ 3 pick intostr "%n" subst BBM-Poster strcat getprop
         ToDBref REFtemp !
         BBoard path @ 3 pick intostr "%n" subst BBM-Date strcat getprop ToInt
         BBoard path @ 4 pick intostr "%n" subst BBM-UserDir strcat "/" strcat
         Plyr @ int intostr strcat getprop ToInt swap over =
         swap Plyr @ timestamps pop pop pop = or not REFtemp @ dup ok? if owner
         then Plyr @ owner dbcmp not and if
            MsgNum @ idx @ array_appenditem idx !
         then
      then
      pop
   REPEAT
   idx @ SORTTYPE_NOCASE_ASCEND \array_sort
;
 
: do_array_notify[ ref:Plyr arr:ARRmsg int:Color? -- ]
   0 VAR! idx VAR pidx VAR cidx
   ARRmsg @ dup array_count cidx !
   Plyr @ BBP-PauseLines getprop ToInt dup not if pop 9999999 then dup pidx !
   cidx @ >= if
      pop ARRmsg @ { Plyr @ }list
      Color? @ if
         array_ansi_notify
      else
         array_notify
      then
      exit
   then
   pidx @ not if
      20 pidx !
   then
   FOREACH
      swap pop idx ++ cidx -- me @ swap
      Color? @ if
         ansi_notify
      else
         notify
      then
      idx @ pidx @ >= if
         me @ "^CYAN^Paused.  ^AQUA^Continue on? "
         "^FOREST^(^GREEN^yes^FOREST^/no) ^NORMAL^[%n lines left]"
         strcat cidx @ intostr "%n" subst ansi_notify
         read strip dup "no" stringcmp not if
            break
         then
         0 idx !
      then
   REPEAT
;
 
: Board-ShowBoards[ -- ]
   VAR idx VAR STRtemp { }list VAR! ARRmsg
   "^WHITE^------------------------------------------------------------------------------"
   atell
   "muckname" sysparm "'s Bulletin Boards" strcat "\["
   swap strcat 79 STRcenter "^AQUA^" "\[" subst atell
   "^WHITE^=============================================================================="
   atell
   "^WHITE^|^FOREST^#    ^WHITE^|^FOREST^Group Name                    ^WHITE^|^FOREST^Last  Post^WHITE^|       ^FOREST^#unread/#mesgs       ^WHITE^|"
   atell
   "^WHITE^------------------------------------------------------------------------------"
   atell
   1 BBoard BB-Count getprop ToInt 1
   FOR
      idx !
      BB-GroupNum not if BBoard BB-BoardDir idx @ intostr "%n" subst BB-Exist?
      strcat getpropstr "yes" stringcmp not else 1 then not if
         CONTINUE
      then
      me @ idx @ BB-Subscribed? me @ idx @ BB-ReadPerm? and if
         BB-BoardDir idx @ intostr "%n" subst STRtemp !
         "^WHITE^|^YELLOW^" idx @ intostr 3 STRleft strcat
         BBoard STRtemp @ BB-Restricted? strcat getpropstr "yes" stringcmp not
         if "^RED^*" else " " then strcat
         BBoard STRtemp @ BB-ReadOnly? strcat getpropstr "yes" stringcmp not if
            me @ idx @ BB-WritePerm? if
               "+"
            else
               "-"
            then
         else
            " "
         then
         strcat "^WHITE^|^PURPLE^" strcat
         BBoard STRtemp @ BB-Name strcat getpropstr 30 STRleft dup strlen
         30 > if 30 strcut pop then
         "^^" "^" subst strcat "^WHITE^|^VIOLET^" strcat
         BBoard STRtemp @ BB-LastPost strcat getpropstr 10 STRcenter dup strlen
         10 > if 10 strcut pop then
         strcat "^WHITE^|^YELLOW^" strcat
         BBoard STRtemp @ BB-Notify strcat me @ owner int intostr strcat getprop
         dup string? if
            dup "yes" stringcmp not over "no" stringcmp not or
         else
            0
         then
         swap ToInt me @ owner timestamps pop pop pop = or if
            "-"
         else
            " "
         then
         strcat "^VIOLET^" strcat
         me @ idx @ BB-UnreadMsgs array_count intostr 13 STRright 13 strcut pop
         "/" strcat
         BBoard STRtemp @ BB-FakeNumMsgs strcat getprop ToInt intostr 13 STRleft
         13 strcut pop strcat
         strcat "^WHITE^|" strcat
         ARRmsg @ array_appenditem ARRmsg !
      then
   REPEAT
   me @ ARRmsg @ 1 do_array_notify
   "^WHITE^------------------------------------------------------------------------------"
   atell
   " ^WHITE^'^RED^*^WHITE^' = ^GREEN^restricted      ^WHITE^'^RED^-^WHITE^' = ^GREEN^read only     ^WHITE^'^RED^+^WHITE^' = ^GREEN^read only, but you can write  "
   atell
   "^WHITE^=============================================================================="
   atell
;
 
: Board-ListBoards[ -- ]
   VAR idx VAR STRtemp { }list VAR! ARRmsg
   "^WHITE^=============================================================================="
   atell
   "^WHITE^|^FOREST^Available Bulletin Board Groups    ^WHITE^|^FOREST^Member?^WHITE^| ^FOREST^Timeout ^WHITE^|^FOREST^Owner                 ^WHITE^|"
   atell
   "^WHITE^------------------------------------------------------------------------------"
   atell
   1 BBoard BB-Count getprop ToInt 1
   FOR
      idx !
      BB-GroupNum not if BBoard BB-BoardDir idx @ intostr "%n" subst BB-Exist?
      strcat getpropstr "yes" stringcmp not else 1 then not if
         CONTINUE
      then
      me @ idx @ BB-ReadPerm? if
         BB-BoardDir idx @ intostr "%n" subst STRtemp !
         "^WHITE^|^YELLOW^" idx @ intostr 4 STRleft strcat "^WHITE^|^PURPLE^"
         strcat
         BBoard STRtemp @ BB-Name strcat getpropstr 30 STRleft dup strlen
         30 > if 30 strcut pop then
         "^^" "^" subst strcat "^WHITE^|^VIOLET^" strcat
         me @ idx @ BB-Subscribed? if "Yes" else "No" then 7 STRcenter strcat
         "^WHITE^|^VIOLET^" strcat
         BBoard STRtemp @ BB-Timeout strcat getprop ToInt dup not if
            pop BBoard BB-DefTimeout getprop ToInt dup not if
               pop "---------"
            else
               dup intostr swap 1 = if " day" else " days" then strcat
            then
         else
            dup intostr swap 1 = if " day" else " days" then strcat
         then
         9 STRcenter dup strlen 9 > if pop "9999 days" then strcat
         "^WHITE^|^VIOLET^" strcat
         BBoard STRtemp @ BB-Owner strcat getprop ToDBref dup player?
         if name else
             pop BBoard STRtemp @ BB-Owner strcat #-1 setprop "Toaded Player"
         then
         22 STRleft dup strlen 22 > if 22 strcut pop then strcat "^WHITE^|"
         strcat
         ARRmsg @ array_appenditem ARRmsg !
      then
   REPEAT
   me @ ARRmsg @ 1 do_array_notify
   "^WHITE^------------------------------------------------------------------------------"
   atell
   "^BLUE^To join groups, type ^WHITE^'^NAVY^+bbjoin ^WHITE^<^AQUA^group number or name^WHITE^>'"
   atell
   "^WHITE^=============================================================================="
   atell
;
 
: BB-find_text_array?[ arr:ARRmsg str:STRtext -- int:BOLtype ]
   ARRmsg @ dup array_count not if
      pop " " STRtext @ smatch exit
   then
   FOREACH
      swap pop STRtext @ smatch if
         1 exit
      then
   REPEAT
   0
;
 
: Board-ListMsgs[ int:Board str:STRmatch int:SearchType -- ]
(*
 * SearchType:
 *  1 = Name
 *  2 = Subject
 *  3 = Message Text
 *  4 = All
 *)
   VAR MsgIdx VAR RealIdx VAR Subj VAR PostOn VAR PostBy VAR STRtemp { }list
   VAR! ARRmsg
   STRmatch @ strip dup STRmatch ! not if
      "*" STRmatch !
   then
   STRmatch @ "*" instr not if
      "*" STRmatch @ over strcat strcat STRmatch !
   then
   Board @ not if
      me @ "^CFAIL^BBOARD: Invalid message board." ansi_notify exit
   then
   me @ Board @ BB-ReadPerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ Board @ BB-Subscribed? not if
      me @ "^CFAIL^BBOARD: You are not subscribed to that board." ansi_notify
      exit
   then
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-FakeNumMsgs strcat getprop
   ToInt not if
      me @ "^CFAIL^BBOARD: There are no messages on that board." ansi_notify
      exit
   then
   BB-GroupNum not if
      "^WHITE^=============================================================================="
      atell
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-Name strcat
      getpropstr "^^" "^" subst "\[" swap strcat
      69 STRcenter "^AQUA^" "\[" subst " ^BLUE^****" strcat "^BLUE^**** " swap
      strcat me @ swap ansi_notify
   then
   "^WHITE^------------------------------------------------------------------------------"
   atell
   BB-GroupNum if
      "^WHITE^|^FOREST^#        ^WHITE^|^FOREST^Message                       ^WHITE^|^FOREST^  Posted  ^WHITE^|^FOREST^By              ^WHITE^|^FOREST^Timeout^WHITE^|"
      atell
   else
      "^WHITE^|^FOREST^#/#      ^WHITE^|^FOREST^Message                       ^WHITE^|^FOREST^  Posted  ^WHITE^|^FOREST^By              ^WHITE^|^FOREST^Timeout^WHITE^|"
      atell
   then
   "^WHITE^------------------------------------------------------------------------------"
   atell
   1 BBoard BB-BoardDir Board @ intostr "%n" subst BB-FakeNumMsgs strcat
   getprop ToInt 1
   FOR
      MsgIdx !
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-MsgNums strcat MsgIdx @
      intostr strcat getprop ToInt RealIdx !
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir
      RealIdx @ intostr "%n" subst strcat dup STRtemp ! BBM-Subject strcat
      getpropstr Subj !
      BBoard STRtemp @ BBM-Date strcat getprop ToInt PostOn !
      BBoard STRtemp @ BBM-Poster strcat getprop ToDbref PostBy ! PostBy @ dup
      ok? if dup player? else 0 then
      not swap #-30 dbcmp not and if
         BBoard STRtemp @ BBM-Poster strcat #-1 setprop
      then
      BB-GroupNum if
         ""
      else
         Board @ intostr "/" strcat
      then
      MsgIdx @ intostr strcat 7 STRleft dup strlen 7 > if 7 strcut pop then
      "^WHITE^/^RED^" "/" subst "^WHITE^|^CRIMSON^" swap strcat
      BBoard STRtemp @ BBM-UserDir strcat me @ int intostr strcat getprop dup
      ToStr swap ToInt dup PostOn @ =
      swap me @ owner timestamps pop pop pop = or swap "yes" stringcmp not or
      not PostBy @ me @ dbcmp not and if
         BBoard STRtemp @ BBM-Urgent? strcat getpropstr "yes" stringcmp not if
            "^RED^!"
         else
            " "
         then
         "^YELLOW^U" strcat
      else
         "  "
      then
      strcat "^WHITE^|^PURPLE^" strcat Subj @ 30 STRleft dup strlen 30 >
      if 27 strcut pop "^^" "^" subst "^NORMAL^..." strcat
      else "^^" "^" subst then
      strcat "^WHITE^|^VIOLET^" strcat "%a %b %e" PostOn @ timefmt strcat
      "^WHITE^|^VIOLET^" strcat
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-Anonymous strcat
      getpropstr strip dup not if
          pop PostBy @ dup ok? if dup player? else 0 then
          if name else #-30 dbcmp if "Guest" else "Toaded Player" then then
      else
         me @ "Wizard" flag? if
            PostBy @ dup ok?
            if dtos "(" swap strcat ")" strcat strcat else pop then
         then
      then
      dup STRmatch @ smatch not SearchType @ dup 1 = swap 4 = or and if
         pop pop CONTINUE
      then
      Subj @ STRmatch @ smatch not SearchType @ dup 2 = swap 4 = or and if
         pop CONTINUE
      then
      SearchType @ dup 3 = swap 4 = or if
         BBoard STRtemp @ BBM-Msg strcat array_get_proplist STRmatch @
         BB-find_text_array? not if
            pop CONTINUE
         then
      then
      16 STRleft dup strlen 16 > if 13 strcut pop "^^" "^" subst "^NORMAL^..."
      strcat else "^^" "^" subst then strcat "^WHITE^|^VIOLET^" strcat
      Board @ RealIdx @ Board-Timeout dup -1 = not if
         dup 99 > if pop 99 then
         dup not if
            pop "  ^YELLOW^Now  "
         else
            dup 1 > if " days" else " day" then swap intostr swap strcat 7
            STRleft
         then
      else
         pop BBoard BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir
         RealIdx @
         intostr "%n" subst strcat BBM-Protected? strcat getpropstr "yes"
         stringcmp not if
            "^YELLOW^Protect"
         else
            "-------"
         then
      then
      strcat "^WHITE^|" strcat ARRmsg @ array_appenditem ARRmsg !
   REPEAT
   me @ ARRmsg @ 1 do_array_notify
   me @ "^WHITE^------------------------------------------------------------------------------" ansi_notify
;
 
: Board-ReadMsgs[ int:Board arr:Msgs -- ]
   VAR MSGidx VAR MSGreal VAR STRtemp VAR INTtemp { }list VAR! ARRnomsgs VAR subj VAR poston VAR poster 0 VAR! idx
   Board @ not if
      me @ "^CFAIL^BBOARD: Invalid message board." ansi_notify exit
   then
   me @ Board @ BB-ReadPerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ Board @ BB-Subscribed? not if
      "^CFAIL^BBOARD: You are not subscribed to that board." atell exit
   then
   Msgs @
   FOREACH
      swap pop MSGidx !
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-MsgNums strcat MSGidx @
      intostr strcat getprop ToInt MSGreal !
      MSGreal @ if
         BB-GroupNum if
            me @ "^WHITE^" "" "=" 78 STRfillfield strcat ansi_notify
         else
            BBoard BB-BoardDir Board @ intostr "%n" subst BB-Name strcat
            getpropstr 77 over strlen - 2 / "" "=" rot STRfillfield
            "^WHITE^" swap strcat " ^AQUA^" rot strcat " " strcat over strcat
            strcat me @ swap ansi_notify
         then
         "^GREEN^Message^WHITE^: ^RED^" BB-GroupNum not if Board @ intostr "/"
         strcat MSGidx @
         intostr strcat else MsgIdx @ intostr then 26 STRleft "^WHITE^/^RED^"
         "/" subst strcat
         "^GREEN^Posted        Author" strcat "" 23 STRLeft strcat atell
         BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir MSGreal @ intostr
         "%n" subst strcat STRtemp !
         BBoard STRtemp @ BBM-Subject strcat getpropstr subj !
         BBoard STRtemp @ BBM-Date strcat getprop ToInt dup INTtemp ! "%a %b %e"
         swap timefmt poston !
         BBoard STRtemp @ BBM-Poster strcat getprop ToDbref poster ! poster @
         dup ok? if dup player? else 0 then
         not swap #-30 dbcmp not and if
            BBoard STRtemp @ BBM-Poster strcat #-1 setprop
         then
         BBoard BB-BoardDir Board @ intostr "%n" subst BB-Anonymous strcat
         getpropstr strip dup not if
            pop poster @ dup ok? if dup player? else 0 then if name else #-30
            dbcmp if "Guest" else "Toaded Player" then then poster !
         else
            me @ "WIZARD" flag?
            if "(" strcat poster @ dtos strcat ")" strcat then poster !
         then
         "^FOREST^" subj @ 30 STRleft dup strlen
         30 > if 30 strcut pop then
         "^^" "^" subst strcat "   " strcat
         poston @ strcat "      " strcat poster @ 29 STRleft dup strlen
         29 > if 39 strcut pop then "^^" "^" subst strcat me @ swap ansi_notify
         "^WHITE^------------------------------------------------------------------------------"
         atell
         BBoard STRtemp @ BBM-Msg strcat array_get_proplist dup array_count not
         if
            pop me @ "^CFAIL^BBOARD: No message text to display." ansi_notify
         else
            me @ swap 0 do_array_notify
         then
         me @ "^WHITE^==============================================================================" ansi_notify
         me @ owner isGuest? not if
            BBoard STRtemp @ BBM-UserDir strcat me @ int intostr strcat
            me @ owner timestamps pop pop pop setprop
         then
         idx ++
      else
         MSGidx @ intostr ARRnomsgs @ array_appenditem ARRnomsgs !
      then
   REPEAT
   ARRnomsgs @ array_count if
      me @ "^CFAIL^BBOARD: Message(s) %n do not exist." ARRnomsgs @ ARRcommas
      "%n" subst ansi_notify
   then
   idx @ 1 > if
      me @ "^CINFO^Done." ansi_notify
   then
;
lvar NewMessages
: Board-NextMsg[ int:Board int:NumMsgs int:display -- ]
   VAR MSGidx VAR MSGreal VAR INTtemp VAR REFtemp 0 VAR! idx VAR STRtemp
   VAR TheBoard
   NumMsgs @ 1 < if
      1 NumMsgs !
   then
   Board @ 0 > if
      Board @ not if
         me @ "^CFAIL^BBOARD: Invalid message board." ansi_notify exit
      then
      me @ Board @ BB-ReadPerm? not if
         me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
      then
      me @ Board @ BB-Subscribed? not if
         "^CFAIL^BBOARD: You are not subscribed to that board." atell exit
      then
   then
   Board @ TheBoard !
   1 BBoard BB-Count getprop ToInt 1 FOR
      Board !
      TheBoard @ -1 = Board @ TheBoard @ = or not if
         CONTINUE
      then
      TheBoard @ -1 = if
         BBoard BB-BoardDir Board @ intostr "%n" subst BB-Notify strcat
         me @ owner int intostr strcat getprop dup string? if
            dup "yes" stringcmp not over "no" stringcmp not or
         else
            0
         then
         swap ToInt me @ owner timestamps pop pop pop = or if
            CONTINUE
         then
      then
      BB-GroupNum not if BBoard BB-BoardDir Board @ intostr "%n" subst
      BB-Exist? strcat getpropstr "yes" stringcmp not else 1 then if
         me @ Board @ BB-ReadPerm? me @ Board @ BB-Subscribed? and if
            1 BBoard BB-BoardDir Board @ intostr "%n" subst BB-FakeNumMsgs
            strcat getprop ToInt 1
            FOR
               MSGidx !
               BBoard BB-BoardDir Board @ intostr "%n" subst BB-MsgNums strcat
               MSGidx @ intostr strcat getprop ToInt MSGreal !
               BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir
               MSGreal @ intostr "%n" subst strcat STRtemp !
               BBoard STRtemp @ BBM-Date strcat getprop ToInt INTtemp !
               BBoard STRtemp @ BBM-Poster strcat getprop ToDBref REFtemp !
               BBoard STRtemp @ BBM-UserDir strcat "/" strcat me @ owner int
               intostr strcat getprop ToInt
               dup INTtemp @ = swap me @ owner timestamps pop pop pop = or not
               REFtemp @ dup ok? if owner then me @ owner dbcmp not and if
                  display @ not if 1 NewMessages ! break then
                  { MsgIdx @ }list Board @ swap Board-ReadMsgs idx ++ idx @
                  NumMsgs @ >= if 1 TheBoard ! BREAK then
                  "^CYAN^Paused.  ^AQUA^Continue on? ^FOREST^(^GREEN^yes^FOREST^/no)"
                  atell
                  read strip dup "no" stringcmp not if
                     break
                  then
               then
            REPEAT
            TheBoard @ 0 > if
               break
            then
            Display @ not NewMessages @ and if break then ( already found )
         then
      then
   REPEAT
   display @ idx @ not and if (If nothing found on the first run, don't scan )
       "^AQUA^There are no new messages to be read." atell exit
   then
   display @ if ( not the check loop, so do the check loop )
       -1 0 0 board-nextmsg
       newMessages @ if
           "^FOREST^There are more new messages. Use '+bbnext' to continue."
           atell exit
       else
           "^AQUA^There are no more messages to be read." atell exit
       then
   else ( it is the check loop, in which case we want to just exit )
       exit
   then
;
 
: Board-SearchMsgs[ arr:Board str:STRname -- ]
   { }list VAR! ARRnoexist { }list VAR! ARRnoperm { }list VAR! ARRnosub 1 VAR!
   SearchType
   STRname @ strip dup STRname ! "#" instr 1 = if
      STRname @ " " split strip dup not if swap then STRname ! strip
      BEGIN
         dup "#name" stringcmp not if pop
            1
         break then
         dup "#subj" stringcmp not if pop
            2
         break then
         dup "#text" stringcmp not if pop
            3
         break then
         dup "#all" stringcmp not if pop
            4
         break then
         pop 1 BREAK
      REPEAT
      SearchType !
   then
   Board @ dup array_count not if
      pop { }list Board !
      1 BBoard BB-Count getprop ToInt 1
      FOR
         BB-GroupNum not if BBoard BB-BoardDir 3 pick intostr "%n" subst
         BB-Exist? strcat getpropstr "yes" stringcmp not else 1 then if
            Board @ array_appenditem Board !
         else
            pop
         then
      REPEAT
      Board @
   then
   FOREACH
      swap pop
      dup not if
         ARRnoexist @ array_appenditem ARRnoexist ! CONTINUE
      then
      me @ over BB-ReadPerm? not if
         "#" intostr strcat ARRnoperm @ array_appenditem ARRnoperm ! CONTINUE
      then
      me @ over BB-Subscribed? not if
         ARRnosub @ array_appenditem ARRnosub ! CONTINUE
      then
      STRname @ SearchType @ Board-ListMsgs
   REPEAT
   ARRnoexist @ array_count if
      me @ "^CFAIL^BBOARD: Some of those boards do not exist." ansi_notify
   then
   ARRnoperm @ array_count if
      me @ "^CFAIL^BBOARD: %n: %s." ARRnoperm @ ARRcommas "%n" subst
      "noperm_mesg" sysparm "^^" "^" subst "%s" subst ansi_notify
   then
   ARRnosub @ array_count if
      me @ "^CFAIL^BBOARD: You are not subscribed to %n." ARRnosub @ ARRcommas
      "%n" subst ansi_notify
   then
;
 
: Board-Editor[ int:Board int:MsgRealNum int:Message str:Subject arr:Msg int:Protect? int:Urgent? int:Timeout int:NewMsg? --
                int:Board int:MsgRealNum int:Message str:Subject arr:Msg int:Protect? int:Urgent? int:Timeout ]
(*
   Editor Commands:
     .urgent       -- Toggle urgent flag.
     .protect      -- Toggle protection flag.
     .info         -- Show message data.
     .timeout =<#> -- Set timeout to <#> days.
     .subj =<subj> -- Set a new subject.
 *)
   VAR aMask { "lhelp" "protect" "urgent" "info" "timeout" "subj" }list aMask !
   VAR cPos  1 cPos !
   VAR eMsg  0 eMsg !
   VAR cStr  ".i $" cStr !
   VAR aArg  VAR eCmd
   VAR bOwner
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Owner strcat getprop dup ok?
   if owner then ToDbref bOwner !
   me @ "_prefs/lstoggle" getpropstr strip "alt" stringcmp not if
      "^CYAN^<  ^NORMAL^Welcome to the +BBoard Editor!  If you want help then type '^WHITE^..h^NORMAL^'. ^CYAN^>"
      atell
      "^CYAN^<  ^NORMAL^'^WHITE^..end^NORMAL^' will exit and post the msg, '^WHITE^..abort^NORMAL^' will abort any      ^CYAN^>"
      atell
      "^CYAN^<  ^NORMAL^changes.   Remember, ANYTHING to be sent to the editor must have  ^CYAN^>"
      atell
      "^CYAN^<  ^NORMAL^a '^WHITE^.^NORMAL^' mark placed at the start to be recoginized.                 ^CYAN^>"
      atell
   else
      "^CYAN^<  ^NORMAL^Welcome to the +BBoard Editor!  If you want help then type '^WHITE^.h^NORMAL^'.  ^CYAN^>"
      atell
      "^CYAN^<  ^NORMAL^'^WHITE^.end^NORMAL^' will exit and post the msg, '^WHITE^.abort^NORMAL^' will abort any        ^CYAN^>"
      atell
      "^CYAN^<  ^NORMAL^changes.  To perform external commands(Like paging or whatever.), ^CYAN^>"
      atell
      "^CYAN^<  ^NORMAL^place a '^WHITE^|^NORMAL^' mark at the start like '^WHITE^|page blah=hey!^NORMAL^'              ^CYAN^>"
      atell
   then
   BEGIN
      cStr @ me @ "_prefs/lstoggle" getpropstr strip "alt" stringcmp not and if
         "." cStr @ strcat cStr !
      then
      Msg @ aMask @ cPos @ cStr @ eMsg @ ArrayEDITORloop eCmd ! aArg ! cPos ! aMask ! Msg ! "" cStr !
      eCmd @ "lhelp" stringcmp not if
         me @ "^YELLOW^--^CRIMSON^LOCAL HELP^YELLOW^---------------------------------------------------------------" ansi_notify
         me @ " ^WHITE^.protect                  ^NORMAL^Toggle the protection flag [Board owners or wizard only]" ansi_notify
         me @ " ^WHITE^.urgent                   ^NORMAL^Toggle the urgent flag [Board owners or wizard only]" ansi_notify
         me @ " ^WHITE^.info                     ^NORMAL^Show information on this message." ansi_notify
         me @ " ^WHITE^.timeout =<#>             ^NORMAL^Set the timeout to <#> days." ansi_notify
         me @ " ^WHITE^.subj =<subj>             ^NORMAL^Set a new subject." ansi_notify
         me @ "^YELLOW^Done." ansi_notify
      then
      eCmd @ "protect" stringcmp not if
         bOwner @ me @ dbcmp BBoard owner me @ dbcmp or me @ "Wizard" flag?
         or not if
            me @ "^CYAN^< ^CFAIL^BBOARD: Permission denied. ^CYAN^>" ansi_notify
         else
            Protect? @ if
               "^CYAN^< ^CFAIL^Protection flag is now off. ^CYAN^>" atell
                0 Protect? !
            else
               "^CYAN^< ^CSUCC^Protection flag is now on. ^CYAN^>" atell
                1 Protect? !
            then
         then
         CONTINUE
      then
      eCmd @ "urgent" stringcmp not if
         bOwner @ me @ dbcmp BBoard owner me @ dbcmp or me @ "Wizard" flag? or
         not if
            me @ "^CYAN^< ^CFAIL^BBOARD: Permission denied. ^CYAN^>" ansi_notify
         else
            Urgent? @ if
               "^CYAN^< ^CFAIL^Urgent flag is now off. ^CYAN^>" atell 0
               Urgent? !
            else
               me @ "^CYAN^< ^CSUCC^Urgent flag is now on. ^CYAN^>" ansi_notify
               1 Urgent? !
            then
         then
         CONTINUE
      then
      eCmd @ "info" stringcmp not if
         "> ^CINFO^Message Information (#%b/%m):" Board @ intostr "%b" subst Message @ intostr "%m"
         subst atell
         "> ^WHITE^Subject: ^NORMAL^" Subject @ "^^" "^" subst strcat atell
         "> ^WHITE^Timeout: ^NORMAL^" Timeout @ intostr strcat " day(s)" strcat
         atell
         "> ^WHITE^Protect: ^NORMAL^" Protect? @ if "Yes" else "No" then strcat
         atell
         "> ^WHITE^Urgent?: ^NORMAL^" Protect? @ if "Yes" else "No" then strcat
         atell
         me @ "> ^CINFO^Done." ansi_notify
         ".p" cStr ! CONTINUE
      then
      eCmd @ "timeout" stringcmp not if
         aArg @ 2 array_getitem atoi dup Timeout ! if
            me @ "^CYAN^< ^CSUCC^Timeout is set to %d day(s). ^CYAN^>"
            Timeout @ intostr "%d" subst ansi_notify
         else
            me @ "^CYAN^< ^CFAIL^Timeout is cleared. ^CYAN^>" ansi_notify
         then
         CONTINUE
      then
      eCmd @ "subj" stringcmp not if
         aArg @ 2 array_getitem strip dup if dup Subject ! then if
            me @ "^CYAN^< ^CSUCC^New subject is now set. ^CYAN^>" ansi_notify
         else
            "^CYAN^< ^CFAIL^You must have a subject for a message. ^CYAN^>"
            atell
         then
         CONTINUE
      then
      eCmd @ "abort" stringcmp not if
         { }list Msg ! 0 Board ! 0 Message ! "" Subject ! 0 Protect? !
         0 Timeout ! break
      then
      eCmd @ "end" stringcmp not if
         break
      then
   REPEAT
   Board @ MsgRealNum @ Message @ Subject @ Msg @ Protect? @ Urgent? @ Timeout @
;
 
: do_arr_union[ arr:ARRoldarray arr:ARRnewarray -- arr:ARRjoined ]
   ARRnewarray @
   FOREACH
      swap pop
      ARRoldarray @ array_appenditem ARRoldarray !
   REPEAT
   ARRoldarray @
;
 
: Board-PostMsg[ int:Board str:Subject str:Message -- ]
   0 VAR! Protect? 0 VAR! Timeout 0 VAR! Urgent? VAR MsgFakeNum VAR MsgNum
   VAR STRtemp VAR STRtemp2
   force_level if
      me @ "^CFAIL^BBOARD: This function cannot be forced." ansi_notify exit
   then
   Board @ not if
      me @ "^CFAIL^BBOARD: Invalid message board." ansi_notify exit
   then
   me @ Board @ BB-ReadPerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ Board @ BB-WritePerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ Board @ BB-Subscribed? not if
      "^CFAIL^BBOARD: You are not subscribed to that board." atell exit
   then
   me @ isGuest? not BBoard BB-BoardDir Board @ intostr "%n" subst
   BB-GuestPost? strcat getpropstr "yes" stringcmp not or not if
      me @ "^CFAIL^BBOARD: Guests cannot post on that board." ansi_notify exit
   then
   BB-BoardDir Board @ intostr "%n" subst BB-ReaLMsgDir strcat STRtemp !
   0 MsgNum !
   BEGIN
      MsgNum ++ BBoard STRtemp @ MsgNum @ intostr "%n" subst BBM-Exist? strcat
      getpropstr "yes" stringcmp not WHILE
   REPEAT
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-FakeNumMsgs strcat dup
   STRtemp ! getprop ToInt 1 + dup MsgFakeNum !
   Subject @ strip dup Subject ! not if
      me @ "^CYAN^Please enter a subject for this message below:" ansi_notify
      BEGIN
         read strip dup not WHILE pop
         me @ "^CFAIL^Invalid subject.  Try again:" ansi_notify
      REPEAT
      Subject !
   then
   Message @ dup Message ! strip if
      { Message @ }list Message ! 0 Protect? ! 0 Timeout !
   else
      me @ "^GREEN^Entering the post editor: ^FOREST^#%b/" Board @ intostr "%b"
      subst Subject @ 1 escape_ansi strcat ansi_notify
      Board @ MsgNum @ MsgFakeNum @ Subject @ { }list Protect? @ Urgent? @
      Timeout @ 1
      Board-Editor Timeout ! Urgent? ! Protect? ! Message ! Subject !
      MsgFakeNum ! MsgNum ! Board !
   then
   Message @ array_count not if
      me @ "^CFAIL^BBOARD: Message aborted." ansi_notify exit
   then
   me @ BBP-Signature array_get_proplist
   me @ BBP-Signature getpropstr dup strip if
      { swap }list array_union
   else
      pop
   then
   Message @ swap do_arr_union Message !
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-LastPost strcat "%a %b %e"
   systime timefmt setprop
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-NumMsgs strcat over over
   getprop ToInt MsgFakeNum @ < if
      MsgFakeNum @ setprop
   else
      pop pop
   then
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-MsgNums strcat MsgFakeNum @
   intostr strcat MsgNum @ setprop
   BBoard STRtemp @ MsgFakeNum @ setprop
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir MsgNum @ intostr
   "%n" subst strcat dup STRtemp ! dup strlen 1 - strcut pop remove_prop
   BBoard STRtemp @ BBM-Exist? strcat "yes" setprop
   BBoard STRtemp @ BBM-MsgNum strcat MsgFakeNum @ setprop
   me @ owner isGuest? if
      BBoard STRtemp @ BBM-Poster strcat #-30 setprop
   else
      BBoard STRtemp @ BBM-Poster strcat me @ setprop
   then
      BBoard STRtemp @ BBM-Date strcat systime setprop
   BBoard STRtemp @ BBM-Subject strcat Subject @ setprop
   BBoard STRtemp @ BBM-Msg strcat Message @ array_put_proplist
   BBoard STRtemp @ BBM-Timeout strcat Timeout @ setprop
   BBoard STRtemp @ BBM-Protected? strcat Protect? @ if "yes" else "no" then
   setprop
   BBoard STRtemp @ BBM-Urgent? strcat Urgent? @ if "yes" else "no" then setprop
   "^WHITE^(^FOREST^You sense a new message at ^GREEN^%g^WHITE^(^CRIMSON^#%n^WHITE^/^RED^%m^WHITE^) ^FOREST^by ^GREEN^%p^WHITE^: ^AQUA^%s^WHITE^)"
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Name strcat
   getpropstr "%g" subst Board @ intostr "%n" subst
   MsgFakeNum @ intostr "%m" subst
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Anonymous strcat getpropstr
   dup strip not if pop
   me @ dup isGuest? if pop "Guest" else name then then "%p" subst
   Subject @ "%s" subst STRtemp !
   me @ "^CSUCC^BBOARD: Message posted." ansi_notify
   BB-BoardDir Board @ intostr "%n" subst BB-Notify strcat STRtemp2 !
   BBoard BB-Board dbcmp not if
      exit
   then
   online_array
   FOREACH
      swap pop
      dup Board @ BB-Subscribed? over Board @ BB-ReadPerm? and over me @ dbcmp
      not and
      BBoard STRtemp2 @ 4 pick int intostr strcat getprop dup string? swap ToInt
      4 pick timestamps pop pop pop = or not and if
         STRtemp @ ansi_notify
      else
         pop
      then
   REPEAT
;
 
: Board-EditMsg[ int:Board int:Message str:Text1 str:Text2 -- ]
(*
   If both Text1 and Text2 are blank = Edit message in list editor
   If only Text1 is blank            = Change the subject
   If neither are blank              = Replace text throughout the message
 *)
   VAR PathDir VAR MsgNum VAR Msg VAR Subj VAR Protect? VAR Timeout VAR Urgent?
   me @ owner isGuest? if
      me @ "^CFAIL^BBOARD: Guests cannot do that." ansi_notify exit
   then
   force_level if
      me @ "^CFAIL^BBOARD: This function cannot be forced." ansi_notify exit
   then
   Board @ not if
      me @ "^CFAIL^BBOARD: Invalid message board." ansi_notify exit
   then
   me @ Board @ BB-ReadPerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ Board @ BB-WritePerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ Board @ BB-Subscribed? not if
      "^CFAIL^BBOARD: You are not subscribed to that board." atell exit
   then
   BBoard BB-BoardDir Board @ intostr "%n" subst dup PathDir ! BB-MsgNums
   strcat Message @ intostr strcat getprop ToInt MsgNum !
   MsgNum @ not if
      me @ "^CFAIL^BBOARD: Invalid message." ansi_notify exit
   then
   BBoard PathDir @ BB-Owner strcat getprop ToDBref me @ dbcmp
   BBoard PathDir @ BB-RealMsgDir MsgNum @ intostr "%n" subst strcat dup
   PathDir ! BBM-Msg strcat array_get_proplist Msg !
   BBoard PathDir @ BBM-Poster strcat getprop ToDBref dup ok? if owner then
   me @ owner dbcmp or me @ "WIZARD" flag? or me @ BBoard controls or not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   BBoard PathDir @ BBM-Subject strcat getpropstr Subj !
   BBoard PathDir @ BBM-Timeout strcat getprop ToInt Timeout !
   BBoard PathDir @ BBM-Protected? strcat getpropstr "yes" stringcmp not
   Protect? !
   BBoard PathDir @ BBM-Urgent? strcat getpropstr "yes" stringcmp not Urgent? !
   Text2 @ Text1 @ and if
      Msg @ 0 over array_count Text1 @ Text2 @ ARRreplace Msg !
      me @ "^CSUCC^BBOARD: Finished replacing text." ansi_notify
   else
      Text1 @ strip if
         Text1 @ strip Subj !
         me @ "^CSUCC^BBOARD: Finished editing subject." ansi_notify
      else
         Board @ Message @ MsgNum @ Subj @ Msg @ Protect? @ Urgent? @ Timeout @
         0 Board-Editor
         Timeout ! Urgent? ! Protect? ! Msg ! Subj ! Message ! MsgNum ! Board !
         Msg @ array_count not if
            me @ "^CFAIL^BBOARD: Message aborted." ansi_notify exit
         then
         me @ "^CSUCC^BBOARD: Finished editing message." ansi_notify
      then
   then
   BBoard PathDir @ BBM-Subject strcat Subj @ setprop
   BBoard PathDir @ BBM-Timeout strcat Timeout @ setprop
   BBoard PathDir @ BBM-Protected? strcat Protect? @ if "yes" else "no" then
   setprop
   BBoard PathDir @ BBM-Urgent? strcat Urgent? @ if "yes" else "no" then setprop
   BBoard PathDir @ BBM-Msg strcat Msg @ array_put_proplist
;
 
: Board-ProtectMsg[ int:Board arr:Msgs -- ]
   VAR PathDir { }list dup VAR! Protected dup VAR! NoExist VAR! UnProtected
   VAR MsgNum
   me @ owner isGuest? if
      me @ "^CFAIL^BBOARD: Guests cannot do that." ansi_notify exit
   then
   force_level if
      me @ "^CFAIL^BBOARD: This function cannot be forced." ansi_notify exit
   then
   Board @ not if
      me @ "^CFAIL^BBOARD: Invalid message board." ansi_notify exit
   then
   me @ Board @ BB-ReadPerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ Board @ BB-WritePerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ Board @ BB-Subscribed? not if
      "^CFAIL^BBOARD: You are not subscribed to that board." atell exit
   then
   me @ "WIZARD" flag?
   me @ BBoard controls or
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Owner strcat getprop
   ToDBref me @ dbcmp or not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   BB-BoardDir Board @ intostr "%n" subst PathDir ! Msgs @
   FOREACH
      swap pop intostr MsgNum !
      BBoard PathDir @ BB-MsgNums strcat MsgNum @ strcat getprop ToInt dup if
         BBoard PathDir @ BB-RealMsgDir strcat rot intostr "%n" subst
         BBM-Protected? strcat over over getpropstr "yes" stringcmp not if
            "no" setprop MsgNum @ UnProtected @ array_appenditem UnProtected !
         else
            "yes" setprop MsgNum @ Protected @ array_appenditem Protected !
         then
      else
         pop MsgNum @ NoExist @ array_appenditem NoExist !
      then
   REPEAT
   Protected @ array_count if
      me @ "^CSUCC^BBOARD: Message(s) %n on board #%b is/are now protected."
      Protected @ ARRcommas "%n" subst Board @ intostr "%b" subst ansi_notify
   then
   UnProtected @ array_count if
      "^CSUCC^BBOARD: Message(s) %n on board #%b is/are no longer protected."
      UnProtected @ ARRcommas "%n" subst Board @ intostr "%b" subst atell
   then
   NoExist @ array_count if
      me @ "^CFAIL^BBOARD: Message(s) %n on board #%b do(es) not exist."
      NoExist @ ARRcommas "%n" subst Board @ intostr "%b" subst ansi_notify
   then
   NoExist @ array_count Protected @ array_count or UnProtected @ array_count
   or not if
      me @ "^CFAIL^BBOARD: Nothing done." ansi_notify
   then
;
 
: Board-RemoveMsg[ int:Board int:Message -- int:Succ ]
   VAR RealMsgNum VAR STRtemp VAR STRtemp2
   me @ owner isGuest? if
      me @ "^CFAIL^BBOARD: Guests cannot do that." ansi_notify exit
   then
   force_level if
      me @ "^CFAIL^BBOARD: This function cannot be forced." ansi_notify exit
   then
   Board @ not if
      -1 exit
   then
   BB-GroupNum not if BBoard BB-BoardDir Board @ intostr "%n" subst BB-Exist?
   strcat getpropstr "yes" stringcmp else 0 then if
      -1 exit
   then
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-MsgNums strcat Message @
   intostr strcat getprop ToInt dup RealMsgNum ! not if
      -1 exit
   then
   me @ "WIZARD" flag?
   BBoard owner me @ owner dbcmp or
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Owner strcat getprop ToDBref
   dup ok? if owner then me @ owner dbcmp or
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir strcat
   RealMsgNum @ intostr "%n" subst
   BBM-Poster strcat getpropstr ToDBref dup ok? if owner then me @ owner dbcmp
   or not if 0 exit then
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir strcat
   RealMsgNum @ intostr "%n" subst dup strlen 1 - strcut pop remove_prop
   BB-BoardDir Board @ intostr "%n" subst BB-MsgNums strcat STRtemp !
   BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir strcat STRtemp2 !
   BBoard STRtemp @ Message @ intostr strcat getprop ToInt
   BBoard STRtemp2 @ rot intostr "%n" subst BBM-Exist? strcat remove_prop
   BEGIN
      BBoard STRtemp @ Message @ intostr strcat remove_prop Message ++
      BBoard STRtemp @ Message @ intostr strcat getprop ToInt dup WHILE
      BBoard STRtemp @ Message @ 1 - intostr strcat 3 pick setprop
      BBoard STRtemp2 @ rot intostr "%n" subst BBM-MsgNum strcat Message @
      1 - setprop
   REPEAT
   pop 1
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-FakeNumMsgs strcat over over
   getprop ToInt 1 - setprop
;
 
: Board-MoveMsgs[ int:Board arr:Msgs int:NewBoard -- ]
   VAR MsgNum VAR RealMsgNum { }list dup VAR! NoPerm dup VAR! NoExist VAR! Moved VAR MsgProps VAR Msg VAR idx
   VAR BoardPerm VAR NewMsgNum VAR NewRealMsgNum VAR STRtemp VAR DIRuser
   me @ owner isGuest? if
      me @ "^CFAIL^BBOARD: Guests cannot do that." ansi_notify exit
   then
   force_level if
      me @ "^CFAIL^BBOARD: This function cannot be forced." ansi_notify exit
   then
   Board @ not if
      me @ "^CFAIL^BBOARD: Invalid old message board." ansi_notify exit
   then
   me @ Board @ BB-ReadPerm? not if
      me @ "^CFAIL^BBOARD: Permission denied (old)." ansi_notify exit
   then
   me @ Board @ BB-WritePerm? not if
      me @ "^CFAIL^BBOARD: Permission denied (old)." ansi_notify exit
   then
   me @ Board @ BB-Subscribed? not if
      "^CFAIL^BBOARD: You are not subscribed to that board (old)." atell exit
   then
   NewBoard @ not if
      me @ "^CFAIL^BBOARD: Invalid new message board." ansi_notify exit
   then
   me @ NewBoard @ BB-ReadPerm? not if
      me @ "^CFAIL^BBOARD: Permission denied (new)." ansi_notify exit
   then
   me @ NewBoard @ BB-WritePerm? not if
      me @ "^CFAIL^BBOARD: Permission denied (new)." ansi_notify exit
   then
   me @ NewBoard @ BB-Subscribed? not if
      "^CFAIL^BBOARD: You are not subscribed to the new board (new)." atell exit
   then
   me @ "WIZARD" flag?
   BBoard owner me @ owner dbcmp or
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Owner strcat
   getprop ToDBref owner me @ owner dbcmp
   BBoard BB-BoardDir NewBoard @ intostr "%n" subst BB-Owner strcat
   getprop ToDBref owner me @ owner dbcmp and or BoardPerm !
   Msgs @ SORTTYPE_NOCASE_ASCEND \array_sort
   FOREACH
      swap pop MsgNum !
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-MsgNums strcat
      MsgNum @ intostr strcat getprop ToInt dup RealMsgNum ! if
         BBoard BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir
         RealMsgNum @ intostr "%n" subst strcat array_get_propvals MsgProps !
         BBoard BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir
         RealMsgNum @ intostr "%n" subst strcat BBM-UserDir strcat "/" strcat
         array_get_propvals DIRuser !
         BBoard BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir
         RealMsgNum @ intostr "%n" subst strcat BBM-Msg strcat
         array_get_proplist Msg !
         MsgProps @ BBM-Poster array_getitem ToDBref dup ok? if owner then
         me @ owner dbcmp BoardPerm @ or if
            Board @ MsgNum @ Board-RemoveMsg if
               MsgNum @ intostr Moved @ array_appenditem Moved !
               BB-BoardDir NewBoard @ intostr "%n" subst BB-RealMsgDir strcat
               STRtemp ! 0 idx !
               BEGIN
                  idx ++ BB-GroupNum idx @ 1 = and not if BBoard STRtemp @ idx @
                   intostr "%n" subst BB-Exist? strcat getpropstr "yes"
                   stringcmp else 0 then if
                     break
                  then
               REPEAT
               idx @ NewRealMsgNum !
               BBoard BB-BoardDir NewBoard @ intostr "%n" subst BB-NumMsgs
               strcat over over getprop ToInt NewRealMsgNum @ < if
                  NewRealMsgNum @ setprop
               else
                  pop pop
               then
               BBoard BB-BoardDir NewBoard @ intostr "%n" subst BB-FakeNumMsgs
               strcat over over getprop ToInt 1 + dup NewMsgNum ! setprop
               BBoard BB-BoardDir NewBoard @ intostr "%n" subst BB-MsgNums
               strcat NewMsgNum @ intostr strcat NewRealMsgNum @ setprop
               BBoard BB-BoardDir NewBoard @ intostr "%n" subst
               BB-RealMsgDir NewRealMsgNum @ intostr "%n" subst strcat
               MsgProps @ array_put_propvals
               BBoard BB-BoardDir NewBoard @ intostr "%n" subst
               BB-RealMsgDir NewRealMsgNum @ intostr "%n" subst
               strcat BBM-UserDir strcat "/" strcat DIRuser @ array_put_propvals
               BBoard BB-BoardDir NewBoard @ intostr "%n" subst
               BB-RealMsgDir NewRealMsgNum @ intostr "%n" subst strcat BBM-MsgNum strcat NewMsgNum @ setprop
               BBoard BB-BoardDir NewBoard @ intostr "%n" subst
               BB-RealMsgDir NewRealMsgNum @ intostr "%n" subst strcat
               BBM-Msg strcat Msg @ array_put_proplist
            else
               MsgNum @ intostr NoPerm @ array_appenditem NoPerm !
            then
         else
            MsgNum @ intostr NoPerm @ array_appenditem NoPerm !
         then
      else
         MsgNum @ intostr NoExist @ array_appenditem NoExist !
      then
   REPEAT
   Moved @ array_count if
      me @ "^CSUCC^BBOARD: Moving message(s) %d on board %n to board "
      Moved @ ARRcommas "%d" subst
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-Name strcat getpropstr
      Board @ intostr "(#%n)" swap "%n" subst strcat "%n" subst
      BBoard BB-BoardDir NewBoard @ intostr "%n" subst BB-Name strcat getpropstr
      NewBoard @ intostr "(#%n)" swap "%n" subst strcat
      strcat "." strcat ansi_notify
   then
   NoPerm @ array_count if
      me @ "^CSUCC^BBOARD: No permission for message(s) %d on board %n."
      NoPerm @ ARRcommas "%d" subst
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-Name strcat getpropstr
      Board @ intostr "(#%n)" swap "%n" subst strcat "%n" subst ansi_notify
   then
   NoExist @ array_count if
      "^CSUCC^BBOARD: Message(s) %d on board %n do(es) not exist."
      NoExist @ ARRcommas "%d" subst
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-Name strcat
      getpropstr Board @ intostr "(#%n)" swap "%n" subst strcat "%n" subst atell
   then
   NoExist @ array_count NoPerm @ array_count or Moved @ array_count or not if
      me @ "^CFAIL^BBOARD: Nothing done." ansi_notify
   then
;
 
: Board-DeleteMsg[ int:Board arr:Messages -- ]
   { }list dup VAR! Removed dup VAR! NoPerm VAR! NoExist VAR MsgNum
   force_level if
      me @ "^CFAIL^BBOARD: This function cannot be forced." ansi_notify exit
   then
   me @ owner isGuest? if
      me @ "^CFAIL^BBOARD: Guests cannot do that." ansi_notify exit
   then
   Board @ not if
      me @ "^CFAIL^BBOARD: Invalid message board." ansi_notify exit
   then
   me @ Board @ BB-ReadPerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ Board @ BB-WritePerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ Board @ BB-Subscribed? not if
      "^CFAIL^BBOARD: You are not subscribed to that board." atell exit
   then
   Messages @ SORTTYPE_CASE_ASCEND \array_sort
   FOREACH
      swap pop dup intostr MsgNum ! Board @ swap Board-RemoveMsg
      dup 1 = if
         pop MsgNum @ Removed @ array_appenditem Removed ! CONTINUE
      then
      dup 0 = if
         pop MsgNum @ NoPerm @ array_appenditem NoPerm ! CONTINUE
      then
      pop MsgNum @ NoExist @ array_appenditem NoExist !
   REPEAT
   Removed @ array_count if
      me @ "^CSUCC^BBOARD: Removed message(s) %d on board %n." Removed @ ", "
      ARRAY_join "%d" subst
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-Name strcat getpropstr
      Board @ intostr "(#%n)" swap "%n" subst strcat "%n" subst ansi_notify
   then
   NoPerm @ array_count if
      me @ "^CSUCC^BBOARD: No permission for message(s) %d on board %n."
      NoPerm @ ", " ARRAY_join "%d" subst
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-Name strcat
      getpropstr Board @ intostr "(#%n)" swap "%n" subst strcat "%n" subst ansi_notify
   then
   NoExist @ array_count if
      me @ "^CSUCC^BBOARD: Message(s) %d on board %n do(es) not exist."
      NoExist @ ", " ARRAY_join "%d" subst
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-Name strcat getpropstr
      Board @ intostr "(#%n)" swap "%n" subst strcat "%n" subst ansi_notify
   then
   NoExist @ array_count NoPerm @ array_count or Removed @ array_count or
   not if
      me @ "^CFAIL^BBOARD: Nothing done." ansi_notify
   then
;
 
: Board-JoinBoard[ int:Board -- ]
   force_level if
      me @ "^CFAIL^BBOARD: This function cannot be forced." ansi_notify exit
   then
   me @ owner isGuest? if
      me @ "^CFAIL^BBOARD: Guests cannot do that." ansi_notify exit
   then
   Board @ not if
      me @ "^CFAIL^BBOARD: Invalid message board." ansi_notify exit
   then
   me @ owner Board @ BB-ReadPerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ owner Board @ BB-Subscribed? if
      "^CFAIL^BBOARD: You are already subscribed to that board." atell exit
   then
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-UserDir strcat "/"
   strcat me @ owner int intostr strcat me @ owner timestamps pop pop pop
   setprop
   me @ "^CSUCC^BBOARD: Subscribed." ansi_notify
;
 
: Board-LeaveBoard[ int:Board -- ]
   force_level if
      me @ "^CFAIL^BBOARD: This function cannot be forced." ansi_notify exit
   then
   me @ owner isGuest? if
      me @ "^CFAIL^BBOARD: Guests cannot do that." ansi_notify exit
   then
   Board @ not if
      me @ "^CFAIL^BBOARD: Invalid message board." ansi_notify exit
   then
   me @ owner Board @ BB-ReadPerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ owner Board @ BB-Subscribed? not if
      me @ "^CFAIL^BBOARD: You are not subscribed to that board." ansi_notify exit
   then
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-AutoSub? strcat getpropstr
   "yes" stringcmp not if
      me @ "^CFAIL^BBOARD: You cannot unsubscribe from that group." ansi_notify
      exit
   then
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-UserDir strcat "/" strcat
   me @ owner int intostr strcat remove_prop
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-UserDir strcat "/" strcat
   me @ owner dtos strcat remove_prop
   me @ "^CSUCC^BBOARD: Unsubscribed." ansi_notify
;
 
: Board-CreateBoard[ str:STRname -- ]
   0 VAR! idx
   me @ owner isGuest? if
      me @ "^CFAIL^BBOARD: Guests cannot do that." ansi_notify exit
   then
   force_level if
      me @ "^CFAIL^BBOARD: This function cannot be forced." ansi_notify exit
   then
   STRname @ Board-MatchName if
      me @ "^CFAIL^BBOARD: That board name already exists." ansi_notify exit
   then
   BBoard owner me @ dbcmp me @ "WIZARD" flag? or
   BBoard BB-PCreate? getpropstr "yes" stringcmp not or not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   STRname @ dup "/" instr swap ":" instr or if
      me @ "^CFAIL^BBOARD: Illegal board name." ansi_notify exit
   then
   BBoard BB-NamePath STRname @ strcat getprop ToInt
   BB-GroupNum not if BBoard BB-BoardDir rot intostr "%n" subst BB-Exist? strcat
   getpropstr "yes" stringcmp not else 1 then if
      me @ "^CFAIL^BBOARD: That board name is already taken." ansi_notify exit
   else
      BBoard BB-NamePath STRname @ strcat getprop ToInt if
         BBoard BB-NamePath STRname @ strcat over over getprop ToInt rot rot
         remove_prop
         BBoard BB-BoardDir rot intostr "%n" subst dup strlen 1 - strcut pop
         remove_prop
      then
   then
   BEGIN
      idx ++
      BB-GroupNum not if BBoard BB-BoardDir idx @ intostr "%n" subst BB-Exist?
      strcat getpropstr "yes" stringcmp not else 0 then WHILE
   REPEAT
   BBoard BB-BoardDir idx @ intostr "%n" subst BB-Name strcat getpropstr dup if
      BBoard BB-NamePath rot strcat remove_prop
   else
      pop
   then
   BBoard BB-BoardDir idx @ intostr "%n" subst dup strlen 1 - strcut pop
   remove_prop
   BBoard BB-BoardDir idx @ intostr "%n" subst BB-Exist? strcat "yes" setprop
   BBoard BB-BoardDir idx @ intostr "%n" subst BB-LastPost strcat "%a %b %e"
   systime timefmt setprop
   BBoard BB-BoardDir idx @ intostr "%n" subst BB-Owner strcat me @ setprop
   BBoard BB-BoardDir idx @ intostr "%n" subst BB-AutoSub? strcat
   me @ "WIZARD" flag? if "yes" else "no" then setprop
   BBoard BB-BoardDir idx @ intostr "%n" subst BB-Name strcat STRname @ setprop
   BBoard BB-BoardDir idx @ intostr "%n" subst BB-BoardNum strcat idx @ setprop
   BBoard BB-NamePath STRname @ strcat idx @ setprop
   BBoard BB-Count getprop ToInt idx @ < if
      BBoard BB-Count idx @ setprop
   then
   me @ "^CSUCC^BBOARD: %s(#%d) is created." idx @ intostr "%d" subst
   STRname @ "^^" "^" subst "%s" subst ansi_notify
;
 
: Board-ChownBoard[ int:Board ref:Plyr -- ]
   force_level if
      me @ "^CFAIL^BBOARD: This function cannot be forced." ansi_notify exit
   then
   Board @ not if
      me @ "^CFAIL^BBOARD: Invalid message board." ansi_notify exit
   then
   me @ Board @ BB-ReadPerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ Board @ BB-WritePerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ Board @ BB-Subscribed? not if
      "^CFAIL^BBOARD: You are not subscribed to that board." atell exit
   then
   me @ owner isGuest? if
      me @ "^CFAIL^BBOARD: Guests cannot do that." ansi_notify exit
   then
   Plyr @ #-2 dbcmp if
      me @ "^CINFO^BBOARD: I don't know which one you mean!" ansi_notify exit
   then
   Plyr @ ok? not if
      me @ "^CINFO^BBOARD: I can't find that player." ansi_notify exit
   then
   Plyr @ isGuest? if
      "^CINFO^BBOARD: You cannot chown a board to a guest." atell exit
   then
   Plyr @ me @ dbcmp if
      me @ "WIZARD" flag? BBoard owner me @ owner dbcmp or
      prog "D" set
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-ChownOk? strcat getprop
      ToDbref owner me @ owner dbcmp or prog "!D" set if
         BBoard BB-BoardDir Board @ intostr "%n" subst over over BB-ChownOk?
         strcat remove_prop BB-Owner strcat me @ setprop
         me @ "^CSUCC^BBOARD: Board(%d) chowned to you."
         Board @ intostr "%d" subst ansi_notify exit
      else
         me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
      then
   then
   me @ "WIZARD" flag?
   BBoard owner me @ owner dbcmp or
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Owner strcat getprop
   ToDBref owner me @ owner dbcmp or if
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-ChownOk? strcat
      Plyr @ setprop
      me @ "^CSUCC^BBOARD: Board(%d) set chown-ok for %s."
      Board @ intostr "%d" subst Plyr @ name "%s" subst ansi_notify exit
   else
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
;
 
: Board-DeleteBoard[ int:Board -- ]
   BB-GroupNum if
      "^CFAIL^BBOARD: You cannot do that with one-room boards." atell exit
   then
   me @ owner isGuest? if
      me @ "^CFAIL^BBOARD: Guests cannot do that." ansi_notify exit
   then
   force_level if
      me @ "^CFAIL^BBOARD: This function cannot be forced." ansi_notify exit
   then
   Board @ not if
      me @ "^CFAIL^BBOARD: Invalid message board." ansi_notify exit
   then
   me @ Board @ BB-ReadPerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ Board @ BB-WritePerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ "WIZARD" flag?
   BBoard owner me @ owner dbcmp or
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Owner strcat getprop
   ToDBref dup ok? not if pop #0 then owner me @ owner dbcmp or not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Exist? strcat "no" setprop
   "^CSUCC^BBOARD: Board removed.  Type '+bbundelete %d' to undelete it.  However, if someone creates a new board, it may or may not remove any change of undeleting it."
   atell
;
 
: Board-UndeleteBoard[ int:Board -- ]
   me @ owner isGuest? if
      exit
   then
   BB-GroupNum not if BBoard BB-BoardDir Board @ intostr "%n" subst BB-Exist?
   strcat getpropstr "no" stringcmp not else 0 then not if
      "^CFAIL^BBOARD: That board either already exists or can no longer be undeleted."
      atell exit
   then
   me @ "WIZARD" flag?
   BBoard owner me @ owner dbcmp or
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Owner strcat getprop ToDBref
   owner me @ owner dbcmp or not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Exist? strcat "yes" setprop
   "^CSUCC^BBOARD: Board (#%d) undeleted." Board @ intostr "%d" subst atell
;
 
: Board-ClearGroup[ int:Board -- ]
   me @ owner isGuest? if
      me @ "^CFAIL^BBOARD: Guests cannot do that." ansi_notify exit
   then
   force_level if
      me @ "^CFAIL^BBOARD: This function cannot be forced." ansi_notify exit
   then
   Board @ not if
      me @ "^CFAIL^BBOARD: Invalid message board." ansi_notify exit
   then
   me @ Board @ BB-ReadPerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ Board @ BB-WritePerm? not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   me @ Board @ BB-Subscribed? not if
      "^CFAIL^BBOARD: You are not subscribed to that board." atell exit
   then
   me @ "WIZARD" flag?
   BBoard owner me @ owner dbcmp or
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-Owner strcat getprop ToDBref
   owner me @ owner dbcmp or not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-MsgNums strcat
   dup strlen 1 - strcut pop remove_prop
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir "/" rsplit
   pop strcat remove_prop
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-NumMsgs strcat remove_prop
   BBoard BB-BoardDir Board @ intostr "%n" subst BB-FakeNumMsgs strcat
   remove_prop
   me @ "^CSUCC^BBOARD: Cleared all messages for that group." ansi_notify exit
;
 
: Board-SetTimeout[ int:Board arr:Msgs int:Timeout -- ]
(*
   If Board and Msgs is -1  ==  Set global  timeout
   If only Msgs is -1       ==  Set board   timeout
   If neither is -1         ==  Set message timeout
   Note: Msgs == -1 is same as == Empty array
 *)
   VAR BOLperm? VAR STRtemp VAR STRtemp2 VAR STRtemp3 VAR MsgNum VAR RealMsgNum
   { }list dup VAR! NoExist dup VAR! NoPerm dup VAR! BOLset VAR! BOLrem
   me @ owner isGuest? if
      me @ "^CFAIL^BBOARD: Guests cannot do that." ansi_notify exit
   then
   force_level if
      me @ "^CFAIL^BBOARD: This function cannot be forced." ansi_notify exit
   then
   Timeout @ ToInt dup Timeout ! 0 >= not if
      "^CFAIL^BBOARD: Timeout must be greater than or equal to zero days.  Set to zero to remove the timeout."
      atell exit
   then
   Board @ Msgs @ array_count and if (* Message Timeouts *)
      me @ "WIZARD" flag? BBoard owner me @ owner dbcmp or
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-Owner strcat getprop
      ToDbref owner me @ owner dbcmp or BOLperm? !
      BB-BoardDir Board @ intostr "%n" subst dup BB-RealMsgDir strcat
      STRtemp2 ! BB-MsgNums strcat STRtemp ! Msgs @
      FOREACH
         swap pop ToInt MsgNum !
         BBoard STRtemp @ MsgNum @ intostr strcat getprop ToInt dup RealMsgNum !
         if
            BBoard STRtemp2 @ RealMsgNum @ intostr "%n" subst dup STRtemp3 !
            BBM-Poster strcat getprop ToDbref dup ok? if owner then me @ owner
            dbcmp BOLperm? or if
               BBoard STRtemp3 @ BBM-Timeout strcat Timeout @ dup if
                  setprop MsgNum @ intostr BOLset @ array_appenditem BOLset !
               else
                  pop remove_prop MsgNum @ intostr BOLrem @ array_appenditem
                  BOLrem !
               then
            else
               MsgNum @ intostr NoPerm @ array_appenditem NoPerm !
            then
         else
            MsgNum @ intostr NoExist @ array_appenditem NoExist !
         then
      REPEAT
      NoExist @ array_count if
         me @ "^CFAIL^BBOARD: Messages (#%s) do not exist." NoExist @ ", "
         ARRcommas "%s" subst ansi_notify
      then
      NoPerm @ array_count if
         me @ "^CFAIL^BBOARD: Permission denied for messages (#%s)." NoPerm @
         ", " ARRcommas "%s" subst ansi_notify
      then
      BOLset @ array_count if
         me @ "^SUCC^BBOARD: Messages (#%s) set with their timeouts." BOLset @
         ", " ARRcommas "%s" subst ansi_notify
      then
      BOLrem @ array_count if
         me @ "^SUCC^BBOARD: Messages (#%s)'s timeouts are now cleared."
         BOLrem @ ", " ARRcommas "%s" subst ansi_notify
      then
      NoExist @ array_count NoPerm @ array_count or BOLset @ array_count or
      BOLrem @ array_count or not if
         me @ "^CFAIL^BBOARD: Nothing done." ansi_notify
      then
   else
      Board @ if (* Board timeout *)
         me @ "WIZARD" flag? BBoard owner me @ owner dbcmp or
         BBoard BB-BoardDir Board @ intostr "%n" subst BB-Owner strcat getprop
         ToDbref owner me @ owner dbcmp or not if
            me @ "^CFAIL^BBOARD: Permission denied." ansi_notify
         then
         BBoard BB-BoardDir Board @ intostr "%n" subst BB-Timeout strcat
         Timeout @ dup if
            setprop "^CSUCC^BBOARD: Board's timeout is now set." atell
         else
            pop remove_prop "^CSUCC^BBOARD: Board's timeout is now cleared."
            atell
         then
      else
         Msgs @ array_count if (* Invalid reference *)
            me @ "^CFAIL^BBOARD: Invalid message board." ansi_notify
         else (* Global timeout *)
            me @ "WIZARD" flag? BBoard owner me @ owner dbcmp or not if
               me @ "^CFAIL^BBOARD: Permission denied." ansi_notify
            then
            BBoard BB-DefTimeout Timeout @ dup if
               setprop "^CSUCC^BBOARD: Global timeout is now set." atell
            else
               pop remove_prop "^CSUCC^BBOARD: Global timeout is now cleared."
               atell
            then
         then
      then
   then
;
 
: Board-AutoTimeout ( -- )
   VAR idx VAR STRtemp VAR Board VAR sme
   me @ sme ! #1 me !
   1 BBoard BB-Count getprop ToInt 1 FOR
      ToInt Board !
      BB-GroupNum not if BBoard BB-BoardDir Board @ intostr "%n" subst
      BB-Exist? strcat getpropstr "yes" stringcmp not else 1 then if
         BB-BoardDir Board @ intostr "%n" subst BB-MsgNums strcat STRtemp !
         0 idx !
         BEGIN
            idx ++ BBoard STRtemp @ idx @ intostr strcat getprop ToInt dup if
               Board @ swap Board-TimeOut 0 = if
                  Board @ idx @ Board-RemoveMsg pop
               then
            else
               pop break
            then
         REPEAT
      then
   REPEAT
   sme @ me !
;
 
: Board-Scan ( -- )
   { }list VAR! ARRmsg
   VAR Board VAR STRtemp VAR STRname 0 VAR! idx
   1 BBoard BB-Count getpropval 1 FOR
      Board !
     BB-GroupNum not if BBoard BB-BoardDir Board @ intostr "%n" subst
     BB-Exist? strcat getpropstr "yes" stringcmp not else 1 then if
         me @ Board @ BB-ReadPerm? me @ Board @ BB-Subscribed? and if
            BBoard BB-BoardDir Board @ intostr "%n" subst BB-Name strcat
            getpropstr STRname !
            me @ owner isGuest? if
               BBoard BB-BoardDir Board @ intostr "%n" subst BB-GuestRead?
               strcat getpropstr "yes" stringcmp not not if
                  CONTINUE
               then
            then
            me @ owner Board @ BB-UnreadMsgs dup array_count if
               "" STRtemp !
               FOREACH
                  swap pop ToInt
                  BBoard BB-BoardDir Board @ intostr "%n" subst BB-NoCatchUp?
                  strcat getpropstr "yes" stringcmp not not if
                     BBoard BB-BoardDir Board @ intostr "%n" subst BB-MsgNums
                     strcat 3 pick intostr strcat getprop ToInt
                     BBoard BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir
                     strcat rot intostr "%n" subst BBM-Urgent? strcat
                     getpropstr "yes" stringcmp not not if
                        BBoard BB-BoardDir Board @ intostr "%n" subst BB-Notify
                        strcat me @ owner int intostr strcat getprop dup string?
                        if
                           dup "yes" stringcmp not over "no" stringcmp not or
                        else
                           0
                        then
                        swap ToInt me @ owner timestamps pop pop pop = or if
                           pop CONTINUE
                        then
                     then
                  then
                  STRtemp @ dup if ", " strcat then swap intostr strcat
                  STRtemp !
               REPEAT
               STRtemp @ not if
                  CONTINUE
               then
               0 idx @ = if
                  BB-GroupNum if
                     "^WHITE^------------------ ^AQUA^Unread Postings on  Local Bulletin Board ^WHITE^------------------"
                  else
                     "^WHITE^------------------ ^AQUA^Unread Postings on Global Bulletin Board ^WHITE^------------------"
                  then
                  ARRmsg @ array_appenditem ARRmsg !
               then
               STRtemp @ STRname @ Board @ intostr
               "^WHITE^[^GREEN^#%-3s^WHITE^] ^FOREST^%-40s ^WHITE^(%s)"
               fmtstring
               ARRmsg @ array_appenditem ARRmsg ! 1 idx !
            else
               pop
            then
         then
      then
   REPEAT
   idx @ 1 = if
      "^WHITE^- ^FOREST^Type ^WHITE^'^CYAN^+bbhelp^WHITE^' ^FOREST^for help with the bulletin board program ^WHITE^--------------------"
   else
      "^CINFO^There are no unread postings on the boards."
   then
   ARRmsg @ array_appenditem { me @ }list array_ansi_notify
;
 
: Board-ToggleNotify[ arr:Boards str:Option -- ]
(*
   No Boards == All boards
 *)
   VAR Board { }list dup VAR! NoExist dup VAR! NoPerm dup VAR! BOLnot
   VAR! BOLnotify
   me @ owner isGuest? if
      me @ "^CFAIL^BBOARD: Guests cannot do that." ansi_notify exit
   then
   force_level if
      me @ "^CFAIL^BBOARD: This function cannot be forced." ansi_notify exit
   then
   Boards @ array_count not if
      "^CFAIL^BBOARD: You need to enter some boards to toggle!" atell exit
   then
   BBoard BB-NamePath array_get_propvals
   FOREACH
      swap pop ToInt Board !
      Boards @ Board @ intostr array_findval array_count Boards @ Board @
      array_findval array_count or not if
         CONTINUE
      then
      BB-GroupNum not if BBoard BB-BoardDir Board @ intostr "%n" subst
      BB-Exist? strcat getpropstr "yes" stringcmp not else 1 then if
         me @ Board @ BB-ReadPerm? me @ Board @ BB-Subscribed? and
         BBoard BB-BoardDir Board @ intostr "%n" subst BB-NoCatchUp? strcat
         getpropstr "yes" stringcmp not not and if
            Option @ strip not if
               BBoard BB-BoardDir Board @ intostr "%n" subst BB-Notify strcat
               "/" strcat me @ owner int intostr strcat over over getprop dup
               string?
               swap ToInt me @ owner timestamps pop pop pop = or if
                  remove_prop Board @ intostr BOLnotify @ array_appenditem
                  BOLnotify !
               else
                  me @ owner timestamps pop pop pop setprop Board @ intostr
                  BOLnot @ array_appenditem BOLnot !
               then
            else
               BBoard BB-BoardDir Board @ intostr "%n" subst BB-Notify strcat
               "/" strcat me @ owner int intostr strcat
               Option @ strip "off" stringcmp not if
                  me @ owner timestamps pop pop pop setprop Board @ intostr
                  BOLnot @ array_appenditem BOLnot !
               else
                  remove_prop Board @ intostr BOLnotify @ array_appenditem
                  BOLnotify !
               then
            then
         else
            Board @ intostr NoPerm @ array_appenditem NoPerm !
         then
      else
         Board @ intostr NoExist @ array_appenditem NoExist !
      then
   REPEAT
   NoExist @ array_count if
      me @ "^CFAIL^BBOARD: Boards (#%s) do not exist." NoExist @ ", " ARRcommas
      "%s" subst ansi_notify
   then
   NoPerm @ array_count if
      me @ "^CFAIL^BBOARD: Permission denied for boards (#%s)." NoPerm @ ", "
      ARRcommas "%s" subst ansi_notify
   then
   BOLnot @ array_count if
      "^SUCC^BBOARD: Boards (#%s) will no longer notify you of unread postings."
      BOLnot @ ", " ARRcommas "%s" subst atell
   then
   BOLnotify @ array_count if
      "^SUCC^BBOARD: Boards (#%s) will now notify you of unread postings."
      BOLnotify @ ", " ARRcommas "%s" subst atell
   then
   NoExist @ array_count NoPerm @ array_count or BOLnot @ array_count or
   BOLnotify @ array_count or not if
      me @ "^CFAIL^BBOARD: Nothing done." ansi_notify
   then
;
 
: Board-CatchUp[ arr:Boards -- ]
   VAR Board { }list dup VAR! NoExist dup VAR! NoPerm VAR! BOLcatchup
   VAR STRtemp VAR STRtemp2 VAR idx
   me @ owner isGuest? if
      me @ "^CFAIL^BBOARD: Guests cannot do that." ansi_notify exit
   then
   force_level if
      me @ "^CFAIL^BBOARD: This function cannot be forced." ansi_notify exit
   then
   BBoard BB-NamePath array_get_propvals
   FOREACH
      swap pop ToInt Board !
      Boards @ Board @ intostr array_findval array_count Boards @ Board @
      array_findval array_count or
      Boards @ array_count not or not if
         CONTINUE
      then
      BB-GroupNum not if BBoard BB-BoardDir Board @ intostr "%n" subst BB-Exist?
      strcat getpropstr "yes" stringcmp not else 1 then if
         me @ Board @ BB-ReadPerm? me @ Board @ BB-Subscribed? and
         BBoard BB-BoardDir Board @ intostr "%n" subst BB-NoCatchUp? strcat
         getpropstr "yes" stringcmp not not and if
            Board @ intostr BOLcatchup @ array_appenditem BOLcatchup !
            me @ Board @ BB-UnreadMsgs dup array_count not if
               pop CONTINUE
            then
            BB-BoardDir Board @ intostr "%n" subst BB-MsgNums strcat STRtemp !
            BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir strcat
            STRtemp2 !
            FOREACH
               swap pop idx !
               BBoard STRtemp @ idx @ intostr strcat getprop ToInt
               BBoard STRtemp2 @ 3 pick intostr "%n" subst BBM-Urgent? strcat
               getpropstr "yes" stringcmp not if
                  pop CONTINUE
               then
               BBoard STRtemp2 @ rot intostr "%n" subst BBM-UserDir strcat "/"
               strcat me @ int intostr strcat
               me @ owner timestamps pop pop pop setprop
            REPEAT
         else
            Boards @ array_count if
               Board @ intostr NoPerm @ array_appenditem NoPerm !
            then
         then
      else
         Boards @ array_count if
            Board @ intostr NoExist @ array_appenditem NoExist !
         then
      then
   REPEAT
   NoExist @ array_count if
      me @ "^CFAIL^BBOARD: Boards (#%s) do not exist." NoExist @ ", "
      ARRcommas "%s" subst ansi_notify
   then
   NoPerm @ array_count if
      me @ "^CFAIL^BBOARD: Permission denied for boards (#%s)." NoPerm @ ", "
      ARRcommas "%s" subst ansi_notify
   then
   BOLcatchup @ array_count if
      me @ "^SUCC^BBOARD: Boards (#%s) now have their message(s) marked read."
      BOLcatchup @ ", " ARRcommas "%s" subst ansi_notify
   then
   NoExist @ array_count NoPerm @ array_count or BOLcatchup @ array_count
   or not if
      "^CFAIL^BBOARD: No board #'s entered. Use 'all' to catchup every board."
      atell
   then
;
 
: STR2HTML[ str:STRtext -- str:STRhtml ]
   STRtext @
   "&amp;" "&"  subst "&quot;" "\"" subst
   "&lt;"  "<"  subst "&gt;"   ">"  subst
   "<BR>"  "\r" subst "&#32;"  " "  subst
;
 
: Web-BoardList[ int:INTdescr -- ]
   VAR Board
   INTdescr @
   "<center><table border=\"1\" cellpadding=\"1\" cellspacing=\"1\" width=\"100%\">"
   notify_descriptor
   INTdescr @
   "<tr><td><font color=#00AA00>#</font></td><td><font color=#00AA00>Group Name</font></td><td align=center><font color=#00AA00>Last Post</font></td><td align=center><font color=#00AA00># of messages</font></td></tr>"
   notify_descriptor
   1 BB-Board BB-Count getprop ToInt 1 FOR
      Board !
      BB-GroupNum not if BB-Board BB-BoardDir Board @ intostr "%n" subst
      BB-Exist? strcat getpropstr "yes" stringcmp not else 1 then if
         BB-Board BB-BoardDir Board @ intostr "%n" subst BB-WWWRead strcat
         getpropstr "yes" stringcmp not if
            "<tr><td><a href=\"%s?" BBW-BBoardLoc "%s" subst Board @ intostr
            strcat "\"><font color=#FFFF11>" strcat Board @ intostr strcat
            "</a></font></td><td>" strcat "<a href=\"/BBoard?" strcat
            Board @ intostr strcat "\"><font color=#FF22FF>" strcat
            BB-Board BB-BoardDir Board @ intostr "%n" subst BB-Name strcat
            getpropstr STR2HTML strcat
            "</font></a></td><td align=center><font color=#AA22AA>" strcat
            BB-Board BB-BoardDir Board @ intostr "%n" subst BB-LastPost strcat
            getpropstr strcat
            "</font></td><td align=center><font color=#AA22AA>" strcat
            BB-Board BB-BoardDir Board @ intostr "%n" subst BB-FakeNumMsgs
            strcat getprop ToInt intostr strcat "</font></td></tr>" strcat
            INTdescr @ swap notify_descriptor
         then
      then
   REPEAT
   INTdescr @ "</table></center>" notify_descriptor
   INTdescr @ "<br><center><a href=\""
   #0 "/_/www/main" getpropstr dup not IF
      pop "/"
   THEN
   strcat "\">Go back to the main page.</a></center>" strcat
   notify_descriptor
;
 
: Web-ListMsgs[ int:INTdescr int:Board -- ]
   VAR MsgIdx VAR RealMsgIdx VAR STRtemp
   INTdescr @ "<center><font color=#00AAFF>*** </font><font color=#00AAAA>"
   BB-Board BB-BoardDir Board @ intostr "%n" subst BB-Name strcat getpropstr
   STR2HTML strcat " </font><font color=#00AAFF>***</font></center>" strcat
   notify_descriptor
   BB-Board BB-BoardDir Board @ intostr "%n" subst BB-WWWRead strcat
   getpropstr "yes" stringcmp not not if
      INTdescr @ "<center><font color=red>ACCESS DENIED</font></center>"
      notify_descriptor exit
   then
   INTdescr @
   "<center><table border=\"1\" cellpadding=\"1\" cellspacing=\"1\" width=\"100%\">"
   notify_descriptor
   INTdescr @
   "<tr><td width=\"5%\"><font color=#00AA00>#/#</font></td><td width=\"45%\"><font color=#00AA00>Message</font></td><td align=center width=\"10%\"><font color=#00AA00><TT>Posted</TT></font></td><td width=\"30%\"><font color=#00AA00>By</font></td><td align=center width=\"10%\"><font color=#00AA00><TT>Timeout</TT></font></td></tr>"
   notify_descriptor
   BB-Board BB-BoardDir Board @ intostr "%n" subst BB-FakeNumMsgs strcat getprop
   ToInt dup not if
      pop INTdescr @ "<center><font color=red>NO MESSAGES</font></center>"
      notify_descriptor exit
   then
   BB-Board BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir strcat
   STRtemp !
   BB-Board BB-BoardDir Board @ intostr "%n" subst BB-FakeNumMsgs strcat
   getprop ToInt
   1 swap 1 FOR
      MsgIdx !
      BB-Board BB-BoardDir Board @ intostr "%n" subst BB-MsgNums strcat
      MsgIdx @ intostr strcat getprop ToInt RealMsgIdx !
      Board @ intostr "/" strcat MsgIdx @ intostr strcat
      "<tr><td><a href=\"%s?" BBW-BBoardLoc "%s" subst over strcat
      "\"><font color=#FF0000>" strcat over strcat
      "</font></a></td><td><a href=\"%s?" BBW-BBoardLoc "%s"
      subst strcat over strcat "\"><font color=#FF22FF>"
      strcat
      BB-Board STRtemp @ RealMsgIdx @ intostr "%n" subst BBM-Subject strcat
      getpropstr STR2HTML strcat
      "</font></a></td><td align=center><TT><font color=#AA22AA>" strcat
      BB-Board STRtemp @ RealMsgIdx @ intostr "%n" subst BBM-Date strcat getprop
      ToInt "%a %b %e" swap timefmt strcat
      "</font></TT></td><td><font color=#AA22AA>" strcat
      BB-Board BB-BoardDir Board @ intostr "%n" subst BB-Anonymous strcat
      getpropstr strip dup not if
         pop BB-Board STRtemp @ RealMsgIdx @ intostr "%n" subst BBM-Poster
         strcat getprop ToDBref dup ok? if dup player? else 0 then if
            "<a href=\"%s?name=" BBW-LookUpLoc "%s" subst over name strcat
            "\"><font color=#AA22AA>" strcat swap name STR2HTML strcat
            "</font></a>" strcat
         else
            #-30 dbcmp if
               "Guest"
            else
                BB-Board STRtemp @ RealMsgIdx @ intostr "%n" subst BBM-Poster
                strcat #-1 setprop
               "(Toaded Player)"
            then
         then
      then
      strcat "</font></td><td align=center><TT><font color=#AA22AA>" strcat
      BB-Board STRtemp @ RealMsgIdx @ intostr "%n" subst BBM-Protected? strcat
      getpropstr "yes" stringcmp not if
         "<font color=#FFFF11>Protect</font>"
      else
         Board @ RealMsgIdx @ Board-TimeOut dup 0 = if
            pop "Now"
         else
            dup -1 = if
               pop "-------"
            else
               dup 99 > if pop 99 then
               dup intostr swap 1 = if " day" else " days" then strcat
            then
         then
      then
      strcat "</font></TT></td></tr>" strcat
      INTdescr @ swap notify_descriptor
   REPEAT
   INTdescr @ "</table></center><br><center><a href=\"%s" BBW-BBoardLoc "%s"
   subst "\">Go back to group listing.</a></center>" strcat notify_descriptor
   INTdescr @ "<br><center><a href=\""
   #0 "/_/www/main" getpropstr dup not IF
      pop "/"
   THEN
   strcat "\">Go back to the main page.</a></center>" strcat
   notify_descriptor
;
 
: Web-ReadMsgs[ int:INTdescr int:Board arr:ARRmsgs -- ]
   VAR MsgIdx VAR RealMsgIdx 0 VAR! Idx { }list VAR! NoExist VAR STRtemp
   BB-GroupNum not if BB-Board BB-BoardDir Board @ intostr "%n" subst BB-Exist?
   strcat getpropstr "yes" stringcmp not not else 0 then if
      INTdescr @
      "<font color=red><center>THAT BOARD DOES NOT EXIST</center></font>"
      notify_descriptor
   then
   BB-Board BB-BoardDir Board @ intostr "%n" subst BB-WWWRead strcat
   getpropstr "yes" stringcmp not not if
      INTdescr @ "<font color=red><center>ACCESS DENIED</center></font>"
      notify_descriptor
   then
   ARRmsgs @ array_count if ARRmsgs @ 0 array_getitem not else 1 then if
      INTdescr @ "<font color=red><center>NO MESSAGES TO LIST</center></font>"
      notify_descriptor
   then
   INTdescr @ "<center><font color=#00AAFF>*** </font><font color=#00AAAA>"
   BB-Board BB-BoardDir Board @ intostr "%n" subst BB-Name strcat
   getpropstr STR2HTML strcat
   " </font><font color=#00AAFF>***</font></center>" strcat notify_descriptor
   ARRmsgs @
   FOREACH
      swap pop atoi MsgIdx !
      BB-Board BB-BoardDir Board @ intostr "%n" subst BB-MsgNums strcat
      MsgIdx @ intostr strcat getprop ToInt dup RealMsgIdx ! not if
         CONTINUE
      then
      Idx @ 0 = if
         idx ++
      else
         "<hr>"
      then
      INTdescr @
      "<center><table border=\"1\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">"
      notify_descriptor
      "<tr><td align=left><font color=#00FF00>Message: </font><font color=#FF0000>"
      Board @ intostr strcat "/" strcat MsgIdx @ intostr strcat
      "</font></td><td align=center><font color=#00FF00>Posted</font></td><td><font color=#00FF00>Author</font></td></tr>"
      strcat INTdescr @ swap notify_descriptor
      "<tr><td><font color=#00AA00>" BB-Board BB-BoardDir Board @ intostr "%n"
      subst BB-RealMsgDir strcat RealMsgIdx @ intostr "%n" subst dup STRtemp !
      BBM-Subject strcat getpropstr STR2HTML strcat
      "</font></td><td align=center><font color=#00AA00><TT>" strcat
      BB-Board STRtemp @ BBM-Date strcat getprop ToInt "%a %b %e" swap timefmt
      strcat "</TT></font></td><td><font color=#00AA00>" strcat
      BB-Board BB-BoardDir Board @ intostr "%n" subst BB-Anonymous strcat
      getpropstr strip dup not if
         pop BB-Board STRtemp @ BBM-Poster strcat getprop ToDBref dup ok?
         if dup player? else 0 then if
            "<a href=\"%s?name=" BBW-LookUpLoc "%s" subst over name strcat
            "\"><font color=#00AA00>" strcat swap name STR2HTML strcat
            "</font></a>" strcat
         else
            #-30 dbcmp if
               "Guest"
            else
               BB-Board STRtemp @ BBM-Poster strcat #-1 setprop
               "(Toaded Player)"
            then
         then
      then
      strcat "</font></td></tr></table></center>" strcat INTdescr @ swap
      notify_descriptor
      INTdescr @
      "<center><table border=\"1\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\"><tr><td><font color=#BBBBBB>"
      notify_descriptor
      BB-Board STRtemp @ BBM-Msg strcat array_get_proplist dup array_count if
         FOREACH
            swap pop INTdescr @ swap STR2HTML "<BR>" strcat notify_descriptor
         REPEAT
      else
         pop INTdescr @
         "<font color=red><center>NO MESSAGE TEXT</center></font>"
         notify_descriptor
      then
      INTdescr @ "</font></td></tr></table></center>" notify_descriptor
   REPEAT
   INTdescr @ "<br><center><a href=\"%s?" BBW-BBoardLoc "%s" subst Board @
   intostr strcat "\">Go back to the message listing.</a></center>" strcat
   notify_descriptor
   INTdescr @ "<br><center><a href=\""
   #0 "/_/www/main" getpropstr dup not IF
      pop "/"
   THEN
   strcat "\">Go back to the main page.</a></center>" strcat
   notify_descriptor
;
 
: Board-Web ( str:Args -- )
   VAR INTdescr VAR STRhost VAR STRuser VAR STRparams
   BB-Board BB-Var !
   "|" explode pop atoi INTdescr ! STRhost ! STRuser ! " " "%20" subst
   STRparams !
   INTdescr @ BBW-BODY notify_descriptor
   INTdescr @ "<TITLE>%s's Bulletin Boards</TITLE>" "muckname" sysparm
   STR2HTML "%s" subst notify_descriptor
   STRparams @ not if
      INTdescr @ Web-BoardList
   else
      STRparams @ "/" split strip swap strip "group=" split dup if swap then
      pop ( INTdescr @ over notify_descriptor ) atoi swap dup if
         " " explode_array INTdescr @ rot rot Web-ReadMsgs
      else
         pop INTdescr @ swap ( over over instostr notify_descriptor )
         Web-ListMsgs
      then
   then
;
 
: Board-Convert ( -- )
   VAR Board VAR MsgIdx VAR RealMsgIdx VAR INTtemp VAR TempDB
   me @ "WIZARD" flag? BBoard @ location #0 dbcmp and BBoard
   owner "TRUEWIZARD" flag? and trig owner "WIZARD" flag? and not if
      me @ "^CFAIL^Permission denied." ansi_notify exit
   then
   me @ "^CNOTE^WARNING: ONLY RUN THIS COMMAND *ONCE*!" ansi_notify
   "^CNOTE^Are you sure you wish to run it? (Type 'yes' and hit enter if you are sure)"
   atell
   read "yes" stringcmp if
      pop me @ "^CINFO^Quitting." ansi_notify exit
   then
   me @ "^GREEN^Updating board properties..." ansi_notify
   prog "_Boards" getprop ToInt BBoard BB-Count rot setprop
   me @ " ^FOREST^- Board count..^CNOTE^Ok!" ansi_notify
   "_Boards/Names/" begin
      prog swap nextprop dup while
      prog over propdir? not if
         prog over getprop  over 14 strcut swap pop
         BBoard BB-NamePath rot strcat rot setprop
      then
   repeat pop
   me @ " ^FOREST^- Board names..^CNOTE^Ok!" ansi_notify
   me @ "^GREEN^Updating boards... ^CINFO^(This might take awhile)" ansi_notify
   1 BBoard BB-Count getprop ToInt FOR
      Board !
      me @ " ^FOREST^- Updating props for board #" Board @ intostr strcat
      ansi_notify
      prog "_Boards/Num/%n/" array_get_propvals
      BBoard BB-BoardDir Board @ intostr "%n" subst rot array_put_propvals
            me @ "   ^GREEN^* Finished copying properties for board #"
            Board @ intostr strcat ansi_notify
      " ^FOREST^- Updating propdirs for board #" Board @ intostr strcat atell
      prog "_Boards/Num/%n/Mesgs/" Board @ intostr "%n" subst array_get_propvals
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-MsgNums strcat rot
      array_put_propvals
      me @ "   ^FOREST^* Fake message number propdir...^CNOTE^Ok!" ansi_notify
      prog "_Boards/Num/%n/Allow/" Board @ intostr "%n" subst array_get_propvals
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-Allow strcat "/" strcat
      rot array_put_propvals
      me @ "   ^FOREST^* Allowed players propdir...^CNOTE^Ok!" ansi_notify
      prog "_Boards/Num/%n/AllowPost/" Board @ intostr "%n" subst
      array_get_propvals
      BBoard BB-BoardDir Board @ intostr "%n" subst BB-AllowPost strcat "/"
      strcat rot array_put_propvals
      me @ "   ^FOREST^* Allowed posters propdir...^CNOTE^Ok!" ansi_notify
      me @ " ^GREEN^- Copying messages for board #" Board @ intostr strcat
      ansi_notify
      1 BBoard BB-BoardDir Board @ intostr "%n" subst BB-NumMsgs strcat getprop
      ToInt 1 FOR
         RealMsgIdx !
         prog "_Boards/Num/%n/Msgs/%m/" Board @ intostr "%n" subst RealMsgIdx @
         intostr "%m" subst array_get_propvals
         BBoard BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir strcat
         RealMsgIdx @ intostr "%n" subst rot array_put_propvals
         prog "_Boards/Num/%n/Msgs/%m/Msg" Board @ intostr "%n" subst
         RealMsgIdx @ intostr "%m" subst array_get_proplist
         BBoard BB-BoardDir Board @ intostr "%n" subst BB-RealMsgDir strcat
         RealMsgIdx @ intostr "%n" subst BBM-Msg strcat rot array_put_proplist
         me @ "     ^FOREST^% Copied message (real)#" RealMsgIdx @ intostr
         strcat ansi_notify
      REPEAT
      me @ "   ^GREEN^* Finished copying messages from board #" Board @ intostr
      strcat ansi_notify
   REPEAT
   me @ "^GREEN^Boards copied...^CNOTE^Ok!" ansi_notify
   me @ "^GREEN^Moving user based props over to bboard props... ^CINFO^(This might take awhile)" ansi_notify
   #0
   BEGIN
      nextplayer dup tempdb ! ok? if
         dup player? if
            "@BoardSub/" BEGIN
               tempdb @ swap nextprop dup while
               dup dup "/" instr strcut swap pop Board !
               tempdb @ over getpropstr "yes" stringcmp not BB-GroupNum not
               if BBoard BB-BoardDir Board @ intostr "%n" subst BB-Exist?
               strcat getpropstr "yes" stringcmp not else 1 then and if
                  BBoard BB-BoardDir Board @ intostr "%n" subst BB-UserDir
                  strcat over over over over getprop ToInt 1 + ToStr setprop
                  "/" strcat tempdb @ int intostr strcat tempdb @ timestamps
                  pop pop pop setprop
               then
               tempdb @ over "/Tell" strcat getpropstr "no" stringcmp not if
                  BBoard BB-BoardDir Board @ intostr "%n" subst BB-Notify
                  strcat tempdb @ int intostr strcat
                  tempdb @ timestamps pop pop pop setprop
               then
            REPEAT pop
            tempdb @ "@BoardSub" remove_prop
            "@Boards/" BEGIN
               tempdb @ swap nextprop dup while
               tempdb @ over propdir? if
                  dup dup "/" instr strcut swap pop Board !
                  dup "/" strcat BEGIN
                     tempdb @ swap nextprop dup WHILE
                     dup dup "/" rinstr strcut swap pop RealMsgIdx !
                     BBoard BB-BoardDir Board @ intostr "%n" subst
                     BB-RealMsgDir strcat RealMsgIdx @ "%n" subst BBM-Exist? strcat getpropstr "yes" stringcmp not
                     tempdb @ 3 pick getpropstr "yes" stringcmp not and if
                        BBoard BB-BoardDir Board @ intostr "%n" subst
                        BB-RealMsgDir strcat RealMsgIdx @ "%n" subst
                        BBM-UserDir strcat tempdb @ int intostr strcat
                        tempdb @ timestamps pop pop pop setprop
                     then
                  REPEAT pop
               then
            REPEAT pop
            tempdb @ "@Boards" remove_prop
         then
      then
   dup ok? not UNTIL pop
   me @ "^CINFO^Done." ansi_notify
;
 
: Board-Install[ ref:REFtrig -- ]
   me @ owner me !
   REFtrig @ ok? not if
      REFtrig @ #-2 dbcmp if
         me @ "^CFAIL^BBOARD: I don't know which one you mean!" ansi_notify
      else
         me @ "^CFAIL^BBOARD: I can't find that here." ansi_notify
      then
      exit
   then
   me @ REFtrig @ controls not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify
   then
   REFtrig @ exit? not if
      "^CFAIL^BBOARD: The object must be an exit for this to install properly."
      atell
   then
   me @ "^CSUCC^Installation finished." ansi_notify
   BB-GroupNum not if
      "+bbread;+bbcatchup;+bbscan;+bbnext;+bbnotify;+bbpost;+bbwrite;+bbeditgroup;+bbconfig;+bbedit;+bbsearch;+bbdelete;+bbremove;+bbcleargroup;+bbtimeout;+bbprotect;+bbchown;+bblist;+bbjoin;+bbleave;+bbnewgroup;+bbcreate;+bbmove;+bbundelete"
      REFtrig @ swap setname
      prog "_Boards" propdir? if
         "^CNOTE^WARNING: Old +bboard data found.  Running conversion program."
         atell
         Board-Convert
      then
      "www_root" sysparm ToDBref "/_/WWW/" BBW-BBoardLoc strcat prog setprop
      "^CSUCC^Installation finished.  Global +bboard is installed.  Type +bbhelp for further help."
      atell exit
   then
   REFtrig @
   "read;catchup;scan;next;notify;write;post;config;edit;search;delete;remove;cleargroup;timeout;protect"
   setname
   me @
   "^CSUCC^Installation finished.  Local +bboard is installed.  Type 'config' to configure it."
   ansi_notify exit
;
 
: Board-ShowConfigMenu[ int:Board -- str:Options ]
   VAR Options VAR STRtemp VAR STRdir
   Board @ if
      "^GREEN^Message Board Editor (#%d)" Board @ intostr "%d" subst atell
      me @ " " notify
      BB-BoardDir Board @ intostr "%n" subst STRdir !
      BBoard STRdir @ BB-Name strcat getpropstr STRtemp !
      "^CNOTE^( ^CINFO^1^CNOTE^) ^AQUA^Board Name^WHITE^:        ^BLUE^"
      STRtemp @ strcat atell
      BBoard STRdir @ BB-Restricted? strcat getpropstr "yes" stringcmp not
      if "Yes" else "No" then STRtemp !
      me @ "^CNOTE^( ^CINFO^2^CNOTE^) ^AQUA^Restricted^WHITE^?        ^BLUE^"
      STRtemp @ strcat ansi_notify
      BBoard STRdir @ BB-Allow strcat "/" strcat array_get_propvals "" STRtemp !
      FOREACH
         swap stod dup ok? if dup player? else 0 then if
            swap dup ToStr "yes" stringcmp not swap ToInt 3 pick owner
            timestamps pop pop pop = or if
               name STRtemp @ dup if ", " strcat then swap strcat STRtemp !
            else
               pop
            then
         else
            pop pop
         then
      REPEAT
      STRtemp @ strip dup not if pop "^CNOTE^[^CFAIL^None Set^CNOTE^]" then
      STRtemp !
      me @ "^CNOTE^( ^CINFO^3^CNOTE^) ^AQUA^Allow List^WHITE^:        ^BLUE^"
      STRtemp @ strcat ansi_notify
      BBoard STRdir @ BB-AllowProp strcat getpropstr strip dup not
      if pop "^CNOTE^[^CFAIL^None Set^CNOTE^]" then STRtemp !
      me @ "^CNOTE^( ^CINFO^4^CNOTE^) ^AQUA^Allow Prop^WHITE^:        ^BLUE^"
      STRtemp @ strcat ansi_notify
      BBoard STRdir @ BB-ReadOnly? strcat getpropstr "yes" stringcmp not
      if "Yes" else "No" then
      STRtemp !
      me @ "^CNOTE^( ^CINFO^5^CNOTE^) ^AQUA^Read Only^WHITE^?         ^BLUE^"
      STRtemp @ strcat ansi_notify
      BBoard STRdir @ BB-AllowPost strcat "/" strcat array_get_propvals ""
      STRtemp !
      FOREACH
         swap stod dup ok? if dup player? else 0 then if
            swap dup ToStr "yes" stringcmp not swap ToInt 3 pick owner
            timestamps pop pop pop = or if
               name STRtemp @ dup if ", " strcat then swap strcat STRtemp !
            else
               pop
            then
         else
            pop pop
         then
      REPEAT
      STRtemp @ strip dup not if pop "^CNOTE^[^CFAIL^None Set^CNOTE^]" then
      STRtemp !
      me @ "^CNOTE^( ^CINFO^6^CNOTE^) ^AQUA^Allowed Posters^WHITE^:   ^BLUE^"
      STRtemp @ strcat ansi_notify
      BBoard STRdir @ BB-PosterProp strcat getpropstr strip dup not if pop
      "^CNOTE^[^CFAIL^None Set^CNOTE^]" then STRtemp !
      me @ "^CNOTE^( ^CINFO^7^CNOTE^) ^AQUA^Posters Prop^WHITE^:      ^BLUE^"
      STRtemp @ strcat ansi_notify
      BBoard BB-Board dbcmp if
         BBoard STRdir @ BB-AutoSub? strcat getpropstr "yes" stringcmp not
         if "Yes" else "No" then STRtemp !
         me @ "^CNOTE^( ^CINFO^8^CNOTE^) ^AQUA^Auto Subscribe^WHITE^?    ^BLUE^"
         STRtemp @ strcat me @ "WIZARD" flag? BBoard owner me @ owner dbcmp or
         not if 1 unparse_ansi then ansi_notify
      then
      BBoard STRdir @ BB-Timeout strcat getprop ToInt dup 0 = not
      if dup intostr swap 1 = if " day" else " days" then strcat
      else pop "Never" then STRtemp !
      me @ "^CNOTE^( ^CINFO^9^CNOTE^) ^AQUA^Timeout (In Days)^WHITE^: ^BLUE^"
      STRtemp @ strcat ansi_notify
      BBoard STRdir @ BB-Anonymous strcat getpropstr strip dup not
      if pop "^CNOTE^[^CFAIL^Not Anonymous^CNOTE^]" then STRtemp !
      me @ "^CNOTE^(^CINFO^10^CNOTE^) ^AQUA^Posting Name^WHITE^:      ^BLUE^"
      STRtemp @ strcat ansi_notify
      BBoard BB-Board dbcmp if
         BBoard STRdir @ BB-WWWRead strcat getpropstr "yes" stringcmp not
         if "Yes" else "No" then STRtemp !
         me @ "^CNOTE^(^CINFO^11^CNOTE^) ^AQUA^Web Reading^WHITE^:       ^BLUE^"
         STRtemp @ strcat me @ "WIZARD" flag? BBoard owner me @ owner dbcmp
         or not if 1 unparse_ansi then ansi_notify
         BBoard STRdir @ BB-GuestPost? strcat getpropstr "yes" stringcmp not
         if "Yes" else "No" then STRtemp !
         me @ "^CNOTE^(^CINFO^12^CNOTE^) ^AQUA^Guest Posting^WHITE^?     ^BLUE^"
         STRtemp @ strcat me @ "WIZARD" flag? BBoard owner me @ owner dbcmp
         or not if 1 unparse_ansi then ansi_notify
         BBoard STRdir @ BB-GuestRead? strcat getpropstr "yes" stringcmp not
         if "Yes" else "No" then STRtemp !
         me @ "^CNOTE^(^CINFO^13^CNOTE^) ^AQUA^Guest Unread Msgs^WHITE^? ^BLUE^"
         STRtemp @ strcat me @ "WIZARD" flag? BBoard owner me @ owner dbcmp
         or not if 1 unparse_ansi then ansi_notify
         BBoard STRdir @ BB-NoCatchUp? strcat getpropstr "yes" stringcmp
         not if "Yes" else "No" then STRtemp !
         me @ "^CNOTE^(^CINFO^14^CNOTE^) ^AQUA^No Catchup^WHITE^?        ^BLUE^"
         STRtemp @ strcat me @ "WIZARD" flag? BBoard owner me @ owner dbcmp
         or not if 1 unparse_ansi then ansi_notify
      then
      BBoard STRdir @ BB-AllowMPI strcat getpropstr strip 1 escape_ansi dup not
      if pop "^CNOTE^[^CFAIL^None Set^CNOTE^]" then STRtemp !
      me @ "^CNOTE^(^CINFO^15^CNOTE^) ^AQUA^Allow MPI ^WHITE^:        ^BLUE^"
      STRtemp @ strcat ansi_notify
      BBoard STRdir @ BB-AllowPostMPI strcat getpropstr strip 1 escape_ansi dup
      not if pop "^CNOTE^[^CFAIL^None Set^CNOTE^]" then STRtemp !
      me @ "^CNOTE^(^CINFO^16^CNOTE^) ^AQUA^Posters MPI ^WHITE^:      ^BLUE^"
      STRtemp @ strcat ansi_notify
      me @ "^CNOTE^(^CINFO^20^CNOTE^) ^RED^Quit and save changes^WHITE^."
      ansi_notify
      BBoard BB-Board dbcmp if
         "\r1\r2\r3\r4\r5\r6\r7\r8\r9\r10\r11\r12\r13\r14\r15\r16\r20\rQ\r"
      else
         "\r1\r2\r3\r4\r5\r6\r7\r9\r10\r15\r16\r20\rQ\r"
      then
   else
      me @ "^GREEN^+BBConfig" ansi_notify
      me @ " " ansi_notify
      BBoard BB-Unread? getpropstr "no" stringcmp not if "No" else "Yes" then
      STRtemp !
      "^CNOTE^( ^CINFO^A^CNOTE^) ^AQUA^Scan for unread messages at login^WHITE^? ^BLUE^"
      STRtemp @ strcat atell
      BBoard BB-PCreate? getpropstr "yes" stringcmp not
      if "Yes" else "No" then STRtemp !
      "^CNOTE^( ^CINFO^B^CNOTE^) ^AQUA^Player created bboards^WHITE^?            ^BLUE^"
      STRtemp @ strcat atell
      BBoard BB-DefTimeout getprop ToInt dup 0 = not
      if dup intostr swap 1 = if " day" else " days" then strcat
      else pop "Never" then STRtemp !
      "^CNOTE^( ^CINFO^C^CNOTE^) ^AQUA^Default timeout (In Days)^WHITE^:         ^BLUE^"
      STRtemp @ strcat atell
      BBoard BB-AutoDel? getpropstr "no" stringcmp not
      if "No" else "Yes" then STRtemp !
      "^CNOTE^( ^CINFO^D^CNOTE^) ^AQUA^Autodelation for timeout^WHITE^?          ^BLUE^"
      STRtemp @ strcat atell
      me @ "^CNOTE^(^CINFO^20^CNOTE^) ^RED^Quit the editor^WHITE^." ansi_notify
      "\rA\rB\rC\rD\r15\r16\r20\rQ\r"
   then
;
 
: Board-Config[ int:Board -- ]
   VAR Options "" dup VAR! STRdir dup VAR! STRtemp dup VAR! STRadd dup
   VAR! STRrem VAR! STRdir2 VAR BOLrem?
   me @ owner isGuest? if
      me @ "^CFAIL^BBOARD: Guests cannot do that." ansi_notify exit
   then
   force_level if
      me @ "^CFAIL^BBOARD: This function cannot be forced." ansi_notify exit
   then
   Board @ not if
      me @ "^CFAIL^BBOARD: Invalid message board." ansi_notify exit
   then
   Board @ -1 = if
      0 Board !
   then
   me @ "WIZARD" flag? BBoard owner me @ owner dbcmp or
   Board @ if BBoard BB-BoardDir Board @ intostr "%n" subst BB-Owner strcat
   getprop ToDbref owner me @ owner dbcmp or then not if
      me @ "^CFAIL^BBOARD: Permission denied." ansi_notify exit
   then
   BB-BoardDir Board @ intostr "%n" subst STRdir !
   BEGIN
      Board @ Board-ShowConfigMenu Options !
      me @ "^CINFO^Enter your choice now:" ansi_notify
      BEGIN
         read "\r" over over strcat strcat Options @ swap instring not WHILE pop
         me @ "^CFAIL^Invalid option.  Try again:" ansi_notify
      REPEAT
      Options !
      BEGIN
         Options @ "1" stringcmp not if
            me @ "^CYAN^Enter a new name for the board:" ansi_notify
            BEGIN
               read strip dup STRtemp ! not WHILE
               me @ "^CFAIL^You must enter something!  Try again:" ansi_notify
            REPEAT
            STRtemp @ Board-MatchName if
               "^CFAIL^BBOARD: That board name is already taken." atell BREAK
            then
            STRTemp @ number? STRtemp @ ":" instr or STRtemp @ "/" instr or if
               me @ "^CFAIL^BBOARD: Invalid board name." ansi_notify BREAK
            then
            BBoard STRdir @ BB-Name strcat over over getpropstr
            BBoard BB-NamePath STRtemp @ strcat getprop ToInt dup if
               BBoard BB-BoardDir rot intostr "%n" subst "/" rsplit pop
               remove_prop
               BBoard BB-NamePath STRtemp @ strcat remove_prop
            else
               pop
            then
            BBoard BB-NamePath rot strcat remove_prop STRtemp @ setprop
            BBoard BB-NamePath STRtemp @ strcat Board @ setprop
            me @ "^CSUCC^BBOARD: New board name set." ansi_notify
         BREAK then
         Options @ "2" stringcmp not if
            BBoard STRdir @ BB-Restricted? strcat over over getpropstr "yes"
            stringcmp not if
               remove_prop
            else
               "yes" setprop
            then
            me @ "^CSUCC^BBOARD: Option toggled." ansi_notify
         BREAK then
         Options @ "3" stringcmp not if
            "^CYAN^Enter a new user to add (or, enter '!<user>' to remove one):"
            atell
            "^CNOTE^NOTE: You can add/remove multiple users by entering spaces between the names."
            atell
            BEGIN
               read strip dup STRtemp ! not WHILE
               "^CFAIL^Failed to enter a user (or users).  Try again:" atell
            REPEAT
            STRdir @ BB-Allow strcat "/" strcat STRdir2 !
            STRtemp @ " " explode_array "" STRadd ! "" STRrem !
            FOREACH
               swap pop 0 BOLrem? !
               BEGIN
                  dup "!" instr 1 = WHILE
                  1 strcut swap pop BOLrem? @ not BOLrem? !
               REPEAT
               dup pmatch dup ok? not if
                  pop me @ swap " cannot be found." strcat "^CFAIL^" swap strcat
                  ansi_notify
               else
                  swap pop
                  BBoard STRdir2 @ 3 pick int intostr strcat BOLrem? @ if
                     remove_prop STRrem @ dup if ", " strcat then swap name
                     strcat STRrem !
                  else
                     3 pick timestamps pop pop pop setprop STRadd @ dup if ", "
                     strcat then swap name strcat STRadd !
                  then
               then
            REPEAT
            STRadd @ if
               me @ "^CSUCC^BBOARD: Added %s to the list." STRadd @ "%s" subst
               ansi_notify
            then
            STRrem @ if
               me @ "^CSUCC^BBOARD: Removed %s from the list." STRrem @ "%s"
               subst ansi_notify
            then
            STRadd @ STRrem @ or not if
               me @ "^CFAIL^BBOARD: No action taken." ansi_notify
            then
         BREAK then
         Options @ "4" stringcmp not if
            me @ "^CYAN^Enter a new allow prop [formats: '~prop' or '~prop:1', or blank for none]:"
            ansi_notify
            read strip STRtemp !
            BBoard STRdir @ BB-AllowProp strcat STRtemp @ setprop
            me @ "^CSUCC^BBOARD: New allowed prop set." ansi_notify
         BREAK then
         Options @ "5" stringcmp not if
            BBoard STRdir @ BB-ReadOnly? strcat over over
            getpropstr "yes" stringcmp not if
               remove_prop
            else
               "yes" setprop
            then
            me @ "^CSUCC^BBOARD: Option toggled." ansi_notify
         BREAK then
         Options @ "6" stringcmp not if
            "^CYAN^Enter a new user to add (or, enter '!<user>' to remove one):"
            atell
            "^CNOTE^NOTE: You can add/remove multiple users by entering spaces between the names."
            atell
            BEGIN
               read strip dup STRtemp ! not WHILE
               "^CFAIL^Failed to enter a user (or users).  Try again:" atell
            REPEAT
            STRdir @ BB-AllowPost strcat "/" strcat STRdir2 !
            STRtemp @ " " explode_array "" STRadd ! "" STRrem !
            FOREACH
               swap pop 0 BOLrem? !
               BEGIN
                  dup "!" instr 1 = WHILE
                  1 strcut swap pop BOLrem? @ not BOLrem? !
               REPEAT
               dup pmatch dup ok? not if
                  pop me @ swap " cannot be found." strcat "^CFAIL^" swap strcat
                  ansi_notify
               else
                  swap pop
                  BBoard STRdir2 @ 3 pick int intostr strcat BOLrem? @ if
                     remove_prop STRrem @ dup if ", " strcat then swap name
                     strcat STRrem !
                  else
                     3 pick timestamps pop pop pop setprop STRadd @ dup if ", "
                     strcat then swap name strcat STRadd !
                  then
               then
            REPEAT
            STRadd @ if
               "^CSUCC^BBOARD: Added %s to the list." STRadd @ "%s" subst atell
            then
            STRrem @ if
               me @ "^CSUCC^BBOARD: Removed %s from the list." STRrem @ "%s"
               subst ansi_notify
            then
            STRadd @ STRrem @ or not if
               me @ "^CFAIL^BBOARD: No action taken." ansi_notify
            then
         BREAK then
         Options @ "7" stringcmp not if
            "^CYAN^Enter a new allowed posters prop [formats: '~prop' or '~prop:1', or blank for none]:"
            atell
            read strip STRtemp !
            BBoard STRdir @ BB-PosterProp strcat STRtemp @ setprop
            me @ "^CSUCC^BBOARD: New allowed posters prop set." ansi_notify
         BREAK then
         Options @ "8" stringcmp not if
            me @ "WIZARD" flag? BBoard owner me @ owner dbcmp or not if
               me @ "^CFAIL^BBOARD: Permission denied." ansi_notify BREAK
            then
            BBoard STRdir @ BB-AutoSub? strcat over over getpropstr "yes"
            stringcmp not if
               remove_prop
            else
               "yes" setprop
            then
            me @ "^CSUCC^BBOARD: Option toggled." ansi_notify
         BREAK then
         Options @ "9" stringcmp not if
            "^CYAN^Enter a new timeout for the board (0 for none):" atell
            BEGIN
               read strip dup STRtemp ! number? not WHILE
               me @ "^CFAIL^You must enter a number!  Try again:" ansi_notify
            REPEAT
            BBoard STRdir @ BB-Timeout strcat STRtemp @ atoi setprop
            me @ "^CSUCC^BBOARD: New board timeout set." ansi_notify
         BREAK then
         Options @ "10" stringcmp not if
            "^CYAN^Enter a new name for the anonymous poster [type in a space then hit enter for non-anonymous posting]:"
            atell
            read strip STRtemp !
            BBoard STRdir @ BB-Anonymous strcat STRtemp @ setprop
            me @ "^CSUCC^BBOARD: New poster name set." ansi_notify
         BREAK then
         Options @ "11" stringcmp not if
            me @ "WIZARD" flag? BBoard owner me @ owner dbcmp or not if
               me @ "^CFAIL^BBOARD: Permission denied." ansi_notify BREAK
            then
            BBoard STRdir @ BB-WWWRead strcat over over getpropstr "yes"
            stringcmp not if
               remove_prop
            else
               "yes" setprop
            then
            me @ "^CSUCC^BBOARD: Option toggled." ansi_notify
         BREAK then
         Options @ "12" stringcmp not if
            me @ "WIZARD" flag? BBoard owner me @ owner dbcmp or not if
               me @ "^CFAIL^BBOARD: Permission denied." ansi_notify BREAK
            then
            BBoard STRdir @ BB-GuestPost? strcat over over getpropstr "yes"
            stringcmp not if
               remove_prop
            else
               "yes" setprop
            then
            me @ "^CSUCC^BBOARD: Option toggled." ansi_notify
         BREAK then
         Options @ "13" stringcmp not if
            me @ "WIZARD" flag? BBoard owner me @ owner dbcmp or not if
               me @ "^CFAIL^BBOARD: Permission denied." ansi_notify BREAK
            then
            BBoard STRdir @ BB-GuestRead? strcat over over getpropstr "yes"
            stringcmp not if
               remove_prop
            else
               "yes" setprop
            then
            me @ "^CSUCC^BBOARD: Option toggled." ansi_notify
         BREAK then
         Options @ "14" stringcmp not if
            me @ "WIZARD" flag? BBoard owner me @ owner dbcmp or not if
               me @ "^CFAIL^BBOARD: Permission denied." ansi_notify BREAK
            then
            BBoard STRdir @ BB-NoCatchUp? strcat over over getpropstr "yes"
            stringcmp not if
               remove_prop
            else
               "yes" setprop
            then
            me @ "^CSUCC^BBOARD: Option toggled." ansi_notify
         BREAK then
         Options @ "15" stringcmp not if
            me @ "^CYAN^Enter a new allowed players MPI lock" ansi_notify
            read strip STRtemp !
            BBoard STRdir @ BB-AllowMPI strcat STRtemp @ setprop
            me @ "^CSUCC^BBOARD: New allowed MPI lock set." ansi_notify
         BREAK then
         Options @ "16" stringcmp not if
            me @ "^CYAN^Enter a new allowed posters MPI lock" ansi_notify
            read strip STRtemp !
            BBoard STRdir @ BB-AllowPostMPI strcat STRtemp @ setprop
            me @ "^CSUCC^BBOARD: New allowed poster MPI lock set." ansi_notify
         BREAK then
         Options @ "A" stringcmp not if
            BBoard STRdir @ BB-Unread? strcat over over getpropstr "no"
            stringcmp not if
               remove_prop
            else
               "no" setprop
            then
            me @ "^CSUCC^BBOARD: Option toggled." ansi_notify
         BREAK then
         Options @ "B" stringcmp not if
            BBoard STRdir @ BB-PCreate? strcat over over getpropstr "yes"
            stringcmp not if
               remove_prop
            else
               "yes" setprop
            then
            me @ "^CSUCC^BBOARD: Option toggled." ansi_notify
         BREAK then
         Options @ "C" stringcmp not if
            me @ "^CYAN^Enter a new global timeout (0 for none):" ansi_notify
            BEGIN
               read strip dup STRtemp ! number? not WHILE
               me @ "^CFAIL^You must enter a number!  Try again:" ansi_notify
            REPEAT
            BBoard BB-DefTimeout STRtemp @ atoi setprop
            me @ "^CSUCC^BBOARD: New global timeout set." ansi_notify
         BREAK then
         Options @ "D" stringcmp not if
            BBoard STRdir @ BB-AutoDel? strcat over over getpropstr "no"
            stringcmp not if
               remove_prop
            else
               "no" setprop
            then
            me @ "^CSUCC^BBOARD: Option toggled." ansi_notify
         BREAK then
         Options @ "Q" stringcmp not Options @ "20" stringcmp not or if
            me @ "^CFAIL^Quiting editor." ansi_notify exit
         BREAK then
      REPEAT
   REPEAT
;
 
: Board-Help[ str:Screen -- ]
   Screen @ "" ":" subst "" "/" subst "" "\r" subst "" "\[" subst Screen !
   Screen @ strip dup Screen ! not if "Index" Screen ! then
   me @ "^CYAN^+BBoard v%1.2f - by Moose" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
   me @ "^PURPLE^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" ansi_notify
   Screen @ BEGIN
      trig "_bbhelp/" Screen @ strcat array_get_proplist dup array_count if
         swap pop
         FOREACH
            swap pop me @ swap ansi_notify
         REPEAT
      exit then pop
      dup "BBread" stringcmp not if pop
         me @ "^WHITE^+bbread                ^NORMAL^- This will list all of the boards subscribed to" ansi_notify
         me @ "^WHITE^+bbread [#]            ^NORMAL^- List all of the messages on board [#]" ansi_notify
         me @ "^WHITE^+bbread [#]/[#2]       ^NORMAL^- Read message [#2] on board [#]" ansi_notify
         me @ "^WHITE^+bbread [#]/[List]     ^NORMAL^- Read messages in [List] on board [#]" ansi_notify
         me @ "^WHITE^+bblist                ^NORMAL^- List all boards you can subscribe to" ansi_notify
         me @ "^WHITE^+bbscan                ^NORMAL^- Scan boards for unread messages" ansi_notify
         me @ "^WHITE^+bbcatchup [#]         ^NORMAL^- Set all messages on board [#] as read" ansi_notify
         me @ "^WHITE^+bbcatchup All         ^NORMAL^- Set every message as read" ansi_notify
         me @ "^WHITE^+bbnotify [#]          ^NORMAL^- Toggle being notifed on board [#] of unread posts" ansi_notify
         me @ "^WHITE^+bbnotify [#]=[On/Off] ^NORMAL^- Same as above, but you choose it being on/off" ansi_notify
         me @ "^WHITE^+bbnext                ^NORMAL^- Next unread message on any board" ansi_notify
         me @ "^WHITE^+bbnext [#]            ^NORMAL^- Next unread message on board [#]" ansi_notify
         me @ "^WHITE^+bbnext [#]=[nummsgs]  ^NORMAL^- Next unread message on board [#]" ansi_notify
         me @ "^WHITE^+bbsearch [#]/[Name]   ^NORMAL^- Search board [#] for messages posted by [Name]" ansi_notify
         me @ "^WHITE^+bbsearch #text        ^NORMAL^- Same parameters as above, but searches the message text." ansi_notify
         me @ "^WHITE^+bbsearch #name        ^NORMAL^- Same parameters as above, but searches the player name." ansi_notify
         me @ "^WHITE^+bbsearch #subj        ^NORMAL^- Same parameters as above, but searches the subjects." ansi_notify
         me @ "^WHITE^+bbsearch #all         ^NORMAL^- Same parameters as above, but searches all param types." ansi_notify
         me @ "^WHITE^+bbjoin [#]            ^NORMAL^- Join unsubscribed group [#]" ansi_notify
         me @ "^WHITE^+bbleave [#]           ^NORMAL^- Leave subscribed group [#]" ansi_notify
         me @ "Furthermore, you can change the number of lines to pause at by typing: @set me=%s:<num lines>" BBP-PauseLines "%s" subst ansi_notify
      break then
      dup "BBpost" stringcmp not if pop
         me @ "^WHITE^+bbpost [#]              ^NORMAL^- Post a message to board [#]" ansi_notify
         me @ "^WHITE^+bbpost [#]/[Subj]       ^NORMAL^- Same as above, but set the subject right away" ansi_notify
         me @ "^WHITE^+bbpost [#]/[Subj]=[Text]^NORMAL^- Quick post a message to board [#] with [Text] for msg" ansi_notify
         me @ "^WHITE^+bbedit [#]/[#2]         ^NORMAL^- Edit message [#]/[#2] if it is yours" ansi_notify
         me @ "^WHITE^+bbedit [#]/[#2]/[Subj]  ^NORMAL^- Rewrite the subject for the message" ansi_notify
         me @ "^WHITE^+bbedit [#]/[#2]=[O]/[N] ^NORMAL^- In message [#]/[#2] replace [O] with [N]" ansi_notify
         me @ "^WHITE^+bbmove [#]/[#2] to [#3] ^NORMAL^- Move post [#]/[#2] to board [#3]" ansi_notify
         me @ "^WHITE^+bbremove [#]/[#2]       ^NORMAL^- Remove [#]/[#2] if you wrote it" ansi_notify
         me @ "^WHITE^+bbremove [#]/[List]     ^NORMAL^- Remove a [List] of messages on board [#] that you wrote" ansi_notify
         me @ "^WHITE^+bbtimeout [#]/[#2]=[#3] ^NORMAL^- Set [#3] as new timeout for message [#]/[#2]" ansi_notify
         me @ " " notify
         me @ "If you type 'lsedit me=%s' then you can edit a signature file for posts." BBP-Signature "%s" subst ansi_notify
         me @ "A quick way to make the signature file is to also type: @set me=%s:<signature>" BBP-Signature "%s" subst ansi_notify
      break then
      dup "BBadmin" stringcmp not if pop
         me @ "^WHITE^+bbconfig            ^NORMAL^- Edit global settings for bboard [Also +bbedit]" ansi_notify
         me @ "^WHITE^+bbedit [#]          ^NORMAL^- Edit the group if you own it [Also +bbeditgroup]" ansi_notify
         me @ "^WHITE^+bbnewgroup [Text]   ^NORMAL^- Create a new group named [Text] [Also +bbcreate]" ansi_notify
         me @ "^WHITE^+bbtimeout [#]       ^NORMAL^- Set [#] as new default timeout" ansi_notify
         me @ "^WHITE^+bbtimeout [#]=[#2]  ^NORMAL^- Set [#2] as new timeout for group [#2]" ansi_notify
         me @ "^WHITE^+bbremove [#]        ^NORMAL^- Remove the board [#] if you own it [Also +bbdelete]" ansi_notify
         me @ "^WHITE^+bbprotect [#]/[#2]  ^NORMAL^- Protect [#]/[#2] from timeout deletion" ansi_notify
         me @ "^WHITE^+bbundelete [#]      ^NORMAL^- Undelete board [#] if it wasn't replaced already" ansi_notify
         me @ "^WHITE^+bbcleargroup [#]    ^NORMAL^- Clear all messages on board [#]" ansi_notify
         me @ "^WHITE^+bbchown [#]         ^NORMAL^- Chowns bboard [#] to yourself, if pass chown-ok or perms." ansi_notify
         me @ "^WHITE^+bbchown [#]=[PLYR]  ^NORMAL^- Sets bboard [#] chown-ok for player [PLYR]" ansi_notify
      break then
      dup "WhatsNew" stringcmp not if pop
         me @ "^WHITE^v3.2.2 [Moose] - Added support for $lib/standard and bugfixes." ansi_notify
         me @ "^WHITE^v3.2.1 [Akari] - Fixed the +bbnext 'more messages' support." ansi_notify
         me @ "^WHITE^v3.2.0 [Akari] - Cleaned this up to be 80 column friendly, except for the" ansi_notify
         me @ "   parts that were beyond hope." ansi_notify
         me @ " * Made it so that when +bbcatchup doesn't update any boards, it explains" ansi_notify
         me @ "   how to catchup on all boards." ansi_notify
         me @ " * Made it so that +bbnext will report if there are more unread messages" ansi_notify
         me @ "   or not." ansi_notify
         me @ "^WHITE^v3.0.9 - Fixed up +bbscan and +bbnext to work properly with +bbnotify" ansi_notify
         me @ " * Added a '-' tag to '+bbread' so folks know if they aren't being notified of posts there." ansi_notify
         me @ " ^CINFO^TO DO: [beta version!]" ansi_notify
         me @ " * Add AUTOSHOW flag for posts for an auto-MOTD system [Wizard only]" ansi_notify
         me @ " * Add an autocleaner that runs once a day to clean any posts that weren't removed/set properly." ansi_notify
         me @ "   :: Also add a +bbclean command for this" ansi_notify
         me @ "^WHITE^v3.0.8 - Fixed anonymous posts that aren't so anonymous" ansi_notify
         me @ "^WHITE^v3.0.7 - Bug fixes and one change" ansi_notify
         me @ " * +bbscan now outputs everything in one array-notify to prevent it from" ansi_notify
         me @ "   interfering with the output of any other program." ansi_notify
         me @ " * Just found out that posts weren't removing properly.  Fixed now." ansi_notify
         me @ "^WHITE^v3.0.6 - Bug fixes" ansi_notify
         me @ " * The web-board works properly again." ansi_notify
         me @ " * The array_sort procedure now uses the internal prim." ansi_notify
         me @ "^WHITE^v3.0.5 - Bug fixes (hopefully for the last time?)" ansi_notify
         me @ " * A lot of permission errors were fixed.  It thought so-and-so didn't have" ansi_notify
         me @ "   permission or was not subscribed to a board, when he or she was. Fixed." ansi_notify
         me @ "^WHITE^v3.0.4 - Bug fixes (yet again)" ansi_notify
         me @ " * Somehow +bbremove #/# stopped working. Works now." ansi_notify
         me @ " * Added better checking for if a message or group owner still exists or not." ansi_notify
         me @ "^WHITE^v3.0.3 - Bug fixes (again)" ansi_notify
         me @ " * Page pausing is now off by default." ansi_notify
         me @ " * A typo in +bbhelp was fixed." ansi_notify
         me @ " * +bbnext still didn't work.  Now works fine.  Silly typos." ansi_notify
         me @ " * '+bbcatchup all' works again." ansi_notify
         me @ "^WHITE^v3.0.2 - Bug fixes" ansi_notify
         me @ " * A few bug fixes were done in 3.0.1, but undocumented." ansi_notify
         me @ " * +bbscan runs on logins again." ansi_notify
         me @ " * +bbnext now works properly." ansi_notify
         me @ "^WHITE^v3.0.0 - Second Rewrite" ansi_notify
         me @ "There are tons of new additions.  Here is a full list:" ansi_notify
         me @ " * Option for boards to allow guest posting." ansi_notify
         me @ " * Removed the web posting option [Can't be done properly, unfortunatly]" ansi_notify
         me @ " * Added +bbsearch #text, +bbsearch #subj, +bbsearch #name, and" ansi_notify
         me @ "   +bbsearch #all [Default:name]" ansi_notify
         me @ " * Added URGENT flag to prevent +bbcatchup from setting it as unread." ansi_notify
         me @ "   Only reading it does.  Also stops +bbnotify from working on the board." ansi_notify
         me @ " * Added a <more> option for page pausing when messages are too large." ansi_notify
         me @ " * Added a wizard only option to prevent +bbcatchup on certain boards." ansi_notify
         me @ " * Now, by default, guests are not told of unread messages on boards" ansi_notify
         me @ "   [unless an option is set on it]" ansi_notify
         me @ " * Local / one-room boards are now possible.  @register this program" ansi_notify
         me @ "   as $gen/bboard" ansi_notify
         me @ " * Changed how +bbchown works.  Now, trying to chown it to different" ansi_notify
         me @ "   players will only set it chown-ok for them.  They must 'ok' the" ansi_notify
         me @ "   chown by typing '+bbchown <board #>'" ansi_notify
      break then
      dup "Local" stringcmp not if pop
         me @ "Type the following in the room you want it in:" ansi_notify
         me @ "   ^WHITE^@action read;write;edit;editmsg;remove;protect;next;search;catchup;scan;timeout=here" ansi_notify
         me @ "   ^WHITE^@link read=%d" prog dtos "%d" subst ansi_notify
         me @ "Then you are done and have a one room bulletin board." ansi_notify
      break then
      dup "Index" stringcmp not if pop
         me @ "^WHITE^+bbread            ^NORMAL^- This will list all of the boards subscribed to" ansi_notify
         me @ "^WHITE^+bbread [#]        ^NORMAL^- List all of the messages on board [#]" ansi_notify
         me @ "^WHITE^+bbread [#]/[#2]   ^NORMAL^- Read message [#2] on bard [#]" ansi_notify
         me @ "^WHITE^+bbpost [#]        ^NORMAL^- Post a message to board [#]" ansi_notify
         me @ "^WHITE^+bbedit [#]/[#2]   ^NORMAL^- Edit message [#]/[#2] if it is yours" ansi_notify
         me @ "^WHITE^+bbremove [#]/[#2] ^NORMAL^- Remove [#]/[#2] if you wrote it" ansi_notify
         me @ " " notify
         me @ "^WHITE^+bbhelp bbread     ^NORMAL^- Commands associated with reading" ansi_notify
         me @ "^WHITE^+bbhelp bbpost     ^NORMAL^- Commands associated with posting" ansi_notify
         me @ "^WHITE^+bbhelp bbadmin    ^NORMAL^- Commands associated with administration" ansi_notify
         me @ "^WHITE^+bbhelp whatsnew   ^NORMAL^- See what is new in +bboard" ansi_notify
         me @ "^WHITE^+bbhelp local      ^NORMAL^- How to implement your own local bboard." ansi_notify
      break then
      pop me @ "^CINFO^Invalid help section. Type '+bbhelp' for help." ansi_notify exit
   REPEAT
   me @ "^YELLOW^Done." ansi_notify
;
 
: Cmd-Main ( str:Args -- )
   VAR ARRtemp { }list ARRtemp ! VAR STRtemp
   command @ "(WWW)" stringcmp not if
      Board-Web exit
   then
   command @ "Queued Event." stringcmp not if
      "connect" stringcmp not if
         BACKGROUND
         BBoard BB-UnRead? getpropstr "no" stringcmp not not if
            DEF-CheckWait sleep Board-Scan
         then
         exit
      then
   then
   me @ isPlayer? not trigger @ location #0 dbcmp and if
      pop me @ "^CFAIL^BBOARD: Only players can use boards." ansi_notify exit
   then
   dup  "#help" stringcmp not
   over "#help " instring 1 = or
   command @ "+bbhelp" stringcmp not or command @ "help" instring or if
      dup "#help" instring 1 = if
         5 strcut swap pop strip
      then
      Board-Help exit
   then
   command @ "+BBsetup" stringcmp not command @ "setup" instring or if
      strip dup not if pop trig else match then Board-Install exit
   then
   command @ "+BBread" stringcmp not command @ "read" instring or if
      BB-GroupNum if
         BB-GroupNum intostr "/" strcat swap strcat
      then
      strip dup not if
         pop Board-ShowBoards
      else
         "/" split swap strip Board-MatchName swap strip dup if
            dup "u" stringcmp if
               " " explode_array
               FOREACH
                  swap pop
                  atoi ARRtemp @ array_appenditem ARRtemp !
               REPEAT
 
               ARRtemp @ Board-ReadMsgs
            else
               pop 1 1 Board-NextMsg
            then
         else
            pop "*" 0 Board-ListMsgs
         then
      then
      exit
   then
   command @ "+BBcatchup" stringcmp not command @ "catchup" instring or if
      BB-GroupNum if
         pop BB-GroupNum intostr
      then
      strip dup "all" stringcmp not if
          pop { }list
      else
         " " explode_array dup
         FOREACH
            swap pop
            Board-MatchName ARRtemp @ array_appenditem ARRtemp !
         REPEAT
         ARRtemp @
      then
      Board-CatchUp exit
   then
   command @ "+BBscan" stringcmp not command @ "scan" instring or if
      pop Board-Scan exit
   then
   command @ "+BBnext" stringcmp not command @ "next" instring or if
      BB-GroupNum if
         BB-GroupNum intostr "=" strcat swap strcat
      then
      "=" split strip swap strip dup if Board-MatchName else pop -1 then
      swap atoi dup not if pop 1 then 1 Board-NextMsg exit
   then
   command @ "+BBnotify" stringcmp not command @ "notify" instring or if
      BB-GroupNum if
         BB-GroupNum intostr "=" strcat swap strcat
      then
      "=" split swap strip dup if
         " " explode_array
         FOREACH
            swap pop
            Board-MatchName ARRtemp @ array_appenditem ARRtemp !
         REPEAT
         ARRtemp @
      else
         { }list
      then
      swap strip Board-ToggleNotify exit
   then
   command @ "+BBpost" stringcmp not command @ "+BBwrite" instring or
   command @ "post" instring or command @ "write" instring or if
      BB-GroupNum if
         BB-GroupNum intostr "/" strcat swap strcat
      then
      "=" split swap "/" split strip swap Board-MatchName swap rot
      Board-PostMsg exit
   then
   command @ "+BBeditgroup" stringcmp not
   command @ "+BBconfig" stringcmp not or command @ "editgroup" instring or
   command @ "config" instring or if
      BB-GroupNum if
         pop BB-GroupNum intostr
      then
      strip dup not if
         pop -1
      else
         Board-MatchName
      then
      Board-Config exit
   then
   command @ "+BBedit" stringcmp not command @ "edit" instring or command @
   "editmsg" instring or if
      BB-GroupNum if
         dup if
            BB-GroupNum intostr "/" strcat swap strcat
         else
            pop BB-GroupNum intostr
         then
      else
         strip dup not if
            pop -1 Board-Config exit
         then
         dup Board-MatchName dup if
            swap pop Board-Config exit
         then
         pop
      then
      "/" split swap Board-MatchName swap strip dup "=" instr if
         "=" split swap strip atoi swap "/" split
      else
         dup "/" instr not if
            atoi "" ""
         else
            "/" split swap strip atoi swap strip "" swap
         then
      then
      swap Board-EditMsg exit
   then
   command @ "+BBsearch" stringcmp not command @ "search" instring or if
      strip dup "#" instr if
         " " split strip swap strip STRtemp !
      else
         "" STRtemp !
      then
      BB-GroupNum if
         BB-GroupNum intostr "/" strcat swap strcat
      then
      "/" split strip swap strip dup over "all" stringcmp and if
         " " explode_array
         FOREACH
            swap pop
            Board-MatchName ARRtemp @ array_appenditem ARRtemp !
         REPEAT
         ARRtemp @
      else
         pop { }list
      then
      STRtemp @ " " strcat rot strcat strip Board-SearchMsgs exit
   then
   command @ "+BBdelete" stringcmp not
   command @ "+BBremove" stringcmp not or command @ "delete" instring or
   command @ "remove" instring or if
      BB-GroupNum if
         BB-GroupNum intostr "/" strcat swap strcat
      then
      "/" split swap Board-MatchName swap strip dup if
         " " explode_array
         FOREACH
            swap pop
            atoi ARRtemp @ array_appenditem ARRtemp !
         REPEAT
         ARRtemp @ Board-DeleteMsg
      else
         pop Board-DeleteBoard
      then
      exit
   then
   command @ "+BBcleargroup" stringcmp not command @ "cleargroup" instring or if
      BB-GroupNum if
         pop BB-GroupNum intostr
      then
      Board-MatchName Board-ClearGroup exit
   then
   command @ "+BBtimeout" stringcmp not command @ "timeout" instring or if
      BB-GroupNum if
         BB-GroupNum intostr "/" strcat swap strcat
      then
      "/" split strip dup if
         swap strip Board-MatchName swap strip "=" split strip atoi swap strip
         " " explode_array { }list ARRtemp !
         FOREACH
            swap pop
            atoi ARRtemp @ array_appenditem ARRtemp !
         REPEAT
         ARRtemp @ swap
      else
         pop strip "=" split strip dup if
            atoi swap Board-MatchName { }list rot
         else
            pop atoi 0 { }list rot
         then
      then
      Board-SetTimeout exit
   then
   command @ "+BBprotect" stringcmp not command @ "protect" instring or if
      BB-GroupNum if
         BB-GroupNum intostr "/" strcat swap strcat
      then
      "/" split swap Board-MatchName swap " " explode_array
      FOREACH
         swap pop
         atoi ARRtemp @ array_appenditem ARRtemp !
      REPEAT
      ARRtemp @ Board-ProtectMsg exit
   then
   BB-GroupNum if
      me @ "^CFAIL^BBOARD: Invalid action." ansi_notify
   then
   command @ "+BBchown" stringcmp not command @ "chown" instring or if
      BB-GroupNum if
         pop BB-GroupNum intostr
      then
      "=" split swap Board-MatchName swap dup not over "me" stringcmp not or if
         pop me @
      else
         pmatch
      then
      Board-ChownBoard exit
   then
   command @ "+BBlist" stringcmp not command @ "list" instring or if
      pop Board-ListBoards exit
   then
   command @ "+BBjoin" stringcmp not command @ "join" instring or if
      Board-MatchName Board-JoinBoard exit
   then
   command @ "+BBleave" stringcmp not command @ "leave" instring or if
      Board-MatchName Board-LeaveBoard exit
   then
   command @ "+BBnewgroup" stringcmp not
   command @ "+BBcreate" stringcmp not or command @ "newgroup" instring or
   command @ "create" instring or if
      strip Board-CreateBoard exit
   then
   command @ "+BBmove" stringcmp not command @ "move" instring or command @
   "move" instring or if
      BB-GroupNum if
         BB-GroupNum intostr "/" strcat swap strcat
      then
      "/" split swap Board-MatchName swap " to " split
      Board-MatchName swap strip " " explode_array
      FOREACH
         swap pop
         atoi ARRtemp @ array_appenditem ARRtemp !
      REPEAT
      ARRtemp @ swap Board-MoveMsgs exit
   then
   command @ "+BBundelete" stringcmp not command @ "undelete" instring or if
      BB-GroupNum if
         pop BB-GroupNum intostr
      then
      atoi Board-UndeleteBoard exit
   then
   "+bbconvert" command @ stringcmp not if
      prog "~BBConvert?" getpropstr "yes" stringcmp prog "_Boards" propdir? and
      if
         BBoard BB-Count remove_prop BBoard BB-BoardDir "/" split pop
         remove_prop
         Board-Convert prog "~BBConvert?" "yes" setprop prog "_Boards"
         remove_prop
      else
         me @ "^CFAIL^You have already run +bbconvert.  If you run it again you will lose all of the new information.  Aborted." ansi_notify
      then exit
   then
   me @ "^CFAIL^BBOARD: Invalid action." ansi_notify
;
 
: Main ( str:Args -- )
   Cmd-Main (--->) BACKGROUND (----\/)
   BBoard BB-LastTimeout getprop ToInt systime DEF-AutoTimeoutWait - < if
      BBoard BB-LastTimeout systime setprop
      BBoard BB-AutoDel? getpropstr "no" stringcmp if
         Board-AutoTimeout
      then
   then
;
