(*
   NeonMorph v2.72 - by Van@Beta
 
   Permission to port this, as long as code is left intact and credit is left where it
   is due.
 
   I chose to rewrite morph, since there weren't any very good ones out there around
   the anime-themed mucks, and there were high demands for certain features that were
   normaly spread around each morph program.
 
   New from v1.5 - v1.7: [Van@Beta]
    - Now allows 'random' morphing [ie. Choose a random morph from a listfile] for
      certain morphs, if setup properly.
    - Now prevents people from morphing to the 'def' or 'use' morph
    - Now prevents people from morphing to their current morph
    - Fixed the alias bug, now defaulted to being on
    - Now uses a 'version check' like page does
 
   New from v1.7 - v2.0: [Van@Beta]
    - Is now TinyMuckfb compatible, and uses $lib/muftools instead of $lib/ansi
    - Fixed up the random morphing to be a bit more accurate
    - Added a random morph editor
 
   New from v2.0 - v2.5: [Van@Beta]
    - Added the 'morph #rem' and 'morph #show' commands
    - Prevented any morphing of neonmuck enhancements on tinymuckfb mucks now
    - Actually added stuff to preventing morphing to 'alias' [forgot that one!]
    - Added a 'morph message' editor [finally!]
    - Fixed the proploc problems [Pointed out by Skuld, thanks!]
 
   New from v2.5 - v2.7: [Van@Beta]
    - Added a prop-? editor into the morph editor
    - Added the '/use/morph1-morph2:no' for preventing morphing, in the
      morph editor
    - Added an option to change the 'proploc' as well
    - Fixed *more* proploc problems [Thanks, Skuld!]
 
   New from v2.7 - v2.71:[Van@Beta]
    - Fixed the _race / _race-name props to be set on the user not proploc
    - Got rid of he 'version check' .. no need for it since updates will be
      slower, and smaller
 
   New from v2.71 - v2.72 [Moose]
    - Removed libraries and added $lib/standard support
 
   To install on a muck:
   Create the action morph;morp;mor;mo on room #0
   Thats it ^_^
 
*)
 
$author  Moose
$version 2.72
 
$def CurVersion "NeonMorph v2.72 - by Van@Beta (01/07/03)"
 
$include $lib/standard
 
$undef .atell
$def .atell me @ swap ansi_notify
 
lvar usemesg
lvar bypassl
lvar quietm
 
: Version-Check ( -- )
   me @ "_Prefs/MorphVersion" getpropstr dup CurVersion stringcmp not and not if
      me @ "_Prefs/MorphVersion" getpropstr dup not if
         pop me @ "^YELLOW^NeonMorph updated!  You last used a lower version than v1.7."
         Ansi_Notify
      else
         me @ "^YELLOW^NeonMorph updated!  You last used %m." rot "%m" subst Ansi_Notify
      then
      me @ "_Prefs/MorphVersion" CurVersion setprop
   then
;
 
: ToDbref ( ? -- ref )
   dup VAR! item
   CASE
      Dbref? WHEN
         item @
      END
      Int? WHEN
         item @ dbref
      END
      Float? WHEN
         item @ int dbref
      END
      String? WHEN
         item @ stod
      END
      Lock? WHEN
         item @ unparselock stod
      END
      DEFAULT
         #-1
      END
   ENDCASE
;
 
$def IsWiz? "W" Flag?
 
: OProploc ( dChar -- dLoc )
   "_morph_proploc" getprop dup if
      ToDbref dup ok? not if
         pop me @
      then
   else
      pop me @
      "_proploc" getprop dup if
         ToDbref dup ok? not if
            pop me @
         then
      else
         pop me @
      then
   then
   dup owner me @ dbcmp not if
      pop me @
   then
;
 
