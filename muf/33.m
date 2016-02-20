(*
  Lib-Editor v2.1.5
  Author: Chris Brine [Moose/Van]
  2.1.4 [Akari] Cleaned up formatting to 80 column width. Added $pubdefs.
  2.1.5 [Akari] Fixed the dumb bug of losing the buffer when using .help. :P
  Demands Proto 1.50 or newer!
  Credits:
   Foxen/Revar: Wrote the original $lib/editor
   Deedlit    : Added the new |<command> parser
   Moose/Van  : Rewrote $lib/editor with array support, added support
                for more than one custom command, added tons of new
                commands, and made lsedit a part of $lib/editor now.
  Note: This also replaces cmd-lsedit,  so feel free to remove  that
        muf program and link the lsedit action to this library.  Also,
        lib-editor no longer demands the use of any other library.
  Information:
   Syntax for argument array:
    <0: 1stInt> <1: 2ndInt> <2: Str> <3: Full Argument string>
    Which starts as: 1stInt/2ndInt=Str
   Syntax for new public functions
   [the old ones will be phased out, thus not documented]:
    ArrayEDITOR [ aList -- aList' sExitcmd ]
     - Edit a one-dimensional array of strings, then returns the new array
       and the command used for exiting.
    ArrayEDITORloop [ aList aMask iCurPos sCmdStr iShowExitMsg? --
                      aList' aMask' iCurPos' aArgs sExitcmd ]
     - The loop used in ArrayEDITOR that allows you to also define new
       commands for the editor and run an intial command.
     Syntax:
       aList   = One-dimensional array of strings to edit
       aMask   = One-dimensional array of command strings
                 [Ie. { "lhelp" "undo" "save" }list]
        Note:
         The '.lhelp' command is commonly used for a local help screen for a
         programs internal commands. Ie. Say you add a .cc or .add command it
         is put there.
         Also, when a command is used in 'aMask' it quits the loop. It is the
         MUF coders responsibility to restart the loop if necessary.
       aArgs   = The argument array.
       sCmdstr = The initial command to run for the loop
       iShowExitMsg? = Set to '1' to show the exit messages, or '0' to not show
       it.
       iCurPos = Current position in the array[+1]
       sExitcmd = The command used when exiting the loop.
    ArrayEDITORparse [ aList aMask iCurPos sCmdstr iShowExitMsg? --
                       aList aMask iCurPos [aArgs sExitcmd] iContinue ]
     - This does not loop but merely parses the current command string.  The
       syntax is exactly like ArrayEDITORloop, except if iContinue is equal to 1
       then aArgs and sExitcmd are not returned, but if it is 0 then they are.
    EDITORprop [ dObject sListprop -- ]
     - This goes into an lsedit editor that will edit a specific
       proplist on an object.
     Syntax:
       dObject   = The object that the proplist is on
       sListProp = The proplist to edit
*)
 
$include $lib/arrays
 
: EDITORerror ( iErrnum -- )
   BEGIN dup
       1 = IF pop "Invalid line reference." BREAK THEN DUP
       2 = IF POP "Error: Line referred to is before first line." BREAK THEN DUP
       3 = IF POP "Error: Line referred to is after last line." BREAK THEN DUP
       4 = IF POP "Error: 1st line ref is after 2nd reference." BREAK THEN DUP
       5 = IF POP "Warning: First line reference ignored." BREAK THEN DUP
       6 = IF POP "Warning: Second line reference ignored."BREAK THEN DUP
       7 = IF POP "Warning: String argument ignored." BREAK THEN DUP
       8 = IF POP "Error: Unknown command.  Enter '.h' for help." BREAK THEN DUP
       9 = IF POP "Error: Command needs string parameter." BREAK THEN DUP
      10 = IF POP "Error: Must have pattern to search for." BREAK THEN DUP
      11 = IF POP "Error: Must have a destination line reference." BREAK THEN
              DUP
      12 = IF POP "Error: Columns parameter invalid." BREAK THEN DUP
      13 = IF POP "Error: Inappropriate syntax for string." BREAK THEN DUP
      14 = IF POP "Error: Object not found." BREAK THEN DUP
      15 = IF POP "Error: Permission denied." BREAK THEN DUP
      16 = IF POP "Error: No line to delete." BREAK THEN DUP
      POP 1 IF pop "Unknown error." BREAK THEN DUP
   POP POP 1 UNTIL
   "^CYAN^< ** ^NORMAL^" swap strcat " ^CYAN^** >" strcat
   me @ swap ansi_notify
;
 
: domath[ int:CURcount int:CURnum int:CURnum2 int:EQtype -- int:INTreturn ]
   EQtype @
   BEGIN
      dup 0 = if pop curcount @ curnum @ + curnum2 @ + curcount ! BREAK then
      dup 1 = if pop curcount @ curnum @ - curnum2 @ - curcount ! BREAK then
      dup 2 = if pop curcount @ curnum @ * curnum2 @ * curcount ! BREAK then
      dup 3 = if pop curcount @ curnum @ / curnum2 @ / curcount ! BREAK then
      pop BREAK
   REPEAT
   curcount @
;
 
: EDITORargument[ int:ENDline int:CURline str:STRline -- int:INTline ]
    "" VAR! CURnum  0  VAR! count  0  VAR! cureq
    STRline @
    BEGIN
       strip dup WHILE
       1 strcut swap
       dup "$" stringcmp not if
          pop count @ curnum @ atoi endline @ 1 + cureq @ domath count !
          "" curnum ! CONTINUE
       then
       dup "." stringcmp not if
          pop count @ curnum @ atoi curline @ cureq @ domath count !
          "" curnum ! CONTINUE
       then
       dup "^" stringcmp not if
          pop count @ curnum @ atoi 1 cureq @ domath count !
          "" curnum ! CONTINUE
       then
       dup "+" stringcmp not if
          pop count @ curnum @ atoi cureq @ dup 2 < if 0 else 1 then swap
          domath count ! 0 cureq ! "" curnum ! CONTINUE
       then
       dup "-" stringcmp not if
          pop count @ curnum @ atoi cureq @ dup 2 < if 0 else 1 then swap
          domath count ! 1 cureq ! "" curnum ! CONTINUE
       then
       dup "*" stringcmp not if
          pop count @ curnum @ atoi cureq @ dup 2 < if 0 else 1 then swap
          domath count ! 2 cureq ! "" curnum ! CONTINUE
       then
       dup "/" stringcmp not if
          pop count @ curnum @ atoi cureq @ dup 2 < if 0 else 1 then swap
          domath count ! 3 cureq ! "" curnum ! CONTINUE
       then
       dup number? if
          curnum @ swap strcat curnum ! CONTINUE
       then
       pop 1 EDITORerror 0 count ! BREAK
    REPEAT pop
    count @ curnum @ dup if atoi cureq @ dup 2 < if 0 else 1 then swap
    domath else pop then
    dup endline @ 1 + > if
       pop endline @ 1 +
    then
    dup 1 < if
       pop 1
    then
;
 
: EDITORmesg[ arr:Args str:Msg -- ]
   Msg @ dup strip not if
      pop pop exit
   then
   "%1" args @ 0 array_getitem intostr swap subst
   "%2" args @ 1 array_getitem intostr swap subst
   "%3" args @ 2 array_getitem dup int? if intostr then dup strip
   not if pop "0" then swap subst
   me @ swap ansi_notify
;
 
: parsestuff[ arr:Alist arr:SMask int:CURpos str:CMDstr int:EXITmsg
              -- arr:Alist arr:SMask int:CURpos [arr:AArgs str:CMDstr] int:BOLcontinue? ]
   VAR aargs VAR shownlines VAR sbegin VAR send VAR fullargs
   alist @ array_count      VAR! endpos
 
   cmdstr @
   dup ".\"" 2 strncmp not over ".:" 2 strncmp not or over ".|" 2 strncmp not or
   over ".." 2 strncmp not or if 1 strcut swap pop 1 else 0 then swap
   "." 1 strncmp or if
      cmdstr @ "." instr 1 = if
         cmdstr @ 1 strcut swap pop cmdstr !
      then
      curpos @ 1 - alist @ cmdstr @ array_placeitem smask @ curpos @ 1 + 1 exit
   then
 
   cmdstr @ " " split dup strip fullargs ! swap 1 strcut swap pop
   cmdstr ! "=" split strip swap strip
   dup if
      " " split strip swap strip
      alist @ array_count curpos @ rot EDITORargument
      swap dup if
         alist @ array_count curpos @ rot EDITORargument
         over over > if
            4 EDITORerror
            pop pop pop alist @ smask @ curpos @ 1 exit
         then
      else
         pop 0
      then
   else
      pop 0 0
   then
   rot fullargs @ 4 array_make aargs !
 
   smask @ cmdstr @ array_findval array_count 0 > if
      alist @ smask @ curpos @ aargs @ cmdstr @ 0 exit
   then
 
   cmdstr @ "i" stringcmp not if
      aargs @ 1 array_getitem if 6 EDITORerror then
      aargs @ 0 array_getitem not
          if curpos @ aargs @ 0 array_setitem aargs ! then
      aargs @ 2 array_getitem if 7 EDITORerror then
      aargs @ 0 array_getitem dup curpos ! 0 "" 3 array_make
      "^CYAN^< ^NORMAL^Inserting at line ^WHITE^%1 ^CYAN^>" EDITORmesg
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "l" stringcmp not if
      aargs @ 2 array_getitem if 7 EDITORerror then
      aargs @ 0 array_getitem alist @ array_count
      > if alist @ array_count aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem alist @ array_count
      > if alist @ array_count aargs @ 1 array_setitem aargs ! then
      aargs @ 0 array_getitem not if 1 aargs @ 0 array_setitem
          alist @ array_count swap 1 array_setitem aargs !
      then
      me @ alist @ aargs @ dup 0 array_getitem 1 - swap 1 array_getitem
      1 - over over 2 array_make shownlines ! 0 ARRlist
      shownlines @ array_vals pop 1 + swap 1 + swap dup if
         over over = if
            pop 1
         else
            1 + over -
         then
      else
         pop 1
      then
      over 1 < if swap pop 1 swap then
      "" 3 array_make
      "^CYAN^< ^NORMAL^listed ^WHITE^%2 ^NORMAL^lines starting at line ^WHITE^%1 ^CYAN^>"
      EDITORmesg
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "p" stringcmp not if
      aargs @ 2 array_getitem if 7 EDITORerror then
      aargs @ 0 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 1 array_setitem aargs ! then
      aargs @ 0 array_getitem not if
          1 aargs @ 0 array_setitem
          alist @ array_count swap 1 array_setitem aargs !
      then
      me @ alist @ aargs @ dup 0 array_getitem 1 - swap
      1 array_getitem 1 - over over 2 array_make shownlines ! 1 ARRlist
      shownlines @ array_vals pop 1 + swap 1 + swap dup if
         over over = if
            pop 1
         else
            1 + over -
         then
      else
         pop 1
      then
      over 1 < if swap pop 1 swap then
      "" 3 array_make
      "^CYAN^< ^NORMAL^listed ^WHITE^%2 ^NORMAL^lines starting at line ^WHITE^%1 ^CYAN^>"
      EDITORmesg
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "del" stringcmp not if
      aargs @ 2 array_getitem if 7 EDITORerror then
      aargs @ 0 array_getitem not if { 0 0 0 }list
      "^CYAN^< ^NORMAL^No line to delete. ^CYAN^>" EDITORmesg
      alist @ smask @ curpos @ 1 exit then
      aargs @ 0 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 1 array_setitem aargs ! then
      aargs @ 0 array_getitem dup 1 <
      if pop 1 1 aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem > if
          aargs @ 0 array_getitem aargs @ 1 array_setitem aargs !
      then
      alist @ array_count not if 16 EDITORerror else
      alist @ aargs @ dup 0 array_getitem 1 - swap 1 array_getitem 1 -
      over over 2 array_make shownlines ! array_delrange alist !
      shownlines @ array_vals pop 1 + swap 1 + swap dup if
         over over = if
            pop 1
         else
            1 + over -
         then
      else
         pop 1
      then
      over 1 < if swap pop 1 swap then over curpos !
      "" 3 array_make
      "^CYAN^< ^NORMAL^deleting ^WHITE^%2 ^NORMAL^lines starting at line ^WHITE^%1 ^NORMAL^(^WHITE^Now current line^NORMAL^) ^CYAN^>"
      EDITORmesg then
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "copy" stringcmp not if
      aargs @ 2 array_getitem number? not
      if 12 EDITORerror alist @ smask @ curpos @ 1 exit then
      aargs @ 0 array_getitem not
      if { 0 0 0 }list "^CYAN^< ^NORMAL^No line to copy. ^CYAN^>" EDITORmesg
          alist @ smask @ curpos @ 1 exit
      then
      aargs @ 0 array_getitem alist @ array_count > if
          alist @ array_count aargs @ 0 array_setitem aargs !
      then
      aargs @ 1 array_getitem alist @ array_count > if
          alist @ array_count aargs @ 1 array_setitem aargs !
      then
      aargs @ 0 array_getitem dup 1 < if
          1 aargs @ 0 array_setitem aargs !
      then
      aargs @ 1 array_getitem > if
          aargs @ 0 array_getitem aargs @ 1 array_setitem aargs !
      then
      aargs @ 2 array_getitem atoi 1 < if "1" aargs @ 2 array_setitem then
      aargs @ 2 array_getitem atoi alist @ array_count >
      if alist @ array_count aargs @ 2 array_setitem then
      alist @ aargs @ dup 0 array_getitem 1 - swap 1 array_getitem
      1 - over over 2 array_make shownlines !
      aargs @ 2 array_getitem atoi 1 - ARRcopy alist !
      shownlines @ array_vals pop 1 + swap 1 + swap dup if
         over over = if
            pop 1
         else
            1 + over -
         then
      else
         pop 1
      then
      over 1 < if swap pop 1 swap then
      aargs @ 2 array_getitem dup atoi curpos ! 3 array_make
      "^CYAN^< ^NORMAL^Copying ^WHITE^%2 ^NORMAL^lines from line ^WHITE^%1 ^NORMAL^to line ^WHITE^%3 ^NORMAL^(^WHITE^now current line^NORMAL^) ^CYAN^>"
      EDITORmesg
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "move" stringcmp not if
      aargs @ 2 array_getitem number? not
      if 12 EDITORerror alist @ smask @ curpos @ 1 exit then
      aargs @ 0 array_getitem not
      if { 0 0 0 }list "^CYAN^< ^NORMAL^No line to move. ^CYAN^>" EDITORmesg
          alist @ smask @ curpos @ 1 exit
      then
      aargs @ 0 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 1 array_setitem aargs ! then
      aargs @ 0 array_getitem dup 1 < if 1 aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem >
          if aargs @ 0 array_getitem aargs @ 1 array_setitem aargs !
      then
      aargs @ 2 array_getitem atoi 1 < if "1" aargs @ 2 array_setitem then
      aargs @ 2 array_getitem atoi alist @ array_count >
      if alist @ array_count aargs @ 2 array_setitem then
      alist @ aargs @ dup 0 array_getitem 1 - swap 1
      array_getitem 1 - over over 2 array_make shownlines !
      aargs @ 2 array_getitem atoi 1 - ARRmove alist !
      shownlines @ array_vals pop 1 + swap 1 + swap dup if
         over over = if
            pop 1
         else
            1 + over -
         then
      else
         pop 1
      then
      over 1 < if swap pop 1 swap then
      aargs @ 2 array_getitem dup atoi curpos ! 3 array_make
      "^CYAN^< ^NORMAL^Moving ^WHITE^%2 ^NORMAL^lines from line ^WHITE^%1 ^NORMAL^to line ^WHITE^%3 ^NORMAL^(^WHITE^dest now curr line^NORMAL^) ^CYAN^>"
      EDITORmesg
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "find" stringcmp not if
      aargs @ 2 array_getitem not
      if 10 EDITORerror alist @ smask @ curpos @ 1 exit then
      aargs @ 1 array_getitem if 6 EDITORerror then
      aargs @ 0 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 0 array_setitem aargs ! then
      aargs @ 0 array_getitem not if 1 aargs @ 0 array_setitem then
      aargs @ 0 array_getitem 1 - alist @ aargs @ 2 array_getitem ARRsearch
      dup -1 = if
         pop { 0 0 0 }list "^CYAN^< ^NORMAL^pattern not found ^CYAN^>" EDITORmesg
      else
         1 + { over 0 0 }list
         "^CYAN^< ^NORMAL^Found.  Going to line ^WHITE^%1 ^CYAN^>" EDITORmesg
         alist @ over 1 - array_getitem aargs @ 2 array_getitem "^WHITE^" over
         strcat "^NORMAL^" strcat swap subst
         swap intostr "^WHITE^" swap strcat "^NORMAL^: " strcat 1
         array_make 0 0 5 " " ARRright array_vals pop swap strcat
         me @ swap notify
      then
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "repl" stringcmp not if
      aargs @ 2 array_getitem dup "/" instr 1 = swap "/" rinstr 1 = not and not
      if 10 EDITORerror alist @ smask @ curpos @ 1 exit then
      aargs @ 0 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 1 array_setitem aargs ! then
      aargs @ 0 array_getitem dup 1 < if 1 aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem >
      if aargs @ 0 array_getitem aargs @ 1 array_setitem aargs ! then
      alist @ aargs @ dup 0 array_getitem 1 - swap 1 array_getitem 1 - over over
      2 array_make shownlines ! aargs @ 2 array_getitem 1 strcut swap pop "/"
      split swap ARRreplace alist !
      shownlines @ array_vals pop pop 1 + dup curpos ! 0 0 3 array_make
      "^CYAN^< ^NORMAL^Replaced.  Going to line ^WHITE^%1 ^CYAN^>" EDITORmesg
      me @ alist @ aargs @ dup 0 array_getitem 1 - swap 1 array_getitem 1 - 1
      ARRlist
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "join" stringcmp not if
      aargs @ 2 array_getitem if 7 EDITORerror then
      aargs @ 0 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 1 array_setitem aargs ! then
      aargs @ 0 array_getitem not
      if 1 aargs @ 0 array_setitem
          alist @ array_count swap 1 array_setitem aargs !
      then
      alist @ aargs @ dup 0 array_getitem 1 - dup 1 + curpos ! swap 1
          array_getitem 1 - over over 2 array_make shownlines ! " "
          ARRjoinrng alist !
      shownlines @ array_vals pop 1 + swap 1 + swap dup if
         over over = if
            pop 1
         else
            1 + over -
         then
      else
         pop 1
      then
      over 1 < if swap pop 1 swap then
      "" 3 array_make
      "^CYAN^< ^NORMAL^Joining ^WHITE^%2 ^NORMAL^lines starting at line ^WHITE^%1 ^NORMAL^(^WHITE^Now current line^NORMAL^) ^CYAN^>"
      EDITORmesg
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "split" stringcmp not if
      var curstr
      aargs @ 2 array_getitem dup curstr ! not
      if 9 EDITORerror alist @ smask @ curpos @ 1 exit then
      aargs @ 1 array_getitem if 6 EDITORerror then
      aargs @ 0 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 0 array_setitem aargs ! then
      aargs @ 0 array_getitem 1 < if 1 aargs @ 0 array_setitem aargs ! then
      alist @ aargs @ 0 array_getitem 1 - dup 1 + curpos ! array_getitem dup
      curstr @ instr if
         dup curstr @ instr curstr @ strlen 1 - + strcut swap alist @
         curpos @ 1 - array_setitem curpos @ 1 - array_insertitem alist !
      then
      { curpos @ 0 0 }list
      "^CYAN^< ^NORMAL^Split line ^WHITE^%1^NORMAL^. (^WHITE^Now current line^NORMAL^) ^CYAN^>"
      EDITORmesg
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "left" stringcmp not if
      aargs @ 2 array_getitem dup number? not swap "0" strcmp not or
      if "72" aargs @ 2 array_setitem aargs ! then
      aargs @ 2 array_getitem atoi 160 >
      if "160" aargs @ 2 array_setitem aargs ! then
      aargs @ 2 array_getitem atoi 40 <
      if "40" aargs @ 2 array_setitem aargs ! then
      aargs @ 0 array_getitem not if { 0 0 0 }list
      "^CYAN^< ^NORMAL^No line to justify. ^CYAN^>" EDITORmesg
      alist @ smask @ curpos @ 1 exit then
      aargs @ 0 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 1 array_setitem aargs ! then
      aargs @ 0 array_getitem dup 1 < if 1 aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem > if
          aargs @ 0 array_getitem aargs @ 1 array_setitem aargs !
      then
      alist @ aargs @ dup 0 array_getitem 1 - swap 1
      array_getitem 1 - over over 2 array_make shownlines !
      aargs @ 2 array_getitem atoi " " ARRleft alist !
      shownlines @ array_vals pop 1 + swap 1 + swap dup if
         over over = if
            pop 1
         else
            1 + over -
         then
      else
         pop 1
      then
      over 1 < if swap pop 1 swap then
      aargs @ 2 array_getitem 3 array_make
      "^CYAN^< ^NORMAL^Left justified ^WHITE^%2 ^NORMAL^lines starting at line ^WHITE^%1 ^NORMAL^to column ^WHITE^%3 ^CYAN^>"
      EDITORmesg
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "center" stringcmp not if
      aargs @ 2 array_getitem dup number? not swap "0" strcmp not or
      if "72" aargs @ 2 array_setitem aargs ! then
      aargs @ 2 array_getitem atoi 160 >
      if "160" aargs @ 2 array_setitem aargs ! then
      aargs @ 2 array_getitem atoi 40 <
      if "40" aargs @ 2 array_setitem aargs ! then
      aargs @ 0 array_getitem not if { 0 0 0 }list
      "^CYAN^< ^NORMAL^No line to justify. ^CYAN^>" EDITORmesg
      alist @ smask @ curpos @ 1 exit then
      aargs @ 0 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 1 array_setitem aargs ! then
      aargs @ 0 array_getitem dup 1 < if 1 aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem >
      if aargs @ 0 array_getitem aargs @ 1 array_setitem aargs ! then
      alist @ aargs @ dup 0 array_getitem 1 - swap 1 array_getitem 1 - over over
      2 array_make shownlines ! aargs @ 2 array_getitem atoi " " ARRCenter
      alist !
      shownlines @ array_vals pop 1 + swap 1 + swap dup if
         over over = if
            pop 1
         else
            1 + over -
         then
      else
         pop 1
      then
      over 1 < if swap pop 1 swap then
      aargs @ 2 array_getitem 3 array_make
      "^CYAN^< ^NORMAL^Centered ^WHITE^%2 ^NORMAL^lines starting at line ^WHITE^%1 ^NORMAL^for screenwidth ^WHITE^%3 ^CYAN^>"
      EDITORmesg
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "right" stringcmp not if
      aargs @ 2 array_getitem dup number? not swap "0" strcmp not or
      if "72" aargs @ 2 array_setitem aargs ! then
      aargs @ 2 array_getitem atoi 160 >
      if "160" aargs @ 2 array_setitem aargs ! then
      aargs @ 2 array_getitem atoi 40 <
      if "40" aargs @ 2 array_setitem aargs ! then
      aargs @ 0 array_getitem not if { 0 0 0 }list
      "^CYAN^< ^NORMAL^No line to justify. ^CYAN^>" EDITORmesg
      alist @ smask @ curpos @ 1 exit then
      aargs @ 0 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 1 array_setitem aargs ! then
      aargs @ 0 array_getitem dup 1 < if 1 aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem >
      if aargs @ 0 array_getitem aargs @ 1 array_setitem aargs ! then
      alist @ aargs @ dup 0 array_getitem 1 - swap 1 array_getitem 1 - over over
      2 array_make shownlines ! aargs @ 2 array_getitem atoi " " ARRright
      alist !
      shownlines @ array_vals pop 1 + swap 1 + swap dup if
         over over = if
            pop 1
         else
            1 + over -
         then
      else
         pop 1
      then
      over 1 < if swap pop 1 swap then
      aargs @ 2 array_getitem 3 array_make
      "^CYAN^< ^NORMAL^Right justified ^WHITE^%2 ^NORMAL^lines starting at line ^WHITE^%1 ^NORMAL^to column ^WHITE^%3 ^CYAN^>"
      EDITORmesg
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "indent" stringcmp not if
      aargs @ 2 array_getitem dup number? not swap "0" strcmp not or
      if "2" aargs @ 2 array_setitem aargs ! then
      aargs @ 2 array_getitem atoi 80 >
      if "80" aargs @ 2 array_setitem aargs ! then
      aargs @ 2 array_getitem atoi -80 <
      if "-80" aargs @ 2 array_setitem aargs ! then
      aargs @ 0 array_getitem not
      if { 0 0 0 }list "^CYAN^< ^NORMAL^No line to justify. ^CYAN^>" EDITORmesg
          alist @ smask @ curpos @ 1 exit
      then
      aargs @ 0 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 1 array_setitem aargs ! then
      aargs @ 0 array_getitem dup 1 < if 1 aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem >
      if aargs @ 0 array_getitem aargs @ 1 array_setitem aargs ! then
      alist @ aargs @ dup 0 array_getitem 1 - swap 1 array_getitem 1 - over over
      2 array_make shownlines ! aargs @ 2 array_getitem atoi " " ARRindent
      alist !
      shownlines @ array_vals pop 1 + swap 1 + swap dup if
         over over = if
            pop 1
         else
            1 + over -
         then
      else
         pop 1
      then
      over 1 < if swap pop 1 swap then
      aargs @ 2 array_getitem 3 array_make
      "^CYAN^< ^NORMAL^Indented ^WHITE^%2 ^NORMAL^lines starting at line ^WHITE^%1 ^NORMAL^, ^WHITE^%3 ^NORMAL^columns ^CYAN^>"
      EDITORmesg
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "format" stringcmp not if
      aargs @ 2 array_getitem dup number? not swap "0" strcmp not or
      if "72" aargs @ 2 array_setitem aargs ! then
      aargs @ 2 array_getitem atoi 160 >
      if "160" aargs @ 2 array_setitem aargs ! then
      aargs @ 2 array_getitem atoi 40 <
      if "40" aargs @ 2 array_setitem aargs ! then
      aargs @ 0 array_getitem not
      if { 0 0 0 }list "^CYAN^< ^NORMAL^No line to justify. ^CYAN^>" EDITORmesg
      alist @ smask @ curpos @ 1 exit then
      aargs @ 0 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 1 array_setitem aargs ! then
      aargs @ 0 array_getitem dup 1 < if 1 aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem >
      if aargs @ 0 array_getitem aargs @ 1 array_setitem aargs ! then
      alist @ aargs @ dup 0 array_getitem 1 - swap 1 array_getitem 1 - over over
      2 array_make shownlines ! aargs @ 2 array_getitem atoi ARRformat alist !
      shownlines @ array_vals pop 1 + swap 1 + swap dup if
         over over = if
            pop 1
         else
            1 + over -
         then
      else
         pop 1
      then
      over 1 < if swap pop 1 swap then over curpos !
      aargs @ 2 array_getitem 3 array_make
      "^CYAN^< ^NORMAL^Formatted ^WHITE^%2 ^NORMAL^lines starting at line ^WHITE^%1 ^NORMAL^(^WHITE^Now curr line^NORMAL^) to ^WHITE^%3 ^NORMAL^columns ^CYAN^>"
      EDITORmesg
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "ansi" stringcmp not if
      me @ "WIZARD" Flag? if
         aargs @ 2 array_getitem dup number? not
         if "1" aargs @ 2 array_setitem aargs ! then
         aargs @ 2 array_getitem atoi 2 >
         if "2" aargs @ 2 array_setitem aargs ! then
         aargs @ 2 array_getitem atoi 0 <
         if "0" aargs @ 2 array_setitem aargs ! then
         aargs @ 0 array_getitem not
         if { 0 0 0 }list "^CYAN^< ^NORMAL^No line to ansify. ^CYAN^>" EDITORmesg alist @ smask @ curpos @ 1 exit then
         aargs @ 0 array_getitem alist @ array_count >
         if alist @ array_count aargs @ 0 array_setitem aargs ! then
         aargs @ 1 array_getitem alist @ array_count >
         if alist @ array_count aargs @ 1 array_setitem aargs ! then
         aargs @ 0 array_getitem dup 1 <
         if 1 aargs @ 0 array_setitem aargs ! then
         aargs @ 1 array_getitem >
         if aargs @ 0 array_getitem aargs @ 1 array_setitem aargs ! then
         alist @ aargs @ dup 0 array_getitem 1 - swap 1 array_getitem 1 - over
         over 2 array_make shownlines ! aargs @ 2 array_getitem atoi ARRparse_ansi alist !
         shownlines @ array_vals pop 1 + swap 1 + swap dup if
            over over = if
               pop 1
            else
               1 + over -
            then
         else
            pop 1
         then
         over 1 < if swap pop 1 swap then over curpos !
         aargs @ 2 array_getitem 3 array_make
         "^CYAN^< ^NORMAL^Parsed ansi for ^WHITE^%2 ^NORMAL^lines starting at line ^WHITE^%1 ^NORMAL^(^WHITE^Now curr line^NORMAL^) to type ^WHITE^%3 ^NORMAL^ ^CYAN^>"
         EDITORmesg
      else
         { 0 0 0 }list "^CYAN^< ^CFAIL^Ansi parsing functions can only be used by admin in the editor. ^CYAN^>"
         EDITORmesg
      then
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "unparse" stringcmp not if
      me @ "WIZARD" Flag? if
         aargs @ 2 array_getitem dup number? not
         if "1" aargs @ 2 array_setitem aargs ! then
         aargs @ 2 array_getitem atoi 2 >
         if "2" aargs @ 2 array_setitem aargs ! then
         aargs @ 2 array_getitem atoi 0 <
         if "0" aargs @ 2 array_setitem aargs ! then
         aargs @ 0 array_getitem not if { 0 0 0 }list
         "^CYAN^< ^NORMAL^No line to unparse the ansi. ^CYAN^>" EDITORmesg
         alist @ smask @ curpos @ 1 exit then
         aargs @ 0 array_getitem alist @ array_count >
         if alist @ array_count aargs @ 0 array_setitem aargs ! then
         aargs @ 1 array_getitem alist @ array_count >
         if alist @ array_count aargs @ 1 array_setitem aargs ! then
         aargs @ 0 array_getitem dup 1 <
         if 1 aargs @ 0 array_setitem aargs ! then
         aargs @ 1 array_getitem >
         if aargs @ 0 array_getitem aargs @ 1 array_setitem aargs ! then
         alist @ aargs @ dup 0 array_getitem 1 - swap 1 array_getitem 1 - over
         over 2 array_make shownlines ! aargs @ 2 array_getitem atoi
         ARRunparse_ansi alist !
         shownlines @ array_vals pop 1 + swap 1 + swap dup if
            over over = if
               pop 1
            else
               1 + over -
            then
         else
            pop 1
         then
         over 1 < if swap pop 1 swap then over curpos !
         aargs @ 2 array_getitem 3 array_make
         "^CYAN^< ^NORMAL^Unarsed ansi for ^WHITE^%2 ^NORMAL^lines starting at line ^WHITE^%1 ^NORMAL^(^WHITE^Now curr line^NORMAL^) to type ^WHITE^%3 ^NORMAL^ ^CYAN^>"
         EDITORmesg
      else
         { 0 0 0 }list
         "^CYAN^< ^CFAIL^Ansi parsing functions can only be used by admin in the editor. ^CYAN^>"
         EDITORmesg
      then
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "escape" stringcmp not if
      me @ "WIZARD" Flag? if
         aargs @ 2 array_getitem dup number? not
         if "1" aargs @ 2 array_setitem aargs ! then
         aargs @ 2 array_getitem atoi 2 >
         if "2" aargs @ 2 array_setitem aargs ! then
         aargs @ 2 array_getitem atoi 0 <
         if "0" aargs @ 2 array_setitem aargs ! then
         aargs @ 0 array_getitem not
         if { 0 0 0 }list
             "^CYAN^< ^NORMAL^No line to escape the ansi. ^CYAN^>" EDITORmesg
             alist @ smask @ curpos @ 1 exit
         then
         aargs @ 0 array_getitem alist @ array_count >
         if alist @ array_count aargs @ 0 array_setitem aargs ! then
         aargs @ 1 array_getitem alist @ array_count >
         if alist @ array_count aargs @ 1 array_setitem aargs ! then
         aargs @ 0 array_getitem dup 1 <
         if 1 aargs @ 0 array_setitem aargs ! then
         aargs @ 1 array_getitem >
         if aargs @ 0 array_getitem aargs @ 1 array_setitem aargs ! then
         alist @ aargs @ dup 0 array_getitem 1 - swap 1 array_getitem 1 -
         over over 2 array_make shownlines ! aargs @ 2 array_getitem atoi
         ARRescape_ansi alist !
         shownlines @ array_vals pop 1 + swap 1 + swap dup if
            over over = if
               pop 1
            else
               1 + over -
            then
         else
            pop 1
         then
         over 1 < if swap pop 1 swap then over curpos !
         aargs @ 2 array_getitem 3 array_make
         "^CYAN^< ^NORMAL^Escaped ansi codes for ^WHITE^%2 ^NORMAL^lines starting at line ^WHITE^%1 ^NORMAL^(^WHITE^Now curr line^NORMAL^) to type ^WHITE^%3 ^NORMAL^ ^CYAN^>"
         EDITORmesg
      else
         { 0 0 0 }list "^CYAN^< ^CFAIL^Ansi parsing functions can only be used by admin in the editor. ^CYAN^>" EDITORmesg
      then
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "mpi" stringcmp not if
      var temparray
      aargs @ 2 array_getitem if 7 EDITORerror then
      aargs @ 0 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 1 array_setitem aargs ! then
      aargs @ 0 array_getitem not
      if 1 aargs @ 0 array_setitem alist @ array_count
          swap 1 array_setitem aargs !
      then
      me @ alist @ aargs @ dup 0 array_getitem 1 - swap 1 array_getitem 1 - over
      over 2 array_make shownlines ! "(lib-editor)" 1 ARRmpiparse temparray !
      shownlines @ array_vals pop 1 + swap 1 + swap dup if
         over over = if
            pop 1
         else
            1 + over -
         then
      else
         pop 1
      then
      over 1 < if swap pop 1 swap then
      "" 3 array_make
      "^CYAN^< ^NORMAL^tested for mpi ^WHITE^%2 ^NORMAL^lines starting at line ^WHITE^%1 ^CYAN^>"
      EDITORmesg
      me @ temparray @ 0 over array_count 0 ARRlist
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "paste" stringcmp not if
      var spos var tpos
      aargs @ 1 array_getitem if 6 EDITORerror then
      aargs @ 0 array_getitem alist @ array_count > if alist @ array_count
      aargs @ 0 array_setitem aargs ! then
      aargs @ 0 array_getitem dup not if pop curpos @ then spos !
      alist @ array_count 1 + dup spos @ < if spos ! else pop then
      aargs @ 2 array_getitem dup "/" instr not
      if pop 13 EDITORerror alist @ smask @ curpos @ 1 exit then
      dup "/" instr 1 - strcut 1 strcut swap pop strip swap strip match dup ok?
      not if pop pop 14 EDITORerror alist @ smask @ curpos @ 1 exit then
      me @ over controls not
      if pop pop 15 EDITORerror alist @ smask @ curpos @ 1 exit then
      swap dup not if pop pop 9 EDITORerror alist @ smask @ curpos @ 1 exit then
      array_get_proplist dup array_count tpos ! alist @ spos @ 1 - rot
      array_insertrange alist !
      tpos @ spos @ 0 3 array_make
      "^CYAN^< ^WHITE^%1 ^NORMAL^lines pasted to line ^WHITE^%2 ^NORMAL^(^WHITE^Current line^NORMAL^) ^CYAN^>"
      EDITORmesg spos @ curpos !
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "sort" stringcmp not if
      var sfwd? 0 sfwd? !
      aargs @ 0 array_getitem alist @ array_count 1 - >
      if alist @ array_count 1 - aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem alist @ array_count 1 - >
      if alist @ array_count 1 - aargs @ 1 array_setitem aargs ! then
      aargs @ 2 array_getitem "reverse" stringcmp if 1 sfwd? ! then
      aargs @ 1 array_getitem dup not if pop alist @ array_count then 1 - send !
      aargs @ 0 array_getitem dup not if pop 1 then 1 - sbegin !
      alist @ sbegin @ send @ array_getrange sfwd? @
      if SORTTYPE_NOCASE_ASCEND else SORTTYPE_NOCASE_DESCEND then
      \array_sort alist @ sbegin @ send @ array_delrange sbegin @ rot
      array_insertrange alist !
      send @ sbegin @ - 1 + sbegin @ 1 + dup curpos ! 0 3 array_make
      "^CYAN^< ^NORMAL^Sorted ^WHITE^%1 ^NORMAL^lines starting at line ^WHITE^%2 ^NORMAL^(^WHITE^Now current line^NORMAL^) ^CYAN^>"
      EDITORmesg
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "scramble" stringcmp not if
      aargs @ 2 array_getitem if 7 EDITORerror then
      aargs @ 0 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 0 array_setitem aargs ! then
      aargs @ 1 array_getitem alist @ array_count >
      if alist @ array_count aargs @ 1 array_setitem aargs ! then
      aargs @ 1 array_getitem dup not if pop alist @ array_count then 1 - send !
      aargs @ 0 array_getitem dup not if pop 1 then 1 - sbegin !
      alist @ sbegin @ send @ array_getrange ARRshuffle alist @ sbegin @ send @
      array_delrange sbegin @ rot array_insertrange alist !
      send @ sbegin @ - 1 + sbegin @ 1 + dup curpos ! 0 3 array_make
      "^CYAN^m< ^NORMAL^Scrambled ^WHITE^%1 ^NORMAL^lines starting at line ^WHITE^%2 ^NORMAL^(^WHITE^Now current line^NORMAL^) ^CYAN^>"
      EDITORmesg
      alist @ smask @ curpos @ 1 exit
   then
   cmdstr @ "end" stringcmp not if
      exitmsg @ if
         { 0 0 "" "" }list "^CYAN^< ^NORMAL^Editor exited. ^CYAN^>" EDITORmesg
      then
      alist @ smask @ curpos @ aargs @ cmdstr @ 0 exit
   then
   cmdstr @ "abort" stringcmp not if
      exitmsg @ if
         { 0 0 "" "" }list "^CYAN^< ^NORMAL^Editor aborted. ^CYAN^>" EDITORmesg
      then
      0 array_make smask @ curpos @ aargs @ cmdstr @ 0 exit
   then
   cmdstr @ "h" stringcmp not cmdstr @ "help" stringcmp not or if
      me @ "          ^CYAN^MUFedit Help Screen.  Arguments in [] are optional." ansi_notify
      me @ "    ^NAVY^Any line not starting with a '^BLUE^.^NAVY^' is inserted at the current line." ansi_notify
      me @ "^NAVY^Lines starting with '^BLUE^..^NAVY^', '^BLUE^.\"^NAVY^' , or '^BLUE^.:^NAVY^' are added with the '^BLUE^.^NAVY^' removed." ansi_notify
      me @ "^NAVY^Sarting with '^BLUE^.|^NAVY^' will remove the '^BLUE^.^NAVY^' in the editor." ansi_notify
      me @ "^YELLOW^-------  ^BROWN^st = start line   en = end line   de = destination line  ^YELLOW^-------" ansi_notify
      me @ " ^WHITE^.end                      ^NORMAL^Exits the editor with the changes intact." ansi_notify
      me @ " ^WHITE^.abort                    ^NORMAL^Aborts the edit." ansi_notify
      me @ " ^WHITE^.h[elp]                   ^NORMAL^Displays this help screen." ansi_notify
      me @ " ^WHITE^.i [st]                   ^NORMAL^Changes the current line for insertion." ansi_notify
      me @ " ^WHITE^.l [st [en]]              ^NORMAL^Lists the line(s) given. (if none, lists all.)" ansi_notify
      me @ " ^WHITE^.p [st [en]]              ^NORMAL^Like .l, except that it prints line numbers too." ansi_notify
      me @ " ^WHITE^.del [st [en]]            ^NORMAL^Deletes the given lines, or the current one." ansi_notify
      me @ " ^WHITE^.copy [st [en]]=de        ^NORMAL^Copies the given range of lines to the dest." ansi_notify
      me @ " ^WHITE^.move [st [en]]=de        ^NORMAL^Moves the given range of lines to the dest." ansi_notify
      me @ " ^WHITE^.find [st]=text           ^NORMAL^Searches for the given text starting at line start." ansi_notify
      me @ " ^WHITE^.repl [st [en]]=/old/new  ^NORMAL^Replaces old text with new in the given lines." ansi_notify
      me @ " ^WHITE^.join [st [en]]           ^NORMAL^Joins together the lines given in the range." ansi_notify
      me @ " ^WHITE^.split [st]=text          ^NORMAL^Splits given line into 2 lines.  Splits after text" ansi_notify
      me @ " ^WHITE^.left [st [en]]           ^NORMAL^Aligns all the text to the left side of the screen." ansi_notify
      me @ " ^WHITE^.center [st [en]]=cols    ^NORMAL^Centers the given lines for cols screenwidth." ansi_notify
      me @ " ^WHITE^.right [st [en]]=col      ^NORMAL^Right justifies to column col." ansi_notify
      me @ " ^WHITE^.indent [st [en]]=cols    ^NORMAL^Indents or undents text by cols characters" ansi_notify
      me @ " ^WHITE^.format [st [en]]=cols    ^NORMAL^Formats text nicely to cols columns." ansi_notify
      me @ " ^WHITE^.mpi [st [en]]            ^NORMAL^Tests the mpi code in the given lines." ansi_notify
      me @ " ^WHITE^.paste [st]=[db]/[lsprop] ^NORMAL^Grabs a list of strings and pastes them to the editor." ansi_notify
      me @ " ^WHITE^.sort [st [en]][=reverse] ^NORMAL^Sorts the list in order to being forward or reverse." ansi_notify
      me @ " ^WHITE^.scramble [st [en]]       ^NORMAL^Randomize the strings in the list." ansi_notify
     me @ "WIZARD" Flag? if
      me @ " ^WHITE^.ansi [st [en]]=[atype]   ^NORMAL^Parses ansi to standard ansi for the lines. [1 = neon, 2 = mush]." ansi_notify
      me @ " ^WHITE^.unparse [st [en]]=[atype]^NORMAL^Unparses ansi codes for the given type. [0 = standard, 1 = neon, 2 = mush]" ansi_notify
      me @ " ^WHITE^.escape [st [en]]=[atype] ^NORMAL^Escapes the ansi codes to be displayable. [atype same as .unparse]" ansi_notify
     then
      me @ " ^WHITE^.lhelp                    ^NORMAL^Shows a help screen for the program running the editor." ansi_notify
      me @ "^YELLOW^---- ^BROWN^Example line refs:  $ = last line, . = curr line, ^^ = first line. ^YELLOW^----" ansi_notify
      me @ "^NAVY^12 15 (^BLUE^lines 12 to 15^NAVY^)    5 $ (^BLUE^line 5 to last line^NAVY^)    ^^+3 6 (^BLUE^lines 4 to 6^NAVY^)" ansi_notify
      me @ "^NAVY^.+2 $-3 (^BLUE^curr line + 2 to last line - 3^NAVY^)     5 +3 (^BLUE^line 5 to curr line + 3^NAVY^)" ansi_notify
      me @ "_prefs/lstoggle" getpropstr strip "alt" stringcmp not if
      me @ "^YELLOW^Note: ^BROWN^For every line, MUFedit command, etc, prepend it with a(nother) .(period) for it to" ansi_notify
         me @ "      ^BROWN^work.  Otherwise it will run what you type as a command." ansi_notify
         me @ "      ^BROWN^Type '^YELLOW^@set me=_prefs/lstoggle:^BROWN^' to change how this works." ansi_notify
      else
         me @ "^YELLOW^Note: ^BROWN^To run any command in the editor type: ^YELLOW^|<any command>" ansi_notify
         me @ "      ^BROWN^Type '^YELLOW^|@set me=_prefs/lstoggle:alt^YELLOW^' to change how this works." ansi_notify
      then
      smask @ "lhelp" array_findval array_count 0 > if
         alist @ smask @ curpos @ { 0 0 "" "" }list "lhelp" 0 exit
      else
         me @ "^YELLOW^Done." ansi_notify
         alist @ smask @ curpos @ 1 exit
      then
   then
   cmdstr @ "lhelp" stringcmp not if
      me @ "^RED^There is no help screen for the program running this editor."
      ansi_notify alist @ smask @ curpos @ 1 exit
   then
   8 EDITORerror alist @ smask @ curpos @ 1 exit
;
 
: ArrayEDITORparse ( aList aMask iCurPos sCmdstr iShowExitMsg? --
                     aList aMask iCurPos [aArgs sExitcmd] iContinue )
( Note: args and exitcmd are not returned if 'iContinue' is equal to 1 )
   var showexitmsg? showexitmsg? !
   var args { 0 0 "" }list args !
   begin
      dup not while
      pop read
   repeat
   me @ "_prefs/lstoggle" getpropstr strip "alt" stringcmp not if
      dup "." instr 1 = if
         1 strcut swap pop showexitmsg? @ parsestuff
      else
         dup if
            me @ swap force 1 exit
         else
            me @ "^CINFO^You need to type in something to run!" ansi_notify
            pop 1 exit
         then
      then
   else
      dup "|" instr 1 = if
         1 strcut swap pop dup if
            me @ swap force 1 exit
         else
            me @ "^CINFO^You need to type in something to run!"
            ansi_notify pop 1 exit
         then
      else
         showexitmsg? @ parsestuff
      then
   then
;
 
: EDITORparse ( {rng} sMask iCurPos sCmdstr --
           {rng} sMask iCurPos [sArgStr3 iArgInt1 iArgInt2 sExitCmd] iContinue )
   var icontinue
   rot 1 array_make -3 rotate 3 array_make over 2 + -1 * rotate array_make
   swap array_vals pop 1 ArrayEDITORparse
   dup icontinue ! not if
      swap array_vals pop pop 4 rotate 6 rotate array_vals pop -6 rotate
      6 array_make swap array_vals dup 2 + rotate array_vals pop
   else
      swap array_vals pop swap 2 array_make swap array_vals dup
      2 + rotate array_vals pop
   then
   icontinue @
;
 
: ArrayEDITORloop ( aList aMask iCurPos sCmdStr iShowExitMsg? --
                    aList aMask iCurPos aArgs sExitcmd )
   var showexitmsg showexitmsg !
   var cmdstr cmdstr !
   dup 1 < if pop 1 then
   begin
       cmdstr @ showexitmsg @ ArrayEDITORparse while "" cmdstr !
   repeat
;
 
: EDITORloop ( {rng} sMask iCurPos sCmdStr --
                       {rng} sMask iCurPos sArgStr3 iArgInt1 iArgInt2 sExitcmd )
   rot 1 array_make -3 rotate 3 array_make over 2 + -1 * rotate array_make swap
   array_vals pop 1 ArrayEDITORloop
   swap array_vals pop pop -3 rotate 4 rotate 6 rotate array_vals pop -6 rotate
   6 array_make swap array_vals dup 2 + rotate array_vals pop
;
 
: EDITORheader ( -- )
   me @ "_prefs/lstoggle" getpropstr strip "alt" stringcmp not if
      me @ "^CYAN^<  ^NORMAL^Welcome to the list editor.  You can get help by entering '^WHITE^..h^NORMAL^'.  ^CYAN^>" ansi_notify
      me @ "^CYAN^<  ^NORMAL^'^WHITE^..end^NORMAL^' will exit and save the list, '^WHITE^..abort^NORMAL^' will abort any     ^CYAN^>" ansi_notify
      me @ "^CYAN^<  ^NORMAL^changes.   Remember, ANYTHING to be sent to the editor must have  ^CYAN^>" ansi_notify
      me @ "^CYAN^<  ^NORMAL^a '^WHITE^.^NORMAL^' mark placed at the start to be recoginized.                 ^CYAN^>" ansi_notify
   else
      me @ "^CYAN^<  ^NORMAL^Welcome to the list editor.  You can get help be entering '^WHITE^.h^NORMAL^'.   ^CYAN^>" ansi_notify
      me @ "^CYAN^<  ^NORMAL^'^WHITE^.end^NORMAL^' will exit and save the list, '^WHITE^.abort^NORMAL^' will abort any       ^CYAN^>" ansi_notify
      me @ "^CYAN^<  ^NORMAL^changes.  To perform external commands(Like paging or whatever.), ^CYAN^>" ansi_notify
      me @ "^CYAN^<  ^NORMAL^place a '^WHITE^|^NORMAL^' mark at the start like '^WHITE^|page blah=hey!^NORMAL^'              ^CYAN^>" ansi_notify
   then
;
: ArrayEDITOR ( aList -- aList sExitcmd )
   EDITORheader
   0 array_make 1
   me @ "_prefs/lstoggle" getpropstr strip "alt" stringcmp not if
      "..i $"
   else
      ".i $"
   then
   1 ArrayEDITORloop -4 rotate 3 popn
;
: EDITOR ( {rng} -- {rng} exitcmd )
   array_make ArrayEDITOR swap array_vals dup 2 + rotate
;
: EDITORprop ( dObject sListprop -- )
   var amask
   var cmdstr var dobject var slistprop var alist var currline
   var cntfmt
   "proplist_entry_fmt" sysparm dup if
      dup "/" instr if
         dup "/" instr 1 - strcut pop
      then
      "" "N" subst "" "P" subst
   else
      pop "#"
   then
   cntfmt !
   me @ "_prefs/lstoggle" getpropstr strip "alt" stringcmp not if
      "..i $"
   else
      ".i $"
   then
   cmdstr !
   "/" swap strcat "" ":" subst
   begin
      dup "//" instr while
      "/" "//" subst
   repeat
   begin
      dup "/" rinstr over strlen = over and while
      dup strlen 1 - strcut pop
   repeat
   strip dup not if
      me @
      "^CFAIL^You must specify a listname.  ^CYAN^Syntax: ^AQUA^lsedit <obj>=<listname>"
      ansi_notify
      pop pop exit
   then
   trig "ARCHWIZARD" Flag? not if
      dup "/@" instr over "/~" instr or me @ "wizard" flag? not and
      me @ 4 pick controls not or if
         "noperm_mesg" sysparm
         me @ "^CFAIL^" rot 1 escape_ansi strcat ansi_notify pop pop exit
      then
   then
   over dobject ! dup slistprop ! array_get_proplist alist ! 1 currline !
   me @ "^CINFO^Entering list editor for: ^NORMAL^" dobject @ unparseobj
   strcat "=" strcat slistprop @ 1 escape_ansi strcat ansi_notify
   EDITORheader
   "save" "lhelp" "undo" 3 array_make amask !
   begin
      alist @ amask @ currline @ cmdstr @ 1 ArrayEDITORloop
    swap pop rot pop
      dup "lhelp" stringcmp not if
         pop currline ! alist !
         me @ "^YELLOW^--^WHITE^LOCAL HELP^YELLOW^---------------------------------------------------------------" ansi_notify
         me @ " ^WHITE^.undo                     ^NORMAL^Returns the list to its last save state." ansi_notify
         me @ " ^WHITE^.save                     ^NORMAL^Saves the current list to its property." ansi_notify
         me @ "^YELLOW^Object/LSProperty: ^BROWN^" dobject @ unparseobj strcat
         "^YELLOW^/^BROWN^" strcat slistprop @ 1 strcut swap pop strcat
         ansi_notify
         me @ "^YELLOW^Done." ansi_notify
         "" cmdstr ! continue
      then
      dup "undo" stringcmp not if
         0 0 0 3 array_make
         "^CYAN^< ^NORMAL^Changes since last save are undone. ^CYAN^>"
         EDITORmesg
         pop pop pop dobject @ slistprop @ array_get_proplist alist !
         me @ "_prefs/lstoggle" getpropstr strip "alt" stringcmp not if
            "..i $"
         else
            ".i $"
         then
         cmdstr ! 0 currline ! continue
      then
      dup "save" stringcmp not if
         0 0 0 3 array_make "^CYAN^< ^NORMAL^List saved. ^CYAN^>" EDITORmesg
         pop "" cmdstr ! currline ! dobject @ slistprop @ over over cntfmt @
         strcat remove_prop rot dup alist ! array_put_proplist continue
      then
      dup "abort" stringcmp not if
         0 0 0 3 array_make "^CYAN^< ^NORMAL^list not saved. ^CYAN^>" EDITORmesg
         pop pop pop break
      then
      dup "end" stringcmp not if
         0 0 0 3 array_make "^CYAN^< ^NORMAL^list saved. ^CYAN^>" EDITORmesg
         pop pop dobject @ slistprop @ over over cntfmt @ strcat remove_prop
         rot array_put_proplist break
      then
   repeat
;
: IsGuest? ( d -- i )
   dup name "Guest" stringpfx
   swap "G" flag? or
;
: cmd-lsedit ( sParams -- )
   "me" match me !
   "=" split strip
   me @ IsGuest? if
      "noguest_mesg" sysparm
      me @ "^CFAIL^" rot strcat notify pop pop exit
   then
   dup not if
      me @
      "^CFAIL^You must specify a listname.  ^CYAN^Syntax: ^AQUA^lsedit <obj>=<listname>"
      ansi_notify
      pop pop exit
   then
   swap strip dup not if
      me @
      "^CFAIL^You must specify an object.  ^CYAN^Syntax: ^AQUA^lsedit <obj>=<listname>"
      ansi_notify
      pop pop exit
   then
   match dup #-2 dbcmp if
      pop me @
      "^CFAIL^I don't know what object you mean.  ^CYAN^Syntax: ^AQUA^lsedit <obj>=<list>"
      ansi_notify
      pop exit
   else
      dup ok? not if
         pop me @
         "^CFAIL^I can't find that.  ^CYAN^Syntax: ^AQUA^lsedit <obj>=<list>"
         ansi_notify
         pop exit
      then
   then
   swap EDITORprop
;
$pubdef Array_EDITOR "$lib/editor" match "ArrayEDITOR" call
$pubdef Array_EDITORloop "$lib/editor" match "ArrayEDITORloop" call
$pubdef Array_EDITORparse "$lib/editor" match "ArrayEDITORparse" call
$pubdef ArrayEDITOR "$lib/editor" match "ArrayEDITOR" call
$pubdef ArrayEDITORloop "$lib/editor" match "ArrayEDITORloop" call
$pubdef ArrayEDITORparse "$lib/editor" match "ArrayEDITORparse" call
$pubdef ArrEDITOR "$lib/editor" match "ArrayEDITOR" call
$pubdef ArrEDITORloop "$lib/editor" match "ArrayEDITORloop" call
$pubdef ArrEDITORparse "$lib/editor" match "ArrayEDITORparse" call
$pubdef EDITOR "$lib/editor" match "EDITOR" call
$pubdef EDITORheader "$lib/editor" match "EDITORheader" call
$pubdef EDITORloop "$lib/editor" match "EDITORloop" call
$pubdef EDITORparse "$lib/editor" match "EDITORparse" call
$pubdef EDITORprop "$lib/editor" match "EDITORprop" call
public EDITOR
public EDITORloop
public EDITORparse
public EDITORheader
public EDITORprop
public ArrayEDITOR
public ArrayEDITORloop
public ArrayEDITORparse
