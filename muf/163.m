(*
   Cmd-WizList
   by Moose
 
   [ Includes capability for any kind of list, default is all set TRUEWIZARD ]
 *)
 
$author  Moose
$version 1.0
 
$include $lib/strings
$include $lib/time
 
: Online?[ ref:ref -- int:count ]
   VAR CURtime
   ref @ Awake? IF
      ref @ "DARK" Flag?
      ref @ "HIDDEN" Flag? OR not
      ref @ "LIGHT" Flag? OR
   ELSE
      0
   THEN
   IF
      ref @ descrleastidle descridle
   ELSE
      -1
   THEN
;
 
: WIZLIST-get_all_flag[ str:STRflag int:INTpower? -- arr:ARRref_list ]
   { }list
   #-1 "" "P" FIND_ARRAY
   FOREACH
      swap pop
      dup STRflag @ INTpower? @ IF Power? ELSE Flag? THEN IF
         swap ARRAY_appenditem
      ELSE
         pop
      THEN
   REPEAT
;
 
: WIZLIST-list[ arr:ARRreflist str:STRflag -- ]
   STRflag @ strip dup IF
      dup ":" instr 1 = IF
         1 strcut swap pop strip 1
      ELSE
         0
      THEN
   ELSE
      pop "" 0
   THEN
   over IF
      WIZLIST-get_all_flag
   ELSE
      pop pop ARRreflist @
   THEN
   "^PURPLE^= ^YELLOW^" "muckname" sysparm 1 escape_ansi strcat
   trig "/@Title" getpropstr 1 escape_ansi strcat " ^PURPLE^" strcat
   dup 1 unparse_ansi 78 swap strlen - "" "=" rot STRfillfield strcat
   me @ swap ansi_notify
   FOREACH
      swap pop dup name 16 STRaleft 16 strcut pop 1 escape_ansi
      trig "/@/%d/Note" 4 pick dtos "%d" subst getpropstr dup strip IF
         46 STRaleft 46 strcut pop 1 escape_ansi
      ELSE
         pop "^CFAIL^" "None set." 46 STRaleft strcat
      THEN
      rot dup Online? dup -1 = not IF
         over "Q" Flag? trig "/@/%d/OffDuty?" 5 pick dtos "%d" subst getpropstr "y" stringpfx or IF
            pop pop "^YELLOW^OffDuty "
         ELSE
            swap "IDLE" Flag? IF
               -1 PARSEtime 4 STRleft dup strlen 4 > IF pop "999d" THEN "Idle" strcat
               "^YELLOW^" swap strcat
            ELSE
               pop " ^GREEN^Awake  "
            THEN
         THEN
      ELSE
         pop pop "^RED^Offline "
      THEN
      rot rot swap "^PURPLE^[^GREEN^%s^PURPLE^]:[^FOREST^%s^PURPLE^]:[%s^PURPLE^]" FMTstring
      me @ swap ansi_notify
   REPEAT
   me @ "^PURPLE^" "" "=" 78 STRfillfield strcat ansi_notify
;
 
: WIZLIST-add[ ref:ref -- ]
   trig "/@Refs" ref @ REFLIST_find IF
      me @ "^CFAIL^That player is already in the reflist." ansi_notify EXIT
   THEN
   trig "/@Refs" ref @ REFLIST_add
   me @ "^CSUCC^Player added to reflist." ansi_notify
;
 
: WIZLIST-rem[ ref:ref -- ]
   trig "/@Refs" ref @ REFLIST_find not IF
      me @ "^CFAIL^That player is not in the reflist." ansi_notify EXIT
   THEN
   BEGIN
      trig "/@Refs" ref @ REFLIST_find WHILE
      trig "/@Refs" ref @ REFLIST_del
   REPEAT
   me @ "^CSUCC^Player removed from reflist." ansi_notify
;
 
: WIZLIST-flag[ str:STRflag -- ]
   STRflag @ strip dup not over ":" stringcmp not or IF
      pop
      trig "/@Flag" remove_prop
      me @ "^CSUCC^Flag/Power set back to default of TrueWizard flag." ansi_notify
   ELSE
      trig "/@Flag" rot setprop
      me @ "^CSUCC^Flag/Power setting set." ansi_notify
   THEN
;
 
