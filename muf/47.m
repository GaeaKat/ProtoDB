(*
   Lib-Puppet v2.0.2
   Version 2.02: [Akari]  09/06/2001
     - Added new 1.7 directives.
   To Get all puppets on the MUCK to work, type:
      @set $Lib/Puppet=@Config/AllPuppets?:yes
   Author: Chris Brine [Moose/Van]
      PUBLIC  puppet_count        [ ref:REFowner -- arr:ARRreflist ]
      PUBLIC  puppets_owned       [ ref:REFowner -- dpup1..dpupi i ]
      PUBLIC  puppets_owned_array [ ref:REFowner -- arr:ARRreflist ]
      PUBLIC  puppet_match        [ str:STRmatch -- ref:REFpup     ]
      PUBLIC  puppet_smatch       [ str:STRmatch -- arr:ARRreflist ]
      PUBLIC  puppet_exists?      [ str:STRpup   -- int:BOLexist?  ]
      WIZCALL puppet_register     [              -- arr:ARRreflist ]
      WIZCALL puppets_online      [              -- arr:ARRreflist ]
      WIZCALL puppets_registered  [ ref:REFpup   -- int:BOLsucc?   ]
   Recoded from scratch, but based upon Confu's and my own old libraries.
 *)
 
$author Moose
$lib-version 2.02
 
: AllPuppets?[ -- int:BOLall? ]
   prog "@Config/AllPuppets?" getpropstr "yes" stringcmp not
;
: puppets_registered[ -- arr:ARRlist ]
   VAR RegName
   { }list
   AllPuppets? if
      #0
      BEGIN
         "ZOMBIE" NEXTTHING_FLAG dup ok? WHILE
         dup rot array_appenditem swap
      REPEAT
      pop
   else
      #0 "/_Puppets/" array_get_propvals
      FOREACH
         swap RegName ! dup dbref? not if
            dup string? if
               dtos
            else
               dup int? if
                  dbref
               else
                  pop #-1
               then
            then
         then
         dup ok? if
            dup thing? over "ZOMBIE" flag? and if
               swap array_appenditem
            else
               pop #0 "/_Puppets/" RegName @ strcat remove_prop
            then
         else
            pop #0 "/_Puppets/" RegName @ strcat remove_prop
         then
      REPEAT
   then
;
: puppets_online[ -- arr:ARRlist ]
   { }list
   puppets_registered
   FOREACH
      swap pop dup owner awake? if
         swap array_appenditem
      else
         pop
      then
   REPEAT
;
: puppet_do_smatch[ str:STRmatch int:PlaceStars? -- arr:ARRlist ]
   { }list
   STRmatch @ strip dup STRmatch ! not if
      exit
   then
   PlaceStars? @ if
      "*" STRmatch @ strcat "*" strcat STRmatch !
   then
   puppets_registered
   FOREACH
      swap pop dup name STRmatch @ smatch if
         swap array_appenditem
      else
         pop
      then
   REPEAT
;
: puppet_smatch[ str:STRmatch -- arr:ARRlist ]
   STRmatch @ dup "*" instr not puppet_do_smatch
;
: puppet_match[ str:STRmatch -- ref:ref ]
   STRmatch @ "\\*" "*" subst 1 puppet_do_smatch
   dup array_count dup if
      1 > if
         pop #-2
      else
         0 array_getitem
      then
   else
      pop pop #-1
   then
;
: puppet_exists?[ (str/ref:)puppet -- int:BOLexist? ]
   puppet @ dbref? if
      puppets_registered
      FOREACH
         swap pop puppet @ dbcmp if
            1 exit
         then
      REPEAT
      0
   else
      puppet @ string? if
         puppet @ puppet_match ok?
      else
         0
      then
   then
;
: puppets_owned_array[ ref:ref -- arr:ARRlist ]
   { }list
   puppets_registered
   FOREACH
      swap pop dup owner ref @ owner dbcmp if
         swap array_appenditem
      else
         pop
      then
   REPEAT
;
: puppets_owned[ ref:ref -- d...di i ]
   ref @ puppets_owned_array array_vals
;
: puppet_count[ ref:ref -- int:count ]
   ref @ puppets_owned_array array_count
;
: puppet_register[ ref:ref -- int:BOLsucc? ]
   0 VAR! Idx
   ref @ dup thing? swap "ZOMBIE" flag? and not if
      0 exit
   then
   ref @ name puppet_exists? if
      0 exit
   then
   BEGIN
      #0 "/_Puppets/" Idx dup ++ @ intostr strcat getprop WHILE
   REPEAT
   #0 "/_Puppets/" Idx @ intostr strcat ref @ setprop 1
;
$pubdef :
$pubdef PupCount "$Lib/Puppet" match "puppet_count" call
$pubdef PupExists? "$Lib/Puppet" match "puppet_exists?" call
$pubdef PupMatch "$Lib/Puppet" match "puppet_match" call
$pubdef PupOnline "$Lib/Puppet" match "puppets_online" call
$pubdef PupOwned "$Lib/Puppet" match "puppets_owned" call
$pubdef PupOwned_Array "$Lib/Puppet" match "puppets_owned_array" call
$pubdef Puppet_Count "$Lib/Puppet" match "puppet_count" call
$pubdef Puppet_Exists? "$Lib/Puppet" match "puppet_exists?" call
$pubdef Puppet_Match "$Lib/Puppet" match "puppet_match" call
$pubdef Puppet_Register "$Lib/Puppet" match "puppet_register" call
$pubdef Puppet_Smatch "$Lib/Puppet" match "puppet_smatch" call
$pubdef Puppets_Online "$Lib/Puppet" match "puppets_online" call
$pubdef Puppets_Online_Array "$Lib/Puppet" match "puppets_online" call
$pubdef Puppets_Owned "$Lib/Puppet" match "puppets_owned" call
$pubdef Puppets_Owned_Array "$Lib/Puppet" match "puppets_owned_array" call
$pubdef Puppets_Registered "$Lib/Puppet" match "puppets_registered" call
$pubdef PupRegister "$Lib/Puppet" match "puppet_register" call
$pubdef PupRegistered "$Lib/Puppet" match "puppets_registered" call
$pubdef PupSmatch "$Lib/Puppet" match "puppet_smatch" call
PUBLIC  puppet_count
PUBLIC  puppets_owned
PUBLIC  puppets_owned_array
PUBLIC  puppet_match
PUBLIC  puppet_smatch
PUBLIC  puppet_exists?
WIZCALL puppets_registered
WIZCALL puppets_online
WIZCALL puppet_register
