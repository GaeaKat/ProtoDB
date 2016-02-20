( Lib-Strings v2.01
 
Added rsort-string-length ( user request ) by Akari 2.01 12/12/2002
Added many new routines, including the neon/ansi ones [Moose] 2.0
Previously: Unknown
 
These routines deal with spaces in strings.
 STRblank?   [       str -- bool         ]  true if str null or only spaces
 
 
The following are useful for formatting strings into fields.
 STRfillfield  [ str char width -- padstr  ]  return padding string to width chars
 STRcenter     [ str width -- str'         ]  center a string in a field.
 STRleft       [ str width -- str'         ]  pad string w/ spaces to width chars
 STRright      [ str width -- str'         ]  right justify string to width chars
 
 
The following are like the previous formatting functions except allow ansi codes: [By Moose]
 STRafillfield [ str char width -- padstr  ]  return padding string to width chars
 STRacenter    [ str width -- str'         ]  center a string in a field.
 STRaleft      [ str width -- str'         ]  pad string w/ spaces to width chars
 STRaright     [ str width -- str'         ]  right justify string to width chars
 neon_fillfield[ str char width -- padstr  ]
 neon_center   [ str width -- str'         ]
 neon_left     [ str width -- str'         ]
 neon_right    [ str width -- str'         ]
 neon_offset   [ str int   -- int          ]
 neon_strcut   [ str int   -- str1 str2    ]
 neon_strlen   [ str       -- intlen       ]
 neon_striplead[ str       -- str'         ]
 neon_striptail[ str       -- str'         ]
 neon_strip    [ str       -- str'         ]
rsort_strlen   [ arr:strings -- arr:strings' in reverse length order ]
 
 
This routine is useful for parsing command line input:
  STRparse   [       str -- str1 str2 str3] " #X Y  y = Z"  ->  "X" "Y y" " Z"
 
 
Lil' warning: ProtoMUCK v1.50 or newer only.
)
 
$author Moose Akari Unknown
$lib-version 2.01
 
: neon_strlen ( str -- int )
  1 unparse_ansi strlen
;
 
 
: neon_offset ( str int -- int )
   VAR! offset 0 VAR! curpos 0 VAR! inansi 0 VAR! lastisit 0 VAR! curpos
   "" swap
   BEGIN
      1 strcut rot rot dup "^" stringcmp not if
         lastisit @ if
            curpos ++
         then
         inansi @ not inansi ! 1 lastisit !
         strcat swap
      else
         0 lastisit !
         inansi @ not if
            curpos ++
         then
         strcat swap
      then
      curpos @ offset @ >= if
         BREAK
      then
   REPEAT
   pop strlen
;
 
 
: neon_strcut ( str int -- str1 str2 )
   over swap neon_offset strcut
;
 
 
: neon_striplead ( str -- str )
   0 VAR! inansi
   "" swap
   BEGIN
      1 strcut rot rot dup "^" stringcmp not if
         strcat swap inansi @ not inansi !
         over dup strlen 2 >= if
            dup strlen 2 - strcut swap pop "^" instr 1 = if
               strcat BREAK
            else
               CONTINUE
            then
         else
            pop CONTINUE
         then
      then
      inansi @ if
         strcat swap CONTINUE
      else
         dup " " stringcmp not if
            pop swap CONTINUE
         else
            strcat swap strcat BREAK
         then
      then
   REPEAT
;
 
 
: neon_striptail ( str -- str )
   0 VAR! inansi
   "" swap
   BEGIN
      dup strlen 1 - strcut dup "^" stringcmp not if
         rot strcat swap inansi @ not inansi !
         over 1 strcut swap pop "^" instr 1 = if
            swap strcat BREAK
         else
            CONTINUE
         then
      then
      inansi @ if
         rot strcat swap CONTINUE
      else
         dup " " stringcmp not if
            pop CONTINUE
         else
            strcat swap strcat BREAK
         then
      then
   REPEAT
;
 
 
: neon_strip ( str -- str )
   neon_striplead neon_striptail
;
 
 
: fillfield (str padchar fieldwidth -- padstr)
  rot strlen - dup 1 < if pop pop "" exit then
  swap over begin swap dup strcat swap 2 / dup not until pop
  swap strcut pop
;
 
 
: ansi_fillfield (str padchar fieldwidth -- padstr)
  rot ansi_strlen - dup 1 < if pop pop "" exit then
  swap over begin swap dup strcat swap 2 / dup not until pop
  swap ansi_strcut pop
;
 
 
: neon_fillfield (str padchar fieldwidth -- padstr)
  rot neon_strlen - dup 1 < if pop pop "" exit then
  swap over begin swap dup strcat swap 2 / dup not until pop
  swap neon_strcut pop
;
 
 
: left (str fieldwidth -- str')
  over " " rot fillfield strcat
;
 
 
: ansi_left (str fieldwidth -- str')
  over " " rot ansi_fillfield strcat
;
 
 
: neon_left (str fieldwidth -- str')
  over " " rot neon_fillfield strcat
 
;
 
 
: right (str fieldwidth -- str')
  over " " rot fillfield swap strcat
;
 
 
: ansi_right (str fieldwidth -- str')
  over " " rot ansi_fillfield swap strcat
;
 
 
: neon_right (str fieldwidth -- str')
  over " " rot neon_fillfield swap strcat
;
 
 
: center (str fieldwidth -- str')
  over " " rot fillfield
  dup strlen 2 / strcut
  rot swap strcat strcat
;
 
 
: ansi_center (str fieldwidth -- str')
  over " " rot neon_fillfield
  dup neon_strlen 2 / neon_strcut
  rot swap strcat strcat
;
 
 
: neon_center (str fieldwidth -- str')
  over " " rot ansi_fillfield
  dup ansi_strlen 2 / ansi_strcut
  rot swap strcat strcat
;
 
 
: STRparse ( s -- s1 s2 s3 ) (
    Before: " #option  tom dick  harry = message "
    After:  "option" "tom dick harry" " message "
    )
    "=" rsplit swap
    striplead dup "#" 1 strncmp not if
        1 strcut swap pop
        " " split
    else
        "" swap
    then
    strip stripspaces rot
;
$pubdef rsort_strlen "$lib/strings" match "rsort-string-length" call
 
 
: rsort-string-length[ arr:theStrings -- arr:theStrings' ]
 
  (* Given an array of strings, returns the array with the strings
   * sorted longest to shortest. It works by magic. *)
  0 array_make_dict var! stringsLengths
  0 array_make var! lengths
    theStrings @ foreach swap pop ( s )
        dup strlen ( s i )
        dup lengths @ array_appenditem lengths !
        swap stringsLengths @ swap array_setitem stringsLengths !
    repeat
    ( Now stringsLengths contains a dict of <string>:<length> )
    ( And lengths is an array of just the lengths )
    lengths @ 1 array_nunion array_reverse lengths ! ( put them big to small )
    0 array_make theStrings ! ( clear the passed array )
    lengths @ foreach swap pop ( now we go through the lengths )
        stringsLengths @ swap array_findval ( find strings with that length )
        foreach swap pop (Now we iterate the returned array from array_findval)
            theStrings @ array_appenditem theStrings !
        repeat
    repeat
    theStrings @ ( put the result back on the stack )
;
$pubdef .acenter "$lib/strings" match "ansi_center" call
$pubdef .afillfield "$lib/strings" match "ansi_fillfield" call
$pubdef .aleft "$lib/strings" match "ansi_left" call
$pubdef .aright "$lib/strings" match "ansi_right" call
$pubdef .asc \ctoi
$pubdef .blank? \striplead not
$pubdef .center "$lib/strings" match "center" call
$pubdef .chr \itoc
$pubdef .command_parse "$lib/strings" match "STRparse" call
$pubdef .fillfield "$lib/strings" match "fillfield" call
$pubdef .left "$lib/strings" match "left" call
$pubdef .right "$lib/strings" match "right" call
$pubdef .rsplit \rsplit
$pubdef .singlespace \striplead \striptail
$pubdef .sls \striplead
$pubdef .sms \striplead \striptail
$pubdef .split \split
$pubdef .strip \striplead \striptail
$pubdef .stripspaces \striplead \striptail
$pubdef .sts \striptail
$pubdef neon_center "$lib/strings" match "neon_center" call
$pubdef neon_left "$lib/strings" match "neon_left" call
$pubdef neon_offset "$lib/strings" match "neon_offset" call
$pubdef neon_right "$lib/strings" match "neon_right" call
$pubdef neon_strcut "$lib/strings" match "neon_strcut" call
$pubdef neon_strip "$lib/strings" match "neon_strip" call
$pubdef neon_striplead "$lib/strings" match "neon_striplead" call
$pubdef neon_striptail "$lib/strings" match "neon_striptail" call
$pubdef neon_strlen "$lib/strings" match "neon_strlen" call
$pubdef stripspaces \striplead \striptail
$pubdef STRacenter "$lib/strings" match "ansi_center" call
$pubdef STRafillfield "$lib/strings" match "ansi_fillfield" call
$pubdef STRaleft "$lib/strings" match "ansi_left" call
$pubdef STRaright "$lib/strings" match "ansi_right" call
$pubdef STRasc \ctoi
$pubdef STRblank? \striplead not
$pubdef STRcenter "$lib/strings" match "center" call
$pubdef STRchr \itoc
$pubdef STRfillfield "$lib/strings" match "fillfield" call
$pubdef STRleft "$lib/strings" match "left" call
$pubdef STRparse "$lib/strings" match "STRparse" call
$pubdef STRright "$lib/strings" match "right" call
$pubdef STRrsplit \rsplit
$pubdef STRsinglespace \striplead \striptail
$pubdef STRsls \striplead
$pubdef STRsms \striplead \striptail
$pubdef STRsplit \split
$pubdef STRstrip \striplead \striptail
$pubdef STRsts \striptail
public rsort-string-length
public neon_offset
public neon_strlen
public neon_strcut
public neon_striplead
public neon_striptail
public neon_strip
public fillfield
public ansi_fillfield
public neon_fillfield
public left
public ansi_left
public neon_left
public right
public ansi_right
public neon_right
public center
public ansi_center
public neon_center
public STRparse
