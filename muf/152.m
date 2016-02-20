(*
   WebNews
 *)
$author  Moose
$version 1.0
 
$cleardefs
 
$def HTML_TITLE   "<h2>ProtoMUCK: <i><font size=\"3\">News</font></i></h2>"
$def NOHTML_TITLE "ProtoMUCK: News"
 
$include $Lib/CGI
$include $Lib/Editor
$include $Lib/Strings
 
VAR INTdescr
 
$def descr INTdescr @
 
$def TELL descr swap notify_descriptor
$define ATELL
   FOREACH
      swap pop TELL
   REPEAT
$enddef
$def BLINE " " TELL
 
: WEB-title[ -- ]
   prog "@TITLE" ARRAY_get_proplist dup ARRAY_count if
      ATELL
   else
      pop
      "<html>" TELL
      BLINE
      "<head>" TELL
      "<title>" NOHTML_TITLE strcat "</title>" strcat TELL
      "</head>" TELL
      BLINE
      "<body bgcolor=\"#000000\" text=\"#FFFFFF\" link=\"#00FF00\" vlink=\"#00FF00\" alink=\"#00FF00\">" TELL
      BLINE
      HTML_TITLE TELL
      "<div align=\"left\">" TELL
      "  <table border=\"1\" width=\"50%\" bgcolor=\"#0000FF\" cellspacing=\"0\" cellpadding=\"0\">" TELL
      "    <tr>" TELL
      "      <td width=\"100%\" valign=\"middle\" align=\"center\"><a href=\""
      #0 "/_/www/main" getpropstr dup not IF
         pop "/"
      THEN
      strcat "\">Back To The Main Page</a></td>" strcat TELL
      "    </tr>" TELL
      "  </table>" TELL
      "</div>" TELL
      BLINE
   then
;
 
: WEB-show-news[ int:INTpost -- ]
   VAR STRpost
   INTpost @ intostr STRpost !
   prog "/@News/Post/" STRpost @ strcat Propdir? if
      "<br>" TELL
      "<br>" TELL
      "<div align=center>" TELL
      "  <center>" TELL
      "  <table border=\"1\" width=\"100%\" bgcolor=\"#0000FF\" cellspacing=\"0\" cellpadding=\"0\">" TELL
      "    <tr>" TELL
      "      <td width=\"70%\"><b>"
             prog "/@News/Post/" STRpost @ strcat "/Subject" strcat getpropstr
             TEXT2HTML strcat "</b></td>" strcat TELL
      "      <td width=\"30%\"><b>"
             prog "/@News/Post/" STRpost @ strcat "/Date" strcat getpropval
             "%a&nbsp;%b&nbsp;%e,&nbsp;%Y&nbsp&nbsp;&nbsp;&nbsp;%l:%M %p %Z" swap TimeFMT
             strcat "</b></td>" strcat TELL
      "    </tr>" TELL
      "  </table>" TELL
      "  </center>" TELL
      "</div>" TELL
      "<p><TT>" TELL
      prog "/@News/Post/" STRpost @ strcat "/Message" strcat ARRAY_get_proplist
      FOREACH
         swap pop "<BR>" strcat TELL
      REPEAT
      "</TT></p>" TELL
   then
;
 
: WEB-news[ -- ]
   VAR INTspot
   prog "/@News" getpropval dup 0 > if
      INTspot !
      BEGIN
         prog "/@News/" INTspot @ intostr strcat getpropval
         WEB-show-news
      INTspot dup -- @ 0 <= UNTIL
   else
      pop
      "<p><font color=\"red\">No News Posts!</font></p>"
   then
;
 
: WEB-footer[ -- ]
   prog "@FOOTER" ARRAY_get_proplist dup ARRAY_count if
      ATELL
   else
      pop
      "<h6><i>(c) Copyright 2000-2001 Proto Team (Moose and Akari)<br>" TELL
      "Webpage Designed by Moose</i></h6>" TELL
      BLINE
      "</body>" TELL
      BLINE
      "</html>" TELL
      BLINE
   then
;
 
: WEB-main[ str:Args -- ]
   Args @ "|" explode pop atoi INTdescr ! pop pop pop
   WEB-title
   WEB-news
   WEB-footer
;
 
: MUCK-add[ -- ]
   VAR STRsubj VAR ARRpost VAR INTpost
   me @ "^CNOTE^Please enter a short subject phrase for this post:" ansi_notify
   READ STRsubj !
   me @ "^CINFO^Subject: " STRsubj @ 1 escape_ansi STRsubj !
   { }list ArrayEDITOR pop dup ARRAY_count not if
      pop me @ "^CFAIL^Aborted." ansi_notify EXIT
   then
   ARRpost !
   0 INTpost !
   BEGIN
      INTpost ++
      prog "/@News/Post/" INTpost @ intostr strcat Propdir? not if
         BREAK
      then
   REPEAT
   prog "/@News/Post/" INTpost @ intostr strcat
   over over "/Subject" strcat STRsubj @ setprop
   over over "/Message" strcat ARRpost @ ARRAY_put_proplist
   "/Date" strcat SYStime setprop
   prog "/@News" over over getpropval ++ rot rot 3 pick setprop
   prog "/@News/" rot intostr strcat INTpost @ setprop
   me @ "^CINFO^News essage posted!" ansi_notify
   me @ "^CINFO^*Done*" ansi_notify
