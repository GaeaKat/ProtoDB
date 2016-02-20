(*
   CMD-relog.MUF v2.0 - Rewritten by Moose/Van
   * Based upon Deedlits relog program, but rewritten for more accuracy
     with the descriptors thanks to Proto.
 *)
 
$author Moose
$version 2.0
 
: main ( str:Args -- )
   command @ "out" instring if
      descr descrcon if
         descr "^CINFO^" "leave_message" sysparm 1 escape_ansi strcat 1 parse_ansi notify_descriptor
         descr DESCR_logout
      else
         descr "^CFAIL^You are already logged out!" 1 parse_ansi notify_descriptor
      then
      EXIT
   then
   strip dup not if
      pop descr "^CYAN^Usage: ^AQUA^" command @ 1 escape_ansi strcat
      " <character> <password>" strcat 1 parse_ansi notify_descriptor
      EXIT
   then
   " " split strip swap strip
   pmatch dup ok? not if
      pop pop
      descr "^CFAIL^Incorrect login or password." 1 parse_ansi notify_descriptor EXIT
   then
   swap over over CHECKpassword not if
      pop pop
      descr "^CFAIL^Incorrect login or password." 1 parse_ansi notify_descriptor EXIT
   then
   descr "^CSUCC^Logging in as: ^NORMAL^" 4 pick unparseobj
   1 escape_ansi strcat 1 parse_ansi notify_descriptor
   descr rot rot DESCR_setuser
;
