(*
   Cmd-Smell v2.0 [Based on Taura's version, recoded for Proto]
   by Moose
 *)
 
$author Moose
$version 2.0
 
$include $lib/strings
 
$def PROPS-smell        "/_scent"
$def PROPS-smell_ansi   "/_AnsiSmell"
$def PROPS-smell_bridge "/Bridge"
$def PROPS-smell_notify "/_Smell_Notify"
$def MESG-def_smell     "You smell nothing special."
$def MESG-def_room      "You smell many scents mixed together."
$def MESG-def_notify    "^GREEN^>> ^FOREST^%N just smelled you."
$def MESG-def_nothing   "-nothing-"
 
$def smell     PROPS-smell "(smell)" 0 parseprop
$def ansismell PROPS-smell_ansi "(smell)" 0 parseprop
 
VAR target
 
$define notify_both ( ref:tellto str:msg -- )
       (%ver) prog "/_Version" getpropstr strtof "%1.2f" fmtstring "%ver" subst
       (%loc) me @ location name "%loc" subst
    (%target) target @ dup #-1 dbcmp over #-2 dbcmp or IF
                 pop MESG-def_nothing
              ELSE
                 name
              THEN
              "%target" subst
   (%command) command @ tolower "%command" subst
       (\r\r) "%" "\r\r" subst
   ansi_notify
$enddef
$def tell_both me @ swap notify_both
 
: ansi_unparseobj[ ref:ref -- str:STRansi ]
   ref @ CASE
      Room? WHEN
         "^CYAN^"
      END
      Thing? WHEN
         "^PURPLE^"
      END
      Player? WHEN
         "^GREEN^"
      END
      Exit? WHEN
         "^BLUE^"
      END
      Program? WHEN
         "^RED^"
      END
      DEFAULT pop
         "^PURPLE^"
      END
   ENDCASE
   ref @
   me @ over controls IF
      unparseobj "(#" rsplit "^YELLOW^(#" swap strcat strcat
   ELSE
      name
   THEN
   strcat
   ref @ Thing? IF
      ref @ "ZOMBIE" Flag? IF
         " ^NORMAL^(Puppet)" strcat
      THEN
      ref @ "VEHICLE" Flag? IF
         " ^NORMAL^(Vehicle)" strcat
      THEN
   THEN
;
 
: SMELL-get[ ref:ref -- str:STRsmell ]
   me @ "COLOR" Flag? IF
      ref @ ansismell dup strip not IF
         pop ref @ smell 1 escape_ANSI
      THEN
   ELSE
      ref @ smell dup strip not IF
         pop ref @ ansismell 1 unparse_ANSI
      THEN
   THEN
   dup 1 unparse_ANSI strip not IF
      pop ref @ Room? IF
         MESG-def_room
      ELSE
         MESG-def_smell
      THEN
   THEN
;
 
: SMELL-notify[ ref:ref -- ]
   ref @ PROPS-smell_notify getpropstr dup strip NOT IF
      pop MESG-def_notify
   THEN
   ref @ swap "(smell)" 0 parsempi me @ swap pronoun_sub
   ref @ swap notify_both
;
 
: SMELL-obj[ ref:ref int:ShortList? -- ]
   ref @ target !
   ref @ SMELL-get
   dup strip not IF
      pop MESG-def_smell
   THEN
   ref @ ansi_unparseobj
   ShortList? @ not IF
      tell_both
   ELSE
      "^YELLOW^: ^NORMAL^" strcat swap strcat
   THEN
   tell_both
   ref @ Room? IF
      EXIT
   THEN
   ref @ Player? IF
      ref @ SMELL-notify
   THEN
   ref @ Thing? IF
      ref @ "VEHICLE" Flag? IF
         ref @ PROPS-smell_bridge getprop
         dup String? IF
            stod
         ELSE
            dup Dbref? not IF
               pop #-1
            THEN
         THEN
         dup Ok? IF
            SMELL-notify
         ELSE
            pop
         THEN
      ELSE
         ref @ "ZOMBIE" Flag? IF
            ref @ SMELL-notify
         THEN
      THEN
   THEN
;
 
: SMELL-room[ ref:ref -- ]
   ref @ 0 SMELL-obj
   "^CINFO^You smell the following:" tell_both
   ref @ CONTENTS_ARRAY
   FOREACH
      swap pop 1 SMELL-obj
   REPEAT
   "^CINFO^Done." tell_both
;
 
: SMELL-help ( -- )
   {
      "^GREEN^Smell %ver - by Moose"
      "^PURPLE^~~~~~~~~~~~~~~~~~~~~~~"
      " %command                   ^WHITE^- Smells the current room and all its objects."
      " %command here              ^WHITE^- Smells the current room."
      " %command <object>          ^WHITE^- Smells the given object."
      " %command <obj1> <obj2> ... ^WHITE^- Smells the given objects."
      " "
      "^CNOTE^Properties:"
      " " PROPS-smell 23 STRleft strcat " ^WHITE^- Scent string on object, player, room." strcat
      " " PROPS-smell_ansi 23 STRleft strcat " ^WHITE^- As above, but with ansi." strcat
      " " PROPS-smell_notify 23 STRleft strcat " ^WHITE^- Notify string on player or puppet, allows ansi." strcat
      " " PROPS-smell_bridge 23 STRleft strcat " ^WHITE^- Dbref of bridge / main room of the vehicle." strcat
      " "
      "^CNOTE^Message substitutions:"
      " \r\rtarget                 ^WHITE^- Name of the target."
      " \r\rloc                    ^WHITE^- Name of the location."
      " \r\rcommand                ^WHITE^- Name of the command that triggered this."
      " \r\rver                    ^WHITE^- Version of this program."
      " "
      " ^CNOTE^All standard pronoun substitutions and MPI parsing is done on the string properties."
      "^CINFO^Done."
   }list
   FOREACH
      swap pop tell_both
   REPEAT
;
 
: main ( str:STRargs -- )
   #-1 target !
   strip dup not IF
      pop loc @ SMELL-room EXIT
   THEN
   dup "#h" stringpfx IF
      SMELL-help EXIT
   THEN
   " " explode_array
   FOREACH
      swap pop dup
      match
      dup #-2 dbcmp IF
         "^CFAIL^" rot 1 escape_ansi strcat
         "^CINFO^: I don't know which one you mean!" strcat
         tell_both CONTINUE
      THEN
      dup Ok? NOT IF
         "^CFAIL^" rot 1 escape_ansi strcat
         "^CINFO^: I cannot find that!" strcat
         tell_both CONTINUE
      THEN
      swap pop
      0 SMELL-obj
   REPEAT
;
