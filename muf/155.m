(*
   Web-LookUp v1.2
   Author: Chris Brine [Moose/Van]
*)
 
$author Moose
$version 1.2
$include $lib/standard
$def thebody "<BO" "DY bgcolor=#000000 fgcolor=#BBBBBB text=#BBBBBB link=#0077FF vlink=#0077FF>" strcat
 
VAR INTdescr
 
$def descr INTdescr @
 
: dotell ( s -- )
   descr swap notify_descriptor
;
 
: FIXHTML ( s -- s )
   "&amp;"  "&"  subst
   "&quot;" "\"" subst
   "&gt;"   ">"  subst
   "&lt;"   "<"  subst
;
 
: show-liveinfo ( s -- )
   pmatch dup ok? not if
      "<I>I'm sorry, but that user can not be found. Please try again.</I>" dotell exit
   then
   "<B><FONT SIZE=+3><U>LiveInfo:</U> " over name FIXHTML strcat "</FONT></B><HR>" strcat dotell
   dup awake? over dup "DARK" flag? not swap "LIGHT" flag? or and if
      "<B><FONT color=green>%n is currently online.</FONT></B><HR>" over name FIXHTML "%n" subst dotell
   then
   dup "_/www" getpropstr over "_/www#" propdir? or over PROPS-webpage getpropstr or if
      "<I>This player has a webpage at: </I><a href=\"/~"
      over name strcat "\">" strcat over "_/www" getpropstr 3 pick PROPS-webpage getpropstr or if
         over "_/www" getpropstr dup not if pop over PROPS-webpage getpropstr then
         dup "http://" instring 1 = not if "http://" swap strcat then strcat
      else
         "http://" strcat "servername" sysparm strcat ":" strcat "wwwport"
         sysparm strcat "/~" strcat over name strcat
      then
      "</a><HR>" strcat
      dotell
   then
   dup PROPS-picture_url getpropstr strip dup if
      "<img src=\"" swap strcat "\" align=right>" strcat dotell
   else
      pop
   then
   dup PROPS-web_shortinfo array_get_proplist dup array_count not if
      pop dup PROPS-web_shortinfo getpropstr strip dup not if
         pop { over "<I>This user does not have %p information set.</I>" pronoun_sub }list
      else
         { swap }list
      then
   then
   FOREACH
      swap pop over swap "(Webserver)" 1 parsempi "<BR>" "\r" subst "" "\[" subst dotell
   REPEAT
   pop
   "<BR CLEAR=ALL>" dotell
;
 
: ask-liveinfo ( s -- )
   "<B>Enter the username that you wish to search for: "
   "<FORM method=get action=\"\"><INPUT type=\"TEXT\" name=\"user\" value=\"%1\" maxlength=25 size=25>" rot "%1" subst strcat
   " <INPUT type=\"SUBMIT\" value=\"Lookup\"></FORM></B>" strcat dotell
;
 
: main ( s -- )
   "" VAR! strname
   thebody dotell
   "|" explode pop atoi INTdescr ! pop pop
   dup "user=" stringpfx over and if
      5 strcut swap pop strip strname !
   then
   strname @ if
      strname @ show-liveinfo
      "<HR>" dotell
   then
   strname @ ask-liveinfo
   "<HR><a href=\"" #0 "/_/www/main" getpropstr dup not IF
      pop "/"
   THEN
   strcat "\">Return to the main page</a>" strcat dotell
;
