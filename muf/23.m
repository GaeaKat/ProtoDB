(*
   Cmd-Globals v1.0.1
   Author: Chris Brine [Moose/Van]
 
   For compatability, the action name should be as follows:
      globals;+globals;global;+globals;+help;lhelp;+lhelp
 
   PROPERTIES:
    ~COMMAND / ACTION~
      _help/docs   -or-   docs
           You can either set this as a listfile or a normal comment.  It
           also accepts MUSH-style ansi codes, and also allows the use
           of the %r return key if it is a one-line comment.  Set this on
           individual actions. <ie. 'lsedit page=_help/docs'>  The prop
           _comment also works for a one-line comment, but not a listfile.
      _prefs/subj
           Set this to a subject / catagory that you wish for the specific
           action / command to be in.  If it is not set then it will be
           placed within the default group.  The default group name is not
           shown if no catagories are made.
      _help/option?
           Set this to 'yes' if your program has an internal help system
           and you'd prefer to run it.  Only works for an action that is
           linked to a program.  Defaults to #help.
      _help/args
           Set this to the arguments to pass to the help system.  If it is
           {NULL} then it will send a null string.  If it isn't set to
           anything, then it it will pass #help.
    ~'GLOBALS' ACTION~
      _prefs/def
           Set this to the default group name.
      _hide/<command name>
           Set this to 'yes' if you wish to hide a specific command / action
           from any globals listing.
      _help/<command name>
           This allows you to set a listfile or one-line comment for any
           new page additions / commands that you wish to add to the globals
           listing.
      _cat/<command name>
           If you wish to place a command in _help/<command name> into a
           specific catagory then set this to 'yes'.
   FLAGS:
    ~COMMAND / ACTION~
      PARENT
           If you set this then all of the exits / commands on a specific
           exit dbref will be revealed in the globals listing.
      DARK
           Hide the exit from the globals listing, unless set LIGHT.
      LIGHT
           Show the exit regardless of there being a DARK flag set or not.
*)
 
$author Moose
$version 1.01
 
$include $lib/arrays
$include $lib/strings
 
$def Def-Group "Miscellaneous" (* Set this to the default catagory name *)
 
VAR BOLnohelp
 
: DefGroup[ ref:ref -- str:Group ]
   ref @ "_Prefs/Def" getpropstr dup strip not if
      pop trig "_Prefs/Def" getpropstr dup strip not if
         pop Def-Group
      then
   then
;
 
: GET-group[ ref:ref str:STRname -- str:STRgroup ]
   trig "_Cat/" STRname @ strcat getpropstr dup strip not if
      pop ref @ "_Prefs/Subj" getpropstr dup strip not if
         pop ref @ "_Catagory" getpropstr dup strip not if
           pop ref @ DefGroup
         then
      then
   then
;
 
: GET-help[ ref:ref str:STRname -- arr:ARRhelp ]
   trig "_Help/" STRname @ strcat array_get_proplist dup array_count not if
      pop ref @ "_Help/Docs" array_get_proplist dup array_count not if
         pop ref @ "Docs" array_get_proplist dup array_count not if
            pop ref @ "_Comment" array_get_proplist dup array_count not if
               pop trig "_Help/" STRname @ strcat getpropstr dup strip not if
                  pop ref @ "_Help/Docs" getpropstr dup strip not if
                     pop ref @ "Docs" getpropstr dup strip not if
                        pop ref @ "_Comment" getpropstr dup strip not if
                           pop { }list EXIT
                        then
                     then
                  then
               then
               { swap }list
            then
         then
      then
   then
;
 
: NAME-hide?[ ref:ref str:STRname -- int:BOLhide? ]
   trig "_Hide/" STRname @ strcat getpropstr "yes" stringcmp not not if
      ref @ "_Hide/" STRname @ strcat getpropstr "yes" stringcmp not not if
         ref @ "_Listed?" getpropstr "no" stringcmp not
      else
         1
      then
   else
      1
   then
;
 
: NAME-help?[ ref:ref str:STRname -- int:BOLhide? ]
   ref @ STRname @ GET-help array_count not not
   ref @ "/_Help/Option?" getpropstr "yes" stringcmp not
   ref @ getlink Program? and or