lvar newrace
lvar racename
lvar oldrace
lvar oloc
lvar sme
lvar tempint
: Do-Morph ( sOldRace sNewRace -- )
 me @ "GUEST" flag? if
    "^GREEN^[ ^YELLOW^Sorry, Guests can't use morph. ^GREEN^]" .atell exit
  then
   dup "def" stringcmp not over "use" stringcmp not or over "alias" stringcmp not or if
      pop pop me @ "^RED^Invalid race." Ansi_Notify exit
   then
 
   newrace ! oldrace ! me @ oproploc oloc !
 
   oloc @ "_morph/%n/random?" newrace @ "%n" subst getpropstr strip dup "y" stringpfx and if
      oloc @ "_morph/%n/rand#" newrace @ "%n" subst getpropstr atoi
      dup 1 > if
         oloc @ "_morph/%n/lastrand" newrace @ "%n" subst getprop tempint ! 1
         begin
            pop random over % 1 +
         dup tempint @ = not
         oloc @ "_morph/%n/rand#/" 3 pick intostr strcat newrace @ "%n" subst getpropstr strip
         dup "def" stringcmp not over "use" stringcmp not or swap "alias" stringcmp not or
         not and until
         swap pop
         oloc @ "_morph/%n/rand#/" 3 pick intostr strcat newrace @ "%n" subst getpropstr strip
         oloc @ "_morph/%n/lastrand" newrace @ "%n" subst 4 rotate setprop
         newrace !
         me @ "^WHITE^Randomly morphing into the '%n' morph." newrace @ "%n" subst Ansi_Notify
      else
         pop me @ "^RED^The random morph lsedit list needs two or more morphs in it."
         Ansi_Notify exit
      then
   then
 
   (* Check if newrace exists *)
   oloc @ "_morph/use/%n" newrace @ "%n" subst getpropstr
   strip dup not over dup dup "y" stringpfx and over dup "o" stringpfx and or or not if
      me @ "^RED^That race doesn't exist." Ansi_Notify exit
   then
 
   oloc @ "_morph/use/%o-%n" oldrace @ "%o" subst newrace @ "%n" subst getpropstr
   strip dup "n" stringpfx and bypassl @ not and if
      me @ "^RED^Sorry, but you can't morph from to that race from the current one."
      Ansi_Notify exit
   then
 
   newrace @ oldrace @ stringcmp not if
      me @ "^RED^You allready are a %n." newrace @ "%n" subst Ansi_Notify exit
   then
 
   (* Do message *)
   quietm @ not if
      oloc @ "_morph/%o/%n-alias?" oldrace @ "%o" subst newrace @ "%n" subst getpropstr
      strip dup "n" stringpfx and not if
         me @ "%n" pronoun_sub " " strcat sme !
      else
         me @ name " " strcat sme !
      then
      oloc @ "_morph/%n/name" newrace @ "%n" subst getpropstr strip dup if
         racename !
      else
         pop newrace @ racename !
      then
      usemesg @ if
         me @ usemesg @ pronoun_sub loc @ sme @ rot strcat 0 swap notify_exclude
      else
         oloc @ "_morph/%o/%n" oldrace @ "%o" subst newrace @ "%n" subst getpropstr
         strip dup if
            me @ swap pronoun_sub loc @ sme @ rot strcat 0 swap notify_exclude
         else
            pop oloc @ "_morph/def/def" getpropstr strip dup if
               me @ swap pronoun_sub loc @ sme @ rot strcat 0 swap notify_exclude
            else
               pop loc @ "%mmorphs into a %n."
               sme @ "%m" subst racename @ "%n" subst 0 swap notify_exclude
            then
         then
      then
   else
      oloc @ "_morph/%o/%n-alias?" oldrace @ "%o" subst newrace @ "%n" subst getpropstr
      strip dup "y" stringpfx or if
         me @ "%n" pronoun_sub " " strcat sme !
      else
         me @ name " " strcat sme !
      then
      oloc @ "_morph/%n/name" newrace @ "%n" subst getpropstr strip dup if
         racename !
      else
         pop newrace @ racename !
      then
      me @ "^WHITE^You quietly morph into %n." racename @ "%n" subst Ansi_Notify
   then
 
   (* Do Internal Props *)
(Desc)
   oloc @ "_morph/%n/desc" newrace @ "%n" subst getpropstr strip dup if
      me @ "_/de" rot setprop
   else
      pop oloc @ "_morph/def/desc" getpropstr strip dup if
         me @ "_/de" rot setprop
      else
         pop
      then
   then
$ifdef __neon
(HtmlDesc)
   oloc @ "_morph/%n/htmldesc" newrace @ "%n" subst getpropstr strip dup if
      me @ "_/htmlde" rot setprop
   else
      pop oloc @ "_morph/def/htmldesc" getpropstr strip dup if
         me @ "_/htmlde" rot setprop
      else
         pop
      then
   then
(AnsiDesc) (* For NeonLook v2.0, when it comes out *)
   oloc @ "_morph/%n/ansidesc" newrace @ "%n" subst getpropstr strip dup if
      me @ "_/anside" rot setprop
   else
      pop oloc @ "_morph/def/ansidesc" getpropstr strip dup if
         me @ "_/anside" rot setprop
      else
         pop
      then
   then
$endif
(Sex)
   oloc @ "_morph/%n/sex" newrace @ "%n" subst getpropstr strip dup if
      me @ PROPS-gender rot setprop
   else
      pop oloc @ "_morph/def/sex" getpropstr strip dup if
         me @ PROPS-gender rot setprop
      else
         pop
      then
   then
(Alias)
   oloc @ "_morph/%n/alias" newrace @ "%n" subst getpropstr strip dup if
      me @ "%n" rot setprop
   else
      pop oloc @ "_morph/def/alias" getpropstr strip dup if
         me @ "%n" rot setprop
      else
         pop
      then
   then
 
   (* Set Custom Props *)
   1 begin
      oloc @ "_morph/%n/prop-%i" newrace @ "%n" subst 3 pick intostr "%i" subst
      getpropstr strip dup not if
         pop pop break
      else
         swap 1 + swap
      then
      dup "=" instr if
         dup "=" instr 1 - strcut 1 strcut swap pop strip swap
         strip swap me @ rot rot setprop
      else
         me @ swap remove_prop
      then
   repeat
 
   (* Set Current Race *)
   me @ "_race" newrace @ setprop
   me @ "_race-name" racename @ setprop
;
 
lvar oloc
: List-Morphs ( -- )
   me @ oproploc dup oloc ! "_morph/use/"
   me @ "^WHITE^Your current morphs are:" Ansi_Notify
   me @ " " notify
   begin
      nextprop
      dup not if
         pop break
      then
      oloc @ over getpropstr dup "y" stringpfx over "o" stringpfx or and if
         dup 11 strcut swap pop
         "_morph/%n/name" over "%n" subst oloc @ swap getpropstr strip
         dup not if
            pop
         else
            "^WHITE^(^GRAY^%m^WHITE^)" strcat swap "%m" subst
         then
         "^CYAN^" swap strcat me @ swap Ansi_Notify
      then
      oloc @ swap
   repeat
   me @ " " notify
   me @ "^WHITE^You currently are a %m."
   me @ "_race-name" getpropstr strip "%m" subst Ansi_Notify
;
 
