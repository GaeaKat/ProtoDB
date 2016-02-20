( Gen-StageMaker by Akari                                                 )
(                    Nakoruru08@hotmail.com                               )
(                                                                         )
( Version 1.1 - 04/05/01 - Changed it to work with things as cameras too. )
(                                                                         )
( Based on Confu@Ranma's gen-bigroom, with a few                          )
( clarifications and easier to use interface.                             )
( Install: Program must be set = L. And ought to be = V. That's about it. )
( Props: Ones with the * mark are required.                               )
( In listening room or on listening thing:                                )
(   *_arrive/stage:dbref# of program                                      )
(   *_listen/stage:dbref# of program                                      )
(    _stage/roomName:What name should be used for the room when notifying.)
(    _stage/arrive:What message should be shown to arriving players.      )
(   *_stage/group:List of room dbref#'s to notify to.                     )
( In receiving room:                                                      )
(   *_stage/ok:yes Without this prop, a room won't be notified.           )
(    _stage/format: An alternate format to the default. Must include %w   )
(                   for where the room name goes, and %m for where the    )
(                   message goes.                                         )
(    _stage/<dbref of a room without the # mark> For alternate room names.)
(           For example, _stage/3122:DownStairs would replace whatever the)
(           original name of the stage was to 'downstairs' instead.       )
( On players:                                                             )
(    _prefs/seestage:no -- Will block getting notified of events taking   )
(                          place on the stage.                            )
$def atell me @ swap ansi_notify
$def defaultform "^WHITE^[In ^CRIMSON^%w^WHITE^] ^GREY^%m"
$define defArrive
"^WHITE^[^CRIMSON^OOC^WHITE^] ^GREY^Events in this room are heard in other rooms."
$enddef
$def addit dup notNotify @ array_appenditem notNotify !
lvar roomName ( Stores the original default name for the room. )
lvar mesg
: notify-arrival ( -- )
  trig room? if
    loc @ "_stage/arrive" getpropstr strip dup not if pop defArrive then atell
  else
    trig "_stage/arrive" getpropstr strip dup not if pop defArrive then atell
  then
;
: validate-form ( s -- 's )
  "%w" "%W" subst "%m" "%M" subst
  dup "%w" instr over "%m" instr and not if pop defaultForm then
;
: get-players ( d -- a, d<room> -- a<dbrefs to notify> )
  0 array_make var! notNotify
  contents begin dup ok? while
    dup "_prefs/seestage" getpropstr "no" stringcmp not if
      addit next continue then
    dup "Z" flag? if dup owner location over location dbcmp if
      addit next continue then
    then
    dup program? if addit next continue then
    next
  repeat pop
  notNotify @
;
: notify-rooms ( a -- ,array of room dbrefs )
  var curRoom var curFormat var curName var notNotify
  foreach swap pop dup room? not if pop continue then curRoom !
    curRoom @ "_stage/ok" getpropstr strip "yes" stringcmp if continue then
    curRoom @ "_stage/" trig intostr strcat getpropstr strip dup not
    if pop roomName @ then
    curRoom @ "_stage/format" getpropstr strip dup not if pop defaultForm then
    validate-form swap "%w" subst mesg @ "%m" subst curFormat !
    curRoom @ get-players notNotify !
    curRoom @ notNotify @ array_vals curFormat @ ansi_notify_exclude
  repeat
;
: toggle-notify ( -- )
  me @ "_prefs/seestage" getpropstr "no" stringcmp not if
    "^FOREST^You will now be notified by gen-stage events." atell
    me @ "_prefs/seestage" "yes" setprop else
    "^BROWN^You will no longer be notifed by gen-stage events." atell
    me @ "_prefs/seestage" "no" setprop
  then
;
: main ( s -- )
  strip
  dup "Arrive" stringcmp not if pop notify-arrival exit then
  trig exit? if pop toggle-notify exit then
  dup "*has arrived." smatch trig room? not and if pop notify-arrival exit then
  mesg !
  trig "_arrive/stage" getprop dup string? if match then
  prog dbcmp not if pop exit then
  trig "_stage/group" array_get_reflist dup array_count not if exit then
  var! rooms
  trig "_stage/roomname" getpropstr strip dup not if pop trig name then
  roomName !
  rooms @ notify-rooms
;
