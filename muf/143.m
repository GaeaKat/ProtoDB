(*
   Cmd-Teleport
   by Moose
 *)
 
$author  Moose
$version 1.0
 
$include $Lib/Strings
$include $Lib/Puppet
 
$def PROPDIR-tel-alias     "/@/Teleport/Alias/"
$def PROPS-tel-allow       "/@/Teleport/Allow"
$def PROPS-tel-block       "/@/Teleport/Block"
$def PROPS-tel-allow-all?  "/@/Teleport/AllowAll?"
$def PROPS-tel-block-all?  "/@/Teleport/BlockAll?"
$def PROPS-tel-arrive      "/_Teleport/Arrive"
$def PROPS-tel-oarrive     "/_Teleport/oArrive"
$def PROPS-tel-depart      "/_Teleport/Depart"
$def PROPS-tel-odepart     "/_Teleport/oDepart"
$def PROPS-tel-no-in-mesg  "/_Teleport/NoInMesg"
$def PROPS-tel-no-out-mesg "/_Teleport/NoOutMesg"
$def PROPS-tel-can-tel?    "/@/Teleport/CannotTeleport?"
$def PROPS-tel-to-player?  "/@/Teleport/CannotTelToPlayer?"
$def PROPS-tel-no-global?  "/@/Teleport/CannotUseNonGlobalAlias?"
$def PROPS-tel-no-out?     "/@/Teleport/BlockTelOut?"
 
$def atell me @ swap ansi_notify
 
: ansi_unparseobj_skip_perm ( ref:ref -- str:strref )
   dup Room? IF
      "^CYAN^"
   ELSE
      dup Player? IF
         "^GREEN^"
      ELSE
         "^PURPLE^"
      THEN
   THEN
   swap unparseobj 1 escape_ansi strcat "(#" rsplit
   "^YELLOW^(#" swap strcat strcat
;
 
: ansi_unparseobj ( ref:ref -- str:strref )
   dup #-3 dbcmp IF
      pop "^RED^All" EXIT
   THEN
   dup ansi_unparseobj_skip_perm
   me @ rot dup controls swap "LINK_OK" Flag? or not IF
      "^YELLOW^(#" split pop
   THEN
;
 
: TEL-list-alias[ int:INTglobal? -- ]
   VAR ref
   INTglobal? @ IF
      "^CYAN^Teleport Global Alias List" atell
      "^PURPLE^=================================================" atell
      #0
   ELSE
      "^CYAN^Teleport Alias List" atell
      "^PURPLE^=================================================" atell
      #0   PROPS-tel-no-global? getpropstr strip 1 strcut pop "n" stringcmp not
      me @ owner PROPS-tel-no-global? getpropstr strip 1 strcut pop "n" stringcmp not or IF
         "^CFAIL^You cannot use any of your personal alias'." atell
      THEN
      me @ owner
   THEN
   dup ref ! PROPDIR-tel-alias ARRAY_get_propvals { }dict swap
   FOREACH
      dup Room? IF
         over over
         ansi_unparseobj "^YELLOW^ = " swap strcat
         swap 1 escape_ansi swap strcat "^GREEN^" swap strcat atell
         rot rot ARRAY_setitem
      ELSE
        pop pop
      THEN
   REPEAT
   ref @ PROPDIR-tel-alias over over
   dup strlen 1 - strcut pop remove_prop
   rot ARRAY_put_propvals
   me @ "^CINFO^Done." ansi_notify
;
 
: TEL-show-perms[ ref:ref str:STRprop str:STRprestr -- ]
   ref @ STRprop @ ARRAY_get_reflist 0 VAR! INTcount
   "" { }list rot
   FOREACH
      swap pop
      dup Player? over Thing? 3 pick "ZOMBIE" Flag? and or not IF
         pop CONTINUE
      THEN
      dup ansi_unparseobj
      rot rot swap ARRAY_appenditem
      rot INTcount dup @ swap ++ 0 > IF
         "^NORMAL^, " strcat
      THEN
      rot strcat swap
   REPEAT
   ref @ STRprop @ rot ARRAY_put_reflist
   dup IF
      "^GREEN^" STRprestr @ strcat swap strcat atell
   ELSE
      pop
   THEN
