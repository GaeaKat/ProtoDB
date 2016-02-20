( Cmd-PupReg by Akari                                       )
(                                                           )
( Version 1.1 - Made to work with Moose's new $lib/puppet   )
( Just install with an action like @pupreg.                 )
( Requires $lib/puppet 2.0 or newer.                        )
$author Akari
$version 1.1
$include $lib/puppet
$def atell me @ swap ansi_notify
$def .atell atell
lvar var1
: do-copysearch ( d -- )
  0 var1 !
  "_puppets/"
  begin
    #0 swap nextprop dup while
    #0 over getprop
    3 pick dbcmp if
      pop 1 var1 ! break
    then
  repeat
  pop
;
: doregister ( s -- )
  match dup ok? not
  if
    pop me @ "^CFAIL^I don't see that here." ansi_notify exit
  then
  dup thing? not
  if
    pop "^CFAIL^You many only register objects as puppets." atell exit
  then
  me @ over controls not
  if
    pop me @ "^CFAIL^You do not own that object." ansi_notify exit
  then
  dup name "*" swap strcat match ok?
  if
    pop me @ "^CFAIL^That name is being used by a player." ansi_notify exit
  then
  dup name " " instr
  if
    pop me @ "^CFAIL^A puppet name may not have a space in it." ansi_notify exit
  then
  do-copysearch
  var1 @ 1 = if
    me @ "^CFAIL^That puppet is already registered." ansi_notify
    me @ "^CFAIL^Please unregister it first." ansi_notify
    exit
  then
  puppet_register if
    "^CSUCC^Registration successful." .atell
  "^CNOTE^Make sure to set your puppet's finger profile." .atell
  else
    "^CFAIL^Registration failed. Bug Namco." .atell
  then
;
: tempoldstuff
  dup name "_puppets/" swap strcat #0 swap getpropstr dup
  if
    dup "(#" swap strcat ")" strcat swap atoi dbref dup name rot strcat swap
    "That name is already registered by " swap owner name strcat
    " for " strcat swap strcat "." strcat
    me @ "^CFAIL^" rot "^^" "^" subst strcat ansi_notify pop exit
  then pop
( okay register it )
  dup name " registered as a puppet." strcat me @ "^CSUCC^" rot
  "^^" "^" subst strcat notify
  dup name "_puppets/" swap strcat #0 swap rot intostr 0 addprop
;
: dounregister ( s -- )
  match dup ok? not if pop "I don't see that puppet here." .tell exit then
  me @ over controls not if
    "^CFAIL^You don't own that puppet." .atell exit
  then
  "_puppets/"
  begin
    #0 swap nextprop dup while
    #0 over getprop
    3 pick dbcmp if
      "Unregistering " 3 pick name strcat "." strcat "^^" "^" subst
      "^CSUCC^" swap strcat .atell
      #0 over remove_prop
      exit
    then
  repeat
  "^CFAIL^That puppet isn't registered." .atell
;
: listpuppets ( -- )
   PUPregistered array_vals array_make SORTTYPE_NOCASE_ASCEND array_sort
   FOREACH
      swap pop dup name "^^" "^" subst "^PURPLE^" swap strcat
      " ^CYAN^is registered to ^GREEN^" strcat
      swap owner name "^^" "^" subst strcat me @ swap ansi_notify
   REPEAT
   me @ "^CYAN^Usage: ^AQUA^@pupreg [!]<puppetname>" ansi_notify
;
: main ( s -- )
  dup if
    strip dup "!" 1 strncmp
    if
      doregister
    else
      1 strcut swap pop dounregister
    then
  else
    pop
    listpuppets exit
    me @ "^CYAN^Usage: ^AQUA^@pupreg [!]<puppetname>" ansi_notify
  then
;
