( Proto UserList by Akari                                           )
(                     Nakoruru08@hotmail.com                        )
( Version 1.1 finished 12/18/2000                                   )
( Version 1.2 finished 03/19/2001                                   )
( Version 1.21 on      12/10/2001                                   )
( Version 1.3 finished 01/06/2003 by Moose                          )
(                                                                   )
( After getting fed up with the existing userlists, I went ahead    )
( and made my own. This one does a full scan each time using the    )
( 'nextplayer' prim, and is just as fast as any other userlist. It  )
( also maintains the property list of characters for compatability  )
( with programs that depend on that list being there.               )
( Users can limit their search to by series or by name, it searches )
( both by default. Since a full scan is done every time, the        )
( the property list is as accurate as of the last time the program  )
( was run.                                                          )
( Version 1.1 added the ONLINE and IDLE tags.                       )
( Version 1.2 Changed the block flag to GUEST. DARK characters still)
(             won't show up as being Online at the moment though.   )
( Version 1.21 Cleaned up to 80 column format.                      )
( Version 1.3 Changed it so that the 'Series' tag can be changed or )
(             removed for sites that want something else            )
(             Also can now choose [ansi allowed] text for what shows)
(             if no series is set... like in old userlist programs  )
(             Also added $lib/standard support                      )
$def SeriesTag "Series" (please, no spaces and keep it short!)
$def SeriesProp PROPS-series ( prop where to get the series from )
$def UnsetSeries "^WHITE^< ^NORMAL^Unset ^WHITE^>"
( See note on DefaultIdle.                                          )
$def defaultIdle 30
( Number of days before that character is considered idle           )
(                      Set to 0 to prevent idle stamping            )
$version 1.3
$def atell me @ swap ansi_notify
$def PropLoc prog ( location of the properties )
$def propList "_d" ( prop to store the userlist on )
$include $lib/standard
lvar sSeries ( 1 if searching series )
lvar sName ( 1 if searching names )
lvar filter ( What to search against )
lvar count ( counts up the matches )
lvar idlePref
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
: add-player? ( d -- i, 1 indicates should add player to directory )
  dup "G" flag? if pop 0 exit then
  dup "player_prototype" sysparm stod dbcmp if pop 0 exit then
  dup "www_surfer" sysparm stod dbcmp if pop 0 exit then
  (** extras added by Moose **)
  dup "@Ignore?" getpropstr "y" stringpfx IF pop 0 exit THEN
  prog "@IgnoreList" 3 pick REFLIST_find IF pop 0 exit THEN
  #0 "@IgnoreList" 3 pick REFLIST_find IF pop 0 exit THEN
  pop 1
;
: on-or-idle? ( d -- s, d<player> -- s<idle or online or 4 spaces>)
  dup awake? over "DARK" flag? not and if
  pop "^WHITE^[^GREEN^O^WHITE^] ^NORMAL^" exit then
  defaultIdle not if pop "    " exit then
  timestamps pop swap pop swap pop systime swap - idlePref @ > if
    "^WHITE^[^RED^I^WHITE^] ^NORMAL^" exit then
  "    "
;
: print-results ( a -- , array of dbrefs to print )
  SeriesTag if
     "^PURPLE^Name                    " SeriesTag strcat atell
     "^NAVY^-----------------------+---------------------------------------------------------"
  else
     "^PURPLE^Players" atell
     "^NAVY^---------------------------------------------------------------------------------"
  then
  atell
  array_vals 4 sort array_make foreach swap pop count ++
    dup dup on-or-idle? swap name strcat "                            " strcat
    SeriesTag if
       1 parse_ansi 22 ansi_strcut pop
       " ^NAVY^| ^NORMAL^" strcat
       swap seriesProp getpropstr dup strip not if
           pop UnsetSeries
       then
       strcat
    else
       swap pop
    then
    1 parse_ansi 78 ansi_strcut pop atell
  repeat
  "^NAVY^-- ^YELLOW^" count @ intostr strcat
  " ^NORMAL^characters found. ^NAVY^--"
  strcat atell
;
: do-scan ( -- a , array of matching players )
  var match_array
  0 array_make match_array !
  PropLoc propList remove_prop
  filter @ dup "*" instr not if "*" strcat "*" swap strcat then filter !
  #0 begin nextplayer dup ok? while
    dup add-player? if
      PropLoc over dup name propList "/" strcat swap strcat swap setprop
    else continue then
    sName @ if
      dup name filter @ smatch if dup
        match_array @ array_appenditem match_array ! continue
      then
    then
    sSeries @ if
      dup seriesProp getpropstr dup if
        filter @ smatch if dup
          match_array @ array_appenditem match_array ! continue
        then
      else pop then
    then
  repeat pop
  match_array @ print-results
;
: do-help ( -- )
  "^BLUE^" "" "-" 78 strlenset strcat atell
  "^WHITE^Proto UserList by Akari" 1 parse_ansi
  dup ansi_strlen 78 swap - 2 / "" swap " " swap strlenset
  swap strcat " " 78 strlenset atell
  "^BLUE^" "" "-" 78 strlenset strcat atell
  "A list of the characters on the MUCK. This program searches by series " .tell
  "and by character names. It maintains the _d/ directory in order to be " .tell
  "compatible with the userlist programs by Van and Confucious.          " .tell
  "The location of the property list is " proploc dtos strcat "." strcat .tell
  " " .tell
  "  " command @ strcat
  " #name <something>   - To search by character names only."
  strcat .tell
  "  " command @ strcat
  " #" strcat SeriesTag strcat "<something> - To search only by series.         "
  strcat .tell
  "  " command @ strcat
  " *                   - To list all the characters.       "
  strcat .tell
  "  " command @ strcat
  " <something>         - To search by both series and name."
  strcat .tell
  "  See ^YELLOW^'^NORMAL^man smatch^YELLOW^' ^NORMAL^for details about"
  " matching patterns." strcat atell
  "  Those marked ^GREEN^O ^NORMAL^are online at the moment." atell
  defaultIdle if
    "  Those marked ^RED^I ^NORMAL^are over ^YELLOW^"
   idlePref @ 86400 / intostr strcat " ^NORMAL^days idle." strcat
    atell
  then
  "^YELLOW^~Done~" atell
;
: main ( s -- )
  background strip
  PropLoc "_idle" getpropstr strip dup if atoi else pop defaultIdle then
  86400 * idlePref !
  SeriesTag if
  dup not if pop do-help exit then
  dup "#help" instring if pop do-help exit then
     dup "#" SeriesTag strcat instring if
       "" "#" SeriesTag strcat subst strip 1 sSeries ! dup not if pop do-help exit then
       filter ! do-scan exit then
     dup "#name" instring if
       "" "#name" subst strip 1 sName ! dup not if pop do-help exit then
     filter ! do-scan exit then
     1 sName ! 1 sSeries ! filter ! do-scan
  else
     dup not if
        pop "*"
     then
     1 sName ! 0 sSeries ! filter ! do-scan
  then
;