;
 
: TEL-list-perms[ -- ]
   VAR INTcount
   me @ owner me !
   "^PURPLE^=================================================" atell
   me @ "^CINFO^Your permissions:" ansi_notify
   me @ PROPS-tel-allow-all? getpropstr "y" stringpfx IF
      "^GREEN^Allowing: ^YELLOW^*ALL*" atell
   ELSE
      me @ PROPS-tel-allow getpropstr IF
         me @ PROPS-tel-allow "Allowing: " TEL-show-perms
      THEN
      me @ PROPS-tel-block-all? getpropstr "y" stringpfx IF
         "^GREEN^Blocking: ^YELLOW^*ALL*" atell
      ELSE
         me @ PROPS-tel-block "Blocking: " TEL-show-perms
      THEN
   THEN
   "^FOREST^Can teleport at all? -------------> "
   me @ PROPS-tel-can-tel? getpropstr strip 1 strcut pop "n" stringcmp not IF
      "^CFAIL^No"
   ELSE
      "^CSUCC^Yes"
   THEN
   strcat atell
   "^FOREST^Can teleport to players? ---------> "
   me @ PROPS-tel-to-player? getpropstr strip 1 strcut pop "n" stringcmp not IF
      "^CFAIL^No"
   ELSE
      "^CSUCC^Yes"
   THEN
   strcat atell
   "^FOREST^Can teleport using personal alias'? "
   me @ PROPS-tel-no-global? getpropstr strip 1 strcut pop "n" stringcmp not IF
      "^CFAIL^No"
   ELSE
      "^CSUCC^Yes"
   THEN
   strcat atell
   me @ loc @ controls IF
      "^PURPLE^=================================================" atell
      me @ "^CINFO^Room permissions:" ansi_notify
      loc @ PROPS-tel-allow-all? getpropstr "y" stringpfx IF
         "^GREEN^Allowing: ^YELLOW^*ALL*" atell
      ELSE
         loc @ PROPS-tel-allow getpropstr IF
            loc @ PROPS-tel-allow "Allowing: " TEL-show-perms
         THEN
         loc @ PROPS-tel-block-all? getpropstr "y" stringpfx IF
            "^GREEN^Blocking: ^YELLOW^*ALL*" atell
         ELSE
            loc @ PROPS-tel-block "Blocking: " TEL-show-perms
         THEN
      THEN
      "^FOREST^You can teleport out here? -------> "
      loc @ PROPS-tel-no-out? getpropstr strip 1 strcut pop "y" stringcmp not IF
         "^RED^No"
      ELSE
         "^GREEN^Yes"
      THEN
      strcat atell
   THEN
   "^PURPLE^=================================================" atell
   me @ "^CINFO^Global permissions:" ansi_notify
   "^FOREST^Can teleport at all? -------------> "
   #0 PROPS-tel-can-tel? getpropstr strip 1 strcut pop "n" stringcmp not IF
      "^CFAIL^No"
   ELSE
      "^CSUCC^Yes"
   THEN
   strcat atell
   "^FOREST^Can teleport to players? ---------> "
   #0 PROPS-tel-to-player? getpropstr strip 1 strcut pop "n" stringcmp not IF
      "^CFAIL^No"
   ELSE
      "^CSUCC^Yes"
   THEN
   strcat atell
   "^FOREST^Can teleport using personal alias'? "
   #0 PROPS-tel-no-global? getpropstr strip 1 strcut pop "n" stringcmp not IF
      "^CFAIL^No"
   ELSE
      "^CSUCC^Yes"
   THEN
   strcat atell
   me @ "^CINFO^Done." ansi_notify
;
 