lvar oloc
lvar editrace
lvar tempstr
: MsgEditor ( sEditRace -- )
   editrace !
   begin
      me @ " " notify
      me @ "^WHITE^A list of morphs/messages:" Ansi_Notify
      me @ " " notify
      me @ oproploc dup oloc ! "_morph/use/"
      begin
         nextprop
         dup not if
            pop break
         then
         oloc @ over getpropstr strip "yes" over stringpfx "ok" 3 pick stringpfx or and
         oloc @ 3 pick 11 strcut swap pop "_morph/%n/random?" swap "%n" subst
         getpropstr strip "yes" over stringpfx and not and over 11 strcut swap pop
         editrace @ stringcmp not not and if
            dup 11 strcut swap pop dup tempstr !
            "_morph/%n/name" over "%n" subst oloc @ swap getpropstr strip
            dup not if
               pop "^WHITE^: " strcat
            else
               "^WHITE^(^GRAY^%m^WHITE^): " strcat swap "%m" subst
            then
            "^CYAN^" swap strcat
            oloc @ "_morph/%n/" editrace @ "%n" subst
            4 pick 11 strcut swap pop strcat getpropstr strip dup not if
               pop " morphs into a %n." tempstr @ "%n" subst
            then
            me @ "%n" pronoun_sub " " strcat swap strcat strcat me @ swap Ansi_Notify
         then
         oloc @ swap
      repeat
      me @ " " notify
      me @ "^WHITE^You acurrently are editing %m." editrace @ "%m" subst Ansi_Notify
      me @ " " notify
      me @ "^CYAN^Type in the name of the morph to change, below (.q quits):" Ansi_Notify
      read oloc @ "_morph/use/" 3 pick strcat getpropstr strip
      "yes" over stringpfx "ok" 3 pick stringpfx or and over ".q" stringcmp not not and if
         oloc @ "_morph/%n/random?" tempstr @ "%n" subst getpropstr strip
         "yes" over stringpfx and not if
            dup editrace @ stringcmp not not if
               oloc @ "_morph/%n/" rot strcat editrace @ "%n" subst
               me @ " " notify
               me @ "^CYAN^Type in the new message below:" Ansi_Notify
               read setprop me @ "^GREEN^Set." Ansi_Notify
            else
               pop me @ "^RED^Thats the same race you are editing!" Ansi_Notify
            then
         else
            pop me @ "^RED^Thats a random morph!" Ansi_Notify
         then
      else
         me @ " " notify
         ".q" stringcmp not if
            me @ "^GREEN^Done." Ansi_Notify break
         else
            me @ "^RED^Invalid race." Ansi_Notify
         then
         me @ " " notify
      then
   repeat
;
lvar editrace
lvar oloc
: PropEditor ( s -- )
   strip editrace !
   me @ oproploc oloc !
   begin
      me @ " " notify
      me @ "^CYAN^Prop-Editor v2.72 - by Van@Beta" Ansi_Notify
      me @ "^WHITE^================================" Ansi_Notify
      me @ " " notify
      me @ "^WHITE^[^CYAN^1^WHITE^] ^YELLOW^%m"
      oloc @ "_morph/%n/prop-1" editrace @ "%n" subst getpropstr strip "%m" subst Ansi_Notify
      me @ "^WHITE^[^CYAN^2^WHITE^] ^YELLOW^%m"
      oloc @ "_morph/%n/prop-2" editrace @ "%n" subst getpropstr strip "%m" subst Ansi_Notify
      me @ "^WHITE^[^CYAN^3^WHITE^] ^YELLOW^%m"
      oloc @ "_morph/%n/prop-3" editrace @ "%n" subst getpropstr strip "%m" subst Ansi_Notify
      me @ "^WHITE^[^CYAN^4^WHITE^] ^YELLOW^%m"
      oloc @ "_morph/%n/prop-4" editrace @ "%n" subst getpropstr strip "%m" subst Ansi_Notify
      me @ "^WHITE^[^CYAN^5^WHITE^] ^YELLOW^%m"
      oloc @ "_morph/%n/prop-5" editrace @ "%n" subst getpropstr strip "%m" subst Ansi_Notify
      me @ "^WHITE^[^CYAN^6^WHITE^] ^YELLOW^%m"
      oloc @ "_morph/%n/prop-6" editrace @ "%n" subst getpropstr strip "%m" subst Ansi_Notify
      me @ "^WHITE^[^CYAN^7^WHITE^] ^YELLOW^%m"
      oloc @ "_morph/%n/prop-7" editrace @ "%n" subst getpropstr strip "%m" subst Ansi_Notify
      me @ "^WHITE^[^CYAN^8^WHITE^] ^YELLOW^%m"
      oloc @ "_morph/%n/prop-8" editrace @ "%n" subst getpropstr strip "%m" subst Ansi_Notify
      me @ "^WHITE^[^CYAN^9^WHITE^] ^YELLOW^%m"
      oloc @ "_morph/%n/prop-9" editrace @ "%n" subst getpropstr strip "%m" subst Ansi_Notify
      me @ "^WHITE^[^CYAN^Q^WHITE^] ^BLUE^Quit" Ansi_Notify
      begin
         read
         strip "123456789Q" over instring over strlen 1 = and if
            break
         else
            pop
         then
      repeat
      dup "Q" stringcmp not if
         pop break
      then
      me @ "^CYAN^Enter the new prop setting (prop=string setting) ^WHITE^[prop #%n]:"
      3 pick "%n" subst Ansi_Notify
      read oloc @ "_morph/%n/prop-%o" 4 rotate "%o" subst editrace @ "%n" subst rot setprop
      me @ "^GREEN^Prop set." Ansi_Notify
   repeat
