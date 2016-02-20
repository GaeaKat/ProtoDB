(*
   Cmd-@MPI v1.0
   by Moose
 *)
 
$author  Moose
$version 1.0
 
: main[ str:STRargs -- ]
   "mpi_needflag" sysparm "yes" stringcmp not IF
      me @ "MPI" Flag? not IF
         me @ "^CFAIL^Permission denied." ansi_NOTIFY
         EXIT
      THEN
   THEN
   STRargs @ strip dup not swap "#help" stringcmp not or IF
      me @ "^CYAN^Syntax: ^AQUA^" command @ 1 escape_ANSI
      strcat " <mpi code>" strcat ansi_NOTIFY
      EXIT
   THEN
   {
      "^CYAN^Command : ^AQUA^" STRargs @ 1 escape_ANSI strcat
      "^CYAN^Result  : ^AQUA^"
         me @ STRargs @ "(@mpi)" 1 parseMPI 1 escape_ANSI
         "\r          ^AQUA^" "\r" subst strcat
      "^CINFO^Done."
   }list
   {
      me @
   }list
   ARRAY_ansi_notify
;
