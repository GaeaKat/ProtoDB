(*
   Web-WHO v1.3
   Author: Chris Brine [Moose/Van]
   v1.31:[By Akari]
    - Fixed the program to be 80 column friendly.
   v1.3: [By Moose]
    - Made the LIGHT flag work to force the showing of users, even if DARK is
      set.
    - Added a few more items to the stats screen, including the number of
      puppets, vehicles, and the current system time.
   Made for the internal webserver for ProtoMUCK 1.00+
*)
 
$author Moose
$version 1.31
 
$include $lib/standard
$include $Lib/Strings
 
VAR INTdescr
 
$def descr INTdescr @
 
$define thebody "<bo"
   "dy bgcolor=#000000 fgcolor=#BBBBBB text=#BBBBBB link=#0077FF vlink=#0077FF>"
   strcat
$enddef
 
: dotell ( s -- )
   "<TT>" swap strcat "</TT>" strcat
   descr swap notify_descriptor
;
 
: FIXHTML ( s -- s )
   "&amp;"  "&"  subst
   "&quot;" "\"" subst
   "&gt;"   ">"  subst
   "&lt;"   "<"  subst
;
 
: getname ( d -- s )
   dup name 17 STRLeft over name strlen strcut swap FIXHTML
   3 pick "/_/www" getpropstr dup not if pop 3 pick PROPS-webpage getpropstr then
   dup if
      "<a href=\"" swap dup "http://" instr 1 = not if
         "http://" swap strcat
      then
      strcat "\"><FONT color=#00FF00>" strcat swap strcat "</FONT></a>" strcat
   else
      pop 3 pick "/_/www#" propdir? if
         "<a href=\"/~" 4 pick name strcat "/\"><FONT color=#00FF00>"
         strcat swap strcat "</FONT></a>" strcat
      then
   then
   swap strcat swap pop
;
 
: timestr1 ( i i -- s )
   "" VAR! clockstr
   dup 86400 >= if
      86400 over over / rot rot % swap intostr "d" strcat clockstr !
   then
   3600 over over / rot rot % swap intostr ":" strcat
   swap 60 / intostr dup strlen 1 = if "0" swap strcat then strcat
   clockstr @ dup if " " strcat then swap strcat 10 STRRight
   dup strlen 10 > if pop "999d 23:59" then
   swap condbref "IDLE" flag? if
      "I"
   else
      " "
   then
   strcat
;
 
: timestr2b ( i -- s )
   dup 86400 > if
      86400 / intostr "d" strcat 4 STRRight
      dup strlen 4 > if pop "999d" then exit
   then
   dup 3600 > if
      3600 / intostr "h" strcat 4 STRRight
      dup strlen 4 > if pop "999d" then exit
   then
   dup 60 > if
      60 / intostr "m" strcat 4 STRRight dup strlen
      4 > if pop "999d" then exit
   then
   intostr "s" strcat 4 STRRight dup strlen 4 > if pop "999d" then
;
 
: timestr2 ( i i -- s )
   timestr2b
   swap condbref "INTERACTIVE" flag? if
      "* "
   else
      "  "
   then
   strcat
;
 
: FlagThingCount[ str:STRflag -- int:count ]
   0 VAR! count
   #0
   BEGIN
      STRflag @ NEXTTHING_FLAG dup ok? WHILE count ++
   REPEAT
   pop count @
;
 
: do-counter ( -- )
   prog "count" getpropval 1 +
   prog "count" 3 pick setprop
   "<CENTER><H5>This page has been visited %d times.</H5></CENTER>"
   swap intostr "%d" subst dotell
;
 
