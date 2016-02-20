(*
   Cmd-@View v1.4
   Author: Chris Brine [Moose/Van]
   Fix by Moose:
   1.4 - Small change
   Bug fixing by Akari:
   1.3 - Fixed the '@settable' view of defintions to set the correct prop.
   1.2 - Fixed abort error when docs aren't set.
   1.1 - Made it so that the program owner can @view their own programs. 7/01
 *)
 
$author Moose
$version 1.4
$include $lib/objects
 
: PROG-info[ ref:ref -- ]
   ref @ ANSIunparse "  ^NORMAL^Owner: " strcat
   ref @ owner me @ owner over CONTROLS if
      unparseobj
   else
      name
   then
   1 escape_ansi strcat
   me @ swap ansi_notify
   ref @ "_Version" getpropstr dup if
      "^CYAN^Version " swap strcat
      me @ swap ansi_notify
   else
      pop
   then
   ref @ "_Lib-Version" getpropstr dup if
      "^CYAN^Library Version " swap strcat
      me @ swap ansi_notify
   else
      pop
   then
   me @ " " notify
;
 
: PROG-fixdocs[ ref:ref str:STRdocs -- str:STRdocs' ]
   STRdocs @ dup "-" split Number? swap Number? and not if
      pop ""
   ELSE
      dup "-" split atoi swap atoi < IF
         pop ""
      ELSE
         "@list " ref @ dtos strcat "=!" strcat swap strcat
      THEN
   then
 
;
 
: PROG-docs[ ref:ref -- ]
   VAR STRdocs
   ref @ "VIEWABLE" Flag? not me @ owner ref @ CONTROLS not and if
      me @ "^CFAIL^No documention to list." ansi_notify EXIT
   then
   ref @ dup "/_Docs" getpropstr PROG-fixdocs STRdocs !
   STRdocs @ not if exit then
   me @ "^CYAN^Document Command: ^AQUA^" STRdocs @
        1 escape_ansi strcat ansi_notify
   ref @ "/_Docs/Force?" getpropstr "yes" stringcmp not not if
      me @
      "^CNOTE^Show the documentation? ^WHITE^(^NORMAL^y^WHITE^/^NORMAL^N^WHITE^)"
      ansi_notify
      READ strip "yes" over instring 1 = and not if
         me @ "^CFAIL^Documentation listing cancelled." ansi_notify EXIT
      then
   then
   me @ STRdocs @ FORCE
   me @ " " notify
;
 
: PROG-defs[ ref:ref -- ]
   VAR LISTtype 0 VAR! IDXcnt
   ref @ "VIEWABLE" Flag? me @ owner ref @ CONTROLS or
   ref @ "/_Defs" Propdir? and not if
      me @ "^CFAIL^No definitions to list." ansi_notify EXIT
   then
   me @
   "^CNOTE^Show the definitions? ^WHITE^(^NORMAL^y^WHITE^/^NORMAL^s^WHITE^/^NORMAL^N^WHITE^)"
   me @ "^FOREST^'s' displays the definitions in @settable format." ansi_notify
   ansi_notify
   READ strip dup "yes" over instring 1 = over "s" instring 1 = or and not if
      pop me @ "^CFAIL^Definition listing cancelled." ansi_notify EXIT
   then
   "s" instring 1 = LISTtype !
   ref @ "/_Defs" array_get_propvals
   FOREACH
      LISTtype @ if
         "^WHITE^@set ^YELLOW^" ref @ name 1 escape_ansi strcat
         "^WHITE^=^GREEN^_defs/" strcat
         rot 1 escape_ansi strcat "^WHITE^:^FOREST^" strcat
         swap 1 escape_ansi strcat
      else
         "^GREEN^" rot 1 escape_ansi strcat " ^WHITE^= ^FOREST^" strcat
         swap 1 escape_ansi strcat
      then
      me @ swap ansi_notify IDXcnt ++
   REPEAT
   IDXcnt @ dup intostr swap 1 = if
      " definition listed."
   else
      " definitions listed."
   then
   strcat "^CNOTE^" swap strcat
   me @ swap ansi_notify
   me @ " " notify
;
 
: main[ str:Args -- ]
   Args @ strip dup not over "#help" stringcmp not or if
      pop me @ "^CYAN^Syntax: ^AQUA^@view <MUF program object>" ansi_notify EXIT
   then
   match dup ok? not if
      #-1 dbcmp if
         "^CINFO^I cannot find that program."
      else
         "^CINFO^I don't know which program you mean!"
      then
      me @ swap ansi_notify EXIT
   then
   dup Program? not if
      pop me @ "^CFAIL^That is not a program!" ansi_notify EXIT
   then
   dup PROG-info
   dup PROG-docs
   dup PROG-defs
   pop
   me @ "^CINFO^Done." ansi_notify
;
