( meetme.muf -- 1/22/95 by Squirrelly@Furtoonia, Ported by Rarz. )
( * ANSI and puppet additions by Moose/Van
  * Added WSUMMON by Moose/Van
  A program to get you and another person to the same location.
  Properties on yourself:
   _meetme/succ:  Message given when you move.
   _meetme/osucc: Message given when you move.
   _meetme/odrop: Message given when you move.
   _meetme/usex?:yes  -- Use x-msgs set on other if available.
   _meetme/xsucc: \  Messages given when other moves if they
   _meetme/xosucc: > are set _meetme/usex?:yes ..
   _meetme/xodrop:/
  The above are MPI parsed with {&how} set to the dbref of the
  other party.
)
$author Squirrelly, Rarz, Moose
$version 2.01
$include $lib/puppet
$include $lib/strings
$def Puppet? dup Thing? over "PUPPET" Flag? rot "LISTENER" Flag? or and
$def .atodbrf "" "#" subst atoi dbref
$def .quote "\"" swap strcat "\"" strcat
$def TIMEOUT 300
$define GUEST? ( d -- i )
   dup Player? swap "GUEST" Flag? and
$enddef
$def .atell me @ swap ansi_notify
lvar REQUESTER
lvar REQUESTED
lvar TARGET
lvar WHAT
: helpmsg ( -- )
 "^CINFO^MeetMe.muf by Squirrelly 1/22/95" .atell
 "  ^CYAN^Usage:  ^NORMAL^Mjoin <name>    ^WHITE^-- Request to go to their location." .atell
 "          Msummon <name>  ^WHITE^-- Request they come to your location." .atell
 "          Meet <name>     ^WHITE^-- Request to meet, location their choice." .atell
 "          Mcancel <name>  ^WHITE^-- To cancel a request you made." .atell
 "          Mdecline <name> ^WHITE^-- Turn down a request to meet." .atell
 "          Mcancel <name>  ^WHITE^-- To cancel a request you made." .atell
 "          Meet #ignore [[!]<name>] ^WHITE^-- Set/display MeetMe ignore list." .atell
 "          Meet <#on|#off> ^WHITE^-- Enable and disable MeetMe requests." .atell
 me @ "WIZARD" Flag? IF
 "          Wsummon <name>  ^WHITE^-- WIZ ONLY: Tug a player to your location." .atell
 THEN
 "  ^CINFO^Requests to meet expire after 5 minutes." .atell
;
: givemsgs ( s -- )
WHAT !
"^CINFO^MEETME: " REQUESTER @ name strcat " would like " strcat
WHAT @ "s" strcmp not if "you to join them" then
WHAT @ "j" strcmp not if "to join you" then
WHAT @ "m" strcmp not if "to meet with you" then
strcat ". Please respond with" strcat
REQUESTED @ swap ansi_notify
"^CINFO^MEETME: \""
WHAT @ "j" strcmp if "mjoin " else "msummon " then
strcat REQUESTER @ name strcat "\" or \"" strcat
WHAT @ "m" strcmp if "meet " else "msummon " then
strcat REQUESTER @ name strcat "\" to " strcat
WHAT @ "s" strcmp not if "go to their location," then
WHAT @ "j" strcmp not if "bring them here," then
WHAT @ "m" strcmp not if "meet with them," then
strcat REQUESTED @ swap ansi_notify
"^CINFO^MEETME: or \"mdecline " REQUESTER @ name strcat
"\" turn down the request." strcat
REQUESTED @ swap ansi_notify
;
: getmsg ( d2 d1 s i -- s )
-4 rotate
"_meetme/" swap strcat rot intostr "#" swap strcat 4 rotate
parseprop
;
: sendoff ( d1 d2 -- ) ( d1 moving to d2 )
dup "@meet/" 4 pick intostr strcat remove_prop
over "@meet/" 3 pick intostr strcat remove_prop
over over swap "usex?" 1 getmsg
"yes" strcmp not rot rot
3 pick if over over "xsucc" 1 getmsg else "" then
dup not if pop over over swap "succ" 1 getmsg then
dup if 3 pick swap notify else pop then
3 pick if over over "xosucc" 0 getmsg else "" then
dup not if pop over over swap "osucc" 0 getmsg then
dup if
  dup tolower "'s " 3 strncmp if " " swap strcat then
  3 pick name swap strcat
  3 pick dup location swap 1 4 rotate notify_exclude
else
  pop