: WIZLIST-toggle-refs[ -- ]
   trig "/@Refs?" over over getpropstr "y" stringpfx IF
      remove_prop
   ELSE
      "yes" setprop
   THEN
   me @ "^CSUCC^Toggled." ansi_notify
;
 
: WIZLIST-title[ str:STRtitle -- ]
   STRtitle @ strip dup IF
      trig "/@Title" rot setprop
      me @ "^CSUCC^Set." ansi_notify
   ELSE
      pop trig "/@Title" remove_prop
      me @ "^CSUCC^Cleared." ansi_notify
   THEN
;
 
: WIZLIST-note[ str:STRnote -- ]
   trig "/@/%d/Note" me @ dtos "%d" subst
   STRnote @ strip dup IF
      setprop
      me @ "^CSUCC^Set." ansi_notify
   ELSE
      pop remove_prop
      me @ "^CSUCC^Cleared." ansi_notify
   THEN
;
 
: WIZLIST-toggle-duty[ -- ]
   trig "/@/%d/OffDuty?" me @ dtos "%d" subst over over getpropstr "y" stringpfx IF
      remove_prop
   ELSE
      "yes" setprop
   THEN
   me @ "^CSUCC^Toggled." ansi_notify
;
 
: REF-match[ str:STRref -- ref:ref ]
   STRref @ strip dup IF
      pmatch
   ELSE
      pop #-1
   THEN
   dup Ok? not IF
      dup #-2 dbcmp IF
         "^CINFO^I don't know which player you mean!"
      ELSE
         "^CINFO^I cannot find that player."
      THEN
      me @ swap ansi_notify
   THEN
;
 
: REFLIST_name[ arr:ARRref_list -- str:STRnames ]
   { }list ARRref_list @
   FOREACH
      swap pop
      me @ over controls IF
         unparseobj
      ELSE
         name
      THEN
      swap ARRAY_appenditem
   REPEAT
   dup ARRAY_count IF
      ", " ARRAY_join ", " rsplit dup IF
         ", and " swap strcat strcat
      ELSE
         pop
      THEN
   ELSE
      pop "(Nothing)"
   THEN
;
 
