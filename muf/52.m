(*
   Lib-IC v1.2.4
   Author: Chris Brine [Moose/Van]
 
 
   v1.2.4: Changed to use $lib/standard [Moose]
   v1.2.3: Changed to 80 column width and added new directves. [Akari]
   v1.2.2: Added ref-filter-status and ref-filter-status-noafk
   v1.2.1: Added forced IC or OOC for rooms or regions.
   v1.2.0: Made it so that zone/region-based IC/OOCs can have players set AFK.
           Fixed a few bugs with the zone/region-based IC/OOC stuff.
           Added in forced approvals for going IC, which is optional for admin.
   v1.1.0: Made it so that there is an option to allow for IC/OOC to keep being
           used.
 
 
   Allows you to have an outside program finally check to see if a player is IC,
   OOC, or AFK.
   * Only this program needs to be modified if the other programs are made to
     use this.
 
 
   Public functions:
    REF-IC?       [ dbref    -- bolint ] [ Returns: -1 = AFK, 0 = OOC, 1 = IC  ]
    REF-IC-NOAFK? [ dbref    -- bolint ] [ Returns: 0 = OOC, 1 = IC            ]
    REF-APPROVED? [ dbref    -- bolint ] [ Returns: 1 = if can go IC, 0 if not ]
    REF-FILTER-STATUS[ array array -- array ]
    REF-FILTER-STATUS-NOAFK[ array array -- array ]
   Wizard functions:
    REF-GO-IC     [ dbref         --        ]
    REF-GO-OOC    [ dbref         --        ]
    REF-GO-AFK    [ dbref         --        ]
   Archwizard functions:
    REF-APPROVE   [ dbref strname --        ]
    REF-UNAPPROVE [ dbref strname --        ]
 *)
 
 
$author Moose
$version 1.24
$lib-version 1.24
 
 
$include $Lib/Standard
 
 
: REF-IC?[ ref:ref -- int:BOLint ]
   ref @ location ICOOC-forceoocprop envpropstr swap pop "yes" stringcmp not if
      0 EXIT
   then
   ref @ location ICOOC-forceicprop envpropstr over ok? not
   ICOOC-envicoocprop? and if
      ICOOC-AFKvalue stringcmp not ref @ PROPS-icooc getpropstr strip ICOOC-AFKvalue
      stringcmp not or if
         -1
      else
         ref @ PROPS-icooc remove_prop
         ref @ location PROPS-icooc envprop pop ok?
      then
      swap ok? if
         not
      then
   else
      swap ok? not if
         pop ref @ PROPS-icooc getpropstr
      then
      strip dup not if
         pop ICOOC-nullvalue?
      else
         dup ICOOC-ICvalue stringcmp not if
            pop 1
         else
            dup ICOOC-OOCvalue stringcmp not if
               pop 0
            else
               dup ICOOC-AFKvalue stringcmp not if
                  pop -1
               else
                  pop ICOOC-DEFvalue?
               then
            then
         then
      then
   then
;
 
 
: REF-IC-NOAFK?[ ref:ref -- int:BOLint ]
   ref @ location ICOOC-forceoocprop envpropstr swap pop "yes" stringcmp not if
      0 EXIT
   then
   ref @ location ICOOC-forceicprop envpropstr over ok? not
   ICOOC-envicoocprop? and if
      ref @ PROPS-icooc getpropstr ICOOC-AFKvalue stringcmp not not if
         ref @ PROPS-icooc remove_prop
      then
      pop ref @ location PROPS-icooc envprop pop ok?
      swap ok? if
         not
      then
   else
      swap ok? not if
         pop ref @ PROPS-icooc getpropstr
      then
      strip dup not if
         pop ICOOC-nullvalue? dup -1 = if pop 0 then
      else
         dup ICOOC-ICvalue stringcmp not if
            pop 1
         else
            dup ICOOC-OOCvalue stringcmp not if
               pop 0
            else
               pop ICOOC-defvalue? dup -1 = if pop 0 then
            then
         then
      then
   then
