(*
   Lib-Look v2.11 [ProtoLook]
   Last Update: January 31st, 2003
   Author: Chris Brine [Moose]
   E-Mail: contikimoose@hotmail.com
 
   Note: This program *must* be @registered as $Lib/Look and $Cmd/Look
 
  v2.11:  - Fixed up the definitions, so that some of the
            missing old ones work.  Also added backward
            compatability for the old db-show-cont and
            db-show-exit.  Thankfully the new versions have
            new function names.
  v2.10:  - Added the expanded custom look.  Now any object
            type is customizable.
          - Seperated the personal custom looks and the
            internal ones.  This may cause some compatability
            problems, but at least now it works better than
            before.
          - Removed the force format option.  Except in the
            case of globaly itself.  That's it.
          - Fixed a bug with the parameters that caused look
            to crash.  So now M[] will actually work.
          - Added an F[] option to the custom look to call
            MUF programs.  A third argument can be used
            for the arguments.  What is returned in a
            string can be used for more custom look functions.
          - Added another MPI function, this one P[], which
            will allow one to return more custom look
            functions so you can do some funky stuff.
          - Fixed a bug where the long contents display did
            not show the fake objects.  Now it does.
          - Fixed a bug where the neon exits listing did not
            escape the ansi code when it should have.  Whoops.
          - Added customization for contents and exits.
            Contents:
              C[, 0]: This is the default for whatever object.
              C[, 1]: Default for whatever object for NeonLook.
              C[, 2]: Default for object for StandardLook.
              C[, 3]: This is for the sorted listing.
              C[, 4]: The short listing, always show.
              C[, 5]: The short listing, show if contents exist.
              C[, 6]: Two line listing, always show.
              C[, 7]: A two line listing, title above.
              C[, 8]: A long listing of the contents.
            Exits:
              E[, 0]: This is the default for whatever object.
              E[, 1]: Default for whatever object for NeonLook.
              E[, 2]: Default for object for StandardLook.
              E[, 3]: Short display, colored.
              E[, 4]: Short display, no color.
              E[, 5]: Short display, color, Actions:.
              E[, 6]: Short display, no color, Actions:.
              E[, 7]: Long display, color.
              E[, 8]: Long display, no color.
              E[, 9]: Long display, long name.
              E[,10]: Long display, long name, no color.
          - Completed a muchly expanded documentation, which
            now covers everything in look.
          - Rewrote the options editor to include how the
            custom look works now.  Also uses $Lib/Menu for it.
          - Moved all of the unmoved props to $Lib/Standard.
  v2.02:  Fixed up the code a little.
          The look notify now supports ANSI.  Moved props to
          $defs, so they're moved to $lib/standard.  Also
          removed support for out of date props, such as
          /_Prefs/Container? and _Visible?.  One can use the
          LIGHT flag instead, and the $lib/standard settable
          prop for containers.  Speeds things up, which is
          a good thing[tm].  Also added the expanded custom
          look, which allows for L[RT] type routines, to, say,
          show a line for only rooms or things.  Plus, MPI can
          be ran using the M[,{mpi here}] function.  It basicly
          works like this: ?[TYPES,args].  So far, only the M[]
          command takes arguments.  Eventually exits and
          contents will as well, which will also make the
          exits and contents functions work differently.
          TO ALSO DO: Added the expanded custom look, at last.
          * Finish with props first!
  v2.01:  Added $lib/standard support.  Keep in mind that some
          properties will no long work.  You have to change
          $lib/standard to change what property is used, for
          anything listed there that's used in look.
 *)
 
$author Moose
$lib-version 2.11
$version 2.11
 
$nomacros
$cleardefs ALL
 
$def LOOK-pref_terse?           SETTING-look_terse
$def LOOK-prop_lock_desc        SETTING-desc_lock
$def LOOK-prop_lock_look        SETTING-look_lock
$def LOOK-prop_exit_lookthru    SETTING-exit_lookthru
$def LOOK-prop_exit_notify      SETTING-exit_notify
$def LOOK-prop_exit_format_show SETTING-exit_shown
$def LOOK-prop_look_notify      SETTING-look_notify
$def LOOK-prop_looker_notify    SETTING-looker_notify
$def LOOK-prop_tattle_notify    SETTING-tattle_notify
$def LOOK-prop_exit_listing     SETTING-exits_listing
$def LOOK-prop_contents_listing SETTING-contents_list
 
$include $Lib/Arrays
$include $Lib/CGI
$include $Lib/Fakes
$include $Lib/Menu
$include $Lib/Objects
$include $Lib/ObjEditors
$include $Lib/Standard
 
: ToInt ( ?? -- int )
   dup String? IF
      atoi
   ELSE
      dup Float? IF
         int
      ELSE
         dup Dbref? IF
            int
         ELSE
            dup Int? not IF
               pop 0
            THEN
         THEN
      THEN
   THEN
;
 
: LOOK-standard[ ref:REFplyr ref:ref -- ref:ref int:INTstnd ]
( 0 = DefDefault, 1 = ProtoLook, 2 = NeonLook, 3 = StandardLook, 4 = Custom )
   VAR temp
   prog LOOK-pref_force_fmt? getpropstr "y" stringpfx IF
      prog dup temp ! LOOK-pref_look_stnd_me? getprop ToInt dup not IF
         pop #-1 temp ! DefLook
      THEN
   ELSE
      ref @ dup temp ! LOOK-pref_look_stnd? getprop ToInt dup not IF
 
         pop REFplyr @ #-2 temp ! LOOK-pref_look_stnd_me? getprop ToInt dup not IF
            pop prog dup temp ! LOOK-pref_look_stnd_me? getprop ToInt dup not IF
               pop #-1 temp ! DefLook
            THEN
         THEN
      THEN
   THEN
   dup 0 = IF
      pop DefLook dup 0 = IF
         pop 1
      THEN
   THEN
   dup 1 < over 4 > or IF
      pop DefLook dup 1 < over 4 > or IF
         pop 1 (If DefLook is bad, then return for the ProtoLook format)
      THEN
   THEN
   temp @ swap
;
 
: LOOK-custom-format[ ref:REFplyr ref:ref -- str:STRfmt ]
   VAR BOLforced?
   prog LOOK-pref_force_fmt? getpropstr "y" stringpfx BOLforced? !
   ref @ CASE
      Thing? WHEN
         ref @ #-1 dbcmp BOlforced? @ or IF
            prog LOOK-pref_look_thing_fmt_me over over getpropstr strip not IF
               pop pop prog LOOK-pref_look_fmt_me
            THEN
         ELSE
            ref @ #-2 dbcmp IF
               REFplyr @ LOOK-pref_look_thing_fmt_me over over getpropstr strip not IF
                  pop pop REFplyr @ LOOK-pref_look_fmt_me
               THEN
            ELSE
               ref @ LOOK-pref_look_thing_fmt over over getpropstr strip not IF
                  pop pop ref @ LOOK-pref_look_fmt
               THEN
            THEN
         THEN
         BOLforced? @ IF
            getpropstr dup strip not IF
               pop DefLookFmt_Thing dup strip not IF
                  DefLookFmt
               THEN
            THEN
         ELSE
            getpropstr dup strip not IF
               pop REFplyr @ LOOK-pref_look_thing_fmt_me getpropstr dup strip not IF
                  pop REFplyr @ LOOK-pref_look_fmt_me getpropstr dup strip not IF
                     pop prog LOOK-pref_look_thing_fmt_me getpropstr dup strip not IF
                        pop prog LOOK-pref_look_fmt_me getpropstr dup strip not IF
                           pop DefLookFmt_Thing dup strip not IF
                              DefLookFmt
                           THEN
                        THEN
                     THEN
                  THEN
               THEN
            THEN
         THEN
      END
      Player? WHEN
         ref @ #-1 dbcmp BOLforced? @ or IF
            prog LOOK-pref_look_player_fmt_me over over getpropstr strip not IF
               pop pop prog LOOK-pref_look_fmt_me
            THEN
         ELSE
            ref @ #-2 dbcmp IF
               REFplyr @ LOOK-pref_look_player_fmt_me over over getpropstr strip not IF
                  pop pop REFplyr @ LOOK-pref_look_fmt_me
               THEN
            ELSE
               ref @ LOOK-pref_look_player_fmt over over getpropstr strip not IF
                  pop pop ref @ LOOK-pref_look_fmt
               THEN
            THEN
         THEN
         BOLforced? @ IF
            getpropstr dup strip not IF
               pop DefLookFmt_Player dup strip not IF
                  DefLookFmt
               THEN
            THEN
         ELSE
            getpropstr dup strip not IF
               pop REFplyr @ LOOK-pref_look_player_fmt_me getpropstr dup strip not IF
                  pop REFplyr @ LOOK-pref_look_fmt_me getpropstr dup strip not IF
                     pop prog LOOK-pref_look_player_fmt_me getpropstr dup strip not IF
                        pop prog LOOK-pref_look_fmt_me getpropstr dup strip not IF
                           pop DefLookFmt_Player dup strip not IF
                              DefLookFmt
                           THEN
                        THEN
                     THEN
                  THEN
               THEN
            THEN
         THEN
      END
      Program? WHEN
         ref @ #-1 dbcmp BOLforced? @ or IF
            prog LOOK-pref_look_program_fmt_me over over getpropstr strip not IF
               pop pop prog LOOK-pref_look_fmt_me
            THEN
         ELSE
            ref @ #-2 dbcmp IF
               REFplyr @ LOOK-pref_look_program_fmt_me over over getpropstr strip not IF
                  pop pop REFplyr @ LOOK-pref_look_fmt_me
               THEN
            ELSE
               ref @ LOOK-pref_look_program_fmt over over getpropstr strip not IF
                  pop pop ref @ LOOK-pref_look_fmt
               THEN
            THEN
         THEN
         BOLforced? @ IF
            getpropstr dup strip not IF
               pop DefLookFmt_Program dup strip not IF
                  DefLookFmt
               THEN
            THEN
         ELSE
            getpropstr dup strip not IF
               pop REFplyr @ LOOK-pref_look_program_fmt_me getpropstr dup strip not IF
                  pop REFplyr @ LOOK-pref_look_fmt_me getpropstr dup strip not IF
                     pop prog LOOK-pref_look_program_fmt_me getpropstr dup strip not IF
                        pop prog LOOK-pref_look_fmt_me getpropstr dup strip not IF
                           pop DefLookFmt_Program dup strip not IF
                              DefLookFmt
                           THEN
                        THEN
                     THEN
                  THEN
               THEN
            THEN         THEN
      END
      Exit? WHEN
         ref @ #-1 dbcmp BOLforced? @ or IF
            prog LOOK-pref_look_exit_fmt_me over over getpropstr strip not IF
               pop pop prog LOOK-pref_look_fmt_me
            THEN
         ELSE
            ref @ #-2 dbcmp IF
               REFplyr @ LOOK-pref_look_exit_fmt_me over over getpropstr strip not IF
                  pop pop REFplyr @ LOOK-pref_look_fmt_me
               THEN
            ELSE
               ref @ LOOK-pref_look_exit_fmt over over getpropstr strip not IF
                  pop pop ref @ LOOK-pref_look_fmt
               THEN
            THEN
         THEN
         BOLforced? @ IF
            getpropstr dup strip not IF
               pop DefLookFmt_Exit dup strip not IF
                  DefLookFmt
               THEN
            THEN
         ELSE
            getpropstr dup strip not IF
               pop REFplyr @ LOOK-pref_look_exit_fmt_me getpropstr dup strip not IF
                  pop REFplyr @ LOOK-pref_look_fmt_me getpropstr dup strip not IF
                     pop prog LOOK-pref_look_exit_fmt_me getpropstr dup strip not IF
                        pop prog LOOK-pref_look_fmt_me getpropstr dup strip not IF
                           pop DefLookFmt_Exit dup strip not IF
                              DefLookFmt
                           THEN
                        THEN
                     THEN
                  THEN
               THEN
            THEN
         THEN
      END
      Room? WHEN
         ref @ #-1 dbcmp BOLforced? @ or IF
            prog LOOK-pref_look_room_fmt_me over over getpropstr strip not IF
               pop pop prog LOOK-pref_look_fmt_me
            THEN
         ELSE
            ref @ #-2 dbcmp IF
               REFplyr @ LOOK-pref_look_room_fmt_me over over getpropstr strip not IF
                  pop pop REFplyr @ LOOK-pref_look_fmt_me
               THEN
            ELSE
               ref @ LOOK-pref_look_room_fmt over over getpropstr strip not IF
                  pop pop ref @ LOOK-pref_look_fmt
               THEN
            THEN
         THEN
         BOLforced? @ IF
            getpropstr dup strip not IF
               pop DefLookFmt_Room dup strip not IF
                  DefLookFmt
               THEN
            THEN
         ELSE
            getpropstr dup strip not IF
               pop REFplyr @ LOOK-pref_look_room_fmt_me getpropstr dup strip not IF
                  pop REFplyr @ LOOK-pref_look_fmt_me getpropstr dup strip not IF
                     pop prog LOOK-pref_look_room_fmt_me getpropstr dup strip not IF
                        pop prog LOOK-pref_look_fmt_me getpropstr dup strip not IF
                           pop DefLookFmt_Room dup strip not IF
                              DefLookFmt
                           THEN
                        THEN
                     THEN
                  THEN
               THEN
            THEN
         THEN
      END
      DEFAULT pop
         ref @ #-1 dbcmp BOLforced? @ or IF
            prog LOOK-pref_look_fmt_me
         ELSE
            ref @ #-2 dbcmp IF
               REFplyr @ LOOK-pref_look_fmt_me
            ELSE
               ref @ LOOK-pref_look_fmt
            THEN
         THEN
         BOLforced? @ IF
            getpropstr dup strip not IF
               DefLookFmt
            THEN
         ELSE
            getpropstr dup strip not IF
               pop REFplyr @ LOOK-pref_look_fmt_me getpropstr dup strip not IF
                  pop prog LOOK-pref_look_fmt_me getpropstr dup strip not IF
                     pop DefLookFmt
                  THEN
               THEN
            THEN
         THEN
      END
   ENDCASE
