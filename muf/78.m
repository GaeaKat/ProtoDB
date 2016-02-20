(*
   LIB-time.MUF v1.0.4
   Author: Chris Brine [Moose/Van]
 
   Version 1.04 [Moose]
     - Removed the custom timezone support.  Didn't work too well.
   Version 1.03 [Akari] 09/05/2001
     - Cleaned formatting to 80 colums. Added new directives.
 
   Functions [All but SETzone are M1 or above]:
     DOWNtime[ -- int:INTtime ]
      * Gets the system time for when the MUCK last shutdown/restarted
     STARTtime[ -- int:INTtime ]
      * Gets the system time for when the MUCK last started up
     DUMPtime[ -- int:INTtime ]
      * Gets the system time for the last database dump that occured
     NEXTdump[ -- int:INTtime ]
      * Gets the system time for the next database dump that will occur
     PARSEtime[ int:INTfmt int:INTtime -- str:STRfmt ]
      * Parses the time into a string [ie. 1 day, 1 minute, and 1 second] in a
        multitude of different formats.
         : INTfmt  = The type of format to use. Can be as follows:
             -9 = Always ends up as: 3h 00m 01s
             -8 = Always ends up as: 1d 03h 00m 01s
             -7 = Like -6, except does not show anything higher than 'days'.
             -6 = 1d 03:00
             -5 = 1d 03:00:01
             -4 = 1d, 3h, and 1s
             -3 = 1d, 3h, 1s
             -2 = 1d 3h 1s
             -1 = 1d
              0 = 97200s
              1 = 1 day
              2 = 1 day 3 hours 1 second
              3 = 1 day, 3 hours, 1 second
              4 = 1 day, 3 hours, and 1 second
              5 = 1 day 03:00:01
              6 = 1 day 03:00
              7 = Like 6, except does not show anything higher than 'days'.
              8 = Always ends up as: 1 days 03 hours 00 minutes 00 seconds
              9 = Always ends up as: 3 hours 00 minutes 00 seconds
             [Note: -8 and 8 may change in length if days is greater than 9]
             [Note: Same thing for -9 and 9, except for the hours]
         : INTtime = The amount of time to parse with INTfmt
         : STRfmt  = The output string
 *)
 
$author      Moose
$lib-version 1.04
 
: DOWNtime[ -- int:INTtime ]
   #0 "/~sys/ShutdownTime" getpropval
;
 
: STARTtime[ -- int:INTtime ]
   #0 "/~sys/StartupTime" getpropval
;
 
: DUMPtime[ -- int:INTtime ]
   #0 "/~SYS/LastDumpTime" getpropval
;
 
: NEXTdump[ -- int:INTtime ]
   DUMPtime STARTtime > if
      DUMPtime
   else
      STARTtime
   then
   "dump_interval" SYSparm atoi +
;
 
$def ISEQ? ( i i - t/f ) swap dup 0 < if -1 * then =
 