: TEL-perm[ str:STRplyrs int:BOLallow? int:BOLadd? int:BOLtome? -- ]
   0 VAR! INTcount VAR STRprop VAR STRprop2 VAR ref 0 VAR! DidAll? VAR tempref
   me @ owner me !
   BOLtome? @ dup not swap 2 = or IF
      me @ loc @ controls not IF
         me @ "^CFAIL^" "noperm_mesg" sysparm 1 escape_ansi
         strcat ansi_notify EXIT
      THEN
   THEN
   BOLtome? @ 2 = IF
      BOLallow? @ IF
         loc @ PROPS-tel-no-out? getpropstr strip 1 strcut pop "y" stringcmp not IF
            loc @ PROPS-tel-no-out? remove_prop
            "^CSUCC^Players can teleport out again."
         ELSE
            "^CFAIL^Players can already teleport out."
         THEN
      ELSE
         loc @ PROPS-tel-no-out? getpropstr strip 1 strcut pop "y" stringcmp not IF
            "^CFAIL^Players allready cannot teleport out."
         ELSE
            loc @ PROPS-tel-no-out? "yes" setprop
            "^CSUCC^Players cannot teleport out."
         THEN
      THEN
      atell EXIT
   THEN
   STRplyrs @ strip dup STRplyrs ! not IF
      me @ "^CFAIL^Incorrect syntax." ansi_notify
      me @ "^CYAN^Syntax: ^AQUA^Tel #%c <player/puppet>"
      BOLallow? @ IF
         BOLadd? @ IF
            "allow"
         ELSE
            "unallow"
         THEN
      ELSE
         BOLtome? @ IF
            BOLadd? @ IF
               "blockme"
            ELSE
               "allowme"
            THEN
         ELSE
            BOLadd? @ IF
               "block"
            ELSE
               "unblock"
            THEN
         THEN
      THEN
      "%c" subst ansi_notify EXIT
   THEN
   BOLtome? @ IF
      me @
   ELSE
      loc @
   THEN
   ref !
   BOLallow? @ IF
      PROPS-tel-allow PROPS-tel-allow-all?
   ELSE
      PROPS-tel-block PROPS-tel-block-all?
   THEN
   STRprop2 ! STRprop ! "" { }list STRplyrs @ " " EXPLODE_ARRAY
   FOREACH
      swap pop
      dup "all" stringcmp not IF
         pop #-3
      ELSE
         dup dup strip IF
            pmatch
         ELSE
            pop #-4
         THEN
         dup #-2 dbcmp over Ok? or not IF
            pop dup puppet_match
         THEN
         dup #-2 dbcmp IF
            pop me @ "^CINFO^I don't know which " rot strcat
            " you mean!" strcat ansi_notify CONTINUE
         THEN
         dup #-4 dbcmp IF
            pop pop me @ "^CINFO^You need to enter a player name or 'all'!"
            ansi_notify CONTINUE
         THEN
         dup Ok? not IF
            pop me @ "^CINFO^I cannot find " rot strcat
            " here." strcat ansi_notify CONTINUE
         ELSE
            owner
         THEN
         swap pop
      THEN
      dup #-3 dbcmp IF
         ref @ STRprop2 @ getpropstr 1 strcut pop "y" stringcmp not
         BOLadd? @ IF
            IF
               pop "^CFAIL^Everbody is already allowed." atell
               CONTINUE
            THEN
         ELSE
            not IF
               pop "^CFAIL^The all setting wasn't set." atell
               CONTINUE
            THEN
         THEN
      ELSE
         ref @ STRprop @ 3 pick REFLIST_find
         BOLadd? @ IF
            IF
               "^CFAIL^" swap ansi_unparseobj strcat
               " ^CFAIL^is already there." strcat atell
               CONTINUE
            THEN
         ELSE
            not IF
               "^CFAIL^" swap ansi_unparseobj strcat
               " ^CFAIL^isn't there." strcat atell
               CONTINUE
            THEN
         THEN
      THEN
      dup ansi_unparseobj
      4 rotate INTcount dup @ swap ++ 0 > IF
         "^FOREST^, " strcat
      THEN
      swap strcat -3 rotate
      dup #-3 dbcmp IF
         pop
         BolAdd? @ IF
            ref @ STRprop2 @ "yes" setprop
         ELSE
            ref @ STRprop2 @ remove_prop
         THEN
         1 DidAll? !
      ELSE
         swap ARRAY_appenditem
      THEN
   REPEAT
   DidAll? @ IF
      BOLadd? @ IF
         "^CSUCC^All users set."
      ELSE
         "^CSUCC^All users removed."
      THEN
      atell
   THEN
   dup ARRAY_count not IF
      pop pop
      DidAll? @ not IF
         "^CFAIL^No players to do that upon." atell
      THEN
      EXIT
   THEN
   ref @ STRprop @ over over ARRAY_get_reflist 4 rotate swap
   BOLadd? @ if
      ARRAY_union ARRAY_put_reflist
      " ^FOREST^added." STRprop !
   ELSE
      ARRAY_diff ARRAY_put_reflist
      " ^FOREST^removed." STRprop !
   THEN
   me @ swap "^FOREST^, " rsplit dup IF "^FOREST^, and " swap strcat strcat ELSE pop THEN
   STRprop @ strcat atell