;
 
: LOOK-format[ ref:REFplyr ref:REFobj -- str:STRfmt ]
   VAR ref
   REFplyr @ REFobj @ LOOK-standard swap ref !
   (i) CASE
      4 = WHEN
         REFplyr @ ref @ LOOK-custom-format
      END
      3 = WHEN
         REFobj @ CASE
            Player? WHEN
               "ndc[,2]"
            END
            Thing? WHEN
               "ndc[,2]"
            END
            Program? WHEN
               "nd"
            END
            Room? WHEN
               "ndsc[,2]e[,2]"
            END
            Exit? WHEN
               "nd"
            END
            DEFAULT pop
               "ndsc[,2]e[,2]"
            END
         ENDCASE
      END
      2 = WHEN
         REFobj @ CASE
            Player? WHEN
               "ndc[,1]"
            END
            Thing? WHEN
               "ndc[,1]"
            END
            Program? WHEN
               "nd"
            END
            Room? WHEN
               REFplyr @ "PUEBLO" Flag? IF
                  "lndse[,1]c[,1]"
               ELSE
                  "ndse[,1]c[,1]"
               THEN
            END
            Exit? WHEN
               "d"
            END
            DEFAULT pop
               "ndse[,1]c[,1]"
            END
         ENDCASE
      END
      1 = WHEN
         REFobj @ CASE
            Player? WHEN
               "ndc"
            END
            Thing? WHEN
               "ndec"
            END
            Program? WHEN
               "nd"
            END
            Room? WHEN
               "lndsec"
            END
            Exit? WHEN
               "nd"
            END
            DEFAULT pop
               "ndsec"
            END
         ENDCASE
      END
      DEFAULT pop
         REFobj @ CASE
            Player? WHEN
               DefLookFmt_Player
            END
            Thing? WHEN
               DefLookFmt_Thing
            END
            Program? WHEN
               DefLookFmt_Program
            END
            Room? WHEN
               DefLookFmt_Room
            END
            Exit? WHEN
               DefLookFmt_Exit
            END
            DEFAULT pop
               DefLookFmt
            END
         ENDCASE
      END
   ENDCASE
;
 
: SafeCall[ item ref:ref -- ]
   VAR sme VAR sloc VAR scommand VAR strigger VAR INTargs
  0 TRY
   me @ sme ! loc @ sloc ! command @ scommand ! trigger @ strigger ! depth INTargs !
   item @ ref @ CALL depth INTargs @ - popn
   sme @ me ! sloc @ loc ! scommand @ command ! strigger @ trigger !
  CATCH
     "^CINFO^SAFECALL ERROR: ^CFAIL^" swap strcat me @ swap ansi_notify
  ENDCATCH
;
 
: Safer_Fmt_Call[ ref:REFperm item ref:ref -- str:STRargs ]
   VAR sme VAR sloc VAR scommand VAR strigger VAR INTargs VAR STRargs
  0 TRY
   REFperm @ owner ref @ controls ref @ "LINK_OK" Flag? or not IF
      me @ "^CINFO^SAFECALL ERROR: ^CFAIL^Permission denied." ansi_notify "" EXIT
   THEN
   me @ sme ! loc @ sloc ! command @ scommand ! trigger @ strigger ! depth INTargs !
   {
   item @ ref @ CALL depth IF
      STRargs !
      } popn
   THEN
   sme @ me ! sloc @ loc ! scommand @ command ! strigger @ trigger !
  CATCH
     "^CINFO^SAFECALL ERROR: ^CFAIL^" swap strcat me @ swap ansi_notify
  ENDCATCH
  STRargs @ dup String? NOT IF
     pop ""
  THEN
;
 
: Unparse[ ref -- str:STRname ]
 
   ref @ array? if
      me @ owner ref @ FAKE-CONTROLS me @ owner "SEE_ALL" Power? or me @ "SILENT" flag? not and if
         ref @ FAKE-UNPARSE
      else
         ref @ FAKE-NAME
      then
   else
      me @ owner ref @ ShowUnparse? if
         ref @ UNPARSEOBJ
      else
         ref @ NAME
      then
   then
;
 
: DARK?[ ref:ref -- int:INTdark? ]
   ref @ "DARK" Flag? ref @ location "DARK" Flag? or
   "dark_sleepers" sysparm "yes" stringcmp not
   ref @ location LOOK-pref_dark_sleepers? getpropstr "yes" stringcmp not or if
      ref @ dup Player? swap owner Awake? not and or
   then
   ref @ location Thing? if
      ref @ location PROPS-container? getpropstr "y" instring if
         ref @ location "HIDE" Flag? or
      then
   then
   ref @ "LIGHT" Flag? ref @ location "DARK" Flag? or
   me @ owner ref @ Controls (?) or
   me @ owner "SEE_ALL" Power? or not and
;
 
: STD-Filter[ ref:ref -- int:INTbol? ]
   ref @ Room? if
      0
   else
      ref @ DARK? if
         0
      else
         ref @ Program? if
            me @ ref @ Controls (?) ref @ "LINK_OK" Flag? or ref @ "VIEWABLE" Flag? or
         else
            ref @ me @ dbcmp not
         then
      then
   then
;
 
