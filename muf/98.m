(*
   Cmd-Time v1.0
   Author: Moose
 
   To do:
    - Eventually incorporate custom time zones
 *)
 
$author  Moose Alynna
$version 1.0
 
$include $lib/alynna
: main[ str:STRargs -- ]
   me @ { 
   "^CYAN^Time: ^AQUA^%l:%M:%S" systime timefmt
   systime_precise dup int - 2 fchop "." "0." subst 
   " "
   "%p %Z on %A, %B %e, %Y" systime timefmt 
   " "
   "(@" systime_precise 86400.0 fmod 86400.0 / 1000.0 * 2 fchop ")"
   }cat ansi_NOTIFY
;