;
 
: TEL-alias[ str:STRalias int:BOLglobal? int:BOLadd? -- ]
   VAR ref VAR STRmsg
   me @ owner me !
   STRalias @ dup ":" instr over "/" instr or over "^" instr or
   over "\[" instr or over strip not or IF
      me @ "^CFAIL^Invalid alias." ansi_notify EXIT
   THEN
   BOLglobal? @ IF
      me @ "WIZARD" Flag? not IF
         me @ "^CFAIL^" "noperm_mesg" sysparm 1 escape_ansi strcat
         ansi_notify EXIT
      THEN
      #0
   ELSE
      me @
   THEN
   ref !
   loc @ Room? not IF
      me @ "^CFAIL^You can only alias a room, sorry." ansi_notify EXIT
   THEN
   me @ ref @ controls ref @ "LINK_OK" Flag? or not IF
      me @ "^CFAIL^" "noperm_mesg" sysparm 1 escape_ansi strcat
      ansi_notify EXIT
   THEN
   ref @ PROPDIR-tel-alias STRalias @ strcat getprop
   dup String? IF
      stod
   THEN
   dup Dbref? not IF
      pop #-1
   THEN
   dup Ok? IF
      dup Room? IF
         ansi_unparseobj
      ELSE
         pop "^NORMAL^(Nothing)"
      THEN
   ELSE
      pop "^NORMAL^(Nothing)"
   THEN
   BOLglobal? @ IF
      "^FOREST^[GLOBAL] "
   ELSE
      ""
   THEN
   "^GREEN^" STRalias @ 1 escape_ansi strcat strcat dup STRmsg !
   " was previously aliased to: "
   rot strcat strcat
   atell
   STRmsg @ " is now aliased to: " strcat
   ref @ PROPDIR-tel-alias STRalias @ strcat
   BOLadd? @ IF
      loc @ setprop
      loc @ ansi_unparseobj_skip_perm
   ELSE
      remove_prop
      "^NORMAL^(Nothing)"
   THEN
   strcat atell
;
 
