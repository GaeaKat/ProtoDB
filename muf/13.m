(*
   Lib-Arrays v1.5.1
  Author: Chris Brine [Moose/Van]
 
  v1.51 [Akari] 09/04/2001
  - Cleaned up the formatting to 80 colums and added new directives.
 
  Note: These were only made for string-list one-dimensional arrays,
        and not dictionaries or any other kind.
  Note: Ansi codes are accepted in these functions.
 
  Lib-Arrays requires ProtoMUCK v1.50+
                  and $lib/strings (ProtoMUCK version 1.5 or newer)
 
  Functions:
    ArrParse_Ansi[ a @1 @2 itype -- a ]
     - Runs an itype parse_ansi on every string from @1 to @2.
    ArrUnparse_Ansi[ a @1 @2 itype -- a ]
     - Removes all ansi codes of itype type ansi from @1 to @2.
    ArrEscape_Ansi[ a @1 @2 itype -- a ]
     - Runs itype escape_ansi on every string from @1 to @2.
    ArrCommas [ a [s] -- s ]
     - Takes an array of strings and returns a string with them seperated by
       commas.
    ArrLeft [ a @1 @2 icol schar -- a ]
     - Aligns all text in the given range to the left in the number of
        columns and with the given char.
    ArrRight [ a @1 @2 icol schar -- a ]
     - Same as ArrLeft, but it is aligned to the right instead.
    ArrCenter [ a @1 @2 icol schar -- a ]
     - Same as ArrLeft, but it is aligned to the center instead.
    ArrIndent [ a @1 @2 icol schar -- a ]
     - Indents the text in the given range by the number of columns
       given.
    ArrFormat [ a @1 @2 icol -- a ]
     - Formats the given range in the array to a specific number of columns;
       however, it will only seperate the line at the last space before icol...
       that way it doesn't cut it off in the middle of any word.
    ArrJoinRng [ a @1 @2 schar -- a ]
     - Joins a range of text.  schar is the seperating char.
    ArrList [ d a @1 @2 iBolLineNum -- ]
     - List the contents of the range in the array; if iBolLineNum is not equal
       to 0 then it will display the line numbers as well. 'd' is the object
       that the list is displayed to.
    ArrSearch [ @ a ? -- i ]
     - Searches through the array for any item containing '?' starting at
       the given index
    ArrCopy [ a @1 @2 @3 -- a ]
     - Copies the given range to the position of @3.
    ArrMove [ a @1 @2 @3 -- a ]
     - Moves the given range to the position of @3
    ArrPlaceItem [ @ a ? -- a ]
     - Place an item at the exact position, moving the old one that was there
       down
       [Ie. An object switcheroo after array_insertitem]
    ArrShuffle [ a -- a ]
     - Randomize the array.
    ArrReplace [ a @1 @2 s1 s2 -- a ]
     - Replace any 's1' text with 's2' in the given range for the array.
    ArrMPIparse [ d a @1 @2 s i -- a ]
     - Parse the given lines in an array and returns the parsed lines.
      d = Object to apply permission checking to [or use for parseprop under
          FuzzballMUCKs since they do not have PARSEMPI]
      a = The starting array
     @1 = The first index marker to parse
     @2 = The last index marker to parse
      s = String containing the &how variable's contents
      i = Integer used for {delay} on whether it is shown to the player or room.
    ArrVals [ a -- a ]
     - Works like array_vals except it returns an array instead of a list of
       vals
    ArrKeys [ a -- a ]
     - Works like array_keys except it returns an array instead of a list of
       keys.
    ArrKey? [ a @ -- i ]
     - Checks to see if '@' is an index marker in the given array/dictionary.
    ArrnCombine [ a1 a2 -- a ]
     - Like array_nunion, except that it does not sort the values after
       combining.
    ArrCombine [ a1..ai i -- a ]
     - Like array_union, except that it does not sort the values after
       combining.
*)
 
$author Moose
$lib-version 1.51
$include $lib/strings (* Demands version 1.5 -- ProtoMUCK modified one *)
 
