( PlayerConfig By *Nakoruru@DragonMUCK*Akari@Distant Shores* )
(                               Nakoruru08@hotmail.com       )
( Version 1.0  completed 3/29/00                             )
( Version 1.1  completed 4/30/00                             )
( Version 2.0  completed 1/23/01                             )
( Version 2.1  completed 2/21/01                             )
( Version 2.11 completed 2/23/01                             )
( Version 2.12 completed 2/28/01                             )
( Version 2.13 completed 3/11/01                             )
( Version 2.2  completed 4/04/01                             )
( Version 2.21 completed 1/06/03                             )
( Version 2.30 completed 1/18/03                             )
(                                                            )
( The objective was to create a player editor that lets you  )
( do more than just set finger profile information. The code )
( was written in a way that makes it easy to add to and take )
( away configureable options. It was written to go along with)
( my version of 'finger', though could be tweaked easily to  )
( work with just about any finger program out there.         )
( It is configured to work with the following programs in    )
( mind:                                                      )
( Page version 2.54a or later                                )
( Teleport by Confu@Ranma or by Deedlit@Dragon               )
( Con-Announce. Either the old version, or ProtoWF by Moose. )
( NeonMUCK/ProtoMUCK for the ANSI color C flag setting       )
( Soft coded @rec front end by Deedlit@Dragon                )
( Soft coded @aname with confirmation                        )
( Throw program by Confu@Ranma                               )
( @paste version done by me, Deedlit@Dragon, and crysaliq    )
( AkariSpeak say and pose program by Akari.                  )
( ProtoFind by Akari                                         )
( ProtoLastOn by Moose                                       )
(                                                            )
( In version 1.1, the Web Support Editor menu was added.     )
( It's free for the taking, though it would most definitely  )
( require substantial changes at any MUCK that doesn't offer )
( the same sorts of programs as I have set up at mine.       )
(                                                            )
( Version 2.0 cleaned up some of the code, added the ability )
( to clear properties by entering a space, since there was no)
( way to clear settings before. Also added calls to some of  )
( the other editors I have in other programs, such as say and)
( find. This version is written for just ProtoMUCK as well as)
( a custom color editor to take advantage of Proto's custom  )
( color support.                                             )
( Version 2.1 - Added some more stuff to @colors.            )
( Version 2.11- More stuff to @colors.                       )
( Version 2.12- You guessed it. More stuff to @colors.       )
( Version 2.13- Finger profile @colors added.                )
( Version 2.2 - Added call to laston #custom, page colors,   )
(               and default WHO format preference.           )
( Version 2.3 - Added new finger / standard support, and     )
(               removed the @recycle / @aname stuff          )
(                                                            )
( Please contact with questions or problems.                 )
 
$author Akari
$version 2.2
 
(**Changeable $Defs**)
$def include_websupport? WWW_support? ( set to 0 to leave out the websupport stuff )
$define localserver
    "servername" sysparm ":" strcat "wwwport" sysparm strcat
$enddef
$def find-prog "$cmd/find" ( set to 0 to leave out the find editor )
$def say-prog  "$cmd/say"  ( set to 0 to leave out the say editor )
$def last-prog "$cmd/laston" ( set to 0 to leave out the laston editor )
$def custom-color 1        ( Set to 0 to leave out the custom color menu )
(**Program $Defs/$Includes**)
$def str_to_dbref stod ( s -- d )
$def atell me @ swap ansi_notify
$def infoSet? dup not if pop "<Not Set>" then
$def addit menu @ array_appenditem menu !
$define colors-list
"red|green|yellow|blue|purple|cyan|white|crimson|forest|brown|navy|violet|aqua|grey|bred|bgreen|byellow|bblue|bpurple|bcyan|bwhite|cred|cgreen|cyellow|cblue|cpurple|caqua|cwhite"
$enddef
$include $lib/puppet
$include $lib/editor
$include $lib/standard
(**Program Global Variables**)
var target (This will hold the dbref# of whatever's being edited)
var temp (Lazy programmer's varilable. ^^; Holds anything )
(**Program Code**)
lvar msgchoice ( message choice for message editor )
: Message-menu
  begin
  "^PURPLE^Editing: ^WHITE^" target @ unparseobj strcat atell
  target @ "_teleport/odepart" getpropstr infoSet?
  "  [1] Teleport departing message: " swap strcat .tell
  target @ "_teleport/oarrive" getpropstr infoSet?
  "  [2] Teleport arriving message: " swap strcat .tell
  target @ "_desc_notify_looked" getpropstr infoSet?
  "  [3] Look notify message: " swap strcat .tell
  target @ "_sweep/sweep" getpropstr infoSet?
  "  [4] Custom sweep message: " swap strcat .tell
  target @ "ride/_mode" getpropstr dup not if pop "Default" then
  "  [5] Handup messages: " swap strcat .tell
  target @ "_page/havenmsg" getpropstr infoSet?
  "  [6] Page Haven message: " swap strcat .tell
  target @ "_page/idlemsg" getpropstr infoSet?
  "  [7] Page Idle message: " swap strcat .tell
  target @ "_page/ignoremsg" getpropstr infoSet?
  "  [8] Page Ignore message: " swap strcat .tell
  target @ "_page/sleepmsg" getpropstr infoSet?
  "  [9] Page Sleep message: " swap strcat .tell
  target @ "_page/standard?" getpropstr "yes" stringcmp not if
    target @ "_page/stdf" getpropstr else "Nothing set." then
  " [10] Force page messages to: " swap strcat .tell
  target @ PROPS-heavyrotation getpropstr dup not if pop
    target @ "_/do" getpropstr dup not if pop
      "<None Set>" then
  then
  " [11] @Doing message: " swap strcat .tell
  " " .tell
  "^GREEN^  [^YELLOW^H^GREEN^]elp." atell
  "^PURPLE^  [^YELLOW^R^PURPLE^]eturn to previous menu." atell
  "^BLUE^  [^YELLOW^Q^BLUE^]uit the player editor." atell
  read strip msgchoice !
  msgchoice @ "1" stringcmp not if
    "Enter odepart teleport message, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
      target @ swap "_teleport/odepart" swap setprop
      "^GREEN^Message set." atell continue
    then
  then
  msgchoice @ "2" stringcmp not if
    "Enter oarrive teleport message, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
      target @ swap "_teleport/oarrive" swap setprop
      "^GREEN^Message set." atell continue
    then
  then
  msgchoice @ "3" stringcmp not if
    "Set your look notify message, a space to clear, or '.' to leave as is." .tell
    "Use '%N' for where you want the player's name to be." .tell
    read strip dup "." stringcmp not if pop continue else
      target @ swap "_desc_notify_looked" swap setprop
      "^GREEN^Message set." atell continue
    then
  then
  msgchoice @ "4" stringcmp not if
    "Set your custom sweep message, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
      target @ swap "_sweep/sweep" swap setprop
      "^GREEN^Message set. Sweep #help for additional messages." atell
    then continue
  then
  msgchoice @ "5" stringcmp not if
    "Set your handup message preference, a space to clear, or '.' to leave as is: " .tell
    "Typical options include ride, hand, walk, and fly." .tell
    read strip dup "." stringcmp not if pop continue else
      target @ swap "ride/_mode" swap setprop
      "^GREEN^Hand up preference set." atell continue
    then
  then
  msgchoice @ "6" stringcmp not if
    "Enter your page haven message, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
      target @ swap "_page/havenmsg" swap setprop
      "^GREEN^Message set." atell
    then continue
  then
  msgchoice @ "7" stringcmp not if
    "Enter your page idle message, a space to clear, or '.' to leave as is: " .tell
    "Use %i to insert the idle time in your message." .tell
    read strip dup "." stringcmp not if pop continue else
      target @ swap "_page/idlemsg" swap setprop
      "^GREEN^Message set." atell
    then continue
  then
  msgchoice @ "8" stringcmp not if
    "Enter your page ignore message, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
      target @ swap "_page/ignoremsg" swap setprop
      "^GREEN^Message set." atell
    then continue
  then
  msgchoice @ "9" stringcmp not if
    "Enter your page sleep message, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
      target @ swap "_page/sleepmsg" swap setprop
      "^GREEN^Message set." atell
    then continue
  then
  msgchoice @ "10" stringcmp not if
    "Enter the format to force pages to, '.' to leave as is, or" .tell
    "a space to no longer receive pages in forced format:" .tell
    "%n-Substitutes pager's name." .tell
    "%m-Where the message will be listed." .tell
    "%t-To whom the page was sent." .tell
    "%w-When the page was sent." .tell
    read strip dup "." stringcmp not if pop continue else
      dup " " stringcmp not if
        pop target @ "_page/standard?" remove_prop
        "^GREEN^No longer forcing pages to a standard format." atell else
        target @ swap "_page/stdf" swap setprop
        target @ "_page/standard?" "yes" setprop
        "^GREEN^Now forcing pages to a standard format." atell
      then continue
    then
  then
  msgchoice @ "11" stringcmp not if
    "Enter new @doing message, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
      target @ swap "@doing " swap strcat force
      "^GREEN^@Doing message set." atell
    then continue
  then
  msgchoice @ "h" stringcmp not if
"------------------------------------------------------------" .tell
"- = PlayerConfig by Nakoruru@Dragon/Akari@Distant Shores = -" .tell
"------------------------------------------------------------" .tell
"                       *MESSAGES MENU*                      " .tell
"This menu lets you configure custom messages for programs.  " .tell
"  Teleport depart: What others see in the room you leave.   " .tell
"  Teleport arrive: What others see in the room you arrive in." .tell
"  Look-notify: Message your shown when others look at you.  " .tell
"  Sweep: Message shown when you sweep a room of sleepers.   " .tell
"  Handup message: What people see when you handup a player. " .tell
"  Page Haven: When havened, pagers are shown this message.  " .tell
"  Page Idle: When idle, pagers are shown this message.      " .tell
"  Page Ignore: When ignoring someone, they're shown this.   " .tell
"  Page Sleep: When disconnected, pages are shown this.      " .tell
"  Page Format: Force other player's pages to a specfic format." .tell
"  @Doing: Set your @doing message for the WHO listing.      " .tell
"Type any character and hit enter to continue." .tell
    read pop continue
  then
  msgchoice @ "r" stringcmp not if
    "^BLUE^Returning to the previous menu." atell 0 exit
  then
  msgchoice @ "Q" stringcmp not if
    "^GREEN^Quitting player editor." atell 1 exit
  then
  "^RED^Invalid choice." atell
  repeat
;
lvar advchoice ( Choice for advanced menu )
: Advanced-menu
  begin
  "^PURPLE^Editing: ^WHITE^" target @ unparseobj strcat atell
  target @ "_prefs/con_announce?" getpropstr dup not if
    pop "No" then
  "  [1] Watchfor on: " swap strcat .tell
  target @ "_prefs/trange" getpropstr strip infoSet?
  "  [2] Set your page length for things like BBoard and Tutor: " swap strcat .tell
  target @ "_prefs/logintime?" getpropstr dup not if pop "No" then
  "  [3] Report logged time upon logging in: " swap strcat .tell
  target @ "_meet/off?" getpropstr "yes" stringcmp
  not if "No" else "Yes" then
  "  [4] Allow people to use msummon/mjoin with you: " swap strcat .tell
  target @ SETTING-look_terse getpropstr dup not if pop "No" then
  "  [5] Look tersing on: " swap strcat .tell
  target @ "_prefs/def3who?" getpropstr "yes" stringcmp not if "Yes" else "No" then
  "  [6] Have 'WHO' print in 3who format by default: " swap strcat .tell
  target @ "_throw/receive_ok?" getpropstr dup not if pop "Yes" then
  "  [7] Accepting thrown objects: " swap strcat .tell
  target @ "_prefs/oldpaste" getpropstr "yes" stringcmp not if
    "Old Style @paste" else "LSedit @paste" then
  "  [8] Version of @paste you are using: " swap strcat .tell
  target @ "_prefs/paste_ok" getpropstr "no" stringcmp
  not if "No" else "Yes" then
  "  [9] Allow @pasting to you: " swap strcat .tell
  " " .tell
  "^CYAN^  [^YELLOW^M^CYAN^]essage editor." atell
  "^GREEN^  [^YELLOW^H^GREEN^]elp." atell
  "^PURPLE^  [^YELLOW^R^PURPLE^]eturn to main menu." atell
  "^BLUE^  [^YELLOW^Q^BLUE^]uit the player editor." atell
  read strip advchoice !
  advchoice @ "1" stringcmp not if
    target @ "_prefs/con_announce?" getpropstr dup "yes" stringcmp not if
      target @ "_prefs/con_announce?" remove_prop
      "^GREEN^Watchfor off." atell else
      target @ "_prefs/con_announce?" "yes" setprop
      "^GREEN^Watchfor on." atell
    then continue
  then
  advchoice @ "2" stringcmp not if
    "Enter the number of lines you want displayed at once, or space to clear: " .tell
    read strip target @ swap "_prefs/trange" swap setprop
    "^GREEN^Page length set." atell continue
  then
  advchoice @ "3" stringcmp not if
    target @ "_prefs/logintime?" getpropstr "yes" stringcmp not if
      target @ "_prefs/logintime?" remove_prop
      "^GREEN^You will not be told logged time at login." atell else
      target @ "_prefs/logintime?" "yes" setprop
      "^GREEN^You will be notified of logged time at login." atell
    then
  then
  advchoice @ "4" stringcmp not if
    target @ "_meet/off?" getpropstr "yes" stringcmp not if
      target @ "_meet/off?" remove_prop
      "^GREEN^Allowing people to mjoin/msummon you." atell else
      target @ "_meet/off?" "yes" setprop
      "^GREEN^Disallowing people to mjoin/msummon you." atell
    then continue
  then
  advchoice @ "5" stringcmp not if
    target @ SETTING-look_terse getpropstr "yes" stringcmp not if
      target @ SETTING-look_terse remove_prop
      "^GREEN^Look tersing off." atell else
      target @ SETTING-look_terse "yes" setprop
      "^GREEN^Look tersing on." atell
    then continue
  then
  advchoice @ "6" stringcmp not if
    target @ "_prefs/def3who?" getpropstr "yes" stringcmp not if
      target @ "_prefs/def3who?" remove_prop
      "^GREEN^You will no longer see 3who for your default WHO format." atell else
      target @ "_prefs/def3who?" "yes" setprop
      "^GREEN^You will now see WHO in the 3who format by default." atell
    then continue
  then
  advchoice @ "7" stringcmp not if
    target @ "_throw/receive_ok?" getpropstr "no" stringcmp not if
      target @ "_throw/receive_ok?" remove_prop
      "^GREEN^You will catch thrown objects now." atell else
      target @ "_throw/receive_ok?" "no" setprop
      "^GREEN^You will no longer catch thrown objects." atell
    then continue
  then
  advchoice @ "8" stringcmp not if
    target @ "_prefs/oldpaste" getpropstr "yes" stringcmp not if
      target @ "_prefs/oldpaste" remove_prop
      "^GREEN^Now using: ^YELLOW^ LSedit @paste." atell else
      target @ "_prefs/oldpaste" "yes" setprop
      "^GREEN^Now using: ^YELLOW^ Old style @paste." atell
    then continue
  then
  advchoice @ "9" stringcmp not if
    target @ "_prefs/paste_ok" getpropstr "no" stringcmp not if
      target @ "_prefs/paste_ok" "yes" setprop
      "^GREEN^Now accepting @paste messages." atell else
      target @ "_prefs/paste_ok" "no" setprop
      "^GREEN^Not accepting @paste messages." atell
    then continue
  then
  advchoice @ "h" stringcmp not if
"------------------------------------------------------------" .tell
"- = PlayerConfig by Nakoruru@Dragon/Akari@Distant Shores = -" .tell
"------------------------------------------------------------" .tell
"                        *OPTIONS MENU*                      " .tell
"This menu allows you to toggle different program settings.  " .tell
"  Watchfor:If on, you'll be notifed when people in your wf  " .tell
"           list connect.                                    " .tell
"  TRange: This sets your page length for things like tutor and" .tell
"          BBoard messages.                                    " .tell
"  Logged time notify:Be told of logged time when connecting." .tell
"  ANSI Color: Turn ANSI color on and off.                   " .tell
"  Look terse: Don't see room descs when changing rooms.     " .tell
"  WWF-Block:Keeps people from knowing they're in your wf list." .tell
"  Throw ok:Allows people to throw you objects from other rooms." .tell
"  @paste Version:Toggles which version of @paste you'll use." .tell
"  @paste ok:If off, no one can @paste to you but wizzes.    " .tell
"  Meet off:Will block people from using msummon or mjoin w/you." .tell
"Type any key and hit enter to continue." .tell read pop continue
  then
  advchoice @ "m" stringcmp not if
    message-menu if 1 exit else continue then
  then
  advchoice @ "r" stringcmp not if
    "^BLUE^Returning to main menu." atell 0 exit
  then
  advchoice @ "Q" stringcmp not if
    "^GREEN^Quitting player editor." atell 1 exit
  then
  "^RED^Invalid choice." atell
  repeat
;
lvar oocChoice (Holds OOC menu selections )
: OOC-menu
  begin
  "^PURPLE^Editing: ^WHITE^" target @ unparseobj strcat atell
  "(Note: None of these show in your finger profile unless set.)" .tell
  " " .tell
 FINGER-type not IF
  target @ PROPS-ooc_shortdesc getpropstr infoSet?
  "  [1] OOC ShortDesc: " swap strcat .tell
  target @ PROPS-ooc_misc getpropstr infoSet?
  "  [2] OOC Misc Info: " swap strcat .tell
  target @ PROPS-ooc_full_name getpropstr infoSet?
  "  [3] OOC Full Name: " swap strcat .tell
  target @ PROPS-ooc_location getpropstr infoSet?
  "  [4] OOC Location:  " swap strcat .tell
  target @ PROPS-ooc_gender getpropstr infoSet?
  "  [5] OOC Gender:    " swap strcat .tell
  target @ PROPS-ooc_job getpropstr infoSet?
  "  [6] OOC Job:       " swap strcat .tell
  target @ PROPS-ooc_age getpropstr infoSet?
  "  [7] OOC Age:       " swap strcat .tell
  target @ PROPS-ooc_birthday getpropstr infoSet?
  "  [8] OOC Birthday:  " swap strcat .tell
  target @ PROPS-ooc_height getpropstr infoSet?
  "  [9] OOC Height:    " swap strcat .tell
  target @ PROPS-ooc_weight getpropstr infoSet?
  " [10] OOC Weight:    " swap strcat .tell
 THEN
  target @ PROPS-icq_id getpropstr infoSet?
  " [11] ICQ Number:    " swap strcat .tell
  target @ PROPS-yahoo_id getpropstr infoSet?
  " [12] Yahoo ID:      " swap strcat .tell
  target @ PROPS-webpage getpropstr infoSet?
  " [13] Homepage URL:  " swap strcat .tell
  target @ PROPS-email getpropstr infoSet?
  " [14] EMail Address: " swap strcat .tell
 FINGER-type not IF
  target @ PROPS-ooc_elsemu getpropstr infoSet?
  " [15] Elsemu* Chars: " swap strcat .tell
  target @ SETTING-block_ooc_info? getpropstr "yes" stringcmp not if "Yes" else "No" then
  " [16] Block OOC finger info to normal users? " swap strcat .tell
  " [17] Edit OOC stats: " .tell
  target @ "" swap "/_Info/OOC/Stats/"
( s d p )
  begin
    over swap nextprop dup while
    dup "" "/_Info/OOC/Stats/" subst
    ": " strcat
    3 pick 3 pick getpropstr strcat 78 strcut pop "\r  " swap strcat
    4 rotate swap strcat -3 rotate
  repeat pop pop .tell
 THEN
  " " .tell
  "^GREEN^  [^YELLOW^H^GREEN^]elp." atell
  "^PURPLE^  [^YELLOW^R^PURPLE^]eturn to main menu." atell
  "^BLUE^  [^YELLOW^Q^BLUE^]uit the player editor." atell
  read strip oocchoice !
 FINGER-type not IF
  oocchoice @ "1" stringcmp not if
    "Enter OOC short description, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-ooc_shortdesc swap setprop
    "^GREEN^OOC Short description set." atell continue then
  then
  oocchoice @ "2" stringcmp not if
    "Enter OOC misc info, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-ooc_misc swap setprop
    "^GREEN^OOC Misc info set." atell continue then
  then
  oocchoice @ "3" stringcmp not if
    "Enter OOC full name, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-ooc_full_name swap setprop
    "^GREEN^OOC Name set." atell continue then
  then
  oocchoice @ "4" stringcmp not if
    "Enter OOC location, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-ooc_location swap setprop
    "^GREEN^OOC Location set." atell continue then
  then
  oocchoice @ "5" stringcmp not if
    "Enter OOC gender, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-ooc_gender swap setprop
    "^GREEN^OOC Gender set." atell continue then
  then
  oocchoice @ "6" stringcmp not if
    "Enter OOC job (or, 'Student' if a student), a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-ooc_job swap setprop
    "^GREEN^OOC Job set." atell continue then
  then
  oocchoice @ "7" stringcmp not if
    "Enter OOC age, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-ooc_age swap setprop
    "^GREEN^OOOC Age set." atell continue then
  then
  oocchoice @ "8" stringcmp not if
    "Enter OOC birthday, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-ooc_birthday swap setprop
    "^GREEN^OOC Birthday set." atell continue then
  then
  oocchoice @ "9" stringcmp not if
    "Enter OOC height, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-ooc_height swap setprop
    "^GREEN^OOC Height set." atell continue then
  then
  oocchoice @ "10" stringcmp not if
    "Enter OOC weight, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-ooc_weight swap setprop
    "^GREEN^OOC Weight set." atell continue then
  then
 THEN
  oocchoice @ "11" stringcmp not if
    "Enter ICQ number, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-icq_id swap setprop
    "^GREEN^ICQ number set." atell continue then
  then
  oocchoice @ "12" stringcmp not if
    "Enter Yahoo ID, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-yahoo_id swap setprop
    "^GREEN^Yahoo ID set." atell continue then
  then
  oocchoice @ "13" stringcmp not if
    "Enter home page URL, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-webpage swap setprop
    "^GREEN^Homepage URL set." atell continue then
  then
  oocchoice @ "14" stringcmp not if
    "Enter contact email address, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-email swap setprop
    "^GREEN^Email address set." atell continue then
  then
 FINGER-type not IF
  oocchoice @ "15" stringcmp not if
    "Enter your ElseMU* characters, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-ooc_elsemu swap setprop
    "^GREEN^Elsemu* chracters set." atell continue then
  then
  oocchoice @ "16" stringcmp not if
    target @ SETTING-block_ooc_info? getpropstr "yes" stringcmp not if
      target @ SETTING-block_ooc_info? remove_prop
      "^GREEN^No longer blocking the OOC finger info to normal users." atell else
      target @ SETTING-block_ooc_info? "yes" setprop
      "^GREEN^Now blocking the OOC finger info to normal users." atell
    then continue
  then
  oocchoice @ "17" stringcmp not if
    "Enter the name of the OOC stat to edit or '.' to cancel: " .tell
    target @ read dup "." stringcmp not if pop continue then
    dup ":" instring if pop
      "^RED^OOC Stats cannot have ^YELLOW^: ^RED^ marks in them." atell continue then
    "Enter the info for the OOC stat, or a blank space to remove it: " .tell
    read dup " " stringcmp not if
      pop "/_Info/OOC/Stats/" swap strcat remove_prop else
      swap "/_Info/OOC/Stats/" swap strcat swap setprop
    then
    "^GREEN^OOC Stats updated." atell continue
  then
 THEN
  oocchoice @ "h" stringcmp not if
"------------------------------------------------------------" .tell
"- = PlayerConfig by Nakoruru@Dragon/Akari@Distant Shores = -" .tell
"------------------------------------------------------------" .tell
"                           *OOC MENU*                       " .tell
" This menu is used to set the OOC information fields in your" .tell
" finger profile. Everything in this menu is entirely        " .tell
" optional. Fields that are left blank won't be listed in    " .tell
" your profile.                                              " .tell
"  Shortdesc: Put something short enough to fit in the field in 'ws'." .tell
"  Misc Info: Put whatever else you'd like to add here.      " .tell
"  ICQ #: Put your ICQ ID number here.                       " .tell
"  Picture URL: Put a URL to a picture of your character here." .tell
"  Homepage URL: Put the URL to your homepage here.          " .tell
"  Email: Put your contact email here.                       " .tell
"  Edit stats: Create your own fields to appear in your profile." .tell
"Type any character and press enter to continue.             " .tell
    read pop continue
  then
  oocchoice @ "r" stringcmp not if
    "^BLUE^Returning to main menu." atell 0 exit
  then
  oocchoice @ "Q" stringcmp not if
    "^GREEN^Quitting player editor." atell 1 exit
  then
  "^RED^Invalid choice." atell
  repeat
;
lvar icchoice ( Holds the choice from the menu )
: IC-menu ( -- i ) ( 0 for returning , 1 for quiting )
  begin
  "^PURPLE^Editing: ^WHITE^" target @ unparseobj strcat atell
  " " .tell
  target @ PROPS-shortdesc getpropstr infoSet?
  "  [1] Short Desc:    " swap strcat .tell
  target @ PROPS-misc getpropstr infoSet?
  "  [2] Misc Info:     " swap strcat .tell
  target @ PROPS-full_name getpropstr infoSet?
  "  [3] Full Name:     " swap strcat .tell
  target @ PROPS-gender getpropstr infoSet?
  "  [4] Gender:        " swap strcat .tell
  target @ PROPS-species getpropstr infoSet?
  "  [5] Species:       " swap strcat .tell
  target @ PROPS-series getpropstr infoSet?
  "  [6] Series:        " swap strcat .tell
  target @ PROPS-age getpropstr infoSet?
  "  [7] Age:           " swap strcat .tell
  target @ PROPS-birthday getpropstr infoSet?
  "  [8] Birthday:      " swap strcat .tell
  target @ PROPS-height getpropstr infoSet?
  "  [9] Height:        " swap strcat .tell
  target @ PROPS-weight getpropstr infoSet?
  " [10] Weight:        " swap strcat .tell
  target @ PROPS-class getpropstr infoSet?
  " [11] Class:         " swap strcat .tell
  target @ PROPS-align getpropstr infoSet?
  " [12] Alignment:     " swap strcat .tell
  target @ PROPS-picture_url getpropstr infoSet?
  " [13] Picture URL:   " swap strcat .tell
  " [14] Edit stats: " .tell
  target @ "" swap "/_Info/Stats/"
( s d p )
  begin
    over swap nextprop dup while
    dup "" "/_Info/Stats/" subst
    ": " strcat
    3 pick 3 pick getpropstr strcat 78 strcut pop "\r  " swap strcat
    4 rotate swap strcat -3 rotate
  repeat pop pop .tell
  " " .tell
  "^GREEN^  [^YELLOW^H^GREEN^]elp." atell
  "^PURPLE^  [^YELLOW^R^PURPLE^]eturn to main menu." atell
  "^BLUE^  [^YELLOW^Q^BLUE^]uit the player editor." atell
  read strip icchoice !
  icchoice @ "1" stringcmp not if
    "Enter short description, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-shortdesc swap setprop
    "^GREEN^Short description set." atell continue then
  then
  icchoice @ "2" stringcmp not if
    "Enter misc info, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-misc swap setprop
    "^GREEN^Misc info set." atell continue then
  then
  icchoice @ "3" stringcmp not if
    "Enter full name, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-full_name swap setprop
    "^GREEN^Name set." atell continue then
  then
  icchoice @ "4" stringcmp not if
    "Enter gender, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-gender swap setprop
    "^GREEN^Gender set." atell continue then
  then
  icchoice @ "5" stringcmp not if
    "Enter species, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-species swap setprop
    "^GREEN^Species set." atell continue then
  then
  icchoice @ "6" stringcmp not if
    "Enter series, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-series swap setprop
    "^GREEN^Series set." atell continue then
  then
  icchoice @ "7" stringcmp not if
    "Enter age, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-age swap setprop
    "^GREEN^Age set." atell continue then
  then
  icchoice @ "8" stringcmp not if
    "Enter birthday, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-birthday swap setprop
    "^GREEN^Birthday set." atell continue then
  then
  icchoice @ "9" stringcmp not if
    "Enter height, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-height swap setprop
    "^GREEN^Height set." atell continue then
  then
  icchoice @ "10" stringcmp not if
    "Enter weight, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-weight swap setprop
    "^GREEN^Weight set." atell continue then
  then
  icchoice @ "11" stringcmp not if
    "Enter class, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-class swap setprop
    "^GREEN^Class set." atell continue then
  then
  icchoice @ "12" stringcmp not if
    "Enter alignment, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-align swap setprop
    "^GREEN^Alignment set." atell continue then
  then
  icchoice @ "13" stringcmp not if
    "Enter picture URL, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-picture_url swap setprop
    "^GREEN^Picture URL set." atell continue then
  then
  icchoice @ "14" stringcmp not if
    "Enter the name of the stat to edit or '.' to cancel: " .tell
    target @ read dup "." stringcmp not if pop continue then
    dup ":" instring if pop
      "^RED^Stats cannot have ^YELLOW^: ^RED^ marks in them." atell continue then
    "Enter the info for the stat, or a blank space to remove it: " .tell
    read dup " " stringcmp not if
      pop "/_Info/Stats/" swap strcat remove_prop else
      swap "/_Info/Stats/" swap strcat swap setprop
    then
    "^GREEN^Stats updated." atell continue
  then
  icchoice @ "h" stringcmp not if
"------------------------------------------------------------" .tell
"- = PlayerConfig by Nakoruru@Dragon/Akari@Distant Shores = -" .tell
"------------------------------------------------------------" .tell
"                           *IC MENU*                        " .tell
" This menu is mostly used to set the IC information that    " .tell
" shows up when your finger profile is read.                 " .tell
"  Full name: The full name of your character.               " .tell
"  Gender: Muck programs only recognize male/female/neuter.  " .tell
"  Species: What kind of creature is your character.         " .tell
"  Series: If your character doesn't come from a series, put 'Original.'" .tell
"  Age: The IC age of your character. Can be -real-, or -apparent-." .tell
"  Bday: Won't be displayed in your profile if you enter nothing." .tell
"  Height/Weight: Same as bday.                              " .tell
"  Class: Can be the class, profession, or occupation of your character." .tell
"  Alignment: Can be real or apparent alignment of your character." .tell
"Type any character and hit enter to continue.               " .tell
    read pop continue
  then
  icchoice @ "r" stringcmp not if
    "^BLUE^Returning to main menu." atell 0 exit
  then
  icchoice @ "Q" stringcmp not if
    "^GREEN^Quitting player editor." atell 1 exit
  then
  "^RED^Invalid choice." atell
  repeat
;
lvar lchoice ( stores choices made in live info menu )
lvar page ( stores string for the name of the page to edit )
: liveinfo-menu ( -- i 1 for quit, 0 for continue )
  target @ player? not if
    "^YELLOW^Live Info support is for players only." atell
    0 exit
  then
  begin
  "^PURPLE^Editing: ^WHITE^" target @ unparseobj strcat atell
  " " .tell
  target @ PROPS-webpage getpropstr dup not if pop
    target @ "_/www" getpropstr then infoSet?
  "  [1] Home Page on other server: " swap strcat .tell
  target @ PROPS-picture_url getpropstr infoSet?
  "  [2] Picture for live info page: " swap strcat .tell
  target @ PROPS-web_icon getpropstr infoset?
  "  [3] Icon for web site listings: " swap strcat .tell
  target @ PROPS-web_gallery_pic getpropstr infoset?
  "  [4] Picture for " "muckname" sysparm strcat "'s picture gallery: "
  strcat swap strcat .tell
  target @ SETTING-getwebmail? getpropstr "yes" stringcmp not if
    "Yes" else "No" then
  "  [5] Accept webmail: " swap strcat .tell
  "  [6] Edit your live info page information." .tell
  "  [7] Create or edit a web page in-MUCK." .tell
  "Web pages " "muckname" sysparm strcat " is hosting for you: "
  strcat .tell
  target @ "_/www#" getpropstr if
    "http://" localserver strcat "/~" strcat target @ name strcat .tell
  then
  "_/www/" begin target @ swap nextprop dup while
    dup "/" explode pop pop pop "http://" localserver strcat
    "/~" strcat target @ name strcat "/" strcat
    swap " " "#" subst strcat .tell
  repeat
  " " .tell
  "^GREEN^  [^YELLOW^H^GREEN^]elp." atell
  "^PURPLE^  [^YELLOW^R^PURPLE^]eturn to main menu." atell
  "^BLUE^  [^YELLOW^Q^BLUE^]uit the player editor." atell
  read strip lchoice !
  lchoice @ "1" stringcmp not if
    "Make sure to include -no- spaces." .tell
    "Enter URL for your home page, a space to clear completely, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap "homepage" swap setprop
    "^GREEN^Homepage set." atell continue then
  then
  lchoice @ "2" stringcmp not if
    "Make sure to include -no- spaces." .tell
    "Enter a picture to be displayed on your character's live info page" .tell
    "a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-picture_url swap setprop
    "^GREEN^Live info picture set." atell continue then
  then
  lchoice @ "3" stringcmp not if
    "The picture will be forced to 100 X 100, so edit it to that size" .tell
    "  before hand." .tell
    "Enter a small icon picture to be displayed in the different lists" .tell
    "on the website, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-web_icon swap setprop
    "^GREEN^Web page icon set." atell continue then
  then
  lchoice @ "4" stringcmp not if
    "Remember. Nothing wider than 200 pixels!" .tell
    "Enter the URL to the picture you want in the picture gallery" .tell
    "on the website, a space to clear, or '.' to leave as is: " .tell
    read strip dup "." stringcmp not if pop continue else
    target @ swap PROPS-web_gallery_pic swap setprop
    "^GREEN^Picture gallery picture set." atell continue then
  then
  lchoice @ "5" stringcmp not if
    target @ SETTING-getwebmail? getpropstr "yes" stringcmp not if
      target @ SETTING-getwebmail? remove_prop
      "^GREEN^You will not get webmail." atell continue else
      target @ SETTING-getwebmail? "yes" setprop
      "^GREEN^You will now receive webmail." atell continue
    then
  then
  lchoice @ "6" stringcmp not if
    "<This list is where you enter the text that you want displayed>" .tell
    "<on your 'LiveInfo' page on the " "muckname" sysparm strcat " pages.>"
    strcat .tell
    "<You can look up your live info page at               >" .tell
    "<http://" localserver strcat "/dolookup?user=" strcat
    target @ name strcat " >" strcat .tell
    target @ PROPS-shortinfo_list EDITORprop
  then
  lchoice @ "7" stringcmp not if
    "^YELLOW^Enter the name of the page you want to edit, or " atell
    "^YELLOW^a space to edit your default page." atell
    "^YELLOW^Typing a ! mark before the name (or by itself) will delete" atell
    "^YELLOW^that page." atell
    read dup 1 strcut swap "!" stringcmp not if
      dup strip "" stringcmp not if pop
        target @ "_/www#" remove_prop
        "^RED^Main page deleted." atell continue
      else
        target @ over "_/www/" swap strcat "#" strcat remove_prop
        "^RED^" swap strcat " deleted." strcat atell continue
      then
    else pop then
    dup 1 strcut pop " " stringcmp not if pop "" then
    page !
    "<You can create webpages that will be hosted by the MUCK.   >" .tell
    "<The URL for your webpage will be:                          >" .tell
    "<http://" localserver strcat "/~" strcat target @ name strcat
    "/" strcat page @ strcat " >" strcat .tell
    "<Any graphics will need to be stored elsewhere, but you can>" .tell
    "<do the HTML design you'd like through this editor.        >" .tell
    page @ dup if "_/www/" swap strcat else pop "_/www" then
    target @ swap EDITORprop
  then
  lchoice @ "h" stringcmp not if
"------------------------------------------------------------" .tell
"- = PlayerConfig by Nakoruru@Dragon/Akari@Distant Shores = -" .tell
"------------------------------------------------------------" .tell
" ProtoMUCKs are designed to be able to host websites. This  " .tell
" interface is intended to make that as simple to set up and " .tell
" maintain as possible, giving more players a chance to know " .tell
" about this support, and take advantage of it.              " .tell
" The LiveInfo support is a small page that is generated by  " .tell
" the MUCK to talk about your character, and provide a       " .tell
" picture. The personal WebPage support is intended to allow " .tell
" you to make full featured web page, just like any other.   " .tell
"Live Info menu options:                                     " .tell
" Home page on another server: Putting a URL here will cause " .tell
"   your name and URL to be listed on                        " .tell
"   http://bb6.betterbox.net:1401/webpages                   " .tell
" Live Info picture: This sets a single picture for your     " .tell
"   live info page found at                                  " .tell
"   http://bb6.betterbox.net:1401/dolookup?user=" target @ name
  strcat .tell
" Small Icon: This is an icon shown next to your name on the " .tell
"   different lists. It is -forced- to be 100 X 100, so it is" .tell
"   suggested you resize the picture to that size on your own." .tell
" WebMail - It is possible for people to send you messages from" .tell
"   a website without even being conneted to the MUCK. This    " .tell
"   toggles whether or not you wish to receive those.          " .tell
" Live info editor - To edit the text that shows up on your   " .tell
"   live info screen.                                         " .tell
" MUCK-Hosted web pages - The MUCK will host web pages. This  " .tell
"   editor is designed to allow you to edit the HTML for your " .tell
"   own webpages. The URL for the default will be             " .tell
"   http://bb6.betterbox.net:1401/~" target @ name strcat .tell
"Enter any thing and push enter to continue.                 " .tell
  read pop continue
  then
  lchoice @ "r" stringcmp not if
    "^BLUE^Returning to main menu." atell 0 exit
  then
  lchoice @ "Q" stringcmp not if
    "^GREEN^Quitting player editor." atell 1 exit
  then
  "^RED^Invalid choice." atell
  repeat
;
: print-colors ( -- )
  "^RED^RED           ^CRIMSON^CRIMSON/CRED         ^GREY^^BRED^BRED" atell
  "^GREEN^GREEN         ^FOREST^FOREST/CGREEN        ^GREY^^BGREEN^BGREEN" atell
  "^YELLOW^YELLOW        ^BROWN^BROWN/CYELLOW        ^GREY^^BYELLOW^BYELLOW" atell
  "^BLUE^BLUE          ^NAVY^NAVY/CBLUE           ^GREY^^BBLUE^BBLUE" atell
  "^PURPLE^PURPLE        ^VIOLET^VIOLET/CPURPLE       ^GREY^^BPURPLE^BPURPLE" atell
  "^CYAN^CYAN          ^AQUA^AQUA/CCYAN           ^GREY^^BCYAN^BCYAN^" atell
  "^WHITE^WHITE         ^GREY^GREY/CWHITE          ^GREY^^BWHITE^BWHITE" atell
;
: get-color ( s -- s<tag name>, s<color pref> )
  "_/colors/" swap strcat
  target @ over getpropstr strip dup not if pop
    #0 swap getpropstr strip dup not if pop "NORMAL" then
  else swap pop
  then
  "^%c^" over "%c" subst swap strcat
;
: print-options ( -- )
  var count var middle
  0 array_make var! menu
  target @ "C" flag? if "Yes" else "No" then
  "  ^WHITE^[1] ANSI Color on: " swap strcat addit
  "  ^WHITE^[2] Edit standard colors." addit
  "  ^WHITE^[3] Edit in-server colors." addit
  " " addit
  "^CYAN^Say Program" addit
  "SAY/SAY" get-color
  "  ^WHITE^[4] Spoken text: " swap strcat addit
  "SAY/POSE" get-color
  "  ^WHITE^[5] Posed text: " swap strcat addit
  "SAY/QUOTES" get-color
  "  ^WHITE^[6] Quote marks: " swap strcat addit
  "^CYAN^ComSys Channels System" addit
  "COMSYS/MESG" get-color
  "  ^WHITE^[7] Message text: " swap strcat addit
  "COMSYS/TEXT" get-color
  "  ^WHITE^[8] Posed text: " swap strcat addit
  "COMSYS/QUOTE" get-color
  "  ^WHITE^[9] Quote marks: " swap strcat addit
  "COMSYS/TITLE" get-color
  " ^WHITE^[10] Channel Title: " swap strcat addit
  "COMSYS/BORDER" get-color
  " ^WHITE^[11] Channel title border: " swap strcat addit
  "^CYAN^Whisper Program" addit
  "WHISPER/SAY" get-color
  " ^WHITE^[12] Whisper speach color: " swap strcat addit
  "WHISPER/POSE" get-color
  " ^WHITE^[13] Whisper pose color: " swap strcat addit
  "WHISPER/QUOTE" get-color
  " ^WHITE^[14] Whisper quotes color: " swap strcat addit
  " " addit
  "^CYAN^Mumble Program" addit
  "MUMBLE/SAY" get-color
  " ^WHITE^[15] Mumble speach color: " swap strcat addit
  "MUMBLE/POSE" get-color
  " ^WHITE^[16] Mumble pose color: " swap strcat addit
  "MUMBLE/QUOTE" get-color
  " ^WHITE^[17] Mumble quote color: " swap strcat addit
  "^CYAN^Spoof Program" addit
  "SPOOF/SAY" get-color
  " ^WHITE^[18] Spoof spoken text color: " swap strcat addit
  "SPOOF/QUOTE" get-color
  " ^WHITE^[19] Spoof quote marks color: " swap strcat addit
  "SPOOF/POSE" get-color
  " ^WHITE^[20] Spoof posed text color: " swap strcat addit
  "SPOOF/PARENS" get-color
  " ^WHITE^[21] Spoof parentheses: " swap strcat addit
  "^CYAN^Find Program" addit
  "FIND/FRAME" get-color
  " ^WHITE^[22] Find program table frames: " swap strcat addit
  "FIND/PLAYER" get-color
  " ^WHITE^[23] Find player name color: " swap strcat addit
  "FIND/ROOM" get-color
  " ^WHITE^[24] Find room name color: " swap strcat addit
  "FIND/PARENT" get-color
  " ^WHITE^[25] Find parent name color: " swap strcat addit
  "FIND/TIME" get-color
  " ^WHITE^[26] Find time columns color: " swap strcat addit
  "^CYAN^Finger Program" addit
  "FR/FIELD" get-color
  " ^WHITE^[27] Finger program fields: " swap strcat addit
  "FR/PROP" get-color
  " ^WHITE^[28] Finger program contents: " swap strcat addit
  "^CYAN^Page Program" addit
  "PAGE/TEXT" get-color
  " ^WHITE^[29] Page program format text color: " swap strcat addit
  "PAGE/MESG" get-color
  " ^WHITE^[30] Page program message text color: " swap strcat addit
  menu @ array_count dup count ! 2 / middle !
  0 count @ 2 / 1 - 1 for
    menu @ swap array_getitem
    "                                                        "
    strcat 1 parse_ansi 37 ansi_strcut pop " " strcat
    menu @ middle @ array_getitem strcat atell
    middle ++
  repeat
;
lvar cchoice ( stores choices for color menu )
lvar propcolor ( stores the prop color name )
lvar newcolor ( stores new color setting )
: color-editor ( -- i )
  begin
  "^PURPLE^Editing: ^WHITE^" target @ unparseobj strcat atell
  " " .tell
  print-options
  " " .tell
  "^GREEN^  [^YELLOW^H^GREEN^]elp." atell
  "^PURPLE^  [^YELLOW^R^PURPLE^]eturn to main menu." atell
  "^BLUE^  [^YELLOW^Q^BLUE^]uit the player editor." atell
  read strip cchoice !
  cchoice @ "1" strcmp not if
    target @ "C" flag? if
      target @ "!C" set else
      target @ "C" set then continue
  then
  cchoice @ "2" strcmp not if
    print-colors
    "Above is a list of the colors you can alter. Using this screen, you can" .tell
    "override one of the colors with another one, in case something comes up" .tell
    "too dark or glaring on your moniter, or you just don't like the color. " .tell
    "Type in the following to replace a color with another one, or '.' to exit:" .tell
    "<color to replace>=<color to replace it with>" .tell
    read strip dup "." strcmp not if pop continue then
    "=" explode 2 = not if depth popn continue then propcolor ! newcolor !
    colors-list propcolor @ instring not if continue then
    me @ "_/colors/" propcolor @ strcat newcolor @ setprop continue
  then
  cchoice @ "3" strcmp not if
    print-colors
    "In ProtoMUCK it is possible to change the color you see for the various" .tell
    "in-server messages that you get displayed. Above is a list of the standard" .tell
    "colors to select from. The messages groups you can change are as follows:" .tell
    "  ^SUCC^SUCC  - Messages indicating success, such as prop or flag setting." atell
    "  ^FAIL^FAIL  - Messages indicating failure, such as permission denied." atell
    "  ^INFO^INFO  - Info messages as part of various messages." atell
    "  ^NOTE^NOTE  - Usually bolded information of message output." atell
    "  ^MOVE^MOVE  - Messages displayed when players arrive or connect." atell
    "Type in the following to change one of the inserver messages, or '.' to exit: " .tell
    "<message group>=<new color>" .tell
    read strip dup "." strcmp not if pop continue then
    "=" explode 2 = not if depth popn continue then propcolor ! newcolor !
    "succ|fail|info|note|move" propcolor @ instring not if continue then
    me @ "_/colors/" propcolor @ strcat newcolor @ setprop continue
  then
  cchoice @ "4" strcmp not if
    print-colors
    "This is the color that appears as the spoken text when you use say/pose." .tell
    "It is currently set to: " .tell
    "SAY/SAY" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/say/say" swap setprop continue
  then
  cchoice @ "5" strcmp not if
    print-colors
    "This is the color that appears in the posed text when you use say/pose." .tell
    "It is currently set to: " .tell
    "SAY/POSE" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/say/pose" swap setprop continue
  then
  cchoice @ "6" strcmp not if
    print-colors
    "This is the color that is used for quote marks and other punctuation in say/pose." .tell
    "It is currently set to: " .tell
    "SAY/QUOTES" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/say/quotes" swap setprop continue
  then
  cchoice @ "7" strcmp not if
    print-colors
    "This is the color that is used for spoken text on comsys." .tell
    "It is currently set to: " .tell
    "COMSYS/MESG" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/comsys/mesg" swap setprop continue
  then
  cchoice @ "8" strcmp not if
    print-colors
    "This is the color that is used for posed text on comsys." .tell
    "It is currently set to: " .tell
    "COMSYS/TEXT" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/comsys/text" swap setprop continue
  then
  cchoice @ "9" strcmp not if
    print-colors
    "This is the color that is used for quotemarks on comsys." .tell
    "It is currently set to: " .tell
    "COMSYS/QUOTE" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/comsys/quote" swap setprop continue
  then
  cchoice @ "10" strcmp not if
    print-colors
    "This is the color that is used for the channel title on comsys." .tell
    "It is currently set to: " .tell
    "COMSYS/TITLE" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/comsys/title" swap setprop continue
  then
  cchoice @ "11" strcmp not if
    print-colors
    "This is the color that is used for the brackets around the channel title on comsys." .tell
    "It is currently set to: " .tell
    "COMSYS/BORDER" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/comsys/border" swap setprop continue
  then
  cchoice @ "12" strcmp not if
    print-colors
    "This is the color for whispered text. Currently set to: " .tell
    "WHISPER/SAY" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/whisper/say" swap setprop continue
  then
  cchoice @ "13" strcmp not if
    print-colors
    "This is the color for posed text in whispers. Currently: " .tell
    "WHISPER/POSE" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/whisper/pose" swap setprop continue
  then
  cchoice @ "14" strcmp not if
    print-colors
    "This is the color for quote marks in your whisper. Currently: " .tell
    "WHISPER/QUOTE" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/whisper/quote" swap setprop continue
  then
  cchoice @ "15" strcmp not if
    print-colors
    "This is the color for spoken text in your mumbles. Currently: " .tell
    "MUMBLE/SAY" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/mumble/say" swap setprop continue
  then
  cchoice @ "16" strcmp not if
    print-colors
    "This is the color for posed text in your mumbles. Currently: " .tell
    "MUMBLE/POSE" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/mumble/pose" swap setprop continue
  then
  cchoice @ "17" strcmp not if
    print-colors
    "This is the color for quotes in your mumbles. Currently: " .tell
    "MUMBLE/QUOTE" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ Swap "_/colors/mumble/quote" swap setprop continue
  then
  cchoice @ "18" strcmp not if
    print-colors
    "This is the color for text between quotes in spoofs. Currently: " .tell
    "SPOOF/SAY" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/spoof/text" swap setprop continue
  then
  cchoice @ "19" strcmp not if
    print-colors
    "This is the color for the quote marks in spoofs. Currently: " .tell
    "SPOOF/QUOTE" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/spoof/quote" swap setprop continue
  then
  cchoice @ "20" strcmp not if
    print-colors
    "This is the color for the posed text in spoofs. Currently: " .tell
    "SPOOF/POSE" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/spoof/pose" swap setprop continue
  then
  cchoice @ "21" strcmp not if
    print-colors
    "This is the color for the parentheses that sometimes are arounds poofs. Currently: " .tell
    "SPOOF/PARENS" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/spoof/parens" swap setprop continue
  then
  cchoice @ "22" strcmp not if
    print-colors
    "This is the color for the tables and frames of the find program. Currently: " .tell
    "FIND/FRAME" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/find/frame" swap setprop continue
  then
  cchoice @ "23" strcmp not if
    print-colors
    "This is the color for the player names in find. Currently: " .tell
    "FIND/PLAYER" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/find/player" swap setprop continue
  then
  cchoice @ "24" strcmp not if
    print-colors
    "This is the color for the room names in find. Currently: " .tell
    "FIND/ROOM" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/find/room" swap setprop continue
  then
  cchoice @ "25" strcmp not if
    print-colors
    "This is the color for the parent rooms in find. Currently: " .tell
    "FIND/PLAYER" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/find/parent" swap setprop continue
  then
  cchoice @ "26" strcmp not if
    print-colors
    "This is the color for the time columns in find. Currently: " .tell
    "FIND/PLAYER" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/find/time" swap setprop continue
  then
  cchoice @ "27" strcmp not if
    print-colors
    "This is the color for the field names in finger. Currently: " .tell
    "FR/FIELD" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/fr/field" swap setprop continue
  then
  cchoice @ "28" strcmp not if
    print-colors
    "This is the color for the time columns in find. Currently: " .tell
    "FR/PROP" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/fr/prop" swap setprop continue
  then
  cchoice @ "29" strcmp not if
    print-colors
    "This is the color for the format text in pages you receive. Currently: " .tell
    "PAGE/TEXT" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/page/text" swap setprop continue
  then
  cchoice @ "30" strcmp not if
    print-colors
    "This is the color for the message text in pages you recieve. Currently: " .tell
    "PAGE/MESG" get-color atell
    "Enter '.' to cancel, a space to clear your own preference, or a new color: " .tell
    read strip dup "." strcmp not if pop continue then
    me @ swap "_/colors/page/mesg" swap setprop continue
  then
  cchoice @ "h" stringcmp not if
    "Welcome to @colors! A revolutionary idea made possible by the ProtoMUCK team" .tell
    "that allows you to pick the colors that you see when using the MUCK, rather" .tell
    "than having them forced on you by the code writters themselves. We realize" .tell
    "everyone's tastes are different, and as such, we've gone out of our way to" .tell
    "give you every possible chance to customize your custom ANSI preferences. If" .tell
    "you think of other programs you would like to see include custom color support" .tell
    "simply let us know!   -Akari and Moose                                     " .tell
    "^FOREST^Type any key and hit enter to continue." atell
    read pop continue
  then
  cchoice @ "r" stringcmp not if 0 exit then
  cchoice @ "q" stringcmp not if "^BLUE^Quitting editor." atell 1 exit then
  "^RED^Invalid choice." atell
  repeat
;
lvar mchoice ( stores choices made for main menu )
: main-menu
  "^GRAY^Welcome to " "muckname" sysparm strcat
  "'s Player Editor" strcat atell
  begin
    "Currently editing: ^YELLOW^" target @ unparseobj  strcat atell
    "^GRAY^Choose from the following options: " atell
    " " .tell
    " [^YELLOW^I^NORMAL^]C Menu" atell
    " [^YELLOW^O^NORMAL^]OC Menu" atell
custom-color if
    " [^YELLOW^C^NORMAL^]olor preferences menu" atell
then
    " [^YELLOW^T^NORMAL^]oggle Options Menu" atell
    " [^YELLOW^M^NORMAL^]essages Menu" atell
include_websupport? if
    " [^YELLOW^W^NORMAL^]eb Support Editor" atell
then
find-prog if
    " [^YELLOW^F^NORMAL^]ind program settings" atell
then
say-prog if
    " [^YELLOW^S^NORMAL^]ay program settings" atell
then
last-prog if
    " [^YELLOW^L^NORMAL^]aston program settings" atell
then
    " [^YELLOW^H^NORMAL^]elp" atell
    " " .tell
    "^BLUE^ [^YELLOW^Q^BLUE^]uit Player Editor" atell
    read mchoice !
    mchoice @ "i" stringcmp not if ic-menu if exit then continue then
    mchoice @ "o" stringcmp not if ooc-menu if exit then continue then
    mchoice @ "t" stringcmp not if advanced-menu if exit then continue then
    mchoice @ "m" stringcmp not if message-menu if exit then continue then
say-prog if
    mchoice @ "s" stringcmp not if say-prog match "player-config" call exit then
then
find-prog if
    mchoice @ "f" stringcmp not if find-prog match "do-options" call exit then
then
last-prog if
    mchoice @ "l" stringcmp not if target @ last-prog match "laston-custom" call exit then
then
custom-color if
    mchoice @ "c" stringcmp not if color-editor if exit then continue then
then
include_websupport? if
    mchoice @ "w" stringcmp not if liveinfo-menu if exit then continue then
then
    mchoice @ "h" stringcmp not if
"------------------------------------------------------------" .tell
"- = PlayerConfig by Nakoruru@Dragon/Akari@Distant Shores = -" .tell
"------------------------------------------------------------" .tell
" This program is intended to make it easy to set up your    " .tell
" character, both in terms of designing your finger profile  " .tell
" contents, as well as configuring how some of the programs  " .tell
" on the MUCK interact with your character.                  " .tell
"                                                            " .tell
"Main Menu Options:                                          " .tell
"  The IC menu allows you to change IC information.          " .tell
"  The OOC menu is for OOC finger information.               " .tell
"  The toggle options menu is for game configurations.       " .tell
"  The messages menu is to set custom messages for programs. " .tell
include_websupport? if
"  To edit web site information for your character.          " .tell
then
"Enter any thing and push enter to continue.                 " .tell
  read pop continue
    then
    mchoice @ "q" stringcmp not if
      "^GREEN^Finished editing character." atell exit
    then
    "^RED^Invalid option." atell
  repeat
;
: get-target ( s -- i ) ( Puts dbref# in target variable, 1=found,0=no match )
 ( s coming in can be a dbref#, player, puppet )
  dup "" stringcmp not if pop me @ target ! 1 exit then
  dup pmatch dup if
    swap pop me @ "WIZARD" flag? if
      target ! 1 exit else
      "^YELLOW^Can't edit other players!" atell 0 exit
    then else pop
  then
  dup puppet_match dup ok? if swap pop
    dup me @ swap controls if target ! 1 exit
      else "^RED^You do not own " swap strcat "." strcat atell 0 exit
    then
  else pop then
  dup "#" stringpfx if
    str_to_dbref else
    match
  then
  dup ok? if
    dup me @ swap controls if
      dup "Z" flag? if
        target ! 1 exit
      else
        "^RED^" swap name strcat " is not a player or puppet."
        strcat atell 0 exit
      then
    else "^RED^You do not control " swap name strcat "." strcat
    atell 0 exit
    then
  then
  pop "^YELLOW^Could not find that." atell 0
;
: main
  me @ "G" flag? if "Not for guests. Get a character! ^^" .tell exit then
  strip get-target not if exit then
  command @ "@colors" stringcmp not if color-editor if exit then then
  main-menu
;