: PARSEtime[ int:INTfmt int:INTtime -- str:STRfmt ]
(*** FORMATS:
   -9 = Always ends up as: 3h 00m 01s
   -8 = Always ends up as: 1d 03h 00m 01s
   -7 = Like -6, except does not show anything higher than 'days'.
   -6 = 1d 03:00
   -5 = 1d 03:00:01
   -4 = 1d, 3h, and 1s
   -3 = 1d, 3h, 1s
   -2 = 1d 3h 1s
   -1 = 1d
    0 = 97200s
    1 = 1 day
    2 = 1 day 3 hours 1 second
    3 = 1 day, 3 hours, 1 second
    4 = 1 day, 3 hours, and 1 second
    5 = 1 day 03:00:01
    6 = 1 day 03:00
    7 = Like 6, except does not show anything higher than 'days'.
    8 = Always ends up as: 1 days 03 hours 00 minutes 00 seconds
    9 = Always ends up as: 3 hours 00 minutes 00 seconds
   [Note: -8 and 8 may change in length if days is greater than 9]
   [Note: Same thing for -9 and 9, except for the hours]
 ***)
   VAR NUMtemp
   INTfmt @ not if
      INTtime @ intostr "s" strcat EXIT
   then
   INTtime @ not if
      INTfmt @ 8 ISEQ? if
         INTfmt @ 0 > if
            "0 days 00 hours 00 minutes 00 seconds"
         else
            "0d 00h 00m 00s"
         then
         EXIT
      then
      INTfmt @ 9 ISEQ? if
         INTfmt @ 0 > if
            "0 hours 00 minutes 00 seconds"
         else
            "0h 00m 00s"
         then
         EXIT
      then
      INTfmt @ 5 ISEQ? if
         "00:00:00" EXIT
      then
      INTfmt @ dup 6 ISEQ? swap 7 ISEQ? or if
         "00:00" EXIT
      then
      INTfmt @ 0 > if
         "0 seconds"
      else
         "0s"
      then
      EXIT
   then
   INTtime @ 31536000 / INTfmt @ 7 ISEQ? INTfmt @ dup 8 ISEQ? swap 9 ISEQ?
   or or not and if (years)
      INTtime @ 31536000 / dup intostr
      INTfmt @ 0 > if
         swap 1 = if
            " year"
         else
            " years"
         then
      else
         swap pop "y"
      then
      strcat INTfmt @ 1 ISEQ? if
         EXIT
      then
      INTtime @ 31536000 % INTtime !
   else
      ""
   then
   dup INTfmt @ dup 5 ISEQ? swap 6 ISEQ? or and not INTfmt @ 9 ISEQ? not and if
 
      INTtime @ 604800 / INTfmt @ 7 ISEQ? INTfmt @ 8 ISEQ? or not and if (weeks)
         INTtime @ 604800 / dup intostr
         INTfmt @ 0 > if
            swap 1 = if
               " week"
            else
               " weeks"
            then
         else
            swap pop "w"
         then
         strcat INTfmt @ 1 ISEQ? if
            swap pop EXIT
         then
         swap dup if
            INTfmt @ dup 3 ISEQ? swap 4 ISEQ? or not if
               " " strcat
            else
               "\[" strcat
            then
         then
         swap strcat
         INTtime @ 604800 % INTtime !
      then
      dup INTfmt @ dup 5 ISEQ? swap 6 ISEQ? or and not if
         INTtime @ 86400 / if (days)
            INTtime @ 86400 / dup intostr
            INTfmt @ 0 > if
               swap 1 = INTfmt @ 8 ISEQ? not and if
                  " day"
               else
                  " days"
               then
            else
               swap pop "d"
            then
            strcat INTfmt @ 1 ISEQ? if
               swap pop EXIT
            then
            swap dup if
               INTfmt @ dup 3 ISEQ? swap 4 ISEQ? or not if                  " " strcat
               else
                  "\[" strcat
               then
            then
            swap strcat
            INTtime @ 86400 % INTtime !
         else
            INTfmt @ 8 ISEQ? if
               pop INTfmt @ 0 > if
                  "0 days"
               else
                  "0d"
               then
            then
         then
      then
   then
   INTfmt @ 9 ISEQ? not if
      INTtime @ 86400 % INTtime !
   then
   INTtime @ 3600 / if (hours)
      INTtime @ 3600 / dup intostr
      INTfmt @ dup 5 ISEQ? swap 6 ISEQ? or not if
         INTfmt @ 0 > if
            swap 1 = INTfmt @ 8 ISEQ? not and if
               " hour"
            else
               " hours"
            then
         else
            swap pop "h"
         then
         INTfmt @ 8 ISEQ? if
            over strlen 2 < if
               "0" rot strcat swap
            then
         then
      else
         swap pop over if
            swap " " strcat swap
         then
         dup strlen 1 = if
            "0" swap strcat
         then
         ":" strcat ""
      then
      strcat INTfmt @ 1 ISEQ? if
         swap pop EXIT
      then
      swap dup if
         INTfmt @ dup 5 ISEQ? swap 6 ISEQ? or not if
            INTfmt @ dup 3 ISEQ? swap 4 ISEQ? or not if
               " " strcat
            else
               "\[" strcat
            then
         then
      then
      swap strcat
      INTtime @ 3600 % INTtime !
   else
      INTfmt @ dup 5 ISEQ? swap 6 ISEQ? or if
         " 00:" strcat striplead
      else
         INTfmt @ 8 ISEQ? INTfmt @ 9 ISEQ? or if
            dup if
               " " strcat
            then
            INTfmt @ 0 > if
               "0 hours"
            else
               "0h"
            then
            INTfmt @ 8 ISEQ? if
               "0" swap strcat
            then
            strcat
         then
      then
   then
   INTtime @ 60 / if (minutes)
      INTtime @ 60 / dup intostr
      INTfmt @ dup 5 ISEQ? swap 6 ISEQ? or not if
         INTfmt @ 0 > if
            swap 1 = INTfmt @ 8 ISEQ? not and if
               " minute"
            else
               " minutes"
            then
         else
            swap pop "m"
         then
         INTfmt @ dup 8 ISEQ? swap 9 ISEQ? or if
            over strlen 2 < if
               "0" rot strcat swap
            then
         then
      else
         swap pop dup strlen 1 = if
            "0" swap strcat
         then
         INTfmt @ 6 ISEQ? if
            strcat EXIT
         else
            ":" strcat
         then
         ""
      then
      strcat INTfmt @ 1 ISEQ? if
         swap pop EXIT
      then
      swap dup if
         INTfmt @ dup 5 ISEQ? swap 6 ISEQ? or not if
            INTfmt @ dup 3 ISEQ? swap 4 ISEQ? or not if
               " " strcat
            else
               "\[" strcat
            then
         then
      then
      swap strcat
      INTtime @ 60 % INTtime !
   else
      INTfmt @ dup 5 ISEQ? swap 6 ISEQ? or if
         "00" strcat
         INTfmt @ 6 ISEQ? if
            EXIT
         else
            ":" strcat
         then
      else
         INTfmt @ 8 ISEQ? INTfmt @ 9 ISEQ? or if
            dup if
               " " strcat
            then
            INTfmt @ 0 > if
               "00 minutes" strcat
            else
               "00m" strcat
            then
         then
      then
 
   then
   INTtime @ if
      INTtime @ dup intostr
      INTfmt @ dup 5 ISEQ? swap 6 ISEQ? or not if
         INTfmt @ 0 > if
            swap 1 = INTfmt @ 8 ISEQ? not and if
               " second"
            else
               " seconds"
            then
         else
            swap pop "s"
         then
         INTfmt @ dup 8 ISEQ? swap 9 ISEQ? or if
            over strlen 2 < if
               "0" rot strcat swap
            then
         then
      else
         swap pop dup strlen 1 = if
            "0" swap strcat
         then
         strcat EXIT
      then
      strcat INTfmt @ 1 ISEQ? if
         swap pop EXIT
      then
      swap dup if
         INTfmt @ dup 3 ISEQ? swap 4 ISEQ? or not if
            " " strcat
         else
            "\[" strcat
         then
      then
      swap strcat
   else
      INTfmt @ dup 5 ISEQ? swap 6 ISEQ? or if
         "00" strcat EXIT
      else
         INTfmt @ 8 ISEQ? INTfmt @ 9 ISEQ? or if
            dup if
               " " strcat
            then
            INTfmt @ 0 > if
               "00 seconds" strcat
            else
               "00s" strcat
            then
         then
      then
   then
   INTfmt @ 4 ISEQ? over "\[" instr and if
      "\[" rsplit ", and " swap strcat strcat
   then
   INTfmt @ dup 3 ISEQ? swap 4 ISEQ? or if
      ", " "\[" subst
   then
;
 
$pubdef DOWNtime "$Lib/Time" match "DOWNtime" call
$pubdef DUMPtime "$Lib/Time" match "DUMPtime" call
$pubdef NEXTdump "$Lib/Time" match "NEXTdump" call
$pubdef PARSEtime "$Lib/Time" match "PARSEtime" call
$pubdef STARTtime "$Lib/Time" match "STARTtime" call
PUBLIC DOWNtime
PUBLIC STARTtime
PUBLIC DUMPtime
PUBLIC NEXTdump
PUBLIC PARSEtime
