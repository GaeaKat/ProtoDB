(*
   Lib-Objects v1.0.2
   Author: Chris Brine [Moose/Van]
   v1.0.2 [Akari] Cleaned up the formatting to be 80 column friendly.
                  Added the $pubdefs.
   v1.0.1:
    - Made it possible to use ANSINAME and PUEBLONAME on #-1 and #-2.
 *)
 
 
$author      Moose
$lib-version 1.02
 
$include $Lib/CGI
$include $Lib/Fakes
$include $Lib/Standard
  
: ShowUnparse?[ ref:REFplyr ref:ref -- int:BOLshow? ]
   REFplyr @ ok? not if
      0 EXIT
   then
   REFplyr @ owner ref @ Controls (?) REFplyr @ "SEE_ALL" Power? or
   ref @ Player? not if
      ref @ "CHOWN_OK" Flag? ref @ Program? not and if
         REFplyr @ ref @ "/@/ChLk" ISlocked? not or
      then
      ref @ "PARENT" Flag? ref @ "ABODE" Flag? or ref @ Room? and or
      ref @ "LINK_OK" Flag? ref @ dup Program? swap Room? or and or
      ref @ "XFORCIBLE" Flag? if
         REFplyr @ ref @ "/@/FLK" ISlocked? not or
      then
   then
   ref @ "EXAMINE_OK" Flag? or REFplyr @ "SILENT" Flag? not and
  ref @ case
   room? when me @ LOOK-pref_parse_exclude getpropstr "R" instr if 0 else 1 then end
   exit? when me @ LOOK-pref_parse_exclude getpropstr "E" instr if 0 else 1 then end
   thing? when me @ LOOK-pref_parse_exclude getpropstr "T" instr if 0 else 1 then end
   program? when me @ LOOK-pref_parse_exclude getpropstr "F" instr if 0 else 1 then end
   player? when me @ LOOK-pref_parse_exclude getpropstr "P" instr if 0 else 1 then end
   default 0 end
  endcase and
;
 
: Nearby?[ ref:REFplyr ref:ref -- int:BOLnear? ]
   REFplyr @ ok? not if me @ REFplyr ! then
   REFplyr @ ref @ dbcmp
   REFplyr @ location ref @ dbcmp or
   REFplyr @ ref @ location dbcmp or
   REFplyr @ location ref @ location dbcmp or
;
 
 
: Enviroment?[ ref:REFplyr ref:ref -- int:BOLenviroment? ]
   BEGIN
      REFplyr @ dup ok? not if pop me @ then ref @ Nearby? if
         1 EXIT
      then
      REFplyr @ dup ok? not if pop me @ then location dup REFplyr ! ok? WHILE
   REPEAT
   0
;
 
 
: REF-COLOR[ ref:ref -- str:STRcolor ]
   ref @ Player? if
      "^GREEN^"
   else
      ref @ Exit? if
         "^CYAN^"
      else
         ref @ Room? if
            "^CYAN^"
         else
            ref @ Thing? if
               "^PURPLE^"
            else
               ref @ Program? if
                  "^RED^"
               else
                  "^NORMAL^"
               then
            then
         then
      then
   then
;
 
 
: REF-PUEBLO-HINT[ ref:ref -- str:STRhint ]
   ref @ exit? if
      ref @ GETlink dup ref ! Ok? if
         ref @ Program? if
            "Run the MUF program"
         else
            ref @ Player? if
               "Teleport to " ref @ name strcat
            else
               ref @ Thing? if
                  "Bring %n here" ref @ name "%n" strcat
               else
                  ref @ Exit? if
                     "Run the meta-link"
                  else
                     ref @ Room? if
                        "Go to " ref @ name strcat
                     else
                        "Run the MPI command"
                     then
                  then
               then
            then
         then
      else
         "Run the MPI command"
      then
   else
      "Look at " ref @ name strcat
   then
;
 
 
: REF-PUEBLO[ ref:REFplyr ref:ref str:STRname -- str:STRpueblo ]
   ref @ Exit? if
      REFplyr @ ref @ Enviroment? REFplyr @ dup ok? not if pop me @ then
      ref @ Locked? not and if
         "<a xch_cmd=\"" ref @ name ";" split dup if
            swap pop ";" split pop
         else
            pop
         then
         strcat "\" xch_hint=\"" strcat
         ref @ REF-PUEBLO-HINT strcat "\">" strcat STRname @ strcat "</a>"
         strcat
      else
         STRname @
      then
   else
      REFplyr @ ref @ Nearby? if
         "<a xch_cmd=\"look " ref @ name "\"" split pop strcat
         "\" xch_hint=\"" strcat
         ref @ REF-PUEBLO-HINT strcat "\">" strcat STRname @ strcat "</a>"
         strcat
      else
         REFplyr @ ref @ location Nearby? if
            "<a xch_cmd=\"look " ref @ location name "\"" split pop strcat
            "=" strcat
            ref @ name "\"" split pop strcat "\" xch_hint=\"" strcat
            ref @ REF-PUEBLO-HINT strcat "\">" strcat STRname @ strcat
            "</a>" strcat
         else
            STRname @
         then
      then
   then