: TEL-help[ int:INThelp -- ]
   {
   INThelp @ CASE
      1 = WHEN
         prog "_Version" getpropstr strtof
         "^CYAN^Teleport v%1.2f - by Moose" FMTstring
         "^PURPLE^~~~~~~~~~~~~~~~~~~~~~~~~~~~"
         "Tel <location>     ^WHITE^- Teleport to a location."
         "Tel <player>       ^WHITE^- Teleport to a player."
         "Tel <alias/global> ^WHITE^- Teleport to an alias or global."
         "Tel #HELP          ^WHITE^- This screen."
         "Tel #ALIAS <?>     ^WHITE^- Set an alias for this room."
         "Tel #UNALIAS <?>   ^WHITE^- Unset an alias."
        me @ "WIZARD" Flag? IF
         "Tel #GLOBAL <?>    ^WHITE^- Set a global alias for this room."
         "Tel #REMGLOBAL <?> ^WHITE^- Unset a global alias."
        THEN
         "Tel #ALLOW <?>     ^WHITE^- Always allow a player (or 'all') in"
         "                     ^WHITE^this room."
         "Tel #UNALLOW <?>   ^WHITE^- Remove the #allow setting for a player"
         "                     ^WHITE^(or 'all')."
         "Tel #BLOCK <?>     ^WHITE^- Always block a player (or 'all')in"
         "                     ^WHITE^this room."
         "Tel #UNBLOCK <?>   ^WHITE^- Remove the #block setting for a player"
         "                     ^WHITE^(or 'all')."
         "^WHITE^Tel #HELP2 --> For second Page."
         "^CINFO^Done."
      END
      2 = WHEN
         prog "_Version" getpropstr strtof
         "^CYAN^Teleport v%1.2f - by Moose" FMTstring
         "^PURPLE^~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        me @ "WIZARD" Flag? IF
         "Tel #RESTRICT <?>  ^WHITE^- Edit global restrict settings for a"
         "                     ^WHITE^player."
         "Tel #RESTRICT #ALL ^WHITE^- Edit global resitrct settings for all"
         "                     ^WHITE^players."
        THEN
         "Tel #BLOCKME <?>   ^WHITE^- Prevents a player (or 'all') from"
         "                     ^WHITE^teleporting to you directly."
         "Tel #ALLOWME <?>   ^WHITE^- Allows a player (or 'all') to teleport"
         "                     ^WHITE^to you again."
         "Tel #BLOCKOUT      ^WHITE^- Block all outbound teleportations here."
         "Tel #ALLOWOUT      ^WHITE^- Re-allow all outbound teleportations here."
         "Tel #PERMS         ^WHITE^- List the permissions for yourself and"
         "                     ^WHITE^the room (if you own it)."
         "Tel #ALIASLIST     ^WHITE^- List your teleport alias'."
         "Tel #GLIST         ^WHITE^- List the global alias'."
         "Tel #PROPS         ^WHITE^- Properties used for this program."
         "^CINFO^Done."
      END
      DEFAULT pop
         "^CFAIL^That help screen is unavailable."
      END
   ENDCASE
   }list
   { me @ }list array_ansi_notify
;
 
: TEL-props[ int:INTprops -- ]
   {
   INTprops @ CASE
      1 = WHEN
         prog "_Version" getpropstr strtof
         "^CYAN^Teleport v%1.2f - by Moose" FMTstring
         "^PURPLE^~~~~~~~~~~~~~~~~~~~~~~~~~~~"
         PROPS-tel-arrive 20 STRleft
           " ^WHITE^- What you see when you teleport in." strcat
         PROPS-tel-oarrive 20 STRleft
           " ^WHITE^- What others see when you teleport in." strcat
         PROPS-tel-depart 20 STRleft
           " ^WHITE^- What you see when you teleport out." strcat
         PROPS-tel-odepart 20 STRleft
           " ^WHITE^- What others see when you teleport out." strcat
         PROPS-tel-no-in-mesg 20 STRleft
           " ^WHITE^- Shown to someone blocked from teleporting in." strcat
         "" 25 STRleft "   ^WHITE^(Only settable on the room)" strcat
         PROPS-tel-no-out-mesg 20 STRleft
           " ^WHITE^- Shown to someone blocked from teleporting out." strcat
         "" 25 STRleft "   ^WHITE^(Only settable on the room)" strcat
         "^CINFO^Done."
      END
      DEFAULT pop
         "^CFAIL^That properties screen is unavailable."
      END
   ENDCASE
   }list
   { me @ }list array_ansi_notify
;
 
