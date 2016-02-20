(*
   Web-UsersLookUp v1.2
   Author: Chris Brine [Moose/Van]
 
   v1.2: [By Moose]
    - Added a section that shows if a player is online or not
 *)
 
$author Moose
$version 1.2
$include $lib/cgi
$include $lib/standard
 
VAR INTdescr
 
$def descr INTdescr @
 
$def thebody "<BO" "DY bgcolor=#000000 fgcolor=#BBBBBB text=#BBBBBB link=#0000FF vlink=#0000FF>" strcat
$def dotell descr swap notify_descriptor
 
: HasLiveInfo?[ ref:ref -- int:BOLint ]
   ref @ "/_LiveInfo/Picture" getpropstr if
      2
   else
      0
   then
   ref @ PROPS-web_shortinfo "#" strcat propdir? if
      3
   else
      0
   then
   +
;
 
: HasWebpage?[ ref:ref -- int:BOLint ]
   ref @ PROPS-webpage getpropstr if
      3
   else
      ref @ "/_/www" getpropstr if
         2
      else
         ref @ "/_/www#" propdir? if
            1
         else
            0
         then
      then
   then
;
 
: ShowUser[ ref:ref -- ]
   "<tr><td width=\"120\" align=center>"
   ref @ PROPS-web_icon getpropstr if
      "<img src=\"" strcat ref @ PROPS-web_icon getpropstr strcat "\">" strcat
   then
   "</td><td align=center>" strcat
   ref @ awake? ref @ "DARK" flag? not ref @ "LIGHT" flag? or and if
      "<font color=green>[O]</font>" strcat
   then
   "</td><td>" strcat
   ref @ name TEXT2HTML ref @ "TRUEWIZARD" flag? if " <B>(Wiz)</B>" strcat then strcat "</td><td>" strcat
   ref @ HasWebpage? dup if
      "<a href=\"" swap dup 3 = if
         pop ref @ PROPS-webpage getpropstr dup "http://" instr 1 = not if
            "http://" swap strcat
         then
      else
         2 = if
            ref @ "/_/www" getpropstr dup "http://" instr 1 = not if
               "http://" swap strcat
            then
         else
            "/~" ref @ name strcat "/" strcat
         then
      then
      strcat "\">Click Here</a>" strcat strcat
   else
      pop
   then
   "</td><td>" strcat ref @ HasLiveInfo? if
      "<a href=\"/LookUp?user=" strcat ref @ name strcat "\">Click Here</a>" strcat
   then
   "</td></tr>" strcat dotell
;
 
: array_get_propvals[ ref:ref str:STRpropdir -- dict:DICTprops ]
   { }dict STRpropdir @
   BEGIN
      ref @ swap NEXTPROP dup WHILE
      dup STRpropdir @ strlen strcut swap pop ref @ 3 pick getprop 4 rotate rot array_setitem swap
   REPEAT
   pop
;
 
: GrabUsers ( -- arr:ARRusers )
   #-1 #-1 "" "P!G" FIND_ARRAY SORTTYPE_NOCASE_ASCEND \array_sort
;
 
: DoCounter ( -- )
   prog "count" getpropval 1 +
   prog "count" 3 pick setprop
   "<CENTER><H5>This page has been visited %d times.</H5></CENTER>" swap intostr "%d" subst dotell
;
 
: main ( str:Args -- )
   "|" explode pop atoi INTdescr ! pop pop pop
   thebody dotell
   "<H1>%s User Directory</H1>" "muckname" sysparm TEXT2HTML "%s" subst dotell
   "This is a quick directory of <i>only</i> the MUCK users who have set homepages or LiveInfo information.<HR>" dotell
   "<table width=100% border=0>" dotell
   "<tr><th></th><th><font color=green><b>[O]</b></font><th align=left><b>User</b></th><th align=left><b>Homepage</b></th>"
   "<th align=left><b>LiveInfo</b></th></tr>" strcat dotell
   GrabUsers
   FOREACH
      swap pop dup HasWebPage? over HasLiveInfo? or if
         ShowUser
      else
         pop
      then
   REPEAT
   "</table><HR><BR><BR><a href=\"" #0 "/_/www/main" getpropstr dup not IF
      pop "/"
   THEN
   strcat "\">Return to the main page</a>" strcat dotell
   DoCounter 5 sleep descr descrboot 1 sleep
;