;
 
 
: doname[ ref:ref -- str:STRname ]
   ref @ ok? if
      ref @ name
   else
      ref @ #-1 dbcmp if
         "*NOTHING*"
      else
         ref @ #-2 dbcmp if
            "*AMBIGUOUS*"
         else
            ref @ #-3 dbcmp if
               "*HOME*"
            else
               "*NOTHING*"
            then
         then
      then
   then
;
 
 
: ANSINAME[ ref:ref -- str:STRname ]
   ref @ dup REF-COLOR swap doname 1 escape_ansi strcat
;
 
 
: PUEBLONAME[ ref:REFplyr ref:ref -- str:STRname ]
   REFplyr @ dup ok? not if pop me @ then ref @ dup doname TEXT2HTML REF-PUEBLO
;
 
 
: ANSIUNPARSE[ ref:ref -- str:STRname ]
   ref @ ANSINAME "^CINFO^" strcat ref @ dup unparseobj swap name strlen
   strcut swap pop 1 escape_ansi strcat
;
 
 
: PUEBLOUNPARSE[ ref:REFplyr ref:ref -- str:STRname ]
   REFplyr @ ref @ dup unparseobj TEXT2HTML REF-PUEBLO
;
 
 
: ANSITRUENAME[ ref:ref -- str:STRname ]
   ref @ dup REF-COLOR swap truename 1 escape_ansi strcat
   ref @ Exit? if
      "[^YELLOW^" "[" subst
      "(^YELLOW^" "(" subst
      "{^YELLOW^" "{" subst
      "<^YELLOW^" "<" subst
      "^CYAN^]" "]" subst
      "^CYAN^)" ")" subst
      "^CYAN^}" "}" subst
      "^CYAN^>" ">" subst
   then
;
 
 
: PUEBLOTRUENAME[ ref:REFplyr ref:ref -- str:STRname ]
   REFplyr @ ref @ dup truename TEXT2HTML REF-PUEBLO
;
 
 
: TRUEUNPARSE[ ref:ref -- str:STRname ]
   ref @ dup truename swap dup unparseobj swap name strlen strcut swap pop
   strcat
;
 
 
: PUEBLOTRUEUNPARSE[ ref:REFplyr ref:ref -- str:STRname ]
   REFplyr @ ref @ dup TRUEUNPARSE TEXT2HTML REF-PUEBLO
;
 
 
: ANSITRUEUNPARSE[ ref:ref -- str:STRname ]
   ref @ ANSITRUENAME "^CINFO^" strcat ref @ dup TRUEUNPARSE swap
   TRUENAME strlen strcut swap pop 1 escape_ansi strcat
;
 
 
: ANSI-FULLNAME[ ref:REFplyr ref:ref -- str:STRname ]
   0 VAR! idx
   REFplyr @ dup ok? if owner then ref @ ShowUnparse? if
      ref @ dup Exit? if
         ANSITRUEUNPARSE
      else
         ANSIUNPARSE
      then
   else
      ref @ dup Exit? if
         ANSITRUENAME
      else
         ANSINAME
      then
   then
   ref @ Thing? if
      ref @ "VEHICLE" flag? if
         idx @ if " (Vehicle)" else " ^NORMAL^(Vehicle)" idx ++ then strcat
      then
      ref @ "PUPPET" flag? if
         idx @ if " (Puppet)" else " ^NORMAL^(Puppet)" idx ++ then strcat
      then
      ref @ PROPS-container? getpropstr "y" stringpfx if
         REFplyr @ dup ok? not if pop me @ then ref @ "/_/CLK" ISlocked? if
            idx @ if " (Locked)" else " ^NORMAL^(Locked)" idx ++ then strcat
         else
            idx @ if " (Unlocked)" else " ^NORMAL^(Unlocked)" idx ++ then strcat
         then
      then
   else
      ref @ Exit? if
         REFplyr @ dup ok? not if pop me @ then ref @ Locked? if
            idx @ if " (Locked)" else " ^NORMAL^(Locked)" idx ++ then strcat
         then
      then
   then
   (
   ref @ "LISTENER" flag? if
      idx @ if " (Listener)" else " ^NORMAL^(Listener)" idx ++ then strcat
   then
   )
;
 
 
: PUEBLO-FULLNAME[ ref:REFplyr ref:ref -- str:STRname ]
   REFplyr @ dup ok? if owner then ref @ ShowUnparse? if
      REFplyr @ ref @ dup Exit? if
         PUEBLOTRUEUNPARSE
      else
         PUEBLOUNPARSE
      then
   else
      REFplyr @ ref @ dup Exit? if
         PUEBLOTRUENAME
      else
         PUEBLONAME
      then
   then
   ref @ Thing? if
      ref @ "VEHICLE" flag? if
         " (Vehicle)" strcat
      then
      ref @ "PUPPET" flag? if
         " (Puppet)" strcat
      then
      ref @ PROPS-container? getpropstr "y" stringpfx if
         REFplyr @ dup ok? not if pop me @ then ref @ "/_/CLK" ISlocked? if
            " (Locked)" strcat
         else
            " (Unlocked)" strcat
         then
      then
   else
      ref @ Exit? if
         REFplyr @ dup ok? not if pop me @ then ref @ Locked? if
            " (Locked)" strcat
         then
      then
   then
   (
   ref @ "LISTENER" flag? if
      " (Listener)" strcat
   then
   )
