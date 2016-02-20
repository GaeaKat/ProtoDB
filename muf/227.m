( cmd-@action    v1.0    Jessy @ FurryMUCK    3/00
 
  Cmd-@action emulates the standard @action command and incorporates
  quota control. Like the @action command provided by the standard
  cmd-quota program, it also allows the action to be linked at the
  time it is created.
 
  INSTALLATION:
 
  Port cmd-@action and set it Wizard. Link a global action named
  '@action;@act' to it.
 
  Cmd-@action may be freely ported. Please comment any changes.
  
  Alynna: Changes for ProtoMUCK:
   Recognize NIL, and HOME.
   Respect the Autolinking tune.
)
 
(2345678901234567890123456789012345678901234567890123456789012345678901)
 
lvar ourDest
lvar ourExit
lvar ourRegname
lvar ourSource
lvar ourString
 
 
$define Tell me @ swap notify $enddef
$define NukeStack begin depth while pop repeat $enddef
 
: CheckName  ( s -- i )    (* return true if s is a valid object name *)
 
  dup "#"    stringpfx if pop 0 exit then
  dup "="    instr     if pop 0 exit then
  dup "&"    instr     if pop 0 exit then
  dup "here" smatch    if pop 0 exit then
  dup "me"   smatch    if pop 0 exit then
  dup "home" smatch    if pop 0 exit then
  pop 1 ;
 
 
: RegisterObject  ( d s --   )          (* set personal regname for d *)
 
  me @ "_reg/" 3 pick strcat getprop dup if
    "Used to be registered as $prop: $object"
    swap unparseobj "$object" subst
    over "$prop" subst me @ swap notify
  else
    pop
  then
  me @ "_reg/" 3 pick strcat 4 pick setprop
  "Now registered as $prop: $object"
  swap "$prop" subst
  swap unparseobj "$object" subst me @ swap notify ;
 
 
: DoHelp  (  --  )                                (* show help screen *)
 
  " " Tell
  "@action <name>=<source>[,<destination>] [=<regname>]" Tell " " Tell
 
"Creates a new action and attaches it to the thing, room, or player "
"specified. If a <regname> is specified, then the _reg/<regname> property "
"on the player is set to the dbref of the new object. This lets players "
"refer to the object as $<regname> (ie: $mybutton) in @locks, @sets, etc. "
"You may only attach actions you control to things you control. Creating "
"an action costs 1 penny. The action can then be linked with the command "
"@LINK, or by including the optional <destination> at the time of creation "
  strcat strcat strcat strcat strcat strcat Tell ;
 
: DoCreateAction  (  --  )             (* create action, attach, link *)
 
  ourSource @ ourExit @ newexit ourExit !            (* create action *)
  "Action created with number $dbref and attached."
  ourExit @ intostr "$dbref" subst Tell
 
  ourDest @ if                     (* link if a destination was given *)
    "Trying to link..." Tell               (* try to find destination *)
    ourDest @ match
    dup  #-1 dbcmp
    over #-2 dbcmp 
    or if
      "I couldn't find '$dest'."
      ourDest @ "$dest" subst Tell pop
    else                      (* ... if so, check permission and link *)
      ourDest !
$ifdef __proto
      ourDest @ #-3 dbcmp ourDest @ #-4 dbcmp or if
        ourExit @ ourDest @ setlink
        "Linked to $dest."
        ourDest @ unparseobj "$dest" subst Tell
      else
$endif
      me @ ourDest @ controls not if
        ourDest @ "A" flag? not if
          "You can't link to $dest."
          ourDest @ name "$dest" subst Tell
        else
          ourExit @ ourDest @ setlink
          "Linked to $dest."
          ourDest @ unparseobj "$dest" subst Tell
        then
      else
        ourExit @ ourDest @ setlink
        "Linked to $dest."
        ourDest @ unparseobj "$dest" subst Tell
      then
$ifdef __proto 
     then
$endif      
    then
  else
$ifdef __proto
   "autolinking" sysparm "yes" smatch if
        ourExit @ #-4 setlink
        "Linked to *NIL*." tell
   then
$endif
  then
                                          (* set regname if specified *)
  ourRegname @ if
    ourExit @ ourRegname @ RegisterObject
  then ;
 
: DoParse  (  --  )                         (* parse command and args *)
 
  ourString @ dup "=" instr if                               (* parse *)
    dup "=" instr strcut strip ourSource !
    dup strlen 1 - strcut pop strip ourExit !
    ourSource @ "=" instr if
      ourSource @ dup "=" instr strcut strip ourRegname !
      dup strlen 1 - strcut pop strip ourSource !
    then
    ourSource @ "," instr if
      ourSource @ dup "," instr strcut strip ourDest !
      dup strlen 1 - strcut pop strip ourSource !
    then
    ourSource @ not if
      "You must specify an action name and a source object."
      Tell NukeStack exit
    then
  else
    "You must specify an action name and a source object."
    Tell NukeStack exit
  then
                                              (* locate source object *)
  ourSource @ match
  dup  #-1 dbcmp
  over #-2 dbcmp or if
    "I don't see that here." Tell exit
  then
  me @ over controls not if
    "Permission denied." Tell exit
  then
  dup program? if
    "You can't attach an action to a program." Tell exit
  then
  ourSource !
 
  ourExit @ CheckName if
    DoCreateAction
  else
    "That's a silly name for an exit!" Tell
  then ;
 
: main
 
  "me" match me !
 
  me @ "B" flag? not if
    "That command is restricted to authorized builders." Tell exit
  then
 
  dup if
    ourString !
    "#help" ourString @ stringpfx if DoHelp exit then
    DoParse
  else
    "You must specify an action name and a source object." Tell
  then
;
