lvar newref
lvar myname
lvar passwd
lvar email
 
$include $lib/alynna
$def rtell descr swap descrnotify
$def wiznotify prog "MOBILE" flag? if { "!wc #" rot }cat "$avatar" match swap force then
 
: error ( i -- )
dup 0 = if "[Request] No errors." rtell then
dup 1 = if "[Request] Format: request name=password=email" rtell then
dup 2 = if "[Request] Name invalid or taken, try another." rtell then
pop
;
: main
me @ #-1 dbcmp not if
 me @ "@/lastrequest" getprop systime 300 - > if
  { "[Request] You must wait " systime 300 - me @ "@/lastrequest" getprop - timex " before requesting another character." }cat rtell exit then
then
"=" explode 3 = not if 1 error exit then
myname ! passwd ! email !
myname @ pmatch #-1 = not if 2 error exit then
myname @ passwd @ newplayer newref !
newref @ "/@pc/name" myname @ setprop
newref @ "/@pc/startname" myname @ setprop
me @ #-1 dbcmp if
 newref @ "/@/createdby" "<Login>" setprop
 newref @ "/@/id" { myname @ ":-:" email @ ":" date rot "/" 4 rotate "/" 5 rotate ":<Login>" }cat setprop
else
 newref @ "/@/createdby" me @ name setprop
 newref @ "/@/id" { myname @ ":-:" email @ ":" date rot "/" 4 rotate "/" 5 rotate ":" me @ }cat setprop
then
newref @ "/@/email" email @ setprop
 
{ "[Request] A character named '" newref @ "' should have been made with the password of '" passwd @ "', you will now be automatically logged into it." }cat rtell
me @ #-1 dbcmp not if
 { "[Request] " me @  " just requested character '" newref @ "', and it was created." }cat tellhere
 me @ "@/lastrequest" systime setprop
then
{ "[Request] " me @ #-1 dbcmp if "<Login>" else me @ then " just requested character '" newref @ "', and it was created." }cat wiznotify
descr newref @ passwd @ descr_setuser
;