: main ( str:args -- )
   0 VAR! idx
   "|" explode pop atoi INTdescr ! pop pop pop
   descr thebody notify_descriptor
   "<TITLE>" "muckname" sysparm strcat " - Online Player Listing</TITLE>" strcat
   dotell
   "<B><FONT SIZE=+1>Users connected to " "muckname" sysparm strcat
   " as of %A, %B, %e, %Y, at %l:%M %p %Z.<BR></FONT></B>"
   systime timefmt strcat dotell
   "secure_who" sysparm "no" stringcmp not if
      "<B>Player Name          "
      "<PRE><FONT color=#00FF00>" swap strcat "</FONT><FONT color=#D000D0>"
      strcat "Online " strcat "</FONT><FONT color=YELLOW>"
      strcat "Idle  " strcat "</FONT><FONT color=CYAN>"
      strcat #0 "_poll" getpropstr dup not if pop "Doing..." then FIXHTML
      strcat "</FONT></B><HR>" strcat dotell
      #-1 descr_array
      FOREACH
         swap pop
         dup descrcon not if pop continue then
         dup descrcon condbref dup "DARK" flag? swap "LIGHT" flag? not
         and if pop continue then
         dup descrcon condbref getname
         "<FONT color=#00FF00>" swap strcat "</FONT><FONT color=D000D0>"
         strcat over descrcon dup contime timestr1 strcat
         "</FONT><FONT color=YELLOW>" strcat over descrcon dup conidle
         timestr2 strcat "</FONT><FONT color=CYAN>"
         strcat over descrcon condbref "_/do" getpropstr strip FIXHTML
         45 STRLeft dup strlen 45 > if 45 strcut pop then
         strcat "</FONT>" strcat dotell idx ++
      REPEAT
      "<HR>" dotell
      "<B>" idx @ intostr strcat "</B>" strcat idx @ 1 = if " player is "
      else " players are " then strcat "connected, max was <B>" strcat
      #0 "~sys/max_connects" getpropval intostr "</B>." strcat strcat dotell
   else
      "<BR><B><FONT COLOR=red>This MUCK does not allow WHO listings when not"
      " logged in.  So, log in and find out!</FONT></B>" strcat dotell
   then
   "</PRE><BR><B>Last restart:</B> %A, %B %e, %Y at %l:%M %p %Z.<BR>"
   #0 "~sys/startuptime" getprop timefmt dotell
   "<B>System time:</B>  %A, %B %e, %Y at %l:%M %p %Z.<HR>" systime timefmt
   dotell
   "<PRE><FONT SIZE=+1>" "Current Database Statistics For "
   strcat "muckname" sysparm strcat "</FONT>" strcat dotell
   #-1 stats
   "<B>     Players: </B>" rot intostr 10 STRLeft strcat
   "<B>    Programs: </B>" 4 rotate intostr 10 STRLeft strcat strcat
   "<B>      Things: </B>" 4 rotate intostr 10 STRLeft strcat strcat "<BR>"
   strcat
   "<I>              </I>" "" 10 STRleft strcat strcat
   "<I>     Puppets: </I>" "ZOMBIE" FlagThingCount intostr 10 STRleft strcat
   strcat
   "<I>    Vehicles: </I>" "VEHICLE" FlagThingCount intostr 10 STRleft strcat
   strcat "<BR>" strcat
   "<B>       Exits: </B>" 4 rotate intostr 10 STRLeft strcat strcat
   "<B>       Rooms: </B>" 4 rotate intostr 10 STRleft strcat strcat
   "<B>     Garbage: </B>" rot intostr 10 STRLeft strcat strcat "<BR>" strcat
   "<B>       Total: </B>" rot intostr 10 STRLeft strcat strcat
   "<B>Last Dump On: </B>%A, %B %e, %Y at %l:%M %p %Z."
   #0 "~sys/lastdumptime" getprop timefmt strcat
   "</PRE><HR>" strcat dotell
   "muckname" sysparm " is running on " strcat version strcat
   "<HR>" strcat dotell
   "<a href=\"" #0 "/_/www/main" getpropstr dup not IF
      pop "/"
   THEN
   strcat "\">Return to the main page</a>" strcat dotell
  10 sleep
   do-counter
;
