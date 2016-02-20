$undef ignoring?
( MUFpage    Copyright 4/15/91 by Garth Minette                  )
(                                 foxen@netcom.com               )
(                                                                )
( Ruffin changes are marked for 2.40x1 and up                    )
( Reworked by Syvel @ Sociopolitical Ramifications to be more    )
( like MUFpage 2.51, and maintain compatibility with SPR's 2.53  )
$include $lib/strings
$include $lib/reflist
$include $lib/lmgr
$include $lib/editor
$include $lib/props
$def descr_idle descrcon conidle
$def GLOWMUCK 1
(-----Begin Raven's addition for GlowMUCK colors!-----)
( Quick ANSI support version 1.01 by Raven Jan 1999   )
( --------------------------------------------------- )
( To install paste this text into the header of your  )
( program and make the following adjustments.         )
( -Add a function to allow users to set their color   )
(  preference. <command> #color <color> for example.  )
( UPDATE: I *do* have a version that will work with   )
(     Caspian's Lib-ANSI-free libraries. It is        )
(     called quickansi-4ansilib.muf and is available  )
(     via FTP from my MUF distribution site!          )
(     http://users.vnet.net/raven3/homepage.html      )
( --------------------------------------------------  )
( This code is freely portable so long as you retain  )
( these message headers! I MEAN IT! THANKS! :> -Raven )
(  Please E-mail bugreports to raven3@vnet.net        )
( ------------------Set ifdef flags------------------ )
$define ravensglowcolor 1 $enddef ([optional])
$define ravensansicolor 1 $enddef ([optional])
 
( Use one or the other blow...  *=default             )
( *Uncomment the following to use the prefered color. )
( Comment out the following to use the pref-prop.     )
 
$def usecolorprefprop 1
 
( -----Define property to get prefered color from---- )
$ifdef usecolorprefprop
   $def color-prefprop "_page/color"
$else
   $def preferedcolor "^white^"
$endif
( -------------Define available colors--------------- )
$def color-yellow  "^yellow^"
$def color-white   "^white^"
$def color-black   "^black^"  (black or invisible)
$def color-green   "^green^"
$def color-blue    "^blue^"
$def color-red     "^red^"
$def color-purple  "^purple^" (Why this? 500 different)
$def color-violet  "^purple^" (names for this color   )
$def color-magenta "^purple^" (thats why :>           )
$def color-cyan    "^cyan^"
$def color-normal  "^normal^" (reset color)
( --This is the default color if you want to set it-- )
$def use_default_color color-normal
( -------Replace .tell with do_color.tell------------ )
$def .tell do_color.tell
( --------Replace NOTIFY with do_color_notify-------- )
$def notify do_color_notify
( -------------Begin word definitions-----------------)
: do_getpreferedcolor ( d -- s )
  $ifdef usecolorprefprop
    color-prefprop getpropstr tolower
    dup "yellow" stringcmp not if
      pop color-yellow exit
    then
    dup "white" stringcmp not if
      pop color-white exit
    then
    dup "black" stringcmp not if
      pop color-black exit
    then
    dup "green" stringcmp not if
      pop color-green exit
    then
    dup "blue" stringcmp not if
      pop color-blue exit
    then
    dup "red" stringcmp not if
      pop color-red exit
    then
    dup "purple" stringcmp not if
      pop color-purple exit
    then
    dup "violet" stringcmp not if
      pop color-violet exit
    then
    dup "magenta" stringcmp not if
      pop color-magenta exit
    then
    dup "cyan" stringcmp not if
      pop color-cyan exit
    then
    dup "normal" stringcmp not if
      pop color-normal exit
    then
    dup "none" stringcmp not if
      pop color-normal exit
    then
    pop use_default_color exit
  $else
    pop preferedcolor
  $endif
;
: do_color_notify ( d s -- )
  "^^" "^" subst (*Keep things 'clean' subst out ^color^ in params)
  swap dup do_getpreferedcolor rot strcat
  color-normal strcat ansi_notify
;
: do_color.tell ( s -- )
  me @ swap do_color_notify
;
(------END Raven's addition for GlowMUCK colors!------)
var str
: oproploc ( dbref -- dbref' )
    dup "_proploc" getpropstr
    dup if
        dup "#" 1 strncmp not if
            1 strcut swap pop
        then
        atoi dbref
        dup ok? if
            dup owner 3 pick
            dbcmp if swap then
        else swap
        then pop
    else pop
    then
;
: myproploc ( -- dbref)
    me @ oproploc
;
$define tell me @ swap notify $enddef
$define split .split $enddef
: fillspace
    swap strlen -
    "                                        " ( 40 spaces )
    dup strcat ( 80 spaces now )
    swap strcut pop
;
$define strip-leadspaces striplead $enddef
$define strip-trailspaces striptail $enddef
$define stripspaces strip $enddef
: compare stringcmp 0 > ;
($def sort 'compare .sort )
: sort-stringwords ( str -- str' )
  stripspaces
  dup " " instr if
    " " explode 2 sort
    begin
      dup 1 > while
      1 - swap " " strcat rot strcat swap
    repeat pop
    stripspaces
  then
;
: fake_format? (default string -- string' TRUE )
               (            or -- default FALSE )
    "%n" me @ name subst
    dup "%n" instr not if
        "%n " swap strcat
    then
    dup "%t" instr not if
        " (to %t)" strcat
    then
    dup  "%n whispers, \"%m\"" stringcmp not
    over "%n whispers \"%m\"" stringcmp not or
    over "%n shouts, \"%m\"" stringcmp not or
    over "%n shouts \"%m\"" stringcmp not or
    over "%n %m" stringcmp not or if
        pop 0
    else
        swap pop 1
    then
;
( *** routines to get and set properties *** )
: search-prop (propname -- str)
    myproploc over getpropstr
    dup not if
        me @ location
        rot envprop
    then
    swap pop
;
: getprop (playerdbref propname -- str)
    over oproploc over \getpropstr
    dup not if
        pop swap over \envprop swap pop
        dup not if
            pop trigger @ swap \getpropstr
        else swap pop
        then
    else rot rot pop pop
    then
;
( ------------Added by Raven for Color support! ------------ )
: goodcolor? ( s -- i )
    tolower
    dup "yellow" stringcmp not if pop 1 exit then
    dup "white" stringcmp not if pop 1 exit then
    dup "black" stringcmp not if pop 1 exit then
    dup "green" stringcmp not if pop 1 exit then
    dup "blue" stringcmp not if pop 1 exit then
    dup "red" stringcmp not if pop 1 exit then
    dup "cyan" stringcmp not if pop 1 exit then
    dup "magenta" stringcmp not if pop 1 exit then
    dup "violet" stringcmp not if pop 1 exit then
    dup "purple" stringcmp not if pop 1 exit then
    dup "none" stringcmp not if pop 1 exit then
    dup "normal" stringcmp not if pop 1 exit then
    pop 0
;
: showavailcolors
 me @
  "-------Available Colors-------\r"
  color-yellow "YELLOW" strcat color-normal strcat  "   " strcat strcat
  color-white "WHITE" strcat color-normal strcat  "   " strcat strcat
  color-black "BLACK" strcat color-normal strcat  "   " strcat strcat
  color-green "GREEN" strcat color-normal strcat  "   " strcat strcat
  color-blue "BLUE" strcat color-normal strcat  "   " strcat strcat
  color-red "RED" strcat color-normal strcat  "   " strcat strcat
  color-cyan "CYAN" strcat color-normal strcat  "\r" strcat strcat
  color-purple "MAGENTA (violet and purple are the same)" strcat color-normal strcat  "\r" strcat strcat
  color-normal "NONE (No color [default])" strcat color-normal strcat  "\r" strcat strcat
  me @ do_getpreferedcolor "-------\r" strcat strcat color-normal strcat
  "Usage: Page #color <color> -- Sets pages to appear in <color>.\r" strcat
  "       Page #color #clear  -- Sets pages to no colors.\r" strcat
  "       Page #color none    -- Same as #clear.\r" strcat
  me @ do_getpreferedcolor "You are currently using this color." strcat strcat color-normal strcat
 ansi_notify
;
: tell-bad-color
  "Page: MUST be a proper color!" .tell
  showavailcolors
;
( --------END addition for color support by Raven----------- )
 
( *** BEGIN PERSONAL PROPS *** )
: getignorestr (playerdbref -- ignorestr)
    oproploc "_page/@ignore" getprop
;
: setignorestr (ignorestr playerdbref -- )
    oproploc "_page/@ignore" rot setpropstr
;
: getprioritystr (playerdbref -- prioritystr)
    oproploc "_page/@priority" getprop
;
: setprioritystr (prioritystr playerdbref -- )
    oproploc "_page/@priority" rot setpropstr
;
: getlastpager (playerdbref -- string)
    oproploc "_page/@lastpager" getprop
;
: setlastpager (string playerdbref -- )
    oproploc "_page/@lastpager" rot setpropstr
;
: getlastpagers (playerdbref -- string)
    oproploc "_page/@lastpagers" getprop
;
: setlastpagers (string playerdbref -- )
    oproploc "_page/@lastpagers" rot setpropstr
;
: getlastpaged (playerdbref -- string)
    oproploc "_page/@lastpaged" getprop
;
: setlastpaged (string playerdbref -- )
    oproploc "_page/@lastpaged" rot setpropstr
;
: getlastpagedgroup (playerdbref -- string)
    oproploc "_page/@lastpagedgroup" getprop
;
: setlastpagedgroup (string playerdbref -- )
    oproploc "_page/@lastpagedgroup" rot setpropstr
;
: set_page_standard (valstr -- )
    myproploc "_page/standard?" rot setpropstr
;
: page_standard? (playerdbref -- bool)
    oproploc "_page/standard?" getpropstr
    dup "yes" stringcmp not if pop 2 exit then
    "prepend" stringcmp not if 1 exit then
    0
;
: set_page_echo (valstr -- )
    myproploc "_page/echo?" rot setpropstr
;
: page_echo? ( -- bool)
    myproploc "_page/echo?" getpropstr
    "no" stringcmp not not
;
: set_page_inform (valstr -- )
    myproploc "_page/inform?" rot setpropstr
;
: page_inform? (playerdbref -- bool)
    oproploc "_page/inform?" getpropstr
    "yes" stringcmp not
;
: get-curr-format ( -- formatname )
    myproploc "_page/curr_format" getpropstr
    dup not if pop "page" then
;
: set-curr-format ( formatname -- )
    myproploc "_page/curr_format" rot setpropstr
;
: set-format-prop ( playerdbref formatname format -- )
    rot oproploc rot "_page/formats/" swap strcat rot setpropstr
;
: get-format-prop ( playerdbref formatname -- format )
    "_page/formats/" swap strcat over swap getprop
    dup not if pop "_page/formats/page" getprop else swap pop then
    dup not if pop "You page, \"%m\" to %n." then
;
: set-oformat-prop ( playerdbref formatname format -- )
    rot oproploc rot "_page/formats/o" swap strcat rot setpropstr
;
: get-oformat-prop ( playerdbref formatname -- format )
    "_page/formats/o" swap strcat over swap getprop
    dup not if pop "_page/formats/opage" getprop else swap pop then
    "%n pages, \"%m\" to %t." swap dup if fake_format? then pop
;
: get_opose ( -- oposeformat)
    myproploc "_page/formats/opose" over swap getprop
    dup not if pop "_page/formats/opage" getprop else swap pop then
    "In a page-pose to %t, %n %m" swap dup if fake_format? then pop
;
: set-standard (stdformat playerdbref -- )
    oproploc "_page/stdf" rot setpropstr
;
: get-standard (playerdbref -- stdformat)
    oproploc "_page/stdf" getpropstr
    dup not if pop "%n pages: %m <to %t>"
      trigger @ "_page/stdf" getpropstr dup if swap then
      pop
    then
    "<loc>" "%l" subst
;
: set-prepend (prepformat playerdbref -- )
    oproploc "_page/prepf" rot setpropstr
;
: get-prepend (playerdbref -- prepformat)
    oproploc "_page/prepf" getpropstr
    dup not if pop "%n pages: "
      trigger @ "_page/prepf" getpropstr dup if swap then
      pop
    then
    "<loc>" "%l" subst
;
: get-forward (playerdbref -- string)
    oproploc "_page/forward" getpropstr
;
: set-forward (string -- )
    myproploc "_page/forward" rot setpropstr
;
: mail-count (playerdbref -- count)
    oproploc "_page/@mail#" getpropstr atoi
;
: mail-get   (playerdbref -- message)
  ( replaced by *Tyro to work with the new mail-read routine )
    oproploc dup "_page/@mail#/1" getpropstr dup not
      if pop dup "_page/@mail1" getpropstr then
    1 1 "_page/@mail" 5 rotate lmgr-deleterange
;
: mail-add   (playerdbref message -- )
    over mail-count 1 + intostr
    3 pick oproploc "_page/@mail#" 3 pick setpropstr
    rot oproploc "_page/@mail#/" rot strcat rot setpropstr
;
: mail-erase ( playerdbref -- erased? )
  ( re-written by *Tyro to fix a bug in mail-erase )
  dup oproploc swap mail-count
  begin
    dup while
    dup "_page/@mail" 4 pick LMGR-getelem
    " " split pop 1 strcut swap pop atoi dbref
    me @ dbcmp not
      if 1 - continue
      else 1 over "_page/@mail" 5 rotate LMGR-deleterange exit
      then
  repeat swap pop
;
: get-lastversion ( -- versionstr)
    myproploc "_page/lastversion" getpropstr
;
: set-lastversion (versionstr -- )
    myproploc "_page/lastversion" rot setpropstr
;
: get-multimax (playerdbref -- int)
    oproploc "_page/multimax" getpropstr
    atoi dup not if pop 8888 then
;
: set-multimax (int playerdbref -- )
    oproploc "_page/multimax"
    rot intostr setpropstr
;
: get-sleepmsg (dbref -- string)
    oproploc "_page/sleepmsg" getpropstr
;
: set-sleepmsg (string dbref -- )
    oproploc "_page/sleepmsg" rot setpropstr
;
( ------------Added by Raven for Color support! ------------ )
: set-color (string dbref -- )
    oproploc "_page/color" rot tolower setpropstr
;
( --------END addition for color support by Raven----------- )
: get-havenmsg (dbref -- string)
    oproploc "_page/havenmsg" getpropstr
;
: set-havenmsg (string dbref -- )
    oproploc "_page/havenmsg" rot setpropstr
;
: get-idlemsg (dbref -- string)   (*Ruffin)
    oproploc "_page/idlemsg" getpropstr
;
: set-idlemsg (string dbref -- )  (*Ruffin)
    oproploc "_page/idlemsg" rot setpropstr
;
: get-showwho (dbref -- string)   (*Ruffin)
    oproploc "_page/showwho" getpropstr
;
: set-showwho (string dbref -- )  (*Ruffin)
    oproploc "_page/showwho" rot setpropstr
;
: get-ignoremsg (dbref -- string)
    oproploc "_page/ignoremsg" getpropstr
;
: set-ignoremsg (string dbref -- )
    oproploc "_page/ignoremsg" rot setpropstr
;
: get-awaymsg (dbref -- string)
    oproploc "_page/awaymsg" getpropstr
;
 
: set-awaymsg (string dbref -- )
    oproploc "_page/awaymsg" rot setpropstr
;
: get-idletime (dbref -- int)
    oproploc "_page/idletime" getpropval
    dup not if pop 600 then
;
 
: set-idletime (int dbref -- )
    oproploc "_page/idletime" rot setprop
;
 
( change proploc )
: move-prop (dbref newdbref str -- )
    3 pick over getpropstr
    4 rotate 3 pick remove_prop
    setpropstr
;
: do-proplock-set (str -- )
    stripspaces match dup not if
        "page #proploc: I don't know what object you mean!"
        tell pop exit
    then dup #-2 dbcmp if
        "page #proploc: I don't know _which_ object you mean!"
        tell pop exit
    then dup owner me @ dbcmp not if
        "page #proploc: You don't own that object!"
        tell pop exit
    then dup myproploc dbcmp if
        "page #proploc: You already have that set as your proploc."
        tell pop exit
    then myproploc swap
    dup int intostr me @ "_proploc" rot setpropstr
    over over "_page/@lastpager"      move-prop
    over over "_page/@lastpagers"     move-prop
    over over "_page/@lastpaged"      move-prop
    over over "_page/@lastpagedgroup" move-prop
    over over "_page/@priority"       move-prop
    over over "_page/@ignore"         move-prop
    over over "_page/standard?"       move-prop
    over over "_page/echo?"           move-prop
    over over "_page/inform?"         move-prop
    over over "_page/curr_format"     move-prop
    over over "_page/formats/page"    move-prop
    over over "_page/formats/opage"   move-prop
    over over "_page/lastversion"     move-prop
    over over "_page/prepf"           move-prop
    over over "_page/stdf"            move-prop
    over over "_page/away"            move-prop
    over over "_page/forward"         move-prop
    over over "_page/sleepmsg"        move-prop
    over over "_page/havenmsg"        move-prop
    over over "_page/multimax"        move-prop
    over over "_page/ignoremsg"       move-prop
    over over "_page/idlemsg" move-prop (*Ruffin)
    over over "_page/showwho" move-prop (*Ruffin)
    over "_page/@mail#" getpropstr atoi
    3 pick "_page/@mail#/" begin
      3 pick while
      dup 4 pick intostr strcat
      6 pick 6 pick rot               move-prop
      rot 1 - -3 rotate
    repeat pop pop pop
    over over "_page/@mail#"          move-prop
    over "_page/@omail#" getpropstr atoi
    3 pick "_page/@omail#/" begin
      3 pick while
      dup 4 pick intostr strcat
      6 pick 6 pick rot               move-prop
      rot 1 - -3 rotate
    repeat pop pop pop
    over over "_page/@omail#"         move-prop
    over "_page/formats/" begin
      over swap nextprop dup while
      4 pick 4 pick rot               move-prop
      "_page/formats/"
    repeat pop pop
    over "_page/alias/" begin
      over swap nextprop dup while
      4 pick 4 pick rot               move-prop
      "_page/alias/"
    repeat pop pop
    "Properties now stored on \""
    over unparseobj strcat "\"" strcat tell
    me @ dbcmp if me @ "_proploc" remove_prop then
    pop
;
( *** END PERSONAL PROPS *** )
: set-personal-alias (aliasname aliasstr -- )
    swap tolower dup strlen
    10 > if 10 strcut pop then
    over if
        "Personal alias set." tell
    else
        "Personal alias cleared." tell
    then
    stripspaces myproploc "_page/alias/"
    rot strcat rot setpropstr
;
: get-personal-alias (aliasname playerdbref -- aliasstr)
    oproploc "_page/alias/" rot strcat getpropstr
;
: get-global-alias (aliasname -- aliasstr)
    prog "_page/alias/"
    rot strcat getpropstr
;
: set-global-alias (aliasname aliasstr -- )
    over get-global-alias
    me @ "w" flag? not and
    me @ prog owner dbcmp not and
    "_page/alias/" 4 pick strcat "/own" strcat
    prog swap getpropstr
    me @ int intostr stringcmp and if
        "Permission denied." tell
        pop pop exit
    then
    (aliasname aliasstr)
    dup not if
        "_page/alias/" 3 pick strcat "/own" strcat
        prog swap remove_prop
    then
    (aliasname aliasstr)
    swap tolower dup strlen
    10 > if 10 strcut pop then
    swap
    over if
        ( Line #888 in pre-cpp source )
        "Global alias set." tell
    else
        "Global alias cleared." tell
    then
    stripspaces
    "_page/alias/" 3 pick strcat "/own" strcat
    prog swap me @ intostr setpropstr
    "_page/alias/" rot strcat
    prog swap rot setpropstr
;
: get-alias (aliasname playerdbref -- aliasstr)
    over swap get-personal-alias
    dup not if
        pop get-global-alias
    else swap pop
    then
;
( *** END PROPS ON PROG *** )
: getday ( -- int)
    systime dup 86400 % 86400 + time 60 * + 60 * + - 86400 % - 86400 /
;
: setday ( int -- )
    #0 "day" "" 4 pick addprop
    prog "day" rot "" swap addprop
;
: gettime ( -- int )
    time 60 * + 60 * +
;
: get-timestr ( -- timestr)
    time rot pop ":"
    rot dup intostr
    swap 10 < if "0" swap strcat then
    strcat over 11 > if
        "pm" strcat swap 12 - swap
    else
        "am" strcat
    then
    swap dup not if pop 12 then
    intostr swap strcat
;
( *** end of routines for getting and setting properties *** )
( alias listing stuff )
: list-personal-aliases ( - )
    "  Personal Aliases List" tell
    "Alias Name -- Alias Expansion" tell
    "----------    --------------------------------------------------" tell
    myproploc "_page/alias/" begin
      over swap nextprop dup while
      over over getpropstr
      " -- " swap strcat
      over "" "_page/alias/" subst swap
      swap dup 10 fillspace strcat swap strcat tell
    repeat pop pop
;
: list-global-aliases ( - )
    "   Global Aliases List" tell
    "Alias Name -- Alias Expansion" tell
    "----------    --------------------------------------------------" tell
    prog "_page/alias/" begin
      over swap nextprop dup while
      over over getpropstr
      " -- " swap strcat
      over "" "_page/alias/" subst swap
      swap dup 10 fillspace strcat swap strcat tell
    repeat pop pop
;
: list-matching-aliases (namestr -- )
  "Aliases containing the name \"" over strcat "\"" strcat tell
  "Alias Name -- Alias Expansion" tell
  "----------    --------------------------------------------------" tell
    myproploc "_page/alias/" begin
      over swap nextprop dup while
      over over getpropstr
      dup 5 pick instring if
        over "" "_page/alias/" subst dup 10 fillspace strcat
        " -- " strcat swap strcat .tell
      else pop then
    repeat pop pop
  prog "_page/alias/" begin
    over swap nextprop dup while
    over over getpropstr
    dup 5 pick instring if
      over "" "_page/alias/" subst dup 10 fillspace strcat
      " -- " strcat swap strcat tell
      else pop then
  repeat pop pop
;
( misc simple routines )
: single-space (s -- s') (strips all multiple spaces down to a single space)
  begin
    dup "  " instr while
    " " "  " subst
  repeat
;
: comma-format (string -- formattedstring)
    stripspaces single-space
    ", " " " subst
    dup ", " rinstr dup if
        1 - strcut 2 strcut
        swap pop " and "
        swap strcat strcat
    else pop
    then
;
: popn (dbrefrange -- )
    begin
      dup while
      1 -
    repeat pop
;
: stringmatch? (str cmpstr #charsmin-- bool)
    rot " " split pop rot rot
    swap over strcut swap
    4 rotate 4 rotate strcut rot rot
    stringcmp if pop pop 0 exit then
    swap over strlen strcut pop
    stringcmp not
;
( simple player matching )
: player-match? (playername -- [dbref] succ?)
    .pmatch dup if 1 else pop 0 then
;
: partial-match-loop (dbrefrange playername dbref -- dbref)
    3 pick not if swap pop swap pop exit then
    3 pick 3 + rotate
    dup name
    (dbrefrange playername matched dbref name)
    4 pick strlen strcut pop
    4 pick stringcmp not if
        over over dbcmp
        3 pick not or if swap pop
        else pop pop #-2
        then
    else pop
    then
    rot 1 - rot rot
    partial-match-loop
;
: partial-match ( playername -- [dbref] succ? )
    online dup 2 + rotate #-1 partial-match-loop
    dup int 0 > if 1 else pop 0 then
;
: cull-loop (strings count nullstr -- string')
    over not if swap pop exit then
    over 6 > if rot pop swap 1 - swap cull-loop exit then
    rot dup if " " strcat strcat else pop then
    swap 1 - swap cull-loop
;
: cullto5words (string -- string')
    single-space stripspaces
    " " explode "" cull-loop
;
: match-lastpagers (partname playerdbref -- [dbref] success?)
    over strlen 3 < if pop pop 0 exit then
    getlastpagers stripspaces
    " " swap strcat dup tolower
    " " 4 rotate strcat tolower instr
    dup not if pop pop 0 exit then
    strcut swap pop " " split pop
    player-match?
;
: update-lastpagers (fullname playerdbref -- )
    dup getlastpagers stripspaces
    " " swap over strcat strcat
    " " 4 rotate over strcat strcat
    over tolower over tolower instr not if
        1 strcut swap pop strcat
        cullto5words swap setlastpagers
    else
        pop pop pop
    then
;
( remember stuff )
: extract-player ( playername string -- string' )
  single-space " " explode dup 2 + rotate "" swap
  begin
    3 pick while
    4 rotate dup if
        over over stringcmp not if pop
        else
            rot dup if " " strcat then
            swap strcat swap
        then
    else pop
    then
    rot 1 - rot rot
  repeat pop swap pop
;
: remember-pager (playerdbref -- )
    me @ name over setlastpager
    me @ name over update-lastpagers
    me @ getlastpaged
    over name swap extract-player
    swap setlastpagedgroup
;
: remember-pagee (player[s] -- player[s])
    dup not if        (is a player specified?)
        pop me @      (if not, use last player paged...)
        getlastpaged
    else
        single-space  (...otherwise, use the player given...)
    then
;
( ignore stuff )
: ignored?       (playerdbref -- ignored?)
    oproploc "_page/@ignore" me @ REF-inlist?
;
: ignoring?       (playerdbref -- ignored?)
    oproploc me @ "_page/@ignore" rot REF-inlist?
;
: ignore-dbref (dbref -- )
    myproploc "_page/@ignore" rot REF-add
;
: unignore-dbref (dbref -- )
    myproploc "_page/@ignore" rot REF-delete
;
: check-ignored-dbref (dbref -- player?)
    dup player? not if
        unignore-dbref 0
    else
        pop 1
    then
;
: list-ignored ( -- string)
    myproploc "_page/@ignore" REF-list
;
( priority stuff )
: priority?   (playerdbref -- priority?)
    oproploc "_page/@priority" me @ REF-inlist?
;
: priority-dbref (dbref -- )
    myproploc "_page/@priority" rot REF-add
;
: unpriority-dbref (dbref -- )
    myproploc "_page/@priority" rot REF-delete
;
: check-priority-dbref (dbref -- player?)
    dup player? not if
        unpriority-dbref 0
    else
        pop 1
    then
;
: list-priority ( -- string)
    myproploc "_page/@priority" REF-list
;
( page stuff )
: havened?  (playerdbref -- haven?)
    "haven" flag?
;
: pagepose? (string -- bool)
    dup strlen 1 > if
        2 strcut pop
        dup ":" 1 strncmp not if
          1 strcut swap pop
          " ABCDEFGHIJKLMNOPQRSTUVWXYZ,':*"
          swap instring
        else pop 0
        then
    else pop 0
    then
;
: page-me-inform (message -- )
    page_echo? if         (does sender not want to see the echo?)
        tell (if not, show constructed string to sender)
    else
        pop              (else, pop the string off the stack)
        "Your message has been sent."
        tell
    then
;
: page-them-inform (message dbref format to -- )
    3 pick name "you" swap subst -4 rotate
    over page_standard? dup 1 = if
        pop over get-prepend
        over over strlen strcut pop
        stringcmp if
            over get-prepend
            " " strcat swap strcat
        then
    else
        2 = if
            get_opose over stringcmp if
                pop dup get-standard
            else
                pop dup get-standard
                "%n %m" "%m" subst
            then
        then
    then
    3 pick " " split pop
    1 strcut strlen 3 <
    over not if swap pop " " swap then
    ".,?!:' " rot instr and
    if "%n%m" "%n %m" subst then
    me @ name "%n" subst (do name substitution for %n in format string)
    me @ location
    name "%l" subst      (do location of sender sub for %l in format string)
    4 pick " " instr if (*Ruffin - multiple person page #showwho)
      dup "%t" instr not if
        over get-showwho if
          " [Sent to %t]" strcat
    then then then
    4 rotate "%t" subst  (subst in the to line for %t)
    dup "%w" instr if
        get-timestr
        "%w" subst
    then
    "%%m" "%m" subst
    "%%m" "%M" subst     (keep %m from being pronoun_subbed)
    me @ swap pronoun_sub (do pronoun subs for %o, %p, %r, %s in format str)
                          (using sender's pronoun subs)
    rot "%m" subst       (do message sub for %m in format string)
    notify               (show constructed string to receiver)
;
( mail stuff  )
: mail-unparse-mesg (mesgstr -- player time mesg)
    ( "#dbref day@hh:mm:ss Cencryptedmesg" )
    " " split swap
    dup "#" 1 strncmp not if
        1 strcut swap pop
        atoi dbref dup player? not if
          pop "(Toaded Player)"
        else name then swap
        "@" split swap
        atoi getday swap -
        dup not if
            pop "Today, "
        else dup 1 = if
            pop "Yesterday, "
            else
                intostr " days ago, " strcat
            then
        then
        swap " " split rot rot
        ":" split swap atoi
        dup 11 > if 12 - "PM" else "AM" then
        rot swap strcat swap
        dup not if pop 12 then
        intostr ":" strcat swap strcat strcat
        swap
    else
        swap 3 strcut swap pop ") -- " split
        swap ":" split swap atoi
        dup 11 > if 12 - "PM" else "AM" then
        rot swap strcat swap
        dup not if pop 12 then
        intostr ":" strcat swap strcat
        "Unknown day at " swap strcat swap
    then
;
: mail-oldlist
  myproploc "_page/@omail#" getpropstr atoi
  dup not if
    "You have no saved mail messages." tell exit
  then
  "Summary of saved mail:" tell
  1 begin
    over over >= while
    myproploc "_page/@omail#/" 3 pick intostr strcat
    getpropstr mail-unparse-mesg
    4 pick intostr " " swap strcat
    dup 5 fillspace strcat 4 rotate strcat
    dup 20 fillspace strcat rot strcat dup 52 fillspace strcat
    swap strcat
    dup "\r" instr if
      "\r" split pop
    then
    78 strcut pop tell
  1 + repeat pop pop
  "Done." tell
;
: mail-read
  ( changed into begin-repeat loop by *Tyro to avoid )
  ( mail-loss when disconnecting during mail-reading )
    begin
      me @ mail-count 0 > while
      me @ mail-get
        dup mail-unparse-mesg
        me @ " " notify
        "----" tell rot dup 20 fillspace strcat
        rot strcat tell "----" tell
        " " tell tell " " tell
        "Save this mail message? (y,n)" tell read
        1 strcut pop "y" stringcmp not if
          myproploc "_page/@omail#" over over getpropstr
          dup atoi 9 < not if
            pop pop pop pop
            "Sorry, you can only save 10 mail messages at a time." tell
          else
            atoi 1 + intostr 3 pick 3 pick 3 pick 0 addprop
            "/" swap strcat strcat rot 0 addprop
            "Message saved." tell
          then
        else
          pop "Message tossed." tell
        then
    repeat
;
: mail-nuke   ( -- )   (*Tyro)
  me @ mail-count dup
    if "Delete " over intostr " page-mail message" strcat strcat swap 1 =
      if "? (yes/no)" else "s? (yes/no)" then strcat .tell
    read strip " " strcat "{yes|y} " smatch
      if me @ oproploc "_page/@mail#" remove_prop
      "All page-mail messages nuked.  Have a nice day." .tell
      else "Aborted." .tell
      then
    else "No page-mail messages to nuke." .tell
    then
;
: mail-oldread ( mesg# -- )
  dup number? not if
    pop "Must specify a message number." tell exit
  then
  myproploc "_page/@omail#/" 3 pick strcat getpropstr
  dup not if
    pop pop "No saved mail message by that number." tell exit
  then
  "Mail message " rot strcat " of " strcat
  myproploc "_page/@omail#" getpropstr strcat ":" strcat tell
  mail-unparse-mesg
  "----" tell rot dup 20 fillspace strcat
  rot strcat tell "----" tell
  " " tell tell " " tell
;
: delete-message ( mesg# -- )
  1 swap "_page/@omail" myproploc lmgr-deleterange
;
: mail-delete-old ( mesg# -- )
  dup "#all" stringcmp not if pop
    "Are you sure you want to delete ALL your saved mail?" tell
    read .yes? if
      myproploc "_page/@omail#" over over remove_prop
      "0" 0 addprop
      "All saved mail deleted." tell
    else
      "Aborted." tell
    then exit
  then
  dup mail-oldread
  dup not if pop "0" then
  myproploc "_page/@omail#/" 3 pick strcat
  getpropstr not if pop exit then
  "Delete this saved mail message? (y,n)" tell
  read strip .yes? if
    atoi delete-message
    "Message deleted." tell
  else
    pop "Message spared." tell
  then
;
: do-editor (players -- players compiled-message)
    "Enter the subject for this letter:" tell
    read strip "Re: |\r \r" swap "|" subst
    0 EDITOR dup "abort" stringcmp not if
      pop 1 + popn "Message aborted." tell 0 exit
    then
    pop dup 2 + rotate begin
      over while
      over 2 + rotate
      dup striptail if striptail else pop " " then
      "|\r" swap "|" subst strcat
      dup "" " " subst strlen 3000 > if
        begin depth while pop repeat
        "Error: Message is too long for mail to contain." tell 0 exit
      then
      swap 1 - swap
    repeat
    swap pop 1
;
: mail-send (message player -- )
  ( dup mail-count 40 < not if )
    dup mail-count 40 < me @ "Truewiz" flag? or not if
        name "'s page-mail box is full." strcat tell pop
    else
        dup "You sense that you have new page-mail from " me @ name strcat
        ".  Use \"page #mail\" to read." strcat notify
        "#" me @ intostr strcat " " strcat
        getday intostr strcat "@" strcat
        time intostr ":" strcat
        swap dup intostr ":" strcat swap 10 < if "0" swap strcat then strcat
        swap dup intostr swap 10 < if "0" swap strcat then strcat
        strcat
        (message player string)
      ( " D" strcat over int 4 rotate crypt2 )
        " " strcat rot
        strcat mail-add
        ( "#dbref day@hh:mm:ss Cencryptedmesg" )
    then
;
: send-old-mail (message player -- )
    dup mail-count 40 < not if
        name "'s page-mail box is full." strcat tell pop
    else
        dup "You sense that you have new page-mail from " me @ name strcat
        ".  Use \"page #mail\" to read." strcat notify
        swap " " split " " split
        " (Sent from " me @ name strcat ")\r" strcat
        swap strcat strcat " " swap strcat strcat
        mail-add
    then
;
( player getting stuff )
: get-playerdbrefs  (count nullstr playersstr -- dbref_range unrecstr)
  begin
    dup while
    " " split swap
    dup "(" 1 strncmp not if
        " " strcat swap strcat
        ")" split swap pop stripspaces
        get-playerdbrefs exit
    then
    dup "#" 1 strncmp not if
        dup 1 strcut swap pop
        dup number? if
            atoi dbref dup ok? if
                dup player? if
                    swap pop 4 rotate 1 +
                    -4 rotate -4 rotate
                    get-playerdbrefs exit
                else pop
                then
            else pop
            then
        else pop
        then
    then
    dup "*" 1 strncmp not if
        1 strcut swap pop me @
        get-alias " " strcat
        swap strcat single-space
        get-playerdbrefs exit
    then
    dup player-match? dup -1 = if
        pop pop pop
        stripspaces exit
    then
    0 > if
        swap pop 4 rotate
        1 + -4 rotate -4 rotate
    else
        dup me @ get-alias dup if
            swap pop " " strcat
            swap strcat single-space
        else pop
            dup partial-match
            dup -1 = if
                pop pop pop stripspaces exit
            then if
                swap pop 4 rotate 1 +
                -4 rotate -4 rotate
            else
                "\"" swap strcat
                "\" " strcat rot
                swap strcat swap
            then
        then
    then
    repeat
    pop sort-stringwords
;
: refs2names  (dbrefrange count nullstr -- dbrefrange namestr)
  begin
    over while
    3 pick 3 + rotate dup -5 rotate
    dup "_page/name" getpropstr strip dup not
      if pop name else swap pop then
    strcat " " strcat
    swap 1 - swap
  repeat
  swap pop sort-stringwords
;
: remove-sleepers (dbrefrange count nullstr -- dbrefrange sleeperstr)
  begin
    over while
    3 pick 3 + rotate dup awake? if
        -4 rotate
    else
        dup get-sleepmsg dup if
            "Sleeping message for "
            rot name strcat ": " strcat
            swap strcat me @ swap notify
        else
            pop name " " strcat strcat
        then
        rot 1 - rot rot
    then
    swap 1 - swap
  repeat
  swap pop sort-stringwords
;
: remove-non-erasees (dbrefrange count nullstr -- dbrefrange non-erasestr)
  begin
    over while
    3 pick 3 + rotate dup mail-erase if
        -4 rotate
    else
        name " " strcat strcat
        rot 1 - rot rot
    then
    swap 1 - swap
  repeat
  swap pop sort-stringwords
;
: remove-nopagers (dbrefrange count nullstr -- dbrefrange nopagestr)
  begin
    over while
    3 pick 3 + rotate dup havened? not over priority? or if
        -4 rotate
    else
        dup page_inform? if
            dup "You sense that " me @ name strcat
            " tried to page you, but you are set havened."
            strcat notify
        then
        dup get-havenmsg dup if
            "Haven message for "
            rot name strcat ": " strcat
            swap strcat me @ swap notify
        else
            pop name " " strcat strcat
        then
        rot 1 - rot rot
    then
    swap 1 - swap
  repeat
  swap pop sort-stringwords
;
: remove-ignoring (dbrefrange count nullstr -- dbrefrange ignoringstr)
  begin
    over while
    3 pick 3 + rotate dup ignored? not if
        -4 rotate
    else
        dup page_inform? if
            dup me @ name
            " tried to page you, but you are ignoring %o."
            strcat me @ swap pronoun_sub notify
        then
        dup get-ignoremsg dup if
            "Ignore message for "
            rot name strcat ": " strcat
            swap strcat me @ swap notify
        else
            pop name " " strcat strcat
        then
        rot 1 - rot rot
    then
    swap 1 - swap
  repeat
  swap pop sort-stringwords
;
: remove-maxers (dbrefrange count count nullstr -- dbrefrange ignoringstr)
  begin
    over while
    4 pick 4 + rotate dup get-multimax 5 pick < not over priority? or if
        -5 rotate
    else
        dup page_inform? if
            dup me @ name
            " tried to include you in too large of a multi-page."
            strcat notify
        then
        name " " strcat strcat
        4 rotate 1 - -4 rotate
    then
    swap 1 - swap
  repeat
  swap pop swap pop sort-stringwords
;
: remove-nonwiz (dbrefrange count nullstr -- dbrefrange sleeperstr)
  begin
    over while
    3 pick 3 + rotate dup "wizard" flag? if
        -4 rotate
    else
        name " " strcat strcat
        rot 1 - rot rot
    then
    swap 1 - swap
  repeat
  swap pop sort-stringwords
;
: list-ignored-pagees (dbrefrange count nullstr -- dbrefrange ignoringstr)
  begin
    over while
    3 pick 3 + rotate dup ignoring? not if
        -4 rotate
    else
        dup -5 rotate
        name " " strcat strcat
    then
    swap 1 - swap
  repeat
  swap pop sort-stringwords
;
: do-getplayers (players -- dbrefrange)
    stripspaces single-space
    remember-pagee
    0 "" rot get-playerdbrefs
    dup if
        comma-format dup " " instr
        "I don't recognize the player"
        swap if "s" strcat then
        " named " strcat swap strcat
        tell
    else pop
    then
;
: do-sleepers (dbrefrange -- dbrefrange')
    dup "" remove-sleepers
    dup if
        comma-format dup " " instr
        if " are " else " is " then
        "currently asleep." strcat
        strcat tell
        "You can leave page-mail with \"page #mail <plyrs>=<mesg>\""
        tell
    else pop
    then
;
: do-erasees (dbrefrange -- dbrefrange')
    dup "" remove-non-erasees
    dup if
        comma-format
        " didn't have any messages from you."
        strcat tell
    else pop
    then
;
: do-nopagers (dbrefrange -- dbrefrange')
    dup "" remove-nopagers
    dup if
        comma-format dup " " instr
        if " are " else " is " then
        "currently not accepting pages."
        strcat strcat tell
    else pop
    then
;
: do-ignoring (dbrefrange -- dbrefrange')
    dup "" remove-ignoring
    dup if
        comma-format dup " " instr
        if " are " else " is " then
        "currently ignoring you."
        strcat strcat tell
    else pop
    then
;
: do-nonwiz (dbrefrange -- dbrefrange')
    dup "" remove-nonwiz
    dup if
        comma-format dup " " instr if
          " are not wizards."
        else
          " is not a wizard."
        then
        strcat tell
    else pop
    then
;
: do-maxers ( dbrefrange -- dbrefrange' )
    dup dup "" remove-maxers
    dup if
        comma-format dup " " instr
        if " don't " else " doesn't " then
        "want to be included in multi-pages to that many people."
        strcat strcat tell
    else pop
    then
;
: do-list-ignored-pagees (dbrefrange -- dbrefrange')
    dup "" list-ignored-pagees
    dup if
        comma-format dup " " instr
        if " are " else " is " then
        "currently ignored by you."
        strcat strcat tell
    else pop
    then
;
(********* MUFpage 2.51 **********)
(********* ADDED BY RISS *********)
: list-ineditor (lists folks in I mode)
    begin
        over while
        3 pick 3 + rotate dup "I" flag? not if
            -4 rotate
        else
            dup -5 rotate
            name " " strcat strcat
        then
        swap 1 - swap
    repeat swap pop sort-stringwords
;
: do-interactive (added by riss)
    dup "" list-ineditor
    dup if
        comma-format dup " " instr if
            " are editing a program or file and might not respond quickly."
        else
            " is editing a program or file and might not respond quickly."
        then
        strcat tell
    else pop
    then
;
(******* END ADDED BY RISS *******)
 
: away? (dbref -- bool)
    oproploc "_page/away" getpropstr
;
 
: idle-length (dbref -- int)
    dup player? if
        descriptors dup not if pop -1 exit then
        1 - swap descr_idle
        begin
            over
        while
            swap 1 - swap
            rot descr_idle
            over over > if swap then pop
        repeat
        swap pop
    else
        timestamps pop swap pop swap pop
        systime swap -
    then
;
 
: idle? (dbref -- bool)
    dup idle-length
    swap get-idletime >=
;
 
: do-list-away (refrange -- refrange')
    dup "" begin over while swap 1 - swap
        over 4 + pick dup away? not over "I" flag? or if pop continue then
        dup get-awaymsg dup if
            "Away message for "
            rot name strcat ": " strcat
            swap strcat tell
        else
            pop name " " strcat strcat
        then
    repeat swap pop sort-stringwords
    dup if
        comma-format dup " " instr
        if " are " else " is " then
        "currently away and may not get back to you soon." strcat
        strcat tell
    else pop
    then
;
 
: do-list-idle (refrange -- refrange')
    dup ""
    begin
        over
    while
        swap 1 - swap
 
        over 4 + pick dup idle? not over away? or over "I" flag? or
        if pop continue then
 
        dup get-idlemsg dup if
            "Idle message for "
            3 pick name strcat ": " strcat
            swap strcat
        else
            pop dup name
            " is currently %i idle and may not get back to you soon."
            strcat
        then
 
        swap idle-length
        dup 3600 > if
            3600 / " hour"
        else
            dup 60 > if 60 / " minute" else " second" then
        then
        over 1 = not if "s" strcat then
        swap intostr swap strcat
        "%i" subst tell
    repeat
    swap pop sort-stringwords
    dup if
        comma-format dup " " instr
        if " are " else " is " then
        "currently idle and may not get back to you soon." strcat
        strcat tell
    else pop
    then
;
 
: do-warn-away ()
    me @ away? if
        "You are currently marked as being away." tell
    then
;
: get-valid-pagees (players -- dbrefrange players')
    do-getplayers
    do-sleepers
    do-nopagers
    do-ignoring
    do-maxers
    do-interactive (ADDED BY RISS *******)
    do-list-away
    do-list-idle
    do-list-ignored-pagees
    do-warn-away
    dup "" refs2names
;
: page-toeach (dbrefrange to message -- )
    begin
        3 pick while
        3 pick 3 + rotate over swap
        (refrange to mesg mesg dbref)
        dup remember-pager
        get-curr-format
        me @ swap get-oformat-prop
        (refrange to mesg mesg dbref format)
        5 pick page-them-inform
        rot 1 - rot rot
    repeat pop pop pop
;
 
 
: summon-toeach (dbrefrange -- )
    begin
        dup while
        dup 1 + rotate
        dup remember-pager
        "You sense that " me @ name strcat
        " is looking for you in " strcat
        me @ location name strcat
        over me @ location owner dbcmp if
          me @ location intostr
          "(#" swap strcat ")" strcat strcat
        then
        "." strcat notify
        1 -
    repeat pop
;
(****** From MUFpage 2.51 ********)
 
( SPR MUFpage, removed
: get-valid-pagees {players -- dbrefrange players'}
    do-getplayers
    do-sleepers
    do-nopagers
    do-ignoring
    do-maxers
    do-list-ignored-pagees
    dup "" refs2names
;
{ each stuff }
: idle-check {dbref -- } {*Ruffin}
    dup get-idlemsg dup if
      swap name "Idle message for " swap strcat ": " strcat swap strcat tell
    else pop pop then
;
: page-toeach {dbrefrange to message -- }
    3 pick not if pop pop pop exit then
    3 pick 3 + rotate over swap
    {refrange to mesg mesg dbref}
    dup idle-check {*Ruffin}
    dup remember-pager
    get-curr-format
    me @ swap get-oformat-prop
    {refrange to mesg mesg dbref format}
    5 pick page-them-inform
    rot 1 - rot rot page-toeach
;
: summon-toeach {dbrefrange -- }
  begin
    dup while
    dup 1 + rotate
    dup remember-pager
    "You sense that " me @ name strcat
    " is looking for you in " strcat
    me @ location name strcat
    over me @ location owner dbcmp if
      me @ location intostr
      "{#" swap strcat "}" strcat strcat
    then
    "." strcat notify
    1 -
  repeat pop
; )
: mail-toeach (dbrefrange message -- )
  begin
    over while
    over 2 + rotate
    over swap mail-send
    swap 1 - swap
  repeat
  pop pop
;
: forward-toeach ( dbrefrange message -- )
    begin
      over while
      over 2 + rotate
      over swap send-old-mail
      swap 1 - swap
    repeat pop pop
;
: mail-send-old ( dbrefrange message -- )
    begin
      over while
      swap 1 - swap
      over 3 + rotate
      dup get-forward dup if
        do-getplayers dup if
          dup "" remove-ignoring pop
          dup 2 + rotate name
          "(Orig. to " swap strcat
          ")\r" strcat
          over 3 + pick strcat
        else pop 1 3 pick
        then
      else pop 1 3 pick
      then
      forward-toeach
    repeat
    pop pop
;
: mail-do-forwards (dbrefrange message -- )
  begin
    over while
    swap 1 - swap
    over 3 + rotate
    dup get-forward dup if
        do-getplayers dup if
            dup "" remove-ignoring pop
            dup 2 + rotate name
            "(Orig. to " swap strcat
            ")\r" strcat
            over 3 + pick strcat
        else pop 1 3 pick
        then
    else pop 1 3 pick
    then
    mail-toeach
  repeat
  pop pop
;
: check-each (dbrefrange -- )
  begin
    dup while
    dup 1 + rotate
    dup name " has " strcat
    over mail-count
    dup not if
      pop "no messages" strcat
    else
      dup 1 = if
        pop "1 message" strcat
      else
        intostr strcat
        " messages" strcat
      then
    then
    " waiting." strcat
    over mail-count if
        "  Oldest is dated " strcat swap
        oproploc dup "_page/@mail#/1" getpropstr
        swap pop mail-unparse-mesg
        pop swap pop strcat "." strcat
    else swap pop
    then
    tell
    1 -
  repeat pop
;
: ignore-each (dbrefrange -- )
  begin
    dup while
    swap ignore-dbref
    1 -
  repeat pop
;
: unignore-each (dbrefrange -- )
  begin
    dup while
    swap unignore-dbref
    1 -
  repeat pop
;
: priority-each (dbrefrange -- )
    dup not if pop exit then
    swap priority-dbref
    1 - priority-each
;
: unpriority-each (dbrefrange -- )
    dup not if pop exit then
    swap unpriority-dbref
    1 - unpriority-each
;
( multi stuff )
: multi-page (message player -- )
    get-valid-pagees
    dup if
        (message dbrefrange playerstr)
        dup me @ setlastpaged comma-format
        (message dbrefrange playerstr)
        over 3 + rotate
        (dbrefrange playerstr message)
        dup me @ get-curr-format
        (derefrange plyrstr mesg mesg formatname)
        get-format-prop
        (derefrange plyrstr mesg mesg format)
        over " " split pop
        1 strcut strlen 3 <
        over not if swap pop " " swap then
        ".,?!:' " rot instr and
        if "%i%m" "%i %m" subst then
        (derefrange plyrstr mesg mesg format)
        4 pick "%n" subst
        (derefrange plyrstr mesg mesg format)
        dup "%w" instr if
            get-timestr
            "%w" subst
        then
        me @ name "%i" subst
        (derefrange plyrstr mesg mesg format)
        swap "%m" subst
        (derefrange plyrstr mesg format)
        page-me-inform page-toeach
        me @ havened? if
            "You are currently set haven."
            tell
        then
    else pop pop pop
    then
;
: multi-summon (player -- )
    get-valid-pagees
    dup if
        dup me @ setlastpaged comma-format
        "You sent your summons to "
        swap strcat "." strcat
        page-me-inform summon-toeach
        me @ havened? if
            "You are currently set haven."
            tell
        then
    else pop pop
    then
;
: multi-ping (player -- )
    get-valid-pagees
    dup if
        dup me @ setlastpaged
        comma-format
        "You can page to "
        swap strcat "." strcat
        page-me-inform popn
        me @ havened? if
            "You are currently set haven."
            tell
        then
    else pop pop
    then
;
: multi-oldforward (mesg names -- )
    do-getplayers
    do-ignoring
    dup "" refs2names
    dup if
      dup me @ setlastpaged
      comma-format
      "Mail forwarded to " over strcat "." strcat tell
      dup " " instr if
        "\r<forwarded to " swap strcat ">" strcat
        over 3 + rotate swap strcat over 2 + -1 * rotate
      else pop then
      dup 2 + rotate
      mail-send-old
      me @ havened? if
        "You are currently set haven." tell
      then
    then
;
: multi-mail (mesg names -- )
    do-getplayers
    do-ignoring
    dup "" refs2names
    ( mesg {dbref_range} names )
    dup if
        dup me @ setlastpaged
        over 3 + rotate dup pagepose? if
            1 strcut swap pop
            dup " " split pop
            1 strcut strlen 3 <
            over not if swap pop " " swap then
            ".?!,': " rot instr and
            not if " " swap strcat then
            me @ name swap strcat
        then
        swap comma-format
        over "\r" instr not if
          "You page-mail \"" 3 pick strcat
          "\" to " strcat over strcat "." strcat tell
        else
          "Message sent to " over strcat "." strcat tell
        then
        dup " " instr if
            "\r(to " swap strcat ")" strcat strcat
        else pop
        then
        mail-do-forwards
        me @ havened? if
            "You are currently set haven."
            tell
        then
    then
;
: multi-check
    do-getplayers
    dup if
        check-each
    then
;
: multi-erase (player -- )
    do-getplayers
    do-erasees
    dup "" refs2names
    dup if
        comma-format
        "You erased your last message to "
        swap strcat "." strcat
        page-me-inform popn
    else pop pop
    then
;
: multi-ignore (players -- )
    do-getplayers
    dup "" refs2names
    comma-format
    "Adding " swap strcat
    " to your ignore list."
    strcat tell ignore-each
;
: multi-unignore (players -- )
    do-getplayers
    dup "" refs2names
    comma-format
    "Removing " swap strcat
    " from your ignore list."
    strcat tell unignore-each
;
: multi-priority (players -- )
    do-getplayers
    dup "" refs2names
    comma-format
    "Adding " swap strcat
    " to your priority list."
    strcat tell priority-each
;
: multi-unpriority (players -- )
    do-getplayers
    dup "" refs2names
    comma-format
    "Removing " swap strcat
    " from your priority list."
    strcat tell unpriority-each
;
(  _______
  {__|__  \
  ___|__}_/
)
( help stuff )
: show-help-list
  begin
    dup while
    dup 1 + rotate
    str @ "|" subst
    tell
  1 - repeat
;
: show-changes
"MUFpage v2.54 by Foxen (ANSI support by Raven)   Changes"
"---------------------------------------------------------------------------"
"ANSI  01/31/99  Added ansi support."
"v2.54 10/10/97  Converted p |idle to p |away.  Added |idlemsg. Added"
"                |idletime.  Added Interactive checking.  All taken from"
"                latest MufPage from Foxen.  |idle is same as |away (Syvel)"
"x3   Sep 04 96  p |nuke to delete page-mail messages without reading (*Tyro)"
"x2   Mar 10 96  p |showwho to force showing of multiple person pages (Ruffin)"
"x1    Mar 9 96  Summons only works to one person, cut down accidents (Ruffin)"
"x1              Added p |idle to warn of paging idling person (Ruffin)"
"v2.53 10/ 4/94  Fixed |proploc to work as designed."
"v2.52  8/16/94  Mail improved to use optional lsedit-style, saving mail,"
"                 and all commands thereunto pertaining."
"v2.51  8/15/94  Aliases upgraded to _props and propdirs."
"v2.50  8/14/94  Encryption removed and all props placed in @propdirs."
"v2.40  7/13/92  Modded to use propdirs and assume FB server."
"v2.35  3/31/92  Made page-posing more intelligent with regards to spacing."
"v2.34  2/ 5/92  Make lastpaged/r/group encrypted.  Improved encryptions."
"                 Added partial name matching for last five pagers."
"v2.32  1/22/92  Added |lookup <player> to list aliases w/ them in them."
"v2.31 10/31/91  Summoning now gives room# if pagee owns room pager is in."
"v2.30 10/12/91  Added |priority for letting players page you despite haven."
"v2.29 10/11/91  Added |sleepmsg, |haven and |ignore messages."
"v2.26 10/10/91  Fixed |multimax probs, and made |mail remember last paged."
"v2.25  9/ 6/91  Fixed |proploc page-mail copying problem.  Added |multimax."
"-- Type 'page |help' to see more info on each command.  \"feeps 4-ever!\" --"
25 show-help-list (*Ruffin) (*Tyro)
;
(  old changes:
"v2.23  8/21/91  Added #erase for erasing messages mistakenly #mailed."
"v2.22  6/20/91  Added #inform.  Various bugfixes and security fixes."
"v2.20  6/17/91  Made #proploc work with p-aliases.  Added 'page &<alias>'"
"                 Fixed aliases to work with dbrefs and ignore stuff in parens"
"v2.18  6/14/91  Made it sort all multiple name outputs alphabetically."
"v2.17  6/12/91  Added sorting to alias listing."
"v2.16  6/11/91  Made small formatting fixes.  Moved p-aliases to player"
"v2.15  5/27/91  Made paging of multiple ignored players list on one line."
"v2.14  5/21/91  Added %w oformat sub for time.  Made all functions that"
"                 take player arguments work with page-again feature. Added"
"                 #time to tell the current time.  Helpful with %w's"
"v2.11  5/20/91  Added #proploc and made #ignore work on page-mail."
"v2.09  5/16/91  Added #check to see if a player has page-mail waiting."
"v2.08  5/16/91  Made page-mail use encryption, and disallowed multi-page"
"                 usage by the Guest character.  Added update notification."
"v2.05  5/ 9/91  Added %t substitution for #oformats to list all paged to."
"v2.04  5/ 9/91  Added #forward, and day stamping in page-mail."
"v2.02  5/ 1/91  Added #credits and fixed a problem with paging when broke."
"v2.00  4/27/91  Removed #pose, #opose, #page, #opage and replaced them with"
"                 #format,  #oformat and 'page !<format> <plyrs>=<msg>'."
20 )
: show-credits
"MUFpage v2.54 by Foxen (ANSI support by Raven)           Credits"
"-------------------------------------------------------------------------"
"The following people, through questions, comments, or suggestions gave me"
"the ideas for the following features:  (in alphabetical order)"
"  Ashtoreth:    disallowing Guest multi-paging, |inform"
"  auzzie:       |ignore, formats, |haven, |ping, |help, |credits"
"  Bruce:        |mail"
"  Chris:        informing when you are haven, or page an ignored player"
"  ChupChup:     |echo, |standard, using /lib/cpp"
"  darkfox:      various coding ideas, %w subs, and being a kooshball target"
"  Deuce:        Removal of encryption and implementation of @props."
"                Revamping of aliases and mail. \"If you don't trust your"
"                wizards, they shouldn't be wizards at all.\""
"  Erych:        encryption of page-mail"
"  fur:          Made all player arg commands work with page-again"
"  Gazer:        The shell sort routines. (he wrote the code)"
"  Jack_Salem:   |erasing of mistakenly sent page-mail"
"  Karrejanshi:  showing room numbers in summons when pagee owns room."
"  Lunatic:      single line messages for multiple people."
"  Lynn_Onyx:    page |mail security loophole fix.  |priority"
"  Miller:       |check"
"  Platypus_Bob: |prepending formats, |standard formats"
"  Raven:        ANSI support."
"  Siegfried:    disallowing Guest use of |commands.  dbrefs in aliases."
"  Snooze:       debugging help with paging without pennies"
"  tk:           global and personal multi-person aliases"
"  Tugrik:       multiple selectable formats"
"And this leaves only multi-player paging, |version, |changes, |hints,"
"|index and page-posing as completely my own ideas that no-one else"
"suggested I add into it."
30 show-help-list
;
: show-index
"MUFpage v2.54 by Foxen (ANSI support by Raven)            Index"
"----------------------------------------------------------------"
"Aliases            2,A               Multimax              2    "
"Changes            1                 Oformats              3,A,B"
"Echo               3                 Page format           A,B  "
"Erase              1                 Pose format           A,B  "
"Formatted          3                 Paging                1    "
"Formats            3,A               Pinging               2    "
"Forwarding         3                 Posing                1,B  "
"Global aliases     2,A               Prepend               3,B  "
"Haven              2                 Proploc               3,B  "
"Help               1,2,3             Repaging              1    "
"Hints              1,A,B             Replying              1    "
"Idle messages      4                 Color                 4    " (*Ruffin)(Raven)
"Ignoring           2                 Sleepmsg              2    "
"Inform             3                 Standard              3    "
"Mailing            4                 Summoning             1    "
"Mail-checking      3                 Version               1    "
"Mail-nuking        1                 Deleting              1    " (*Tyro)
"Multi-paging       1,4               Who                   1    " (*Ruffin)
"--  1 = page |help      2 = page |help2      3 = page |help3  --"
"--  A = page |hints     B = page |hints2     4 = page |help4  --"
22 show-help-list
;
: show-help
"MUFpage v2.54 by Foxen (ANSI support by Raven)            Page1"
"--------------------------------------------------------------------------"
"To give your location to another player:     'page <player>'"
"To send a message to another player:         'page <player> = <message>'"
"To send a pose style page to a player:       'page <player> = :<pose>'"
"To page multiple people:                     'page <plyr> <plyr> [= <msg>]'"
"To send another mesg to the last players:    'page = <message>'"
"To send your loc to the last players paged:  'page'"
"To send a message in a different format:     'page !<fmt> <plyrs> = <msg>'"
"To reply to a page sent to you:              'page |r [= <message>]'"
"To reply to all the people in a multi-page:  'page |R [= <message>]'"
"To erase a message you sent to a player:     'page |erase <players>'"
"To list who you last paged, who last"
"  paged you, and who you are ignoring:       'page |who'"
"To display what version this program is:     'page |version'"
"To display the latest program changes:       'page |changes'"
"To show who all helped with this program:    'page |credits'"
"To display an index of commands:             'page |index'"
"To display the next help screen:             'page |help2'"
"-- Words in <> are parameters.  Parameters in [] are optional. --"
19 1 + show-help-list
;
: show-help2
"MUFpage v2.54 by Foxen (ANSI support by Raven)             Page2"
"------------------------------------------------------------------------"
"To test if you can page a player:          'page |ping <players>'"
"To refuse pages from specific players:     'page |ignore <players>'"
"To set the mesg all ignored players see:   'page |ignore [<plyrs>]=<mesg>'"
"To accept pages from a player again:       'page |!ignore <player>'"
"To let players page you despite haven:     'page |priority <players>'"
"To remove players from your priority list: 'page |!priority <players>'"
"To page a group of people in an alias:     'page *<aliasname> = <message>'"
"To set a personal page alias:              'page |alias <alias>=<players>'"
"To clear a personal page alias:            'page |alias <alias>='"
"To list who is in an alias:                'page |alias <alias>'"
"To list all your personal aliases:         'page |alias'"
"To set an alias to the players last paged: 'page &<aliasname>'"
"To make an alias that everyone can use:    'page |global <alias>=<players>'"
"To clear a global page alias:              'page |global <alias>='"
"To list all the global aliases:            'page |global'"
"To list all aliases with a player in them: 'page |lookup <playername>'"
"To see the time (useful with %w subs):     'page |time'"
"To set the max# of plyrs in a page to you: 'page |multimax <max#players>'"
"To see your multimax setting:              'page |multimax'"
"To set the your 'Sleeping' message:        'page |sleepmsg <message>'"
"To clear the your 'Sleeping' message:      'page |sleepmsg |clear'"
"To display the third help screen: \"page |help3\""
24 show-help-list
;
: show-help3
"MUFpage v2.54 by Foxen (ANSI support by Raven)          Page3"
"--------------------------------------------------------------------------"
"To haven yourself so you are unpagable:      'page |haven'"
"To set your 'havened' message:               'page |haven <message>'"
"To clear your 'havened' message:             'page |haven |clear'"
"To unhaven yourself so you can be paged:     'page |!haven'"
"To turn on echoing of your message:          'page |echo'"
"To turn off echoing of your message:         'page |!echo'"
"To be informed when a page to you fails:     'page |inform'"
"To be turn off failed-page informing:        'page |!inform'"
"To see another player's formatted pages:     'page |formatted'"
"To prepend a format string to other's pages: 'page |prepend'"
"To set your prepended format string:         'page |prepend <formatstr>'"
"To force other's pages to a standard format: 'page |standard'"
"To set the standard format you receive in:   'page |standard <formatstr>'"
"To set a format that you see when paging:    'page |format <fmtname>=<fmt>'"
"To set a format that others receive:         'page |oformat <fmtname>=<fmt>'"
"To forward page-mail to another player:      'page |forward <players>'"
"To stop forwarding page-mail:                'page |forward |'"
"To see who page-mail to you is forwarded to: 'page |forward'"
"To see if page-mail is waiting for a player: 'page |check [players]'"
"To use an object for storing page props on:  'page |proploc <object>'"
"To display the fourth and last help screen: \"page |help4\""
23 show-help-list
;
: show-help4
"MUFpage v2.54 by Foxen (ANSI support by Raven)          Page4"
"---------------------------------------------------------------------------"
"To mail someone a short message:             'page |mail <names>=<message>'"
"To use the mail editor for longer messages:  'page |mail <names>'"
"To read your own mail:                       'page |mail'"
"(You can now save mail when you read it.)"
"To delete all your mail without reading it:  'page |nuke'"
"To list saved mail:                          'page |old'"
"To look at a saved message:                  'page |old <messagenumber>'"
"To delete a saved message:                   'page |delete <number>'"
"To forward a saved message to others:        'page |send <number>=<names>'"
"To mark yourself away:                       'page |away'"
"To set your away flag and message:           'page |away <message>'"
"To clear your away message:                  'page |away #clear'"
"To reset your away flag:                     'page |!away'"
"To set your idle message:                    'page |idlemsg <message>'"
"To clear your idle message:                  'page |idlemsg #clear'"
"To view what your current idle timeout is:   'page |idletime'"
"To set how long your idle timeout is:        'page |idletime <minutes>'"
"To turn off your idle messages:              'page |idletime #off'"
"To force showing of received multipages:     'page |showwho'" (*Ruffin)
"To not force showing of received multipages: 'page |!showwho'" (*Ruffin)
"To change your ansi color setting:           'page |color <color>" (*Raven)
"To clear your ansi color setting:            'page |color #clear" (*Raven)
" "
"All saved mail is cleaned out after 10 days for non-wizards."
26 show-help-list
;
: show-hints
"MUFpage v2.54 by Foxen (ANSI support by Raven)            Hints1"
"--------------------------------------------------------------------------"
"All page commands can be used abbreviated to unique identifiers."
"  For example: 'page |gl' is the same as 'page |global'"
"If you page to a name it doesn't recognize, it will check to see if it is"
"  a personal alias.  If it isn't, it checks to see if it is a global alias."
"  For example: If there is a global alias 'tyg' defined as 'Tygryss', then"
"  'page tyg=test' will page 'test' to Tygryss."
"In format strings, %n will be replaced by the name of the player(s) receiv-"
"  ing the page.  %m will be replaced by the message.  %i will be replaced"
"  by your name.  %w gets replaced by the time.  These messages are what are"
"  shown to you when you page to someone."
"In oformat strings, %n will be replaced by your name, %m by the message,"
"  and %l by your location.  %t will be replaced with the names of all the"
"  people in a multi-page.  %w will be replaced with the current time."
"  These messages are what is shown to the player you are paging."
"If you have a |prepend or |standard format with a %w, it shows you the time"
"  when a player paged you."
"Use 'page |hints2' to show the next hints screen."
19 show-help-list
;
: show-hints2
"MUFpage v2.54 by Foxen (ANSI support by Raven)            Hints2"
"--------------------------------------------------------------------------"
"There are two standard formats with page: the 'page' format, and the 'pose'"
"  format.  There are matching |oformats to go with them as well."
"If you really dislike having your pages that begin with colons parsed as"
"  page-poses, then you can 'page |oformat pose=%n pages: :%m'"
"  or alternately, you can simply use 'page ! <players>=<mesg>'"
"One good way to have all the pages to you beeped and hilighted is to do:"
"  'page |prepend ##page>' and then set up the this trigger in tinyfugue:"
"  '/def -p15 -fg -t\"##page> *\" = /beep 3%;/echo %e[7m%-1%e[0m'"
"  If you want bold hilites instead, use '%e[1m' instead of '%e[7m'"
"  This only works if you have version 1.5.0 or later of tinyfugue and a"
"  vt100 terminal type."
"TinyTalk users, to make your pages always beep, use 'page |standard'"
"  Then all pages to you will be in standard page format."
"You can specify another object to store the properties used by the page"
"  program on.  To do this, type 'page |proploc <object>' where <object>"
"  is either the name (if its in the room) or dbref of the object to use."
"  |proploc will automatically copy all the page props to the new object."
19 show-help-list
;
: show-who-info ( -- )
    "You last paged to "
    me @ getlastpaged comma-format
    dup not if pop "no one" then
    strcat "." strcat tell
    "The last six people to page you were "
    me @ getlastpagers comma-format
    dup not if pop "no one" then
    strcat " (who paged last)." strcat tell
    me @ getlastpagedgroup comma-format
    dup if
        "The last group page also included "
        swap strcat "." strcat tell
    else pop
    then
    "You are receiving pages in "
    me @ page_standard?
    dup 1 = if pop "prepended"
    else
        2 = if "forced standard"
        else   "regular formatted"
        then
    then
    strcat " form." strcat tell
    me @ get-multimax dup 888 < if
        "You accept pages including up to "
        over intostr strcat swap 1 >
        if " people." else " player." then strcat tell
    else pop
    then
    "You are ignoring "
    list-ignored dup not
    if pop "no one" then
    strcat "." strcat tell
    "You are giving priority to "
    list-priority dup not
    if pop "no one" then
    strcat "." strcat tell
    "You are %mforcing received multipages to be shown." (*Ruffin)
    me @ get-showwho if "" else "not " then "%m" subst tell (*Ruffin)
    me @ "haven" flag? if
        "You are currently set haven, so no one can page you."
        tell
    then
    me @ get-idlemsg dup if (*Ruffin)
        "Everyone is seeing your idle warning: " swap strcat tell
    else pop then
;
: page-main
    stripspaces
    dup "&" 1 strncmp not if
        1 strcut swap pop
        "=" strcat me @
        getlastpaged strcat
        "#alias " swap strcat
    then
    dup "#R" 2 strncmp not over "-R" 2 strncmp not or if
        2 strcut swap pop
        me @ getlastpagedgroup
        " " strcat swap strcat
        "#r" swap strcat
    then
    dup "#r" 2 strncmp not over "-r" 2 strncmp not or if
        2 strcut swap pop
        me @ getlastpager
        " " strcat swap strcat
    then
    dup "#" 1 strncmp not over "-" 1 strncmp not or if
        1 strcut swap str !
        dup "who" 1 stringmatch? if
            pop show-who-info exit
        then
        dup "version" 1 stringmatch? if
            pop "MUFpage v2.54 by Foxen (ANSI support by Raven)"
            tell exit
        then
        dup "changes" 1 stringmatch? if
            pop show-changes exit
        then
        dup "credits" 2 stringmatch? if
            pop show-credits exit
        then
        dup "index" 2 stringmatch? if
            pop show-index exit
        then
        dup "help" 1 stringmatch? if
            pop show-help exit
        then
        dup  "help2" stringcmp not
        over "hel2" stringcmp not or
        over "he2" stringcmp not or
        over "h2" stringcmp not or if
            pop show-help2 exit
        then
        dup  "help3" stringcmp not
        over "hel3" stringcmp not or
        over "he3" stringcmp not or
        over "h3" stringcmp not or if
            pop show-help3 exit
        then
        dup  "help4" stringcmp not
        over "hel4" stringcmp not or
        over "he4" stringcmp not or
        over "h4" stringcmp not or if
            pop show-help4 exit
        then
        dup "hints" 2 stringmatch? if
            pop show-hints exit
        then
        dup  "hints2" stringcmp not
        over "hint2" stringcmp not or
        over "hin2" stringcmp not or
        over "hi2" stringcmp not or if
            pop show-hints2 exit
        then
        me @ name 5 strcut pop "Guest" stringcmp not
$ifdef GLOWMUCK
        me @ "GUEST" flag? or
$endif
if
            pop "Permission denied." tell exit
        then
        dup "!haven" 2 stringmatch? if
            pop me @ "!haven" set
            "Haven bit reset."
            tell exit
        then
        dup "echo" 1 stringmatch? if
            pop "" set_page_echo
            "Pages now echoed." tell exit
        then
        dup "!echo" 2 stringmatch? if
            pop "no" set_page_echo
            "Pages now not echoed." tell exit
        then
        dup "inform" 2 stringmatch? if
            pop "yes" set_page_inform
            "You will now be informed of ignored page attempts."
            tell exit
        then
        dup "!inform" 3 stringmatch? if
            pop "" set_page_inform
            "You will no longer be informed of ignored page attempts."
            tell exit
        then
        dup " " instr if
            " " split swap
            dup "mail" 1 stringmatch? if
                pop stripspaces dup "=" instr if
                    "=" split stripspaces swap
                    multi-mail exit
                else
                    stripspaces do-editor not if
                      exit
                    else
                      swap multi-mail
                    then
                    exit
                then
            then
            dup "old" 2 stringmatch? if
                pop stripspaces mail-oldread
                "Done." tell exit
            then
            dup "delete" 3 stringmatch? if
                pop stripspaces mail-delete-old
                "Done." tell exit
            then
            dup "send" 2 stringmatch? if
                pop "=" split strip swap strip
                swap myproploc "_page/@omail#/"
                4 rotate strcat getpropstr dup not if
                pop "You have no such saved mail message." tell exit
                then
                swap multi-oldforward exit
            then
            dup "check" 2 stringmatch? if
                pop multi-check exit
            then
( ------------Added by Raven for Color support! ------------ )
            dup "color" 3 stringmatch? if
                pop stripspaces dup
                "#clear" stringcmp not over "-clear" stringcmp not
                or if pop "none" then
                dup goodcolor? if
                   me @ set-color
                else
                   pop tell-bad-color exit
                then
                "Page color now set." tell exit
            then
( --------END addition for color support by Raven----------- )
            dup "haven" 2 stringmatch? if
                pop stripspaces dup
                "#clear" stringcmp not over "-clear" stringcmp not
                or if pop "" then
                me @ set-havenmsg
                me @ "haven" set
                "Haven message and haven bit are now set." tell exit
            then
            dup "away" 3 stringmatch? if
                pop stripspaces dup
                "#clear" stringcmp not if pop "" then
                me @ set-awaymsg
                me @ oproploc "_page/away" "yes" setprop
                "Away message and away flag are now set." tell exit
            then
            dup "idlemsg" 3 stringmatch? if
                pop stripspaces dup
                "#clear" stringcmp not if pop "" then
                me @ set-idlemsg
                "Idle message is set." tell exit
            then
            dup "idletime" 6 stringmatch? if
                pop stripspaces dup
                "#off" stringcmp not if
                    pop 88888888
                else
                    dup number? if atoi else pop -1 then
                then
                dup 0 > if
                    60 * me @ set-idletime
                    "Idle timeout is set." tell
                else
                    pop "page: #idletime: timeout must be a positive number."
                    tell
                then
                exit
            then
            dup "sleepmsg" 2 stringmatch? if
                pop stripspaces dup
                "#clear" stringcmp not over "-clear" stringcmp not
                or if pop "" then
                me @ set-sleepmsg
                "Sleep message is set." tell exit
            then
            dup "ignore" 1 stringmatch? if
                pop stripspaces dup "=" instr if
                    "=" split stripspaces
                    swap stripspaces swap
                    me @ set-ignoremsg
                    "Ignore message is set." tell
                    dup not if pop exit then
                then
                single-space multi-ignore exit
            then
            dup "!ignore" 2 stringmatch? if
                pop stripspaces single-space
                multi-unignore exit
            then
            dup "priority" 1 stringmatch? if
                pop stripspaces single-space
                multi-priority exit
            then
            dup "!priority" 2 stringmatch? if
                pop stripspaces single-space
                multi-unpriority exit
            then
            dup "format" 1 stringmatch? if
                pop dup "=" instr if
                    "=" split stripspaces swap
                    stripspaces single-space
                    "_" " " subst
                    me @ swap rot
                    set-format-prop
                    "Format set." tell
                else
                    stripspaces dup
                    me @ swap get-format-prop
                    swap "' set to \"" strcat
                    swap strcat "\"" strcat
                    "Format '" swap strcat tell
                then exit
            then
            dup "oformat" 2 stringmatch? if
                pop dup "=" instr if
                    "=" split stripspaces swap
                    stripspaces single-space
                    "_" " " subst
                    me @ swap rot
                    set-oformat-prop
                    "Oformat set." tell
                else
                    stripspaces dup
                    me @ swap get-oformat-prop
                    swap "' set to \"" strcat
                    swap strcat "\"" strcat
                    "Oformat '" swap strcat tell
                then exit
            then
            dup "alias" 1 stringmatch? if
                pop dup "=" instr if
                    "=" split single-space
                    stripspaces swap
                    stripspaces single-space
                    dup not if
                        "page: alias: Alias name cannot be null."
                        tell pop pop exit
                    then
                    "_" " " subst swap
                    set-personal-alias
                else
                    stripspaces dup me @
                    get-alias "Alias \"" rot
                    strcat "\" expands to \""
                    strcat swap strcat "\""
                    strcat tell
                then exit
            then
            dup "global" 1 stringmatch? if
                pop "=" split stripspaces single-space
                swap stripspaces single-space
                dup not if
                    "page: global: Alias name cannot be null."
                    tell pop pop exit
                then
                "_" " " subst swap
                set-global-alias exit
            then
            dup "lookup" 2 stringmatch? if
                pop single-space stripspaces
                list-matching-aliases
                "Done." tell exit
            then
            dup "forward" 3 stringmatch? if
                pop single-space
                dup "#" strcmp not over "-" strcmp not or if
                    pop "" "Page-mail forwarding cleared."
                else
                    "Page-mail forwarding set."
                then tell set-forward exit
            then
            dup "erase" 3 stringmatch? if
                pop stripspaces single-space
                multi-erase exit
            then
            dup "multimax" 2 stringmatch? if
                pop stripspaces atoi
                me @ set-multimax
                "Multi-max set." tell exit
            then
            dup "standard" 2 stringmatch? if
                pop me @ set-standard
                "yes" set_page_standard
                "Page standard format set."
                tell exit
            then
            dup "prepended" 2 stringmatch? if
                pop me @ set-prepend
                "prepend" set_page_standard
                "Page prepend format set."
                tell exit
            then
            dup "ping" 2 stringmatch? if
                pop stripspaces
                multi-ping exit
            then
            dup "proploc" 3 stringmatch? if
                pop do-proplock-set exit
            then
        else
            dup "mail" 1 stringmatch? if
                pop mail-read "Done." tell exit
            then
            (*Tyro)
            dup "nuke" 1 stringmatch? if
                pop mail-nuke exit
            then
            dup "old" 2 stringmatch? if
                pop mail-oldlist exit
            then
            dup "check" 2 stringmatch? if
                pop me @ name multi-check exit
            then
            dup "delete" 3 stringmatch? if
              pop "" mail-delete-old "Done." tell exit
            then
            dup "send" 2 stringmatch? if
              pop "You must state a message # and the people recieving it."
              tell exit
            then
( ------------Added by Raven for Color support! ------------ )
            dup "color" 3 stringmatch? if
             showavailcolors exit
            then
( --------END addition for color support by Raven----------- )
            dup "haven" 2 stringmatch? if
                pop me @ "haven" set
                "Haven bit set." tell
                "Your haven message is \""
                me @ get-havenmsg strcat
                "\"" strcat tell exit
            then
            ( *Ruffin )
            dup "away" 3 stringmatch? if
                pop me @ "_page/away" "yes" setprop
                "Away flag set." tell
                "Your away message is \""
                me @ get-awaymsg strcat
                "\"" strcat tell exit
            then
            dup "!away" 3 stringmatch? if
                pop me @ oproploc "_page/away" 0 setprop
                "Away flag reset."
                tell exit
            then
            dup "idlemsg" 3 stringmatch? if
                pop "Your idle message is \""
                me @ get-idlemsg strcat
                "\"" strcat tell exit
            then
            dup "idletime" 6 stringmatch? if
                pop "Your idle timeout is "
                me @ get-idletime 60 / intostr strcat
                " minutes." strcat tell exit
            then
            dup "showwho" 2 stringmatch? if
                "yes" me @ set-showwho
                "You are now forcing page to show you when you have been included"
                "in a multipage, and it's not obvious from the #format."
                swap tell tell exit
            then
            dup "!showwho" 3 stringmatch? if
                "" me @ set-showwho
                "You are no longer forcing page to show you when you have been"
                "included in a multipage, and it isn't obvious from the #format."
                swap tell tell exit
            then
            dup "sleepmsg" 2 stringmatch? if
                pop "Your sleep message is \""
                me @ get-sleepmsg strcat
                "\"" strcat tell exit
            then
            dup "ignore" 1 stringmatch? if
                "You are currently ignoring "
                list-ignored dup not
                if pop "no one" then
                strcat "." strcat
                tell pop "Your ignore message is \""
                me @ get-ignoremsg strcat "\"" strcat
                me @ swap notify exit
            then
            dup "!ignore" 2 stringmatch? if
                "" me @ setignorestr
                "You are now ignoring no one."
                tell pop exit
            then
            dup "priority" 1 stringmatch? if
                "You are currently prioritizing "
                list-priority dup not
                if pop "no one" then
                strcat "." strcat
                tell pop exit
            then
            dup "!priority" 2 stringmatch? if
                "" me @ setprioritystr
                "You are now prioritizing no one."
                tell pop exit
            then
            dup "time" 1 stringmatch? if
                pop "The time is: "
                get-timestr strcat
                tell exit
            then
            dup "alias" 1 stringmatch? if
                list-personal-aliases
                "Done." tell exit
            then
            dup "global" 1 stringmatch? if
                list-global-aliases
                "Done." tell exit
            then
            dup "lookup" 2 stringmatch? if
                "Syntax error: Please specify a name."
                tell exit
            then
            dup "formatted" 2 stringmatch? if
                pop "" set_page_standard
                "Pages now received in formatted form."
                tell exit
            then
            dup "multimax" 2 stringmatch? if
                pop me @ get-multimax
                "You currently accept pages including up to "
                over intostr strcat swap 1 >
                if " people." else " player." then strcat
                tell exit
            then
            dup "oformat" 2 stringmatch? if
                "Bad |oformat syntax.  Type 'page |help3' for more help."
                1 show-help-list pop exit
            then
            dup "forward" 3 stringmatch? if
                pop me @ get-forward comma-format
                dup if
                    "You currently forward page-mail to "
                    swap strcat "." strcat
                else
                    pop "You aren't currently forwarding page-mail."
                then tell exit
            then
            dup "standard" 2 stringmatch? if
                pop "yes" set_page_standard
                "Pages now received in the standard form: "
                me @ get-standard strcat
                tell exit
            then
            dup "prepended" 2 stringmatch? if
                pop "prepend" set_page_standard
                "Pages now received prepended with '"
                me @ get-prepend strcat "'" strcat
                tell exit
            then
            dup "setup" 2 stringmatch? if
                trigger @ owner me @ dbcmp me @ "W" flag? or not if
                  "Permission denied." tell pop exit
                then
                trigger @ "_page/formats/page"
                "You page, \"%m\" to %n."  setpropstr
                trigger @ "_page/formats/opage"
                "%n pages, \"%m\" to %t." setpropstr
                trigger @ "_page/formats/pose"
                "You page-pose, \"%i %m\" to %n."  setpropstr
                trigger @ "_page/formats/opose"
                "In a page-pose to %t, %n %m" setpropstr
                #0 "_connect/page" prog setprop
                "Setup done." tell pop exit
            then
            dup "proploc" 3 stringmatch? if
                pop "Syntax: page |proploc <object>" 1 show-help-list exit
            then
        then
        "page: Syntax error: |" swap strcat
        "Type \"page |help\" for help." 2 show-help-list exit
    then
    dup "=" instr not if
        stripspaces single-space
        me @ name 5 strcut pop "Guest" stringcmp not
$ifdef GLOWMUCK
me @ "GUEST" flag? or
$endif
if
            dup " " instr if
                " " split pop
                "Guests are not allowed to use multi-page." tell
            then
        then
      (*Ruffin)
      dup not over " " instr or if
        "page: You didn't include a '=' in your page.  The 'summon' feature" tell
        "page: only works with a single name, as it's usually a typo." tell
      else
        multi-summon     (do a summons page)
      then
    else
        "=" split
        stripspaces
        dup pagepose? if
            1 strcut swap pop
            "pose" set-curr-format
        else
            "page" set-curr-format
        then
        swap stripspaces single-space
        dup "!" 1 strncmp not if
            " " split swap
            1 strcut swap pop
            dup not if pop "page" then
            set-curr-format
        then
        me @ name 5 strcut pop "Guest" stringcmp not
$ifdef GLOWMUCK
        ME @ "GUEST" flag? or
$endif
        if
            dup " " instr if
                " " split pop
                "Guests are not allowed to use multi-page." tell
            then
        then
        multi-page        (do a message page)
    then
;
: page-connect
  me @ name 5 strcut pop "Guest" stringcmp not
$ifdef GLOWMUCK
  me @ "guest" flag? or
$endif
  if
    myproploc "_page/@mail#" remove_prop exit
  then
  me @ mail-count dup if
    "You sense that you have "
    over 1 = if swap pop "1 page-mail message waiting."
    else
      swap intostr " page-mail messages waiting." strcat
    then
    strcat tell
  else pop then
  myproploc "_page/@omail#" getpropstr atoi if
    0 myproploc "_page/@omail#/" begin
      over swap nextprop dup while
      over over getpropstr
      " " split swap pop "@" split pop
      atoi getday swap -
      me @ "W" flag? if 25 else 10 then > if
        rot 1 + -3 rotate
        dup "" "_page/@omail#/" subst atoi
        -4 rotate
      then
    repeat pop pop
  dup if
    dup dup 1 = if "saved mail message" else "saved mail messages" then
    swap intostr " " strcat swap strcat " cleaned out." strcat tell
    begin
      dup while
      swap delete-message
    1 - repeat pop
  else pop then
  then
;
: main
    trig exit? not if
      dup "Connect" strcmp not if
        pop page-connect exit
      then
    then
    getday setday
    page-main
    me @ mail-count 0 > if
        "You have " me @ mail-count intostr strcat
        " page-mail messages waiting.  Use 'page #mail' to read."
        strcat tell
    then
    get-lastversion "MUFpage v2.54 by Foxen (ANSI support by Raven)" strcmp if
        "Page has been upgraded.  Type 'page #changes' to see the latest mods." tell
        get-lastversion dup if
            "You last used " swap strcat tell
        else pop
        then
        "MUFpage v2.54 by Foxen (ANSI support by Raven)" set-lastversion
    then
    begin depth while pop repeat
;
