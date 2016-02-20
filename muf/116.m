( Cmd-Check by Unknown                                                      )
( Version 1.2 by Moose 01/08/2003                                           )
(     Changed the ANSI colors around, made 'Done.' appear like it does in   )
(     most programs and inside commands [standardization! wheee!], and added)
(     a 'Checking...' line in the start.                                    )
(     NOTE: This could use a Proto face lift though                         )
( Version 1.1 by Akari 12/10/2001                                           )
(     Added ANSI to the code.                                               )
 
$version 1.2
 
$include $lib/strings
$def atell me @ swap ansi_notify
 
lvar check-obj-addr
 
: match_controlled
   dup if
      match
   else
      pop #-1
   then
   dup #-2 dbcmp if
      pop #-1 me @ "^CINFO^I don't know which one you mean!" ansi_notify exit
   then
   dup not if
      pop #-1 me @ "^CINFO^I don't see that here!" ansi_notify exit
   then
   dup ok? if
      me @ over controls not if
         pop #-1 me @ "^CFAIL^Permission denied." ansi_notify exit
      then
   then
;
 
: check-next-loop (d -- )
   dup not if pop exit then
   dup exit? over thing? or
   me @ 3 pick controls and if
      dup check-obj-addr @ execute
   then
   next check-next-loop
;
 
: check-contents (d -- )
   contents check-next-loop
;
 
: check-exits (d -- )
   exits check-next-loop
;
 
: exec-err (d mtypestr warnstr -- )
   "^NORMAL^On ^WHITE^" 4 rotate unparseobj strcat
   "^NORMAL^, in it's ^WHITE^" strcat rot strcat
   "^NORMAL^, ^WHITE^" strcat swap strcat atell
;
 
: can-linkto? (player object -- i)
   dup "link_ok" flag? if pop pop 1 exit then
   controls
;
 
: check-exec (d mtype execstr -- )
   dup "@" 1 strncmp if pop pop pop exit then
   1 strcut swap pop
   " " split pop
   dup "$" 1 strncmp not if
      dup match ok? not if
         " is not a known registered program." strcat
         exec-err exit
      then
      dup match program? not if
         " is not a program." strcat
         exec-err exit
      then
      3 pick owner over match can-linkto? not if
         " is not Link_OK." strcat
         exec-err exit
      then
   else
      dup number? not if
         " is not a program dbref." strcat
         "@" swap strcat exec-err exit
      then
      dup atoi dbref ok? not if
         " is not a valid program reference." strcat
         "@" swap strcat exec-err exit
      then
      dup atoi dbref program? not if
         " is not a valid program reference." strcat
         "@" swap strcat exec-err exit
      then
      3 pick owner over atoi dbref can-linkto? not if
         " is not Link_OK." strcat
         "@" swap strcat exec-err exit
      then
   then
   pop pop pop
;
 
 
: missing-err ( d s -- )
   swap unparseobj
   " ^NORMAL^is missing an ^WHITE^"
   strcat swap strcat
   " ^NORMAL^message." strcat "^WHITE^" swap strcat atell
;
 
: colon-err ( d s -- )
   swap unparseobj
   " has an unnecesary ':' at the start of its ^WHITE^"
   strcat swap strcat
   " ^NORMAL^message." strcat "^WHITE^" swap strcat atell
;
 
: check-desc (d -- )
   dup ansidesc not if
      dup desc not if
         dup "@description" missing-err
      else
         dup "@description" over
         desc check-exec
      then
   then
   dup desc not if
      dup ansidesc not if
         dup "@ansidescription" missing-err
      else
         dup "@ansidescription" over
         ansidesc check-exec
      then
   then
   pop
;
 
: check-succ (d -- )
   dup succ not if
      "@success" missing-err
   else
      "@success" over
      succ check-exec
   then
;
 
: check-fail (d -- )
   dup fail not if
      "@fail" missing-err
   else
      "@fail" over
      fail check-exec
   then
;
 
: check-drop (d -- )
   dup drop not if
      "@drop" missing-err
   else
      "@drop" over
      drop check-exec
   then
;
 
: check-osucc (d -- )
   dup osucc not if
      "@osuccess" missing-err
   else
      dup osucc ":" 1 strncmp not if
         "@osuccess" colon-err
      else pop
      then
   then
;
 
: check-ofail (d -- )
   dup ofail not if
      "@ofail" missing-err
   else
      dup ofail ":" 1 strncmp not if
         "@ofail" colon-err
      else pop
      then
   then
;
 
: check-odrop (d -- )
   dup odrop not if
      "@odrop" missing-err
   else
      dup odrop ":" 1 strncmp not if
         "@odrop" colon-err
      else pop
      then
   then
;
 
$define islocked? (d -- i) getlockstr "*UNLOCKED*" stringcmp $enddef
 
: islocked_always? (d -- i)
   getlockstr dup "#0" stringcmp not if pop 1 exit then
   dup "#" STRsplit swap pop atoi
   "#" swap intostr strcat
   (lockstr "#dbref")
   dup "&!" over strcat strcat
   3 pick stringcmp not if pop pop 1 exit then
   "&" over strcat strcat "!" swap strcat
   stringcmp not if 1 exit then
   0
;
 
: check-link ( d -- )
   dup getlink not if
      dup unparseobj " ^NORMAL^is unlinked." strcat "^WHITE^" swap strcat atell
   else
      dup getlink over location dbcmp if
         dup islocked? not if
            dup unparseobj
            " ^NORMAL^is linked to it's location, but is unlocked." strcat
            "^WHITE^" swap strcat atell
         then
      else (is not linked to it's location)
         dup getlink program? if
            dup dup owner swap getlink can-linkto? not if
               dup unparseobj
               " ^NORMAL^is linked to a program which is not Link_OK."
               strcat "^WHITE^" swap strcat atell
            then
         then
      then
   then
   pop
;
 
: check-room (d -- )
   dup check-desc
   dup islocked? if
      dup islocked_always? not if
         dup check-succ
      then
      dup check-fail
   then
   dup getlink if
      dup check-drop
      dup check-odrop
   then
   dup check-contents
   check-exits
;
 
: check-exit ( d -- )
   dup check-link
   dup check-desc
   dup getlink dup ok? if
      program? not if
         dup islocked_always? not if
            dup check-succ
            dup check-osucc
            dup check-odrop
         then
         dup islocked? if
            dup check-fail
            dup check-ofail
         then
      then
   else pop
   then
   pop
;
 
: check-thing ( d -- )
   dup check-desc
   dup islocked_always? not if
      dup check-succ
      dup check-osucc
   then
   dup islocked? if
      dup check-fail
      dup check-ofail
   then
   dup check-drop
   dup check-odrop
   check-exits
;
 
: check-player ( d -- )
   dup check-desc
   dup islocked_always? not if
      dup check-succ
      dup check-osucc
   then
   dup islocked? if
      dup check-fail
      dup check-ofail
   then
   dup check-contents
   check-exits
;
 
: check-program ( d -- )
   check-desc
;
 
: check-obj (d -- )
   dup room?   if check-room   exit then
   dup exit?   if check-exit   exit then
   dup thing?  if check-thing  exit then
   dup player? if check-player exit then
   check-program
;
 
: main
   'check-obj check-obj-addr !
   strip dup not if pop "here" then
   match_controlled
   dup #-3 dbcmp if pop me @ getlink then
   dup ok? not if pop exit then
   me @ "^CINFO^Checking..." ansi_notify
   check-obj
   me @ "^CINFO^Done." ansi_notify
;