: TEL-goto[ str:STRgoto -- ]
   VAR ref
   me @ owner PROPS-tel-can-tel? getpropstr strip 1 strcut pop "n" stringcmp not
   #0   PROPS-tel-can-tel? getpropstr strip 1 strcut pop "n" stringcmp not or
   me @ owner "WIZARD" Flag? not and IF
      "^CFAIL^You do not have permission to teleport." atell EXIT
   THEN
   loc @ PROPS-tel-no-out? getpropstr strip 1 strcut pop "y" stringcmp not IF
      loc @ PROPS-tel-no-out-mesg envpropstr dup strip IF
         "(teleport)" 0 parsempi
      ELSE
         pop pop ""
      THEN
      dup strip IF
         "^CMOVE^" swap strcat
      ELSE
         pop "^CFAIL^You cannot teleport out from here."
      THEN
      atell EXIT
   THEN
   STRgoto @ dup "$" stringpfx IF
      match
   ELSE
      dup "#" stringpfx IF
         dup 1 strcut swap pop Number?
      ELSE
         0
      THEN
      IF
         stod
      ELSE
         dup ":" instr over "\r" instr or over "\[" instr or not IF
            me @ owner PROPS-tel-no-global? getpropstr strip 1 strcut pop "n" stringcmp not
            #0   PROPS-tel-no-global? getpropstr strip 1 strcut pop "n" stringcmp not or
            me @ owner "WIZARD" Flag? not and IF
               #-1 0
            ELSE
               me @ owner PROPDIR-tel-alias 3 pick strcat getprop dup Dbref?
            THEN
            IF
               1
            ELSE
               pop #0 PROPDIR-tel-alias 3 pick strcat getprop dup Dbref?
            THEN
         ELSE
            #-1 0
         THEN
         not IF
            pop
            me @ owner PROPS-tel-to-player? getpropstr strip 1 strcut pop "n" stringcmp not
            #0   PROPS-tel-to-player? getpropstr strip 1 strcut pop "n" stringcmp not or
            me @ owner "WIZARD" Flag? not and IF
               pop #-1
            ELSE
               dup pmatch dup #-1 dbcmp IF
                  pop PUPPET_match
               ELSE
                  swap pop
               THEN
            THEN
         ELSE
            swap pop
         THEN
      THEN
   THEN
   dup Ok? not IF
      #-2 dbcmp IF
         "^CINFO^I don't know which one you mean!"
      ELSE
         "^CINFO^I cannot find that here!"
      THEN
      atell EXIT
   THEN
   dup Player? over Thing? or IF
      dup owner dup
      PROPS-tel-block me @ owner REFLIST_find
      swap PROPS-tel-block-all? getpropstr strip 1 strcut pop "y" stringcmp not or IF
         pop "^CFAIL^You cannot teleport to them." atell EXIT
      THEN
      dup Thing? over "VEHICLE" Flag? and not IF
         location
      THEN
   THEN
   ref !
   ref @ Room? ref @ dup Thing? swap "VEHICLE" Flag? and or not IF
      "^CFAIL^Invalid destination." atell EXIT
   THEN
   ref @ loc @ dbcmp IF
      "^CFAIL^You are already there!" atell EXIT
   THEN
   ref @ PROPS-tel-allow-all? getpropstr strip 1 strcut pop "y" stringcmp not
   ref @ PROPS-tel-allow me @ owner REFLIST_find or
   me @ ref @ controls or not IF
      ref @ PROPS-tel-block-all? getpropstr strip 1 strcut pop "y" stringcmp not
      ref @ PROPS-tel-block me @ owner REFLIST_find or IF
         ref @ PROPS-tel-no-in-mesg envpropstr swap pop dup strip IF
            "^CMOVE^" swap strcat
         ELSE
            pop "^CFAIL^You cannot teleport to them."
         THEN
         atell EXIT
      THEN
   THEN
   me @ ref @ Locked? IF
      "^CFAIL^You are locked from that room." atell EXIT
   THEN
   loc @ PROPS-tel-depart "(teleport)" 0 parseprop dup strip not IF
      pop me @ PROPS-tel-depart "(teleport)" 0 parseprop
   THEN
   dup strip IF
      "^CMOVE^" swap 1 escape_ansi strcat
      dup "%n" instr over "%N" instr or over me @ name instr or not IF
         me @ name " " strcat swap strcat
      THEN
      me @ swap pronoun_sub atell
   ELSE
      pop
   THEN
   loc @ PROPS-tel-odepart "(teleport)" 1 parseprop dup strip not IF
      pop me @ PROPS-tel-odepart "(teleport)" 0 parseprop
   THEN
   dup strip IF
      "^CMOVE^" swap 1 escape_ansi strcat
      dup "%n" instr over "%N" instr or over me @ name instr or not IF
         me @ name " " strcat swap strcat
      THEN
      me @ swap pronoun_sub loc @ me @ rot ansi_notify_except
   ELSE
      pop
   THEN
   me @ ref @ moveto
   ref @ PROPS-tel-arrive "(teleport)" 0 parseprop dup strip not IF
      pop me @ PROPS-tel-arrive "(teleport)" 0 parseprop
   THEN
   dup strip IF
      "^CMOVE^" swap 1 escape_ansi strcat
      dup "%n" instr over "%N" instr or over me @ name instr or not IF
         me @ name " " strcat swap strcat
      THEN
      me @ swap pronoun_sub atell
   ELSE
      pop
   THEN
   ref @ PROPS-tel-oarrive "(teleport)" 1 parseprop dup strip not IF
      pop me @ PROPS-tel-oarrive "(teleport)" 1 parseprop
   THEN
   dup strip IF
      "^CMOVE^" swap 1 escape_ansi strcat
      dup "%n" instr over "%N" instr or over me @ name instr or not IF
         me @ name " " strcat swap strcat
      THEN
      me @ swap pronoun_sub ref @ me @ rot ansi_notify_except
   ELSE
      pop
   THEN
