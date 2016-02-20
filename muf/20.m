(*
   Proto-@Register v1.2
   Author: Chris Brine [Moose/Van]
   v1.2: [By Akari]
    - Fitted the fomatting to 80 colums and added new directives.
   v1.1: [By Moose]
    - Fixed the top of page link on the web pubprogs section.
   To setup for web support [assuming you setup the webserver], type:
     @propset <web room>=dbref:/_/WWW/PubProgs:<program>
 *)
 
$author Moose
$version 1.2
 
$def atell me @ swap ansi_notify
 
: Ansi-Name[ ref:ref -- str:STRname ]
   ref @ ok? not if
      ref @ #-3 dbcmp if
         "^NORMAL^*HOME*" exit
      then
      ref @ #-2 dbcmp if
         "^NORMAL^*AMBIGUOUS*" exit
      then
      ref @ #-1 dbcmp if
         "^NORMAL^*NOTHING*" exit
      then
      "^NORMAL^<garbage>^CINFO^(%s)" ref @ dtos "%s" subst exit
   then
   ref @ unparseobj ref @ name strlen strcut "^^" "^" subst "^CINFO^"
   swap strcat swap "^^" "^" subst swap strcat
   ref @ program? if
      "^RED^" swap strcat exit
   then
   ref @ player? if
      "^GREEN^" swap strcat exit
   then
   ref @ thing? if
      "^PURPLE^" swap strcat exit
   then
   ref @ room? if
      "^CYAN^" swap strcat exit
   then
   ref @ exit? if
      "^BLUE^" swap strcat exit
   then
   "^WHITE^" swap strcat
;
 
: Get-Reg-Name[ ref:ref str:STRprop -- str:STRname ]
   ref @ STRprop @ getprop dup not if
      pop "^NORMAL^(Nothing)" exit
   then
   dup string? if
      dup stod dup ok? not if
         pop strip dup if
            match
         else
            pop #-1
         then
      else
         swap pop
      then
   then
   dup lock? if
      pop "^PURPLE^(LOCK)" exit
   then
   dup int? if
      dbref
   then
   dup float? if
      int dbref
   then
   dup dbref? not if
      pop "^CRIMSON^(Unknown)" exit
   then
   dup Ansi-Name swap dup program? not if
      pop exit
   then
   dup "_Version" getpropstr strip dup if
      rot "     ^CYAN^Ver. ^WHITE^" strcat swap "^^" "^" subst strcat swap
   else
      pop
   then
   "_Lib-Version" getpropstr strip dup if
     swap "     ^BLUE^Lib.ver. ^NORMAL^" strcat swap "^^" "^" subst strcat
   else
      pop
   then
;
 
