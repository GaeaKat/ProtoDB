( Gallery.HTMuf, by Akari )
( Based roughly on userlist.HTMuf by Loki )
$author Akari
$version 1.0
$def serverbase ""
$include $lib/cgi
$include $lib/standard
$def userlist "$CMD/Userlist" match
var descr
var user
var host
var params
: write
  descr @ swap notify_descriptor
;
: doheader
  "<title>" "muckname" sysparm strcat " Picture Gallery</title>" strcat write
  "<body bgcolor=#000000 fgcolor=#BBBBBB text=#BBBBBB link=#0077FF vlink=#0077FF>" write
  "<h1>" "muckname" sysparm strcat " Picture Gallery</h1>" strcat write
  "This page is a gallery of the characters on " "muckname" sysparm strcat ". If you have a character, and would like to add your character's picture to the gallery, just set a prop on your character called '" PROPS-web_gallery_pic strcat "', with the URL to a picture. <br><b>Note</b>:The pictures -must- be no larger than 200 pixels wide. I'll leave it up to you to watch for that, but if I see people not staying within that limit, I'll start forcing all pictures to be displayed at 200 pixels wide (give or take 20 or so ), which would distort any that are less wide.<hr>" strcat strcat write
  "<table width=100% border=0>" write
  "<tr><th></th><th align=left><b></b></th><th align=left><b></b></th><th align=left><b></b></th></tr>"
  write
;
: dofooter
"</table><HR><BR><BR>To return to the main page, click <a href=\""
#0 "/_/www/main" getpropstr dup not IF
   pop "/"
THEN
strcat "\">here</a>." strcat write
;
lvar curuser
lvar liveinfo
lvar homepage
lvar usericon
lvar curprop
lvar count
: make-table ( -- )
  "<td><center><img src=\"" swap strcat "\"><br><font size=\"3\"><b>" strcat
  curuser @ name strcat "</font></center></td>" strcat
  count @ 3 % not if "</tr><tr>" strcat then
  write
;
: userLoop
  "<tr>" write
  #-1 curuser !
  "/_d/" curprop !
  begin
    "" liveinfo ! "" homepage ! "" usericon !
    userlist curprop @ nextprop dup curprop !
    dup while
    userlist swap getprop dup curuser ! player? if
      curuser @ PROPS-web_gallery_pic getpropstr dup if
        count ++ make-table else pop then
    then
  repeat
;
: do-count
  prog "count" getpropval 1 + prog over "count" swap setprop
  "<center><h5>This page has been visited " swap intostr strcat
  " times.</h5></center>" strcat write
;
: main
  parseweb
  doheader
  userLoop
  dofooter
  do-count
;
