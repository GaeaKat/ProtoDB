( cmd-SystemStats by Akari                                        )
(                  Nakoruru08@hotmail.com                         )
( A nifty replacement for the traditional Uptime command.         )
( Requires ProtoMUCK 1.70 or newer.                               )
( 1.00: Initial release by Akari                                  )
( 1.01: [Moose] Just added 'Done', thats it.                      )
$def atell me @ swap ansi_notify
$author Akari
$version 1.01
: time-format-years ( i<time> -- s<#years #days #minutes #seconds )
  ( ** Returns years, days, hours, minutes, seconds, depending on time. ** )
  "" var! timeStr
  dup 31536000 / dup if dup 1 > if " years " else " year " then
    swap intostr swap strcat timeStr @ swap strcat timeStr ! else pop then
  dup 31536000 % 86400 / dup if dup 1 > if " days " else " day " then
    swap intostr swap strcat timeStr @ swap strcat timeStr ! else pop then
  dup 31536000 % 86400 % 3600 / dup if dup 1 > if " hours " else " hour " then
    swap intostr swap strcat timeStr @ swap strcat timeStr ! else pop then
  dup 31536000 % 86400 % 3600 % 60 / dup if dup 1 > if " minutes " else
  " minute " then
    swap intostr swap strcat timeStr @ swap strCat timeStr ! else pop then
  dup 31536000 % 86400 % 3600 % 60 % dup if dup 1 > if " seconds " else
  " second " then
    swap intostr swap strcat timeStr @ swap strCat timeStr ! else pop then
  pop timeStr @ strip dup
  " " explode dup 2 > if popn
    " " rsplit swap " " rsplit swap " and " strcat
    swap strcat " " strcat swap strcat
  else popn
  then
;
: get-uptime ( -- s s )
    var curTime
    #0 "~sys/startuptime" getpropval dup not if pop "" "" exit then curTime !
    "      ^FOREST^Uptime: ^GREEN^" systime curTime @ - time-format-years strcat
    "       ^FOREST^Since: ^GREEN^" "%a %b %e ^FOREST^at ^GREEN^%k:%M %p"
    curtime @
    timefmt strcat swap
;
: get-downtime ( -- s s )
    var curTime
    #0 "~sys/shutdowntime" getpropval dup not if pop "" "" exit then curTime !
    "^BROWN^Shutdown for: ^YELLOW^" #0 "~sys/startuptime" getpropval
    curTime @ - time-format-years strcat
    "          ^BROWN^On: ^YELLOW^"
    "%a %b %e ^BROWN^at ^YELLOW^%k:%M %p" curtime @ timefmt strcat swap
;
: get-save ( -- s )
    #0 "~sys/lastdumptime" getpropval dup not if pop "" exit then
    "%a %b %e ^VIOLET^at ^PURPLE^%k:%M %p" swap timefmt
    "   ^VIOLET^Last Save: ^PURPLE^" swap strcat
;
: get-archive ( -- s )
    "auto_archive" sysparm "yes" stringcmp if "" exit then
    #0 "~sys/lastarchive" getpropval dup not if pop "" exit then
    "%a %b %e ^VIOLET^at ^PURPLE^%k:%M %p" swap timefmt
    "^VIOLET^Last Archive: ^PURPLE^" swap strcat
;
: get-concount ( -- s )
    #0 "~sys/concount" getpropval dup not if pop "" exit then
    " ^AQUA^Connections: ^CYAN^" swap intostr strcat
;
: get-usage ( -- s )
    "     ^CRIMSON^Traffic: ^RED^" bandwidth var! commands
    + 1000 / var! traffic
    traffic @ 100000 < if
        traffic @ intostr " Kbytes" strcat
    else
        traffic @ 1000 / intostr " Mbytes" strcat
    then
    " ^CRIMSON^over ^RED^" commands @ intostr strcat
    " commands^CRIMSON^." strcat strcat strcat
;
: main ( s -- )
    pop
    "^GREEN^" "muckname" sysparm strcat " ^FOREST^System Stats" strcat atell
    "^BLUE^--------------------------------------------------------------" atell
    get-uptime dup not if pop pop else atell atell then
    get-downtime dup not if pop pop else atell atell then
    get-save atell
    get-archive atell
    get-concount atell
    get-usage atell
    "^CINFO^Done." atell
;