;
 
: BlockEditor ( s -- )
   editrace !
   begin
      me @ " " notify
      me @ "^WHITE^A list of morphs/messages:" Ansi_Notify
      me @ " " notify
      me @ oproploc dup oloc ! "_morph/use/"
      begin
         nextprop
         dup not if
            pop break
         then
         oloc @ over getpropstr strip "yes" over stringpfx "ok" 3 pick stringpfx or and
         oloc @ 3 pick 11 strcut swap pop "_morph/%n/random?" swap "%n" subst
         getpropstr strip "yes" over stringpfx and not and over 11 strcut swap pop
         editrace @ stringcmp not not and if
            dup 11 strcut swap pop dup tempstr !
            "_morph/%n/name" over "%n" subst oloc @ swap getpropstr strip
            dup not if
               pop "^WHITE^: " strcat
            else
               "^WHITE^(^GRAY^%m^WHITE^): " strcat swap "%m" subst
            then
            "^CYAN^" swap strcat
            oloc @ "_morph/use/%n-" editrace @ "%n" subst
            4 pick 11 strcut swap pop strcat getpropstr strip "no" over stringpfx and if
               "No."
            else
               "Yes."
            then
           strcat me @ swap Ansi_Notify
         then
         oloc @ swap
      repeat
      me @ " " notify
      me @ "^WHITE^You acurrently are editing %m." editrace @ "%m" subst Ansi_Notify
      me @ " " notify
      me @ "^CYAN^Type in the name of the morph to change, below (.q quits):" Ansi_Notify
      read oloc @ "_morph/use/" 3 pick strcat getpropstr strip
      "yes" over stringpfx "ok" 3 pick stringpfx or and over ".q" stringcmp not not and if
         oloc @ "_morph/%n/random?" tempstr @ "%n" subst getpropstr strip
         "yes" over stringpfx and not if
            dup editrace @ stringcmp not not if
               oloc @ "_morph/use/%n-" rot strcat editrace @ "%n" subst
               me @ " " notify
               me @ "^CYAN^Type in the new message below:" Ansi_Notify
               read setprop me @ "^GREEN^Set." Ansi_Notify
            else
               pop me @ "^RED^Thats the same race you are editing!" Ansi_Notify
            then
         else
            pop me @ "^RED^Thats a random morph!" Ansi_Notify
         then
      else
         me @ " " notify
         ".q" stringcmp not if
            me @ "^GREEN^Done." Ansi_Notify break
         else
            me @ "^RED^Invalid race." Ansi_Notify
         then
         me @ " " notify
      then
   repeat
;
 
lvar oloc
lvar editrace
: Edit-Morph ( s -- )
   dup "def" stringcmp not over "use" stringcmp not or over "alias" stringcmp not or if
      pop me @ "^RED^Invalid race." Ansi_Notify exit
   then
 
   me @ oproploc dup oloc ! "_morph/use/" 3 pick strcat getpropstr dup "o" stringpfx and
   oloc @ "_morph/use/" 4 pick strcat getpropstr dup "y" stringpfx and or not if
      me @ "^RED^That race does not exist." Ansi_Notify exit
   then
 
   me @ oproploc oloc ! editrace !
 
   oloc @ "_morph/%n/random?" editrace @ "%n" subst getpropstr strip dup "y" stringpfx and if
      me @ "^RED^This is a random morph, not a regular morph." Ansi_Notify exit
   then
 
   begin
      me @ "^WHITE^Morph Editor v2.72 - by Van@Beta ^CYAN^(^GRAY^Editing: %n^CYAN^)"
      editrace @ "%n" subst Ansi_Notify
      me @ " " notify
      me @ "^WHITE^[^YELLOW^1^WHITE^] ^CYAN^Morph Name: ^WHITE^[^GRAY^%m^WHITE^]"
      oloc @ "_morph/%n/name" editrace @ "%n" subst getpropstr strip dup not if
         pop "None Set"
      else
         "^^" "^" subst
      then
      dup strlen 100 > if
         97 strcut pop "..." strcat
      then
      "%m" subst Ansi_Notify
      me @ "^WHITE^[^YELLOW^2^WHITE^] ^CYAN^Morph Gender: ^WHITE^[^GRAY^%m^WHITE^]"
      oloc @ "_morph/%n/sex" editrace @ "%n" subst getpropstr strip dup not if
         pop "None Set"
      else
         "^^" "^" subst
      then
      dup strlen 100 > if
         97 strcut pop "..." strcat
      then
      "%m" subst Ansi_Notify
      me @ "^WHITE^[^YELLOW^3^WHITE^] ^CYAN^Morph Desc: ^WHITE^[^GRAY^%m^WHITE^]"
      oloc @ "_morph/%n/desc" editrace @ "%n" subst getpropstr strip dup not if
         pop "None Set"
      else
         "^^" "^" subst
      then
      dup strlen 100 > if
         97 strcut pop "..." strcat
      then
      "%m" subst Ansi_Notify