: ToDBref[ ref -- ref:ref' ]
   ref @ string? if
      ref @ stod exit
   then
   ref @ int? if
      ref @ dbref exit
   then
   ref @ float? if
      ref @ int dbref exit
   then
   ref @ dbref? if
      ref @ exit
   then
   #-1
;
 
: FixDir[ str:STRdir -- str:STRdir' ]
   STRdir @ strip "" ":" subst
   BEGIN
      dup "//" instr WHILE
      "/" "//" subst strip
   REPEAT
   BEGIN
      dup "/" rinstr over strlen = over strlen and WHILE
      dup strlen 1 - strcut pop strip
   REPEAT
   BEGIN
      dup "/" instr 1 = WHILE
      1 strcut swap pop strip
   REPEAT
   "/" swap strcat
;
 
: Muck-View[ ref:ref str:STRdir str:STRsubdir -- ]
   me @ "^CNOTE^Registered objects on " ref @ Ansi-Name strcat "^CNOTE^:"
   strcat ansi_notify
   STRdir @ FixDir dup "/" strcat STRdir ! STRsubdir @ FixDir strcat
   FixDir "/" strcat
   BEGIN
      ref @ swap NEXTPROP dup WHILE
      dup "/@" instr over "/~" instr or not me @ "ARCHWIZARD" flag? or
      ref @ #0 dbcmp or not if
         CONTINUE
      then
      ref @ over propdir? if
         "    ^FOREST^" over STRdir @ strlen strcut swap pop
         "^^" "^" subst strcat "^BLUE^/ (Directory)" strcat
         me @ swap ansi_notify
      then
      ref @ over getprop if
         "  ^FOREST^" over STRdir @ strlen strcut swap pop "^^" "^" subst
         strcat "^GREEN^: " strcat ref @ 3 pick Get-Reg-Name strcat
         me @ swap ansi_notify
         ref @ over getprop ToDBref dup program? if
            "_Note" getpropstr strip dup if
               me @ "   ^AQUA^" rot "^^" "^" subst strcat ansi_notify
            else
               pop
            then
         else
            pop
         then
      then
   REPEAT
   pop me @ "^CINFO^Done." ansi_notify
;
 
: Reg-Help[ -- ]
   me @ "^CINFO^Proto-@Register v%1.2f - by Moose" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
   me @ "^CNOTE^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" ansi_notify
   " ^WHITE^@reg [<prefix>]              ^NORMAL^- List all registered objects."
   atell
   " ^WHITE^@reg [<prefix>] <subdir>     ^NORMAL^- List all objects in subdir."
   atell
   " ^WHITE^@reg [<prefix>] =<name>      ^NORMAL^- Remove the register $<name>."
   atell
   " ^WHITE^@reg [<prefix>] <obj>=<name> ^NORMAL^- Register an object as $<name>."
   atell
   "^CINFO^Although <prefix> is not required, it could be set as:" atell
   " ^WHITE^#me               ^NORMAL^- Set yourself as the target object."
   atell
   " ^WHITE^#prop <obj>:<dir> ^NORMAL^- Set the target object and propdir."
   atell
   me @ "^CINFO^Properties:" ansi_notify
   " ^WHITE^_Note             ^NORMAL^- Note shown in @register listing." atell
   " ^WHITE^_Version          ^NORMAL^- Version info for non-library programs."
   atell
   " ^WHITE^_Lib-Version      ^NORMAL^- The version info for library programs."
   atell
   "www_root" sysparm ToDBref dup ok? if
      "/_/www/PubProgs" getprop ToDBref prog dbcmp if
         "^CINFO^To add a program to the program to the public MUF WWW list:"
         atell
         me @ "  Set the program JUMP_OK and VIEWABLE." ansi_notify
         me @ " ^CNOTE^Type the following after:" ansi_notify
         me @ "  @set <program>=_Author:<author name>" ansi_notify
         me @ "  @set <program>=@Category:<category name>" ansi_notify
         me @ "  ^CNOTE^Multiple categories can be done by seperating the name with |'s." ansi_notify
         "  lsedit <program>=/_/De   ^CNOTE^--> Enter the description." atell
      then
   else
      pop
   then
   me @ "^CINFO^Done." ansi_notify
;
 
: cmd-@register[ str:Args -- ]
   #0 VAR! ref "/_Reg" VAR! STRdir 0 VAR! GotIt?
   Args @ strip dup not if
      #0 "/_Reg" rot Muck-View exit
   then
   dup "#prop" instring 1 = over "#me" instring 1 = or if
      " " split swap
      BEGIN
         dup "#help" stringcmp not if
            pop Reg-Help exit
         then
         dup "#prop" stringcmp not if
            pop strip dup ":" instr if
                ":" split swap strip dup 1
            else
                " " split swap strip dup 0
            then
            GotIt? ! if
               match
            else
               pop me @
            then
            dup ref ! ok? not if
               pop ref @ #-1 dbcmp if
                  "^CINFO^I cannot find that here."
               else
                  "^CINFO^I don't know which one you mean!"
               then
               me @ swap ansi_notify exit
            then
            ref @ #0 dbcmp me @ ref @ controls or not if
               pop me @ "^CFAIL^" "noperm_mesg" sysparm
               "^^" "^" subst strcat ansi_notify exit
            then
            strip GotIt? @ if
               " " split swap FixDir strip STRdir ! strip
            else
               "/" STRdir !
            then
            BREAK
         then
         dup "#me" stringcmp not if
            pop me @ ref ! BREAK
         then
         pop me @ "^CFAIL^Invalid option." ansi_notify exit
      REPEAT
   then
   dup "=" instr if
      "=" split strip FixDir swap strip dup if
         match
      else
         pop #-5
      then
      dup ok? over #-5 dbcmp or not if
         #-1 dbcmp if
            "^CINFO^I cannot find that here."
         else
            "^CINFO^I don't know which one you mean!"
         then
         me @ swap ansi_notify pop exit
      then
      dup #-5 dbcmp not if
         me @ over controls not if
            pop pop me @ "^CFAIL^" "noperm_mesg" sysparm
            "^^" "^" subst strcat ansi_notify exit
         then
      then
      me @ ref @ controls not if
         pop pop me @ "^CFAIL^" "noperm_mesg" sysparm
         "^^" "^" subst strcat ansi_notify exit
      then
      swap strip dup "/" stringcmp not over not or if
         pop pop "^CFAIL^You need to @register it to something." atell exit
      then
      dup "/@" instr over "/~" instr or STRdir @ dup "/@" instr swap "/~"
      instr or or not me @ "ARCHWIZARD" flag? or not if
         pop pop "^CFAIL^You need to @register it to something." atell exit
      then
      ref @ STRdir @ rot strcat dup STRdir ! over over getprop if
         over over Get-Reg-Name
         me @ "^CNOTE^Used to be registered as " STRdir @
         "^^" "^" subst strcat ":" strcat rot strcat ansi_notify
      then
      over over 5 rotate dup #-5 dbcmp if pop remove_prop else setprop then
      Get-Reg-Name
      me @ "^CSUCC^Now registered as " STRdir @
      "^^" "^" subst strcat ":" strcat rot strcat " ^CSUCC^on " strcat
      ref @ Ansi-Name strcat "^CSUCC^." strcat ansi_notify
   else
      strip FixDir ref @ STRdir @ rot Muck-View
   then
;
 
: main[ str:Args -- ]
   Args @ strip dup "#help" stringcmp not if
      pop Reg-Help exit
   then
   "@register" command @ instring 1 = if
      cmd-@register exit
   then
   me @ "^CFAIL^What kind of command is that?" ansi_notify
;