;
 
 
: DO-NAME[ ref:REFplyr ref:ref -- str:STRname ]
   VAR sme
   ref @ array? if
      me @ sme ! REFplyr @ me ! ref @ FAKE-DONAME sme @ me ! EXIT
   then
   REFplyr @ dup ok? not if pop me @ then "PUEBLO" flag? if
      REFplyr @ ref @ PUEBLO-FULLNAME
   else
      REFplyr @ ref @ ANSI-FULLNAME
   then
;
 
 
: Do-Name-List-NoPueblo[ ref:REFplyr arr:ARRreflist -- str:STRnamelist ]
   0 VAR! INTpos  "" VAR! STRnamelist VAR INTcnt VAR sme
   { }list ARRreflist @
   FOREACH
      swap pop dup Array? if
         dup FAKE-VISIBLE? if
            swap array_appenditem
         else
            pop
         then
      else
         swap array_appenditem
      then
   REPEAT
   dup array_count INTcnt !
   FOREACH
      swap pop dup array? if
         me @ sme ! REFplyr @ me !
         FAKE-DONAME
         sme @ me !
      else
         REFplyr @ swap ANSI-FULLNAME
      then
      INTpos ++ STRnamelist @ dup if
         INTpos @ INTcnt @ = if
            "^NORMAL^, and "
         else
            "^NORMAL^, "
         then
         strcat
      then
      swap strcat STRnamelist !
   REPEAT
   STRnamelist @
;
 
 
: Do-Name-List[ ref:REFplyr arr:ARRreflist -- str:STRnamelist ]
   0 VAR! INTpos  "" VAR! STRnamelist VAR INTcnt
   { }list ARRreflist @
   FOREACH
      swap pop dup Array? if
         dup FAKE-VISIBLE? if
            swap array_appenditem
         else
            pop
         then
      else
         swap array_appenditem
      then
   REPEAT
   dup array_count INTcnt !
   FOREACH
      swap pop REFplyr @ swap DO-NAME INTpos ++ STRnamelist @ dup if
         INTpos @ INTcnt @ = if
            me @ "PUEBLO" flag? if
               ", and "
            else
               "^NORMAL^, and "
            then
         else
            me @ "PUEBLO" flag? if
               ", "
            else
               "^NORMAL^, "
            then
         then
         strcat
      then
      swap strcat STRnamelist !
   REPEAT
   STRnamelist @
;
$pubdef ANSI-FULLNAME "$Lib/Objects" match "ANSI-FULLNAME" CALL
$pubdef ANSINAME "$Lib/Objects" match "ANSINAME" CALL
$pubdef ANSITRUENAME "$Lib/Objects" match "ANSITRUENAME" CALL
$pubdef ANSITRUEUNPARSE "$Lib/Objects" match "ANSITRUEUNPARSE" CALL
$pubdef ANSIUNPARSE "$Lib/Objects" match "ANSIUNPARSE" CALL
$pubdef DO-NAME "$Lib/Objects" match "DO-NAME" CALL
$pubdef Do-Name-List "$Lib/Objects" match "Do-Name-List" CALL
$pubdef Do-Name-List-NoPueblo "$Lib/Objects" match "Do-Name-List-NoPueblo" CALL
$pubdef Enviroment? "$Lib/Objects" match "Enviroment?" CALL
$pubdef Nearby? "$Lib/Objects" match "Nearby?" CALL
$pubdef PUEBLO-FULLNAME "$Lib/Objects" match "PUEBLO-FULLNAME" CALL
$pubdef PUEBLONAME "$Lib/Objects" match "PUEBLONAME" CALL
$pubdef PUEBLOTRUENAME "$Lib/Objects" match "PUEBLOTRUENAME" CALL
$pubdef PUEBLOTRUEUNPARSE "$Lib/Objects" match "PUEBLOTRUEUNPARSE" CALL
$pubdef PUEBLOUNPARSE "$Lib/Objects" match "PUEBLOUNPARSE" CALL
$pubdef ShowUnparse? "$Lib/Objects" match "ShowUnparse?" CALL
$pubdef TRUEUNPARSE "$Lib/Objects" match "TRUEUNPARSE" CALL
PUBLIC ShowUnparse?
PUBLIC Nearby?
PUBLIC Enviroment?
PUBLIC PUEBLONAME
PUBLIC ANSINAME
PUBLIC PUEBLOUNPARSE
PUBLIC ANSIUNPARSE
PUBLIC PUEBLOTRUENAME
PUBLIC ANSITRUENAME
PUBLIC TRUEUNPARSE
PUBLIC PUEBLOTRUEUNPARSE
PUBLIC ANSITRUEUNPARSE
PUBLIC ANSI-FULLNAME
PUBLIC PUEBLO-FULLNAME
PUBLIC DO-NAME
PUBLIC Do-Name-List
PUBLIC Do-Name-List-NoPueblo
