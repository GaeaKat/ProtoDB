(*
   Cmd-Finger v2.0
   by Moose
 *)
 
$author  Moose
$version 2.0
 
$include $lib/ic
$include $lib/puppet
$include $lib/standard
$include $lib/strings
 
: Online?[ ref:ref -- int:count ]
   ref @ Awake? IF
      ref @ "DARK" Flag?
      ref @ "HIDDEN" Flag? OR
      ref @ "LIGHT" Flag? not and
   ELSE
      1
   THEN
   IF
      ref @ timestamps IF
         rot rot pop pop
      ELSE
         pop pop pop 1
      THEN
   ELSE
      0
   THEN
;
 
: STR_left_just[ str:STRline int:INTlen -- str:STRline' ]
   STRline @ INTlen @ STRaleft dup strlen INTlen @ > IF
      INTlen @ strcut pop
   THEN
;
 
: STR_right_just[ str:STRline int:INTlen -- str:STRline' ]
   STRline @ INTlen @ STRaright dup strlen INTlen @ > IF
      INTlen @ strcut pop
   THEN
;
 
: FINGER-get-sort[ ref:ref int:BOLlong? -- ]
   ref @ Player? IF
      ref @ "TRUEWIZARD" Flag? FINGER-sort_type and IF
         BOLlong? @ IF
            "Wizard"
         ELSE
            "W"
         THEN
      ELSE
         ref @ "STAFF" Power? FINGER-sort_type and IF
            BOLlong? @ IF
               "Staff"
            ELSE
               "S"
            THEN
         ELSE
            BOLlong? @ IF
               "Player"
            ELSE
               "P"
            THEN
         THEN
      THEN
   ELSE
      ref @ dup Thing? swap "ZOMBIE" Flag? IF
         BOLlong? @ IF
            "Puppet"
         ELSE
            "Z"
         THEN
      ELSE
         BOLlong? @ IF
            "Unknown"
         ELSE
            "?"
         THEN
      THEN
   THEN
;
 
: FINGER-get_ic[ ref:ref -- str:STRic ]
   ref @ REF-IC? CASE
      -1 = WHEN
         " ^YELLOW^*AFK*"
      END
      0  = WHEN
         " ^RED^*OOC*"
      END
      1  = WHEN
         " ^CYAN^*IC*"
      END
      DEFAULT pop " ^RED^*???*"
      END
   ENDCASE
;
 
: FINGER-notify[ ref:ref -- ]
   me @ "TRUEWIZARD" Flag? ref @ "WIZARD" Flag? not and IF
      me @ "/_Prefs/Block-FingerNotify?" getpropstr "y" stringpfx IF
         EXIT
      THEN
   THEN
   ref @ "/_Prefs/FingerNotify" getpropstr dup strip
   ref @ "/_Prefs/FingerNotify?" getpropstr "y" stringpfx or IF
      dup strip not IF
         pop "^WHITE^*** %n ^NORMAL^has just checked your ^WHITE^%f ^NORMAL^finger profile. ^WHITE^***"
      THEN
      FINGER-type IF
         "IC/OOC"
      ELSE
         command @ "o" instring IF
            "OOC"
         ELSE
            "IC"
         THEN
      THEN
      "%f" subst me @ swap pronoun_sub
      ref @ swap ansi_notify
   ELSE
      pop
   THEN
;
 
: FINGER-old[ ref:ref -- ]
   0 VAR! INTstats VAR STRline
   {
      me @ ref @ controls IF
           ref @ unparseobj 1 escape_ansi "(#" rsplit "^YELLOW^(#" swap strcat strcat
        ELSE
           ref @ name 1 escape_ansi
        THEN
        "^GREEN^" swap strcat
        " ^FOREST^(" strcat
        FINGER-type -- IF
           "Alias: ^GREEN^"
           "%n"
        ELSE
           "Full name: ^GREEN^"
           PROPS-full_name
        THEN
        ref @ swap getpropstr dup strip IF
           1 escape_ansi
        ELSE
           pop "^RED^None set."
        THEN
        strcat strcat "^FOREST^) " strcat
        ref @ FINGER-get_ic strcat
        "" "=" 3 pick 1 unparse_ansi strlen 3 + dup 78 > IF
           pop 78
        THEN
      STRfillfield "^PURPLE^" swap strcat dup STRline !
      "     ^FR/FIELD^Sort: ^FR/PROP^" ref @ 1 FINGER-get-sort strcat
      "   ^FR/FIELD^Gender: ^FR/PROP^" ref @ PROPS-gender getpropstr dup strip IF
           1 escape_ansi
        ELSE
           pop "^RED^None set."
        THEN
        strcat
      "  ^FR/FIELD^Species: ^FR/PROP^" ref @ PROPS-species getpropstr dup strip IF
           1 escape_ansi
        ELSE
           pop "^RED^None set."
        THEN
        strcat
      "   ^FR/FIELD^Series: ^FR/PROP^" ref @ PROPS-series getpropstr dup strip IF
           1 escape_ansi
        ELSE
           pop "^RED^None set."
        THEN
        strcat
      "      ^FR/FIELD^Age: ^FR/PROP^" ref @ PROPS-age getpropstr dup strip IF
           1 escape_ansi
        ELSE
           pop "^RED^None set."
        THEN
        strcat
        ref @ PROPS-birthday getpropstr dup strip IF
             "^FR/FIELD^Birthdate: ^FR/PROP^" swap strcat
          THEN
        ref @ PROPS-height getpropstr dup strip IF
             "   ^FR/FIELD^Height: ^FR/PROP^" swap strcat
          THEN
        ref @ PROPS-weight getpropstr dup strip IF
             "   ^FR/FIELD^Height: ^FR/PROP^" swap strcat
          THEN
        "    ^FR/FIELD^Class: ^FR/PROP^" ref @ PROPS-class getpropstr dup strip IF
           1 escape_ansi
        ELSE
           pop "^RED^None set."
        THEN
        strcat
      "^FR/FIELD^Alignment: ^FR/PROP^" ref @ PROPS-align getpropstr dup strip IF
           1 escape_ansi
        ELSE
           pop "^RED^None set."
        THEN
        strcat
      STRline @
      ref @ owner Online? dup IF
           dup 1 = IF
              pop " ^FR/PROP^Never connected."
           ELSE
              " ^FR/PROP^Last disconnected on ^FR/FIELD^%a %b %e, %Y ^FR/PROP^at ^FR/FIELD^%r %Z^FR/PROP^."
              swap TimeFMT
           THEN
        ELSE
           pop " ^FR/FIELD^Currently connected."
        THEN
      ref @ PAGE-maildir getprop dup String? IF atoi THEN
        dup IF
           " ^FR/FIELD^%n message%e waiting."
           over 1 > IF
              "s are"
           ELSE
              " is"
           THEN
           "%e" subst swap intostr "%n" subst
        ELSE
           pop " ^FR/PROP^No mail is waiting."
        THEN
      STRline @
      "^FR/FIELD^Short Description: ^FR/PROP^" ref @ PROPS-shortdesc getpropstr dup strip IF
           1 escape_ansi
        ELSE
           pop "^RED^None set."
        THEN
        strcat
      "^FR/FIELD^Miscellaneous: ^FR/PROP^" ref @ PROPS-misc getpropstr dup strip IF
           1 escape_ansi
        ELSE
           pop "^RED^None set."
        THEN
        strcat
      ref @ PROPS-icq_id getpropstr dup strip IF
           "^FR/FIELD^ICQ Number: ^FR/PROP^" swap strcat
        THEN
      ref @ PROPS-yahoo_id getpropstr dup strip IF
           "^FR/FIELD^Yahoo ID: ^FR/PROP^" swap strcat
        THEN
      ref @ PROPS-email getpropstr dup strip IF
           "^FR/FIELD^E-Mail Address: ^FR/PROP^" swap strcat
        THEN
      ref @ PROPS-webpage getpropstr dup strip IF
           "^FR/FIELD^Homepage URL: ^FR/PROP^" swap strcat
        THEN
      ref @ PROPS-picture_url getpropstr dup strip IF
           "^FR/FIELD^Character's Picture URL: ^FR/PROP^" swap strcat
        THEN
      ref @ "/_Info/Stats/" ARRAY_get_propvals
        FOREACH
           dup strip IF
              "^FR/FIELD^" rot 1 escape_ansi strcat ": ^FR/PROP^" strcat swap 1 escape_ansi strcat
              INTstats ++
           ELSE
              pop pop
           THEN
        REPEAT
      INTstats @ IF
           STRline @
        THEN
  }list
  { me @ }list ARRAY_ansi_notify
  ref @ FINGER-notify
;
 
: FINGER-ooc[ ref:ref -- ]
   0 VAR! INTstats
   me @ ref @ controls not IF
      ref @ SETTING-block_ooc_info? getpropstr "y" stringpfx IF
         me @ "^CFAIL^That player has opted to block their OOC info." ansi_notify EXIT
      THEN
   THEN
   {
      "^PURPLE^[^VIOLET^" ref @ 0 FINGER-get-sort strcat "^PURPLE^] ^GREEN^" strcat
        me @ ref @ controls IF
           ref @ unparseobj 68 STR_left_just 1 escape_ansi
           "(#" rsplit "^YELLOW^(#" swap strcat strcat
        ELSE
           ref @ name 68 STR_left_just 1 escape_ansi
        THEN
        strcat " ^PURPLE^[^GREEN^OOC^PURPLE^]" strcat
      "^PURPLE^=============================================================================="
      " ^FR/FIELD^Full Name: ^FR/PROP^" ref @ PROPS-ooc_full_name getpropstr dup strip IF
           65 STR_left_just 1 escape_ansi
        ELSE
           pop "^RED^" "Unknown" 65 STR_left_just strcat
        THEN
        strcat
      ref @ PROPS-ooc_elsemu getpropstr dup strip IF
        "   ^FR/FIELD^Elsemu*: ^FR/PROP^" swap 65 STR_left_just 1 escape_ansi strcat
      ELSE
         pop
      THEN
      "  ^FR/FIELD^Location: ^FR/PROP^" ref @ PROPS-ooc_location getpropstr dup strip IF
           65 STR_left_just 1 escape_ansi
        ELSE
           pop "^RED^" "Unknown" 65 STR_left_just strcat
        THEN
        strcat
      "    ^FR/FIELD^E-Mail: ^FR/PROP^" ref @ PROPS-email getpropstr dup strip IF
           65 STR_left_just 1 escape_ansi
        ELSE
           pop "^RED^" "Unknown" 65 STR_left_just strcat
        THEN
        strcat
      ref @ PROPS-icq_id getpropstr dup strip IF
        "^FR/FIELD^ICQ Number: ^FR/PROP^" swap 65 STR_left_just 1 escape_ansi strcat
      ELSE
         pop
      THEN
      ref @ PROPS-yahoo_id getpropstr dup strip IF
        "  ^FR/FIELD^Yahoo ID: ^FR/PROP^" swap 65 STR_left_just 1 escape_ansi strcat
      ELSE
         pop
      THEN
      ref @ PROPS-webpage getpropstr dup strip IF
        "   ^FR/FIELD^Webpage: ^FR/PROP^" swap 65 STR_left_just 1 escape_ansi strcat
      ELSE
         pop
      THEN
      "    ^FR/FIELD^Gender: ^FR/PROP^" ref @ PROPS-ooc_gender getpropstr dup strip IF
           23 STR_left_just 1 escape_ansi
        ELSE
           pop "^RED^" "Unknown" 23 STR_left_just strcat
        THEN
        strcat
        "        ^FR/FIELD^Job: ^FR/PROP^" ref @ PROPS-ooc_ethnic getpropstr dup strip IF
             25 STR_left_just 1 escape_ansi
          ELSE
             pop "^RED^" "Unknown" 25 STR_left_just strcat
          THEN
        strcat strcat
      "       ^FR/FIELD^Age: ^FR/PROP^" ref @ PROPS-ooc_age getpropstr dup strip IF
           23 STR_left_just 1 escape_ansi
        ELSE
           pop "^RED^" "Unknown" 23 STR_left_just strcat
        THEN
        strcat
        "  ^FR/FIELD^Birthdate: ^FR/PROP^" ref @ PROPS-ooc_birthday getpropstr dup strip IF
             25 STR_left_just 1 escape_ansi
          ELSE
             pop "^RED^" "Unknown" 25 STR_left_just strcat
          THEN
        strcat strcat
      "    ^FR/FIELD^Height: ^FR/PROP^" ref @ PROPS-ooc_height getpropstr dup strip IF
           23 STR_left_just 1 escape_ansi
        ELSE
           pop "^RED^" "Unknown" 23 STR_left_just strcat
        THEN
        strcat
        "     ^FR/FIELD^Weight: ^FR/PROP^" ref @ PROPS-ooc_weight getpropstr dup strip IF
             25 STR_left_just 1 escape_ansi
          ELSE
             pop "^RED^" "Unknown" 25 STR_left_just strcat
          THEN
        strcat strcat
      "^PURPLE^=============================================================================="
      ref @ owner Online? dup IF
         dup 1 = IF
            pop " ^FR/PROP^Never connected."
         ELSE
            " ^FR/PROP^Last disconnected on ^FR/FIELD^%a %b %e, %Y ^FR/PROP^at ^FR/FIELD^%r %Z^FR/PROP^."
            swap TimeFMT
         THEN
      ELSE
         pop " ^FR/FIELD^Currently connected."
      THEN
      ref @ PAGE-maildir getprop dup String? IF atoi THEN
        dup IF
           " ^FR/FIELD^%n message%e waiting."
           over 1 > IF
              "s are"
           ELSE
              " is"
           THEN
           "%e" subst swap intostr "%n" subst
        ELSE
           pop " ^FR/PROP^No mail is waiting."
        THEN
      "^PURPLE^=============================================================================="
      "^FR/FIELD^Short Description: ^FR/PROP^" ref @ PROPS-ooc_shortdesc getpropstr dup strip IF
           1 escape_ansi
        ELSE
           pop "^RED^None set."
        THEN
        strcat
      "^FR/FIELD^Miscellaneous: ^FR/PROP^" ref @ PROPS-ooc_misc getpropstr dup strip IF
           1 escape_ansi
        ELSE
           pop "^RED^None set."
        THEN
        strcat
      "^PURPLE^=============================================================================="
      ref @ "/_Info/OOC/Stats/" ARRAY_get_propvals
      FOREACH
         dup strip IF
            "^FR/FIELD^" rot 1 escape_ansi strcat ": ^FR/PROP^" strcat swap 1 escape_ansi strcat
            INTstats ++
         ELSE
            pop pop
         THEN
      REPEAT
      INTstats @ IF
         "^PURPLE^=============================================================================="
      THEN
   }list
   { me @ }list ARRAY_ansi_notify
   ref @ FINGER-notify
;
 
: FINGER-ic[ ref:ref -- ]
   0 VAR! INTstats
   {
      "^PURPLE^[^VIOLET^" ref @ 0 FINGER-get-sort strcat "^PURPLE^] ^GREEN^" strcat
        me @ ref @ controls IF
           ref @ unparseobj 
           "(#" rsplit "^YELLOW^(#" swap strcat strcat
           { "" ref @ "@pa" getprop if "^NORMAL^(^CYAN^PA#" ref @ "@pa" getprop "^NORMAL^)" then }cat strcat
        ELSE
           ref @ name
           { "" ref @ "@pa" getprop if "^NORMAL^(^CYAN^PA#" ref @ "@pa" getprop "^NORMAL^)" then }cat strcat
        THEN
        strcat "   " strcat
        ref @ "%n" getpropstr dup strip IF
           dup strlen dup 32 > IF
              pop 29 strcut pop "^RED^..." strcat
              "^PURPLE^(^FOREST^%n^PURPLE^)" swap "%n" subst
           ELSE
              32 swap - "" swap STR_right_just swap 1 escape_ansi
              "^PURPLE^(^FOREST^%n^PURPLE^)" swap "%n" subst strcat
           THEN
        ELSE
           pop "" 23 STR_right_just "^PURPLE^(^RED^None set.^PURPLE^)" strcat
        THEN
        strcat
        ref @ FINGER-get_ic strcat
      "^PURPLE^=============================================================================="
      "^FR/FIELD^Full Name: ^FR/PROP^" ref @ PROPS-full_name getpropstr dup strip IF
           65 STR_left_just 1 escape_ansi
        ELSE
           pop "^RED^" "Unknown" 65 STR_left_just strcat
        THEN
        strcat
      "   ^FR/FIELD^Series: ^FR/PROP^" ref @ PROPS-series getpropstr dup strip IF
           65 STR_left_just 1 escape_ansi
        ELSE
           pop "^RED^" "Unknown" 65 STR_left_just strcat
        THEN
        strcat
      ref @ PROPS-picture_url getpropstr dup strip IF
         strip dup "http://" instring 1 = not IF
            "http://" swap strcat
         THEN
         65 STR_left_just 1 escape_ansi
         "  ^FR/FIELD^Picture: ^FR/PROP^" swap strcat
      THEN
      "    ^FR/FIELD^Class: ^FR/PROP^" ref @ PROPS-class getpropstr dup strip IF
           25 STR_left_just 1 escape_ansi
        ELSE
           pop "^RED^" "Unknown" 25 STR_left_just strcat
        THEN
        strcat
        " ^FR/FIELD^Alignment: ^FR/PROP^" ref @ PROPS-align getpropstr dup strip IF
             25 STR_left_just 1 escape_ansi
          ELSE
             pop "^RED^" "Unknown" 25 STR_left_just strcat
          THEN
        strcat strcat
      "   ^FR/FIELD^Gender: ^FR/PROP^" ref @ PROPS-gender getpropstr dup strip IF
           25 STR_left_just 1 escape_ansi
        ELSE
           pop "^RED^" "Unknown" 25 STR_left_just strcat
        THEN
        strcat
        "   ^FR/FIELD^Species: ^FR/PROP^" ref @ PROPS-species getpropstr dup strip IF
             25 STR_left_just 1 escape_ansi
          ELSE
             pop "^RED^" "Unknown" 25 STR_left_just strcat
          THEN
        strcat strcat
      "      ^FR/FIELD^Age: ^FR/PROP^" ref @ PROPS-age getpropstr dup strip IF
           25 STR_left_just 1 escape_ansi
        ELSE
           pop "^RED^" "Unknown" 25 STR_left_just strcat
        THEN
        strcat
        " ^FR/FIELD^Birthdate: ^FR/PROP^" ref @ PROPS-birthday getpropstr dup strip IF
             25 STR_left_just 1 escape_ansi
          ELSE
             pop "^RED^" "Unknown" 25 STR_left_just strcat
          THEN
        strcat strcat
      "   ^FR/FIELD^Height: ^FR/PROP^" ref @ PROPS-height getpropstr dup strip IF
           25 STR_left_just 1 escape_ansi
        ELSE
           pop "^RED^" "Unknown" 25 STR_left_just strcat
        THEN
        strcat
        "    ^FR/FIELD^Weight: ^FR/PROP^" ref @ PROPS-weight getpropstr dup strip IF
             25 STR_left_just 1 escape_ansi
          ELSE
             pop "^RED^" "Unknown" 25 STR_left_just strcat
          THEN
        strcat strcat
      "^PURPLE^=============================================================================="
      ref @ owner Online? dup IF
         dup 1 = IF
            pop " ^FR/PROP^Never connected."
         ELSE
            " ^FR/PROP^Last disconnected on ^FR/FIELD^%a %b %e, %Y ^FR/PROP^at ^FR/FIELD^%r %Z^FR/PROP^."
            swap TimeFMT
         THEN
      ELSE
         pop " ^FR/FIELD^Currently connected."
      THEN
      ref @ PAGE-maildir getprop dup String? IF atoi THEN
        dup IF
           " ^FR/FIELD^%n message%e waiting."
           over 1 > IF
              "s are"
           ELSE
              " is"
           THEN
           "%e" subst swap intostr "%n" subst
        ELSE
           pop " ^FR/PROP^No mail is waiting."
        THEN
      "^PURPLE^=============================================================================="
      "^FR/FIELD^Short Description: ^FR/PROP^" ref @ PROPS-shortdesc getpropstr dup strip IF
           1 escape_ansi
        ELSE
           pop "^RED^None set."
        THEN
        strcat
      "^FR/FIELD^Miscellaneous: ^FR/PROP^" ref @ PROPS-misc getpropstr dup strip IF
           1 escape_ansi
        ELSE
           pop "^RED^None set."
        THEN
        strcat
      "^PURPLE^=============================================================================="
      ref @ "/_Info/Stats/" ARRAY_get_propvals
      FOREACH
         dup strip IF
            "^FR/FIELD^" rot 1 escape_ansi strcat ": ^FR/PROP^" strcat swap 1 escape_ansi strcat
            INTstats ++
         ELSE
            pop pop
         THEN
      REPEAT
      INTstats @ IF
         "^PURPLE^=============================================================================="
      THEN
   }list
   { me @ }list ARRAY_ansi_notify
   ref @ FINGER-notify
;
 
$def prop_len 20 STR_left_just
 
: FINGER-help[ int:INTscreen -- ]
  {
   INTscreen @ CASE
      1 = FINGER-type or WHEN
         "^CYAN^Finger v%1.2f - by Moose" prog "_version" getpropstr strtof swap FMTstring
         "^PURPLE^========================="
         "^WHITE^Properties for Finger:"
         "%n" prop_len " ^WHITE^- Your alias." strcat
         PROPS-full_name prop_len " ^WHITE^- Your character's fullname." strcat
         PROPS-series prop_len " ^WHITE^- Your character's series." strcat
         PROPS-age prop_len " ^WHITE^- Your character's age." strcat
         PROPS-birthday prop_len " ^WHITE^- Your character's birthdate." strcat
         PROPS-gender prop_len " ^WHITE^- Your character's gender." strcat
         PROPS-species prop_len " ^WHITE^- Your character's species." strcat
         PROPS-height prop_len " ^WHITE^- Your character's height." strcat
         PROPS-weight prop_len " ^WHITE^- Your character's weight." strcat
         PROPS-class prop_len " ^WHITE^- Your character's class info." strcat
         PROPS-align prop_len " ^WHITE^- Your character's alignment." strcat
         PROPS-shortdesc prop_len " ^WHITE^- A short description of your character." strcat
         PROPS-misc prop_len " ^WHITE^- Anything else you want to add." strcat
         PROPS-picture_url prop_len " ^WHITE^- A picture URL of your character." strcat
        FINGER-type IF
         PROPS-email prop_len " ^WHITE^- Your e-mail address." strcat
         PROPS-webpage prop_len " ^WHITE^- Your homepage." strcat
         PROPS-yahoo_id prop_len " ^WHITE^- Your Yahoo ID (if you have one)." strcat
         PROPS-icq_id prop_len " ^WHITE^- Your ICQ Number (if you have one)." strcat
        THEN
         "^WHITE^You can set any additional information by typing:"
         " @set me=/_Info/Stats/<Name>:<Setting>"
         "^WHITE^You can turn on your finger notify by typing:"
         " @set me=/_Prefs/FingerNotify?:yes"
         "^WHITE^You can customize it by typing: [parses subs, %f is type of finger]"
         " @set me=/_Prefs/FingerNotify:<finger notify string, with ansi>"
        me @ "WIZARD" Flag? IF
         "^WHITE^As a wizard, you can block others from seeing you finger them by typing:"
         " @set me=/_Prefs/Block-FingerNotify?:yes"
        THEN
         "^WHITE^Custom Colors:"
         " @set me=/_/COLORS/FR/FIELD:<color> - i.e. 'Age:', 'Gender:'"
         " @set me=/_/COLORS/FR/PROP:<color>  - What the above are set to."
        FINGER-type not IF
         "Type '^WHITE^finger #help2^NORMAL^' for information on OOC properties."
        THEN
         "^CINFO^Done."
      END
      2 = FINGER-type not and WHEN
         "^CYAN^Finger v%1.2f - by Moose" prog "_version" getpropstr strtof swap FMTstring
         "^PURPLE^========================="
         "^WHITE^Properties for OOCFinger:"
         PROPS-ooc_full_name prop_len " ^WHITE^- Your RL fullname." strcat
         PROPS-ooc_elsemu prop_len " ^WHITE^- Your chracter's ElseMU*." strcat
         PROPS-ooc_location prop_len " ^WHITE^- Your RL location." strcat
         PROPS-ooc_age prop_len " ^WHITE^- Your RL age." strcat
         PROPS-ooc_birthday prop_len " ^WHITE^- Your RL birthdate." strcat
         PROPS-ooc_gender prop_len " ^WHITE^- Your RL gender." strcat
         PROPS-ooc_job prop_len " ^WHITE^- Your RL job (or student)." strcat
         PROPS-ooc_height prop_len " ^WHITE^- Your RL height." strcat
         PROPS-ooc_weight prop_len " ^WHITE^- Your RL weight." strcat
         PROPS-ooc_shortdesc prop_len " ^WHITE^- A short description of yourself." strcat
         PROPS-ooc_misc prop_len " ^WHITE^- Anything else you want to add." strcat
         PROPS-email prop_len " ^WHITE^- Your e-mail address." strcat
         PROPS-webpage prop_len " ^WHITE^- Your homepage." strcat
         PROPS-yahoo_id prop_len " ^WHITE^- Your Yahoo ID (if you have one)." strcat
         PROPS-icq_id prop_len " ^WHITE^- Your ICQ Number (if you have one)." strcat
         "^WHITE^You can set any additional information by typing:"
         " @set me=/_Info/OOC/Stats/<Name>:<Setting>"
         "^WHITE^You can turn on your finger notify by typing:"
         " @set me=/_Prefs/FingerNotify?:yes"
         "^WHITE^You can customize it by typing: [parses subs, %f is type of finger]"
         " @set me=/_Prefs/FingerNotify:<finger notify string, with ansi>"
        me @ "WIZARD" Flag? IF
         "^WHITE^As a wizard, you can block others from seeing you finger them by typing:"
         " @set me=/_Prefs/Block-FingerNotify?:yes"
        THEN
         "^WHITE^Custom Colors:"
         " @set me=/_/COLORS/FR/FIELD:<color> - i.e. 'Age:', 'Gender:'"
         " @set me=/_/COLORS/FR/PROP:<color>  - What the above are set to."
         "Type '^WHITE^finger #help1^NORMAL^' for information on IC properties."
         "^CINFO^Done."
      END
      DEFAULT pop "^CFAIL^There is no help screen by that number." END
   ENDCASE
  }list
  { me @ }list ARRAY_ansi_notify
;
 
: FINGER-main[ str:STRargs -- ]
   #0 "/_/COLORS/FR" Propdir? not IF
      #0 "/_/COLORS/FR/FIELD" "WHITE"  setprop
      #0 "/_/COLORS/FR/PROP"  "NORMAL" setprop
   THEN
   STRargs @ strip dup not IF
      pop
      {
         "^CYAN^Syntax: ^AQUA^finger <player/puppet>"
        FINGER-type not IF
         "        ^AQUA^oocfinger <player/puppet>"
        THEN
         "        ^AQUA^finger #help"
      }list
      { me @ }list array_ansi_notify EXIT
   THEN
   dup "#help" stringcmp not IF
      pop command @ "o" instring IF 2 ELSE 1 THEN FINGER-help EXIT
   THEN
   dup "#help1" stringcmp not IF
      pop 1 FINGER-help EXIT
   THEN
   dup "#help2" stringcmp not IF
      pop 2 FINGER-help EXIT
   THEN
   dup pmatch dup #-1 dbcmp IF
      pop puppet_match
   ELSE
      swap pop
   THEN
   dup Ok? not IF
      me @ swap
      #-2 dbcmp IF
         "^CINFO^I don't know which player you mean!"
      ELSE
         "^CINFO^I cannot find that player."
      THEN
      ansi_notify EXIT
   THEN
   FINGER-type IF
      FINGER-old
   ELSE
      command @ "o" instring IF
         owner FINGER-ooc
      ELSE
         FINGER-ic
      THEN
   THEN
;