then
3 pick if over over "xodrop" 0 getmsg else "" then
dup not if pop over over swap "odrop" 0 getmsg then
dup if
  dup tolower "'s " 3 strncmp if " " swap strcat then
  3 pick name swap strcat
over location 0 rot notify_exclude
else
  pop
then
rot pop
location moveto
;
: bugok? ( d1 d2 -- i )
    ( d1 requester, d2 requested, i 1=ok, 0=no )
  dup "_meet/off?" getpropstr
  "yes" strcmp not if pop pop 0 exit then
  "@meet/ignore" getpropstr " " swap strcat " " strcat
  swap intostr " " swap strcat " " strcat instr not
;
: main
   dup VAR! strargs
COMMAND @ "{join|summon|decline|cancel}" smatch if
  "^CFAIL^MEETME:  Sorry, this command has been changed to 'm"
  COMMAND @ tolower strcat "'." strcat .atell
  pop exit
then
COMMAND @ "wsummon" stringcmp not not IF
   COMMAND @ "{mjoin|msummon|mdecline|mcancel}" smatch if
     COMMAND @ 1 strcut COMMAND ! pop
   then
   dup if dup "{#join|#summon|#decline|#cancel}*" smatch if
     " " .split swap 1 strcut COMMAND ! pop
   then then
THEN
dup tolower "#help" strcmp over and not if
  pop helpmsg exit
then
ME @ GUEST? if
  "^CFAIL^MEETME:  Sorry, Guests are restricted from using this program."
  .atell pop exit
then
dup tolower "#ignore" 7 strncmp not if
  " " .split swap pop
  ME @ "@meet/ignore" getpropstr
  " " swap strcat " " strcat swap
  begin
    dup while
    " " .split swap
    dup "!" 1 strncmp
    if 0 swap else 1 strcut swap pop 1 swap then
    dup not if pop pop continue then
    dup pmatch
    dup ok? if
      intostr swap pop swap if
        " " swap strcat " " strcat
        rot " " rot subst swap
      else
        " " over strcat " " strcat
        4 rotate " " rot subst
        swap strcat " " strcat swap
      then
    else
      pop "^CFAIL^MEETME:  Could not find player "
      swap .quote strcat "." strcat .atell
      pop
    then
  repeat
  pop strip
  ME @ over "@meet/ignore" swap setprop
  "" swap
  begin
    dup while
    " " .split swap .atodbrf
    dup player? if name " " strcat else pop "[?] " then
    rot swap strcat swap
  repeat
  pop strip dup not if pop "*no one*" then
  "^CINFO^MEETME:  Ignore list: ^NORMAL^" swap strcat .atell
  exit
then
dup tolower "#off" strcmp not if
  ME @ "_meet/off?" "yes" setprop
  "^CSUCC^MEETME:  Requests disabled (off)." .atell
  pop exit
then
dup tolower "#on" strcmp not if
  ME @ "_meet/off?" remove_prop
  "^CSUCC^MEETME:  Requests enabled (on)." .atell
  pop exit
then
COMMAND @ "wsummon" stringcmp not not IF
COMMAND @ "{join|summon|meet|decline|cancel}" smatch not if
  "^CFAIL^MEETME:  " COMMAND @ strcat ": invalid command." strcat
  .atell
  pop exit
then
THEN
ME @ dup player? swap Puppet? or not if
  "^CFAIL^MEETME:  Sorry, players would be unable to respond to a"
  " non-player/puppet request." strcat .atell
  pop exit
then
dup pmatch dup #-1 dbcmp if pop puppet_match else swap pop then
dup ok? not if
  "^CFAIL^MEETME:  Could not find a player by that name." .atell
  pop exit
then
TARGET !
(
join summon meet decline cancel
@meet/<ref>:<j|s|m><expire time>
MEETME:  Someone would like you to join them. ...
MEETME:  Someone would like to join you. ...
MEETME:  Someone would like to meet with you.  Please respond with
MEETME:  "join Someone" or "meet Someone" to go to their location,
MEETME:  or "decline Someone" turn down the request.
)
COMMAND @ "ws" instr 1 = IF
   me @ "WIZARD" Flag? not IF
      me @ "^CFAIL^MEETME:  Permission denied for Wsummon." ansi_notify exit
   THEN
   STRargs @ strip dup IF
      pmatch dup #-2 dbcmp IF
         me @ "^CINFO^MEETME:  I don't know which one you mean!" ansi_notify exit
      THEN
      dup not IF
         me @ "^CINFO^MEETME:  I cannot find that player." ansi_notify exit
      THEN
      dup ME @ dbcmp if
         "^CFAIL^Gee, talk about split personalities!" .atell
         exit
      then
      dup me @ location moveto
      dup "^CMOVE^MEETME:  You have been summoned by the wizard, "
      me @ name 1 escape_ansi strcat "." strcat ansi_notify
      me @ "^CMOVE^MEETME:  You summoned " 3 pick name 1 escape_ansi
      strcat " to your location with wsummon." strcat ansi_notify
   THEN
   EXIT
