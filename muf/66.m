(*
   Cmd-@Alias
   by Moose
 *)
 
$author Moose
$version 1.0
 
: main[ str:STRalias -- ]
   STRalias @ strip dup "#help" stringcmp not IF
      pop
      {
         "^CYAN^Syntax: ^AQUA^@alias"
         "        ^AQUA^@alias <new alias>"
         " "
         "This will set a new alias for yourself.  Blank will clear it."
      }list { me @ }list ARRAY_ansi_notify EXIT
   THEN
   "*" over strcat match Ok? IF
      pop me @ "^CFAIL^A player already has that name." ansi_notify EXIT
   THEN
   dup "^" instr over "\r" instr or over "\[" instr or IF
      me @ "^CFAIL^Illegal alias name." ansi_notify EXIT
   THEN
   me @ "%n" getpropstr strip dup IF
      "^GREEN^" swap 1 escape_ansi strcat
   ELSE
      pop "^NORMAL^(Nothing)"
   THEN
   "^FOREST^Alias previously set to: " swap strcat me @ swap ansi_notify
   "^FOREST^Now set to: "
   over dup IF
      "^GREEN^" swap 1 escape_ansi strcat
   ELSE
      pop "^NORMAL^(Nothing)"
   THEN
   strcat me @ swap ansi_notify
   me @ "%n" rot strip setprop
;
