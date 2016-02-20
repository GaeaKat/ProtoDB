(WhenGraph - Another W* Program by Riss! 6/6/95)
var CC
var scale
var dif
: dohelp
 "WhenGraph - By Riss - Ver 1.2" .tell
 " WG       - Displays a graph of the last 24 hours low and" .tell
 "             counts of connections to the server. " .tell
 " WG #dif  - Same display but with differential graph." .tell
 " WG #help - This message." .tell
 " " .tell
;
: gettimepart  ( -- s)
        "%H" systime timefmt     (returns 00 - 23)
;
: maketrackprop      ( -- s)
        "T" gettimepart strcat
;
: makelowprop    ( -- s)
        "L" gettimepart strcat
;
: makeavename   (i -- s)
        intostr "AV" swap strcat
;
: updatetime    ( -- )
        prog "tracktime" getpropstr
        gettimepart stringcmp if       (changed - reset tracker)
                prog maketrackprop "0" 0 addprop
                prog makelowprop "999" 0 addprop
                prog "tracktime" gettimepart 0 addprop
        then
        prog maketrackprop getpropstr atoi  (got last count)
        CC @                            (how many now)
        < if            (concount larger... update)
                prog maketrackprop CC @ intostr 0 addprop
        then
        prog makelowprop getpropstr atoi  (get low count)
        CC @                     (how many)
        > if     (concount LOWER ... update)
                prog makelowprop CC @ intostr 0 addprop
        then
        prog "alltimehigh" getpropstr atoi
        CC @
        < if
                prog "alltimehigh" CC @ intostr 0 addprop
                prog "alltimetime" "%X %x" systime timefmt 0 addprop
        then
        prog "restarthigh" getpropstr atoi
        CC @
        < if
                prog "restarthigh" CC @ intostr 0 addprop
                prog "restartx" "%X %x" systime timefmt 0 addprop
        then
;
: makehightrack  (i -- s)
        intostr dup strlen 2 = not if "0" swap strcat then
        "T" swap strcat
;
: makelowtrack  (i -- s)
        intostr dup strlen 2 = not if "0" swap strcat then
        "L" swap strcat
;
: getlowcount  (i -- s)
        makelowtrack prog swap getpropstr
        dup strlen 0 = if "   " swap strcat " " strcat EXIT then
        dup strlen 1 = if "  " swap strcat " " strcat EXIT then
        dup strlen 2 = if " " swap strcat " " strcat EXIT then
        " " strcat       (must be 3)
;
: nowspace       (s -- s)
        maketrackprop stringcmp not if   (yes is now)
                "> "
        else
                "  "
        then
;
: getavg        ( -- i)
        1
        Begin
                dup makeavename
                prog swap getpropstr atoi
                swap
                1 +
                dup 6 >
        until
        pop
        + + + + +
        6 /
;
: forkloop      ( -- )
        bg_mode setmode
        BEGIN           (outside loop forever)
                1
                Begin   (inside loop)
                        dup makeavename
                        prog swap concount 0 addprop
                        600 SLEEP
                        1 +
                        dup 6 > 
                Until
        REPEAT
;
: WhenGraph     (main)
  (PREEMPT)
  CONCOUNT CC !
     command @ "Queued event." stringcmp not if
        dup "connect" stringcmp not if updatetime EXIT then
        dup "disconnect" stringcmp not if updatetime EXIT then
        dup "startup" stringcmp not if
                prog "restarthigh" "0" 0 addprop
                prog "restarttime" "%X %x" systime timefmt 0 addprop
        EXIT then
     then
        dup "#help" stringcmp not if dohelp EXIT then
        0 dif !
        dup "#dif" stringcmp not if 1 dif ! then (differnetial)
     (display the graph)
        prog "scale" getpropstr atoi dup not if pop 10 then scale !
"WhenGraph by Riss. * = "
scale @ intostr strcat
" connections. Low and High counts by hour." strcat .tell
"Time Low   ---graph---   High" .tell
     0          (start at 0)
     BEGIN
        dup makehightrack dup dup nowspace strcat  (i s s') 
        3 pick getlowcount strcat
        dif @ if
           3 pick getlowcount atoi scale @ /
        ".   .   .   .   .   .   .   .   .   .   .   .   .   .   .   ." 
           swap strcut pop strcat
        then    
        swap (i s s')
        prog swap getpropstr dup           (i s s" s")
        atoi 
        dif @ if
           4 pick getlowcount atoi -
        then
        scale @ /                          (i s s" i)
        "*************************************************************" 
        swap strcut pop
        " " strcat swap strcat strcat      (i s)
        .tell
        1 + dup 24 =
     UNTIL
        "High since last restart ("
        prog "restarttime" getpropstr strcat "): " strcat
        prog "restarthigh" getpropstr strcat " at " strcat
        prog "restartx" getpropstr strcat "." strcat .tell
        "All time high: "
        prog "alltimehigh" getpropstr strcat " at " strcat
        prog "alltimetime" getpropstr strcat
        ". On now: " strcat  CC @ intostr strcat ". WG #help for help" 
        strcat .tell
;
