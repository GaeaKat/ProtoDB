( Cmd-ProgOwners by Moose                                                    )
( Version 1.01 by Akari 12/10/2001                                           )
(     Added comments and formatted to 80 columns.                            )
( A handy tool that quickly lists all the players on the MUCK that own MUF   )
( programs, and the number of programs they own.                             )
: main ( -- )
   VAR ref
   me @ "ARCHWIZARD" flag? not if
      me @ "^CFAIL^" "noperm_mesg" sysparm "^^" "^" subst
      strcat ansi_notify exit
   then
   { }dict #-1 ref !
   BEGIN
      ref @ NEXTPROGRAM dup ref ! ok? WHILE
      dup ref @ owner int array_getitem 1 + swap ref @ owner int array_setitem
   REPEAT
   FOREACH
      "^GREEN^" rot dbref dup unparseobj swap name strlen strcut
      "^CINFO^" swap "^^" "^" subst strcat
      swap "^^" "^" subst swap strcat strcat
      " ^WHITE^(^NORMAL^%d^WHITE^)" rot intostr "%d" subst strcat
      me @ swap ansi_notify
   REPEAT
   me @ "^CINFO^Done." ansi_notify
;
