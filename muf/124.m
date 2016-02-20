(*
   Cmd-@Hoggers v1.0
   Author: Chris Brine [Moose/Van]
 
   Searches the database for the biggest memory hogging players in terms of
   disk space they occupy within the database. This translates to the
   amount of RAM they occupy as well when the MUCK is not running in DISKBASE
   mode.
   -Added new $directives [Akari]
 *)
$version 1.0
$author Moose
$include $lib/strings
 
: Cutlowestnum[ arr:ARRhogs -- arr:ARRhogs ]
   ARRhogs @ array_vals array_make 1 array_sort 0 array_getitem
   ARRhogs @ swap array_findval 0 array_getitem ARRhogs @ swap array_delitem
;
 
: ARRkey? ( arr:ARRdict ARRkey -- int:BOLkey? )
   swap array_keys array_make swap array_findval array_count not not
;
 
: Gethogs[ int:numhogs -- dict:ARRhogs ]
   { }dict VAR! ARRhogs
   #-1
   BEGIN
      1 + dup dbtop < WHILE
      dup ok? not if
         CONTINUE
      then
      dup owner ARRhogs @ over int ARRkey? if
         ARRhogs @ over int array_getitem
      else
         0
      then
      3 pick objmem + ARRhogs @ rot int array_setitem ARRhogs !
   REPEAT
   ARRhogs @
   BEGIN
      dup array_count numhogs @ > WHILE Cutlowestnum
   REPEAT
;
 
: Showhogs[ dict:ARRhogs -- ]
   0 VAR! idx VAR idx2
   me @ "^CINFO^### Name                RAM Usage" ansi_notify
   ARRhogs @ array_vals array_make 3 array_sort
   FOREACH
      swap pop ARRhogs @ swap dup idx2 ! array_findval
      FOREACH
         swap pop idx ++
         idx @ intostr 3 STRright " " strcat
         swap dbref name 17 STRleft strcat idx2 @ intostr 12 STRright strcat
         me @ swap notify
      REPEAT
   REPEAT
   me @ "^CNOTE^Syntax: ^NORMAL^@hoggers <top number of players>" ansi_notify
   me @ "^CINFO^Done." ansi_notify
;
 
: main ( str:Args -- )
   me @ "WIZARD" flag? not if
      me @ "^CFAIL^Permission denied." ansi_notify exit
   then
  background
   strip dup if
      atoi
   else
      pop 10
   then
   Gethogs Showhogs
;