THEN
COMMAND @ 1 strcut pop tolower COMMAND !
TARGET @ "@meet/" ME @ intostr strcat getpropstr
dup if
  dup 1 strcut swap pop atoi systime < if
    TARGET @ "@meet/" ME @ intostr strcat remove_prop
    pop ""
  then
then
COMMAND @ "d" strcmp not if
  if
    TARGET @ "@meet/" ME @ intostr strcat remove_prop
    "^CFAIL^MEETME:  " ME @ name strcat " has decline to meet you."
    strcat TARGET @ swap ansi_notify
    "^CSUCC^MEETME:  Request declined." .atell
  else
    "^CFAIL^MEETME:  There is no current request to meet from "
    TARGET @ name strcat "." strcat .atell
  then
  exit
then
dup COMMAND @ "c" strcmp and if
  TARGET @ REQUESTER ! ME @ REQUESTED !
  dup "j" 1 strncmp COMMAND @ "j" strcmp or not if
    pop "^CFAIL^MEETME:  Sorry, " REQUESTER @ name strcat
    " has requested to join you." strcat .atell
    "j" givemsgs exit
  then
  dup "s" 1 strncmp COMMAND @ "s" strcmp or not if
    pop "^CFAIL^MEETME:  Sorry, " REQUESTER @ name strcat
    " has requested you to go there." strcat .atell
    "s" givemsgs exit
  then
  dup "m" 1 strncmp COMMAND @ "m" strcmp or not if
    "^CFAIL^MEETME:  Sorry, " REQUESTER @ name strcat
    " wishes you to choose the location." strcat .atell
    "m" givemsgs exit
  then
  "s" 1 strncmp COMMAND @ "j" strcmp and if
    TARGET @ ME @ sendoff
  else
    ME @ TARGET @ sendoff
  then
  exit
then
pop
ME @ "@meet/" TARGET @ intostr strcat getpropstr
dup if
  dup 1 strcut swap pop atoi systime < if
    ME @ "@meet/" TARGET @ intostr strcat remove_prop
    pop ""
  then
then
COMMAND @ "c" strcmp not if
  if
    ME @ "@meet/" TARGET @ intostr strcat remove_prop
"^CNOTE^MEETME:  Request has been canceled by " ME @ name strcat
    "." strcat TARGET @ swap ansi_notify
    "^CSUCC^MEETME:  Request canceled." .atell
  else
    "^CFAIL^MEETME:  You have no current request to meet "
    TARGET @ name strcat "." strcat .atell
 then
 exit
then
ME @ REQUESTER ! TARGET @ REQUESTED !
TARGET @ Guest? if
  "^CFAIL^MEETME:  Sorry, " TARGET @ name strcat
  " is a guest and unable to use this program." strcat .atell
  exit
then
ME @ TARGET @ bugok? not if
  "^CFAIL^MEETME:  Sorry, " TARGET @ name strcat
  " does not wish to be disturbed." strcat .atell
  exit
then
if
  "^CFAIL^MEETME:  Sorry, you already have a request to "
  REQUESTED @ name strcat "." strcat .atell
  "^CFAIL^MEETME:  You will have to 'cancel' it if you wish to make"
  " a new one." strcat .atell
  exit
then
TARGET @ ME @ dbcmp if
  "^CFAIL^Gee, talk about split personalities!" .atell
  exit
then
TARGET @ location ME @ location dbcmp if
  "^CFAIL^MEETME:  That person is already here." .atell
  exit
then
TARGET @ awake? not if
  "^CFAIL^MEETME:  " TARGET @ name strcat " is currently asleep."
  strcat .atell
  exit
then
ME @ "@meet/" TARGET @ intostr strcat
COMMAND @ systime TIMEOUT + intostr strcat setprop
COMMAND @ givemsgs
"^CSUCC^MEETME:  Request sent." .atell
;