$ifdef __neon
      me @ "^WHITE^[^YELLOW^4^WHITE^] ^CYAN^Morph HtmlDesc: ^WHITE^[^GRAY^%m^WHITE^]"
      oloc @ "_morph/%n/htmldesc" editrace @ "%n" subst getpropstr strip dup not if
         pop "None Set"
      else
         "^^" "^" subst
      then
      dup strlen 100 > if
         97 strcut pop "..." strcat
      then
      "%m" subst Ansi_Notify
      me @ "^WHITE^[^YELLOW^5^WHITE^] ^CYAN^Morph AnsiDesc: ^WHITE^[^GRAY^%m^WHITE^]"
      oloc @ "_morph/%n/ansidesc" editrace @ "%n" subst getpropstr strip dup not if
         pop "None Set"
      else
         "^^" "^" subst
      then
      dup strlen 100 > if
         97 strcut pop "..." strcat
      then
      "%m" subst Ansi_Notify
$endif
      me @ "^WHITE^[^YELLOW^6^WHITE^] ^CYAN^Morph Alias: ^WHITE^[^GRAY^%m^WHITE^]"
      oloc @ "_morph/%n/alias" editrace @ "%n" subst getpropstr strip dup not if
         pop me @ name "^^" "^" subst
      else
         "^^" "^" subst
      then
      dup strlen 100 > if
         97 strcut pop "..." strcat
      then
      "%m" subst Ansi_Notify
      me @ "^WHITE^[^YELLOW^7^WHITE^] ^CYAN^Morphing message editor." Ansi_Notify
      me @ "^WHITE^[^YELLOW^8^WHITE^] ^CYAN^Morph propsetting editor." Ansi_Notify
      me @ "^WHITE^[^YELLOW^9^WHITE^] ^CYAN^Morph blocking editor." Ansi_Notify
      me @ "^WHITE^[^YELLOW^Q^WHITE^] ^RED^Quit the editor" Ansi_Notify
      me @ " " notify
      me @ "^WHITE^Enter option [1-9,Q]:" Ansi_Notify
      begin
         read
$ifdef __neon
         "#1#2#3#4#5#6#7#8#9#Q#" "#" 3 pick strcat "#" strcat instring if
$else
         "#1#2#3#6#7#8#9#Q#" "#" 3 pick strcat "#" strcat instring if
$endif
            break
         else
            pop
         then
      repeat
      dup "Q" stringcmp not if
         me @ " " notify
         me @ "^YELLOW^Quiting morph editor." Ansi_Notify
         pop break
      then
      dup "1" stringcmp not if
         me @ "^YELLOW^Enter the morphs name, below: [ '.' keep old one, or '.c' to clear]"
         Ansi_Notify
         read
         dup ".c" stringcmp not if
            oloc @ "_morph/%n/name" editrace @ "%n" subst remove_prop pop
            me @ "^RED^Cleared." Ansi_Notify
         else
            dup "." stringcmp if
               oloc @ "_morph/%n/name" editrace @ "%n" subst rot setprop
               me @ "^GREEN^Set." Ansi_Notify
            else
               pop
            then
         then
      then
      dup "2" stringcmp not if
         me @ "^YELLOW^Enter the morphs gender, below: [ '.' keep old one, or '.c' to clear]"
         Ansi_Notify
         read
         dup ".c" stringcmp not if
            oloc @ "_morph/%n/sex" editrace @ "%n" subst remove_prop pop
            me @ "^RED^Cleared." Ansi_Notify
         else
            dup "." stringcmp if
               oloc @ "_morph/%n/sex" editrace @ "%n" subst rot setprop
               me @ "^GREEN^Set." Ansi_Notify
            else
               pop
            then
         then
      then
      dup "3" stringcmp not if
         me @ "^YELLOW^Enter the morphs desc, below: [ '.' keep old one, or '.c' to clear]"
         Ansi_Notify
         read
         dup ".c" stringcmp not if
            oloc @ "_morph/%n/desc" editrace @ "%n" subst remove_prop pop
            me @ "^RED^Cleared." Ansi_Notify
         else
            dup "." stringcmp if
               oloc @ "_morph/%n/desc" editrace @ "%n" subst rot setprop
               me @ "^GREEN^Set." Ansi_Notify
            else
               pop
            then
         then
      then
$ifdef __neon
      dup "4" stringcmp not if
         me @ "^YELLOW^Enter the morphs HtmlDesc, below: [ '.' keep old one, or '.c' to clear]"
         Ansi_Notify
         read
         dup ".c" stringcmp not if
            oloc @ "_morph/%n/htmldesc" editrace @ "%n" subst remove_prop pop
            me @ "^RED^Cleared." Ansi_Notify
         else
            dup "." stringcmp if
               oloc @ "_morph/%n/htmldesc" editrace @ "%n" subst rot setprop
               me @ "^GREEN^Set." Ansi_Notify
            else
               pop
            then
         then
      then
      dup "5" stringcmp not if
         me @ "^YELLOW^Enter the morphs AnsiDesc, below: [ '.' keep old one, or '.c' to clear]"
         Ansi_Notify
         read
         dup ".c" stringcmp not if
            oloc @ "_morph/%n/ansidesc" editrace @ "%n" subst remove_prop pop
            me @ "^RED^Cleared." Ansi_Notify
         else
            dup "." stringcmp if
               oloc @ "_morph/%n/ansidesc" editrace @ "%n" subst rot setprop
               me @ "^GREEN^Set." Ansi_Notify
            else
               pop
            then
         then
      then
$endif
      dup "6" stringcmp not if
         me @ "^YELLOW^Enter the morphs alias, below: [ '.' keep old one, or '.c' to clear]"
         Ansi_Notify
         read
         dup ".c" stringcmp not if
            oloc @ "_morph/%n/alias" editrace @ "%n" subst remove_prop pop
            me @ "^RED^Cleared." Ansi_Notify
         else
            dup "." stringcmp if
               oloc @ "_morph/%n/alias" editrace @ "%n" subst rot setprop
               me @ "^GREEN^Set." Ansi_Notify
            else
               pop
            then
         then
      then
      dup "7" stringcmp not if
         editrace @ msgeditor
      then
      dup "8" stringcmp not if
         editrace @ propeditor
      then
      dup "9" stringcmp not if
         editrace @ blockeditor
      then
      pop
   repeat