;
 
: MUCK-show-header[ int:INTpost -- ]
   VAR STRpost
   "^BBLUE^^PURPLE^[^YELLOW^#" INTpost @ intostr 3 STRright strcat
   " ^PURPLE^| ^WHITE^" strcat
   prog "/@News/" INTpost @ intostr strcat getpropval INTpost !
   prog "/@News/Post/" INTpost @ intostr strcat dup STRpost ! "/Subject" strcat getpropstr
   47 STRleft dup strlen 47 > if 47 strcut pop then 1 escape_ansi strcat
   " ^PURPLE^| ^CYAN^%m/%d/%y %H:%M %Z ^PURPLE^]"
   prog STRpost @ "/Date" strcat getpropval TimeFMT strcat
   me @ swap ansi_notify
;
 
: MUCK-list[ -- ]
   0 VAR! INTpost
     VAR  NUMposts
   me @ "^CNOTE^Posts:" ansi_notify
   prog "/@News" getpropval dup NUMposts ! 0 > if
      BEGIN
         INTpost dup ++ @ MUCK-show-header
      INTpost @ NUMposts @ >= UNTIL
   then
   me @ "^CINFO^Done." ansi_notify
;
 
: MUCK-show[ int:INTpost -- ]
   VAR STRpost
   prog "/@News/" INTpost @ intostr strcat getpropval dup not if
      pop
      me @ "^CFAIL^Invalid message number." ansi_notify
      EXIT
   then
   "^BBLUE^^PURPLE^[^YELLOW^#" INTpost @ intostr 3 STRright strcat
   " ^PURPLE^| ^WHITE^" strcat swap INTpost !
   prog "/@News/Post/" INTpost @ intostr strcat dup STRpost ! "/Subject" strcat getpropstr
   47 STRleft dup strlen 47 > if 47 strcut pop then 1 escape_ansi strcat
   " ^PURPLE^| ^CYAN^%m/%d/%y %H:%M %Z ^PURPLE^]"
   prog STRpost @ "/Date" strcat getpropval TimeFMT strcat
   me @ swap ansi_notify
   prog STRpost @ "/Message" strcat ARRAY_get_proplist
   { me @ }list ARRAY_ansi_notify
   me @ "^CINFO^Done." ansi_notify
;
 
: MUCK-edit[ int:INTpost -- ]
   prog "/@News/" INTpost @ intostr strcat getpropval dup if
      INTpost !
      prog "/@News/Post/" INTpost @ intostr strcat "/Message" strcat
      over over ARRAY_get_proplist ArrayEDITOR pop dup array_count if
         ARRAY_put_proplist
         me @ "^CSUCC^Finised." ansi_notify
      else
         pop pop pop
         me @ "^CFAIL^Aborted." ansi_notify
      then
   else
      pop
      me @ "^CFAIL^Invalid message number." ansi_notify
   then
;
 
: MUCK-remove[ int:INTpost -- ]
   VAR NUMposts
   prog "/@News/" INTpost @ intostr strcat getpropval dup not if
      pop
      me @ "^CFAIL^Invalid message number." ansi_notify
      EXIT
   then
   prog "/@News/Post/" rot intostr strcat remove_prop
   prog "/@News" over over getpropval 1 - dup NUMposts ! setprop
   BEGIN
      prog "/@News/" over over INTpost @ intostr strcat
      rot rot INTpost dup ++ @ intostr strcat getpropval setprop
      prog "/@News/" INTpost @ intostr strcat remove_prop
   INTpost @ NUMposts @ > UNTIL
   me @ "^CINFO^Removed the post." ansi_notify
;
 
: MUCK-help[ -- ]
  {
             "^CINFO^WEBnews - by Moose/Van"
             "^WHITE^~~~~~~~~~~~~~~~~~~~~~~~"
   command @ "               ^WHITE^- See #list"           strcat
   command @ " #help         ^WHITE^- This screen"         strcat
   command @ " #list         ^WHITE^- List all news posts" strcat
   command @ " #add          ^WHITE^- Add    a news post"  strcat
   command @ " #show <post#> ^WHITE^- Show   a news post"  strcat
   command @ " #edit <post#> ^WHITE^- Edit   a news post"  strcat
   command @ " #rem  <post#> ^WHITE^- Remove a news post"  strcat
             "^CINFO^*Done*"
  }list
   { me @ }list ARRAY_ansi_notify
;
 
: MUCK-main[ str:Args -- ]
   me @ "BOY" Flag? not if
      me @ "^CFAIL^Permission denied." ansi_notify EXIT
   then
   Args @ " " split strip Args ! strip
   dup "#help" stringcmp not if
      pop MUCK-help EXIT
   then
   dup "#list" stringcmp not if
      pop MUCK-list EXIT
   then
   dup "#add" stringcmp not if
      pop MUCK-add EXIT
   then
   dup "#show" stringcmp not if
      pop Args @ atoi MUCK-show EXIT
   then
   dup "#edit" stringcmp not if
      pop Args @ atoi MUCK-edit EXIT
   then
   dup "#rem" stringcmp not if
      pop Args @ atoi MUCK-remove EXIT
   then
   pop MUCK-help
;
 
: main[ str:Args -- ]
   command @ "(WWW)" stringcmp not if
      Args @ WEB-main
   else
      Args @ MUCK-main
   then
;
