(RIDE frontend  Ver 3.71FB by Riss)
(NOTE: To install, just toss this in, link the actions to it, and run '<command> #setup')
(3.71 [Moose] Removed $lib/reflist, moved many RIDE properties to a W3 @prop)
(     so that the dbrefs are hidden, and also added ANSI support, added #setup)
(Props used:)
(@RIDE/ontaur        - REF-list of dbref of riders [taur])
(@RIDE/reqlist       - REF-list of dbrefs that cam come [taur])
(@RIDE/tauring       - Flag to enable _arrive engine [taur])
(@RIDE/onwho         - dbref of carrier [rider])
 
$author  Moose Riss
$version 3.71
 
var target
var taur
var rider
var namelist
var mode
var mess
 
$def globalprop prog
$def .envprop envprop
$def puppet? dup thing? swap "ZOMBIE" flag? and
$def vehicle? dup thing? swap "VEHICLE" flag? and
$def ansitell me @ swap ansi_notify
 
$include $lib/look
 
: tellhelp
"^CINFO^RIDE 3.71FB by Riss" ansitell
"^WHITE^Command                 Function" ansitell
"Handup ^WHITE^| ^NORMAL^carry <name>   ^WHITE^Enables you to carry the named character." ansitell
"Hopon ^WHITE^| ^NORMAL^ride <name>     ^WHITE^Accepts the offer to be carried by <name>." ansitell
"Hopoff ^WHITE^| ^NORMAL^dismount       ^WHITE^Leave the ride." ansitell
"Dropoff ^WHITE^| ^NORMAL^doff <name>   ^WHITE^Drop the named player from your ride." ansitell
"Carrywho ^WHITE^| ^NORMAL^cwho         ^WHITE^Shows who is being carried by you." ansitell
"Ridewho ^WHITE^| ^NORMAL^rwho          ^WHITE^Shows who you are riding." ansitell
"Rideend ^WHITE^| ^NORMAL^rend          ^WHITE^Disables riding and cleans up." ansitell
" " ansitell
"^CNOTE^Example: ^NORMAL^Riss wants to carry Lynx. Riss would: HANDUP LYNX. This would" ansitell
"notify Lynx that Riss offers to carry him. He can accept the offer" ansitell
"with: HOPON RISS. When Riss moves to another location, Lynx will move" ansitell
"with him. Lynx can leave the ride at any time, cleanly by a: HOPOFF," ansitell
"or simply by moving away from Riss by using any normal exit." ansitell
"RIDE does check Locks on exits passed through, and will not allow" ansitell
"someone who is locked out from entering." ansitell
" " ansitell
" ^CNOTE^Enter RIDE #HELP1 for other setup information!" ansitell
;
 
: help1
"^CNOTE^RIDE Custom setups - ^NORMAL^RIDE can be made to display custom messages for" ansitell
" most functions. You can set your own custom messages in your RIDE/" ansitell
" props directory. You may have as many different modes of messages" ansitell
" as you like. Set each group in a different sub directory." ansitell
"^CNOTE^MESSAGE PROP NAMES: ^NORMAL^('taur' refers to carrier, 'rider' to rider.)" ansitell
"_HANDUP^WHITE^:      Message taur sees when using handup command." ansitell
"_OOHANDUP^WHITE^:    Message rider sees when taur offers to carry." ansitell
 
"_OHANDUP^WHITE^:     Message the rest of the room sees." ansitell
"_HOPON^WHITE^:       Message the rider sees when hopping on." ansitell
"_OOHOPON^WHITE^:     Message the taur sees confirming the rider hopped on." ansitell
"_OHOPON^WHITE^:      What the rest of the room sees." ansitell
"_XHOPON^WHITE^:      The fail message to rider when they cant get on the taur." ansitell
"_OOXHOPON^WHITE^:    The fail message to the taur." ansitell
"_OXHOPON^WHITE^:     What the rest of the room sees." ansitell
"_HOPOFF^WHITE^:      Message to the rider when they hopoff." ansitell
"_OOHOPOFF^WHITE^:    Message to the taur when the rider hops off." ansitell
"_OHOPOFF^WHITE^:     What the rest of the room sees." ansitell
"_DROPOFF^WHITE^:     Message to the taur when they drop a rider." ansitell
"_OODROPOFF^WHITE^:   Message to the rider when they are dropped by the taur." ansitell
"_ODROPOFF^WHITE^:    Ditto the rest of the room." ansitell
"^CNOTE^Enter RIDE #HELP2 for next screen." ansitell
;
: help2
"In all the messages, %n will substitute to the taur's name, along with" ansitell
" the gender substitutions %o, %p, and %s. The substitution for the" ansitell
" rider's name is %l. Any message prop beginning with _O will have the" ansitell
" name of the actioner appended to the front automatically." ansitell
"You create the messages in a subdirectory of RIDE/ named for the mode" ansitell
" you want to call it. Examples:" ansitell
"^CNOTE^@set me=ride/carry/_handup:You offer to carry %l." ansitell
"^CNOTE^@set me=ride/carry/_oohandup:offers to carry you in %p hand." ansitell
"^CNOTE^@set me=ride/carry/_ohandup:offers to carry %l in %p hand." ansitell
"And so on.. You would then set your RIDE/_MODE prop to CARRY to use" ansitell
" the messages from that directory. @set me=ride/_mode:carry " ansitell
"If you do not provide messages, or a _mode, or a bad directory name" ansitell
" for _mode, then the default RIDE messages will be used." ansitell
"There are 4 build in modes. RIDE, HAND, WALK, and FLY." ansitell
" RIDE is the default if your mode is not set, and is used for riding" ansitell
" on ones back. HAND is holding hands to show around. WALK is just" ansitell
"walking with, and FLY is used for flying type messages. Feel free to" ansitell
"use these, or customize your own." ansitell
"^CNOTE^------------" ansitell
"There's more! Those are just the messages for the actions, there are" ansitell
" also the messages for the movements themselves!..." ansitell
"^CNOTE^Enter RIDE #HELP3 for those." ansitell
;
: help3
"Messages used by the RIDE engine - Different substitutions apply here." ansitell
"^WHITE^_RIDERMSG ^NORMAL^- What the rider sees when moved. Taur's name prepended and" ansitell
" pronoun subs refer to the taur." ansitell
"^WHITE^_NEWROOM ^NORMAL^- Tells the room entered by the taur and riders what's going" ansitell
" on. %l is the list of riders. Taur's name prepended w/ pronoun subs." ansitell
"^WHITE^_OLDROOM ^NORMAL^- Tells the room just left. Like _NEWROOM." ansitell
"There is no specific message for the taur, as you see the _NEWROOM" ansitell
" message. There are other error messages, they begin with RIDE: and" ansitell
" are not alterable. Set the props in the subdirectory you named in" ansitell
" your _MODE property." ansitell
" ^CNOTE^-------" ansitell
"One last prop... RIDE does check exits passed through for locks against" ansitell
" your riders. If they are locked out, they fall off. If in your RIDE/" ansitell
" directory, you @set me=ride/_ridercheck:YES" ansitell
" then your riders will be checked just after you move to a new place," ansitell
" and if any are locked out, you will automatically be yoyo'ed back" ansitell
" to the place you just left, and get a warning message." ansitell
" ^CNOTE^------- " ansitell
"^CNOTE^Enter RIDE #help4 for more version change info." ansitell
;
: help4
"^CNOTE^Version 3.5 ---" ansitell
"Worked on the lock checking routines to help them work with folks using" ansitell
"the Driveto.muf program for transportation. Should work now. And beefed" ansitell
"lock checking up some. You may now set 2 new properties on ROOMS:" ansitell
"_yesride:yes will allow riders in to a room NO MATTER IF OTHER LOCKS" ansitell
"TRY TO KEEP THEM OUT." ansitell
"_noride:yes will lock out all riders from a room." ansitell
"^CNOTE^Version 3.6 ---" ansitell
"Minor Lock change... You can now carry riders in to a room if you own" ansitell
" it, even if you passed through an exit to which the riders are locked" ansitell
" out. This allows you to not have to unlock exits to say, your front" ansitell
" door, every time you want to carry someone in. This also bypasses _noride"
ansitell
"LookStatus Added - A way to display your RIDE status when someone looks" ansitell
" at you. Add this to the end of your @6800 desc: %sub[RIDE/LOOKSTAT]" ansitell
"The property RIDE/LOOKSTAT will be set on you to display either who" ansitell
" you are carrying or who you are riding. This message comes from:" ansitell
"_LSTATTAUR: is carrying %l with %o.    <- for the 'taur  -or-" ansitell
"_LSTATRIDER: is being carryed by %n.   <- for the rider." ansitell
"These props can be set in the same _mode directory with the other" ansitell
" custom messages. Pronoun subs refer to the taur, and name is prepended." ansitell
" %l is the list of riders. %n is the taur's name." ansitell
"RIDE/LOOKSTAT will _NOT_ be set until after the first move by the 'taur" ansitell
"If RIDE/LOOKSTAT gets stuck showing something wrong, do a RIDEEND." ansitell
"^CNOTE^Version 3.7 --- ^NORMAL^-Zombies should work." ansitell
"^CNOTE^Version 3.71 ---" ansitell
"Removed $lib/reflist, moved many RIDE properties to a W3 @prop so that" ansitell
" the dbrefs are hidden, and also added ANSI support." ansitell
;
: PorZ?   (d -- b   Returns True if Player or Zombie  ***** 3.7)
     dup player? if pop 1 exit then
     dup thing? if "Z" flag? exit then
     pop 0
;
 
: issamestr?   (s s -- i  is same string?)
     stringcmp not
;
: setoldloc         ( -- set taur location to here)
     me @ "@RIDE/oldloc" me @ location intostr 0 addprop
;
 
: getmsg  (s -- s')
     mess ! taur @ "RIDE/_mode" getpropstr mode ! taur @
     "RIDE/" mode @ strcat "/" strcat mess @ strcat
     getpropstr
     dup not if     (no good, try global)
          pop globalprop
          "RIDE/" mode @ strcat "/" strcat mess @ strcat
          getpropstr
          dup not if     (again no good)
               pop globalprop "RIDE/RIDE/" mess @ strcat getpropstr
          then
     then
;
 
 
 
: makesubs     (s -- s)
     rider @ name "%l" subst  (s)
     taur @ name "%n" subst
     taur @ swap pronoun_sub  (s)
;
: telltaur     (s)
     taur @ "^CMOVE^" rot 1 escape_ansi strcat ansi_notify
;
: tellrider    (s)
     rider @ "^CMOVE^" rot 1 escape_ansi strcat ansi_notify
;
: tellroom     (s)
     loc @ taur @ rider @ 2 5 pick "^CMOVE^" swap 1 escape_ansi strcat ansi_notify_exclude
;
: checkin ( --    **** 3.5)
     prog "@RIDE/_check/" rider @ intostr strcat
     taur @ intostr 0 addprop
;
: checkout ( --   **** 3.5)
     prog
     "@RIDE/_check/" rider @ intostr strcat
     remove_prop
;
 
: handup  (USED BY TAUR - takes the param as the name of the player)
     me @ taur !
     dup not if tellhelp EXIT then
     match     (playername to dbref)
     dup porz? not  (is not a player here?)
                    (***** 3.7)
     if
          "^CFAIL^RIDE: That is not a character here." ansitell
          exit
     then
     dup rider !    (save it the rider dbref in here)
     dup me @ dbcmp
     if
          "^CFAIL^RIDE: You want to ride yourself? Kinda silly no?" ansitell
          exit
     then
     me @ "@RIDE/reqlist" rot REFLIST_add
     me @ "@RIDE/tauring" "YES" 0 addprop
     "_HANDUP" getmsg makesubs telltaur
     "_OOHANDUP" getmsg "%n " swap strcat makesubs tellrider
     "_OHANDUP" getmsg "%n " swap strcat makesubs tellroom
     setoldloc      (init this)
;
: hopon   (RUN BY RIDER)
     me @ rider ! dup not
     if tellhelp EXIT then
 
     match
     dup porz? not
          (***** 3.7)
     if
          "^CFAIL^RIDE: That is not a character here." ansitell
          exit
     then
     dup
     taur !    (Is the taur looking to carry you?)
     "@RIDE/reqlist" me @ REFLIST_find not not
     if        (YES.. ok)
          me @           (set our ridingon prop)
          "@RIDE/onwho" taur @ intostr 1 addprop
          "_HOPON" getmsg makesubs tellrider
          "_OOHOPON" getmsg "%l " swap strcat makesubs telltaur
          "_OHOPON" getmsg "%l " swap strcat makesubs tellroom
          CHECKIN
     else
          "_XHOPON" getmsg makesubs tellrider
          "_OOXHOPON" getmsg "%l " swap strcat makesubs telltaur
          "_OXHOPON" getmsg "%l " swap strcat makesubs tellroom
     then
;
: hopoff        (run by rider, does not take a param)
     me @ dup rider ! "@RIDE/onwho" getpropstr     (are we on someone?)
     atoi dbref dup taur !         (save it here)
     porz?                           (***** 3.7)
     if
          taur @ "@RIDE/ontaur" me @ REFLIST_find not not
          if        (YES.. ok)
               "_HOPOFF" getmsg makesubs tellrider
               "_OOHOPOFF" getmsg "%l " swap strcat makesubs telltaur
               "_OHOPOFF" getmsg "%l " swap strcat makesubs tellroom
          else
               "^CFAIL^RIDE: You decide not to go." ansitell
          then
     else
          "^CFAIL^RIDE: Already off." ansitell
     then
     me @ "@RIDE/onwho" "0" 1 addprop
     me @ "RIDE/lookstat" remove_prop
     CHECKOUT
;
: carrywho     (run by taur.. shows the REF-list)
     "^CNOTE^RIDE: You carry: ^NORMAL^" namelist !
     me @ "@RIDE/ontaur" array_get_reflist
     FOREACH
        swap pop
        dup porz? IF
           dup name 1 escape_ansi
           "^WHITE^, ^NORMAL^" strcat
           namelist @ swap strcat namelist !
        ELSE
           pop
        THEN
     REPEAT
     pop
     me @ "@RIDE/reqlist" array_get_reflist
     FOREACH
        swap pop
        dup porz? IF
           dup "@RIDE/onwho" getpropstr stod me @ dbcmp IF
              dup name 1 escape_ansi
              "^WHITE^, ^NORMAL^" strcat
           THEN
           namelist @ swap strcat namelist !
        ELSE
           pop
        THEN
     REPEAT
     pop
     namelist @
     dup strlen -- over "L^" rinstr = if
        dup strlen 17 - strcut pop
        "^WHITE^, ^NORMAL^" rsplit
        "^WHITE^, and ^NORMAL^" swap strcat strcat
     else
        "^CFAIL^Nobody." strcat
     then
     ansitell
;
: ridewho      (run by rider)
     me @
     "@RIDE/onwho"
     getpropstr     (are we on someone?)
     atoi dbref dup taur !         (save it here)
     porz?                       (***** 3.7)
     if
          "^CNOTE^RIDE: You are being carried by ^NORMAL^"
          taur @ name 1 escape_ansi strcat "." strcat ansitell
     else
          "^CINFO^RIDE: You are not being carried." ansitell
     then
;
: rideend           (run by taur.  clean up and stop.)
(need onwho check and rider cleanup)
     me @           (pull list)
     "@RIDE/ontaur" remove_prop
     me @ "@RIDE/reqlist" remove_prop
     me @           (flag off)
     "@RIDE/tauring" "NO" 0 addprop
     me @ "RIDE/lookstat" remove_prop
     "^CINFO^RIDE: Ride over." ansitell
;
 
: dropoff (USED BY TAUR - takes the param as the name of the player)
 
     me @ taur !    (im the taur)
 
     dup not if tellhelp EXIT then
     match     (playername to dbref)
     dup porz? not  (is not a player here?)
               (***** 3.7)
     if
          "^CFAIL^RIDE: That is not a character here." ansitell
          exit
     then
     rider !   (save it the rider dbref in here)
 
     taur @ "@RIDE/ontaur" rider @ REFLIST_find not not
     taur @ "@RIDE/reqlist" rider @ REFLIST_find not not
     or
     if rider @ "@RIDE/onwho" getpropstr atoi dbref taur @ dbcmp
          if rider @ "@RIDE/onwho" "0" 1 addprop
               rider @ "RIDE/lookstat" remove_prop
               CHECKOUT
               taur @ "@RIDE/ontaur" rider @ REFLIST_del
     "_DROPOFF" getmsg makesubs telltaur
     "_OODROPOFF" getmsg "%n " swap strcat makesubs tellrider
     "_ODROPOFF" getmsg "%n " swap strcat makesubs tellroom
          else
               "^CFAIL^RIDE: That player is not set to you." ansitell
          then
     else
          "^CFAIL^RIDE: That player is not in your carry list." ansitell
     then
     taur @ "@RIDE/reqlist" rider @ REFLIST_del
 
;
 
(************)
 
(RIDE ENGINE 3.7FB By Riss)
 
: taurREF-first     ( -- d)
     me @ "@RIDE/ontaur" array_get_reflist dup if 0 [] else pop #-1 then
;
: taurREF-next      (d -- d')
     me @ "@RIDE/ontaur" rot
rot rot array_get_reflist dup rot array_findval 0 [] over swap array_next if [] else pop pop #-1 then
;
: taurREF-delete    (d -- )
     me @ "@RIDE/ontaur" rot REFLIST_del
;
: taurREF-list      ( -- s)
     me @ "@RIDE/ontaur" array_get_reflist array_vals .short-list
;
: taurREF-add       (d -- )
     me @ "@RIDE/ontaur" rot REFLIST_add
;
 
: PorZ?   (d -- b   Returns True if Player or Zombie  ***** 3.7)
     dup player? if pop 1 exit then
     dup thing? if "Z" flag? exit then
     pop 0
;
: Anyonehome?       ( -- b True if first player in Ref-list)
     taurRef-first
     porz?            (***** 3.7)
 
;
: getonwho     (d -- d)
     "@RIDE/onwho" getpropstr atoi dbref
;
 
: onwho?            (d -- b        True if on you  **** 3.5)
     dup                                (d d  For second check)
     getonwho
     me @ dbcmp     (d b)
     swap intostr                       (b s)
     "@RIDE/_check/" swap strcat
     globalprop swap getpropstr         (b s')
     atoi dbref me @ dbcmp
(    dup not if "RIDE: Possible security fault." .tell then)
     AND       (both checks)
;
 
: getatrig          (d-- d'       **** 3.5)
     "@RIDE/theta" getpropstr atoi dbref
;
: setatrig               ( --   records triggerdbref on taur   **** 3.5)
     prog trig dbcmp if  (caused by RIDE?)
          me @ getonwho getatrig
     else
          trig
     then
 
     me @
     "@RIDE/theta" rot intostr 0 addprop
;
 
 
: atoldloc?         (d -- b        True if at old location)
     location me @ "@RIDE/oldloc" getpropstr atoi dbref dbcmp
;
 
: setoldloc         ( -- set taur location to here)
     me @ "@RIDE/oldloc" me @ location intostr 0 addprop
;
: getoldloc         ( -- d)
     me @ "@RIDE/oldloc" getpropstr atoi dbref
;
 
: dororcheck   (d -- b   Rider on rider check  one time)
     dup       (d d)
     getonwho getatrig   (get the trig used by the taur)
     dup       (d d' d')
     exit? if
          locked? EXIT
     then
     (nuts with it.. need recursion)
     pop pop
     0         (<- free ride)
;
 
: lockedout?        (d -- b  True if locked out)
     OWNER               (***** 3.7 for ZOMBIES!)
     dup  (D D)
     dup  (D D D)
     prog owner dbcmp swap    (D b  D)
     "W" flag? or   (D b)
     me @ "W" flag? or (D B)
     me @ prog owner dbcmp or (D B')
     loc @ "_yesride" getpropstr "yes" stringcmp not or
     if pop 0 EXIT then (not locked out)
     (D)
     loc @ owner me @ dbcmp   (I own room?)
     if pop 0 EXIT then
     (D)
     loc @ "_noride" getpropstr "yes" stringcmp not
     if pop 1 EXIT then       (room set to _noride)
     (D)
     trig exit?     (D b)
     if trig locked? EXIT then     (trig WAS an exit)
     (D ok.. must have been a program moveto of some sort)
     trig prog dbcmp     (did RIDE do the moveto?)
     if dororcheck EXIT then  (do rider on rider check)
     (D driveto or objexit maybe?)
     trig mlevel 3 = trig "W" flag? or
(    trig "@ridepass" getpropstr tolower "y" 1 strncmp not or ***NEED W )
     if pop 0 EXIT then (free pass if lev 3 moveto ***** 3.7)
     pop  (heck with the rider.. check the room)
     loc @ "J" flag? not if 1 EXIT then      (no J flag)
     loc @ "vehicle_ok?" .envprop "yes" stringcmp
     loc @ "vehicle_ok"  .envprop "yes" stringcmp AND
     loc @ "_vehicle_ok?" .envprop "yes" stringcmp AND
     loc @ "_vehicle_ok"  .envprop "yes" stringcmp AND
     loc @ "_vok?" .envprop "yes" stringcmp AND
     (exits true if stuff from driveto.muf not found)
;
 
 
: listlocked?       ( -- b)
     taurREF-first
     dup
     porz? not if   (if first dbref no good then cancel ***** 3.7)
          pop 1 exit
     then                (d)
     0 swap              (b d)
     BEGIN               (b d)
          dup            (b d d)
          porz? WHILE    (b d        ***** 3.7)
          dup            (b d d)
          lockedout?     (b d b)
          rot            (d b b)
          or             (d b)
          swap           (b d)
          taurREF-next        (b d')
     REPEAT
     pop                 (b)
;
 
: getmsg  (s -- s')
     mess ! me @ "RIDE/_mode" getpropstr mode !
     me @ "RIDE/" mode @ strcat "/" strcat mess @ strcat
     getpropstr
     dup not if     (no good, try global)
          pop globalprop
          "RIDE/" mode @ strcat "/" strcat mess @ strcat
          getpropstr
          dup not if     (again no good)
               pop
               globalprop
               "RIDE/RIDE/" mess @ strcat
               getpropstr
          then
     then
;
 
: tellnotonwho      (d --   of player not on taur)
     dup            (Tells taur who is not on them)
     name "RIDE: " swap strcat " " strcat "_notonwho" getmsg
     strcat pronoun_sub "^CFAIL^" swap 1 escape_ansi strcat ansitell
;
: tellnotawake      (d -- )
     dup            (Tells taur player fell asleep)
     name "RIDE: " swap strcat " " strcat "_notawake" getmsg
     strcat pronoun_sub "^CFAIL^" swap 1 escape_ansi strcat ansitell
;
: tellnotatoldloc   (d -- )
     dup            (Tells taur that rider moved off)
     name "RIDE: " swap strcat " " strcat "_notatoldloc" getmsg
     strcat pronoun_sub "^CFAIL^" swap 1 escape_ansi strcat ansitell
;
: telllocked        (d -- )
     dup            (Tells taur that rider was locked out)
     name "RIDE: " swap strcat " " strcat "_locked" getmsg
     strcat pronoun_sub 1 escape_ansi "^CFAIL^" swap strcat ansitell
;
: tellridergone     (d -- )
     me @           (for pronounsub. Tells rider they moved with taur)
     me @ name " " strcat "_ridermsg" getmsg strcat pronoun_sub  (d s)
     "^CMOVE^" swap 1 escape_ansi strcat ansi_notify
;
: tellnewroom       ( -- )
     me @           (for pronounsub. Tells room who did what with who)
     me @ name " " strcat "_newroom" getmsg strcat
     taurREF-list "%l" subst       (string, reflist, %l = string)
     pronoun_sub me @ location     (place)
     #0 rot "^CMOVE^" swap 1 escape_ansi strcat ansi_notify_except
;
: telloldroom       ( -- )
     me @           (for pronounsub. Tells room who did what with who)
     me @ name " " strcat "_oldroom" getmsg strcat
     taurREF-list "%l" subst       (string, reflist, %l = string)
     pronoun_sub getoldloc #0 rot
     1 escape_ansi "^CMOVE^" swap strcat ansi_notify_except
;
: resetlookstat
     me @ "RIDE/lookstat" remove_prop
;
 
: setlookstat       ( -- set the lookstat prop for the Taur)
     me @ dup name " " strcat
     "_lstatTAUR" getmsg strcat
     taurREF-list "%l" subst pronoun_sub (setup by the dup)
     me @ "RIDE/lookstat" rot 0 addprop
;
 
: setriderlookstat (d -- sets the riders prop)
     dup            (d d)
     name " " strcat     (d s)
     "_lstatRIDER" getmsg strcat
     me @ name "%n" subst me @ swap pronoun_sub (d s)
     "RIDE/lookstat" swap 0 addprop
;
: yankrider    (d -- d')
     dup taurREF-next swap taurREF-delete
;
: resetrider   (d -- )
     dup
     "@RIDE/onwho" "no_one" 0 addprop
     "RIDE/lookstat" remove_prop
;
: resettaur    ( -- )
     me @ "@RIDE/tauring" "NO" 0 addprop
     resetlookstat
;
 
: allaboard
     me @ "@RIDE/reqlist" ARRAY_get_reflist
     FOREACH
          swap pop
          dup target ! porz? IF
             target @ onwho?
             if
                  target @ taurREF-add
             else
                  "^CFAIL^RIDE: "
                  target @ name 1 escape_ANSI strcat
                  " did not accept your offer to be carried." strcat ansitell
             then
             me @ "@RIDE/reqlist" target @ REFLIST_del
          THEN
     REPEAT
;
 
 
: moveriders        ( -- MAIN)
     SETATRIG
     allaboard
     taurREF-first
     dup
     porz? not if    (***** 3.7)
          "^CINFO^RIDE: You are not carring anyone." ansitell
          resettaur
          setoldloc
          EXIT
     then
     me @
     "@RIDE/_ridercheck"
     getpropstr
     "YES"
     stringcmp not
     if        (ridercheck wanted!)
          listlocked?
          if        (opps.. someone is locked!)
               me @
               getoldloc
               MOVETO
"^CFAIL^RIDE: One or more of your riders were locked out of your destination."
               ansitell
               EXIT      (the whole shebang!)
          then
     then
 
 
     BEGIN                    (d)
          dup porz? WHILE       (***** 3.7)
          dup onwho? not if   (onwho? true if on you)
               dup  tellnotonwho   (d --     NOT on you)
               dup  yankrider      (d -- d'  pull from your list and get next)
               CONTINUE
          then
          dup OWNER awake? not if  (awake true if awake ***** 3.7)
               dup  tellnotawake   (d --     tells taur player not awake)
               dup  resetrider     (d --     Reset them)
               dup  yankrider      (d -- d'  pull from list)
               CONTINUE
          then
          dup atoldloc? not if     (atoldloc? true if at old location)
               dup  tellnotatoldloc     (d --     bailed out)
               dup  resetrider     (d --)
               dup  yankrider      (d -- d')
               CONTINUE
          then
          dup lockedout? if        (lockedout? true if Locked out)
               dup telllocked (d -- tell cant come with)
               dup resetrider      (d -- )
               dup yankrider       (d -- d')
               CONTINUE
          then
          (OK.... move them...)
          dup tellridergone        (d -- tells rider they moving)
          dup setriderlookstat     (D -- sets the riders lookstat)
          dup loc @ MOVETO         (ta da!)
 
          taurREF-next   (d -- d')
     REPEAT
     anyonehome?
     if
          tellnewroom
          telloldroom
          setlookstat
     else
          "^CFAIL^RIDE: No one came with you!" ansitell
          resettaur
     then
 
     setoldloc           (set location to here)
;
: ENGINE-MAINSWITCH
     me @ "@RIDE/TAURING" getpropstr "YES" stringcmp
     if EXIT then
          MOVERIDERS
;
 
: ride-setup[ ref:ref int:PermCheck? -- ]
(*** New #setup routine added by Moose ***)
   PermCheck? @ IF
      me @ "WIZARD" Flag? NOT IF
         me @ "^CFAIL^" "noperm_mesg" sysparm 1 escape_ansi strcat ansi_notify EXIT
      THEN
   THEN
   prog "LINK_OK" set
   #0 "/_Arrive/" ARRAY_get_propvals dup prog ARRAY_findval swap dtos ARRAY_findval or not IF
      #0 "/_Arrive/Ride" prog setprop
   THEN
   ref @ "/RIDE/_dropoff" "You stop leading %l." setprop
   ref @ "/RIDE/_handup" "You offer to lead %l." setprop
   ref @ "/RIDE/_hopoff" "You stop following %n." setprop
   ref @ "/RIDE/_hopon" "You decide to follow %n." setprop
   ref @ "/RIDE/_newroom" "enters with %l following behind." setprop
   ref @ "/RIDE/_odropoff" "stops leading %l." setprop
   ref @ "/RIDE/_ohandup" "offers to lead %l." setprop
   ref @ "/RIDE/_ohopoff" "stops following %n." setprop
   ref @ "/RIDE/_ohopon" "decides to follow %n." setprop
   ref @ "/RIDE/_oldroom" "leaves with %l following behind." setprop
   ref @ "/RIDE/_oodropoff" "stops leading you." setprop
   ref @ "/RIDE/_oohandup" "offers to lead you (Type 'HOPON %n' to accept)." setprop
   ref @ "/RIDE/_oohopoff" "stops following you." setprop
   ref @ "/RIDE/_oohopon" "has decided to follow you." setprop
   ref @ "/RIDE/_ooxhopon" "tries to follow you but can not." setprop
   ref @ "/RIDE/_oxhopon" "tries to follow %n but can not." setprop
   ref @ "/RIDE/_ridermsg" "leaves and you follow behind." setprop
   ref @ "/RIDE/_xhopon" "You try to follow %n but can not." setprop
   ref @ "/RIDE/carry/_DROPOFF" "You drop %l off of you." setprop
   ref @ "/RIDE/carry/_HANDUP" "You offer to carry %l." setprop
   ref @ "/RIDE/carry/_HOPOFF" "You hopoff %n." setprop
   ref @ "/RIDE/carry/_HOPON" "You scramble up on %n." setprop
   ref @ "/RIDE/carry/_NEWROOM" "enters, carrying %l with %o." setprop
   ref @ "/RIDE/carry/_ODROPOFF" "drops %l off." setprop
   ref @ "/RIDE/carry/_OHANDUP" "offers to carry %l." setprop
   ref @ "/RIDE/carry/_OHOPOFF" "hops off of %n." setprop
   ref @ "/RIDE/carry/_OHOPON" "scrambles up on %n." setprop
   ref @ "/RIDE/carry/_OLDROOM" "leaves, carrying %l with %o." setprop
   ref @ "/RIDE/carry/_OODROPOFF" "drops you off here." setprop
   ref @ "/RIDE/carry/_OOHANDUP" "offers to carry you. ('HOPON %n' to accept.)" setprop
   ref @ "/RIDE/carry/_OOHOPOFF" "hops off of you." setprop
   ref @ "/RIDE/carry/_OOHOPON" "scrambles up on you." setprop
   ref @ "/RIDE/carry/_OOXHOPON" "tries to scramble up on you, but %s slips and falls off." setprop
   ref @ "/RIDE/carry/_OXHOPON" "tries to scramble up on %n, but slips and falls off." setprop
   ref @ "/RIDE/carry/_RIDERMSG" "carries you with %o." setprop
   ref @ "/RIDE/carry/_XHOPON" "You try to scramble up on %n, but you slip and fall off." setprop
   ref @ "/RIDE/hand/_DROPOFF" "You let go of %l's hand." setprop
   ref @ "/RIDE/hand/_HANDUP" "You offer to take %l around by the hand." setprop
   ref @ "/RIDE/hand/_HOPOFF" "You let go of %l's hand." setprop
   ref @ "/RIDE/hand/_HOPON" "You take %n's hand." setprop
   ref @ "/RIDE/hand/_NEWROOM" "enters with %l, holding hands." setprop
   ref @ "/RIDE/hand/_ODROPOFF" "lets go of %l's hand." setprop
   ref @ "/RIDE/hand/_OHANDUP" "offers to take %l around by the hand." setprop
   ref @ "/RIDE/hand/_OHOPOFF" "releases %n's hand." setprop
   ref @ "/RIDE/hand/_OHOPON" "takes %n's hand." setprop
   ref @ "/RIDE/hand/_OLDROOM" "leaves, taking %l with %o." setprop
   ref @ "/RIDE/hand/_OODROPOFF" "releases your hand." setprop
   ref @ "/RIDE/hand/_OOHANDUP" "offers to take you around by the hand. ('HOPON %n' to accept.)" setprop
   ref @ "/RIDE/hand/_OOHOPOFF" "releases your hand." setprop
   ref @ "/RIDE/hand/_OOHOPON" "takes your hand firmly." setprop
   ref @ "/RIDE/hand/_OOXHOPON" "tries to take your hand, but you pull it away." setprop
   ref @ "/RIDE/hand/_OXHOPON" "tries to take %n's hand, but fails." setprop
   ref @ "/RIDE/hand/_RIDERMSG" "takes you with %o, holding hands." setprop
   ref @ "/RIDE/hand/_XHOPON" "You try to take %n's hand, but fail." setprop
   ref @ "/RIDE/ride/_DROPOFF" "You stop %l from walking along with you." setprop
   ref @ "/RIDE/ride/_HANDUP" "You offer to let %l walk along with you." setprop
   ref @ "/RIDE/ride/_HOPOFF" "You stop walking along with %n." setprop
   ref @ "/RIDE/ride/_HOPON" "You decide to walk along with %n." setprop
   ref @ "/RIDE/ride/_NEWROOM" "enters, carrying %l with %o." setprop
   ref @ "/RIDE/ride/_ODROPOFF" "stops %l from walking along with %o." setprop
   ref @ "/RIDE/ride/_OHANDUP" "offers to let %l walk along with %o." setprop
   ref @ "/RIDE/ride/_OHOPOFF" "stops walking along with %n." setprop
   ref @ "/RIDE/ride/_OHOPON" "decides to walk along with %n." setprop
   ref @ "/RIDE/ride/_OLDROOM" "leaves, carrying %l with %o." setprop
   ref @ "/RIDE/ride/_OODROPOFF" "stops you from walking along with %o." setprop
   ref @ "/RIDE/ride/_OOHANDUP" "offers to let you walk along with %o. ('HOPON %n' to accept.)" setprop
   ref @ "/RIDE/ride/_OOHOPOFF" "stops walking along with you." setprop
   ref @ "/RIDE/ride/_OOHOPON" "decides to walk along with you." setprop
   ref @ "/RIDE/ride/_OOXHOPON" "tries to walk along with you, but you give %o an angry glare and %s changes %s mind." setprop
   ref @ "/RIDE/ride/_OXHOPON" "tries to walk along with %n, but changes %p mind after receiving an angry glare." setprop
   ref @ "/RIDE/ride/_RIDERMSG" "carries you with %o." setprop
   ref @ "/RIDE/ride/_XHOPON" "You try to walk along with %n, but %s gives you an angry glare and you change your mind." setprop
   ref @ "/RIDE/walk/_DROPOFF" "You stop %l from walking along with you." setprop
   ref @ "/RIDE/walk/_HANDUP" "You offer to let %l walk along with you." setprop
   ref @ "/RIDE/walk/_HOPOFF" "You stop walking along with %n." setprop
   ref @ "/RIDE/walk/_HOPON" "You decide to walk along with %n." setprop
   ref @ "/RIDE/walk/_NEWROOM" "enters, with %l walking along next to %o." setprop
   ref @ "/RIDE/walk/_ODROPOFF" "stops %l from walking along with %o." setprop
   ref @ "/RIDE/walk/_OHANDUP" "offers to let %l walk along with %o." setprop
   ref @ "/RIDE/walk/_OHOPOFF" "stops walking along with %n." setprop
   ref @ "/RIDE/walk/_OHOPON" "decides to walk along with %n." setprop
   ref @ "/RIDE/walk/_OLDROOM" "leaves, with %l walking along next to %o." setprop
   ref @ "/RIDE/walk/_OODROPOFF" "stops you from walking along with %o." setprop
   ref @ "/RIDE/walk/_OOHANDUP" "offers to let you walk along with %o. ('HOPON %n' to accept.)" setprop
   ref @ "/RIDE/walk/_OOHOPOFF" "stops walking along with you." setprop
   ref @ "/RIDE/walk/_OOHOPON" "decides to walk along with you." setprop
   ref @ "/RIDE/walk/_OOXHOPON" "tries to walk along with you, but you give %o an angry glare and %s changes %s mind." setprop
   ref @ "/RIDE/walk/_OXHOPON" "tries to walk along with %n, but changes %p mind after receiving an angry glare." setprop
   ref @ "/RIDE/walk/_RIDERMSG" "leaves, with you walking along next to %o." setprop
   ref @ "/RIDE/walk/_XHOPON" "You try to walk along with %n, but %s gives you an angry glare and you change your mind." setprop
   PermCheck? @ IF
      me @ "^CSUCC^Setup completed.  All ride properties reset." ansi_notify
   THEN
;
 
(************)
 
: ridecom           (MAIN)
     prog "/RIDE" Propdir? NOT if
        prog 0 ride-setup
     THEN
     strip          (clean the param if any)
     dup "#help" issamestr? if tellhelp exit then
     dup "#help1" issamestr? if help1 exit then
     dup "#help2" issamestr? if help2 exit then
     dup "#help3" issamestr? if help3 exit then
     dup "#help4" issamestr? if help4 exit then
     dup "#setup" issamestr? if prog 1 ride-setup exit then
 
     command @      (get the command that started this mess....)
     dup "handup" issamestr? if pop handup exit then
     dup "carry" issamestr? if pop handup exit then
     dup "hopon" issamestr? if pop hopon exit then
     dup "ride" issamestr? if pop hopon exit then
     dup "hopoff" issamestr? if hopoff exit then
     dup "dismount" issamestr? if hopoff exit then
     dup "carrywho" issamestr? if carrywho exit then
     dup "cwho" issamestr? if carrywho exit then
     dup "ridewho" issamestr? if ridewho exit then
     dup "rwho" issamestr? if ridewho exit then
     dup "rideend" issamestr? if rideend exit then
     dup "rend" issamestr? if rideend exit then
     dup "dropoff" issamestr? if pop dropoff exit then
     dup "doff" issamestr? if pop dropoff exit then
     dup "Queued event." issamestr? if pop "Arrive" issamestr? if ENGINE-MAINSWITCH exit then then
     "^CFAIL^RIDE: HUH?  What kind of command is that?"
     ansitell     (should never get here)
;
