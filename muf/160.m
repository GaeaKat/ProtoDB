(*
   Cmd-@Ansi
   by Moose
 *)
 
$author  Moose
$version 1.0
 
: main[ str:STRargs -- ]
   STRargs @ strip dup "#help" stringcmp not IF
      {
         "^CYAN^Syntax: ^AQUA^@ansi"
         "        ^AQUA^@ansi yes"
         "        ^AQUA^@ansi on"
         "        ^AQUA^@ansi no"
         "        ^AQUA^@ansi off"
         " "
         "Changes your ANSI color to on or off, or toggles if no option given."
      }list
      { me @ }list ARRAY_ansi_notify EXIT
   THEN
   strip dup IF
      (s) CASE
         "{yes|on}" smatch WHEN
            me @ "COLOR" set
            me @ "^CSUCC^ANSI turned on." ansi_notify
         END
         "{no|off}" smatch WHEN
            me @ "!COLOR" set
            me @ "^CSUCC^ANSI turned off." ansi_notify
         END
         DEFAULT pop me @ "^CFAIL^Invalid option." ansi_notify END
      ENDCASE
   ELSE
      me @ "COLOR" Flag? IF
         me @ "!COLOR" set
      ELSE
         me @ "COLOR" set
      THEN
      me @ "^CSUCC^ANSI toggled." ansi_notify
   THEN
;