: FLAG_translate[ str:STRflag -- str:STRflag' ]
   STRflag @ strip dup ":" stringpfx IF
      1 strcut swap pop " ^NORMAL^(Power)"
   ELSE
      " ^NORMAL^(Flag)"
   THEN
   swap strip dup IF
      1 escape_ansi swap strcat "^YELLOW^" swap strcat
   ELSE
      pop pop "^YELLOW^TrueWizard ^NORMAL^(Flag)"
   THEN
;
 
$def cmd_len 20 STRaleft 1 escape_ansi
 
: WIZLIST-help[ -- ]
   {
      "^CYAN^WizStaffList v%1.2f - by Moose" prog "_Version" getpropstr strtof swap FMTstring
      "^PURPLE^==============================="
     me @ "WIZARD" Flag? IF
      "   ^WHITE^Reflist: ^NORMAL^" trig "/@Refs" ARRAY_get_reflist REFLIST_name 1 escape_ansi strcat
      "^WHITE^Flag/Power: " trig "/@Flag" getpropstr FLAG_translate strcat
      "^WHITE^What is being used? ^YELLOW^"
        trig "/@Refs?" getpropstr "y" stringpfx IF
           "Reflist"
        ELSE
           "Flag/Power"
        THEN
        strcat
      command @ " #add <plyr>"  strcat cmd_len " ^WHITE^- Add a player to the reflist." strcat
      command @ " #rem <plyr>"  strcat cmd_len " ^WHITE^- Remove a player from the reflist." strcat
      command @ " #flag <flag>" strcat cmd_len " ^WHITE^- Set the flag to scan for.  Start with a : for it to be a power." strcat
      command @ " #refs"        strcat cmd_len " ^WHITE^- Toggle between using the reflist or the flag setting." strcat
      command @ " #title <str>" strcat cmd_len " ^WHITE^- Set a title shown on the list." strcat
     THEN
     trig "/@Refs?" getpropstr "y" stringpfx IF
        trig "/@Refs" me @ REFLIST_find
     ELSE
        trig "/@Flag" getpropstr strip dup IF
           dup ":" instr 1 = IF
              1 strcut swap pop strip dup IF
                 me @ swap Power?
              ELSE
                 pop me @ "STAFF" Flag?
              THEN
           ELSE
              me @ swap Flag?
           THEN
        ELSE
           pop me @ "TRUEWIZARD" Flag?
        THEN
     THEN
     IF
      command @ " #note <str>"  strcat cmd_len " ^WHITE^- Set a note for yourself." strcat
      command @ " #duty"        strcat cmd_len " ^WHITE^- Toggle your duty status between on/off." strcat
     THEN
      command @ " #help"        strcat cmd_len " ^WHITE^- This screen." strcat
      command @ ""              strcat cmd_len " ^WHITE^- List the wizards." strcat
      "^CINFO^Done."
   }list { me @ }list array_ansi_notify
;
 
: WIZLIST-connect[ -- ]
   VAR ref
   #-1
   BEGIN
      prog swap NEXTENTRANCE dup Ok? WHILE
      dup ref !
     0 TRY
      ref @ "/@Refs?" getpropstr strip "y" stringpfx IF
         ref @ "/@Refs" me @ REFLIST_find
      ELSE
         ref @ "/@Flag" getpropstr strip dup IF
            dup ":" stringpfx IF
               1 strcut swap pop strip dup not IF
                  pop "STAFF"
               THEN
               me @ swap Power?
            ELSE
               me @ swap Flag?
            THEN
         ELSE
            pop me @ "TRUEWIZARD" Flag?
         THEN
      THEN
      IF
         ref @ "/@/%d/OffDuty?" me @ dtos "%d" subst getpropstr strip "y" stringpfx IF
            me @ "^RED^You are ^YELLOW^off duty ^RED^for the staff listing on the command: ^YELLOW^"
            ref @ name ";" split pop 1 escape_ansi strcat ansi_notify
         THEN
      THEN
     CATCH
      pop
     ENDCATCH
   REPEAT
   pop
;
 
$def IsIt? stringcmp not
 
: main[ str:STRargs -- ]
   command @ "Queued Event." stringcmp not IF
      WIZLIST-connect EXIT
   THEN
   trig owner "TRUEWIZARD" Flag? not IF
      me @ "^CFAIL^The owner of this trigger is not a wizard." ansi_notify EXIT
   THEN
      STRargs @ strip dup "#" stringpfx IF
         " " split strip STRargs !
         (s) CASE
            "#help" IsIt? WHEN
               WIZLIST-help
            END
           me @ "WIZARD" Flag? IF
            "#add" IsIt? WHEN
               STRargs @ REF-match dup Ok? IF WIZLIST-add ELSE pop THEN
            END
            "#rem" IsIt? WHEN
               STRargs @ REF-match dup Ok? IF WIZLIST-rem ELSE pop THEN
            END
            "#refs" IsIt? WHEN
               WIZLIST-toggle-refs
            END
            "#flag" IsIt? WHEN
               STRargs @ WIZLIST-flag
            END
            "#title" IsIt? WHEN
               STRargs @ WIZLIST-title
            END
           THEN
           trig "/@Refs?" getpropstr "y" stringpfx IF
              trig "/@Refs" me @ REFLIST_find
           ELSE
              trig "/@Flag" getpropstr strip dup IF
                 dup ":" instr 1 = IF
                    1 strcut swap pop strip dup IF
                       me @ swap Power?
                    ELSE
                       pop me @ "STAFF" Flag?
                    THEN
                 ELSE
                    me @ swap Flag?
                 THEN
              ELSE
                 pop me @ "TRUEWIZARD" Flag?
              THEN
           THEN
           IF
            "#note" IsIt? WHEN
               STRargs @ WIZLIST-note
            END
            "#duty" IsIt? WHEN
               WIZLIST-toggle-duty
            END
           THEN
            DEFAULT pop me @ "^CFAIL^Invalid option." ansi_notify END
         ENDCASE
         EXIT
      ELSE
         pop
      THEN
   trig "/@Refs?" getpropstr "y" stringpfx IF
      trig "/@Refs" ARRAY_get_reflist ""
   ELSE
      { }list
      trig "/@Flag" getpropstr dup strip not IF
         pop "TRUEWIZARD"
      THEN
   THEN
   WIZLIST-list
;
