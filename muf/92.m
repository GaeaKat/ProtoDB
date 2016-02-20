( ProtoSweep by Akari                                               )
(            Nakoruru08@hotmail.com                                 )
(                                                                   )
( Version 1.00 - 09/05/2001                                         )
( Version 1.01 - 09/10/2001 - Fixed awake? error                    )
( Version 1.02 - 12/11/2001 - Fixed 'sweep home' abort error.       )
( Version 1.03 - 12/15/2001 - Fixed a room sweeping bug.            )
( Version 1.04 - 05/10/2002 - Fixed a room sweeping bug, again.     )
(                                                                   )
( The goal was to write a version of sweep that isn't so dependent  )
( on other libraries, supports ANSI, and allows the owner of a room )
( to unlink someone from the room they own while sweeping them.     )
( Added permissions, and support for all the ol' standard messages  )
( included. Left out the 'contents of the player go home as well'   )
( part of the original sweep.                                       )
( Planning on wrapping in autosweep as well.                        )
( Concept based on Tygryss's cmd-sweep.muf, but the code is my own. )
( Written for ProtoMUCK, but I suspect that minus the ANSI, it is   )
( FB6 compatible as well, except maybe for the $define for puppet?  )
 
(** Changeable $defs ** )
$define DEFAULT_SWEEP_MESG
  "pulls out a big fuzzy broom and sweeps the room clean of sleepers."
$enddef
 
( ** Program $defs ** )
$author Akari
$version 1.04
$define puppet? ( d -- i )
  dup thing? if dup "LISTENER" flag? swap "Z" flag? or
  else pop 0 then
$enddef
$def atell me @ swap ansi_notify
 
( ** Global Variables ** )
lvar sweepRoom ( Bool to indicate it's a room sweep )
lvar mesgFormat ( message format to check for standard sweeping message )
 
: authorized? ( d<sweepee or room> -- i <can/can't> )
  (** This function determines if the sweeper can sweep the thing or room
   ** indicated by sweepee.
   **)
    var! sweepee
    sweepee @ player? if ( owns room? Higher WLev? )
        me @ "MAGE" flag? if
            me @ mlevel
            sweepee @ mlevel > not if 0 else 1 then exit
        then
        me @ sweepee @ location controls
        sweepee @ location "_sweep/public?" getpropstr "yes" stringcmp not
        or exit
    then
    sweepee @ room? if (owner? public sweeping? authorized specifically? )
        me @ sweepee @ controls if 1 exit then
        me @ "MAGE" flag? if 1 exit then
        sweepee @ "_sweep/public?" getpropstr "yes" stringcmp not if 1 exit then
        sweepee @ "_sweep/authorized" getpropstr dup
        if me @ dtos instr else pop 0 then
        exit
    then
    sweepee @ thing? if ( owner of thing or owner of room? )
        me @ "MAGE" flag? if 1 exit then
        me @ sweepee @ controls
        me @ sweepee @ location controls or exit
    then
    0 ( defaults to not sweepable if all else fails )
;
: subst-message ( d<ref> s<message> -- s<formatted message> )
  (** Gets the message ready for displaying ** )
    var! mesg var! theRef
    mesg @ "^^" "^" subst mesg ! ( escape ANSI )
    me @ name " " strcat mesg @ strcat mesg ! (prepend name)
    theRef @ mesg @ pronoun_sub ( pronoun sub and return )
;
: get-destination ( d<sweepee> -- d<destination> )
  (** Given the player dbref, determines where to send them. ** )
    var! sweepee
    sweepee @ location "_sweep/to" getprop dup if
        dup string? if stod then
        dup dbref? not if sweepee @ getlink
        else
            dup room? over thing? or not if pop
                pop sweepee @ getlink
            then
        then
    else pop sweepee @ getlink
    then
;
: sweep-single ( d<sweepee> -- i<result>)
  (** This function is called once we know who we want to sweep **)
    var! sweepee var destination
    sweepee @ authorized? not if -1 exit then
    sweepee @ get-destination destination !
    destination @ sweepee @ location dbcmp if
        sweepRoom @ if 0 exit then
        "^YELLOW^" sweepee @ name strcat " ^BROWN^is already home. Enter: "
        strcat atell
        "  ^VIOLET^'^BROWN^unlink^VIOLET^'"
        " ^CRIMSON^- ^BROWN^ to sweep and unlink them." strcat atell
        "  ^VIOLET^'^BROWN^sweep^VIOLET^'"
        "  ^CRIMSON^- ^BROWN^ to sweep but leave linked here." strcat atell
        " ^BROWN^Enter anything else to cancel: " atell read strip
        dup "unlink" stringcmp not if pop
            sweepee @ "player_start" sysparm stod setlink
            sweepee @ get-destination destination !
        else "sweep" stringcmp not if
            "player_start" sysparm stod destination !
        else "^BLUE^Cancelled." atell 0 exit
        then then
    then
    sweepRoom @ not if
        mesgFormat @ if
            me @ "_sweep/fmt/" mesgFormat @ strcat getpropstr dup not if pop
                me @ "_sweep/fmt/std" getpropstr dup not if pop
                    "sweeps %n home."
                then
            then
        else
            me @ "_sweep/fmt/std" getpropstr dup not if pop
                "sweeps %n home."
            then
        then
        sweepee @ swap subst-message
        "^FOREST^" swap strcat
        sweepee @ location swap #-1 swap ansi_notify_except
        sweepee @ "_sweep/swept" getpropstr dup if "^^" "^" subst
            sweepee @ name " " strcat swap strcat me @ swap pronoun_sub
        else pop
            sweepee @ name " is sent home." strcat
        then
        "^AQUA^" swap strcat
        sweepee @ location swap #-1 swap ansi_notify_except
    then
 
    sweepee @ destination @ moveto
    1
;
 
: sweep-list ( s<arguements> -- )
  (** Handles non-room sweeps. **)
    var! args var curName var count
    args @ "=" instr if
        args @ "=" split mesgFormat ! curName !
        me @ "MAGE" flag? not if
            curName @ 1 strcut pop "*" strcmp not if
                curName @ 1 strcut swap pop curName !
            then
        then
        match dup ok? if
            sweep-single dup -1 = if pop
                "^CFAIL^Permission denied." atell exit
            else not if exit then
            then
        else
            pop "^BROWN^Unable to find ^YELLOW^" curName @ strcat atell exit
        then
    else
        args @ " " explode_array foreach swap pop curName !
            me @ "MAGE" flag? not if
                curName @ 1 strcut pop "*" strcmp not if
                    curName @ 1 strcut swap pop curName !
                then
            then
            curName @ match dup ok? if
                sweep-single dup -1 = if pop
                    "^CFAIL^Could not sweep " curName @ strcat "." strcat atell
                else not if continue then
                then
            else
                pop "^BROWN^Unable to find ^YELLOW^" curName @ strcat atell
                continue
            then
            count ++
        repeat
        count @ 1 > if
            "^YELLOW^" count @ intostr strcat " ^FOREST^ players swept." strcat
            atell
        then
    then
;
: sweep-room ( d<room> -- )
  (** Given a room dbref, sweeps it free of sleepers if all
   ** the checks pass.
   ** )
    1 sweepRoom ! var count var curObj
    var! theRoom
    theRoom @ authorized? not if
        "^CFAIL^You do not have permission to sweep here." atell exit
    then
    ( Show message to the room. )
    me @ "_sweep/sweep" getpropstr dup if
        me @ swap subst-message
    else
        pop me @ DEFAULT_SWEEP_MESG subst-message
    then
    "^GREEN^" swap strcat theRoom @ swap #-1 swap ansi_notify_except
    theRoom @ contents_array foreach swap pop curObj !
        curObj @ player? curObj @ puppet? or not if continue then (a thing)
        curObj @ owner awake? if continue then ( awake at the moment )
        theRoom @ "_sweep/immune" getpropstr strip dup if " " strcat
            curObj @ dtos " " strcat instr if continue then ( immune player )
        else pop
        then
        curObj @ puppet? if ( don't sweep my own puppets in room-sweep )
            me @ curObj @ owner dbcmp if continue then
        then
        curObj @ sweep-single if count ++ then
    repeat
    "^YELLOW^" count @ intostr strcat
    count @ 1 = not if
      " ^FOREST^players sent home."
    else
      " ^FOREST^player sent home."
    then
    strcat atell
;
 
: do-help ( -- )
"^BLUE^-----------------------------------------------------------------------"
atell
"                      - = ProtoSweep 1.0 by Akari = -" atell
"^BLUE^-----------------------------------------------------------------------"
atell
"A replacement for the old sweep that's been around. Supports the same " .tell
"custom messages that are usable in the standard sweep. Differences are" .tell
"that you can list more than 1 thing to sweep at a time, and objects in" .tell
"your inventory are no longer sent home when you are swept.            " .tell
"Also, it allows you unlink players from your rooms if you no longer   " .tell
"want them linked there." .tell
" " .tell
"  sweep                - Sweeps the room of sleepers if you can." .tell
"  sweep <thing/player> - Sweeps that thing or player from the room." .tell
"  sweep <thing/player>=<format> - Sweeps with your specified format." .tell
"  sweep <player> <player> - To sweep more than 1 player at a time." .tell
"^WHITE^Props:" atell
"  _sweep/sweep       you - Message shown when you sweep a room." .tell
"  _sweep/swept       you - When you get swept. Pronoun_subs player sweeping."
.tell
"  _sweep/fmt/<fmt>   you - Custom formats for sweeping players." .tell
"  _sweep/fmt/std     you - For sweeping a player. Pronoun_subs who's swept."
.tell
"  _sweep/to         room - Dbref where players swept in the room go to." .tell
"  _sweep/authorized room - space seperated list of dbrefs who can sweep." .tell
"  _sweep/immune     room - space seperated list of dbrefs immune to     " .tell
"                           room sweeping while sleeping." .tell
"  _sweep/public?    room - Anyone can room sweep. (but not single sweep)" .tell
"^YELLOW^~Done~" atell
;
: main ( s -- )
    tolower strip var! args
    args @ not if loc @ sweep-room exit then
    args @ "#help" stringcmp not if do-help exit then
    ( defalt behavior assumes single sweep, so try to match )
    args @ match dup
    #-3 dbcmp if pop "^BROWN^'Sweep home' doesn't make sense." atell exit then
    dup room? if sweep-room exit else pop then
    ( It assumes sweeping specific things by default )
    args @ sweep-list
;