;
 
: New-Morph ( s -- )
   dup "def" stringcmp not over "use" stringcmp not or over "alias" stringcmp not or if
      pop me @ "^RED^Invalid race." Ansi_Notify exit
   then
 
   me @ oproploc "_morph/use/" 3 pick strcat "ok" setprop
   Edit-Morph
;
 
lvar oloc
: Del-Morph ( s -- )
   dup "def" stringcmp not over "use" stringcmp not or over "alias" stringcmp not or if
      pop me @ "^RED^Invalid race." Ansi_Notify exit
   then
 
   me @ oproploc dup oloc ! "_morph/use/" 3 pick strcat getpropstr dup "o" stringpfx
   over dup "y" stringpfx and rot rot and or if
      oloc @ "_morph/use/" 3 pick strcat remove_prop
      oloc @ "_morph/" rot strcat remove_prop
      me @ "^GREEN^Morph removed." Ansi_Notify
   else
      me @ "^RED^That race does not exist." Ansi_Notify
   then
;
 
: Add-Rand ( s -- )
   dup "=" instr not if
      pop me @ "^RED^Incorrect Syntax." Ansi_Notify exit
   then
   dup "=" instr 1 - strcut 1 strcut swap pop
   me @ oproploc "_morph/%n/random?" 4 pick "%n" subst getpropstr
   strip dup "y" stringpfx and if
      me @ oproploc "_morph/%n/rand#" 4 pick "%n" subst getpropstr strip atoi 1 +
      me @ oproploc "_morph/%n/rand#" 5 pick "%n" subst 3 pick intostr setprop
      me @ oproploc "_morph/%n/rand#/" 5 rotate "%n" subst rot intostr strcat
      rot setprop me @ "^GREEN^Random morph added." Ansi_Notify
   else
      pop pop me @ "^RED^Not a random morph." Ansi_Notify
   then
;
 
lvar tempstr
lvar tempint
: Rand-Pos? ( s1 s2 -- i )
   swap
   dup "def" stringcmp not over "use" stringcmp not or over "alias" stringcmp not or if
      pop me @ "^RED^Invalid race." Ansi_Notify exit
   then
   me @ oproploc "_morph/%n/random?" 3 pick "%n" subst getpropstr
   strip "yes" over stringpfx and if
      swap tempstr !
      me @ oproploc "_morph/%n/rand" rot "%n" subst ARRAY_get_proplist ARRAY_vals
      dup 0 > if
         begin
            over tempstr @ stringcmp not if
               dup tempint ! popn tempint @ break
            else
               swap pop
            then
            1 - dup
         0 = until
      then
   else
      pop pop 0
   then
;
 
: Rem-Rand ( s -- )
   dup "=" instr not if
      pop me @ "^RED^Incorrect Syntax." Ansi_Notify exit
   then
   dup "=" instr 1 - strcut 1 strcut swap pop
   me @ oproploc "_morph/%n/random?" 4 pick "%n" subst getpropstr
   strip dup "y" stringpfx and if
      over over Rand-Pos? dup if
         swap pop
         me @ oproploc "_morph/%n/rand#/" rot intostr strcat rot "%n" subst "def" setprop
         me @ "^GREEN^Random morph removed." Ansi_Notify
      else
         pop pop pop me @ "^RED^Not in random morph." Ansi_Notify
      then
   else
      pop pop me @ "^RED^Not a random morph." Ansi_Notify
   then
;
 
: Create-Rand ( s -- )
   dup "def" stringcmp not over "use" stringcmp not or over "alias" stringcmp not or if
      pop me @ "^RED^Invalid race." Ansi_Notify exit
   then
   me @ oproploc "_morph/%n/random?" 3 pick "%n" subst getpropstr
   strip dup "y" stringpfx and if
      pop me @ "^RED^Random morph allready exits." Ansi_Notify
   else
      me @ oproploc "_morph/use/%n" 3 pick "%n" subst "ok" setprop
      me @ oproploc "_morph/%n/random?" rot "%n" subst "yes" setprop
      me @ "^GREEN^Random morph created." Ansi_Notify
   then
;
 
: Show-Rand ( s -- )
   dup "def" stringcmp not over "use" stringcmp not or over "alias" stringcmp not or if
      pop me @ "^RED^Invalid race." Ansi_Notify exit
   then
   me @ oproploc "_morph/%n/random?" 3 pick "%n" subst getpropstr
   strip dup "y" stringpfx and if
      me @ "^WHITE^Current morphs in the random morph ^WHITE^(^GRAY^%n^WHITE^):"
      3 pick "%n" subst Ansi_Notify
      me @ oproploc "_morph/%n/rand" rot "%n" subst ARRAY_get_proplist ARRAY_vals
      dup 0 > if
         begin
            dup 1 + rotate me @ "^CYAN^" rot strcat Ansi_Notify
            1 - dup
         0 = until
      then
      pop
      me @ "^YELLOW^*Done*" Ansi_Notify
   else
      me @ "^RED^Random morph doesn't exist!" Ansi_Notify
   then
;
 
