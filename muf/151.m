(*
   Web-Userlist v1.6
   Author: Chris Brine [Moose/Van]
   v1.6: [By Akari]
    - Reformatted to be 80 column friendly for Web PubProgs listing and removed
      Hellmouth dependency code.
   hm:
    - Modified for features for Hellmouth
   v1.5: [By Moose]
    - Modified to show if player is online or not.
    - Changed so that it does not have to be set as /_/www/userlist anymore
   For ProtoMUCK servers only.
*)
 
$author Moose
$version 1.6
 
$include $lib/standard
 
( The word BODY has to be split into two pieces otherwords IE interprets this
  document as a valid web page instead of a text listing. )
$define thebody "<BO"
   "DY bgcolor=#000000 fgcolor=#BBBBBB text=#BBBBBB link=#0000FF vlink=#0000FF>"
   strcat
$enddef
 
VAR INTdescr
 
$def descr INTdescr @
 
: dotell ( s -- )
   descr swap notify_descriptor
;
 
: HTMLunparse ( s -- s )
   "&amp;" "&" subst
   "&quot;" "&" subst
   "&gt;" ">" subst
   "&lt;" "<" subst
;
 
: getname ( d -- s )
   dup name HTMLunparse over "/_/www" getpropstr dup not if pop over
   PROPS-webpage getpropstr then dup if
      "<a href=\"" swap dup "http://" instr 1 = not if
         "http://" swap strcat
      then
      strcat "\"><FONT color=#00FF00>" strcat swap strcat "</FONT></a>" strcat
   else
      pop over "/_/www#" propdir? if
         "<a href=\"/~" 3 pick name strcat "/\"><FONT color=#00FF00>"
         strcat swap strcat "</FONT></a>" strcat
      then
   then
   swap pop
;
 
: do-counter ( -- )
   prog "count" getpropval 1 +
   prog "count" 3 pick setprop
   "<CENTER><H5>This page has been visited %d times.</H5></CENTER>"
   swap intostr "%d" subst dotell
;
 
: array_get_propvals[ ref:ref str:STRpropdir -- dict:DICTprops ]
   { }dict STRpropdir @
   BEGIN
      ref @ swap NEXTPROP dup WHILE
      dup STRpropdir @ strlen strcut swap pop ref @ 3 pick getprop 4 rotate rot
      array_setitem swap
   REPEAT
   pop
;
 
: GRAB_USERS ( -- dict:DICTusers )
   #-1 #-1 "" "P!G" FIND_ARRAY SORTTYPE_NOCASE_ASCEND \array_sort
;
 
: main ( s -- )
   "|" explode pop atoi INTdescr ! pop pop
   7 strcut swap pop strip var! searchstr
   descr thebody notify_descriptor
   "<TITLE>" "muckname" sysparm strcat " - User Listing</TITLE>" strcat dotell
   "<B><H1>" "muckname" sysparm strcat " User Directory</H1></B>" strcat dotell
   "<B>For a smaller list, enter a search string below "
   "(or nothing for all users):</B>" strcat dotell
   "<FORM method=get action=\"\"><INPUT type=\"TEXT\" name=\"search\""
   " value=\"%1\" maxlength=25 size=25>" strcat searchstr @ "%1" subst dotell
   "<INPUT type=\"SUBMIT\" value=\"Search\"></FORM>" dotell
   "<center><table border=2 width=70%><tr><th><font color=green><B>[O]"
   "</B></font></th><th><B>Character</B></th><th><B>Series</B></th></tr>"
   strcat dotell
   searchstr @ strip dup not if "*" searchstr ! then
   searchstr @ dup "*" instr not if "*" swap over strcat strcat then searchstr !
   GRAB_USERS
   FOREACH
      swap pop dup name searchstr @ smatch not if pop continue then
      dup "G" flag? if pop continue then
      dup "player_prototype" sysparm stod dbcmp if pop continue then
      dup "www_surfer" sysparm stod dbcmp if pop continue then
      dup "@Ignore?" getpropstr "y" stringpfx IF pop continue THEN
      "$Cmd/UserList" match dup Dbref? IF
         "@IgnoreList" 3 pick REFLIST_find IF pop continue THEN
      ELSE
         pop
      THEN
      #0 "@IgnoreList" 3 pick REFLIST_find IF pop continue THEN
      dup awake? over dup "DARK" flag? not swap "LIGHT" flag? or and if
         "<font color=green>[O]</font>"
      else
         "&nbsp;&nbsp;&nbsp;"
      then
      "&nbsp;"
      strcat "<tr><td align=center><TT>" swap strcat "</TT></td><td><B>" strcat
      over getname strcat "</B></td><td width=\"75%\"><I>" strcat
      over "series" getpropstr
      dup not if pop "<None Set>" then HTMLunparse strcat
      "</I></td></tr>" strcat dotell pop
   REPEAT
   pop "</table></center><HR><BR>" dotell
   "<a href=\"" #0 "/_/www/main" getpropstr dup not IF
      pop "/"
   THEN
   strcat "\">Return to the main page</a>" strcat dotell
   do-counter
   10 sleep descr descrboot 1 sleep
;
