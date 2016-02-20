( Sensei-MUF by Akari                                                   )
(                 Nakoruru08@hotmail.com                                )
( Version 1.0 finished 08/15/00                                         )
( Version 1.1 finished 01/17/03 - by Moose, added array support, removed)
(                                 $lib/lmgr, and added standardization. )
(                                                                       )
( The goal of this program was to provide a help file board that did    )
( more than just hold messages for players to try and browse through.   )
( It includes a #search function that will scan the messages for words  )
( entered by the players. It will keep track of the searches done, so   )
( that wizzes can review the searches, as well as the success or failure)
( rate, in order to determine which sorts of articles need to be        )
( written.                                                              )
( This program is ProtoMUCK compatible only, though it could work with  )
( FB6 if the ansi prims were replaced by their non-ansi equivalents.    )
$author Akari
$version 1.1
( ** Includes ** )
$include $lib/editor
$include $lib/standard
( ** Program $defs, do not change ** )
$def popall begin depth while pop repeat
$def atell me @ swap ansi_notify
( ** Changeable $defs ** )
$def PropLoc trig ( Location to store the files )
$def defPage 20 ( default page size when paging through files )
$def defWidth 78 ( The screen width to cut the lines at )
$def defCols 4 ( The # of columns for the #titles print out )
( ** Variables ** )
lvar title ( string to hold the title )
lvar subject ( string to hold the subject )
lvar curProp ( string that holds the current prop being worked with )
lvar count ( used for counts throughout the program )
lvar pageit ( if 1 then it reads it off in line groups )
lvar srchstr ( string to search for in articles )
: pad-loop ( Used with strlenset to pad the text out with spaces )
   rot 3 pick strcat
   -3 rotate 1 -
   dup if
     pad-loop
   else
     pop pop
   then
;
: strlenset (s1 s2 i -- s1') (string padchar size-of-final-string -- pad/cutstr)
  3 pick ansi_strlen over swap - dup if
    dup 0 < if
      (s s i negative-of-number-of-chars-to-chop-off-of-string)
      pop swap pop strcut pop
    else
      (s s i number-of-padchars-to-add-to-string)
      swap pop
      pad-loop
    then
  else
    pop pop pop
  then
;
: spit-list ( d s -- , Prints the list of the prop passed to it )
  ARRAY_get_proplist { me @ }list ARRAY_ansi_notify
;
: find-title ( s -- s, arguement, matching title if any, else "---" )
  dup number? if
    PropLoc swap "_tutor/num/" swap strcat getpropstr
    dup not if pop "---" then exit
  else
  PropLoc over "_tutor/msgs/" swap strcat propdir? not if pop "---" exit then
  then
;
: do-pager ( -- )
  var curLine var range
  1 curline !
  me @ BBP-PauseLines getpropstr dup not if pop defPage else atoi then range !
  PropLoc "/_Tutor/Msgs/" title @ strcat "/Msg" strcat ARRAY_get_proplist
  FOREACH
     swap pop atell
     curLine @ range @ = IF
        "^FOREST^Continue? (y/n)" atell
        read strip "y" stringpfx IF 1 ELSE 0 THEN not IF BREAK THEN
     THEN
     curLine ++
  REPEAT
;
: find-article ( s -- )
  var pageSize
  find-title title !
  me @ "_prefs/trange" getpropstr dup not if pop defPage else atoi then pageSize !
  PropLoc "_tutor/msgs/" title @ strcat propdir? not if
    "^YELLOW^Could not find that article." atell exit then
  PropLoc "_tutor/msgs/" title @ strcat "/msg#" strcat getpropstr
  PropLoc "_tutor/msgs/" title @ strcat "/subject" strcat getpropstr subject !
  dup atoi pageSize @ > if "^FOREST^This message is ^GREEN^" swap strcat
    " ^FOREST^lines long, would you like it ^GREEN^" strcat
    pageSize @ intostr strcat
    " ^FOREST^lines at a time?(y/n)" strcat atell
    read "y" stringpfx if 1 pageit ! then
  then
  "( ^WHITE^" title @ strcat " ^BLUE^)" strcat 1 parse_ansi
  dup ansi_strlen defWidth swap - 2 / "" swap "-" swap strlenset
  swap strcat "-" defWidth strlenset "^BLUE^" swap strcat atell
  "^BROWN^Summary: ^YELLOW^" subject @ strcat atell
  pageit @ if
    do-pager else
    PropLoc "_tutor/msgs/" title @ strcat "/msg" strcat spit-list
  then
  "^YELLOW^~Done~" atell
;
: clear-history ( -- )
  me @ "WIZARD" flag? not if "^CRIMSON^Permission denied." atell exit then
  "^FOREST^Clear the #search history?(y/n)" atell read strip "y" stringpfx not if
    "^BLUE^Cancelled." atell else
    PropLoc "_tutor/searches" remove_prop
    "^RED^Cleared." atell
  then
;
: do-history ( -- )
  var curSrch var found var numFound var numNFound
  me @ "WIZARD" flag? not if "^CRIMSON^Permission denied." atell exit then
  "^BLUE^" "" "-" defWidth strlenset strcat atell
  "_tutor/searches/" begin PropLoc swap nextprop dup while 0 found ! count ++
    dup "/" explode 1 - popn curSrch !
    PropLoc over getpropstr "y" stringpfx
    if 1 found ! numFound ++ else numNFound ++ then
    found @ if "  ^GREEN^" else "  ^RED^" then curSrch @ strcat atell
  repeat pop
  "^BLUE^-- ^GREEN^" numFound @ intostr strcat " ^WHITE^Found ^BLUE^-- ^RED^" strcat
  numNFound @ intostr strcat " ^WHITE^Not Found ^BLUE^-- ^YELLOW^" strcat count @ intostr
  strcat " ^WHITE^Total ^BLUE^-----" strcat atell
;
: update-loop ( -- )
  0 count !
  PropLoc "_tutor/num" remove_prop
  "_tutor/msgs/" begin PropLoc swap nextprop dup while
    dup "/" explode 1 - popn title !
    propLoc "_tutor/num/" count ++ count @ intostr strcat title @ setprop
  repeat pop
;
: remove-message ( s -- )
  me @ "MAGE" flag? not if pop "^CRIMSON^Permission denied." atell exit then
  " " split swap pop strip dup not if pop
    "^GREEN^Enter the title to remove or '.' to cancel:" atell read strip
    dup "." strcmp not if pop "^BLUE^Cancelled." atell exit then
  then find-title title !
  PropLoc "_tutor/msgs/" title @ strcat propdir? not if
    "^BROWN^There is no article with that title." atell exit then
  "Remove article titled ^YELLOW^" title @ strcat "^NORMAL^?(y/n)" strcat atell
  read strip "y" stringpfx not if "^BLUE^Cancelled." atell else
  PropLoc "_tutor/msgs/" title @ strcat remove_prop
  "^YELLOW^" title @ strcat " ^NORMAL^removed." strcat atell then
  update-loop
;
: write-message ( -- )
  me @ "MAGE" flag? not if "^CRIMSON^Permission denied." atell exit then
  "" "#write" subst strip dup not if pop
    "^GREEN^Entet message title (16 characters or less) or '.' to cancel: "
    atell read strip
    dup "." strcmp not if pop "^BLUE^Cancelled." atell exit then
  then title !
  "^GREEN^Enter subject or summary line or '.' to leave as is: " atell read strip
  dup "." strcmp not if pop
    PropLoc "_tutor/msgs/" title @ strcat "/subject"
    strcat getpropstr
  then subject !
  "^VIOLET^Title: ^PURPLE^" title @ strcat atell
  "^VIOLET^Subject: ^PURPLE^" subject @ strcat atell
  "_tutor/msgs/" title @ strcat "/msg" strcat PropLoc swap ARRAY_get_proplist
  ArrayEDITOR "abort" stringcmp not if depth popn
    "^CRIMSON^<Tutor file post cancelled.>" atell exit then
  PropLoc "_tutor/msgs/" title @ strcat "/msg#" strcat remove_prop
  "_tutor/msgs/" title @ strcat "/msg" strcat PropLoc swap rot ARRAY_put_proplist
  PropLoc "_tutor/msgs/" title @ strcat "/subject" strcat subject @ setprop
  "^FOREST^< Article ^YELLOW^'^FOREST^" title @ strcat
  "^YELLOW^'^FOREST^ saved.>" strcat atell
  update-loop
;
: print-search ( -- )
  "^BLUE^" "" "-" defWidth strlenset strcat atell
  "@tutor/" begin me @ swap nextprop dup while
    dup "/" explode 1 - popn "  ^GREEN^" over strcat "                       " strcat
    25 strcut pop " ^YELLOW^- ^NORMAL^" strcat swap
    "_tutor/msgs/" swap strcat "/subject" strcat PropLoc swap getpropstr strcat atell
  repeat pop " " .tell
  "^RED^== ^WHITE^" count @ intostr strcat
  " ^NORMAL^matches found for ^YELLOW^'^NORMAL^" strcat srchStr @ strcat
  "^YELLOW^'" strcat atell
  "^RED^== ^NORMAL^Use ^YELLOW^tutor <title>^NORMAL^ to read the articles."  atell
;
: search-msg ( s -- i, title -- 1 = found )
  var curLine
  0 curLine !
  "_tutor/msgs/" over strcat "/subject" strcat PropLoc swap getpropstr
  srchStr @ instring if pop 1 exit then
  prog "_tutor/msgs/" swap strcat "/msg" strcat ARRAY_get_proplist
  FOREACH
     swap pop srchstr @ instring IF
        pop 1 EXIT
     THEN
  REPEAT
  pop 0
;
: do-search ( s -- )
  background
  me @ "@tutor" remove_prop
  " " split swap pop srchstr !
  propLoc "_tutor/searches/" srchstr @ strcat "y" setprop
  "^FOREST^Scanning the messages for ^GREEN^" srchstr @ strcat
  "^FOREST^. This may take a little while." strcat atell
  "_tutor/num/" begin PropLoc swap nextprop dup while
    PropLoc over getpropstr dup title ! search-msg if count ++
      me @ "@tutor/" title @ strcat "y" setprop then
  repeat pop
  me @ "@tutor" propdir? if print-search
    PropLoc "_tutor/searches/" srchstr @ strcat "y" setprop else
    "No matches found for^YELLOW^: ^BLUE^" srchstr @ strcat atell
    PropLoc "_tutor/searches/" srchstr @ strcat "n" setprop
  then
;
: do-titles ( -- )
  var colLength var curCol var curString
  "" curString ! 0 count !
  "^BLUE^" "" "-" defWidth strlenset strcat atell
  "^WHITE^" "muckname" sysparm strcat " Tutor Files" strcat 1 parse_ansi
  dup ansi_strlen defWidth swap - 2 / "" swap " " swap strlenset
  swap strcat " " defWidth strlenset atell
  "^BLUE^" "" "-" defWidth strlenset strcat atell
  defWidth defCols / 3 - colLength !
  begin 0 curCol !
    begin curCol ++
      PropLoc "_tutor/num/" count ++ count @ intostr strcat getpropstr dup not if
      curString @ atell pop exit then
      "                                           "
      strcat colLength @ strcut pop
      curString @ if curString @ " ^BLUE^| ^NORMAL^" strcat curString ! then
      curString @ swap strcat curString !
      curCol @ defCols = if curString @ atell "" curString ! break then
    repeat curString @ dup if atell else pop then "" curString !
  repeat
;
: do-list ( -- )
  0 count 1
  "^BLUE^" "" "-" defWidth strlenset strcat atell
  "^WHITE^" "muckname" sysparm strcat " Tutor Files Listing" strcat 1 parse_ansi
  dup ansi_strlen defWidth swap - 2 / "" swap " " swap strlenset
  swap strcat " " defWidth strlenset atell
  "^BLUE^" "" "-" defWidth strlenset strcat atell
  begin count ++
    propLoc "_tutor/num/" count @ intostr strcat getpropstr
    dup not if pop break then title !
    PropLoc "_tutor/msgs/" title @ strcat "/subject" strcat getpropstr subject !
    count @ 9 > if " " else "  " then "^GREEN^" strcat
    count @ intostr strcat ") ^NORMAL^" strcat title @ strcat
    "                        " strcat 36 strcut pop " ^YELLOW^ - ^NORMAL^"
    strcat subject @ strcat 1 parse_ansi defWidth ansi_strcut pop atell
  repeat
  " " .tell
  "^YELLOW^~Done. Use tutor #help for instructions.~" atell
;
: do-help ( -- )
  "^BLUE^" "" "-" defWidth strlenset strcat atell
  "^WHITE^Sensei-MUF by Akari" 1 parse_ansi
  dup ansi_strlen defWidth swap - 2 / "" swap " " swap strlenset
  swap strcat " " defWidth strlenset atell
  "^BLUE^" "" "-" defWidth strlenset strcat atell
  "Use the following commands to browse and read the help files    " .tell
  "that have been written to help you out with doing various things" .tell
  "on the MUCK.                                                    " .tell
  " " .tell
  "  tutor <number/title> - To read an article.                    " .tell
  "  tutor #list          - To list the articles with subjects.    " .tell
  "  tutor #titles        - To only list the titles of articles.   " .tell
  "  tutor #search        - To search the articles for key words.  " .tell
  me @ "MAGE" flag? if
  "  tutor #write <title> - To post or edit an article.            " .tell
  "  tutor #rem <title>   - To remove an article completely.       " .tell
  then
  me @ "WIZARD" flag? if
  "  tutor #history       - To read the #search history.           " .tell
  "  tutor #clear         - To clear the #search history.          " .tell
  then
  "  @set me=" BBP-PauseLines strcat ":<number> will set your page size." strcat .tell
  "^YELLOW^~Done~" atell
;
: main ( s -- )
  strip
  dup not if pop do-help exit then
  dup "#help" stringpfx if pop do-help exit then
  dup "#list" stringpfx if pop do-list exit then
  dup "#title" stringpfx if pop do-titles " " .tell
    "^YELLOW^~Done. Use tutor #help for instructions.~" atell exit then
  dup "#search" stringpfx if do-search exit then
  dup "#write" stringpfx if write-message exit then
  dup "#rem" stringpfx if remove-message exit then
  dup "#history" stringpfx if pop do-history exit then
  dup "#clear" stringpfx if pop clear-history exit then
  find-article
;
