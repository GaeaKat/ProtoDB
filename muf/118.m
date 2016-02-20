( ProtoTimeLog 3.3 by Akari                                           )
(                Nakoruru08@hotmail.com                               )
( Version 1.0  - Completed 09/07/1999                                 )
( Version 2.0  - Completed 03/16/2000                                 )
( Version 3.0  - Completed 04/01/2001                                 )
( Version 3.1  - Completed 04/15/2001                                 )
( Version 3.2  - Completed 04/17/2001                                 )
( Version 3.3  - Completed 05/12/2001                                 )
(                                                                     )
( Based on my original @TimeLog code, ProtoTimeLog is the 3rd version )
( of @TimeLog that I have completed. New in this version is ANSI color)
( as well as a lot of history tracking additions to the code. There is)
( also some library functions that can be called from other programs  )
( in order to retrieve a player's logged time for various periods. And)
( finally, there are some library time-related functions made         )
( available as well. Requires ProtoMUCK 1.6 or newer.                 )
(                                                                     )
( Version 3.1  - Fixed typo, allowed admin to force login reports.    )
( Version 3.2  - Added #connects for ranking # of connections.        )
(                Added total # of connects to @tl report.             )
( Version 3.3  - Added #age for ranking oldest characters.            )
(                                                                     )
( Install: Simply attach an action called @TimeLog;@tl;T20 to the code)
(          and set calls to it in the _connect/ and _disconnect queues)
(          on #0. The program must be set LINK_OK.                    )
(          Register as $lib/timelog.                                  )
(          You can optionally set this program as your cron_prog in   )
(          @tune. All this does is increase the accuracy of what time )
(          period the time is actually logged in. The totals will be  )
(          as accurate, either way, but this increases accuracy of    )
(          smaller units of time, such as 'days'. A cron_interval of  )
(          one hour should be sufficient.                             )
(                                                                     )
( Library like functions so far:                                      )
( PUBLIC:                                                             )
( number-to-month ( s<number> -- s<Month> )                           )
(     Takes a string number between 1 and 12 and returns Month name.  )
(     Will abort on invalid number being passed.                      )
( month-to-number ( s<month> -- s<number> )                           )
(     Matches the month to the first unique month it will match to.   )
(     I.e, ja will match Janurary, S will match September, Jun June.  )
(     Returns "00" when no match is found.                            )
( maketime ( si mi hi di mi yi -- systime )                           )
(     Given the 6 time parameters, returns the systime that represents)
(     that time.                                                      )
(                                                                     )
( WIZCALL:                                                            )
( month-total ( d<player> i<month> -- time )                          )
(     Given player dbref, and a number between 1 and 12, returns that )
(     player's total time logged in for that month.                   )
( week-total ( d<player> i<week> -- time )                            )
(     Given player dbref, and number between 1 and 4, returns that    )
(     player's total time logged in for that week.                    )
( day-total ( d<player> s<number> -- time )                           )
(     Given player dbref and number between 1 and seven, returns that )
(     player's given time for that day this week. 1 = Sun, 7 = Sat    )
( player-total ( d<player> -- time )                                  )
(     Total time logged in for that player.                           )
( month-history ( d<player> -- dict )                                 )
(     Index 0 = current month, 1 = last month, 2 = 2 months ago       )
( week-history ( d<player> -- dict )                                  )
(     Index 1 = current week, 2 = last week, etc...                   )
( day-history ( d<player> -- dict )                                   )
(     Index 1 = Sunday, Index 2 = Monday... Index 7 = Saturday        )
( update-loggedtime ( -- )                                            )
(     This function should be called before using any of the logged   )
(     time retriving functions in order to update the records to be   )
(     current.                                                        )
$version 3.3
( ** Program $Includes ** )
$include $lib/time            ( Mostly for ParseTime )
$include $lib/strings         ( Mostly for STRCenter )
( ** Preference $Defs ** )
$def logDir "@loggedtime/" ( If replacing older @tl, set to '@loggedtime/' )
$def allowT20 20  ( Set top # of players for non-wiz use of #top. 0 to ban non-wiz using #top )
( $def force-report 1 ) ( Uncomment this to force login reports. )
( ** Program $Defs ** )
$def popall depth popn
$def atell me @ dup "PUEBLO" flag? if swap remove-ansi swap then swap ansi_notify
$def addit dup @ rot + swap !
$ifdef timefmt
    $undef timefmt
    $def timefmt \timefmt
$endif
( ** Formatting and helper functions and Library Functions ** )
: remove-ansi ( s -- s' )
  ( ** Removes ANSI for Pueblo users. Forget trying to fix it to like them. :P ** )
  1 parse_ansi ansi_strip
;
: time-format-hy ( i<time> -- s<# years # days> )
  ( ** Returns time in # years # days format, no matter what time is passed. ** )
  var curTime
  "" curtime !
  dup 31535999 > if
  dup 31536000 / dup intostr swap 1 = if " year " else " years " then strcat curtime !
    31536000 %
  else
    "0 years " curtime !
  then
  dup 86399 > if
  dup 86400 / intostr 3 .right " days " strcat curtime @ swap strcat curtime !
    86400 %
  else
    curtime @ "  0 days " strcat curtime !
  then pop
  curtime @ stripspaces
;
: time-format-hours ( i<time> -- s<#hours #minutes #seconds> )
  ( ** Returns hours, minutes, seconds, depending on time passed ** )
  "" var! timeStr
  dup 3600 / dup if dup 1 > if " hours " else " hour " then
    swap intostr swap strcat timeStr @ swap strcat timeStr ! else pop then
  dup 3600 % 60 / dup if dup 1 > if " minutes " else " minute " then
    swap intostr swap strcat timeStr @ swap strCat timeStr ! else pop then
  dup 3600 % 60 % dup if dup 1 > if " seconds " else " second " then
    swap intostr swap strcat timeStr @ swap strCat timeStr ! else pop then
  pop timeStr @ strip dup
  " " explode dup 2 > if popn
    " " rsplit swap " " rsplit swap " and " strcat
    swap strcat " " strcat swap strcat
  else popn
  then
;
: time-format-years ( i<time> -- s<#years #days #minutes #seconds )
  ( ** Returns years, days, hours, minutes, seconds, depending on time. ** )
  "" var! timeStr
  dup 31536000 / dup if dup 1 > if " years " else " year " then
    swap intostr swap strcat timeStr @ swap strcat timeStr ! else pop then
  dup 31536000 % 86400 / dup if dup 1 > if " days " else " day " then
    swap intostr swap strcat timeStr @ swap strcat timeStr ! else pop then
  dup 31536000 % 86400 % 3600 / dup if dup 1 > if " hours " else " hour " then
    swap intostr swap strcat timeStr @ swap strcat timeStr ! else pop then
  dup 31536000 % 86400 % 3600 % 60 / dup if dup 1 > if " minutes " else " minute " then
    swap intostr swap strcat timeStr @ swap strCat timeStr ! else pop then
  dup 31536000 % 86400 % 3600 % 60 % dup if dup 1 > if " seconds " else " second " then
    swap intostr swap strcat timeStr @ swap strCat timeStr ! else pop then
  pop timeStr @ strip dup
  " " explode dup 2 > if popn
    " " rsplit swap " " rsplit swap " and " strcat
    swap strcat " " strcat swap strcat
  else popn
  then
;
: average-time ( i<seconds> i<connections/days> -- i<average time> )
  ( ** Calculate the mean of time over a given number ** )
  dup 0 = if pop pop 0 exit then
  /
;
: number-to-month ( s<number> -- s<Month> )
  ( ** Given a string number between 1 and 12, returns the month name ** )
  dup int? if intostr then
  dup strlen 2 < if "0" swap strcat then
  dup atoi dup 1 < swap 12 > or
  if popall "" exit then
  {
  "01" "January"   "02" "Feburary" "03" "March"     "04" "April"
  "05" "May"        "06" "June"     "07" "July"      "08" "Auguest"
  "09" "September"  "10" "October"  "11" "November"  "12" "December"
  } 2 /
  array_make_dict swap array_getitem
;
: month-to-number ( s<month> -- s<number> )
  ( ** Return the numerical value for the month passed. ** )
  strip dup not if pop "00" exit then
  dup 1 strcut pop case
    "a" stringcmp not when
      dup 2 strcut pop 1 strcut swap pop case
         "p" stringcmp not when pop "04" exit end
         "u" stringcmp not when pop "08" exit end
        default pop pop "00" exit end
      endcase
    end
    "d" stringcmp not when pop "12" exit end
    "f" stringcmp not when pop "02" exit end
    "j" stringcmp not when
      dup 2 strcut pop 1 strcut swap pop case
        "a" stringcmp not when pop "01" exit end
        "u" stringcmp not when
          dup 3 strcut pop 2 strcut swap pop case
            "l" stringcmp not when pop "07" exit end
            "n" stringcmp not when pop "06" exit end
            default pop pop "00" exit end
          endcase
        end
        default pop pop "00" exit end
      endcase
    end
    "m" stringcmp not when
      dup 3 strcut pop 2 strcut swap pop case
        "r" stringcmp not when pop "03" exit end
        "y" stringcmp not when pop "05" exit end
        default pop pop "00" exit end
      endcase
    end
    "n" stringcmp not when pop "11" exit end
    "o" stringcmp not when pop "10" exit end
    "s" stringcmp not when pop "09" exit end
    default pop pop "00" exit end
  endcase
;
: maketime (s1 m1 h1 d1 m1 y1 -- time)
  ( ** Given the 6 time parameters, returns the systime that represents it ** )
  1970 - 12 * +
  systime dup timesplit pop pop
  1970 - 12 * + -7 rotate pop pop pop pop
  (s1 m1 h1 d1 my2 my1 time)
  begin
    3 pick 3 pick = not while
    3 pick 3 pick - 86400 28 * * -
    3 rotate pop dup timesplit pop pop 1970 - 12 * + -7 rotate pop pop pop pop
  repeat
  -3 rotate pop pop
  (s1 m1 h1 d1 time)
  dup timesplit pop pop pop pop
  86400 * swap 3600 * + swap 60 * + + - -5 rotate
  86400 * swap 3600 * + swap 60 * + + +
;
: month-total ( d<player> s<month number> -- i<logged time> )
  ( ** Return the time logged for that player in that month ** )
  dup int? if intostr then
  logDir swap dup strlen 2 < if "0" swap strcat then
  dup atoi dup 1 < swap 12 > or
  if popall "Invalid month value passed to month-total." abort then
  strcat getpropval
;
: week-total ( d<player> s<week number> -- i<time> )
  ( ** Return time logged for that player in the given week back ** )
  dup int? if intostr then
  logDir "weeks/" strcat swap strcat getpropval
;
: day-total ( d<player> s<day number> -- i<time> )
  ( ** Return time logged by that player this week ** )
  dup int? if intostr then
  dup atoi dup 1 < swap 7 > or
  if popall "Invalid day number passed to day-total" abort then
  logDir "days/" strcat swap strcat getpropval
;
: player-total ( d<player> -- i<time> )
  ( ** Total time logged in by that player. ** )
  logDir "total" strcat getpropval
;
: month-history ( d<player> -- dict )
  ( ** Returns a dictionary. Index '0' is current month. Index 1 is last month, etc. )
  var! target
  0 array_make_dict var! history
  target @ logDir "%m" systime timefmt strcat getpropval
  history @ 0 array_setitem history !
  target @ logDir "%m" systime timefmt atoi 1 - dup
  0 = if pop 12 then intostr dup strlen 2 < if "0" swap strcat then
  strcat getpropval
  history @ 1 array_setitem history !
  target @ logDir "%m" systime timefmt atoi 2 - dup
  0 = if pop 12
  else dup 0 < if pop 11 then
  then intostr dup strlen 2 < if "0" swap strcat then strcat getpropval
  history @ 2 array_setitem
;
: week-history ( d -- dict )
  ( ** Returns dictionary. Index '0' is current week '1' is last week, etc... )
  var! target var curWeek
  0 array_make_dict var! history
  1 4 1 for curWeek !
    target @ logDir "weeks/" curWeek @ intostr strcat strcat getpropval
    history @ curWeek @ array_setitem history !
  repeat
  history @
;
: day-history ( d -- dict )
  ( ** Returns dictionary. Index '0' is Sunday, '1' is Monday, etc... )
  var! target var curDay
  0 array_make_dict var! history
  1 7 1 for curDay !
    target @ logDir "days/" curDay @ intostr strcat strcat getpropval
    history @ curDay @ array_setitem history !
  repeat
  history @
;
: get-sort-data ( s<prop to use> -- arr<sorted key values> dict<times and players>)
  (** Given the prop to read from, returns:
      arr  - List array where the values are time logged in seconds
      dict - Dict where the keys are time in seconds and values are player dbrefs
   ** )
  var! searchProp
  0 array_make var! sortData
  0 array_make_dict var! realData
  #0 begin nextplayer dup player? while
    dup dup searchProp @ getpropval dup not if pop pop continue then
    dup sortData @ array_appenditem sortData !
    realData @ swap array_setitem realData !
  repeat pop
  sortData @ 2 array_sort realData @
;
: get-connects-data ( i -- arr<sorted by key values> dict<times and players> )
   ( **  i = 0 connects; i = 1 created date
         Returns arr - List array where the values are # of connects.
                dict - Where the keys are connects and values are dbrefs
   ** )
  var! mode
  0 array_make var! sortData var curCon
  0 array_make_dict var! realData
  #0 begin nextplayer dup player? while
    mode @ not if
      dup dup timestamps dup not if 4 popn continue then
      curCon ! 3 popn
    else
      dup dup timestamps 3 popn systime swap -
      dup not if pop continue then
      curCon !
    then
    curCon @ sortData @ array_appenditem sortData !
    realData @ curCon @ array_setitem realData !
  repeat pop
  sortData @ 2 array_sort realData @
;
( ** Record Keeping Functions ** )
: check-records ( d<player> -- )
  ( ** This function updates the history tracking props ** )
  var! target var newWeek var curWeek var oldDay
  target @ logDir "lastmonth" strcat getpropval
  dup not if pop ( Doesn't have it set. Set one. )
    target @ logDir "lastmonth" strcat "%m" systime timefmt atoi setprop
  else
    "%m" systime timefmt atoi = not if ( Not same month. Time to update. )
      target @ logDir "%m" systime timefmt strcat remove_prop
      target @ logDir "connects/%m" systime timefmt strcat remove_prop
      target @ logDir "lastmonth" strcat "%m" atoi setprop
    then
  then
  target @ logDir "lastday" strcat getpropval dup oldDay !
  dup not if pop ( Doesn't have last day set. Set one. )
    target @ logDir "lastday" strcat "%j" systime timefmt atoi setprop
    target @ logDir "lastWDay" strcat "%w" systime timefmt atoi 1 + setprop
  else
    "%j" systime timefmt atoi swap - dup 0 = not if ( New day. Time to update. )
      7 >
      target @ logDir "lastWDay" strcat getpropval
      "%w" systime timefmt atoi 1 + >= or if ( New week too. Clear days )
        1 newWeek !
        target @ logDir "days" strcat remove_prop
      else ( Same week, just clear the one day to be safe )
        target @ logDir "days/" strcat
        "%w" systime timefmt atoi 1 + intostr strcat remove_prop
      then
      target @ logDir "lastDay" strcat "%j" systime timefmt atoi setprop
      target @ logDir "lastWDay" strcat "%w" systime timefmt atoi 1 + setprop
    else pop then
  then
  newWeek @ if ( new day of a new week. Update weeks history )
    oldDay @ "%j" systime timefmt atoi swap - 7  / 0 -1 for pop
      4 0 -1 for curWeek !
        target @ logDir "weeks/" curWeek @ 1 - intostr strcat strcat getpropval
        target @ swap logDir "weeks/" curWeek @ intostr strcat strcat swap setprop
      repeat
    repeat
    target @ logDir "weeks/1" strcat remove_prop
  then
;
: update-times ( d<player> -- )
  ( ** This function adds the new logged time after check-records updates ** )
  var! target var newInc
  target @ check-records
  target @ "@/logintime" getpropval dup not if pop
    target @ awake? if target @ "@/logintime" systime setprop then
    exit
  then
  systime swap - newInc !
  target @ "%m" systime timefmt month-total newInc @ +
  target @ swap logDir "%m" strcat systime timefmt swap setprop
  target @ player-total newInc @ +
  target @ swap logDir "total" strcat swap setprop
  target @ "1" week-total newInc @ +
  target @ swap logDir "weeks/1" strcat swap setprop
  target @ "%w" systime timefmt atoi 1 + intostr day-total newInc @ +
  target @ Swap logDir "days/" strcat "%w" systime timefmt atoi 1 + intostr strcat
  swap setprop
  target @ "@/logintime" systime setprop
;
: update-loggedtime ( -- )
  ( ** Update the current time as well as the history for all players. ** )
  #0 begin nextplayer dup player? while
    dup awake? if dup update-times else dup check-records then
  repeat pop
;
( ** Reporting Functions ** )
: report-total ( s -- )
  ( ** Get own total or total of another player for wizards. ** )
  var target
  me @ "WIZARD" flag? not if
    pop me @ target !
  else
    "" "#total" subst strip dup not if pop me @ target !
    else pmatch dup player? not if
        "^YELLOW^Could not find that player." atell exit
      then
    target !
    then
  then
  target @ player-total if
    target @ me @ dbcmp if
      "^FOREST^You have logged ^AQUA^"
    else
      "^FOREST^" target @ unparseobj strcat " has logged ^AQUA^" strcat
    then
    target @ player-total time-format-years strcat
    " ^FOREST^on ^GREEN^" strcat "muckname" sysparm strcat "^FOREST^." strcat
    atell
  else
    target @ me @ dbcmp if
      "^BROWN^You have never logged any time on ^YELLOW^" "muckname" sysparm strcat
      " ^BROWN^... which begs the question: how ARE you seeing this?!" strcat atell
    else
      "^BROWN^" target @ name strcat " has never logged into ^YELLOW^" strcat
      "muckname" sysparm strcat "^BROWN^." strcat atell
    then
  then
;
: report-month ( s -- )
  ( ** Report on a specific month for self, or other player for wizards. ** )
  var target var monthNum
  "=" " " subst
  dup "=" instr if "=" split monthNum !
  else monthNum ! ""
  then
  me @ "WIZARD" flag? not if
    pop me @ target !
  else
    "" "#total" subst strip dup not if pop me @ target !
    else pmatch dup player? not if
        "^YELLOW^Could not find that player." atell exit
      then
    target !
    then
  then
  monthNum @ number? not if
    monthNum @ month-to-number dup "00" strcmp not if pop
      "^YELLOW^Not a valid month." atell exit then
    monthNum !
  then
  monthNum @ atoi dup 1 < swap 12 > or if
    "^YELLOW^Not a valid month." atell exit then
  target @ monthNum @ month-total dup if
    target @ me @ dbcmp if
      "^FOREST^You were connected for ^VIOLET^"
    else
      "^FOREST^" target @ unparseobj strcat " was connected for ^VIOLET^" strcat
    then
    target @ monthNum @ month-total time-format-hours strcat
    " ^FOREST^in ^GREEN^" strcat monthNum @ number-to-month strcat "^FOREST^." strcat atell
  else
    target @ me @ dbcmp if
      "^BROWN^You have no online time recorded for ^YELLOW^"
    else
      "^BROWN^" target @ unparseobj strcat " has no online time recorded for ^YELLOW^" strcat
    then
    monthNum @ number-to-month strcat "^BROWN^." strcat atell
  then
;
: report-year ( s -- )
  ( ** Print out all 12 months, with averages ** )
  var target var lastMonth var curMonth var curTime var curCons
  "" "#year" subst strip
  me @ "WIZARD" flag? not if
    pop me @ target !
  else
    "" "#total" subst strip dup not if pop me @ target !
    else pmatch dup player? not if
        "^YELLOW^Could not find that player." atell exit
      then
    target !
    then
  then
  "^AQUA^" target @ name strcat "'s Year Summary for ^CYAN^" strcat
  "muckname" sysparm strcat atell
  " ^FOREST^Month         ^VIOLET^Time                ^BROWN^# Connections   ^AQUA^Average Connection"
  atell
  "^BLUE^---------------------------------------------------------------------------" atell
  target @ logDir "lastmonth" strcat getpropval lastMonth !
  1 12 1 for dup curMonth !
    dup 10 < if intostr "0" swap strcat else intostr then
    target @ over logDir swap strcat getpropval dup if curTime !
      target @ swap logDir "connects/" strcat swap strcat getpropval curCons !
      lastMonth @ curMonth @ < if "^CRIMSON^*" else " " then
      "^GREEN^" strcat curMonth @ intostr number-to-month "^RED^:   ^PURPLE^" strcat strcat
      "          " strcat 1 parse_ansi 15 ansi_strcut pop
      -8 curTime @ parsetime dup strlen 15 swap - "     " swap strcut pop swap strcat
      "                   " strcat 19 strcut pop strcat
      "^YELLOW^" strcat
      curCons @ intostr 17 STRcenter strcat "^CYAN^" strcat
      curTime @ curCons @ average-time
      -8 swap parsetime dup strlen 15 swap - "     " swap strcut pop swap strcat
      strcat atell
    else
      " ^YELLOW^" curMonth @ intostr number-to-month "^PURPLE^:   ^RED^" strcat strcat
      "         " strcat 1 parse_ansi 15 ansi_strcut pop
      "*No time logged*" strcat atell
    then
  repeat
  "^BLUE^---------------------------------------------------------------------------" atell
  target @ me @ dbcmp if "^FOREST^You have logged a total of ^VIOLET^"
  else "^FOREST^" target @ name strcat " has logged a total of ^VIOLET^" strcat
  then
  target @ player-total time-format-years strcat
  " ^FOREST^on ^GREEN^" strcat "muckname" sysparm strcat "^FOREST^." strcat atell
;
: report-connects ( s -- )
  ( ** For reporting rankings of connections ** )
  var topMany var sortedArr var dataArr
  var curRank var curConnects var curPlayer var total
  allowT20 not me @ "WIZARD" flag? not and if
    "^CRIMSON^Permission denied." atell exit then
  "" "#connects" subst strip dup number? if atoi topMany ! else pop then
  topMany @ not if 20 topMany ! then
  me @ "WIZARD" flag? not if allowT20 topMany ! then
  0 get-connects-data dataArr ! sortedArr !
  "^CYAN^" "muckname" sysparm strcat " ^AQUA^Top ^YELLOW^" strcat
  topMany @ intostr strcat " ^AQUA^Number of Connectios" strcat atell
  " ^RED^Rank  ^YELLOW^Connections       ^GREEN^Name" atell
  "^BLUE^------------------------------------------" atell
  0 topMany @ 1 - 1 for dup curRank !
    sortedArr @ swap array_getitem dup not if pop break then dup total @ + total !
    dataArr @ over array_getitem curPlayer ! curConnects !
    curRank @ 1 + intostr ") " strcat 5 STRright "^CRIMSON^" swap strcat
    "^BROWN^" strcat curConnects @ intostr 10 STRright strcat
    "   ^WHITE^-   ^FOREST^" strcat curPlayer @ name strcat atell
  repeat
  "^BLUE^------------------------------------------" atell
  "^FOREST^TOTAL: ^GREEN^" total @ intostr strcat " ^FOREST^connections." strcat atell
;
: report-age ( s -- )
  ( ** For reporting rankings of character age ** )
  var topMany var sortedArr var dataArr
  var curRank var curAge var curPlayer
  allowT20 not me @ "WIZARD" flag? not and if
    "^CRIMSON^Permission denied." atell exit then
  "" "#age" subst strip dup number? if atoi topMany ! else pop then
  topMany @ not if 20 topMany ! then
  me @ "WIZARD" flag? not if allowT20 topMany ! then
  1 get-connects-data dataArr ! sortedArr !
  "^CYAN^" "muckname" sysparm strcat " ^AQUA^Top ^YELLOW^" strcat
  topMany @ intostr strcat " ^AQUA^Rankings of Age" strcat atell
  " ^RED^Rank              ^YELLOW^Age   ^GREEN^Name" atell
  "^BLUE^------------------------------------------" atell
  0 topMany @ 1 - 1 for dup curRank !
    sortedArr @ swap array_getitem dup not if pop break then
    dataArr @ over array_getitem curPlayer ! curAge !
    curRank @ 1 + intostr ") " strcat 5 STRright "^CRIMSON^" swap strcat
    "^BROWN^" strcat curAge @ time-format-hy 20 STRright strcat
    "   ^WHITE^-   ^FOREST^" strcat curPlayer @ name strcat atell
  repeat
  "^BLUE^------------------------------------------" atell
  "^FOREST^~Done~" atell
;
: report-tops ( s -- )
  (** For reporting Top # of logged in times. ** )
  var topMany var whatPeriod var sortedArr var dataArr
  var curRank var curTime var curPlayer var total
  allowT20 not me @ "WIZARD" flag? not and if
    "^CRIMSON^Permission denied." atell exit then
  "" "#top" subst strip "=" " " subst
  dup "=" instring if "=" split atoi topMany ! strip then
  dup if
    dup number? not if
      month-to-number dup "00" stringcmp not if
        "^YELLOW^Invalid month entered." atell exit then then
    atoi dup 0 < over 12 > or if
      "^YELLOW^Invalid month entered." atell exit then
    whatPeriod !
  then
  topMany @ not if 20 topMany ! then
  me @ "WIZARD" flag? not if allowT20 topMany ! then
  whatPeriod @ dup not if pop "total"
  else intostr dup strlen 2 < if "0" swap strcat then
  then logDir swap strcat get-sort-data dataArr ! sortedArr !
  "^CYAN^" "muckname" sysparm strcat " ^AQUA^Top ^YELLOW^" strcat
  topMany @ intostr strcat " ^AQUA^Login times" strcat
  whatPeriod @ if " for ^CYAN^" strcat whatPeriod @ number-to-month strcat then
  atell
  " ^RED^Rank          ^YELLOW^Total Time       ^WHITE^Seconds   ^GREEN^Name" atell
  "^BLUE^--------------------------------------------------------" atell
  0 topMany @ 1 - 1 for dup curRank !
    sortedArr @ swap array_getitem dup not if break then dup total @ + total !
    dataArr @ over array_getitem curPlayer ! curTime !
    curRank @ 1 + intostr ") " strcat 5 STRright "^CRIMSON^" swap strcat
    "^BROWN^" strcat
    -8 curTime @ parsetime dup strlen 20 swap - "         " swap strcut pop swap strcat strcat
    " ^WHITE^( ^NORMAL^" strcat curTime @ intostr 10 STRright
    "s" strcat strcat " ^WHITE^) ^FOREST^" strcat
    curPlayer @ name strcat atell
  repeat
  "^BLUE^--------------------------------------------------------" atell
  "^FOREST^TOTAL: ^GREEN^" 4 total @ parsetime strcat "^FOREST^." strcat atell
;
: get-parameters ( d<player> -- dict<paramters for report> )
  ( ** Collects all of the needed data for the new TimeLog Report ** )
  var! target 0 array_make_dict var! parameters var age var uses
  var weekTotal var monthTotal var curMonth var createTime
  target @ unparseobj parameters @ "NAME" array_setitem parameters !
  target @ timestamps uses ! 2 popn dup createTime !
  "%a %b %e, %Y at %r" swap timefmt parameters @ "CREATED" array_setitem parameters !
  systime createTime @ - dup age !
  time-format-hy parameters @ "AGE" array_setitem parameters !
  target @ logDir "days/2" strcat getpropval dup
  if -9 swap parsetime dup strlen 13 swap - "      " swap strcut pop swap strcat
  else pop "*No Time*" then
  parameters @ "MONDAY" array_setitem parameters !
  target @ logDir "days/3" strcat getpropval dup
  if -9 swap parsetime dup strlen 13 swap - "      " swap strcut pop swap strcat
  else pop "*No Time*" then
  parameters @ "TUESDAY" array_setitem parameters !
  target @ logDir "days/4" strcat getpropval dup
  if -9 swap parsetime dup strlen 13 swap - "      " swap strcut pop swap strcat
  else pop "*No Time*" then
  parameters @ "WEDNESDAY" array_setitem parameters !
  target @ logDir "days/5" strcat getpropval dup
  if -9 swap parsetime dup strlen 13 swap - "      " swap strcut pop swap strcat
  else pop "*No Time*" then
  parameters @ "THURSDAY" array_setitem parameters !
  target @ logDir "days/6" strcat getpropval dup
  if -9 swap parsetime dup strlen 13 swap - "      " swap strcut pop swap strcat
  else pop "*No Time*" then
  parameters @ "FRIDAY" array_setitem parameters !
  target @ logDir "days/7" strcat getpropval dup
  if -9 swap parsetime dup strlen 13 swap - "      " swap strcut pop swap strcat
  else pop "*No Time*" then
  parameters @ "SATURDAY" array_setitem parameters !
  target @ logDir "days/1" strcat getpropval dup
  if -9 swap parsetime dup strlen 13 swap - "      " swap strcut pop swap strcat
  else pop "*No Time*" then
  parameters @ "SUNDAY" array_setitem parameters !
  target @ logDir "weeks/1" strcat getpropval dup dup weekTotal addit
  if -8 swap parsetime
  else pop "*No Time*" then
  parameters @ "DAYT" array_setitem parameters !
  target @ logDir "weeks/2" strcat getpropval dup dup weekTotal addit
  if -8 swap parsetime dup strlen 15 swap - "      " swap strcut pop swap strcat
  else pop "*No Time*" then
  parameters @ "WEEK2" array_setitem parameters !
  target @ logDir "weeks/3" strcat getpropval dup dup weekTotal addit
  if -8 swap parsetime dup strlen 15 swap - "      " swap strcut pop swap strcat
  else pop "*No Time*" then
  parameters @ "WEEK3" array_setitem parameters !
  target @ logDir "weeks/4" strcat getpropval dup dup weekTotal addit
  if -8 swap parsetime dup strlen 15 swap - "      " swap strcut pop swap strcat
  else pop "*No Time*" then   parameters @ "WEEK4" array_setitem parameters !
  weekTotal @ dup
  if -8 swap parsetime dup strlen 15 swap - "      " swap strcut pop swap strcat
  else pop "*No Time*" then
  parameters @ "WEEKT" array_setitem parameters !
  target @ logDir "%m" systime timefmt dup curMonth !
  strcat getpropval dup monthTotal addit dup not if
    pop "*No Time*"
  else
    -8 swap parsetime dup strlen 15 swap - "      " swap strcut pop swap strcat
    "(" target @ logDir "connects/" curMonth @ strcat strcat getpropval intostr strcat ")" strcat
    13 STRcenter strcat
  then
  parameters @ "MONTH1" array_setitem parameters !
  target @ logDir "%m" systime timefmt atoi 1 -
  dup 0 = if pop 12 then intostr dup strlen 2 < if "0" swap strcat then
  dup curMonth ! strcat getpropval dup monthTotal addit
  dup not if
    pop "*No Time*"
  else
    -8 swap parsetime dup strlen 15 swap - "      " swap strcut pop swap strcat
    "(" target @ logDir "connects/" curMonth @ strcat strcat getpropval intostr strcat ")" strcat
    13 STRcenter strcat
  then
  parameters @ "MONTH2" array_setitem parameters !
  target @ logDir "%m" systime timefmt atoi 2 -
  dup 0 = if pop 12 else dup 0 < if pop 11 then then intostr
  dup strlen 2 < if "0" swap strcat then
  dup curMonth ! strcat getpropval
  dup monthTotal addit
  dup not if
    pop "*No Time*"
  else
    -8 swap parsetime dup strlen 15 swap - "      " swap strcut pop swap strcat
    "(" target @ logDir "connects/" curMonth @ strcat strcat getpropval intostr strcat ")" strcat
    13 STRcenter strcat
  then
  parameters @ "MONTH3" array_setitem parameters !
  monthTotal @ dup not if
    pop "*No Time*"
  else
    -8 swap parsetime dup strlen 15 swap - "      " swap strcut pop swap strcat
  then
  parameters @ "MONTHT" array_setitem parameters !
  target @ player-total dup
  if -7 swap parsetime else pop "*No Time*" then
  parameters @ "TOTAL" array_setitem parameters !
  target @ player-total uses @ average-time dup
  if -7 swap parsetime dup "h" instring not
    if "    " swap strcat
    else dup "h" split pop strlen 2 < if "0" swap strcat then
    then
  else pop "*No Time*" then
  parameters @ "AVERAGE" array_setitem parameters !
  target @ player-total age @ 86400 / average-time dup
  if -7 swap parsetime dup "h" instring not
    if "    " swap strcat
    else dup "h" split pop strlen 2 < if "0" swap strcat then
    then
  else pop "*No Time*" then
  parameters @ "DAVERAGE" array_setitem parameters !
  target @ timestamps intostr " connections" strcat
  parameters @ "TCONNECTS" array_setitem parameters ! 3 popn
  parameters @
;
: report-fullreport ( s -- )
  ( ** Prints out the new TimeLog Report format ** )
  var target var paramArray
  me @ "WIZARD" flag? not if pop me @ target !
  else dup not if pop me @ target ! else pmatch dup player? not if
    "^YELLOW^Could not find that player." atell exit else target ! then
  then then
  target @ get-parameters paramArray !
  "^BLUE^+----------------------------------------------------------------------------+"
  atell
  "^BLUE^| ^FOREST^Name^BROWN^: ^GREEN^"
  paramArray @ "NAME" array_getitem
  "                                            " strcat 27 strcut pop strcat
  " ^FOREST^Created^BROWN^: ^GREEN^" strcat paramArray @ "CREATED" array_getitem strcat
  "        " strcat 1 parse_ansi 77 ansi_strcut pop "^BLUE^|" strcat atell
  "^BLUE^|                                   ^FOREST^Age^BROWN^: ^GREEN^"
  paramArray @ "AGE" array_getitem strcat
  "                                          " strcat
  1 parse_ansi 77 ansi_strcut pop "^BLUE^|" strcat atell
  "^BLUE^|                                                                            |"
  atell
  "^BLUE^| ^WHITE^Current Week's Stats:                  Past 3 Weeks:                       ^BLUE^|"
  atell
  "^BLUE^| ^AQUA^Sunday^BROWN^:" "              " strcat 1 parse_ansi 13 ansi_strcut pop
  "^YELLOW^" strcat paramArray @ "SUNDAY" array_getitem
  "                             " strcat 28 strcut pop strcat
  "^VIOLET^Week 1^BROWN^: ^AQUA^" strcat
  paramArray @ "WEEK2" array_getitem strcat
  "                                  " strcat 1 parse_ansi 77 ansi_strcut pop
  "^BLUE^|" strcat atell
  "^BLUE^| ^AQUA^Monday^BROWN^:" "              " strcat 1 parse_ansi 13 ansi_strcut pop
  "^YELLOW^" strcat paramArray @ "MONDAY" array_getitem
  "                             " strcat 28 strcut pop strcat
  "^VIOLET^Week 2^BROWN^: ^AQUA^" strcat
  paramArray @ "WEEK3" array_getitem strcat
  "                                  " strcat 1 parse_ansi 77 ansi_strcut pop
  "^BLUE^|" strcat atell
  "^BLUE^| ^AQUA^Tuesday^BROWN^:" "              " strcat 1 parse_ansi 13 ansi_strcut pop
  "^YELLOW^" strcat paramArray @ "TUESDAY" array_getitem
  "                             " strcat 28 strcut pop strcat
  "^VIOLET^Week 3^BROWN^: ^AQUA^" strcat
  paramArray @ "WEEK4" array_getitem strcat
  "                                  " strcat 1 parse_ansi 77 ansi_strcut pop
  "^BLUE^|" strcat atell
  "^BLUE^| ^AQUA^Wednesday^BROWN^:" "              " strcat 1 parse_ansi 13 ansi_strcut pop
  "^YELLOW^" strcat paramArray @ "WEDNESDAY" array_getitem
  "                             " strcat 28 strcut pop strcat
  "^PURPLE^4 Week Total^BROWN^: ^CYAN^" strcat
  paramArray @ "WEEKT" array_getitem strcat
  "                                  " strcat 1 parse_ansi 77 ansi_strcut pop
  "^BLUE^|" strcat atell
  "^BLUE^| ^AQUA^Thursday^BROWN^:" "              " strcat 1 parse_ansi 13 ansi_strcut pop
  "^YELLOW^" strcat paramArray @ "THURSDAY" array_getitem
  "                                                                    " strcat strcat
  1 parse_ansi 77 ansi_strcut pop "^BLUE^|" strcat atell
  "^BLUE^| ^AQUA^Friday^BROWN^:" "              " strcat 1 parse_ansi 13 ansi_strcut pop
  "^YELLOW^" strcat paramArray @ "FRIDAY" array_getitem
  "                             " strcat 25 strcut pop strcat
  "^WHITE^Total for last 3 months:^YELLOW^(# of connects)^BLUE^|" strcat atell
  "^BLUE^| ^AQUA^Saturday^BROWN^:" "              " strcat 1 parse_ansi 13 ansi_strcut pop
  "^YELLOW^" strcat paramArray @ "SATURDAY" array_getitem
  "                             " strcat 25 strcut pop strcat
  "^NAVY^" "%m" systime timefmt number-to-month "^CRIMSON^: ^BROWN^" strcat strcat
  "                " strcat 1 parse_ansi 11 ansi_strcut pop strcat
  paramArray @ "MONTH1" array_getitem strcat "                    " strcat
  1 parse_ansi 77 ansi_strcut pop "^BLUE^|" strcat atell
  "^BLUE^| ^CYAN^Total^BROWN^:" "              " strcat 1 parse_ansi 12 ansi_strcut pop
  "^GREEN^" strcat paramArray @ "DAYT" array_getitem
  "                                 " strcat 26 strcut pop strcat
  "^NAVY^" "%m" systime timefmt atoi 1 - dup 0 = if pop 12 then intostr
  number-to-month "^CRIMSON^: ^BROWN^" strcat strcat "             " strcat
  1 parse_ansi 11 ansi_strcut pop strcat
  paramArray @ "MONTH2" array_getitem strcat "                    " strcat
  1 parse_ansi 77 ansi_strcut pop "^BLUE^|" strcat atell
  "^BLUE^|                                     "
  "^NAVY^" "%m" systime timefmt atoi 2 -
  dup 0 = if pop 12
  else dup 0 < if pop 11 then
  then intostr number-to-month "^CRIMSON^: ^BROWN^" strcat strcat
  "             " strcat 1 parse_ansi 11 ansi_strcut pop strcat
  paramArray @ "MONTH3" array_getitem strcat "                    " strcat
  1 parse_ansi 77 ansi_strcut pop "^BLUE^|" strcat atell
  "^BLUE^|                                     "
  "^BLUE^Total^CRIMSON^:     ^YELLOW^"
  paramArray @ "MONTHT" array_getitem strcat
  "                                  " strcat strcat 1 parse_ansi 77 ansi_strcut
  pop "^BLUE^|" strcat atell
  "^BLUE^|                                                                            |"
  atell
  "^BLUE^| ^GREEN^TOTAL: ^PURPLE^"
  paramArray @ "TOTAL" array_getitem strcat
  "                                                   " strcat 1 parse_ansi 38 ansi_strcut pop
  "^WHITE^Averages: ^CYAN^" strcat
  paramArray @ "AVERAGE" array_getitem strcat " per connection" strcat
  "                         " strcat 1 parse_ansi 77 ansi_strcut pop "^BLUE^|" strcat atell
  "^BLUE^|        ^PURPLE^"
  paramArray @ "TCONNECTS" array_getitem strcat
  "                                               " strcat 1 parse_ansi 48 ansi_strcut pop
  "^CYAN^" strcat
  paramArray @ "DAVERAGE" array_getitem strcat " per day" strcat
  "                          " strcat 1 parse_ansi 77 ansi_strcut pop "^BLUE^|" strcat atell
  "^BLUE^+----------------------------------------------------------------------------+"
  atell
;
: report-current ( s -- )
  ( ** Used for the login-display ** )
  me @ "%m" systime timefmt month-total dup 0 = if pop
    "^YELLOW^## ^BROWN^You have not yet logged any time this month." atell
  else
    "^YELLOW^## ^BROWN^You have connected for ^VIOLET^" swap time-format-hours
    strcat " ^BROWN^this month." strcat atell
  then
;
( ** Connection Functions ** )
: player-logout ( -- )
( ** Update all the props when the player logs out! ** )
  me @ ok? not if exit then me @ awake? if exit then
  me @ update-times
;
: player-login ( -- )
  ( ** Set new login time and display current month's standings ** )
  me @ awake? 1 = not if exit then
  me @ check-records
  me @ "@/logintime" systime setprop
  me @ logdir "connects/" strcat "%m" systime timefmt strcat
  dup rot swap getpropval ++
  me @ rot rot setprop
$ifndef force-report
  me @ "_prefs/logintime?" getpropstr
  "yes" stringcmp not if
$endif
    report-current
$ifndef force-report
  then
$endif
;
: do-help ( -- )
"^BLUE^-----------------------------------------------------------------------" atell
"- = ProtoTimeLOG 3.2 by Akari = -" 71 STRcenter atell
"^BLUE^-----------------------------------------------------------------------" atell
" TimeLog records the time players spent logged into the MUCK. A history is  " .tell
"   kept of the last 12 months, the last 4 weeks, and the days of the current" .tell
"   week. It also has a lot of time-logging related library functions that   " .tell
"   other programs can call.                                                 " .tell
"                                                                            " .tell
" @tl          - Shows your connection stats report.                         " .tell
" @tl #total   - Print out your total time logged.                           " .tell
" @tl #year    - Print out your logged time over the last twelve months.     " .tell
" @tl <month>  - Report your time logged in for that month.                  " .tell
allowT20 if
" @tl #top     - Print out the top " allowT20 intostr strcat " ranked players."
  strcat .tell
" @tl #top <month> - Print out the top " allowT20 intostr strcat " for that month."
  strcat .tell
" @tl #connects - Print out a ranking of the top connected players.          " .tell
" @tl #age      - Print out a ranking of the top oldest players.             " .tell
then
" @set me=_prefs/logintime?:yes - Reports monthly total upon login.         " .tell
me @ "WIZARD" flag? if
"^WHITE^*Wizard Tools*" 71 STRcenter atell
" @tl <player>         - Print out that player's connection stats.           " .tell
" @tl #total <player>  - Print out that player's total connected time.       " .tell
" @tl #year <player>   - Print out that player's yearly stats.               " .tell
allowT20 not if
" @tl #top             - Print out top 20 ranked players.                    " .tell
" @tl #top <month>     - Print out top 20 players for that month.            " .tell
then
" @tl #top =<#>        - Print out top # ranked players.                     " .tell
" @tl #top <month>=<#> - Print out top # players for that month.             " .tell
" @tl #connects <#>    - Print out top ranking players with # of connections." .tell
" @tl #age <#>         - Print out the top # of oldest players.              " .tell
then
"^YELLOW^~Done~" atell
;
: main ( s -- )
  ( ** Our Main. Sends us to the appropriate sub-function. ** )
  background
  command @ "Queued event." stringcmp not if
    dup "Connect" stringcmp not if pop player-login exit then
    dup "Disconnect" stringcmp not if pop player-logout exit then
    pop exit
  then strip tolower
  trig #-4 dbcmp if ( Optional Cron support )
    update-loggedtime exit
  then
  update-loggedtime
  command @ "T20" stringcmp not if pop "#top" then
  me @ player? not if me @ owner me ! then
  dup not if report-fullreport exit then
  dup "#help" stringpfx if do-help exit then
  dup "#top" stringpfx if report-tops exit then
  dup "#connects" stringpfx if report-connects exit then
  dup "#age" stringpfx if report-age exit then
  dup "#total" stringpfx if report-total exit then
  dup "#year" stringpfx if report-year exit then
  dup me @ "WIZARD" flag? if
    "=" " " subst dup "=" instr if report-month exit then
    dup number? if report-month exit then
    report-fullreport exit
  else
    report-month exit
  then
;
PUBLIC number-to-month
PUBLIC month-to-number
PUBLIC maketime
WIZCALL month-total
WIZCALL week-total
WIZCALL day-total
WIZCALL player-total
WIZCALL month-history
WIZCALL week-history
WIZCALL day-history
WIZCALL update-loggedtime