: Do-Help ( -- )
   me @ "^CYAN^Morph v2.72 - by Van@Beta" Ansi_Notify
   me @ "^WHITE^=========================" Ansi_Notify
   me @ "Morph #help          - This screen" Notify
   me @ "Morph #props         - Display all of the morph properties" Notify
   me @ "Morph #note          - Whats new for morph" Notify
   me @ "Morph #new <morph>   - Make a new morph with the morph editor" Notify
   me @ "Morph #edit <morph>  - Edit an old morph with the morph editor" Notify
   me @ "Morph #del <morph>   - Delete an old morph" Notify
   me @ "Morph #list          - List all morphs in existance" Notify
   me @ "Morph #add <random morph>=<morph>" Notify
   me @ "                     - Will add morph to the list for random morph" Notify
   me @ "Morph #rem <random morph>=<morph>" Notify
   me @ "                     - Will remove morph from the list for the random morph" Notify
   me @ "Morph #rand <name>   - Create a random morph with name as its name" Notify
   me @ "Morph #show <morph>  - Show what random morphs there are under morph" Notify
   me @ "Morph #proploc <obj> - Change the morph proploc" Notify
   me @ "Morph <morph>        - Morph into the race <morph>" Notify
   me @ "Morph +<morph>       - Morph, but overide all restrictions" Notify
   me @ "Morph -<morph>       - Do a quiet morph" Notify
   me @ "Morph <morph>=<msg>  - Morph, using <msg> to overide the default one" Notify
   me @ "^YELLOW^*Done*" Ansi_Notify
;
 
: Morph-Props ( -- )
   me @ "^CYAN^Morph v2.71 - by Van@Beta" Ansi_Notify
   me @ "^WHITE^=========================" Ansi_Notify
   me @ "To set a proploc/object for your morph props, set on yourself:" Notify
   me @ "(Default is to yourself)" Notify
   me @ " " Notify
   me @ "_morph_proploc  or  _proploc  - points to the object that carrys the props" Notify
   me @ " " Notify
   me @ "Set on the proploc (Needed props):" Notify
   me @ " " Notify
   me @ "_Morph/Use/<MorphName>:ok     - Allows this morph to be used" Notify
   me @ " " Notify
   me @ "Useful props set on the proploc:" Notify
   me @ " " Notify
   me @ "_Morph/<MorphName>/Desc       - Changes the normal desc in a morph" Notify
$ifdef __neon
   me @ "_Morph/<MorphName>/AnsiDesc   - As above, ansidesc (Needs NeonLook v2)" Notify
   me @ "_Morph/<MorphName>/HtmlDesc   - As above, htmldesc" Notify
$endif
   me @ "_Morph/<MorphName>/Name       - Set an alternative name for the morph" Notify
   me @ "_Morph/<MorphName>/Alias      - Change your alias when morphing" Notify
   me @ "_Morph/<MorphName>/<NewMorph>-alias?:no" Notify
   me @ "                              - Don't use the alias when morphing to <NewMorph>" Notify
   me @ "_Morph/<MorphName>/Sex        - Change your gender during morph" Notify
   me @ "_Morph/<OldMorph>/<NewMorph>  - Set the message used when morphing, allows" Notify
   me @ "                              - sub pronouns, starts with chars name/alias" Notify
   me @ "_Morph/Use/<OldMorph>-<NewMorph>:no" Notify
   me @ "                              - Don't allow morphing between the two" Notify
   me @ "_Morph/<MorphName>/Prop-?:<Proptoset>=<Text>" Notify
   me @ "                              - Sets <Text> in the prop, <Proptoset> on" Notify
   me @ "                              - yourself during morphing." Notify
   me @ "_Morph/<MorphName>/Random?:y  - Make <MorphName> a random morph instead" notify
   me @ "                              - of a normal one, uses the next listfile for it" notify
   me @ "_Morph/<MorphName>/Rand       - The lsedit list used for random morphs, is" notify
   me @ "                              - set as: lsedit me=_morph/<morphname>/rand" notify
   me @ "^YELLOW^*Done*" Ansi_Notify
;
 
: Morph-New ( -- )
   me @ "^CYAN^Morph v2.71 - by Van@Beta" Ansi_Notify
   me @ "^WHITE^=Whats New?==============" Ansi_Notify
   me @ "1.7 - Now allows 'random' morphing [ie. Choose a random morph from a" notify
   me @ "    - listfile] for certain morphs, if setup properly." notify
   me @ "    - Now prevents people from morphing to the 'def' or 'use' morph" notify
   me @ "    - Now prevents people from morphing to their current morph" notify
   me @ "    - Fixed the alias bug, now defaulted to being on" notify
   me @ "    - Now uses a 'version check' like page does" notify
   me @ "2.0 - Is now TinyMuckfb compatible, and uses $lib/muftools instead of $lib/ansi" notify
   me @ "    - Fixed up the random morphing to be a bit more accurate" notify
   me @ "    - Added a random morph editor" notify
   me @ "2.5 - Added the 'morph #rem' and 'morph #show' commands" notify
   me @ "    - Prevented any morphing of neonmuck enhancements on tinymuckfb mucks now" notify
   me @ "    - Actually added stuff to preventing morphing to 'alias' [forgot that one!]" notify
   me @ "    - Added a 'morph message' editor [finally!]" notify
   me @ "    - Fixed the proploc problems [Pointed out by Skuld, thanks!]" notify
   me @ "2.7 - Added a prop-? editor into the morph editor" notify
   me @ "    - Added the '/use/morph1-morph2:no' for preventing morphing, in the" notify
   me @ "      morph editor" notify
   me @ "    - Added an option to change the 'proploc' as well" notify
   me @ "    - Fixed *more* proploc problems [Thanks, Skuld!]" notify
   me @ "2.71- Fixed the _race / _race-name props to be set on the user not proploc" notify
   me @ "    - Got rid of he 'version check' .. no need for it since updates will be" notify
   me @ "      slower, and smaller" notify
   me @ "2.72- Removed $lib/lmgr and $lib/muftools" notify
   me @ "    - Added $lib/standard support" notify
   me @ "^WHITE^=To do list=============" Ansi_Notify
   me @ "Any ideas?  'mail Van@Beta'" Notify
   me @ "^WHITE^=Note from Author=======" Ansi_Notify
   me @ "Permission to port this, as long as code is left intact and credit is left" notify
   me @ "where itis due.  Type @list #%n to list the code." prog int intostr "%n" subst notify
   me @ "^YELLOW^*Done*" Ansi_Notify
