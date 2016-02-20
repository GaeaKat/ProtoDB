$undef .split
$def .split \split
( build.muf - original by Alynna, some additions by Taral )
: cost
0
;
 
: main
dup dup "#help" strcmp and not if
  me @
  dup "@build by Alynna" notify
  dup " " notify
  dup "Syntax: "
   command @ strcat
   " <new room>=<exit>=<return exit>[=<description>]" strcat notify
  dup " " notify
  dup "new room:     Name of the room to create" notify
  dup "exit:         Name of the exit used to get to the new room" notify
  dup "return exit:  Name of the exit used to return here" notify
  dup "description:  @desc of the new room (optional)" notify
  dup " " notify
  dup "Player properties: (optional)" notify
  dup " " notify
  dup " _build/de:   @desc to use for new room by default" notify
  dup "   default: You may or may not see something special" notify
  dup " _build/succ: @succ to use for all new rooms" notify
  dup "   default: @$OBVEXITS" notify
  dup " " notify
  dup "Room properties: (optional)" notify
  dup " " notify
  dup " _build/public?:yes Any player with a builder bit can build from here" notify
  dup " _build/limit:<num> Maximum number of exits allowed in this room" notify
  dup "                    Note: this includes exits not created with @build" notify
  dup " " notify
  dup "Current cost of an @build: "
   cost intostr strcat
    " " strcat "pennies" sysparm strcat "." strcat notify
  exit
then
"=" .split "=" .split
dup not if
  me @
  "Syntax: "
  command @ strcat
  " <new room>=<exit>=<return exit>[=<description>]" strcat
  notify
  exit
then
"=" .split
dup not if
  pop
  me @ "_build/de" getprop
  dup string? not if pop 0 then
  dup not if
    pop "You may or may not see something special."
  then
then
loc @ 4 pick rmatch if
  me @ "That exit already exists." notify
  exit
then
cost
dup me @ pennies > if
  me @ dup "You dont have enough money." notify
  "You need "
  rot intostr strcat
  " " strcat "pennies" sysparm strcat "." strcat notify
  exit
then
-5 rotate
( cost roomname exitname returnexit description )
swap rot 4 rotate
( cost description returnexit exitname roomname )
loc @ location
begin dup "a" flag? over #0 dbcmp or not while
  location
repeat
( cost description returnexit exitname roomname parent )
swap newroom
"Room created: " over unparseobj strcat .tell
( cost description returnexit exitname newroom )
loc @ rot newexit
"Forward exit created: " over unparseobj strcat .tell
( cost description returnexit newroom newexit )
over setlink
me @ "Forward exit linked" notify
( cost description returnexit newroom )
dup rot newexit
"Return exit created: " over unparseobj strcat .tell
( cost description newroom rtnexit )
loc @ setlink
me @ "Return exit linked" notify
( cost description newroom )
dup rot setdesc
me @ "_build/succ" getprop dup string? not if pop 0 then
dup not if
  pop "@$OBVEXITS"
then
setsucc
me @ "@desc & @succ set" notify
me @ swap over over 0 swap - addpennies
(
"This @build cost you "
swap intostr strcat
" " strcat "pennies" sysparm strcat "." strcat notify
)
;