;
 
: GET-action[ dict:GBlist ref:ref arr:ARRnames int:INTnotref? -- dict:GBlist ]
           VAR  STRgroup
           VAR  STRfixname
           VAR  STRname
   ARRnames @
   FOREACH
      swap pop dup STRname ! "" ":" subst strip
      BEGIN
         dup "/" rinstr over strlen = over and WHILE
         dup strlen 1 - strcut pop strip
      REPEAT
      STRfixname !
      ref @ STRfixname @ NAME-hide? if
         CONTINUE
      then
      ref @ STRfixname @ NAME-help? if
         " "
      else
         "^RED^*" 1 BOLnohelp !
      then
      "^AQUA^" strcat STRname @ 14 STRleft "^^" "^" subst strcat STRname !
      ref @ STRfixname @ GET-group STRgroup !
      GBlist @ STRgroup @ array_getitem array? if
         GBlist @ STRgroup @ array_getitem
      else
         { }list
      then
      dup STRname @ array_findval array_count not if
         STRname @ swap array_appenditem
      then
      GBlist @ STRgroup @ array_setitem GBlist !
   REPEAT
   GBlist @
;
 
: GET-ref-globals[ arr:CMDlist -- dict:GBlist ]
           VAR  ref
   { }dict VAR! GBlist
   CMDlist @
   FOREACH
      swap pop ref !
      ref @ dbref? if
         ref @ "DARK" flag? ref @ "LIGHT" flag? not and if
            CONTINUE
         then
         ref @ "PARENT" flag? if
            ref @ name ";" explode_array
         else
            { ref @ name ";" split pop }list
         then
         GBlist @ ref @ rot 0 GET-action GBlist !
      else
         GBlist @ ref @ array_vals pop { swap }list 1 GET-action GBlist !
      then
   REPEAT
   GBlist @
;
 
: array_get_refpropvals[ ref:ref str:STRprop -- arr:ARRprops ]
   { }list ref @ STRprop @ array_get_propvals
   FOREACH
      pop ref @ STRprop @ rot strcat array_make swap array_appenditem
   REPEAT
;
 
: GRAB-globals[ -- arr:ARRglobals ]
   VAR ARRlocs VAR ref { }list VAR! CMDlist VAR ARRrefs
   trig "_Locs" array_get_reflist #0 swap array_appenditem array_nodups ARRrefs ! me @ ref !
   ARRrefs @
   FOREACH
      swap pop ref !
      ref @ EXITS_ARRAY
(
      "enable_commandprops" sysparm "yes" stringcmp not if
         ref @ "@Command/" array_get_refpropvals array_union
         ref @ "COMMAND" flag? if
            ref @ "~Command/" array_get_refpropvals array_union
            ref @ "_Command/" array_get_refpropvals array_union
         then
      then
)
      CMDlist @ array_union CMDlist !
   REPEAT
   CMDlist @ trig "_Help/" array_get_refpropvals array_union
;
 
: GET-globals[ -- dict:GBlist ]
   GRAB-globals GET-ref-globals
;
 