;
 
: TEL-restrict[ ref:ref -- ]
   me @ "WIZARD" Flag? not IF
      me @ "^CFAIL^" "noperm_mesg" sysparm 1 escape_ansi strcat ansi_notify EXIT
   THEN
   ref @ Player? ref @ #0 dbcmp or not IF
      "^CFAIL^That is not a player nor global restriction option." atell EXIT
   THEN
   BEGIN
      {
      ref @ Player? IF
         ref @ ansi_unparseobj "^CYAN^'s Restrictions Setup" strcat
         "^PURPLE^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
         "^CYAN^1^AQUA^) Allowed to teleport to Players?           "
           ref @ PROPS-tel-to-player? getpropstr strip 1 strcut pop "n" stringcmp not IF
              "^RED^No"
           ELSE
              "^GREEN^Yes"
           THEN
           strcat
         "^CYAN^2^AQUA^) Allowed to teleport to Non-Global Alias'? "
           ref @ PROPS-tel-no-global? getpropstr strip 1 strcut pop "n" stringcmp not IF
              "^RED^No"
           ELSE
              "^GREEN^Yes"
           THEN
           strcat
         "^CYAN^3^AQUA^) Allowed to teleport at all?               "
           ref @ PROPS-tel-can-tel? getpropstr strip 1 strcut pop "n" stringcmp not IF
              "^RED^No"
           ELSE
              "^GREEN^Yes"
           THEN
           strcat
      ELSE
         "^CYAN^Global Restrictions Setup"
         "^PURPLE^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
         "^CYAN^1^AQUA^) Can teleport to Players?                  "
           ref @ PROPS-tel-to-player? getpropstr strip 1 strcut pop "n" stringcmp not IF
              "^RED^No"
           ELSE
              "^GREEN^Yes"
           THEN
           strcat
         "^CYAN^2^AQUA^) Can teleport to Non-Global Alias'?        "
           ref @ PROPS-tel-no-global? getpropstr strip 1 strcut pop "n" stringcmp not IF
              "^RED^No"
           ELSE
              "^GREEN^Yes"
           THEN
           strcat
         "^CYAN^3^AQUA^) Can teleport at all?                      "
           ref @ PROPS-tel-can-tel? getpropstr strip 1 strcut pop "n" stringcmp not IF
              "^RED^No"
           ELSE
              "^GREEN^Yes"
           THEN
           strcat
      THEN
      "^CYAN^Q^AQUA^) Quit and exit this editor."
      " "
      "^AQUA^Enter your choice [^CYAN^1^AQUA^,^CYAN^2^AQUA^,^CYAN^3^AQUA^,^CYAN^Q^AQUA^]:"
      }list
      { me @ }list array_ansi_notify 0
      BEGIN
         pop READ
         { "1" "2" "3" "Q" }list
         over ARRAY_findval ARRAY_count IF
            BREAK
         THEN
         "^CFAIL^Invalid option." atell
         "^AQUA^Enter your choice [^CYAN^1^AQUA^,^CYAN^2^AQUA^,^CYAN^3^AQUA^,^CYAN^Q^AQUA^]:" atell
      REPEAT
      (s) CASE
         "1" stringcmp not WHEN
            "^CSUCC^Toggled." atell
            ref @ PROPS-tel-to-player? over over getpropstr strip 1 strcut pop "n"stringcmp not IF
               remove_prop
            ELSE
               "no" setprop
            THEN
         END
         "2" stringcmp not WHEN
            "^CSUCC^Toggled." atell
            ref @ PROPS-tel-no-global? over over getpropstr strip 1 strcut pop "n" stringcmp not IF
               remove_prop
            ELSE
               "no" setprop
            THEN
         END
         "3" stringcmp not WHEN
            "^CSUCC^Toggled." atell
            ref @ PROPS-tel-can-tel? over over getpropstr strip 1 strcut pop "n" stringcmp not IF
               remove_prop
            ELSE
               "no" setprop
            THEN
         END
         "Q" stringcmp not WHEN
            "^CSUCC^Quitting the editor." atell EXIT
         END
         DEFAULT pop
            "^CFAIL^Invalid option." atell
         END
      ENDCASE
   REPEAT
