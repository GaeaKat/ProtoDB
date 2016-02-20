( @ports config by Akari                                                     )
(            Nakoruru08@hotmail.com                                          )
(                                                                            )
( Version 1.0 - Started 08/19/2002                                           )
( Just a tool to help configuring and checking @ports settings.              )
 
$include $lib/strings
$author Akari
$version 1.0
 
$def atell me @ swap ansi_notify
lvar portsArray
lvar tcount
lvar wcount
lvar pcount
lvar mcount
lvar acount
$def TYPE_TELNET 0
$def TYPE_WWW    1
$def TYPE_PUEBLO 2
$def TYPE_MUF    3
 
: port-idle[ str:PortNum -- str:PortIdle ]
  (** Returns the max connection idle for telnet and pueblo ports **)
    #0 "@ports/" portNum @ strcat "/Idle" strcat getpropval
    dup not if pop
        "connidle" sysparm
    else atoi
    then
;
 
: port-type[ str:PortNum -- str:Typename ]
  (**Returns the port type string **)
    portNum @ int? not if
        #0 "@ports/" PortNum @ strcat "/Type" strcat getpropval
    else portNum @
    then
    dup TYPE_MUF    = if pop "MUF Port" exit then
    dup TYPE_WWW    = if pop "Pueblo Port" exit then
    dup TYPE_PUEBLO = if pop "Web Port" exit then
    dup TYPE_TELNET = if pop "Telnet Port" exit then
    pop "Unknown Type"
;
 