: NAB-global[ str:STRname -- globalinfo str:REFname ]
   VAR ref { #-1 "" }list VAR! refmatch VAR refname
   GRAB-globals
   FOREACH
      swap pop dup ref ! dbref? if
         ref @ dup "DARK" flag? swap "LIGHT" flag? not and if
            CONTINUE
         then
         ref @ "PARENT" flag? if
            ref @ name ";" explode_array
         else
            { ref @ name ";" split pop }list
         then
         FOREACH
            swap pop refname !
            ref @ refname @ NAME-hide? if
               CONTINUE
            then
            refname @ STRname @ stringcmp not if
               ref @ refname @ EXIT
            then
            ref @ name STRname @ instring if
               refmatch @ dup dbref? swap array? or if
                  { #-2 "" }list refmatch ! CONTINUE
               then
               { ref @ refname @ }list refmatch !
            then
         REPEAT
      else
         ref @ array? if
            ref @ 1 array_getitem "/" split swap pop refname !
            refname @ STRname @ stringcmp not if
               ref @ refname ! EXIT
            then
            STRname @ instring if
               refmatch @ dup dbref? swap array? or if
                  { #-2 "" }list refmatch ! CONTINUE
               then
               { ref @ refname @ }list refmatch !
            then
         then
      then
   REPEAT
   refmatch @ array_vals pop
;
 
: SHOW-globals[ -- ]
   GET-globals VAR! GBlist VAR CATname VAR GBcnt
   "^PURPLE^Globals Listing for " "muckname" sysparm "^^" "^" subst strcat dup neon_strlen 76 < if
      " ^VIOLET^" strcat
      dup neon_strlen 78 1 FOR
         pop "-" strcat
      REPEAT
      dup neon_strlen 78 > if
         78 neon_strcut pop
      then
   else
      75 neon_strcut pop " ^VIOLET^--" strcat
   then
   me @ swap ansi_notify
   GBlist @
   FOREACH
      SORTTYPE_NOCASE_ASCEND \array_sort GBlist ! CATname !
      me @ "^BLUE^[:%s:]" CATname @ "^^" "^" subst "%s" subst ansi_notify
      0 GBcnt ! "" GBlist @
      FOREACH
         swap pop strcat GBcnt dup ++ @ 5 >= if
            me @ swap ansi_notify "" 0 GBcnt !
         then
      REPEAT
      dup if
         me @ swap ansi_notify
      else
         pop
      then
   REPEAT
   me @ "^CYAN^To get help on a topic, type: ^AQUA^globals <topic>" ansi_notify
   BOLnohelp @ if
      me @ "^RED^* ^BROWN^--> ^AQUA^Means that there is no help set on globals for it." ansi_notify
   then
   me @ "^PURPLE^------------------------------------------------------------------------------" ansi_notify
;
 
: VIEW-header[ str:GBLname -- ]
   "^PURPLE^--< ^YELLOW^" GBLname @ toupper strcat dup neon_strlen 75 < if
      " ^PURPLE^>" strcat
      dup neon_strlen 78 1 FOR
         pop "-" strcat
      REPEAT
      dup neon_strlen 78 > if
         78 neon_strcut pop
      then
   else
      74 neon_strcut pop " ^PURPLE^>--" strcat
   then
   me @ swap ansi_notify
;
 
: VIEW-footer[ -- ]
   me @ "^PURPLE^------------------------------------------------------------------------------" ansi_notify
;
 
: VIEW-global[ str:STRname -- ]
   VAR GBLname VAR GBLhelp
   STRname @ NAB-global GBLname ! dup dbref? if
      dup ok? not if
         #-1 dbcmp if
            "^CINFO^I cannot find that global."
         else
            "^CINFO^I don't know which global you mean!"
         then
         me @ swap ansi_notify exit
      then
      dup "/_Help/Option?" getpropstr "yes" stringcmp not
      over getlink Program? and if
         dup trigger !
         GBLname @ command !
         GBLname @ VIEW-header
         1 TRY
            dup "/_Help/Args" getpropstr dup not if
               pop "#help"
            else
               dup "{NULL}" stringcmp not if
                  pop ""
               then
            then
            swap getlink CALL
         CATCH
            pop me @ "^CFAIL^There is no help for this topic." ansi_notify
            trigger @ "/_Help/Option?" remove_prop
         ENDCATCH
         VIEW-footer EXIT
      then
      (dbref) GBLname @ GET-help dup array_count not if
         { "^CFAIL^There is no help for this topic." }list
      then
      GBLhelp !
   else
      0 array_getitem GBLname @ GET-help dup array_count not if
         { "^CFAIL^There is no help for this topic." }list
      then
      GBLhelp !
   then
   GBLname @ VIEW-header
   GBLhelp @ { me @ }list array_ansi_notify
   VIEW-footer
;
 
: GLOBALS-main[ str:Args -- ]
   0 BOLnohelp !
   Args @ strip dup Args ! if
      Args @ VIEW-global
   else
      SHOW-globals
   then
;