: ArrParse_Ansi[ arr:ARRstrings int:StartPos int:EndPos int:itype --
                 arr:ARRstrings' ]
   { }list ARRstrings @
   FOREACH
      swap dup StartPos @ >= swap EndPos @ <= and if
         itype @ 1 = if
            me @ swap "\[[0m" parse_neon
         else
            itype @ parse_ansi
         then
      then
      swap array_appenditem
   REPEAT
;
 
: ArrUnparse_Ansi[ arr:ARRstrings int:StartPos int:EndPos int:itype --
                   arr:ARRstrings' ]
   { }list ARRstrings @
   FOREACH
      swap dup StartPos @ >= swap EndPos @ <= and if
         itype @ unparse_ansi
      then
      swap array_appenditem
   REPEAT
;
 
: ArrEscape_Ansi[ arr:ARRstrings int:StartPos int:EndPos int:itype --
                  arr:ARRstrings' ]
   { }list ARRstrings @
   FOREACH
      swap dup StartPos @ >= swap EndPos @ <= and if
         itype @ escape_ansi
      then
      swap array_appenditem
   REPEAT
;
 
: ArrCommas ( arr:Strings [str:Sep] -- str:StringList )
  dup string? if
     array_join
  else
     "\[\[\[ " array_join "\[\[\[ " rsplit ", and " swap strcat strcat
     ", " "\[\[\[ " subst
  then
;
 
: ArrLeft[ arr:ARRlist int:StartPos int:EndPos int:Columns str:SEPchar --
           arr:NewArray ]
   { }list VAR! NewArray
   ARRlist @ dup array_count not if exit then
   FOREACH
      swap dup StartPos @ >= swap EndPos @ <= and if
         begin
            dup ansi_strlen Columns @ < while
            SEPchar @ strcat
         repeat
         striptail dup not if
            pop " "
         then
      then
      NewArray @ array_appenditem NewArray !
   REPEAT
   newarray @
;
 
: ArrRight[ arr:ARRlist int:StartPos int:EndPos int:Columns str:SEPchar --
            arr:NewArray ]
   { }list VAR! NewArray
   ARRlist @ dup array_count not if exit then
   FOREACH
      swap dup StartPos @ >= swap EndPos @ <= and if
         begin
            dup ansi_strlen Columns @ < while
            SEPchar @ swap strcat
         repeat
         striptail dup not if
            pop " "
         then
 
      then
      NewArray @ array_appenditem NewArray !
   REPEAT
   newarray @
;
 
: ArrCenter[ arr:ARRlist int:StartPos int:EndPos int:Columns str:SEPchar --
             arr:NewArray ]
   { }list VAR! NewArray
   0       VAR! idx
   ARRlist @ dup array_count not if exit then
   FOREACH
      swap dup StartPos @ >= swap EndPos @ <= and if
         begin
            dup ansi_strlen Columns @ < while
            idx @ if
               SEPchar @ swap strcat
            else
               SEPchar @ strcat
            then
            idx @ not idx !
         repeat
         striptail dup not if
            pop " "
         then
      then
      NewArray @ array_appenditem NewArray !
   REPEAT
   newarray @
;
 
: ArrIndent[ arr:ARRlist int:StartPos int:EndPos int:Columns str:SEPchar --
             arr:NewArray ]
   { }list VAR! NewArray
   ARRlist @ dup array_count not if exit then
   FOREACH
      swap dup StartPos @ >= swap EndPos @ <= and if
         1 Columns @ Columns @ 0 > if 1 else -1 then FOR
            pop Columns @ 0 > if
               SEPchar @ swap strcat
            else
               dup " " instr 1 = if
                  1 strcut swap pop
               else
                  break
               then
            then
         REPEAT
         striptail dup not if
            pop " "
         then
      then
      NewArray @ array_appenditem NewArray !
   REPEAT
   newarray @
;
 
: Format-Line[ arr:ARRlist str:STRline int:Columns -- str:Line arr:NewArray ]
   ARRlist @ VAR! NewArray
   STRline @
   BEGIN
      dup ansi_strlen Columns @ > WHILE
      Columns @ ansi_strcut swap " " rsplit striplead rot strcat swap
      NewArray @ array_appenditem NewArray !
   REPEAT
   NewArray @
;
 
: ArrFormat[ arr:ARRlist int:StartPos int:EndPos int:Columns -- arr:NewArray ]
   { }list VAR! NewArray
   ARRlist @ dup array_count not if exit then
   FOREACH
      swap dup StartPos @ >= swap EndPos @ <= and if
         NewArray @ swap Columns @ Format-Line NewArray !
      then
      NewArray @ array_appenditem NewArray !
   REPEAT
   newarray @
;
 
: ArrJoinRng[ arr:ARRlist int:StartPos int:EndPos str:SEPchar -- arr:NewArray ]
   { }list VAR! NewArray VAR idx "" VAR! STRcur
   ARRlist @ dup array_count not if exit then
   FOREACH
      over idx !
      swap dup StartPos @ >= swap EndPos @ <= and if
         STRcur @ dup if SEPchar @ strcat then swap strcat STRcur !
         idx @ EndPos @ = if
            STRcur @ NewArray @ array_appenditem NewArray ! "" STRcur !
         then
      else
         NewArray @ array_appenditem NewArray !
      then
   REPEAT
   newarray @
;
 
: Get-Num ( int:Num -- str:Num )
   intostr "\[[1;37m" swap strcat "\[[0m: " strcat 5 STRaright
;
 
: ArrList ( ref:Obj arr:ARRlist int:StartPos int:EndPos int:BOLlinenums? -- )
   3 pick VAR! ipos
   var dbobj var bolnum bolnum ! 4 rotate dbobj !
   over -1 = if pop pop 0 over array_count 1 - then
   3 pick array_count 1 < if pop pop pop exit then
   dup 0 < if pop 0 then
   over 0 < if swap pop 0 swap then
   3 pick array_count 1 - over over > if swap pop dup then
   3 pick over > if rot pop -3 rotate else pop then
   over over > if pop dup then
   array_getrange
   FOREACH
      swap pop bolnum @ if
         ipos dup ++ @ Get-Num
      else
         ""
      then
      swap strcat
      dbobj @ swap notify
   REPEAT
;
 
: ArrSearch ( int:StartPos arr:ARRlist str:STRinstrtext -- int:Num )
   var strsearch strsearch ! var idx -1 idx ! var dbix 0 dbix !
   swap dup 0 > if
      dup dbix !
      1 - dup 0 = if
         array_delitem
      else
         0 swap array_delrange
      then
   else
      pop
   then
   FOREACH
      strsearch @ instring if
         dbix @ if dbix @ swap + idx ! else idx ! then break
      else
         pop
      then
   REPEAT
   idx @
;
 
: ArrCopy ( arr:ARRlist arr:StartPos arr:EndPos arr:NewPos -- arr:NewArray )
   var arrpos arrpos !
   3 pick rot rot array_getrange arrpos @ swap array_insertrange
;
 
: ArrMove ( arr:ARRlist int:StartPos int:EndPos int:NewPos -- arr:NewArray )
   var arrpos arrpos !
   3 pick 3 pick 3 pick array_getrange -4 rotate array_delrange
   dup array_count arrpos @ < if dup array_count else arrpos @ then
   rot array_insertrange
;
 
: ArrPlaceItem ( int:Pos arr:ARRlist str:Item -- arr:NewArray )
   3 pick rot swap array_insertitem
   over over swap array_getitem
   3 pick 3 rotate swap array_delitem
   rot array_insertitem
;
 
: ArrShuffle ( arr:ARRlist -- arr:ARRshuffled )
   var newarray 0 array_make newarray !
   dup array_count not if exit then
   1 over array_count 1 FOR
      pop
      dup array_count random swap % over over array_getitem rot
      rot array_delitem swap newarray @ array_appenditem newarray !
   REPEAT
   pop newarray @
;
 
: ArrReplace ( arr:ARRlist int:StartPos int:EndPos str:OldText str:NewText --
               arr:NewArray )
   var oldtext oldtext ! var newtext newtext !
   var endpos endpos ! var firstpos firstpos !
   var newarray 0 array_make newarray !
   dup array_count not if exit then
   FOREACH
      swap dup firstpos @ >= swap endpos @ <= and if
         newtext @ oldtext @ subst
      then
      newarray @ array_appenditem newarray !
   REPEAT
   newarray @
;
 
: ArrMPIparse ( ref:PermObj arr:ARRlist int:StartPos int:EndPos str:MPIhow
                int:BOLdelaytype -- arr:NewArray )
   var imesg imesg ! var stype stype !
   var endpos endpos ! var firstpos firstpos !
   var dbobj swap dbobj !
   var newarray 0 array_make newarray !
   FOREACH
      swap dup firstpos @ >= swap endpos @ <= and if
$ifdef __proto
         dbobj @ swap stype @ imesg @ parsempi
$else
         "@/mpi/" systime intostr strcat dup rot
         dbobj @ rot rot setprop
         dbobj @ over stype @ imesg @ parseprop
         dbobj @ swap remove_prop
$endif
         newarray @ array_appenditem newarray !
      swap
         pop
      then
   REPEAT
   newarray @
;
 
: array_packstuff[ thearray int:vals? -- arr:ARRpacked ]
   { }list thearray @
   FOREACH
      vals? @ if
         swap
      then
      pop swap array_appenditem
   REPEAT
;
 
: array_arrvals ( thearray -- arr:ARRvals )
   1 array_packstuff
;
 
: array_arrkeys ( thearray -- arr:ARRkeys )
   0 array_packstuff
;
 
: ArrKey? ( arr:ARRlist ARRkeyidx -- int:Bol )
   over dictionary? if
      swap array_arrkeys swap dup int? not
      over string? not and if pop pop 0 exit then
      array_findval array_count 0 >
   else
      dup int? not if pop pop 0 exit then
      swap array_count over swap < swap 0 >= and
   then
;
 
: array_combine ( arr:ARRlist1 arr:ARRlist2 -- arr:ARRlist )
   VAR! ARRlist2 VAR! ARRlist1
   ARRlist2 @ int? if
      ARRlist1 @ ARRlist2 @ prog "array_ncombine" CALL EXIT
   then
   ARRlist2 @
   FOREACH
      swap pop ARRlist1 @ array_appenditem ARRlist1 !
   REPEAT
   ARRlist1 @
;
 
: array_ncombine ( arr1..arri i -- arr:ARRlist )
   VAR! count
   count @ int? not if
      count @ array_combine EXIT
   then
   count @ 1 = if
      exit
   then
   count @ 1 < if
      { }list exit
   then
   count @ 1 - 1 -1 FOR pop
      array_combine
   REPEAT
;
 
$pubdef :
$pubdef Array_ArrKeys "$Lib/Arrays" match "Array_ArrKeys" call
$pubdef Array_ArrVals "$Lib/Arrays" match "Array_ArrVals" call
$pubdef Array_Center "$lib/arrays" match "ArrCenter" call
$pubdef Array_Combine "$Lib/Arrays" match "Array_Combine" call
$pubdef Array_Commas "$lib/arrays" match "ArrCommas" call
$pubdef Array_Copy "$lib/arrays" match "ArrCopy" call
$pubdef Array_Escape_Ansi "$lib/arrays" match "ArrEscape_Ansi" call
$pubdef Array_Format "$lib/arrays" match "ArrFormat" call
$pubdef Array_Indent "$lib/arrays" match "ArrIndent" call
$pubdef Array_JoinRng "$lib/arrays" match "ArrJoinRng" call
$pubdef Array_Key? "$lib/arrays" match "ArrKey?" call
$pubdef Array_Left "$lib/arrays" match "ArrLeft" call
$pubdef Array_List "$lib/arrays" match "ArrList" call
$pubdef Array_Move "$lib/arrays" match "ArrMove" call
$pubdef Array_MPIparse "$lib/arrays" match "ArrMPIparse" call
$pubdef Array_nCombine "$Lib/Arrays" match "Array_nCombine" call
$pubdef Array_NoDups 1 array_nunion
$pubdef Array_Parse_Ansi "$lib/arrays" match "ArrParse_Ansi" call
$pubdef Array_PlaceItem "$lib/arrays" match "ArrPlaceItem" call
$pubdef Array_Replace "$lib/arrays" match "ArrReplace" call
$pubdef Array_Right "$lib/arrays" match "ArrRight" call
$pubdef Array_Search "$lib/arrays" match "ArrSearch" call
$pubdef Array_Shuffle "$lib/arrays" match "ArrShuffle" call
$pubdef Array_Unparse_Ansi "$lib/arrays" match "ArrUnparse_Ansi" call
$pubdef ArrCenter "$lib/arrays" match "ArrCenter" call
$pubdef ArrCombine "$Lib/Arrays" match "Array_Combine" call
$pubdef ArrCommas "$lib/arrays" match "ArrCommas" call
$pubdef ArrCopy "$lib/arrays" match "ArrCopy" call
$pubdef ArrEscape_Ansi "$lib/arrays" match "ArrEscape_Ansi" call
$pubdef ArrFormat "$lib/arrays" match "ArrFormat" call
$pubdef ArrIndent "$lib/arrays" match "ArrIndent" call
$pubdef ArrJoinRng "$lib/arrays" match "ArrJoinRng" call
$pubdef ArrKey? "$lib/arrays" match "ArrKey?" call
$pubdef ArrKeys "$Lib/Arrays" match "Array_ArrKeys" call
$pubdef ArrLeft "$lib/arrays" match "ArrLeft" call
$pubdef ArrList "$lib/arrays" match "ArrList" call
$pubdef ArrMove "$lib/arrays" match "ArrMove" call
$pubdef ArrMPIparse "$lib/arrays" match "ArrMPIparse" call
$pubdef ArrnCombine "$Lib/Arrays" match "Array_nCombine" call
$pubdef ArrNoDups 1 array_nunion
$pubdef ArrParse_Ansi "$lib/arrays" match "ArrParse_Ansi" call
$pubdef ArrPlaceItem "$lib/arrays" match "ArrPlaceItem" call
$pubdef ArrReplace "$lib/arrays" match "ArrReplace" call
$pubdef ArrRight "$lib/arrays" match "ArrRight" call
$pubdef ArrSearch "$lib/arrays" match "ArrSearch" call
$pubdef ArrShuffle "$lib/arrays" match "ArrShuffle" call
$pubdef ArrSort \array_sort
$pubdef ArrUnparse_Ansi "$lib/arrays" match "ArrUnparse_Ansi" call
$pubdef ArrVals "$Lib/Arrays" match "Array_ArrVals" call
public ArrParse_Ansi ( a @1 @2 itype -- a )
public ArrUnparse_Ansi ( a @1 @2 itype -- a )
public ArrEscape_Ansi ( a @1 @2 itype -- a )
public ArrCommas ( a -- s )
public ArrLeft ( a @1 @2 icol schar -- a )
public ArrRight ( a @1 @2 icol schar -- a )
public ArrCenter ( a @1 @2 icol schar -- a )
public ArrIndent ( a @1 @2 icol schar -- a )
public ArrFormat ( a @1 @2 icol -- a )
public ArrJoinRng ( a @1 @2 schar -- a )
public ArrList ( d a @1 @2 iBolLineNum -- )
public ArrSearch ( @ a ? -- i )
public ArrCopy ( a @1 @2 @3 -- a )
public ArrMove ( a @1 @2 @3 -- a )
public ArrPlaceItem ( @ a ? -- a )
public ArrShuffle ( a -- a )
public ArrReplace ( a @1 @2 s1 s2 -- a )
public ArrMPIparse ( d a @1 @2 s i -- a )
public ArrKey? ( a @ -- i )
public Array_ArrVals ( a -- a )
public Array_ArrKeys ( a -- a )
public Array_Combine ( a1 a2 -- a )
public Array_nCombine ( a1..ai i -- a )
