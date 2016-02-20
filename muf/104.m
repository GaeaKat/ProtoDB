(*
   Cmd-@MUF v1.0
   by Moose
 
   For setting this up for MPI use, you can type:
     @register <program>=Cmd/@Muf
     @set #0=/_MsgMacs/MufCode:{muf:$Cmd/@Muf,{:1};={:2};={:3}}
   NOTE: The mpi MUF coder is only allowed for W3 and up for security reasons.
 *)
 
$author  Moose
$version 1.0
 
$include $lib/file
 
: ToSTR ( ? -- str )
   dup VAR! item
   CASE
      String? WHEN
         "str:\"" item @ strcat "\"" strcat
      END
      Dictionary? WHEN
         "(Dictionary:" item @ ARRAY_count strcat " items)" strcat
      END
      Array? WHEN
         "(Array:" item @ ARRAY_count intostr strcat " items)" strcat
      END
      Int? WHEN
         "int:" item @ intostr strcat
      END
      Float? WHEN
         "float:\"" item @ FtoSTR strcat "\"" strcat
      END
      Dbref? WHEN
         "dbref:" item @ dtos strcat
      END
      Lock? WHEN
         "lock:" item @ unparselock strcat
      END
      Variable? WHEN
         "Variable"
      END
      Address? WHEN
         "Address"
      END
      Socket? WHEN
         "Socket:" item @ SOCKdescr intostr strcat
      END
      Mark? WHEN
         "{MARK}"
      END
      DEFAULT pop
         "(????)"
      END
   ENDCASE
;
 
: STACK2STR ( stack1...stacki -- STRstack )
   depth ARRAY_make "^WHITE^( ^GRAY^" swap dup ARRAY_count IF
      FOREACH
         swap 0 = not IF
            swap "^YELLOW^, ^GRAY^" strcat
         ELSE
            swap
         THEN
         swap ToSTR 1 escape_ANSI strcat
      REPEAT
      "^WHITE^)" strcat
   ELSE
      pop "^RED^Empty stack ^WHITE^)" strcat
   THEN
;
 
: main[ str:STRargs -- ]
   VAR REFprog VAR STRparams
   0 VAR! BOLdebug?
   me @ "M1" Flag? not IF
      me @ "^CFAIL^Permission denied." ansi_NOTIFY
      EXIT
   THEN
   STRargs @ dup ";!=" instr IF
      ";!=" split swap dup ";=" instr IF
         ";=" split ";!=" strcat rot strcat
      ELSE
         swap
         1 BOLdebug? !
      THEN
   ELSE
      ";=" split
   THEN
   STRparams ! STRargs !
   STRargs @ strip dup not swap "#help" stringcmp not or IF
      me @ "^CYAN^Syntax: ^AQUA^" command @ 1 escape_ANSI
      strcat " <muf code>" strcat ansi_NOTIFY
      me @ "^CYAN^Syntax: ^AQUA^" command @ 1 escape_ANSI
      strcat " <muf code>;=<string to pass to it>" strcat ansi_NOTIFY
      me @ "^CYAN^Syntax: ^AQUA^" command @ 1 escape_ANSI
      strcat " <muf code>;!= ^CNOTE^(runs in debug mode)" strcat ansi_NOTIFY
      me @ "^CYAN^Syntax: ^AQUA^" command @ 1 escape_ANSI
      strcat " <muf code>;!=<string to pass to it> ^CNOTE^(runs in debug mode)" strcat ansi_NOTIFY
      me @ "^CNOTE^NOTE: ^NORMAL^You don't need the function start nor end." ansi_NOTIFY
      EXIT
   THEN
   "TEST MUF: If this still exists then please recycle it.muf" NEWprogram REFprog !
   REFprog @ me @ SETown
   BOLdebug? @ IF
      REFprog @ "DEBUG" set
   THEN
   "$MUF/" REFprog @ int intostr strcat ".m" strcat
   {
      ": main ( str -- ??? )"
      STRargs @ "\r" "\\r" subst "\[" "\\[" subst
      ";"
   }list
   ARRAY_put_file
   me @ "^CNOTE^Attempting compile..." ansi_NOTIFY
   REFprog @ 1 compile IF
      me @ "^CSUCC^Successful." ansi_NOTIFY
      me @ "^CNOTE^Program output:" ansi_NOTIFY
      0 TRY
         STRparams @ "\r" "\\r" subst "\[" "\\[" subst REFprog @ CALL 1
      CATCH
         "^CFAIL^Error: " swap 1 escape_ANSI strcat 0
      ENDCATCH
      IF STACK2STR THEN
   ELSE
      "^CFAIL^Unable to compile the code."
   THEN
   STRparams @
   "^AQUA^[^NORMAL^" swap 1 escape_ANSI strcat "^AQUA^]" strcat
   me @ "^CYAN^MUF Code        : ^AQUA^" STRargs @ 1 escape_ANSI strcat ansi_NOTIFY
   me @ "^CYAN^Parameter       : " rot strcat ansi_NOTIFY
   me @ "^CYAN^Debug?          : ^AQUA^" BOLdebug? @ IF "Yes" ELSE "No" THEN strcat ansi_NOTIFY
   me @ "^CYAN^Resulting stack : ^AQUA^" rot 0 escape_ANSI strcat ansi_NOTIFY
   me @ "^CINFO^Done." ansi_NOTIFY
   REFprog @ RECYCLE
;