;
 
 
: REF-FILTER-STATUS[ arr:ARRrefs arr:ARRintstatus -- arr:ARRrefs' ]
   { }list ARRrefs @
   FOREACH
      swap pop dup #0 dbcmp not if
         dup REF-IC? ARRintstatus @ swap array_findval array_count
      else
         0
      then
      if
         swap array_appenditem
      else
         pop
      then
   REPEAT
;
 
 
: REF-FILTER-STATUS-NOAFK[ arr:ARRrefs arr:ARRintstatus -- arr:ARRrefs' ]
   { }list ARRrefs @
   FOREACH
      swap pop dup #0 dbcmp not if
         dup REF-IC-NOAFK? ARRintstatus @ swap array_findval array_count
      else
         0
      then
      if
         swap array_appenditem
      else
         pop
      then
   REPEAT
;
 
 
: REF-APPROVED?[ ref:ref -- int:BOLint ]
$ifdef ICOOC-ICapprove
   ref @ owner ICOOC-approveprop getpropstr "yes" stringcmp not
$else
   1
$endif
;
 
 
: REF-GO-IC[ ref:ref -- ]
$ifndef ICOOC-MultiCmd
   ref @ REF-IC? 1 = if
      ref @ "^CFAIL^You are already IC!" ansi_notify EXIT
   then
$endif
$ifdef ICOOC-ICapprove
   ref @ REF-APPROVED? not if
 
      me @ "^CFAIL^You have not been approved to go IC." ansi_notify EXIT
   then
$endif
   ICOOC-prop-ooc if
      ref @ ICOOC-prop-ooc ref @ location setprop
   then
   ref @ location #-1
   "^WHITE^*** ^GREEN^%n ^FOREST^goes ^GREEN^IC. ^WHITE^***"
   ref @ TRUENAME 1 escape_ansi "%n" subst ansi_notify_except
   ref @ REF-IC-NOAFK? not if
      ICOOC-prop-ic if
         ref @ ICOOC-prop-ic getprop dup dbref? not if
            pop ICOOC-room-ic
         else
            dup ok? if 0 else dup room? not then if
               pop ICOOC-room-ic
            then
         then
      else
         ICOOC-room-ic
      then
      dup ok? if
         dup room? if
            dup me @
            "^WHITE^*** ^GREEN^%n ^FOREST^goes ^GREEN^IC. ^WHITE^***"
            ref @ TRUENAME 1 escape_ansi "%n" subst ansi_notify_except
            ref @ swap moveto
         else
            pop
         then
      else
         pop
      then
   then
   ref @ PROPS-icooc ICOOC-ICvalue setprop
;
 
 
: REF-GO-OOC[ ref:ref -- ]
$ifndef ICOOC-MultiCmd
   ref @ REF-IC? 0 = if
      ref @ "^CFAIL^You are already OOC!" ansi_notify EXIT
   then
$endif
   ref @ location #-1
   "^WHITE^*** ^GREEN^%n ^FOREST^goes ^CRIMSON^OOC ^WHITE^***"
   ref @ TRUENAME 1 escape_ansi "%n" subst ansi_notify_except
   ref @ REF-IC-NOAFK? if
      ICOOC-prop-ooc if
         ref @ ICOOC-prop-ooc getprop dup dbref? not if
            pop ICOOC-room-ooc
         else
            dup ok? if 0 else dup room? not then if
               pop ICOOC-room-ooc
            then
         then
      else
         ICOOC-room-ooc
      then
      dup ok? if
         dup room? if
            dup me @
            "^WHITE^*** ^GREEN^%n ^FOREST^goes ^CRIMSON^OOC ^WHITE^***"
            ref @ TRUENAME 1 escape_ansi "%n" subst ansi_notify_except
            ref @ swap moveto
         else
            pop
         then
      else
         pop
      then
   then
   ref @ PROPS-icooc ICOOC-OOCvalue setprop
;
 
 
: REF-GO-AFK[ ref:ref -- ]
$ifndef ICOOC-MultiCmd
   ref @ REF-IC? -1 = if
      ref @ "^CFAIL^You are already AFK!" ansi_notify EXIT
   then
$endif
   ref @ location #-1
   "^WHITE^*** ^GREEN^%n ^FOREST^goes ^BROWN^AFK ^WHITE^***"
   ref @ TRUENAME 1 escape_ansi "%n" subst ansi_notify_except
   ref @ PROPS-icooc ICOOC-AFKvalue setprop
;
 
 
: REF-APPROVE[ ref:ref str:STRname -- ]
   VAR PLYRref
   STRname @ strip dup not if
      pop ref @ "^CYAN^Syntax: ^AQUA^@approve <player>" ansi_notify EXIT
   then
   pmatch dup ok? not if
      #-1 dbcmp if
         "^CINFO^I cannot find that player."
      else
         "^CINFO^I don't know which player you mean!"
      then
      ref @ swap ansi_notify EXIT
   then
   PLYRref !
   ref @ "ARCHWIZARD" Flag? not if
      ref @ "^CFAIL^" "noperm_mesg" sysparm 1 escape_ansi strcat ansi_notify
      EXIT
   then
   PLYRref @ REF-APPROVED? if
      ref @ "^CFAIL^That player is already approved." ansi_notify EXIT
   then
   PLYRref @ ICOOC-approveprop "yes" setprop
   ref @ "^CSUCC^Approved %n for the IC world." PLYRref @ unparseobj "%n" subst
   ansi_notify
   PLYRref @ "^CSUCC^You have been approved for the IC world." ansi_notify
;
 
 
: REF-UNAPPROVE[ ref:ref str:STRname -- ]
   VAR PLYRref
   STRname @ strip dup not if
      pop ref @ "^CYAN^Syntax: ^AQUA^@unapprove <player>" ansi_notify EXIT
   then
   pmatch dup ok? not if
      #-1 dbcmp if
         "^CINFO^I cannot find that player."
      else
         "^CINFO^I don't know which player you mean!"
      then
      ref @ swap ansi_notify EXIT
   then
   PLYRref !
   ref @ "ARCHWIZARD" Flag? not if
      ref @ "^CFAIL^" "noperm_mesg" sysparm 1 escape_ansi strcat ansi_notify
      EXIT
   then
   PLYRref @ REF-APPROVED? not if
      ref @ "^CFAIL^That player is not approved." ansi_notify EXIT
   then
   PLYRref @ ICOOC-approveprop remove_prop
   ref @ "^CSUCC^Unapproved %n." PLYRref @ unparseobj "%n" subst ansi_notify
   PLYRref @ "^CFAIL^You are no longer approved for the IC world." ansi_notify
;
 
 
: main[ str:Args -- ]
   me @ "GUEST" Flag? me @ "WIZARD" Flag? not and if
      me @ "^CFAIL^" "noguest_mesg" sysparm 1 escape_ansi strcat ansi_notify
      EXIT
   then
   Args @ strip dup Args ! command @ "@" instr 1 = not and if
      Args @ dup ":" instr 1 = if
         command @ "ooc" stringcmp not if
            1 strcut swap pop "opose " swap strcat
         then
      else
         command @ "ooc" stringcmp not if
            "osay "
         else
            "say "
         then
         swap strcat
      then
 
      me @ swap FORCE EXIT
   then
   command @ "ooc" stringcmp not if
      me @ REF-GO-OOC
   else
      command @ "afk" stringcmp not if
         me @ REF-GO-AFK
      else
         command @ "ic" stringcmp not if
            me @ REF-GO-IC
         else
            me @ "ARCHWIZARD" Flag? if
               command @ "@approve" stringcmp not if
                  me @ Args @ REF-APPROVE
               else
                  command @ "@unapprove" stringcmp not if
                     me @ Args @ REF-UNAPPROVE
                  else
                     me @ "^CFAIL^Invalid command." ansi_notify
                  then
               then
            else
               me @ "^CFAIL^Invalid command." ansi_notify
            then
         then
      then
   then
;
$pubdef REF-APPROVE "$Lib/IC" match "REF-APPROVE" call
$pubdef REF-APPROVED? "$Lib/IC" match "REF-APPROVED?" call
$pubdef REF-FILTER-STATUS "$Lib/IC" match "REF-FILTER-STATUS" call
$pubdef REF-FILTER-STATUS-NOAFK "$Lib/IC" match "REF-FILTER-STATUS-NOAFK" call
$pubdef REF-GO-AFK "$Lib/IC" match "REF-GO-AFK" call
$pubdef REF-GO-IC "$Lib/IC" match "REF-GO-IC" call
$pubdef REF-GO-OOC "$Lib/IC" match "REF-GO-OOC" call
$pubdef REF-IC-NOAFK? "$Lib/IC" match "REF-IC-NOAFK?" call
$pubdef REF-IC? "$Lib/IC" match "REF-IC?" call
$pubdef REF-UNAPPROVE "$Lib/IC" match "REF-UNAPPROVE" call
PUBLIC REF-IC?                 ( ref     -- bol )
PUBLIC REF-IC-NOAFK?           ( ref     -- bol )
PUBLIC REF-FILTER-STATUS       ( arr arr -- arr )
PUBLIC REF-FILTER-STATUS-NOAFK ( arr arr -- arr )
PUBLIC REF-APPROVED?           ( ref     -- bol )
WIZCALL REF-GO-IC              ( ref     --     )
WIZCALL REF-GO-OOC             ( ref     --     )
WIZCALL REF-GO-AFK             ( ref     --     )
ARCHCALL REF-APPROVE           ( ref str --     )
ARCHCALL REF-UNAPPROVE         ( ref str --     )