: do-list-ports ( -- )
  (** Simply prints a list of expected open ports and their settings **)
  var curPort var curType
    "^WHITE^" "muckname" sysparm strcat
    " ^NORMAL^Connection Ports:" strcat atell
    "^BLUE^--------------------------------------------------------------" atell
    "^GREEN^" "Port #" 15 StrLeft strcat
    "Port Type" 30 StrLeft strcat
    "Idle Time(s) or Dbref#" strcat atell
    ( First handle the built in default 3 in @tune )
    "^GREEN^" "mainport" sysparm 15 STRLeft strcat
    "^FOREST^Telnet Port  ^VIOLET^(@tune)" 30 Neon_Left strcat
    tcount ++ acount ++
    "^FOREST^" "connidle" sysparm 25 STRLeft strcat strcat atell
    "wwwport" sysparm dup atoi 1 > if
        "^GREEN^" swap 15 STRLeft strcat
        "^FOREST^Web Port     ^VIOLET^(@tune)" 30 Neon_left strcat
        "^BROWN^" "---------" 25 STRLeft strcat strcat atell
        wcount ++ acount ++
    else
        "^CRIMSON^" "-----" 15 STRLeft strcat
        "^BROWN^Web Port     ^CRIMSON^(Disabled)" 30 Neon_Left strcat atell
    then
    "puebloport" sysparm dup atoi  1 > if
        "^GREEN^" swap 15 STRLeft strcat
        "^FOREST^Pueblo Port  ^VIOLET^(@tune)" 30 Neon_Left strcat
        "^FOREST^" "connidle" sysparm 25 STRLeft strcat strcat atell
        pcount ++ acount ++
    else
        "^CRIMSON^" "-----" 15 STRLeft strcat
        "^BROWN^Pueblo Port  ^CRIMSON^(Disabled)" 30 Neon_Left strcat
        atell
    then
    ( Then handle the @ports on #0 list )
    #0 "@ports/" array_get_propdirs foreach swap pop curPort !
        "^GREEN^" curPort @ 15 STRLeft strcat
        curPort @ port-type dup curType !
        dup "Unknown" instring if "^RED^" else "^FOREST^" then
        swap 30 STRLeft strcat strcat
        curType @ dup "telnet" instring swap "pueblo" instring or if
            curPort @ port-idle dup if
                "^FOREST^" swap strcat strcat
            else
                "^BROWN^---------" strcat
            then atell curType @ if pcount ++ else tcount ++ then acount ++
        else curType @ "web" instring if
            "^BROWN^---------" strcat atell wcount ++
        else curType @ "MUF" instring if
            #0 "@ports/" curPort @ strcat "/MUF" strcat getprop
            dup dbref? if "^FOREST^" swap unparseobj strcat strcat
            else pop then atell mcount ++ acount ++
        else atell
        then then then
    repeat
    "^YELLOW^~Done~" atell
;
 
: type-number ( str:typename -- int:num )
    dup "telnet" instring if pop TYPE_TELNET exit then
    dup "web" instring if pop TYPE_WWW exit then
    dup "pueblo" instring if pop TYPE_PUEBLO exit then
    dup "muf" instring if pop TYPE_MUF exit then
    pop -1
;
 
: do-setup ( s -- )
  var curPort var curType var curOther
    " " split swap pop dup number? if curPort !
    else "^FOREST^Enter the port number to configure: " atell
        read strip dup number? not if pop
            "^YELLOW^Not a valid port." atell exit then
        dup atoi 1 < if pop
            "^YELLOW^Not a valid port." atell exit then
        curPort !
    then
    "^AQUA^Editing ^CYAN^" curPort @ strcat atell
    "^FOREST^What type of port is this to be? (telnet/web/pueblo/muf)" atell
    read strip type-number dup 0 < if pop
        "^YELLOW^Unknown type." atell exit
    then dup curType !
    #0 swap "@ports/" curPort @ strcat "/Type" strcat swap setprop
    curType @ TYPE_TELNET = curType @ TYPE_PUEBLO = or if
        "^FOREST^Enter the time in seconds a connection can idle on login, or"
        atell
        "^FOREST^a space to leave the @tuned default of " "connidle" sysparm
        strcat ":" strcat atell
        read dup number? if
            dup atoi 0 > if
                #0 over "@ports/" curPort @ strcat "/idle" strcat swap setprop
                curOther !
            else pop "connidle" sysparm curOther !
            then
        else pop "connidle" sysparm curOther !
        then
        "^FOREST^A ^GREEN^" curType @ port-type strcat
        " ^FOREST^on port ^GREEN^" curPort @ strcat strcat
        " ^FOREST^has been added with a con-idle of ^GREEN^" curOther @ strcat
        strcat "^FOREST^." strcat atell exit
    then
    curType @ TYPE_WWW = if
        "^FOREST^A ^GREEN^Web Port ^FOREST^has been added on port ^GREEN^"
        curPort @ strcat "^FOREST^." strcat atell exit
    then
    curType @ TYPE_MUF = if
        "^FOREST^Enter the dbref of the MUF program this port should call"
        "when a connection comes in: " strcat atell
        read strip stod dup program? if dup unparseobj curOther !
            #0 swap "@ports/" curPort @ strcat "/MUF" strcat swap setprop
            "^FOREST^A ^GREEN^MUF Port ^FOREST^has been added on port ^GREEN^"
            curPort @ strcat " ^FOREST^that calls ^GREEN^" strcat
            curOther @ strcat "^FOREST^." strcat atell
        else
            "^YELLOW^Not a valid program dbref#." atell
        then exit
    then
    ( default )
    "^BROWN^This port type on port ^YELLOW^" curPort @ strcat atell
    " ^BROWN^is not known. It will default to being a normal telnet port." atell
;
 
: do-help ( -- )
    "^BLUE^~~~~~~~~~~~~~~~~~~" atell
    "^WHITE^@ports setup" atell
    "^BLUE^~~~~~~~~~~~~~~~~~~" atell
    " " .tell
    " This is just a basic tool to take away some of the " .tell
    " hassle in setting up @ports support so that you    " .tell
    " don't have to remember what props to set and what  " .tell
    " numbers mean what.                                 " .tell
    " It -only- reflects the settings on your MUCK       " .tell
    " according to what @tunes and props you have set.   " .tell
    " It does -not- know if the ports are actually open  " .tell
    " or not. " .tell
    " " .tell
    "The commands are simply: " .tell
    "  @ports - By itself it lists current settings.     " .tell
    "  @ports #setup # - To configure that port #.        " .tell
    "^YELLOW^~Done~" atell
;
 
: main ( s -- )
    me @ "WIZARD" flag? not if
        "^CRIMSON^Permission denied." atell exit then
    strip dup not if pop do-list-ports exit then
    dup "#help" stringpfx if pop do-help exit then
    dup "#setup" stringpfx over "#config" stringpfx or if
        do-setup exit then
    pop do-help
 
;
