(*
   Cmd-PutPull v1.0
   by Moose
 *)
 
$author  Moose
$version 1.0
 
$include $lib/standard
 
: PUTPULL-mesg[ ref:REFcon ref:REFobj str:STRmsg str:STRomsg str:STRprop -- ]
   STRprop @ dup IF
      REFcon @ swap "(putpull)" 0 parseprop
   THEN
   dup strip not IF
      pop STRmsg @ dup IF
         STRmsg @
      ELSE
         pop STRomsg @
         me @ name " " strcat swap strcat
      THEN
   ELSE
      me @ name " " strcat swap strcat
   THEN
   "%c" "%C" subst "%t" "%T" subst
   REFcon @ name "%c" subst
   REFobj @ dup #-10 dbcmp IF
      pop "all held objects"
   ELSE
      name
   THEN
   "%t" subst
   me @ swap pronoun_sub
   loc @ "^CMOVE^" rot strcat #-1 swap ansi_notify_except
;
 
: PUTPULL-help[ -- ]
   {
      "^CYAN^Syntax: ^AQUA^put  <object> in <container/object>"
      "        ^AQUA^put  all in <container/object>"
      "        ^AQUA^pull <object> from <container/object>"
      "        ^AQUA^pull all from <container/object>"
      "^CNOTE^Note: you can use \"=\", \" in \", or \" from \" in between the two objects."
   }list
   { me @ }list array_ansi_notify
;
 
: Trans-Container ( str:STRcon -- ref:ref )
   VAR STRlock
   strip dup IF
      match
   ELSE
      pop me @ PROPS-container_db getprop
      dup Dbref? not IF
         dup String? IF
            stod
         ELSE
            dup Int? IF
               dbref
            ELSE
               pop #-1
            THEN
         THEN
      THEN
   THEN
   dup Ok? not IF
      EXIT
   THEN
   me @ "WIZARD" Flag? IF
      EXIT
   THEN
   dup location loc @ dbcmp
   over location me @ dbcmp or not IF
      pop #-3 EXIT
   THEN
   dup PROPS-container? getpropstr "y" stringpfx not IF
      me @ over controls not IF
         pop #-4 EXIT
      THEN
   THEN
   dup "/_/Clk" getprop Lock? IF
      PREEMPT
      dup "/_/Lok" getprop STRlock !
      dup "/_/Clk" getprop
      over "/_/Lok" rot setprop
      1 TRY
         me @ over Locked?
      CATCH
         over "/_/Lok" STRlock @ setprop abort
      ENDCATCH
      over "/_/Lok" STRlock @ setprop
      FOREGROUND
      IF
         pop #-5
      THEN
   THEN
;
 
: main ( str:STRargs -- )
   0 VAR! QuietMove?
   command @ "q" stringpfx IF
      command @ 1 strcut swap pop command ! 1 QuietMove? !
   THEN
   strip dup not over "#help" stringcmp not or IF
      pop PUTPULL-help EXIT
   THEN
   "="  " in "  subst
   "=" " from " subst
   "=" split dup strip not IF
      pop pop
      me @ "^CFAIL^Incorrect syntax." ansi_notify
      PUTPULL-help EXIT
   THEN
   Trans-Container
   (d) CASE
      #-5 dbcmp WHEN
         me @ "^CFAIL^Permission denied on the container." ansi_notify
      END
      #-4 dbcmp WHEN
         me @ "^CINFO^That isn't a container." ansi_notify
      END
      #-3 dbcmp WHEN
         me @ "^CINFO^You cannot use a container from far away." ansi_notify
      END
      #-2 dbcmp WHEN
         me @ "^CINFO^I don't know which container you mean!" ansi_notify
      END
      dup #-1 dbcmp swap Ok? not or WHEN
         me @ "^CINFO^I cannot find that container here." ansi_notify
      END
      Room? WHEN
         me @ "^CINFO^A room cannot be a container." ansi_notify
      END
      Exit? WHEN
         me @ "^CINFO^An exit cannot be a container." ansi_notify
      END
      Program? WHEN
         me @ "^CINFO^A program cannot be a container." ansi_notify
      END
$ifdef Hold-Container?
      location me @ dbcmp not WHEN
         me @ "^CINFO^You have to be holding the container before using it." ansi_notify
      THEN
$endif
      DEFAULT
         swap strip dup not IF
            pop me @ "^CFAIL^Incorrect syntax." ansi_notify
            PUTPULL-help EXIT
         THEN
         dup "all" stringcmp not over "*" stringcmp not or IF
            pop #-10
         ELSE
            command @ "pull" stringcmp not IF
               over swap rmatch
            ELSE (put)
               match
            THEN
         THEN
         dup #-2 dbcmp IF
            pop pop me @ "^CINFO^I don't know which object you mean!" ansi_notify EXIT
         THEN
         dup Ok? not over #-10 dbcmp not and IF
            pop pop me @ "^CINFO^I cannot find that object there." ansi_notify EXIT
         THEN
         over over dbcmp IF
            pop pop me @ "^CINFO^Why the same objects?" ansi_notify EXIT
         THEN
         dup Exit? IF
            pop pop me @ "^CINFO^You cannot move an exit." ansi_notify EXIT
         THEN
         dup Room? IF
            pop pop me @ "^CINFO^You cannot move a room." ansi_notify EXIT
         THEN
         me @ "WIZARD" Flag? not IF
            dup Player? IF
               pop pop me @ "^CINFO^You cannot move a player." ansi_notify EXIT
            THEN
         THEN
         dup me @ dbcmp IF
            pop pop me @ "^CINFO^You cannot move yourself." ansi_notify EXIT
         THEN
         dup #-10 dbcmp not IF me @ over controls not ELSE 0 THEN IF
            dup Thing? over "VEHICLE" Flag? and IF
               pop pop me @ "^CINFO^You cannot move a vehicle." ansi_notify EXIT
            THEN
            dup Thing? over "ZOMBIE" Flag? and IF
               pop pop me @ "^CINFO^You cannot move a puppet." ansi_notify EXIT
            THEN
         THEN
         command @ "pull" stringcmp not IF
            dup #-10 dbcmp not IF over over location dbcmp not ELSE 0 THEN IF
               pop pop me @ "^CINFO^That object is not in that container." ansi_notify EXIT
            THEN
            dup #-10 dbcmp IF
               over CONTENTS_ARRAY
               FOREACH
                  swap pop me @ moveto
               REPEAT
            ELSE
               dup me @ moveto
            THEN
            QuietMove? @ IF
               MESG-pull "" ""
            ELSE
               "" MESG-opull PROPS-pull
            THEN
         ELSE (put)
            me @ "WIZARD" Flag? not IF
               dup  location loc @ dbcmp
               over location me  @ dbcmp or not IF
                  pop pop me @ "^CINFO^You cannot move an object from far away." ansi_notify EXIT
               THEN
            THEN
            dup #-10 dbcmp IF
               swap me @ CONTENTS_ARRAY
               FOREACH
                  swap pop over
                  over over dbcmp IF
                     pop pop
                  ELSE
                     moveto
                  THEN
               REPEAT
               swap
            ELSE
               over over swap moveto
            THEN
            QuietMove? @ IF
               MESG-put "" ""
            ELSE
               "" MESG-oput PROPS-put
            THEN
         THEN
         PUTPULL-mesg
      END
   ENDCASE
;