: Contents-Filter-ARRAY[ addr:ADDRfunc ref:REFloc -- arr:ARRreflist ]
   { }list REFloc @ Contents_ARRAY
   FOREACH
      swap pop dup ADDRfunc @ ( ref:REF -- int:INTbol? ) EXECUTE if
         swap ARRAY_appendItem
      else
         pop
      then
   REPEAT (// Contents_Array \\)
;
 
: Contents-Filter[ addr:ADDRfunc ref:REFloc -- ref:REF-1 ... ref:REF-INTnum int:INTnum ]
   ADDRfunc @ REFloc @ Contents-Filter-ARRAY ARRAY_vals
;
 
: STD-Exits-Filter[ ref:ref -- int:BOLint? ]
   ref @ getlink Room? if
      ref @ DARK?
   else
      1
   then
   ref @ location Player? or not ref @ "LIGHT" Flag? or
;
 
: Exits-Filter[ addr:ADDRfunc ref:REFloc -- arr:ARRreflist ]
   { }list REFloc @ Exits_ARRAY
   FOREACH
      swap pop dup ADDRfunc @ ( ref:REF -- int:INTbol? ) EXECUTE if
         swap ARRAY_appendItem
      else
         pop
      then
   REPEAT
;
 
: Get-Contents-ARRAY[ ref:REFloc -- arr:ARRreflist ]
   'STD-Filter REFloc @ Contents-Filter-ARRAY
;
 
: Get-Contents[ ref:REFloc -- ref:REF-1 ... ref:REF-INTnum int:INTnum ]
   'STD-Filter REFloc @ Contents-Filter
;
 
: Get-Exits[ ref:REFloc -- arr:ARRreflist ]
   'STD-Exits-Filter REFloc @ Exits-Filter
;
 : Long-Display-ARRAY[ arr:ARRreflist -- ]
   ARRreflist @
   FOREACH
      swap pop me @ dup rot DO-NAME
      me @ "PUEBLO" flag? if
         notify_html
      else
         ansi_notify
      then
   REPEAT
;
 
: Long-Display ( ref:REF-1 ... ref:REF-INTnum int:INTnum -- )
   ARRAY_make Long-Display-ARRAY
;
 
: Short-List-ARRAY[ arr:ARRreflist -- str:STRnamelist ]
   #-1 ARRreflist @ Do-Name-List-NoPueblo
;
 
: Short-List ( ref:REF-1 ... ref:REF-INTnum int:INTnum -- str:STRnamelist )
   ARRAY_make Short-List-ARRAY 1 unparse_ansi
;
 
: Short-Display-ARRAY[ arr:ARRreflist -- ]
   ARRreflist @ dup array_count not if
      Short-List-ARRAY "You see %s." swap "%s" subst
      me @ "PUEBLO" flag? if
         me @ swap notify_html
      else
         me @ "^CNOTE^" rot strcat ansi_notify
      then
   else
      pop me @ "^CINFO^You see nothing." ansi_notify
   then
;
 
: Short-Display ( ref:REF-1 ... ref:REF-INTnum int:INTnum -- )
   ARRAY_make Short-Display-ARRAY
;
 
: List-Contents[ str:STRheader ref:REFloc -- ]
   me @ "^BLUE^" STRheader @ strcat ansi_notify
   REFloc @ Get-Contents-ARRAY REFloc @ FAKE-GETFAKES ARRAY_ncombine Long-Display-ARRAY
;
 
: ParseMUF[ str:STRdesc -- str:STRdesc' ]
   VAR STRparms VAR ref
   BEGIN
      STRdesc @ "@" instr 1 = WHILE
      STRdesc @ 1 strcut swap pop striplead " " split ";" split STRdesc ! strip STRparms ! strip ref !
      ref @ not if
         me @ "^CFAIL^MATCH: Empty program string." ansi_notify CONTINUE
      then
      ref @ dup Number? if atoi dbref else match then dup ref ! ok? not if
         ref @ #-1 dbcmp if
            "^CINFO^MATCH: I cannot find that."
         else
            "^CINFO^MATCH: I don't know which one you mean!"
         then
         me @ swap ansi_notify CONTINUE
      then
      ref @ Program? not if
         me @ "^CFAIL^MATCH: Not matched to a program." ansi_notify CONTINUE
      then
      trigger @ owner ref @ Controls (?) ref @ "LINK_OK" flag? or not if
         me @ "^CFAIL^MATCH: Permission denied. Program is not linkable." ansi_notify CONTINUE
      then
      STRparms @ ref @ SafeCall
   REPEAT
   STRdesc @
;
 
 
: STR-desc[ str:STRdesc -- ]
   STRdesc @ ParseMUF
   me @ swap notify
;
 
: STR-desc-parse[ str:STRdesc int:PARSEansi? -- ]
   me @ STRdesc @ PARSEansi? @ if 1 parse_ansi 3 parse_ansi ansi_notify else notify then
;
 
: STR-any-desc[ str:STRanydesc int:PARSEansi? -- ]
   me @ "PUEBLO" flag? PARSEansi? @ -1 = not and if
      me @ STRanydesc @ PARSEansi? @ 0 > if 1 parse_ansi then HTMLfix notify_html
   else
      me @ STRanydesc @ PARSEansi? @ 0 > if 1 parse_ansi 3 parse_ansi \ansi_notify else notify then
   then
;
 
: ARR-desc[ arr:ARRdesc int:PARSEansi? -- ]
   ARRdesc @
   FOREACH
      swap pop PARSEansi? @ STR-any-desc
   REPEAT
;
 
: DBSTR-desc[ ref:REFtrig str:STRdesc -- ]
   VAR strigger
   trigger @ strigger ! REFtrig @ trigger !
   STRdesc @ STR-desc
   strigger @ trigger !
;
 
: DBSTR-desc-parse[ ref:REFtrig str:STRdesc int:PARSEansi? -- ]
   VAR strigger
   trigger @ strigger ! REFtrig @ trigger !
   STRdesc @ PARSEansi? @ STR-desc-parse
   strigger @ trigger !
;
 
: DBARR-desc[ ref:REFtrig arr:ARRdesc int:PARSEansi? -- ]
   VAR strigger
   trigger @ strigger ! REFtrig @ trigger !
   ARRdesc @ PARSEansi? @ ARR-desc
   strigger @ trigger !
;
 
: grab_it[ ref:ref str:STRlistprop -- arr:ARRstrlist ]
   ref @ STRlistprop @ array_get_proplist dup ARRAY_count not if
      pop ref @ STRlistprop @ getpropstr dup strip if
         { swap }list
      else
         pop { }list
      then
   then
;
 
: grab_the_list[ ref:ref str:STRlistprop -- arr:ARRstrlist ]
   me @ ref @ LOOK-prop_lock_desc ISlocked? if
      ref @ STRlistprop @ "_/f" "_/" subst grab_it EXIT
   then
   loc @ ref @ dbcmp ref @ dup Thing? swap "VEHICLE" Flag? and and if
      ref @ STRlistprop @ "_/i" "_/" subst grab_it
   else
      me @ ref @ Nearby? not if
         ref @ STRlistprop @ "_/r" "_/" subst grab_it
      else
         { }list
      then
   then
   dup ARRAY_count not if
      pop ref @ STRlistprop @ grab_it
   then
;
 
: ARR-TEXTCONV[ arr:ARRstrlist int:INTparse int:BOLtoHTML? -- arr:ARRstrlist' ]
   { }list ARRstrlist @
   FOREACH
      swap pop
      trigger @ swap "(@Desc)" INTparse @ ParseMPI ParseMUF
      BOLtoHTML? @ 1 >= if
         TEXT2HTML "<CODE>" swap strcat "</CODE>" strcat
      else
         BOLtoHTML? @ 0 = if
            HTML2TEXT
 
         then
      then
      swap array_appenditem
   REPEAT
;
 
VAR DoHTMLhr
 
: DB-show-name[ ref:ref -- ]
   me @ ref @ ANSI-FULLNAME
   me @ "PUEBLO" Flag? if
      1 unparse_ansi
      DoHTMLhr @ if
         "<HR>" swap strcat
      then
      "<H1>" swap strcat "</H1>" strcat
      me @ swap notify_html
   else
      me @ swap ansi_notify
   then
;
 
: DB-show-desc[ ref:ref -- ]
   { }list VAR! ARRdesc 0 VAR! PARSEansi 0 VAR! BOLtextconv? VAR intTEXTconv
   ref @ loc @ dbcmp if
      me @ LOOK-pref_terse? getpropstr "yes" stringcmp not if
         me @ "/@/Look/OldLoc" getprop dup dbref? if
            ref @ dbcmp not if
               me @ "<Tersing>" notify
               me @ "/@/Look/OldLoc" ref @ setprop EXIT
            then
         else
            pop
         then
      then
      me @ "/@/Look/OldLoc" ref @ setprop
   then
   ref @ "_/htmlde" grab_the_list dup ARRAY_count if
      ARRdesc ! me @ "PUEBLO" flag? if
         ARRdesc @ 1 -1 ARR-TEXTCONV ARRdesc !
         ref @ ARRdesc @ 0 DBARR-desc
         me @ "<BR CLEAR=ALL>" notify_html EXIT
      then
      0 intTEXTconv ! 1 BOLtextconv? !
(      ARRdesc @ 1 0 ARR-TEXTCONV ARRdesc ! )
   else
      pop
   then
   ref @ "_/anside" grab_the_list dup ARRAY_count if
      ARRdesc ! 1 PARSEansi !
      me @ "PUEBLO" flag? if
         1 intTEXTconv ! 1 BOLtextconv? ! 0 PARSEansi !
      else
         -1 intTEXTconv ! 1 BOLtextconv? !
      then
      me @ "COLOR" flag? if
         ARRdesc @ 1 intTEXTconv @ ARR-TEXTCONV ARRdesc !
         ref @ ARRdesc @ PARSEansi @ DBARR-desc EXIT
      then
   else
      pop
   then
   ref @ "_/de" grab_the_list dup ARRAY_count if
      ARRdesc !
      me @ "PUEBLO" flag? if
         ARRdesc @ 1 1 ARR-TEXTCONV ARRdesc !
      else
         ARRdesc @ 1 -1 ARR-TEXTCONV ARRdesc !
      then
      ref @ ARRdesc @ me @ "COLOR" flag? if 1 else 0 then DBARR-desc EXIT
   else
      pop
   then
   ARRdesc @ ARRAY_count if
      BOLtextconv? @ if
         ARRdesc @ 1 intTEXTconv @ ARR-TEXTCONV ARRdesc !
      then
      ref @ ARRdesc @ PARSEansi @ DBARR-desc
   else
      me @ "You see nothing special." ansi_notify EXIT
   then
;
 
: DB-show-succ[ ref:ref -- ]
   VAR strigger
   ref @ dup Exit? over Program? or swap Thing? or if
      EXIT
   then
   trigger @ strigger ! ref @ trigger !
   me @ ref @ Locked? if
      ref @ fail dup strip if
         trigger @ swap "(@Fail)" 1 ParseMPI ParseMUF me @ swap notify
      else
         pop
      then
      ref @ ofail dup strip if
         trigger @ swap "(@oFail)" 0 ParseMPI ParseMUF loc @ me @ rot notify_except
      else
         pop
      then
   else
      ref @ succ dup strip if
         trigger @ swap "(@Succ)" 1 ParseMPI ParseMUF me @ swap notify
      else
         pop
      then
      ref @ osucc dup strip if
         trigger @ swap "(@oSucc)" 0 ParseMPI ParseMUF loc @ me @ rot notify_except
      else
         pop
      then
   then
;
 
: DB-show-exits-long[ str:STRheader ref:obj int:USE_COLOR? int:LONG_NAMES? -- ]
   me @ STRheader @ ansi_notify
   obj @ Get-Exits
   FOREACH
      swap pop dup obj ! me @ swap DO-NAME
      USE_COLOR? @ not IF
         me @ "PUEBLO" Flag? not IF
            1 unparse_ansi
         THEN
      THEN
      LONG_NAMES? @ IF
         me @ obj @ ShowUnparse? IF
            obj @ unparseobj ";" split 1 escape_ansi swap pop
            USE_COLOR? @ me @ "PUEBLO" Flag? not and IF
               "(#" rsplit "^YELLOW^(#" swap strcat strcat
            THEN
            me @ "PUEBLO" Flag? IF
               swap "</a>" rsplit pop "(#" rsplit pop ";" strcat swap strcat "</a>" strcat
            ELSE
               swap "(#" rsplit pop ";" strcat swap strcat
            THEN
         ELSE
            obj @ name ";" split 1 escape_ansi swap pop
            me @ "PUEBLO" Flag? IF
               swap "</a>" rsplit pop ";" strcat swap strcat "</a>" strcat
            ELSE
               ";" swap strcat strcat
            THEN
         THEN
         USE_COLOR? @ me @ "PUEBLO" Flag? not and IF
            "^CYAN^;^GREEN^" ";" subst
         THEN
      THEN
      me @ swap
      me @ "PUEBLO" Flag? IF
         notify_html
      ELSE
         ansi_notify
      THEN
   REPEAT
;
 
: DB-show-exits-short[ ref:obj int:USE_COLOR? int:SHOW_AS_ACTIONS? -- ]
   me @ obj @ Get-Exits Do-Name-List
   me @ "PUEBLO" Flag? USE_COLOR? @ or not IF
      1 unparse_ansi "^NORMAL^" swap 1 escape_ansi strcat
   THEN
   SHOW_AS_ACTIONS? @ IF
      me @ "PUEBLO" Flag? IF
         "<TT><B>Actions: </B>" swap strcat "</B>" strcat
      ELSE
         "^GREEN^Actions: " swap strcat
      THEN
   ELSE
      me @ "PUEBLO" Flag? IF         "<TT>[<B>Exits&#32;&#32;&#32;</B>: " swap strcat " ]</TT>" strcat
      ELSE
         "[^CNOTE^Exits   ^NORMAL^: " swap strcat " ^NORMAL^]" strcat
      THEN
   THEN
   me @ swap over "PUEBLO" Flag? IF
      notify_html
   ELSE
      ansi_notify
   THEN
;
 
: DB-show-exits[ ref:obj int:DisplayHow? -- ]
   0 VAR! STRbol
   DisplayHow? @ -1 = IF
      me @ obj @ LOOK-standard swap pop DisplayHow? !
   THEN
   DisplayHow? @ dup 0 < swap 10 > or IF
      0 DisplayHow? !
   THEN
   obj @ program? obj @ exit? or if
      DisplayHow? @ 2 > IF
         DisplayHow? @ dup 5 = swap 6 = or IF
            "^GREEN^No actions."
         ELSE
            DisplayHow? @ 7 >= Room? @ not and IF
               "^GREEN^No actions."
            ELSE
               "^GREEN^No exits."
            THEN
         THEN
         me @ swap ansi_notify
      THEN
      exit
   then
   DisplayHow? @ 2 <= IF
     0 TRY
      obj @ dup owner swap LOOK-prop_exit_listing getprop dup if
         dup string? if
            "(@exits)" 1 parsempi ParseMUF strip dup "#" instr 1 = if
               1 strcut swap pop strip STRbol ++
            else
               dup "$" instr 1 = if
                  dup match dup Program? if
                     dup "LINK_OK" Flag? if
                        swap pop int intostr STRbol ++
                     else
                        pop
                     then
                  else
                     pop
                  then
               then
            then
            STRbol @ over number? and if
               loc @ dtos swap stod SafeCall exit
            else
               me @ swap STRbol @ if "#" swap strcat then notify exit
            then
         else
            swap pop dup int? if
               loc @ dtos swap dbref SafeCall exit
            else
               dup dbref? not if
                  pop me @ "ERROR: Obvexits could not be shown." ansi_notify exit
               else
                  loc @ dtos swap SafeCall exit
               then
            then
         then
      else
         pop pop
      then
      #0    LOOK-pref_internal_exits? getpropstr "no"  stringcmp not
      prog  LOOK-pref_internal_exits? getpropstr "no"  stringcmp not or not
      obj @ LOOK-pref_internal_exits? getpropstr "yes" stringcmp not or
      obj @ LOOK-pref_internal_exits? getpropstr "no"  stringcmp not    not and not if
         exit
      then
     CATCH
      prog owner "PROTOLOOK ERROR [db-show-exits]: " rot strcat notify
     ENDCATCH
   THEN
   DisplayHow? @ CASE
     10 = WHEN
         obj @ Room? IF
            "^GREEN^Obvious Exits:"
         ELSE
            "^GREEN^Actions:"
         THEN
         obj @ 0 1 DB-show-exits-long
      END
      9 = WHEN
         obj @ Room? IF
            "^GREEN^Obvious Exits:"
         ELSE
            "^GREEN^Actions:"
         THEN
         obj @ 1 1 DB-show-exits-long
      END
      8 = WHEN
         obj @ Room? IF
            "^GREEN^Obvious Exits:"
         ELSE
            "^GREEN^Actions:"
         THEN
         obj @ 0 0 DB-show-exits-long
      END
      7 = WHEN
         obj @ Room? IF
            "^GREEN^Obvious Exits:"
         ELSE
            "^GREEN^Actions:"
         THEN
         obj @ 1 0 DB-show-exits-long
      END
      6 = WHEN
         obj @ 0 1 DB-show-exits-short
      END
      5 = WHEN
         obj @ 1 1 DB-show-exits-short
      END
      4 = WHEN         obj @ 0 0 DB-show-exits-short
      END
      3 = WHEN
         obj @ 1 0 DB-show-exits-short
      END
      2 = WHEN
         obj @ Room? IF
            "^GREEN^Obvious Exits:"
         ELSE
            "^GREEN^Actions:"
         THEN
         obj @ 1 0 DB-show-exits-long
      END
      1 = WHEN
         obj @ Room? IF
            obj @ 0 0 DB-show-exits-short
         THEN
      END
      ( 0 = ) DEFAULT pop
         obj @ Room? IF
            obj @ 1 0 DB-show-exits-short
         ELSE
            obj @ Player? not IF
               obj @ Get-Exits ARRAY_count IF
                  obj @ 1 1 DB-show-exits-short
               THEN
            THEN
         THEN
      END
   ENDCASE
;
 
: DB-show-contents-sorted[ ref:obj -- ]
   { }list dup VAR! ARRcontents
           dup VAR! ARRplayers
           dup VAR! ARRsleepers
           dup VAR! ARRthings
               VAR! ARRvehicles
   0           VAR! INTcount
   obj @ Get-Contents-Array
   FOREACH
      swap pop dup Player? over dup Thing? swap "ZOMBIE" Flag? and or IF
         dup owner Awake? over Dark? not and IF
            ARRplayers @ ARRAY_appendItem ARRplayers !
         ELSE
            ARRsleepers @ ARRAY_appendItem ARRsleepers !
         THEN
      ELSE
         dup Thing? over "VEHICLE" Flag? and IF
            ARRvehicles @ ARRAY_appendItem ARRvehicles !
         ELSE
            ARRthings @ ARRAY_appendItem ARRthings !
         THEN
      THEN
   REPEAT
   ARRthings @ obj @ FAKE-GETFAKES ARRAY_ncombine ARRthings !
   ARRplayers @ ARRAY_count IF
      me @ dup ARRplayers @ Do-Name-List me @ obj @ LOOK-standard swap pop 2 = IF
         "^GREEN^" "^PURPLE^" subst
      THEN
      me @ "PUEBLO" Flag? IF
         "<TT>[<B>Players&#32;</B>: " swap strcat " ]</TT>" strcat
         notify_html
      ELSE
         "[^CNOTE^Players ^NORMAL^: " swap strcat " ^NORMAL^]" strcat
         ansi_notify
      THEN
      INTcount ++
   THEN
   ARRsleepers @ ARRAY_count me @ LOOK-pref_dark_sleepers? envprop swap pop "y*" smatch not and IF
      me @ dup ARRsleepers @ Do-Name-List me @ obj @ LOOK-standard swap pop 2 = IF
 
         "^GREEN^" "^PURPLE^" subst
      THEN
      me @ "PUEBLO" Flag? IF
         "<TT>[<B>Sleepers</B>: " swap strcat " ]</TT>" strcat
         notify_html
      ELSE
         "[^CNOTE^Sleepers^NORMAL^: " swap strcat " ^NORMAL^]" strcat
         ansi_notify
      THEN
      INTcount ++
   then
   ARRthings @ ARRAY_count IF
      me @ dup ARRthings @ Do-Name-List dup strip IF
         me @ "PUEBLO" Flag? IF
            "<TT>[<B>Things&#32;&#32;</B>: " swap strcat " ]</TT>" strcat
            notify_html
         ELSE
            "[^CNOTE^Things  ^NORMAL^: " swap strcat " ^NORMAL^]" strcat
            ansi_notify
         THEN
         INTcount ++
      ELSE
         pop pop
      THEN
   THEN
   ARRvehicles @ ARRAY_count IF
      me @ dup ARRvehicles @ Do-Name-List
      me @ "PUEBLO" Flag? IF
         "<TT>[<B>Vehicles</B>: " swap strcat " ]</TT>" strcat
         notify_html
      ELSE
         "[^CNOTE^Vehicles^NORMAL^: " swap strcat " ^NORMAL^]" strcat
         ansi_notify
      THEN
   THEN
   INTcount @ not IF
      me @ dup "PUEBLO" Flag? IF
         "<TT>[<B>Things&#32;&#32;</B>: None ]</TT>"
         notify_html
      ELSE
         "[^CNOTE^Things  ^NORMAL^: ^CFAIL^None ^NORMAL^]"
         ansi_notify
      THEN
   THEN
;
 
: DB-show-contents-short[ ref:obj int:BOLtwo_lines? int:BOLalways_show? -- ]
   obj @ Get-Contents-Array obj @ FAKE-GETFAKES ARRAY_ncombine
   dup ARRAY_count IF
      {
         BOLtwo_lines? @ IF
            "Carrying: "
         ELSE
            "Contents: "
         THEN
         me @ "PUEBLO" Flag? IF
            "<FONT COLOR=BLUE><TT><B>" swap strcat "</B></TT></FONT>" strcat
         ELSE
            "^GREEN^" swap strcat
         THEN
         rot me @ swap Do-Name-List
         BOLtwo_lines? @ not IF
            strcat
         THEN
      }list { me @ }list
      me @ "PUEBLO" Flag? IF
         ARRAY_notify_html
      ELSE
         ARRAY_ansi_notify
      THEN
   ELSE
      BOLalways_show? @ IF
         "^BLUE^Carrying nothing."
         obj @ Player? IF
            " ^WHITE^(^YELLOW^Currency: ^NORMAL^" STRcat
            obj @ PENNIES INtoSTR STRcat " " strcat
            "pennies" sysparm strcat "^WHITE^)" STRcat
         THEN
         me @ swap ansi_notify
      THEN
   THEN
;
 
: DB-show-contents[ ref:obj int:DisplayHow? -- ]
   0 VAR! STRbol
   DisplayHow? @ -1 = IF
      me @ obj @ LOOK-standard swap pop DisplayHow? !
   THEN
   DisplayHow? @ dup 0 < swap 8 > or IF
      0 DisplayHow? !
   THEN
   obj @ program? obj @ exit? or if
      DisplayHow? @ dup 4 = swap 6 = or IF
         pop me @ "^BLUE^Carrying nothing." ansi_notify
      THEN
      exit
   then
   DisplayHow? @ 2 <= IF
     0 TRY
      obj @ dup owner swap LOOK-prop_contents_listing getprop dup if
         dup string? if
            "(@exits)" 1 parsempi ParseMUF strip dup "#" instr 1 = if
               1 strcut swap pop strip STRbol ++
            else
               dup "$" instr 1 = if
                  dup match dup Program? if
                     dup "LINK_OK" Flag? if
                        swap pop int intostr STRbol ++
                     else
                        pop
                     then
                  else
                     pop
                  then
               then
            then
            STRbol @ over number? and if
               loc @ dtos swap stod SafeCall exit
            else
               me @ swap STRbol @ if "#" swap strcat then notify exit
            then
         else
            swap pop dup int? if
               loc @ dtos swap dbref SafeCall exit
            else
               dup dbref? not if
                  pop me @ "ERROR: Obvexits could not be shown." ansi_notify exit
               else
                  loc @ dtos swap SafeCall exit
               then
            then
         then
      else
         pop pop
      then
      #0    LOOK-pref_contents? getpropstr "no"  stringcmp not
      prog  LOOK-pref_contents? getpropstr "no"  stringcmp not or not
      obj @ LOOK-pref_contents? getpropstr "yes" stringcmp not or
      obj @ LOOK-pref_contents? getpropstr "no"  stringcmp not    not and not obj @ "HIDE" Flag? or if
         exit
      then
     CATCH
      prog owner "PROTOLOOK ERROR [db-show-contents]: " rot strcat notify
     ENDCATCH
   THEN
   DisplayHow? @ CASE
      8 = WHEN
         "^BLUE^Contents:" obj @ List-Contents
      END
      7 = WHEN
         obj @ 1 0 DB-show-contents-short
      END
      6 = WHEN
         obj @ 1 1 DB-show-contents-short
      END
      5 = WHEN
         obj @ 0 0 DB-show-contents-short
      END
      4 = WHEN
         obj @ 0 1 DB-show-contents-short
      END
      3 = WHEN
         obj @ DB-show-contents-sorted
      END
      2 = WHEN
         obj @ Room? IF
            "^BLUE^Contents:" obj @ List-Contents
         ELSE
            obj @ PROPS-container? getpropstr "y" stringpfx obj @ "HIDE" Flag? not and
            obj @ Player? obj @ dup Thing? swap "ZOMBIE" Flag? and or or IF
               1
            ELSE
               obj @ Get-Contents-Array obj @ FAKE-GETFAKES ARRAY_ncombine ARRAY_count
            THEN
            IF
               "^BLUE^Contains:" obj @ List-Contents
            THEN
         THEN
      END
      1 = WHEN
         obj @ Room? IF
            obj @ DB-show-contents-sorted
         ELSE
            obj @ 1
            obj @ PROPS-container? getpropstr "y" stringpfx obj @ "HIDE" Flag? not and
            obj @ Player? obj @ dup Thing? swap "ZOMBIE" Flag? and or or
            DB-show-contents-short
         THEN
      END
      ( 0 = ) DEFAULT pop
         obj @ Room? IF
            obj @ DB-show-contents-sorted
         ELSE
            obj @ 1
            obj @ PROPS-container? getpropstr "y" stringpfx obj @ "HIDE" Flag? not and
            obj @ Player? obj @ dup Thing? swap "ZOMBIE" Flag? and or or
            DB-show-contents-short
 
         THEN
      END
   ENDCASE
;
 
: DB-do-notify[ ref:obj -- ]
   obj @ dup Player? swap dup Thing? swap "ZOMBIE" Flag? and or not if
      EXIT
   then
   obj @ LOOK-prop_look_notify getpropstr dup if
      obj @ owner swap "(@desc)" 1 ParseMPI
      me @ swap Pronoun_SUB
      obj @ owner swap ansi_notify
   else
      pop
   then
   obj @ LOOK-prop_looker_notify getpropstr dup if
      obj @ owner swap "(@desc)" 1 ParseMPI
      obj @ swap Pronoun_SUB
      me @ swap ansi_notify
   else
      pop
   then
   obj @ LOOK-prop_tattle_notify getpropstr dup if
      obj @ owner swap "(@desc)" 1 ParseMPI
      me @ swap Pronoun_SUB
      loc @ me @ rot ansi_notify_except
   else
      pop
   then
   "look_propqueues" sysparm "yes" stringcmp not if
      obj @ "_lookq" obj @ dup dtos ENVpropQueue
   then
;
 
: DB-view-format[ ref:REFperm ref:ref str:STRview int:RunLvl -- ]
   VAR STRtype VAR STRargs VAR strig
   RunLvl @ 5 > IF
      EXIT
   THEN
   ref @ CASE
      Room? WHEN
         "R"
      END
      dup Thing? over "ZOMBIE" Flag? and swap Player? or WHEN
         "P"
      END
      Exit? WHEN
         "E"
      END
      Program? WHEN
         "F"
      END
      DEFAULT (Things and stuff)
         pop "T"
      END
   ENDCASE
   STRtype !
   STRview @ strip
   BEGIN
      dup WHILE
      1 strcut strip dup "[" stringpfx IF
         1 strcut swap pop "]" split swap "," split STRargs !
         dup strip IF
            dup "!" STRtype @ strcat instring
            swap STRtype @ instring not or IF
               swap pop CONTINUE
            THEN
         ELSE
            pop
         THEN
      ELSE
         "" STRargs !
      THEN
      strip dup STRview ! swap
      (s) CASE
         "N" stringcmp not WHEN
            ref @ DB-show-name
         END
         "D" stringcmp not WHEN
            ref @ DB-show-desc
         END
         "S" stringcmp not WHEN
            ref @ DB-show-succ
         END
         "E" stringcmp not WHEN
            ref @ STRargs @ strip atoi DB-show-exits
         END
         "C" stringcmp not WHEN
            ref @ STRargs @ strip atoi DB-show-contents
         END
         "L" stringcmp not WHEN
            me @ "PUEBLO" flag? IF
               STRview @ 1 strcut pop "N" stringcmp not IF
 
                  1 DoHTMLhr !
               ELSE
                  me @ "<HR>" notify_html
               THEN
            ELSE
              ( me @ "------------------------------------------------------------------------------" notify )
            THEN
         END
         "M" stringcmp not WHEN
            REFperm @ STRargs @ ref @ dtos 0 ParseMPI dup strip IF
               me @ swap ansi_notify
            ELSE
               pop
            THEN
         END
         "P" stringcmp not WHEN
            REFperm @ STRargs @ ref @ dtos 0 ParseMPI dup strip IF
               REFperm @ ref @ rot RunLvl @ ++ DB-view-format
            ELSE
               pop
            THEN
         END
         "F" stringcmp not WHEN
            STRargs @ "," split STRargs ! match dup Ok? IF dup Program? ELSE 0 THEN IF
               trigger @ strig ! ref @ trigger !
               REFperm @ STRargs @ rot Safer_Fmt_Call dup strip IF
                  REFperm @ ref @ rot RunLvl @ ++ DB-view-format
               ELSE
                  pop
               THEN
               strig @ trigger !
            ELSE
               pop
            THEN
         END
         DEFAULT
            me @ swap ": Invalid command in look format." strcat "^CFAIL^" swap 1 escape_ansi strcat ansi_notify
         END
      ENDCASE
   REPEAT
   pop
;
 
: DB-exit-look[ ref:obj -- ]
   VAR strig
   obj @ exit? not if
      exit
   then
   obj @ getlink room? not if
      exit
   then
   obj @ LOOK-prop_exit_lookthru getpropstr dup if
      obj @ owner swap "(Look)" 1 parsempi strip dup if me @ swap ansi_notify else pop then
   else
      pop
   then
   obj @ LOOK-prop_exit_notify getpropstr dup strip if
      obj @ owner swap "(Look)" 1 parsempi strip dup if
         me @ swap pronoun_sub obj @ getlink 0 "^CMOVE^" 4 rotate "^^" "^" subst ansi_notify_exclude
      else
         pop
      then
   else
      pop
   then
   obj @ LOOK-prop_exit_format_show getpropstr strip dup not if
      pop exit
   then
   dup "yes" stringcmp not if
      pop me @ obj @ getlink LOOK-format
   then
   trigger @ strig ! obj @ trigger !
   obj @ dup getlink swap 1 DB-view-format
   strig @ trigger !
;
 
: DB-desc[ ref:ref -- ]
   VAR RefObj VAR StdFMT VAR strig
   trigger @ strig ! ref @ trigger !
   me @ ref @ LOOK-prop_lock_look ISlocked? if
      me @ "^CFAIL^ERROR: Look lock failed.  Permission denied." ansi_notify exit
   then
   me @ ref @ LOOK-standard pop dup #-2 dbcmp IF
      pop me @
   ELSE
      dup #-1 dbcmp IF
         pop #1
      THEN
   THEN
   ref @ me @ over LOOK-format 1 DB-view-format
   ref @ DB-do-notify
   ref @ DB-exit-look
   strig @ trigger !
;
 
: local-match[ str:STRmatch -- ref:ref ]
   STRmatch @ match dup ok? if
      me @ over Nearby? me @ "WIZARD" flag? or not if
         dup Exit? if
            me @ over Enviroment? not if
               pop #-1
            then
         else
            pop #-1
         then
      then
   then
;
 
: MATCH_LOOK[ str:STRmatch -- ref ]
   STRmatch @ local-match dup not if
      pop STRmatch @ FAKE-MATCH dup ARRAY_count not if
         pop STRmatch @ "=" instr if
            STRmatch @ "=" split
         else
            STRmatch @ " at " instr if
               STRmatch @ " at " split
            else
               STRmatch @ "'s " instr if
                  STRmatch @ "'s " split
               else
                  #-1 EXIT
               then
            then
         then
         strip swap strip over over and if
            local-match dup ok? if
               swap over over Rmatch dup not if
                  pop FAKE-RMATCH dup ARRAY_count not if
                     pop #-1 EXIT
                  then
                  dup ARRAY_count 1 = if
                     pop #-2 EXIT
                  then
               else
                  rot rot pop pop
               then
            then
         else
            pop pop #-1
         then
      else
         dup ARRAY_count 1 = if
            pop #-2
         then
      then
   then
;
 
: CMD-look[ str:STRargs -- ]
   STRargs @ strip dup not if
      pop "here"
   then
   MATCH_LOOK dup array? if
      FAKE-LOOK
   else
      dup ok? not if
         #-1 dbcmp if
            "^CINFO^I cannot find that."
         else
            "^CINFO^I don't know which one you mean!"
         then
         me @ swap ansi_notify
      else
         DB-desc
      then
   then
;
 
: LOOK-help[ str:STRhelp -- ]
   STRhelp @ not STRhelp @ "index" stringcmp not or if
      me @ "^CINFO^ProtoLook v%1.2f - by Moose" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
      me @ "^CNOTE^-------------------------------------------------------" ansi_notify
      me @ "^CINFO^Look [object]           ^NORMAL^- Look at an object, or blank for the room." ansi_notify
      me @ "^CINFO^Lookat [obj1]'s [obj2]  ^NORMAL^- Look at an obj2 in obj1's inventory." ansi_notify
      me @ "^CINFO^Lookat [obj1]=[obj2]    ^NORMAL^- Same as above." ansi_notify
      me @ "^CINFO^Lookat [obj1] at [obj2] ^NORMAL^- Same as above." ansi_notify
      me @ "^CINFO^Look #Terse             ^NORMAL^- Toggle on/off the look tersing." ansi_notify
      me @ "^CINFO^Look #Options           ^NORMAL^- Enter the configuration menu." ansi_notify
      me @ "^CINFO^Look #Edit <obj>        ^NORMAL^- Enter interactive editors for <obj> object." ansi_notify
      me @ "^CINFO^Look #Fake <obj>        ^NORMAL^- Enter the interactive fake object editor." ansi_notify
      me @ "^CINFO^Look #Fake <obj>=<name> ^NORMAL^- Edit a fake object <name> on <obj> object." ansi_notify
      me @ " " notify
      me @ "^CNOTE^Catagories (^NORMAL^Type '^CNOTE^look #help <catagory>^NORMAL^' for help^CNOTE^):" ansi_notify
      me @ " ^CNOTE^FAKEOBJS ^NORMAL^- Help on fake objects." ansi_notify
      me @ " ^CNOTE^CUSTOM   ^NORMAL^- Help on custom formats." ansi_notify
      me @ " ^CNOTE^DESCS    ^NORMAL^- Help on descriptions." ansi_notify
      me @ " ^CNOTE^FLAGS    ^NORMAL^- Help on how flags effect stuff." ansi_notify
      me @ " ^CNOTE^COMMANDS ^NORMAL^- Help on each of the different commands." ansi_notify
      me @ " ^CNOTE^LOOKTHRU ^NORMAL^- Help on exit lookthru support." ansi_notify
      me @ " ^CNOTE^WHATSNEW ^NORMAL^- Take a peek at what is new." ansi_notify
      me @ " ^CNOTE^MISCPROP ^NORMAL^- Miscellaneous properties for ProtoLook." ansi_notify
      me @ " ^CNOTE^CREDITS  ^NORMAL^- Credits for ProtoLook." ansi_notify
      me @ "^CINFO^Done." ansi_notify exit
   then
   "FAKEOBJS" STRhelp @ instring 1 = if
      me @ "^CINFO^ProtoLook v%1.2f - by Moose" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
      me @ "^CNOTE^-------------------------------------------------------" ansi_notify
      me @ "^CNOTE^Fake objects are fun and neat tools to toy with.  Unfortunatly, at this time," ansi_notify
      me @ "^CNOTE^there is not much support... yet.  However, to set one up manualy, you can type:" ansi_notify
      me @ "  @set <object>=%s<Object Name>/Ok?:yes" FAKE-DIR "%s" subst ansi_notify
      me @ "  @set <object>=%s<Object Name>/Name:<Object Name>" FAKE-DIR "%s" subst ansi_notify
      me @ "  @set <object>=%s<Object Name>/Desc:<Description>" FAKE-DIR "%s" subst ansi_notify
      me @ "  @set <object>=%s<Object Name>/ANSIDesc:<ANSI Description>" FAKE-DIR "%s" subst ansi_notify
      me @ "  @set <object>=%s<Object Name>/HTMLDesc:<HTML Description>" FAKE-DIR "%s" subst ansi_notify
      me @ "^CNOTE^And, voila!  That is pretty much all you need to do.  Hopefully, eventually," ansi_notify
      me @ "^CNOTE^programs will support fake objects." ansi_notify
      me @ "^CINFO^It might be easier typing '^CNOTE^look #fake me=<fake object>^CINFO^', however." ansi_notify
      me @ "^CINFO^Done." ansi_notify exit
   then
   "CUSTOM1" STRhelp @ instring 1 = IF
      me @ "^CINFO^ProtoLook v%1.2f - by Moose" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
      me @ "^CNOTE^-------------------------------------------------------" ansi_notify
      me @ "^CNOTE^To setup a custom look, you can type '^NORMAL^look #custom <object>^CNOTE^' on an" ansi_notify
      me @ "^CNOTE^object, or type '^NORMAL^look #custom^CNOTE^' for just personal and global settings." ansi_notify
      me @ " " ansi_notify
      me @ "^CNOTE^For manual settings, the properties are as follows:" ansi_notify
      me @ "  ^CINFO^Objects:" ansi_notify
      me @ "    Standard type:       ^WHITE^" LOOK-pref_look_stnd? 1 escape_ansi strcat ansi_notify
      me @ "    Default look Format: ^WHITE^" LOOK-pref_look_fmt 1 escape_ansi strcat ansi_notify
      me @ "    Program look Format: ^WHITE^" LOOK-pref_look_program_fmt 1 escape_ansi strcat ansi_notify
      me @ "    Player look Format:  ^WHITE^" LOOK-pref_look_program_fmt 1 escape_ansi strcat ansi_notify
      me @ "    Thing look Format:   ^WHITE^" LOOK-pref_look_thing_fmt 1 escape_ansi strcat ansi_notify
      me @ "    Room look Format:    ^WHITE^" LOOK-pref_look_room_fmt 1 escape_ansi strcat ansi_notify
      me @ "    Exit look Format:    ^WHITE^" LOOK-pref_look_exit_fmt 1 escape_ansi strcat ansi_notify
      me @ "  ^CINFO^Personal / Global:" ansi_notify
      me @ "    Force global format: ^WHITE^" LOOK-pref_force_fmt? 1 escape_ansi strcat ansi_notify
      me @ "    Standard type:       ^WHITE^" LOOK-pref_look_stnd_me? 1 escape_ansi strcat ansi_notify
 
      me @ "    Default look Format: ^WHITE^" LOOK-pref_look_fmt_me 1 escape_ansi strcat ansi_notify
      me @ "    Program look Format: ^WHITE^" LOOK-pref_look_program_fmt_me 1 escape_ansi strcat ansi_notify
      me @ "    Player look Format:  ^WHITE^" LOOK-pref_look_program_fmt_me 1 escape_ansi strcat ansi_notify
      me @ "    Thing look Format:   ^WHITE^" LOOK-pref_look_thing_fmt_me 1 escape_ansi strcat ansi_notify
      me @ "    Room look Format:    ^WHITE^" LOOK-pref_look_room_fmt_me 1 escape_ansi strcat ansi_notify
      me @ "    Exit look Format:    ^WHITE^" LOOK-pref_look_exit_fmt_me 1 escape_ansi strcat ansi_notify
      me @ "  ^CNOTE^These should be set on yourself for personal settings." ansi_notify
      me @ "  ^CNOTE^For global settings, set them on $Lib/Look.  For on objects, you only need to set" ansi_notify
      me @ "  ^CNOTE^the standard type, and default look format if its a custom one." ansi_notify
      me @ "^CNOTE^If you want information on the custom format parsings and the look standard" ansi_notify
      me @ "^CNOTE^types, then type: ^NORMAL^look #custom2" ansi_notify
      me @ "^CINFO^Done." ansi_notify exit
   THEN
   "CUSTOM2" STRhelp @ instring 1 = IF
      me @ "^CINFO^ProtoLook v%1.2f - by Moose" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
      me @ "^CNOTE^-------------------------------------------------------" ansi_notify
      me @ "^CNOTE^The following settings can be set for look standard:" ansi_notify
      me @ "  ^CNOTE^0  ^NORMAL^-- The default internal choice for look standard." ansi_notify
      me @ "  ^CNOTE^1  ^NORMAL^-- The internal, standard ProtoLook format." ansi_notify
      me @ "  ^CNOTE^2  ^NORMAL^-- The old NeonLook format." ansi_notify
      me @ "  ^CNOTE^3  ^NORMAL^-- The really, really old and ancient standard look format." ansi_notify
      me @ "  ^CNOTE^4  ^NORMAL^-- For custom formats." ansi_notify
      me @ "^CNOTE^For custom formats, it is really simple.  The function format is: ^NORMAL^?[TYPES,Args]" ansi_notify
      me @ "^WHITE^ARGS  ^NORMAL^- Arguments sent to function." ansi_notify
      me @ "^WHITE^TYPES ^NORMAL^- The object type list it will show on." ansi_notify
      me @ "         ^WHITE^R  ^NORMAL^- Show for rooms." ansi_notify
      me @ "         ^WHITE^T  ^NORMAL^- Show for things." ansi_notify
      me @ "         ^WHITE^P  ^NORMAL^- Show for players." ansi_notify
      me @ "         ^WHITE^F  ^NORMAL^- Show for programs." ansi_notify
      me @ "         ^WHITE^E  ^NORMAL^- Show for exits." ansi_notify
      me @ "  ^WHITE^?   ^NORMAL^- The function name: (&how for M[] and P[] is the dbref)" ansi_notify
      me @ "         ^WHITE^L  ^NORMAL^- Shows a line." ansi_notify
      me @ "         ^WHITE^N  ^NORMAL^- The name of the object." ansi_notify
      me @ "         ^WHITE^D  ^NORMAL^- Description of the object." ansi_notify
      me @ "         ^WHITE^S  ^NORMAL^- Success/fail message, as applicable." ansi_notify
      me @ "         ^WHITE^E  ^NORMAL^- Contents listing. Parameter [ARGS] listed under 'look #help custom3'" ansi_notify
      me @ "         ^WHITE^C  ^NORMAL^- Exits/Action listing. Parameter [ARGS] listed under'look #help custom3'" ansi_notify
      me @ "         ^WHITE^M  ^NORMAL^- Parse MPI and show a message.  The MPI in ARGS." ansi_notify
      me @ "         ^WHITE^P  ^NORMAL^- Parse MPI for more look format stuff to parse.  MPI in ARGS." ansi_notify
      me @ "         ^WHITE^F  ^NORMAL^- Run a given MUF program. Arguments in ARGS. Parses returned string." ansi_notify
      me @ "^CINFO^Examples: ^NORMAL^Look standard: ^YELLOW^NDS[R]C[RP,8]E[R,7]" ansi_notify
      me @ "          ProtoLook: ^YELLOW^L[R]NDS[R]P[RTP,{if:{smatch:{type:{&how}},Room},C[R\\,3],C[P\\,6]C[T\\,7]}]E[R,3]E[T,5]" ansi_notify
      me @ "          NeonLook: ^YELLOW^P[R,{if:{instr:{flags:me},$},L,}]NDS[R]E[,2]C[,2]" ansi_notify
      me @ "          Default: ^YELLOW^LNDESC" ansi_notify
      me @ "^CNOTE^For information on the parameter/args for contents/exits, type: ^NORMAL^look #help custom3" ansi_notify
      me @ "^CINFO^Done." ansi_notify exit
   THEN
   "CUSTOM3" STRhelp @ instring 1 = IF
      me @ "^CINFO^ProtoLook v%1.2f - by Moose" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
      me @ "^CNOTE^-------------------------------------------------------" ansi_notify
      me @ "^CINFO^Contents options:" ansi_notify
      me @ "  ^WHITE^C[, 0]: This is the default for whatever object." ansi_notify
      me @ "  ^WHITE^C[, 1]: Default for whatever object for NeonLook." ansi_notify
      me @ "  ^WHITE^C[, 2]: Default for object for StandardLook." ansi_notify
      me @ "  ^WHITE^C[, 3]: This is for the sorted listing." ansi_notify
      me @ "  ^WHITE^C[, 4]: The short listing, always show." ansi_notify
      me @ "  ^WHITE^C[, 5]: The short listing, show if contents exist." ansi_notify
      me @ "  ^WHITE^C[, 6]: Two line listing, always show." ansi_notify
      me @ "  ^WHITE^C[, 7]: A two line listing, title above." ansi_notify
      me @ "  ^WHITE^C[, 8]: A long listing of the contents." ansi_notify
      me @ "^CINFO^Exits options:" ansi_notify
      me @ "  ^WHITE^E[, 0]: This is the default for whatever object." ansi_notify
      me @ "  ^WHITE^E[, 1]: Default for whatever object for NeonLook." ansi_notify
      me @ "  ^WHITE^E[, 2]: Default for object for StandardLook." ansi_notify
      me @ "  ^WHITE^E[, 3]: Short display, colored." ansi_notify
      me @ "  ^WHITE^E[, 4]: Short display, no color." ansi_notify
      me @ "  ^WHITE^E[, 5]: Short display, color, Actions:." ansi_notify
      me @ "  ^WHITE^E[, 6]: Short display, no color, Actions:." ansi_notify
      me @ "  ^WHITE^E[, 7]: Long display, color." ansi_notify
      me @ "  ^WHITE^E[, 8]: Long display, no color." ansi_notify
      me @ "  ^WHITE^E[, 9]: Long display, long name." ansi_notify
      me @ "  ^WHITE^E[,10]: Long display, long name, no color." ansi_notify
      me @ "^CINFO^Done." ansi_notify exit
   THEN
   "DESCS" STRhelp @ instring 1 = IF
      me @ "^CINFO^ProtoLook v%1.2f - by Moose" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
      me @ "^CNOTE^-------------------------------------------------------" ansi_notify
      me @ "^CNOTE^To look up @desc locking to block viewing for some, type: ^NORMAL^look #help @dlock" ansi_notify
      me @ " " ansi_notify
      me @ "^CNOTE^For one-line-based descriptions:" ansi_notify
      me @ "  @desc <object>=<description>" ansi_notify
      me @ "  @ansidesc <object>=<ANSI description> ^CNOTE^--> See 'man neon' for help on NEON colors." ansi_notify
      me @ "  @htmldesc <object>=<HTML description>" ansi_notify
      me @ " " ansi_notify
      me @ "^CNOTE^For listfile-based descriptions:" ansi_notify
      me @ "  lsedit <object>=/_/De" ansi_notify
      me @ "  lsedit <object>=/_/AnsiDe" ansi_notify
      me @ "  lsedit <object>=/_/HtmlDe" ansi_notify
      me @ " " ansi_notify
      me @ "^CNOTE^If only one of them are set, then it'll show it no matter the connection type," ansi_notify
      me @ "^CNOTE^parsing it properly for that given person.  For example, if you set an ANSI" ansi_notify
      me @ "^CNOTE^description, then it will show it to non-ansi users if the regular description" ansi_notify
      me @ "^CNOTE^is not set, parsing out the color codes while doing so.  Note: The listfile" ansi_notify
      me @ "^CNOTE^descriptions take priority over the one-line based descriptions." ansi_notify
      me @ "^CNOTE^Also note that both listfile and one-line based descriptions accept MPI." ansi_notify
      me @ "^CNOTE^For help on MPI, type '^NORMAL^mpi^CNOTE^'." ansi_notify
      me @ " " ansi_notify
      me @ "^CNOTE^To run a MUF in the description, you can type the following in the start:" ansi_notify
      me @ "  @<muf program> <arguments, or blank for none>" ansi_notify
      me @ "  @<muf program> <arguments, blank for none>;@<muf program> <arguments/blank>;etc etc" ansi_notify
      me @ "  @<muf program> <args>;@<muf> <args>;<description to show after>" ansi_notify
      me @ "^CINFO^Examples: ^NORMAL^@$Cmd/@WHO Mo*" ansi_notify
      me @ "          @#48591 Args;@$Cmd/Prog" ansi_notify
      me @ "          @#4921;This is the description." ansi_notify
      me @ "^CINFO^Done." ansi_notify exit
   THEN
   "FLAGS" STRhelp @ instring 1 = IF
      me @ "^CINFO^ProtoLook v%1.2f - by Moose" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
      me @ "^CNOTE^-------------------------------------------------------" ansi_notify
      me @ "^CINFO^Flags:" ansi_notify
      me @ "  ^WHITE^LIGHT      ^NORMAL^-- Makes something visible, no matter what." ansi_notify
      me @ "  ^WHITE^PARENT     ^NORMAL^-- States that a room can be used as a parent.  Also shows dbref." ansi_notify
      me @ "  ^WHITE^ADOBE      ^NORMAL^-- Same as parent, but also can be used as a home." ansi_notify
      me @ "  ^WHITE^XFORCIBLE  ^NORMAL^-- States that an object can be forced, when the lock is set." ansi_notify
      me @ "  ^WHITE^CHOWN_OK   ^NORMAL^-- An object can be @chowned, also shows the dbref." ansi_notify
      me @ "  ^WHITE^EXAMINE_OK ^NORMAL^-- States that an object can be examined by others, plus shows dbref." ansi_notify
      me @ "  ^WHITE^ZOMBIE     ^NORMAL^-- Designates a thing as a puppet." ansi_notify
      me @ "  ^WHITE^VEHICLE    ^NORMAL^-- Designates a thing as a vehicle." ansi_notify
      me @ "  ^WHITE^PUEBLO     ^NORMAL^-- States that a player is using pueblo.  Not settable." ansi_notify
      me @ "  ^WHITE^COLOR      ^NORMAL^-- States that a player is using color." ansi_notify
      me @ "  ^WHITE^LINK_OK    ^NORMAL^-- States that the room can be linked to with exits, also shows the rooms dbref." ansi_notify
      me @ "  ^WHITE^VIEWABLE   ^NORMAL^-- Shows the rooms dbref." ansi_notify
      me @ "  ^WHITE^DARK       ^NORMAL^-- Prevents an object from showing." ansi_notify
      me @ "  ^WHITE^HIDE       ^NORMAL^-- Hide the contents for a container." ansi_notify
      me @ "  ^WHITE^SILENT     ^NORMAL^-- Prevents a player from seeing any dbrefs." ansi_notify
      me @ "  ^WHITE^LISTENER   ^NORMAL^-- States that an object is a listening object.  Not settable." ansi_notify
      me @ " " ansi_notify
      me @ "^CINFO^Powers:" ansi_notify
      me @ "  ^WHITE^SEE_ALL    ^NORMAL^-- Allows a player to see the dbrefs and any object." ansi_notify
      me @ "^CINFO^Done." ansi_notify exit
   THEN
   "LOOKTHRU" STRhelp @ instring 1 = if
      me @ "^CINFO^ProtoLook v%1.2f - by Moose" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
      me @ "^CNOTE^-------------------------------------------------------" ansi_notify
      me @ "^CNOTE^Setting up exitlookthrus are realitivly simple, and they let users peek through an" ansi_notify
      me @ "^CNOTE^exit to its destination.  Here is the basic way to set it up:" ansi_notify
      me @ "  @set <exit>=" LOOK-prop_exit_format_show strcat ":yes" strcat ansi_notify
      me @ "  @set <exit>=" LOOK-prop_exit_lookthru strcat ":<<< You peek through the exit towards its destination >>>" strcat ansi_notify
      me @ "  @set <exit>=" LOOK-prop_exit_notify strcat ":<<< %n peeks into the area from not far off >>>" strcat ansi_notify
      me @ "^CNOTE^If you want a more advanced way of setting up what is revealed on the other side" ansi_notify
      me @ "^CNOTE^you can always set '_show' to any custom format.  To get information on custom" ansi_notify
      me @ "^CNOTE^formats, type: ^NORMAL^look #help custom2" ansi_notify
      me @ "^CNOTE^And, that is it!  You are finished learning about exitlookthrus." ansi_notify
      me @ "^CINFO^Done." ansi_notify exit
   then
   "COMMANDS" STRhelp @ instring 1 = if
      me @ "^CINFO^ProtoLook v%1.2f - by Moose" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
      me @ "^CNOTE^-------------------------------------------------------" ansi_notify
      me @ "^CNOTE^@setcontents  ^NORMAL^-- Sets a custom contents listing in mpi or muf" ansi_notify
      me @ "^CNOTE^@setexits     ^NORMAL^-- Same as abovem, but for exits." ansi_notify
      me @ "^CNOTE^inventory     ^NORMAL^-- List the inventory for yourself." ansi_notify
      me @ "^CNOTE^@contents     ^NORMAL^-- List the contents for the room or object you own." ansi_notify
      me @ "^CNOTE^@exits        ^NORMAL^-- List the exits in a room or object you own." ansi_notify
      me @ "^CNOTE^@entrances    ^NORMAL^-- List the entrances for the room or object you own." ansi_notify
      me @ "^CNOTE^@llock        ^NORMAL^-- Set a look lock for an object [prevents looking at it!]" ansi_notify
      me @ "^CNOTE^@dlock        ^NORMAL^-- Set a description lock [shows the _/fde description instead!]" ansi_notify
      me @ "^CINFO^Done." ansi_notify exit
   then
   "WHATSNEW" STRhelp @ instring 1 = if
      me @ "^CINFO^ProtoLook v%1.2f - by Moose" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
      me @ "^CNOTE^-------------------------------------------------------" ansi_notify
 
      me @ "^CINFO^v2.10:  - Finished custom look, better docs, more bug fixes." ansi_notify
      me @ "The custom look is now finished.  Any object type is customizable now thanks" ansi_notify
      me @ "to the expansion.  Also, only the program can force how look appears globaly." ansi_notify
      me @ "Players nor objects can force the look format any longer.  Also seperated" ansi_notify
      me @ "the personal and object custom looks, so now they won't conflict.  Added" ansi_notify
      me @ "an F[] option for running MUF programs, with a third argument for parameters" ansi_notify
      me @ "and will also allow for you to return a string for more look format parsing." ansi_notify
      me @ "Also added a new MPI parsing function, this one P[], which will instead" ansi_notify
      me @ "parse a returned look format instead of showing a returned message." ansi_notify
      me @ "Added customization for contents and exits, so now the type of listing can" ansi_notify
      me @ "be easily changed.  Expanded the documentation to cover everything, so all" ansi_notify
      me @ "undocumented stuff can now be found.  Rewrote the options editor to be" ansi_notify
      me @ "in-line with how the custom look now works.  And it also uses $Lib/Menu now." ansi_notify
      me @ "Also moved all lastly unmoved props to $Lib/Standard at last.  Fixed a bug" ansi_notify
      me @ "where M[] crashed thanks to parameters not working right.  Fixed a bug where" ansi_notify
      me @ "long contents listings did not show fake objects so now it does.  Fixed a bug" ansi_notify
      me @ "where neon exits listing did not escape the ansi code when it should have." ansi_notify
      me @ "^CINFO^v2.02 - Fixed up the code a little." ansi_notify
      me @ "A few more props were moved to $Lib/Standard, also removed out of date" ansi_notify
      me @ "props such as /_Prefs/Container? and _Visible?.  _Visible can be replaced" ansi_notify
      me @ "by using the LIGHT flag instead.  And $Lib/Standard has a prop setting for" ansi_notify
      me @ "containers which can be changed easily.  Also expanded the custom look to" ansi_notify
      me @ "allow for each type to be usable only on certain types.  Eg. L[RT] would" ansi_notify
      me @ "show a line for only rooms or things. Basically, it works as ?[TYPES,args]" ansi_notify
      me @ "where as ? is the function letter, TYPES is the list of object types, and args" ansi_notify
      me @ "is, well, the arguments.  So far only M[] takes arguments." ansi_notify
      me @ "^CINFO^v2.01 - Standardization!" ansi_notify
      me @ "Many properties were moved to $Lib/Standard.  Standardization, a wonderful thing!" ansi_notify
      me @ "^CINFO^v2.00 - Initial Release:" ansi_notify
      me @ "A full rewrite of ProtoLook was done as $Lib/Look.  A lot of new additions," ansi_notify
      me @ "including smart descriptions. You only need one description set now," ansi_notify
      me @ "whether it is a Pueblo, ANSI, or text description it will show to any." ansi_notify
      me @ "^CINFO^Done." ansi_notify exit
   then
   "MISCPROP" STRhelp @ instring 1 = if
      me @ "^CINFO^ProtoLook v%1.2f - by Moose" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
      me @ "^CNOTE^-------------------------------------------------------" ansi_notify
      me @ "^CNOTE^On Objects:" ansi_notify
      me @ "  " LOOK-prop_looker_notify strcat "   -- Notifies the looker a message." strcat ansi_notify
      me @ "  " LOOK-prop_look_notify strcat "   -- Notifies the object owner a message." strcat ansi_notify
      me @ "  " LOOK-prop_tattle_notify strcat "   -- Tells the entire room a message." strcat ansi_notify
      me @ " NOTE: The notify props pass the appropiate object through subs." ansi_notify
      me @ "^CNOTE^Global/Room/Object Props:" ansi_notify
      me @ "  " LOOK-pref_contents? strcat "            -- Set to 'no' or 'yes' for internal contents." strcat ansi_notify
      me @ "  " LOOK-pref_internal_exits? strcat "       -- As above, but for the exits." strcat ansi_notify
      me @ "^CNOTE^Room Props:" ansi_notify
      me @ "  " LOOK-pref_dark_sleepers? strcat " -- Set to 'yes' to darken all sleepers in the room." strcat ansi_notify
      me @ "^CINFO^Done." ansi_notify exit
   then
   "CREDITS"  STRhelp @ instring 1 = if
      me @ "^CINFO^ProtoLook v%1.2f - by Moose" prog "_Version" getpropstr strtof swap FMTstring ansi_notify
      me @ "^CNOTE^-------------------------------------------------------" ansi_notify
      me @ "^CNOTE^Moose/Van   ^NORMAL^- Designing of entire ProtoLook and NeonLook programs." ansi_notify
      me @ "^CNOTE^Akari       ^NORMAL^- Partner of Moose's in designing ProtoMUCK." ansi_notify
      me @ "^CNOTE^Loki        ^NORMAL^- For designing the original NeonMUCK." ansi_notify
      me @ "^CNOTE^Revar/Foxen ^NORMAL^- For designing the original FuzzballMUCK." ansi_notify
      me @ "^CINFO^Done." ansi_notify exit
   then
   me @ "^CINFO^Invalid look #help topic.  Type 'look #help' for help." ansi_notify
;
 
: cmd-setconexits[ str:Args str:STRprop str:STRname str:STRcmd int:BOLlock? -- ]
   Args @ strip dup not if
      me @ "^CYAN^Syntax: ^AQUA^" STRcmd @ "^^" "^" subst strcat " <object>=<"
      strcat STRname @ "^^" "^" subst strcat ">" strcat ansi_notify exit
   then
   "=" split strip swap strip match dup ok? not if
      swap pop #-2 dbcmp if
         me @ "^CINFO^I don't know which one you mean!" ansi_notify exit
      then
      me @ "^CINFO^I can't find that here." ansi_notify exit
   then
   me @ over controls not if
      pop pop me @ "^CFAIL^Permission denied." ansi_notify exit
   then
   BOLlock? @ if
      swap parselock swap
   then
   STRprop @ 3 pick setprop if
      "^CSUCC^%s set."
   else
      "^CSUCC^%s cleared."
   then
   STRname @ "%s" subst me @ swap ansi_notify
;
 
: cmd-@stuff[ str:Args int:Type int:BOLhere? -- ]
   0 VAR! idx VAR ref "" VAR! STRlist VAR daref
   Args @ strip dup not if
      pop BOLhere? @ if "here" else "me" then
   then
   match dup ok? not if
      #-2 dbcmp if
         me @ "^CINFO^I don't know which one you mean!" ansi_notify exit
      then
      me @ "^CINFO^I can't find that here." ansi_notify exit
   then
   me @ over controls not if
      me @ "^CFAIL^Permission denied." ansi_notify exit
   then
   dup program? over exit? or Type @ 3 = not and if
      me @ "^CFAIL^Programs and exits can't have exits nor objects." ansi_notify exit
   then
   dup daref !
   Type @ 1 = if
      dup ref ! contents
   then
   Type @ 2 = if
      dup exits #-1 ref !
   then
   Type @ 3 = if
      dup ref ! #-1 nextentrance
   then
   BEGIN
      dup ok? WHILE
      me @ over ANSI-FULLNAME
      Type @ 3 = not 3 pick exit? and if
         "^CNOTE^[^CINFO^To:" strcat over getlink dup ok? if me @ swap ANSI-FULLNAME else "^NORMAL^*NOTHING*" then strcat "^CNOTE^]" strcat
      then
      Type @ 3 = 3 pick exit? and if
         "^CNOTE^[^CINFO^From:" strcat over dup #0 dbcmp if pop "^NORMAL^*NOTHING" else location me @ swap ANSI-FULLNAME then strcat "^CNOTE^]" strcat
      then
      STRlist @ dup if
         "^NORMAL^, " strcat
      then
      swap strcat STRlist ! idx ++
      Type @ 3 = if
         ref @ swap NEXTENTRANCE
 
      else
         NEXT dup ok? not ref @ ok? and BOLhere? @ and if
           pop ref @ exits #-1 ref !
         then
      then
   REPEAT
   pop
   Type @ 1 = if
      daref @ me @ dbcmp if
         "^BLUE^Inventory: "
      else
         "^BLUE^Contents [%n^BLUE^]: " me @ daref @ ANSI-FULLNAME "%n" subst
      then
   else
      Type @ 2 = if
          "^BLUE^Exits: "
      else
         Type @ 3 = if
            "^BLUE^Entrances: "
         else
            "^BLUE^Listing: "
         then
      then
   then
   me @ swap STRlist @ dup not if pop "^NORMAL^*NONE*" then strcat ansi_notify
   me @ idx @ intostr idx @ 1 = if " object listed." else " objects listed." then strcat "^CSUCC^" swap strcat ansi_notify
;
 
: OPTIONS-conv_look_standard[ int:LOOKstnd -- str:STRlookstnd ]
   LOOKstnd @ CASE
      4 = WHEN
         "Custom Format"
      END
      3 = WHEN
         "Standard Look"
      END
      2 = WHEN
         "NeonLook"
      END
      1 = WHEN
         "ProtoLook"
      END
      DEFAULT pop
         prog LOOK-pref_look_stnd_me? getpropval
         dup 0 < over 4 > or IF
            pop DefLook dup 0 < over 4 > or IF
               pop 1
            THEN
         THEN
         dup 0 = IF
            pop "ProtoLook"
         ELSE
            (i) OPTIONS-conv_look_standard
         THEN
         "DEFAULT: " swap strcat
      END
   ENDCASE
;
 
: OPTIONS-check_look_standard[ ref:REFobj str:STRprop dict:DICToptions dict:DICTreturn dict:DICTdisplay -- dict:DICTdisplay dict:DICTreturn' str:STRreturn int:BOLre-init? ]
   VAR STRreturn
   DICToptions @ "Object" ARRAY_getitem
   DICToptions @ "Property" ARRAY_getitem
   over over getpropval
   dup 0 < over 4 > or IF
      pop prog LOOK-pref_look_stnd_me? getpropval
      dup 0 < over 4 > or IF
         pop DefLook dup 0 < over 4 > or IF
            pop 1
         THEN
      THEN
   THEN
   3 pick 3 pick getpropval over dup intostr STRreturn ! = not IF
      me @ "^CFAIL^That is not a valid look setting.  Setting to the default setting." ansi_notify
      setprop
   ELSE
      pop pop pop
   THEN
   DICTdisplay @ DICTreturn @ STRreturn @ atoi OPTIONS-conv_look_standard 1
;
 
: OPTIONS-look_standard[ ref:REFobj str:STRprop str:STRcaption str:STRflaglvl str:STRchoice str:STRask -- str:STRname dict:M_option' ]
   REFobj @ dtos " - Standard Type" strcat " - " strcat systime intostr strcat " - " strcat STRcaption @ strcat
   {
      "Caption"  STRcaption @
      "Justify"  1
      "Choice"   STRchoice @
      "Object"   REFobj @
      "Property" STRprop @
      "PropType" M_PROP_INTEGER
      "Type"     M_TYPE_SMATCH_LINE
      "Default"  14 OPTIONS-conv_look_standard
      "Convert"  'OPTIONS-conv_look_standard
      "Smatch"   "{0|1|2|3|4}"
      "Message"
          {
             "^CINFO^Look Types:"
             "  ^CNOTE^0  ^NORMAL^-- The default internal choice for look standard."
             "  ^CNOTE^1  ^NORMAL^-- The internal, standard ProtoLook format."
             "  ^CNOTE^2  ^NORMAL^-- The old NeonLook format."
             "  ^CNOTE^3  ^NORMAL^-- The really, really old and ancient standard look format."
             "  ^CNOTE^4  ^NORMAL^-- For custom formats."
          }list
      "Ask"      STRask @
      "Address"  'OPTIONS-check_look_standard
      STRflaglvl @ IF
         "FlagLvl"  STRflaglvl @
      THEN
   }M_option
;
 
: OPTIONS-look_format[ ref:REFobj str:STRprop str:STRcaption str:STRflaglvl str:STRchoice str:STRask -- str:STRname dict:M_option' ]
   REFobj @ dtos " - Look Format" strcat " - " strcat systime intostr strcat " - " strcat STRcaption @ strcat
   {
      "Caption"  STRcaption @
      "Justify"  1
      "Choice"   STRchoice @
      "Object"   REFobj @
      "Property" STRprop @
      "PropType" M_PROP_STRING
      "Type"     M_TYPE_LINE
      "Message"
          {
             "^CINFO^Look Types:"
             "^CNOTE^For custom formats, it is really simple.  The function format is: ^NORMAL^?[TYPES,Args]"
             "^WHITE^ARGS  ^NORMAL^- Arguments sent to function."
             "^WHITE^TYPES ^NORMAL^- The object type list it will show on."
             "         ^WHITE^R  ^NORMAL^- Show for rooms."
             "         ^WHITE^T  ^NORMAL^- Show for things."    
             "         ^WHITE^P  ^NORMAL^- Show for players."
             "         ^WHITE^F  ^NORMAL^- Show for programs."    
             "         ^WHITE^E  ^NORMAL^- Show for exits."   
             "  ^WHITE^?   ^NORMAL^- The function name: (&how for M[] and P[] is the dbref)"
             "         ^WHITE^L  ^NORMAL^- Shows a line."
             "         ^WHITE^N  ^NORMAL^- The name of the object."
             "         ^WHITE^D  ^NORMAL^- Description of the object."
             "         ^WHITE^S  ^NORMAL^- Success/fail message, as applicable."
             "         ^WHITE^E  ^NORMAL^- Contents listing.  Parameter [ARGS] is > 0.'"
             "         ^WHITE^C  ^NORMAL^- Exits/Action listing. Parameter [ARGS] is > 0'"
             "         ^WHITE^M  ^NORMAL^- Parse MPI and show a message.  The MPI in ARGS."
             "         ^WHITE^P  ^NORMAL^- Parse MPI for more look format stuff to parse.  MPI in ARGS."
             "         ^WHITE^F  ^NORMAL^- Run a given MUF program. Arguments in ARGS. Parses returned string."
          }list
      "Ask"      STRask @
      STRflaglvl @ IF
         "FlagLvl"  STRflaglvl @
      THEN
   }M_option
;
 
: OPTIONS-forced_format[ ref:REFobj str:STRprop str:STRcaption str:STRflaglvl str:STRchoice -- str:STRname dict:M_option' ]
   REFobj @ dtos " - Force Format" strcat " - " strcat systime intostr strcat " - " strcat STRcaption @ strcat
   {
      "Caption"  STRcaption @
      "SepChar"  " "
      "Justify"  1
      "Choice"   STRchoice @
      "Object"   REFobj @
      "Property" STRprop @
      "Type"     M_TYPE_TOGGLABLE
      "Default"  "NO"
      "Toggle"   "yes"
      STRflaglvl @ IF
         "FlagLvl"  STRflaglvl @
      THEN
   }M_option
;
 
: Cmd-OptionsEditor[ str:STRoptions -- ]
   VAR ref
   STRoptions @ strip dup not IF
      pop #-1 ref !
   ELSE
      match dup Ok? not IF
         #-2 dbcmp IF
            "^CINFO^I don't know which one you mean!"
         ELSE
            "^CINFO^I cannot find that here."
         THEN
         me @ swap ansi_notify EXIT
      THEN
      me @ over controls not IF
         pop me @ "^CFAIL^" "noperm_mesg" sysparm 1 escape_ansi ansi_notify EXIT
      THEN
      ref !
   THEN
   {
      "^CYAN^ProtoLook Options"
      "^PURPLE^~~~~~~~~~~~~~~~~~~"
      prog LOOK-pref_force_fmt? getpropstr "y" stringpfx IF
      THEN
   }list
   {
   }list
   {
     (*******OBJECTS*******)
    ref @ Ok? IF
      "LINE-OBJECTS-1"
         {
            "Message"
               {
 
                  "^WHITE^Object Settings:"
                  "^NORMAL^~~~~~~~~~~~~~~~~~"
               }list
            "Caption"   "^CYAN^Object Settings:"
            "Type"      M_TYPE_STRING
         }M_option
      ref @ LOOK-pref_look_stnd? "Look Standard Type" "" "D1"
      "^GREEN^Enter the number for the look standard now [0-4] [. = keep as is, space = default]:"
      (--->) OPTIONS-look_standard
      ref @ LOOK-pref_look_fmt "Default Look Format" "" "D2"
      "^GREEN^Enter the default look format below [. = keep as is, space = default]:"
      (--->) OPTIONS-look_format
    THEN
     (*******PERSONAL******)
      "LINE-PERSONAL-1"
         {
            "Message"
               {
                ref @ Ok? IF
                  " "
                THEN
                  "^WHITE^Personal Settings:"
                  "^NORMAL^~~~~~~~~~~~~~~~~~~~"
               }list
            "Caption"   "^CYAN^Personal Settings:"
            "Type"      M_TYPE_STRING
         }M_option
      me @ LOOK-pref_look_stnd_me? "Look Standard Type" "" "P1"
      "^GREEN^Enter the number for the personal look standard now [0-4] [. = keep as is, space = default]:"
      (--->) OPTIONS-look_standard
      me @ LOOK-pref_look_fmt_me "Default Look Format" "" "P2"
      "^GREEN^Enter the personal default look format below [. = keep as is, space = default]:"
      (--->) OPTIONS-look_format
      me @ LOOK-pref_look_room_fmt_me "Room Look Format" "" "P3"
      "^GREEN^Enter the personal room look format below [. = keep as is, space = default]:"
      (--->) OPTIONS-look_format
      me @ LOOK-pref_look_thing_fmt_me "Thing Look Format" "" "P4"
      "^GREEN^Enter the personal thing look format below [. = keep as is, space = default]:"
      (--->) OPTIONS-look_format
      me @ LOOK-pref_look_player_fmt_me "Player Look Format" "" "P5"
      "^GREEN^Enter the personal player look format below [. = keep as is, space = default]:"
      (--->) OPTIONS-look_format
      me @ LOOK-pref_look_program_fmt_me "Program Look Format" "" "P6"
      "^GREEN^Enter the personal program look format below [. = keep as is, space = default]:"
      (--->) OPTIONS-look_format
      me @ LOOK-pref_look_exit_fmt_me "Exit Look Format" "" "P7"
      "^GREEN^Enter the personal exit look format below [. = keep as is, space = default]:"
      (--->) OPTIONS-look_format
      me @ LOOK-pref_terse? "Look Tersing?" "" "P8" (--->) OPTIONS-forced_format
     (*******GLOBALS*******)
      "LINE-GLOBAL-1"
         {
            "Message"
               {
                  " "
                  "^WHITE^Global Settings:"
                  "^NORMAL^~~~~~~~~~~~~~~~~~"
               }list
            "Caption"   "^CYAN^Global Settings:"
            "Type"      M_TYPE_STRING
            "FlagLvl"   "ARCHWIZARD"
         }M_option
      "$Lib/Look" match LOOK-pref_look_stnd_me? "Look Standard Type" "ARCHWIZARD" "G1"
      "^GREEN^Enter the number for the global look standard now [0-4] [. = keep as is, space = default]:"
      (--->) OPTIONS-look_standard
      "$Lib/Look" match LOOK-pref_look_fmt_me "Default Look Format" "ARCHWIZARD" "G2"
      "^GREEN^Enter the global default look format below [. = keep as is, space = default]:"
      (--->) OPTIONS-look_format
      "$Lib/Look" match LOOK-pref_look_room_fmt_me "Room Look Format" "ARCHWIZARD" "G3"
      "^GREEN^Enter the global room look format below [. = keep as is, space = default]:"
      (--->) OPTIONS-look_format
      "$Lib/Look" match LOOK-pref_look_thing_fmt_me "Thing Look Format" "ARCHWIZARD" "G4"
      "^GREEN^Enter the global thing look format below [. = keep as is, space = default]:"
      (--->) OPTIONS-look_format
      "$Lib/Look" match LOOK-pref_look_player_fmt_me "Player Look Format" "ARCHWIZARD" "G5"
      "^GREEN^Enter the global player look format below [. = keep as is, space = default]:"
      (--->) OPTIONS-look_format
      "$Lib/Look" match LOOK-pref_look_program_fmt_me "Program Look Format" "ARCHWIZARD" "G6"
      "^GREEN^Enter the global program look format below [. = keep as is, space = default]:"
      (--->) OPTIONS-look_format
      "$Lib/Look" match LOOK-pref_look_exit_fmt_me "Exit Look Format" "ARCHWIZARD" "G7"
      "^GREEN^Enter the global exit look format below [. = keep as is, space = default]:"
      (--->) OPTIONS-look_format
      "$Lib/Look" match LOOK-pref_force_fmt? "Force Format?" "ARCHWIZARD" "G8"
      (--->) OPTIONS-forced_format
     (********MISC*********)
      "LINE-MISC-1"
         {
            "Caption"   " "
            "Type"      M_TYPE_STRING
         }M_option
      "QUIT"
         {
            "Caption"   "^RED^Quit the editor"
            "Choice"    "Q"
            "Type"      M_TYPE_NULL
            "Exit"      M_BOL_TRUE
         }M_option
   }M_run pop pop
   me @ "^CSUCC^Exiting." ansi_notify
;
 
: main[ str:STRargs -- ]
   STRargs @ strip dup STRargs ! dup "#help" stringcmp not swap "#help " instring 1 = or if
      STRargs @ 5 strcut swap pop strip LOOK-help EXIT
   then
   "@setcontents" command @ instring 1 = if
      STRargs @ LOOK-prop_contents_listing "Obvcontents" "@setcontents" 0 cmd-setconexits exit
   then
   "@setexits" command @ instring 1 = if
      STRargs @ LOOK-prop_exit_listing "Obvexits" "@setexits" 0 cmd-setconexits exit
   then
   "@dlock" command @ instring 1 = if
      STRargs @ LOOK-prop_lock_desc "DescLock" "@dlock" 1 cmd-setconexits exit
   then
   "@llock" command @ instring 1 = if
      STRargs @ LOOK-prop_lock_look "LookLock" "@llock" 1 cmd-setconexits exit
   then
   "@exits" command @ instring 1 = if
      STRargs @ 2 1 cmd-@stuff exit
   then
   "@contents" command @ instring 1 = "contents" command @ instring 1 = or if
      STRargs @ 1 1 cmd-@stuff exit
   then
   "inventory" command @ instring 1 = if
      STRargs @ 1 0 cmd-@stuff exit
   then
   "@entrances" command @ instring 1 = if
      STRargs @ 3 1 cmd-@stuff exit
   then
   STRargs @ dup "#options" stringcmp not swap "#options " instring 1 = or if
      STRargs @ 8 strcut swap pop strip Cmd-OptionsEditor EXIT
   then
   STRargs @ dup "#edit" stringcmp not swap "#edit " instring 1 = or if
      STRargs @ 5 strcut swap pop Cmd-Editor EXIT
   then
   STRargs @ dup "#fake" stringcmp not swap "#fake " instring 1 = or if
      STRargs @ 5 strcut swap pop Cmd-FakeEditor EXIT
   then
   STRargs @ "#terse" stringcmp not if
      me @ LOOK-pref_terse? over over getpropstr "yes" stringcmp not if
         remove_prop me @ "^CSUCC^Look tersing is now disabled." ansi_notify
      else
         "yes" setprop me @ "^CSUCC^Look tersing is enabled." ansi_notify
      then
      EXIT
   then
   STRargs @ CMD-look
;
 
PUBLIC SafeCall              ( ? dbref           --                  )
PUBLIC Unparse               ( dbref             -- str              )
PUBLIC Contents-Filter-ARRAY ( addr dbref        -- arr              )
PUBLIC Contents-Filter       ( addr dbref        -- dbref1..dbrefi i )
PUBLIC Exits-Filter          ( addr dbref        -- dbref1..dbrefi i )
PUBLIC Get-Contents-ARRAY    ( dbref             -- arr              )
PUBLIC Get-Contents          ( dbref             -- dbref1..dbrefi i )
PUBLIC Get-Exits             ( dbref             -- arr              )
PUBLIC Long-Display-ARRAY    ( arr               --                  )
PUBLIC Long-Display          ( dbref1..dbrefi i  --                  )
PUBLIC Short-List-ARRAY      ( arr               -- str              )
PUBLIC Short-List            ( dbref1..dbrefi i  -- str              )
PUBLIC Short-Display-ARRAY   ( arr               --                  )
PUBLIC Short-Display         ( dbref1..dbrefi    --                  )
PUBLIC List-Contents         ( str dbref         --                  )
PUBLIC ParseMUF              ( str               -- str'             )
PUBLIC STR-desc              ( str               --                  )
PUBLIC STR-any-desc          ( str int           --                  )
PUBLIC STR-desc-parse        ( str int           --                  )
PUBLIC ARR-desc              ( arr int           --                  )
PUBLIC DBSTR-desc            ( dbref str         --                  )
PUBLIC DBSTR-desc-parse      ( dbref str int     --                  )
PUBLIC DBARR-desc            ( dbref arr int     --                  )
PUBLIC ARR-TEXTCONV          ( arr int int       -- ar               )
PUBLIC DB-show-name          ( dbref             --                  )
PUBLIC DB-show-desc          ( dbref             --                  )
PUBLIC DB-show-succ          ( dbref             --                  )
PUBLIC DB-show-exits         ( dbref int         --                  )
PUBLIC DB-show-contents      ( dbref int         --                  )
PUBLIC DB-do-notify          ( dbref             --                  )
PUBLIC DB-view-format        ( ref ref str int   --                  )
PUBLIC DB-exit-look          ( dbref             --                  )
PUBLIC DB-desc               ( dbref             --                  )
PUBLIC CMD-look              ( str               --                  )
$pubdef :
$pubdef SafeCall "$Lib/Look" match "SafeCall" CALL
$pubdef .SafeCall "$Lib/Look" match "SafeCall" CALL
$pubdef Unparse "$Lib/Look" match "Unparse" CALL
$pubdef .Unparse "$Lib/Look" match "Unparse" CALL
$pubdef Contents-Filter "$Lib/Look" match "Contents-Filter" CALL
$pubdef .Contents-Filter "$Lib/Look" match "Contents-Filter" CALL
$pubdef Contents-Filter-ARRAY "$Lib/Look" match "Contents-Filter-ARRAY" CALL
$pubdef Exits-Filter "$Lib/Look" match "Exits-Filter" CALL
$pubdef Get-Exits "$Lib/Look" match "Get-Exits" CALL
$pubdef Get-Contents "$Lib/Look" match "Get-Contents" CALL
$pubdef .Get-Contents "$Lib/Look" match "Get-Contents" CALL
$pubdef Get-Contents-ARRAY "$Lib/Look" match "Get-Contents-ARRAY" CALL
$pubdef Long-Display "$Lib/Look" match "Long-Display" CALL
$pubdef .Long-Display "$Lib/Look" match "Long-Display" CALL
$pubdef Long-Display-ARRAY "$Lib/Look" match "Long-Display-ARRAY" CALL
$pubdef Short-List "$Lib/Look" match "Short-List" CALL
$pubdef .Short-List "$Lib/Look" match "Short-List" CALL
$pubdef Short-List-ARRAY "$Lib/Look" match "Short-List-ARRAY" CALL
$pubdef Short-Display "$Lib/Look" match "Short-Display" CALL
$pubdef .Short-Display "$Lib/Look" match "Short-Display" CALL
$pubdef Short-Display-ARRAY "$Lib/Look" match "Short-Display-ARRAY" CALL
$pubdef List-Contents "$Lib/Look" match "List-Contents" CALL
$pubdef .List-Contents "$Lib/Look" match "List-Contents" CALL
$pubdef ParseMUF "$Lib/Look" match "ParseMUF" CALL
$pubdef STR-desc "$Lib/Look" match "STR-desc" CALL
$pubdef STR-any-desc "$Lib/Look" match "STR-any-desc" CALL
$pubdef STR-desc-parse "$Lib/Look" match "STR-desc-parse" CALL
$pubdef ARR-desc "$Lib/Look" match "ARR-desc" CALL
$pubdef DBSTR-desc "$Lib/Look" match "DBSTR-desc" CALL
$pubdef .DBSTR-desc "$Lib/Look" match "DBSTR-desc" CALL
$pubdef DBSTR-desc-parse "$Lib/Look" match "DBSTR-desc-parse" CALL
$pubdef DBARR-desc "$Lib/Look" match "DBARR-desc" CALL
$pubdef ARR-TEXTCONV "$Lib/Look" match "ARR-TEXTCONV" CALL
$pubdef DB-show-name "$Lib/Look" match "DB-show-name" CALL
$pubdef DB-show-desc "$Lib/Look" match "DB-show-desc" CALL
$pubdef DB-show-succ "$Lib/Look" match "DB-show-succ" CALL
$pubdef DB-show-exits "$Lib/Look" match "DB-show-exits" CALL
$pubdef DB-show-contents "$Lib/Look" match "DB-show-contents" CALL
$pubdef DB-show-exit -1 "$Lib/Look" match "DB-show-exits" CALL
$pubdef DB-show-cont -1 "$Lib/Look" match "DB-show-contents" CALL
$pubdef DB-do-notify "$Lib/Look" match "DB-do-notify" CALL
$pubdef DB-exit-look "$Lib/Look" match "DB-exit-look" CALL
$pubdef DB-view-format "$Lib/Look" match "DB-view-format" CALL
$pubdef DB-desc "$Lib/Look" match "DB-desc" CALL
$pubdef .DB-desc "$Lib/Look" match "DB-desc" CALL
$pubdef CMD-look "$Lib/Look" match "CMD-look" CALL
$pubdef .CMD-look "$Lib/Look" match "CMD-look" CALL