;
 
: main[ str:STRargs -- ]
   VAR STRargs2
   STRargs @ strip dup STRargs ! not IF
      "#help" STRargs !
   THEN
   STRargs @ striplead "#" stringpfx IF
      STRargs @ strip 1 strcut swap pop Number? not
   ELSE
      0
   THEN
   IF
      STRargs @ striplead " " split STRargs2 !
      (option) CASE
         "#help" stringpfx WHEN
            STRargs @ striplead 5 strcut swap pop strip atoi dup 0 = IF
               pop 1
            THEN
            TEL-help
         END
         "#props" stringpfx WHEN
            STRargs @ striplead 6 strcut swap pop strip atoi dup 0 = IF
               pop 1
            THEN
            TEL-props
         END
         "#alias" stringcmp not WHEN
            STRargs2 @ 0 1 TEL-alias
         END
         "#unalias" stringcmp not WHEN
            STRargs2 @ 0 0 TEL-alias
         END
         "#remalias" stringcmp not WHEN
            STRargs2 @ 0 0 TEL-alias
         END
         "#allow" stringcmp not WHEN
            STRargs2 @ 1 1 0 TEL-perm
         END
         "#block" stringcmp not WHEN
            STRargs2 @ 0 1 0 TEL-perm
         END
         "#unallow" stringcmp not WHEN
            STRargs2 @ 1 0 0 TEL-perm
         END
         "#unblock" stringcmp not WHEN
            STRargs2 @ 0 0 0 TEL-perm
         END
         "#global" stringcmp not WHEN
            STRargs2 @ 1 1 TEL-alias
         END
         "#remglobal" stringcmp not WHEN
            STRargs2 @ 1 0 TEL-alias
         END
         "#restrict" stringcmp not WHEN
            STRargs2 @ strip dup "#all" stringcmp not IF
               pop #0 TEL-restrict
            ELSE
               dup strip IF pmatch ELSE pop #-3 THEN
               dup Ok? IF
                  dup #0 dbcmp not IF owner THEN TEL-restrict
               ELSE
                  dup #-3 dbcmp IF
                     pop "^CINFO^You need to enter a player name or #all."
                  ELSE
                     #-2 dbcmp IF
                        "^CINFO^I don't know which player you mean!"
                     ELSE
                        "^CINFO^I cannot find that player."
                     THEN
                  THEN
                  atell
               THEN
            THEN
         END
         "#blockout" stringcmp not WHEN
            STRargs2 @ 0 0 2 TEL-perm
         END
         "#allowout" stringcmp not WHEN
            STRargs2 @ 1 0 2 TEL-perm
         END
         "#blockme" stringcmp not WHEN
            STRargs2 @ 0 1 1 TEL-perm
         END
         "#allowme" stringcmp not WHEN
            STRargs2 @ 0 0 1 TEL-perm
         END
         "#perms" stringcmp not WHEN
            TEL-list-perms
         END
         "#aliaslist" stringcmp not WHEN
            0 TEL-list-alias
         END
         "#glist" stringcmp not WHEN
            1 TEL-list-alias
         END
         DEFAULT pop
            me @ "^CFAIL^What kind of command is that?" ansi_notify
         END
      ENDCASE
   ELSE
      STRargs @ TEL-goto
   THEN
;
