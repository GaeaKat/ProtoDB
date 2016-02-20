$include $lib/alynna
$def tname target @ name
$def tsex target @ "sex" getpropstr dup "" stringcmp if 1 strcut pop toupper else pop "?" then
$def tspec target @ "species" getpropstr
$def tstat target @ "~status" getpropstr
$def tonline target @ owner onlinetime 60 / dhm
$def tidle target @ owner idletime stimestr
$def tloc target @ location me @ mlevel 5 >= if unparseobj strcat then
 
$def tref target @ unparseobj "" target @ name subst "" "(" subst "" ")" subst
$def tbit target @ mlevel intostr
$ifdef __fuzzball__
$def tipnum "--"
$def tport "--"
$else
$def tipnum value @ descripnum
$def tport value @ descrport
$endif
$def tdescr value @ intostr
$def tobjs target @ stats pop pop pop pop pop pop intostr
$def thost value @ descrhost
 
$def YES? tolower "y*" smatch
 
lvar ttotal
lvar tplayers
lvar trooms
lvar texits
lvar tprograms
lvar tthings
lvar tgarbage
 
: wheader ( -- )
command @ "ws" smatch if
  { "^WHITE^^BGREEN^Name          ^BBROWN^S Species              ^BCYAN^    Time IDL STA ^BBLUE^Short Desc               ^NORMAL^" }tell
then
command @ "{fa|wwi|wizwwi}" smatch if
  { "^WHITE^^BGREEN^Name          ^BBROWN^S Species              ^BCYAN^    Time IDL STA ^BBLUE^Location name            ^NORMAL^" }tell
then
command @ "wizwwi" smatch if
  { "^WHITE^^BGREEN^DBREF         ^BBROWN^M IP:Port              ^BCYAN^    Objs DSC ^BBLUE^Hostname                    ^NORMAL^" }tell
then
command @ "dbwwi" smatch if
  { "^WHITE^^BGREEN^Totals     ^BCYAN^Rooms      ^BGREEN^Exits      ^BYELLOW^Things     ^BBLUE^Programs   ^BPURPLE^Players    ^BRED^Garbage      ^NORMAL^" }tell
( stats: d -- total rooms exits things programs players garbage )
{ #-1 stats tgarbage ! tplayers ! tprograms ! tthings ! texits ! trooms ! ttotal !
    tgarbage @   tgarbage @ ttotal @  1.0 * / 100.0 * swap
    tplayers @   tplayers @ ttotal @  1.0 * / 100.0 * swap
    tprograms @  tprograms @ ttotal @ 1.0 * / 100.0 * swap
    tthings @    tthings @ ttotal @   1.0 * / 100.0 * swap
    texits @     texits @ ttotal @    1.0 * / 100.0 * swap
    trooms @     trooms @ ttotal @    1.0 * / 100.0 * swap
    ttotal @     ttotal @ ttotal @    1.0 * / 100.0 * int swap
    "^WHITE^^BGREEN^%5i %4i%%^BCYAN^%5i %4.1f%%^BGREEN^%5i %4.1f%%^BYELLOW^%5i %4.1f%%^BBLUE^%5i %4.1f%%^BPURPLE^%5i %4.1f%%^BRED^%5i %4.1f%%  ^NORMAL^" fmtstring }tell
then
;
: wfooter ( -- )
  {
  "^WHITE^^BBLUE^-/@< Who/Where/Idle by Alynna >@\\-----"
  { me @ location numplayers "/" concount "/" #0 "/_sys/max_connects" getprop "------------------" }cat 19 strcut pop
  "[ " strcat "%x %X" systime timefmt strcat " ]-^NORMAL^"
  }tell
;
 
: main
var target
var item
var value
 
var iplayers
var igarbage
var iprograms
var ithings
var iexits
var irooms
var itotal
 
wheader
command @ "ws" smatch not if
 online_array
else
 { me @ location contents_array foreach
    swap pop dup dup player? swap "Z" flag? or if dup awake? not if pop then else pop then
   repeat }array
then
 
SORTTYPE_NOCASE_ASCEND array_sort foreach target ! pop
 
command @ "{fa|ws|wwi|wizwwi}" smatch if
target @ "HIDDEN" flag? not target @ "D" flag? not target @ "_invisible?" getpropstr yes? not
target @ location "D" flag? not target @ location "_invisible?" getpropstr yes? not or or or or
me @ mlevel 5 >= if pop 1 then if
 { "^GREEN^" tname 13 lj
     " ^YELLOW^" tsex " " tspec 21 lj
     "^CYAN^" tonline 8 rj " " tidle 3 lj " " tstat 3 lj
     " ^WHITE^"
  target @ "H" flag? target @ "_private?" getpropstr yes? target @ "_prefs/private?" getpropstr yes?
  target @ location "H" flag? target @ location "_private?" getpropstr yes? target @ location "_prefs/private?" getpropstr yes? or or or or or
  me @ mlevel 5 >= if pop 0 then if
   "<Private>"
  else
  target @ location me @ location dbcmp if
  command @ "ws" smatch if
    target @ thing? if "(Puppet: " target @ owner ") " then target @ "sdesc" "SDESC" 0 parseprop
   else
    "<Here>"
   then
  else
   tloc
  then
 then
 "^NORMAL^"
 }tell
then then
 
( expanded wiz wwi )
me @ mlevel 5 >= if command @ "{wizwwi}" smatch if
target @ descriptors array_make foreach value ! item !
{
     "^GREEN^" tref 13 lj
     " ^YELLOW^" tbit " " tipnum ":" tport strcat strcat 21 lj
     "^CYAN^" tobjs 8 rj " " tdescr 3 rj
     " ^WHITE^" thost
}tell
repeat
then then
 
command @ "{dbwwi}" smatch if
  target @ stats igarbage ! iplayers ! iprograms ! ithings ! iexits ! irooms ! itotal !
    iprograms @  iprograms @ tprograms @ 1.0 * / 100.0 * swap
    ithings @    ithings @ tthings @     1.0 * / 100.0 * swap
    iexits @     iexits @ texits @       1.0 * / 100.0 * swap
    irooms @     irooms @ trooms @       1.0 * / 100.0 * swap
    itotal @     itotal @ ttotal @       1.0 * / 100.0 * swap
    "^WHITE^^BGREEN^%5i %4.1f%%^BCYAN^%5i %4.1f%%^BGREEN^%5i %4.1f%%^BYELLOW^%5i %4.1f%%^BBLUE^%5i %4.1f%%^NORMAL^" fmtstring
    { swap
    "^BPURPLE^ " target @ unparseobj 23 lj "^NORMAL^"
    }tell
then
repeat
 
wfooter
;