;
 
lvar fromdb
lvar todb
: MovePropDir ( d d' s -- )
   swap fromdb ! swap todb !
   dup dup strlen 1 - "/" swap strncmp not not if
      "/" strcat
   then
   begin
      fromdb @ swap nextprop
      dup not if
         pop break
      then
      fromdb @ over propdir? if
         todb @ fromdb @ 3 pick MovePropDir
      else
         fromdb @ over getprop todb @ 3 pick rot setprop
      then
   repeat
;
 
lvar oloc
: MovetoProploc ( d -- )
   me @ oproploc oloc !
   dup me @ dbcmp not if
      me @ "_morph_proploc" 3 pick int intostr setprop
   else
      me @ "_morph_proploc" remove_prop
   then
   oloc @ "_morph" movepropdir
   oloc @ "_morph" remove_prop
   me @ "^GREEN^Proploc changed successfully." Ansi_notify exit
;
 
: Change-Proploc ( s -- )
   match
   dup #-1 dbcmp if
      pop me @ "^YELLOW^I don't see that here." Ansi_Notify exit
   then
   dup #-2 dbcmp if
      pop me @ "^YELLOW^I don't know which one you mean!" Ansi_Notify exit
   then
   dup ok? not if
      pop me @ "^RED^Permission denied." Ansi_Notify exit
   then
   dup owner me @ owner dbcmp me @ owner IsWiz? or not if
      pop me @ "^RED^Permission denied." Ansi_Notify exit
   then
   MovetoProploc
;
 
: Cmd-Morph ( s -- )
  me @ "G" flag? if
    "^GREEN^[ ^YELLOW^Sorry, Guests can't use morph. ^GREEN^]" .atell exit
  then
   prog "V" flag? not if
      prog "V" set
   then
   prog "L" flag? not if
      prog "L" set
   then
   me @ sme !
(*   version-check *)
   strip dup not if
      me @ "_race-name" getpropstr strip
      me @ "^WHITE^You are currently a %m." rot "%m" subst Ansi_Notify exit
   then
   dup "#help" stringcmp not if
      pop Do-Help exit
   then
   dup "#props" stringcmp not if
      pop Morph-Props exit
   then
   dup "#note" stringcmp not if
      pop Morph-New exit
   then
   dup "#new " stringpfx if
      5 strcut swap pop strip New-Morph exit
   then
   dup "#edit " stringpfx if
      6 strcut swap pop strip Edit-Morph exit
   then
   dup "#del " stringpfx if
      5 strcut swap pop strip Del-Morph exit
   then
   dup "#list" stringcmp not if
      pop List-Morphs exit
   then
   dup "#add " stringpfx if
      5 strcut swap pop strip Add-Rand exit
   then
   dup "#rem " stringpfx if
      5 strcut swap pop strip Rem-Rand exit
   then
   dup "#rand " stringpfx if
      6 strcut swap pop strip Create-Rand exit
   then
   dup "#show " stringpfx if
      6 strcut swap pop Show-Rand exit
   then
   dup "#proploc " stringpfx if
      9 strcut swap pop Change-Proploc exit
   then
   dup "#edit" stringcmp not if
      pop me @ "^RED^Required syntax missing." Ansi_Notify exit
   then
   dup "#new" stringcmp not if
      pop me @ "^RED^Required syntax missing." Ansi_Notify exit
   then
   dup "#del" stringcmp not if
      pop me @ "^RED^Required syntax missing." Ansi_Notify exit
   then
   dup "#add" stringcmp not if
      pop me @ "^RED^Required syntax missing." Ansi_Notify exit
   then
   dup "#rem" stringcmp not if
      pop me @ "^RED^Required syntax missing." Ansi_Notify exit
   then
   dup "#rand" stringcmp not if
      pop me @ "^RED^Required syntax missing." Ansi_Notify exit
   then
   dup "#show" stringcmp not if
      pop me @ "^RED^Required syntax missing." Ansi_Notify exit
   then
   dup "#proploc" stringcmp not if
      pop me @ "^RED^Required syntax missing." Ansi_Notify exit
   then
   dup "=" instr if
      dup "=" instr 1 - strcut 1 strcut swap pop usemesg !
   then
   dup "+" stringpfx if
      1 strcut swap pop strip 1 bypassl !
   else
      0 bypassl !
   then
   dup "-" stringpfx if
      1 strcut swap pop strip 1 quietm !
   else
      0 quietm !
   then
   me @ oproploc "_morph/alias/" 3 pick strcat getpropstr strip dup not if
      pop
   else
      swap pop
   then
   me @ "_race" getpropstr strip swap Do-Morph exit
;
