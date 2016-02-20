(*
   LIB-Places v2.0
   by Moose
 
   * Inspired by Deedlit's version and the MUSH/MUX version
 
   To setup, type:
    @register <program dbref>=Lib/Places
    @register <program dbref>=Cmd/Places
    @register <program dbref>=MPI/Places
    @set #0=/_MsgMacs/Places:{if:{:2},{muf:$MPI/Places,{:1}\,{:2}},{muf:$MPI/Places,{:1}}}
    @action places;place;tt;depart;join=#0
    @link tt=$Cmd/Places
 
   Standard desc MPI:
    {if:{places:0,count},{for:n,1,{places:0,count},1, {attr:bold,{places:{&n},name}:} {with:p,{commas:{places:{&n}},\, and },{attr:reset,{if:{&p},{&p},Nobody!}}}{nl}}} {attr:bold,Standing: } {with:p,{commas:{places:0},\, and },{attr:reset,{if:{&p},{&p},Nobody!}}}
 
   MPI Functions:
    {places}
      Returns a string list of all of the places in the room.
    {places:<#>}
      Returns a string list of all of the players in a given
      place, by name or number.  Here all of the names are listed.
    {places:<#>,match}
      Match a place name to a given number, if wished.
    {places:0,count}
      Number of places in the room.
    {places:<#>,<info>}
      Grabs a certain piece of info on room #.  Valid info
      names are:
         Name 
           - For the place name
         Users
           - For a string list of all the users' dbrefs.
         MaxUsers
           - For the maximum number of users
         NumUsers
           - For the current count of users
         LastMsgTime
           - Systime that the last message was sent as an integer
         NumOfMsgs
           - Number of messages sent in the place
 
   Public MUF functions:
    PLACES-match          [ ref:REFplace str:STRname                           -- int:INTplace ]
    PLACES-send-message   [ ref:REFplace int:INTplace str:STRmsg               -- ]
    PLACES-join           [ ref:REFplyr ref:REFplace int:INTplace              -- int:BOLnot_succ? ]
    PLACES-depart         [ ref:REFplyr ref:REFplace                           -- int:BOLnot_succ? ]
    PLACES-get-who        [ ref:REFplace int:INTplace                          -- arr:ARRplyr_list ]
    PLACES-get-place-info [ ref:REFplace int:INTplace                          -- dict:DICTplace_info ]
    PLACES-get-places     [ ref:REFplace                                       -- arr:ARRplace_list ]
    PLACES-place?         [ ref:REFplace int:INTplace                          -- int:BOLplace? ]
    PLACES-who            [ ref:REFplace int:INTplace                          -- ]
    PLACES-list           [ ref:REFplace                                       -- ]
    PLACES-talk           [ ref:REFplyr ref:REFplace str:STRmsg                -- ]
    PLACES-add            [ ref:REFplace str:STRplace int:INTmaxusers          -- ]
    PLACES-remove         [ ref:REFplace int:INTplace                          -- ]
    PLACES-set            [ ref:REFplace int:INTplace SETtoTHIS int:INTsetthis -- ]
 *)
 
$author      Moose
$version     2.0
$lib-version 2.0
 
(Time until the player is no longer considered in the place)
$def DEF-expire_time 600 (seconds)
 
: PLACES-Cycle-Users[ ref:REFplace int:INTplace -- ]
   VAR STRdir
   { }list
   REFplace @ "/@Places/" INTplace @ intostr strcat "/Users" strcat dup STRdir ! ARRAY_get_reflist
   FOREACH
      swap pop
      dup Ok? IF
         dup Player? over dup Thing? swap "ZOMBIE" Flag? and or IF
            dup location REFplace @ dbcmp IF
               dup Awake? not IF
                  dup timestamps pop rot rot pop pop DEF-expire_time > IF
                     pop CONTINUE
                  THEN
               THEN
               swap ARRAY_appenditem
            ELSE
               pop
            THEN
         ELSE
            pop
         THEN
      ELSE
         pop
      THEN
   REPEAT
   REFplace @ STRdir @ rot ARRAY_put_reflist
;
 
: PLACES-user-place[ ref:REFplyr arr:REFplace -- int:INTplace ]
   0
   REFplace @ "/@Places/" ARRAY_get_propdirs
   FOREACH
      swap pop
      REFplace @ "/@Places/" 3 pick strcat "/Users" strcat REFplyr @ REFLIST_find IF
         swap pop atoi BREAK
      ELSE
         pop
      THEN
   REPEAT
;
 
: PLACES-match[ ref:REFplace str:STRname -- int:INTplace ]
   STRname @ Number? IF
      REFplace @ "/@Places/" STRname @ strcat Propdir? IF
         STRname @ atoi
      ELSE
         0
      THEN
   ELSE
      0
      REFplace @ "/@Places/" ARRAY_get_propdirs
      FOREACH
         swap pop
         REFplace @ "/@Places/" 3 pick strcat "/Name" strcat getpropstr
         STRname @ stringcmp not IF
            swap pop atoi BREAK
         ELSE
            pop
         THEN
      REPEAT
   THEN
;
PUBLIC PLACES-match
$pubdef PLACES-match "$Lib/Places" match "PLACES-match" CALL
 
: PLACES-send-message[ ref:REFplace int:INTplace str:STRmsg -- ]
   VAR STRdir
   REFplace @ Room? not IF
      "That is not a room dbref (1)" abort
   THEN
   REFplace @ "/@Places/" INTplace @ intostr strcat dup STRdir ! Propdir? not IF
      pop "That place does not exist (2)" abort
   THEN
   REFplace @ INTplace @ PLACES-Cycle-Users
   {
      "^CNOTE^"
      REFplace @ STRdir @ "/Name" strcat getpropstr 1 escape_ansi strcat
      " ^NORMAL^(#" strcat INTplace @ intostr strcat ")^WHITE^> ^PLACES/SAY^" strcat
      STRmsg @ strcat
   }list
   REFplace @ STRdir @ "/Users" strcat ARRAY_get_reflist
   array_ansi_notify
   REFplace @ STRdir @ "/LastMsgTime" strcat systime setprop
   REFplace @ STRdir @ "/NumOfMsgs" strcat over over getpropval
   dup -1 = IF
      ++
   THEN
   ++ setprop
;
PUBLIC PLACES-send-message
$pubdef PLACES-send-message "$Lib/Places" match "PLACES-send-message" CALL
 
: PLACES-join[ ref:REFplyr ref:REFplace int:INTplace -- int:BOLnot_succ? ]
   VAR STRdir
   REFplace @ Room? not IF
      1 EXIT
   THEN
   REFplace @ "/@Places/" INTplace @ intostr strcat dup STRdir ! Propdir? not IF
      2 EXIT
   THEN
   REFplace @ INTplace @ PLACES-Cycle-Users
   REFplace @ STRdir @ "/Users" strcat REFplyr @ REFLIST_find IF
      3 EXIT
   THEN
   REFplyr @ REFplace @ PLACES-user-place IF
      4 EXIT
   THEN
   REFplace @ STRdir @ "/MaxUsers" strcat getpropval
   REFplace @ STRdir @ "/Users" strcat ARRAY_get_reflist ARRAY_count <= IF
      5 EXIT
   THEN
   REFplace @ STRdir @ "/Users" strcat REFplyr @ REFLIST_add
   REFplace @ INTplace @ REFplyr @ name 1 escape_ansi " joins the place." strcat
   "^PLACES/MOVE^" swap strcat PLACES-send-message
   REFplace @ #-1 REFplyr @ name 1 escape_ansi " joins place #%d: "
   INTplace @ intostr "%d" subst strcat
   REFplace @ STRdir @ "/Name" strcat getpropstr 1 escape_ansi strcat
   "^CMOVE^" swap strcat ansi_notify_except
   0
;
PUBLIC PLACES-join
$pubdef PLACES-join "$Lib/Places" match "PLACES-join" CALL
 
: PLACES-depart[ ref:REFplyr ref:REFplace -- int:BOLnot_succ? ]
   VAR STRdir VAR INTplace
   REFplace @ Room? not IF
      1 EXIT
   THEN
   me @ REFplace @ PLACES-user-place dup INTplace ! not IF
      2 EXIT
   THEN
   REFplace @ "/@Places/" INTplace @ intostr strcat dup STRdir ! Propdir? not IF
      3 EXIT
   THEN
   REFplace @ INTplace @ PLACES-Cycle-Users
   REFplace @ STRdir @ "/Users" strcat REFplyr @ REFLIST_find not IF
      4 EXIT
   THEN
   REFplace @ STRdir @ "/Users" strcat REFplyr @ REFLIST_del
   REFplace @ INTplace @ REFplyr @ name 1 escape_ansi " departs the place." strcat
   "^PLACES/MOVE^" swap strcat PLACES-send-message
   REFplace @ #-1 REFplyr @ name 1 escape_ansi " departs place #%d: "
   INTplace @ intostr "%d" subst strcat
   REFplace @ STRdir @ "/Name" strcat getpropstr 1 escape_ansi strcat
   "^CMOVE^" swap strcat ansi_notify_except
   0
;
PUBLIC PLACES-depart
$pubdef PLACES-depart "$Lib/Places" match "PLACES-depart" CALL
 
: PLACES-get-who[ ref:REFplace int:INTplace -- arr:ARRplyr_list ]
   VAR STRdir
   REFplace @ Room? not IF
      "Not a room dbref (1)" abort
   THEN
   INTplace @ IF
      REFplace @ "/@Places/" INTplace @ intostr strcat dup STRdir ! Propdir? not IF
         "There are no places there." abort
      THEN
      REFplace @ INTplace @ PLACES-Cycle-Users
      REFplace @ STRdir @ "/Users" strcat ARRAY_get_reflist
   ELSE
      { }list
      REFplace @ "/@Places/" ARRAY_get_propdirs
      FOREACH
         swap pop
         REFplace @ "/@Places/" rot strcat "/Users" strcat ARRAY_get_reflist
         ARRAY_union
      REPEAT
      REFplace @ CONTENTS_ARRAY ARRAY_diff
      { }list swap
      FOREACH
         swap pop
         dup Player? over dup Thing? swap "ZOMBIE" Flag? and or IF
            swap ARRAY_appenditem
         ELSE
            pop
         THEN
      REPEAT
   THEN
;
PUBLIC PLACES-get-who
$pubdef PLACES-get-who "$Lib/Places" match "PLACES-get-who" CALL
 
: PLACES-get-place-info[ ref:REFplace int:INTplace -- dict:DICTplace_info ]
   VAR STRdir
   REFplace @ Room? not IF
      "Not a room dbref (1)" abort
   THEN
   REFplace @ "@Places/" INTplace @ intostr strcat dup STRdir ! Propdir? NOT if
      { }dict EXIT
   THEN
   REFplace @ INTplace @ PLACES-Cycle-Users
   REFplace @ STRdir @ "/" strcat ARRAY_get_propvals
   REFplace @ STRdir @ "/Users" strcat ARRAY_get_reflist
   swap "Users" ARRAY_setitem
;
PUBLIC PLACES-get-place-info
$pubdef PLACES-get-place-info "$Lib/Places" match "PLACES-get-place-info" CALL
 
: PLACES-get-places[ ref:REFplace -- arr:ARRplace_list ]
   VAR STRdir
   REFplace @ Room? not IF
      "Not a room dbref (1)" abort
   THEN
   { }list
   REFplace @ "@Places" Propdir? not IF
      EXIT
   THEN
   REFplace @ "@Places/" ARRAY_get_propdirs
   FOREACH
      swap pop
      atoi REFplace @ swap PLACES-get-place-info
      swap ARRAY_appenditem
   REPEAT
;
PUBLIC PLACES-get-places
$pubdef PLACES-get-places "$Lib/Places" match "PLACES-get-places" CALL
 
: PLACES-place?[ ref:REFplace int:INTplace -- int:BOLplace? ]
   REFplace @ "/@Places/" INTplace @ intostr strcat Propdir?
;
PUBLIC PLACES-place?
$pubdef PLACES-place? "$Lib/Places" match "PLACES-place?" CALL
 
: ARRAY_name_join[ arr:ARRref_list str:STRstr str:STRend_str -- str:STRname_list ]
   VAR INTcount
   "" ARRref_list @ dup ARRAY_count -- INTcount !
   FOREACH
      swap INTcount @ = swap
      me @ over controls IF
         unparseobj 1 escape_ansi
         "(#" split "^YELLOW^(#" swap strcat strcat
      ELSE
         name 1 escape_ansi
      THEN
      rot dup IF
         rot IF
            STRend_str @
         ELSE
            STRstr @
         THEN
         strcat
      ELSE
         rot pop
      THEN
      swap strcat
   REPEAT
;
 
: PLACES-show-reflist[ arr:REFplace int:INTplace arr:ARRref_list -- ]
   ARRref_list @ dup ARRAY_count IF
      "^NORMAL^, ^WHITE^" "^NORMAL^, and ^WHITE^" ARRAY_name_join
   ELSE
      pop "^CFAIL^Nobody."
   THEN
   me @ "^CINFO^Players in place #%n [^BROWN^Name: %m / Max: %u]: ^WHITE^"
   REFplace @ "/@Places/" INTplace @ intostr strcat "/Name" strcat getpropstr
   1 escape_ANSI "%m" subst INTplace @ intostr "%n" subst rot strcat
   REFplace @ "/@Places/" INTplace @ intostr strcat "/MaxUsers" strcat getpropval
   intostr "%u" subst ansi_notify
;
 
: PLACES-who[ ref:REFplace int:INTplace -- ]
   REFplace @ INTplace @ over over PLACES-get-who PLACES-show-reflist
;
PUBLIC PLACES-who
$pubdef PLACES-who "$Lib/Places" match "PLACES-who" CALL
 
: PLACES-list[ ref:REFplace -- ]
   { }list
   REFplace @ "/@Places/" ARRAY_get_propdirs
   FOREACH
      swap pop atoi
      REFplace @ swap over over PLACES-get-who
      dup 5 rotate ARRAY_union -4 rotate
      PLACES-show-reflist
   REPEAT
   { }list
   REFplace @ CONTENTS_ARRAY
   FOREACH
      swap pop
      dup Player? over dup Thing? swap "ZOMBIE" Flag? and or not IF
         pop CONTINUE
      THEN
      3 pick over ARRAY_findval IF
         pop
      ELSE
         swap ARRAY_appenditem
      THEN
   REPEAT
   dup ARRAY_count IF
      "^NORMAL^, ^WHITE^" "^NORMAL^, and ^WHITE^" ARRAY_name_join
   ELSE
      pop "^CFAIL^Nobody."
   THEN
   me @ "^CINFO^Players standing around: ^WHITE^" rot strcat ansi_notify
;
PUBLIC PLACES-list
$pubdef PLACES-list "$Lib/Places" match "PLACES-list" CALL
 
: PLACES-Process-Quotes[ str:STRmsg -- str:STRmsg' ]
   0 VAR! QuotePos
   "" STRmsg @
   BEGIN
      dup "\"\"" instr over dup strlen swap "\"" rinstr = or WHILE
      "\"" "\"\"" subst
      dup strlen over "\"" rinstr = IF
         dup strlen -- strcut pop
      THEN
   REPEAT
   BEGIN
      dup "\"" instr WHILE
      "\"" split QuotePos @ IF
         "^PLACES/QUOTES^\"^PLACES/POSE^"
      ELSE
         "^PLACES/QUOTES^\"^PLACES/SAY^"
      THEN
      rot swap strcat swap strcat swap
      QuotePos @ not QuotePos !
   REPEAT
   strcat "^PLACES/POSE^" swap strcat
   QuotePos @ IF
      "^PLACES/QUOTES^\"" strcat
   THEN
;
 
: PLACES-talk[ ref:REFplyr ref:REFplace str:STRmsg -- ]
   VAR INTplace
   REFplyr @ REFplace @ PLACES-user-place dup INTplace ! not IF
      me @ "^CFAIL^You are not in any of the places." ansi_notify EXIT
   THEN
   STRmsg @ strip dup not IF
      pop me @ "^CFAIL^What do you wish to say there?" ansi_notify EXIT
   THEN
   REFplyr @ name 1 escape_ansi
   swap
   dup ":" instr 1 = over ";" instr 1 = or not IF
      dup dup strlen -- strcut swap pop
      dup "!" strcmp not IF
         pop " exclaims, \""
      ELSE
         dup "?" strcmp not IF
            pop " asks, \""
         ELSE
            "~" strcmp not IF
               " sings, \""
            ELSE
               " says, \""
            THEN
         THEN
      THEN
      swap 1 escape_ansi strcat strcat "\"" strcat
   ELSE
      1 strcut 1 escape_ansi swap ":" stringcmp not IF
         dup 1 strcut pop
         "-=\`/!?.,$#%*_+|[]()" swap instr not IF
            striplead " " swap strcat
         THEN
      THEN
      strcat
   THEN
   PLACES-Process-Quotes
   REFplace @ INTplace @ rot PLACES-send-message
;
PUBLIC PLACES-talk
$pubdef PLACES-talk "$Lib/Places" match "PLACES-talk" CALL
 
: PLACES-add[ ref:REFplace str:STRplace int:INTmaxusers -- ]
   VAR STRdir VAR STRnum
   STRplace @ strip STRplace !
   me @ REFplace @ controls not IF
      me @ "^CFAIL^" "noperm_mesg" sysparm 1 escape_ansi strcat ansi_notify EXIT
   THEN
   STRplace @ dup  "#" instr    over "^"  instr or over ":"  instr or
              over ";" instr or over "\[" instr or over "\r" instr or
              over "$" instr or over "*"  instr or over Number? or
              over "%" instr or swap not or IF
      me @ "^CFAIL^Cannot be a number nor give the characters: # ^^ : ; \\[ \\r % *" ansi_notify
      me @ "^CFAIL^Invalid name given for the place." ansi_notify
      EXIT
   THEN
   loc @ STRplace @ PLACES-match IF
      me @ "^CFAIL^That places already exists." ansi_notify EXIT
   THEN
   INTmaxusers @ 1 < IF
      me @ "^CFAIL^The maximum users must be greater than 1.  You can set it to a really high"
      "number if you want any amount of people there." strcat ansi_notify EXIT
   THEN
   0
   BEGIN
      ++
      REFplace @ "/@Places/" 3 pick intostr strcat Propdir? WHILE
   REPEAT
   intostr dup STRnum !
   "/@Places/" swap strcat STRdir !
   REFplace @ STRdir @ "/Name" strcat STRplace @ setprop
   REFplace @ STRdir @ "/MaxUsers" strcat INTmaxusers @ setprop
   REFplace @ STRdir @ "/LastMsgTime" strcat systime setprop
   REFplace @ STRdir @ "/NumOfMsgs" strcat -1 setprop
   me @ "^CSUCC^Place (#%d) added: %s (Max Users: %n)"
   STRnum @ "%d" subst STRplace @ 1 escape_ansi "%s" subst
   INTmaxusers @ intostr "%n" subst ansi_notify
;
PUBLIC PLACES-add
$pubdef PLACES-add "$Lib/Places" match "PLACES-add" CALL
 
: PLACES-remove[ ref:REFplace int:INTplace -- ]
   INTplace @ VAR! INTlast
   me @ REFplace @ controls not IF
      me @ "^CFAIL^" "noperm_mesg" sysparm 1 escape_ansi strcat ansi_notify EXIT
   THEN
   REFplace @ "/@Places/" INTplace @ intostr strcat Propdir? not IF
      me @ "^CFAIL^Invalid place number." ansi_notify EXIT
   THEN
   REFplace @ "/@Places/" ARRAY_get_propdirs
   FOREACH
      swap pop
      dup atoi dup INTlast @ > IF
         dup INTlast !
      THEN
      INTplace @ > IF
         REFplace @ "/@Places/" 3 pick strcat "/" strcat ARRAY_get_propvals
         REFplace @ "/@Places/" 4 pick atoi -- intostr strcat "/" strcat rot ARRAY_put_propvals
         REFplace @ "/@Places/" 3 rotate strcat remove_prop
      ELSE
         pop
      THEN
   REPEAT
   REFplace @ "/@Places/" INTlast @ intostr strcat remove_prop
   me @ "^CFAIL^Place removed." ansi_notify
;
PUBLIC PLACES-remove
$pubdef PLACES-remove "$Lib/Places" match "PLACES-remove" CALL
 
: PLACES-set[ ref:REFplace int:INTplace SETtoTHIS int:INTsetthis -- ]
   me @ REFplace @ controls not IF
      me @ "^CFAIL^" "noperm_mesg" sysparm 1 escape_ansi strcat ansi_notify EXIT
   THEN
   REFplace @ "/@Places/" INTplace @ intostr strcat Propdir? not IF
      me @ "^CFAIL^Invalid place number." ansi_notify EXIT
   THEN
   INTsetthis @ CASE
      1 = WHEN (name)
         SETtoTHIS @ String? not IF
            me @ "^CFAIL^You have to set the name to a string!" ansi_notify EXIT
         THEN
         SETtoTHIS @ dup  "#" instr    over "^"  instr or over ":"  instr or
                     over ";" instr or over "\[" instr or over "\r" instr or
                     over "$" instr or over "*"  instr or over Number? or
                     over "%" instr or swap not or IF
            me @ "^CFAIL^Cannot be a number nor give the characters: # ^^ : ; \\[ \\r % *" ansi_notify
            me @ "^CFAIL^Invalid name given for the place." ansi_notify
            EXIT
         THEN
         REFplace @ "/@Places/" INTplace @ intostr strcat SETtoTHIS @ strip setprop
         me @ "^CSUCC^Place(#%d)'s name set to: " INTplace @ intostr "%d" subst
         SETtoTHIS @ 1 escape_ansi strcat ansi_notify
      END
      2 = WHEN (maxusers)
         SETtoTHIS @ Int? not IF
            me @ "^CFAIL^You have to set the max users to an integer!" ansi_notify EXIT
         THEN
         SETtoTHIS @ 1 < IF
            me @ "^CFAIL^The maximum users must be greater than 1.  You can set it to a really high"
            "number if you want any amount of people there." strcat ansi_notify EXIT
         THEN
         REFplace @ "/@Places/" INTplace @ intostr strcat SETtoTHIS @ setprop
         me @ "^CSUCC^Place(#%d)'s max users set to: " SETtoTHIS @ intostr strcat
         INTplace @ intostr "%d" subst ansi_notify
      END
      DEFAULT pop
         me @ "^CFAIL^Set what?" ansi_notify EXIT
      END
   ENDCASE
;
PUBLIC PLACES-set
$pubdef PLACES-set "$Lib/Places" match "PLACES-set" CALL
 
: PLACES-help ( -- )
   {     (---\) prog "_Version" getpropstr strtof
      "^GREEN^Places v%1.2f by Moose" fmtstring
      "^PURPLE^~~~~~~~~~~~~~~~~~~~~~~~"
      " Places        ^WHITE^- List all of the places and who is there."
      " Places <#>    ^WHITE^- List who is in place #."
      " Join <#>      ^WHITE^- Join place #."
      " Depart        ^WHITE^- Depart your current place."
      " TT <msg>      ^WHITE^- Send a message to place #."
      " TT :<msg>     ^WHITE^- Pose a message to place #."
      " "
      "Options:"
      " #new <?>=<#>  ^WHITE^- New place, <?> is the name and <#> is the max users."
      " #rem <?/#>    ^WHITE^- Remove a place name or number."
      " #max <#>=<#>  ^WHITE^- Set a new maximum number of users for a place."
      " #name <#>=<?> ^WHITE^- Set a new name for a place."
      " #stats        ^WHITE^- Statistics and info on every place."
      " #help         ^WHITE^- This screen."
      "^CINFO^Done."
   }list
   { me @ }list array_ansi_notify
;
 
: main[ str:STRargs -- ]
   VAR INTnum
   #0 "/_/COLORS/PLACES" Propdir? not IF
      #0 "/_/COLORS/Places/Say"    "SAY/SAY" setprop
      #0 "/_/COLORS/Places/Quotes" "SAY/QUOTES" setprop
      #0 "/_/COLORS/Places/Pose"   "SAY/POSE" setprop
      #0 "/_/COLORS/Places/Move"   "CMOVE" setprop
   THEN
   command @ "(MPI)" instr IF
      trigger @ owner loc @ controls not IF
         "^CFAIL^Permission denied on {places} MPI." ansi_notify EXIT
      THEN
      STRargs @ strip dup IF
         "," split strip dup IF
            swap strip dup "0" stringcmp not IF
               pop dup "count" stringcmp not IF
                  loc @ "/@Places/" ARRAY_get_propdirs ARRAY_count intostr
               ELSE
                  dup "match" stringcmp not IF
                     pop "0"
                  ELSE
                     " is not a valid command for {places}" strcat abort
                  THEN
               THEN
            ELSE
               loc @ swap PLACES-match dup not IF
                  swap "match" stringcmp not IF
                     pop "0" EXIT
                  ELSE
                     pop "Invalid place in {places} MPI." abort
                  THEN
               THEN
               loc @ swap dup INTnum ! PLACES-get-place-info swap
               (s) CASE
                  "Name" stringcmp not WHEN
                     "Name" ARRAY_getitem dup String? not IF
                        pop ""
                     THEN
                  END
                  "MaxUsers" stringcmp not WHEN
                     "MaxUsers" ARRAY_getitem intostr
                  END
                  "LastMsgTime" stringcmp not WHEN
                     "LastMsgTime" ARRAY_getitem intostr
                  END
                  "NumOfMsgs" stringcmp not WHEN
                     "NumOfMsgs" ARRAY_getitem intostr
                  END
                  "NumUsers" WHEN
                     "Users" ARRAY_getitem ARRAY_count intostr
                  END
                  "Users" stringcmp not WHEN
                     "Users" ARRAY_getitem "\r" ARRAY_join
                  END
                  "Match" stringcmp not WHEN
                     INTnum @ intostr
                  END
                  DEFAULT
                     " is not a valid value for {places:<#>}" strcat abort
                  END
               ENDCASE
            THEN
         ELSE
            pop
            dup "0" stringcmp not IF
               atoi
            ELSE
               loc @ swap PLACES-match dup not IF
                  pop pop "Invalid place in {places} MPI." abort
               THEN
            THEN
            loc @ swap PLACES-get-who
            "" swap
            FOREACH
               swap pop
               name
               swap dup IF
                  "\r" strcat
               THEN
               swap strcat
            REPEAT
         THEN
      ELSE
         pop
         "" loc @ "/@Places/" ARRAY_get_propdirs
         FOREACH
            swap pop
            loc @ "/@Places/" rot strcat "/Name" strcat getpropstr
            swap dup IF
               "\r" strcat
            THEN
            swap strcat
         REPEAT
      THEN
      EXIT
   THEN
   STRargs @ strip "#" stringpfx IF
      STRargs @ strip 1 strcut swap pop " " split STRargs !
      (s) CASE
         "help" stringcmp not WHEN
            PLACES-help
         END
         "new"  stringcmp not WHEN
            STRargs @ "=" split strip atoi loc @ rot rot PLACES-add
         END
         "rem"  stringcmp not WHEN
            loc @ STRargs @ PLACES-match
            dup not IF
               pop me @ "^CFAIL^That place does not exist here." ansi_notify EXIT
            THEN
            loc @ swap PLACES-remove
         END
         "max"  stringcmp not WHEN
            "=" split strip atoi swap strip
            loc @ swap PLACES-match
            dup not IF
               pop pop me @ "^CFAIL^That place does not exist here." ansi_notify EXIT
            THEN
            loc @ rot rot 2 PLACES-set
         END
         "name" stringcmp not WHEN
            "=" split strip swap strip
            loc @ swap PLACES-match
            dup not IF
               pop pop me @ "^CFAIL^That place does not exist here." ansi_notify EXIT
            THEN
            loc @ rot rot 1 PLACES-set
         END
         DEFAULT
            "^CFAIL^#" swap 1 escape_ansi strcat " is not a valid parameter." strcat
            me @ swap ansi_notify
         END
      ENDCASE
      EXIT
   THEN
   command @ CASE
      "p" stringpfx WHEN (places/place)
         STRargs @ strip dup NOT IF
            pop loc @ PLACES-list EXIT
         THEN
         loc @ swap PLACES-match dup IF
            loc @ over PLACES-place? not IF
               me @ "^CFAIL^There is no place for that number." ansi_notify EXIT
            THEN
            loc @ swap PLACES-who EXIT
         THEN
         pop me @ "^CFAIL^What kind of place is that?" ansi_notify
      END
      "j" stringpfx WHEN (join)
         loc @ STRargs @ strip PLACES-match dup NOT if
            pop me @ "^CFAIL^You need to provide a valid place." ansi_notify EXIT
         THEN
         dup IF
            me @ loc @ rot PLACES-join dup IF
               (n) CASE
                  1 = WHEN
                     "^CFAIL^Places only works in a rooms, silly."
                  END
                  2 = WHEN
                     "^CFAIL^That place doesn't exist!"
                  END
                  3 = WHEN
                     "^CFAIL^You are already in that place."
                  END
                  3 = WHEN
                     "^CFAIL^You are already in another place."
                  END
                  5 = WHEN
                     "^CFAIL^There are too many players there."
                  END
               ENDCASE
               me @ swap ansi_notify
            ELSE
               pop me @ "^CSUCC^Successfully joined the place." ansi_notify
            THEN
            EXIT
         THEN
         pop me @ "^CFAIL^What kind of place is that?" ansi_notify
      END
      "d" stringpfx WHEN (depart)
         me @ loc @ PLACES-depart dup IF
            (n) CASE
               1 = WHEN
                  "^CFAIL^Places only works in a room, silly."
               END
               2 = WHEN
                  "^CFAIL^You aren't in any place."
               END
               3 = WHEN
                  "^CFAIL^That place doesn't exist!"
               END
               4 = WHEN
                  "^CFAIL^You are not in that place."
               END
            ENDCASE
            me @ swap ansi_notify
         ELSE
            pop me @ "^CSUCC^Successfully left the place." ansi_notify
         THEN
      END
      "t" stringpfx WHEN (tt)
         me @ loc @ STRargs @ strip PLACES-talk
      END
      DEFAULT pop
         me @ "^CFAIL^What kind of command is that?" ansi_notify
      END
   ENDCASE
;
