(*
   LIB-menu v1.03
   Author: Moose
   E-mail: contikimoose@hotmail.com
 
  Additions:
  ~~~~~~~~~~~~
     v1.03: Whoops, the "address" option didn't work right.  Was
            crashing, but works now.  It also replaced the menu
            option on the menu initiation.  Both are fixed.
     v1.02: Little bug fixes.  Now it works properly!
     v1.01: Important modifcation to the "address" option, adding
            DICToptions, DICTdisplay as parameters.  Also added
            DICTdisplay and BOLreinit? as returns.  BOLreinit?, if
            true, will reinit the entire menu screen, leaving out
            the DICTreturn dictionary here though.
            Added a "convert" option to allow for the proptypes
            to be converted to show something else on the menu.
            Fixed a few teensy bugs here and there
            Allow message to be shown for string types.
 
  How to use $Lib/Menu:
  ~~~~~~~~~~~~~~~~~~~~~~
   }M_run [ arr:ARRheader arr:ARRfooter options_list
                       -- dict:DICTreturn_vals ]
 
   ARRheader: What is displayed before the menu, always.
   ARRfooter: What is displayed before the footer, always.
   DICT_return_vals: A dictionary returning all of the set values that
                     were not set onto an object's property.  It will
                     return it with the given names as the indexes,
                     then the returned value.  0 is returned if it
                     is remained as the default or cleared.  No values
                     are returned of all of the items were set on
                     objects.
   options_list: These are all of the options used with }M_option.
 
   }M_option [ str:STRname options
                     -- str:STRindex_name dict:DICToption ]
 
   STRname: This is the name for the given option.
   STRindex_name: This is returned and should not be touched.
   DICToption: This is returned and should not be touched.
   options: The list of options, which can be any as follows:
      Caption  = Set to what you want to see on the menu
                 display for this option.  If it is not
                 set, then it defaults to STRname.  It
                 WILL parse neon colors.  If it is an
                 M_TYPE_STRING type option, then it will
                 ONLY display this line.
      Choice   = A character here, this is what is put
                 in in the menu for the choice that the
                 user wants to make.  If it is not set,
                 then it will default to the list number.
                 It will also default to the list number
                 if it is a number that is greater than
                 the list number.  Unfortunately, it is
                 impossible to block multiple choices of
                 the same kind.
      Justify  = Allows you to justify to any given
                 length.  If it is a negative number, it
                 will justify to the right instead of
                 the usual left.  If it is set to nothing
                 then it will not justify.  If you put it
                 at 1, then it will justify everything at
                 the same length.
      SepChar  = The character used to seperate the
                 caption from what it is currently set to.
                 It will default to ":" if it is not set.
      Message  = A {}list array of strings to be shown
                 directly after the option is chosen.
      Defualt  = The default setting for this, mostly for
                 display purposes.  If it is not set, then
                 it will default to "(Unset)".  It WILL
                 parse neon colors.
      Convert  = Convert with this address function
                 instead.  It'll give the any variable
                 chosen with PropType, which it'll send
                 to this function.  Then a string of
                 what is shown should be returned.  Only
                 works with SMATCH_LINE and LINE types.
      Exit     = Set this to M_BOL_TRUE or M_BOL_FALSE for
                 whether you want this to quit for when
                 it is done the operation.  It will
                 default to M_BOL_FALSE.
      PreStr   = This is what will go before everything.
                 Does not have to be set.  It WILL parse
                 neon colors.
      Object   = Set this to a valid dbref.  If it is not
                 set, then it will be a value returned via
                 DICTreturn_values after }M_run.
      Property = If Object is set, then this MUST be set
                 to a valid prop or else it will crash.
      FlagLvl  = Set this to a flag to check for permission
                 with.  This is optional.  If it is not set
                 then it will not be checked.  It is useful
                 for, say, you want to check the WIZARD flag
                 for wizard-only permissions.  If the user
                 [me @] does not have permission, then the
                 option will not even be displayed or checked.
      Type     = The type of option to be ran.  It can be one
                 of the following:
             M_TYPE_LINE ------: This will ask for a line of
                 information.  Can also be used for dbref
                 lists, integers, etc.  It will make sure it
                 matches the PropType setting.
             M_TYPE_SMATCH_LINE: As above, except it must
                 match to the SMatch setting.
             M_TYPE_TOGGLABLE -: This is for togglable stuff,
                 so that it will set and unset the Togglable
                 setting to the prop / returns.
             M_TYPE_STRING ----: This is useful for displaying
                 a string [neon ansi allowed] from the Caption
                 line.  It does not work as an option.  Just
                 shows a string.
             M_TYPE_NULL ------: This will not display the end
                 of the line, nor will it check object props.
                 But it is useful for if you wish to, say, run
                 a function.
             M_TYPE_NODISPLAY -: This is for some option you
                 wish to be kept hidden.  It works like the
                 M_TYPE_NULL option, but shows nothing on the
                 menu display.
      PropType = The type of setting for M_TYPE_LINE and
                 M_TYPE_SMATCH_LINE types.  Can be:
             M_PROP_STRING ---------: Strings only.
 
             M_PROP_INTEGER --------: Integer only.
             M_PROP_FLOAT ----------: Floating numbers only.
             M_PROP_LOCK -----------: Its a lock.
             M_PROP_DBREF ----------: Dbrefs, any kind.
             M_PROP_PLYR_DBREF -----: Player dbrefs only.
             M_PROP_PUP_DBREF ------: Puppet dbrefs only.
             M_PROP_PLYR_PUP_DBREF -: Player or puppet dbrefs only.
             M_PROP_REFLIST --------: A reflist for any dbref kind.
             M_PROP_PLYR_REFLIST ---: A player reflist.
             M_PROP_PUP_REFLIST ----: A puppet reflist.
             M_PROP_PLYR_PUP_REFLIST: A player/puppet reflist.
             M_PROP_PROPLIST -------: Proplist for lsedit lists.
             M_PROP_PROPVALS -------: A list of propvals [for things
                                      like /_Prefs/Info/ propdirs]
      Ask      = This is shown for when asking for information
                 when running M_TYPE_LINE and M_TYPE_SMATCH_LINE
 
                 tpes.
      Smatch   = This is what is smatched to for when using
                 M_TYPE_SMATCH_LINE types.
      Address  = This can be used for any option type, for when
                 you wish to run a function.  The arguments:
                 [ ref:REFobj str:STRprop dict:DICToptions dict:DICTreturn dict:DICTdisplay
                                -- dict:DICTdisplay dict:DICTreturn str:STRreturn int:BOLre-init? ]
      Toggle   = The setting for M_TYPE_TOGGLABLE to set on/off.
 
   Example:
   {
      "Menu"
      "~~~~~"
   }list
   {
      "Enter your option below:"
   }list
   {
      "Gender" {
                 "Caption"  "Your Gender"
                 "Choice"   "1"
                 "Justify"  20
                 "Object"   me @
                 "Property" "/Sex"
                 "PropType" M_PROP_STRING
                 "Default"  "Unknown"
                 "Exit"     M_BOL_FALSE
                 "Type"     M_TYPE_SMATCH_LINE
                 "Smatch"   "{male|boy|female|girl|guy|woman}"
               }M_option
      "Terse"  {
                 "Object"   me @
                 "Property" "/_Prefs/Terse?"
                 "Default"  "No"
                 "Type"     M_TYPE_TOGGLABLE
                 "Toggle"   "Yes"
               }M_option
   }M_run
 *)
 
$author      Moose
$lib-version 1.03
 
$include $Lib/Editor
$include $Lib/Puppet
$include $Lib/Strings
 
$def PROP-Main      "/@/" PID intostr strcat
$def PROP-Count     PROP-main "/Count" strcat
$def PROP-MaxLen    PROP-main "/MaxLen" strcat
$def PROP-ChoiceLen PROP-main "/ChoiceLen" strcat
 
$pubdef M_BOL_FALSE             1
$pubdef M_BOL_TRUE              2
$pubdef M_TYPE_TOGGLABLE        1
$pubdef M_TYPE_LINE             2
$pubdef M_TYPE_SMATCH_LINE      3
$pubdef M_TYPE_NULL             4
$pubdef M_TYPE_STRING           5
$pubdef M_TYPE_NODISPLAY        6
$pubdef M_PROP_STRING           1
$pubdef M_PROP_INTEGER          2
$pubdef M_PROP_FLOAT            3
$pubdef M_PROP_LOCK             4
$pubdef M_PROP_DBREF            5
$pubdef M_PROP_PLYR_DBREF       6
$pubdef M_PROP_PUP_DBREF        7
$pubdef M_PROP_PLYR_PUP_DBREF   8
$pubdef M_PROP_REFLIST          9
$pubdef M_PROP_PLYR_REFLIST     10
$pubdef M_PROP_PUP_REFLIST      11
$pubdef M_PROP_PLYR_PUP_REFLIST 12
$pubdef M_PROP_PROPLIST         13
$pubdef M_PROP_PROPVALS         14
 
$include $Lib/Menu
 
$def    M_TYPE_MAX              M_TYPE_NODISPLAY
$def    M_PROP_MAX              M_PROP_PROPVALS
 
: ToSTR[ ANYval -- STRval ]
   ANYval @ CASE
      String? WHEN
         ANYval @
      END
      Int? WHEN
 
         ANYval @ dup IF intostr ELSE pop "" THEN
      END
      Float? WHEN
         ANYval @ dup IF ftostr ELSE pop "" THEN
      END
      Dbref? WHEN
         ANYval @ dup Ok? IF me @ over controls IF unparseobj ELSE name THEN ELSE pop "" THEN
      END
      Lock? WHEN
         ANYval @ dup IF unparselock ELSE pop "" THEN
      END
      DEFAULT
         pop ""
      END
   ENDCASE
;
 
: CONV-combine[ str:STRval ANYval int:INTtype -- ANYval' int:BOLsucc? ]
   VAR BOLrem?
   INTtype @ CASE
      M_PROP_STRING = WHEN
         STRval @
      END
      M_PROP_INTEGER = WHEN
         STRval @ Number? IF
            STRval @ atoi 1
         ELSE
            me @ "^CFAIL^That is not a valid number."
            ansi_notify ANYval @ 0
         THEN
      END
      M_PROP_FLOAT = WHEN
         STRval @ strtof Error? not IF
            STRval @ strtof 1
         ELSE
            pop me @ "^CFAIL^That is not a valid floating number."
            ansi_notify ANYval @ 0
         THEN
      END
      M_PROP_LOCK = WHEN
         STRval @ ParseLock dup IF
            1
         ELSE
            pop me @ "^CFAIL^That is not a valid lock."
            ansi_notify ANYval @ 0
         THEN
      END
      M_PROP_DBREF = WHEN
         STRval @ match dup Ok? IF
            1
         ELSE
            pop me @ "^CFAIL^That is not a valid dbref."
            ansi_notify ANYval @ 0
         THEN
      END
      M_PROP_PLYR_DBREF = WHEN
         STRval @ pmatch dup Ok? IF
            1
         ELSE
            pop me @ "^CFAIL^That is not a valid player dbref."
            ansi_notify ANYval @ 0
         THEN
      END
      M_PROP_PUP_DBREF = WHEN
         STRval @ puppet_match dup Ok? IF
            1
         ELSE
            pop me @ "^CFAIL^That is not a valid puppet dbref."
            ansi_notify ANYval @ 0
         THEN
      END
      M_PROP_PLYR_PUP_DBREF = WHEN
         STRval @ pmatch dup Ok? not IF
            pop STRval @ puppet_match
         THEN
         dup Ok? IF
            1
         ELSE
            pop me @
            "^CFAIL^That is not a valid player nor puppet dbref."
            ansi_notify ANYval @ 0
         THEN
      END
      M_PROP_REFLIST = WHEN
         ANYval @ Array? not IF
            { }list ANYval !
         THEN
         { }list STRval @ " " EXPLODE_ARRAY
         FOREACH
            swap pop STRval ! 0 BOLrem? !
            STRval @ dup "!" stringpfx IF
               1 strcut swap pop 1 BOLrem? !
            THEN
            dup IF match ELSE #-1 THEN dup Ok? IF
               { swap }list
               BOLrem? @ IF
                  ARRAY_diff
               ELSE
                  ARRAY_union
               THEN
            ELSE
               pop STRval @ swap ARRAY_appenditem
            THEN
         REPEAT
         dup ARRAY_count IF
            ", " ARRAY_join "^CFAIL^" swap strcat
            " are not proper dbrefs." strcat
            me @ swap ansi_notify
         ELSE
            pop
         THEN
         1
      END
      M_PROP_PLYR_REFLIST = WHEN
         ANYval @ Array? not IF
            { }list ANYval !
         THEN
         { }list STRval @ " " EXPLODE_ARRAY
         FOREACH
            swap pop STRval ! 0 BOLrem? !
            STRval @ dup "!" stringpfx IF
               1 strcut swap pop 1 BOLrem? !
            THEN
            dup IF pmatch ELSE #-1 THEN dup Ok? IF
               { swap }list
               BOLrem? @ IF
                  ARRAY_diff
               ELSE
                  ARRAY_union
               THEN
            ELSE
               pop STRval @ swap ARRAY_appenditem
            THEN
         REPEAT
         dup ARRAY_count IF
            ", " ARRAY_join "^CFAIL^" swap strcat
            " are not proper dbrefs." strcat
            me @ swap ansi_notify
         ELSE
            pop
         THEN
         1
      END
      M_PROP_PUP_REFLIST = WHEN
         ANYval @ Array? not IF
            { }list ANYval !
         THEN
         { }list STRval @ " " EXPLODE_ARRAY
         FOREACH
            swap pop STRval ! 0 BOLrem? !
            STRval @ dup "!" stringpfx IF
               1 strcut swap pop 1 BOLrem? !
            THEN
            dup IF puppet_match ELSE #-1 THEN dup Ok? IF
               { swap }list
               BOLrem? @ IF
                  ARRAY_diff
               ELSE
                  ARRAY_union
               THEN
            ELSE
               pop STRval @ swap ARRAY_appenditem
            THEN
         REPEAT
         dup ARRAY_count IF
            ", " ARRAY_join "^CFAIL^" swap strcat
            " are not proper dbrefs." strcat
            me @ swap ansi_notify
         ELSE
            pop
         THEN
         1
      END
      M_PROP_PLYR_PUP_REFLIST = WHEN
         ANYval @ Array? not IF
            { }list ANYval !
         THEN
         { }list STRval @ " " EXPLODE_ARRAY
         FOREACH
            swap pop STRval ! 0 BOLrem? !
            STRval @ dup "!" stringpfx IF
               1 strcut swap pop 1 BOLrem? !
            THEN
            dup IF dup pmatch dup Ok? not IF pop puppet_match ELSE swap
            pop THEN ELSE #-1 THEN dup Ok? IF
               { swap }list
               BOLrem? @ IF
                  ARRAY_diff
               ELSE
                  ARRAY_union
               THEN
            ELSE
               pop STRval @ swap ARRAY_appenditem
            THEN
         REPEAT
         dup ARRAY_count IF
            ", " ARRAY_join "^CFAIL^" swap strcat
            " are not proper dbrefs." strcat
            me @ swap ansi_notify
         ELSE
            pop
         THEN
         1
      END
      M_PROP_PROPLIST = WHEN
         0 TRY
            ANYval @ dup Array? not IF
               pop { }list
            THEN
            ArrayEDITOR 1
         CATCH
            me @ "^CFAIL^PROPLIST ERROR: " rot strcat
 
            ansi_notify ANYval @ 0
         ENDCATCH
      END
      M_PROP_PROPVALS = WHEN
         STRval @ ":" split swap "" "\[" subst "" "\r" subst strip
         dup "" "/" subst strip IF
            ANYval @ swap ARRAY_setitem 1
         ELSE
            pop pop me @ "^CFAIL^Invalid setting of a propval."
            ansi_notify ANYval @ 0
         THEN
      END
   ENDCASE
;
 
: CONV-ToStr[ ANYval -- str:STRval ]
   VAR CONVidx
   ANYval @ CASE
      Array? WHEN
         ""
         ANYval @
         FOREACH
            swap CONVidx ! dup Dbref? IF
               dup Ok? IF
                  me @ over controls IF
                     unparseobj
                  ELSE
                     name
                  THEN
               ELSE
                  dtos "(Nothing)(" swap strcat ")" strcat
               THEN
               over IF
                  ", " swap strcat
               THEN
               strcat
            ELSE
               dup String? IF
                  CONVidx @ String? IF
                     "^CYAN^" CONVidx @ 1 escape_ansi strcat
                     " ^YELLOW^= ^AQUA^" strcat 1 parse_ansi
 
                     swap strcat
                  THEN
                  "\r   " swap strcat strcat
               ELSE
                  pop
               THEN
            THEN
         REPEAT
      END
      DEFAULT
         ToStr
      END
   ENDCASE
;
 
: CONV-getprop[ ref:REFobj str:STRprop int:INTtype -- ANYval ]
   VAR ANYval
   INTtype @ CASE
      M_PROP_STRING = WHEN
         REFobj @ STRprop @ getpropstr
      END
      M_PROP_INTEGER = WHEN
         REFobj @ STRprop @ getpropval
      END
      M_PROP_FLOAT = WHEN
         REFobj @ STRprop @ getpropfval
      END
      M_PROP_LOCK = WHEN
         REFobj @ STRprop @ getprop dup Lock? not IF
            pop "" parselock
         THEN
      END
      dup M_PROP_DBREF = over M_PROP_PLYR_DBREF = or
      over M_PROP_PUP_DBREF = or swap M_PROP_PLYR_PUP_DBREF = or WHEN
         REFobj @ STRprop @ getprop dup IF
            dup String? IF
               stod
            ELSE
               dup Int? IF
                  dbref
               ELSE
                  dup Dbref? not IF
                     pop #-1
                  THEN
               THEN
            THEN
         ELSE
            pop #-1
         THEN
      END
      dup M_PROP_REFLIST = over M_PROP_PLYR_REFLIST = or
      over M_PROP_PUP_REFLIST = or
      swap M_PROP_PLYR_PUP_REFLIST = or WHEN
         REFobj @ STRprop @ ARRAY_get_reflist
      END
      M_PROP_PROPLIST = WHEN
         REFobj @ STRprop @ ARRAY_get_proplist
      END
      M_PROP_PROPVALS = WHEN
         REFobj @ STRprop @ ARRAY_get_propvals
      END
      DEFAULT
         ToSTR
      END
   ENDCASE
;
 
: CONV-setprop[ ref:REFobj str:STRprop str:STRval int:INTtype
                                         -- int:BOLsucc? ]
   0 VAR! INTcount
     VAR  BOLrem?
   INTtype @ CASE
      M_PROP_STRING = WHEN
         REFobj @ STRprop @ STRval @ setprop 1
      END
      M_PROP_INTEGER = WHEN
         STRval @ Number? IF
            REFobj @ STRprop @ STRval @ atoi setprop 1         ELSE
            me @ "^CFAIL^That is not a valid number." ansi_notify 0
         THEN
      END
      M_PROP_FLOAT = WHEN
         STRval @ strtof Error? not IF
            REFobj @ STRprop @ rot setprop 1
         ELSE
            pop me @ "^CFAIL^That is not a valid floating number."
            ansi_notify 0
         THEN
      END
      M_PROP_LOCK = WHEN
         STRval @ ParseLock dup IF
            REFobj @ STRprop @ rot setprop 1
         ELSE
            pop me @ "^CFAIL^That is not a valid lock." ansi_notify 0
         THEN
      END
      M_PROP_DBREF = WHEN
         STRval @ match dup Ok? IF
            REFobj @ STRprop @ rot setprop 1
         ELSE
            pop me @ "^CFAIL^That is not a valid dbref." ansi_notify 0
         THEN
      END
      M_PROP_PLYR_DBREF = WHEN
         STRval @ pmatch dup Ok? IF
            REFobj @ STRprop @ rot setprop 1
         ELSE
            pop me @ "^CFAIL^That is not a valid player dbref."
            ansi_notify 0
         THEN
      END
      M_PROP_PUP_DBREF = WHEN
         STRval @ puppet_match dup Ok? IF
            REFobj @ STRprop @ rot setprop 1
         ELSE
            pop me @ "^CFAIL^That is not a valid puppet dbref."
            ansi_notify 0
         THEN
      END
      M_PROP_PLYR_PUP_DBREF = WHEN
         STRval @ pmatch dup Ok? not IF
            pop STRval @ puppet_match
         THEN
         dup Ok? IF
            REFobj @ STRprop @ rot setprop 1
         ELSE
            pop me @
            "^CFAIL^That is not a valid player nor puppet dbref."
            ansi_notify 0
         THEN
      END
      M_PROP_REFLIST = WHEN
         REFobj @ STRprop @ getprop String? not IF
            REFobj @ STRprop @ remove_prop
         THEN
         { }list STRval @ " " EXPLODE_ARRAY
         FOREACH
            swap pop STRval ! 0 BOLrem? !
            STRval @ dup "!" stringpfx IF
               1 strcut swap pop 1 BOLrem? !
            THEN
            dup IF match ELSE #-1 THEN dup Ok? IF
               REFobj @ STRprop @ rot INTcount ++
               BOLrem? @ IF
                  REFLIST_del
               ELSE
                  REFLIST_add
               THEN
            ELSE
               pop STRval @ swap ARRAY_appenditem
            THEN
         REPEAT
         dup ARRAY_count IF
            ", " ARRAY_join "^CFAIL^" swap 1 escape_ansi strcat
            " are not proper dbrefs." strcat
            me @ swap ansi_notify INTcount @ not not
         ELSE
            pop 1
         THEN
      END
      M_PROP_PLYR_REFLIST = WHEN
         REFobj @ STRprop @ getprop String? not IF
            REFobj @ STRprop @ remove_prop
         THEN
         { }list STRval @ " " EXPLODE_ARRAY
         FOREACH
            swap pop STRval ! 0 BOLrem? !
            STRval @ dup "!" stringpfx IF
               1 strcut swap pop 1 BOLrem? !
            THEN
            dup IF pmatch ELSE #-1 THEN dup Ok? IF
               REFobj @ STRprop @ rot INTcount ++
               BOLrem? @ IF
                  REFLIST_del
               ELSE
                  REFLIST_add
               THEN
            ELSE
               pop STRval @ swap ARRAY_appenditem
            THEN
         REPEAT
         dup ARRAY_count IF
            ", " ARRAY_join "^CFAIL^" swap 1 escape_ansi strcat
            " are not proper dbrefs." strcat
            me @ swap ansi_notify INTcount @ not not
         ELSE
            pop 1
         THEN
      END
      M_PROP_PUP_REFLIST = WHEN
         REFobj @ STRprop @ getprop String? not IF
            REFobj @ STRprop @ remove_prop
         THEN
         { }list STRval @ " " EXPLODE_ARRAY
         FOREACH
            swap pop STRval ! 0 BOLrem? !
            STRval @ dup "!" stringpfx IF
               1 strcut swap pop 1 BOLrem? !
            THEN
            dup IF puppet_match ELSE #-1 THEN dup Ok? IF
               REFobj @ STRprop @ rot INTcount ++
               BOLrem? @ IF
                  REFLIST_del
               ELSE
                  REFLIST_add
               THEN
            ELSE
               pop STRval @ swap ARRAY_appenditem
            THEN
         REPEAT
         dup ARRAY_count IF
            ", " ARRAY_join "^CFAIL^" swap 1 escape_ansi strcat
            " are not proper dbrefs." strcat
            me @ swap ansi_notify INTcount @ not not
         ELSE
            pop 1
         THEN
      END
      M_PROP_PLYR_PUP_REFLIST = WHEN
         REFobj @ STRprop @ getprop String? not IF
            REFobj @ STRprop remove_prop
         THEN
         { }list STRval @ " " EXPLODE_ARRAY
         FOREACH
            swap pop STRval ! 0 BOLrem? !
            STRval @ dup "!" stringpfx IF
               1 strcut swap pop 1 BOLrem? !
            THEN
            dup IF dup pmatch dup Ok? not IF pop puppet_match ELSE
            swap pop THEN ELSE #-1 THEN dup Ok? IF
               REFobj @ STRprop @ rot INTcount ++
               BOLrem? @ IF
                  REFLIST_del
               ELSE
                  REFLIST_add
               THEN
            ELSE
               pop STRval @ swap ARRAY_appenditem
            THEN
         REPEAT
         dup ARRAY_count IF
            ", " ARRAY_join "^CFAIL^" swap 1 escape_ansi strcat
            " are not proper dbrefs." strcat
            me @ swap ansi_notify INTcount @ not not
         ELSE
            pop 1
         THEN
      END
      M_PROP_PROPLIST = WHEN
         0 TRY
            REFobj @ STRprop @ EDITORprop 1
         CATCH
            me @ "^CFAIL^PROPLIST ERROR: " rot strcat ansi_notify 0
         ENDCATCH
      END
      M_PROP_PROPVALS = WHEN
         STRval @ ":" split swap "" "\[" subst "" "\r" subst strip
         dup "" "/" subst strip IF
            BEGIN
               strip dup "/" rinstr over strlen = WHILE
               dup strlen -- strcut pop
            REPEAT
            "/" swap strcat STRprop @ swap strcat
            REFobj @ swap rot setprop 1
         ELSE
            pop pop me @ "^CFAIL^Invalid setting of a propval."
            ansi_notify 0
         THEN
      END
      DEFAULT
         pop me @ "^CFAIL^Invalid PropType setting." ansi_notify 0
      END
   ENDCASE
;
 
: CONV-remove_prop[ ref:REFobj str:STRprop int:INTtype -- ]
   INTtype @ M_PROP_PROPLIST = IF
      REFobj @ STRprop @ "#" strcat remove_prop
   ELSE
      INTtype @ M_PROP_PROPVALS = IF
         STRprop @
         BEGIN
            strip dup "/" rinstr over strlen = WHILE
            dup strlen -- strcut pop
         REPEAT
         REFobj @ swap remove_prop
      ELSE
         REFobj @ STRprop @ remove_prop
      THEN
   THEN
;
 
: MENU-check_option[ str:STRname dict:M_option -- dict:M_option' ]
   VAR M_count VAR temp1
  0 TRY
   M_option @ "FlagLvl" ARRAY_getitem dup temp1 ! String? IF
      me @ temp1 @ Flag? not IF
         { }dict EXIT
      THEN
   THEN
   prog PROP-Count over over getpropval ++ dup M_count ! setprop
   M_option @ "Caption" ARRAY_getitem dup not IF
      pop STRname @ dup M_option @ "Caption" ARRAY_setitem M_option !
   THEN
   M_option @ "ListNum" ARRAY_getitem IF
      prog PROP-Main remove_prop
      "The ListNum option is not settable for an M_option.  It "
      "is only settable in $Lib/Menu itself." strcat abort
   THEN
   M_count @ -- M_option @ "ListNum" ARRAY_setitem M_option !
   strlen dup 40 <= IF
      prog PROP-MaxLen over over getpropval 4 pick < IF
         rot setprop
      ELSE
         pop pop pop
      THEN
   ELSE
      pop
   THEN
   M_option @ "Title" ARRAY_getitem IF
      prog PROP-Main remove_prop
      "The ListNum option is not settable for an M_option.  It is "
      "only settable in $Lib/Menu itself." strcat abort
   THEN
   STRname @ M_option @ "Title" ARRAY_setitem M_option !
   M_option @ "Type" ARRAY_getitem M_TYPE_STRING = IF
      M_option @ EXIT
   THEN
   M_option @ "PreStr" ARRAY_getitem String? not IF
      "" M_option @ "PreStr" ARRAY_setitem M_option !
   THEN
   M_option @ "Choice" ARRAY_getitem dup not swap
   atoi M_count @ > or IF
      M_count @ intostr M_option @ "Choice" ARRAY_setitem M_option !
   THEN
   M_option @ "Choice" ARRAY_getitem strlen
   prog PROP-ChoiceLen over over getpropval 4 pick < IF
      rot setprop
   ELSE
      pop pop pop
   THEN
   M_option @ "Default" ARRAY_getitem not IF
      "^NORMAL^(Unset)" M_option @ "Default" ARRAY_setitem M_option !
   THEN
   M_option @ "Type" ARRAY_getitem not IF
      M_TYPE_LINE M_option @ "Type" ARRAY_setitem M_option !
   THEN
   M_option @ "Exit" ARRAY_getitem not IF
      M_BOL_FALSE M_option @ "Exit" ARRAY_setitem M_option !
   THEN
   M_option @ "Address" ARRAY_getitem Address? not IF
      0 M_option @ "Address" ARRAY_setitem M_option !
   THEN
 
   M_option @ "Justify" ARRAY_getitem not IF
      0 M_option @ "Justify" ARRAY_setitem M_option !
   THEN
   M_option @ "SepChar" ARRAY_getitem not IF
      ":" M_option @ "SepChar" ARRAY_setitem M_option !
   THEN
   M_option @ "PropType" ARRAY_getitem dup not IF
      pop M_PROP_STRING
   THEN
   dup 1 < over M_PROP_MAX > or IF
      pop prog PROP-main remove_prop
      "The PropType setting should be set to a valid option "
      "in M_option." strcat abort
   THEN
   M_option @ "PropType" ARRAY_setitem M_option !
   M_option @ "Object" ARRAY_getitem Dbref? IF
      M_option @ "Object" ARRAY_getitem Ok? not IF
         prog PROP-Main remove_prop
         "The object setting for the M_option is not valid." abort
      THEN
      M_option @ "Property" ARRAY_getitem dup String? not IF
         pop prog PROP-main remove_prop
         "The property setting needs to be set for an "
         "object-type option in M_option." strcat abort
      THEN
      dup "\r" instr over ":" instr or over "\[" instr or
      swap "" "/" subst strip not or IF
         pop prog PROP-main remove_prop
         "The property setting is invalid for the M_option." abort
      THEN
   THEN
   M_option @ "Type" ARRAY_getitem CASE
      M_TYPE_LINE = WHEN
         M_option @ "Ask" ARRAY_getitem not IF
            "Enter your response below [. = Keep as-was, or space "
            "= clear/default]:" strcat
             M_option @ "Ask" ARRAY_setitem M_option !
         THEN
      END
      M_TYPE_SMATCH_LINE = WHEN
         M_option @ "Ask" ARRAY_getitem not IF
            "Enter your response below [. = Keep as-was, or space "
            "= clear/default]:" strcat
            M_option @ "Ask" ARRAY_setitem M_option !
         THEN
         M_option @ "Smatch" ARRAY_getitem not IF
            prog PROP-Main remove_prop
            "You need the Smatch option set to something to smatch "
            "to for a M_TYPE_SMATCH_LINE menu option." strcat abort
         THEN
         M_option @ "PropType" ARRAY_getitem M_PROP_PROPLIST = IF
            prog PROP-Main remove_prop
            "The Smatch option does not allow for proplist types."
            abort
         THEN
      END
      M_TYPE_TOGGLABLE = WHEN
         M_option @ "Toggle" ARRAY_getitem not IF
            prog PROP-Main remove_prop
            "You need the Toggle option set to something togglable "
            "for a M_TYPE_TOGGLABLE menu option." strcat abort
         THEN
      END
      DEFAULT
         pop
      END
   ENDCASE
   M_option @
  CATCH
     prog PROP-main remove_prop
     abort
  ENDCATCH
;
PUBLIC MENU-check_option
 
: MENU-init[ dict:M_menu -- dict:DICTdisplay dict:DICTreturn dict:DICToption dict:DICTrun arr:ARRchoices arr:ARRchoices_sort ]
   VAR DICTdisplay VAR DICTrun         VAR DICTreturn VAR DICToption
   VAR ARRchoices  VAR ARRchoices_sort
   VAR STRtitle    VAR STRchoice
   {
   }dict DICTdisplay !
   {
   }dict DICTrun !
   {
   }dict DICTreturn !
   {
   }list ARRchoices !
   {
   }list ARRchoices_sort !
   M_menu @
   FOREACH
      dup ARRAY_count not IF
         pop pop CONTINUE
      THEN
      DICToption ! STRtitle !
      DICToption @ "Type" ARRAY_getitem M_TYPE_STRING = IF
         DICToption @ "Message" ARRAY_getitem dup IF
            { "" rot }list
         ELSE
            pop DICToption @ "Caption" ARRAY_getitem
            { swap "" }list
         THEN
         DICToption @ "ListNum" ARRAY_getitem
         DICTdisplay @ swap ARRAY_setitem DICTdisplay !
         CONTINUE
      THEN
      DICToption @ "Choice" ARRAY_getitem
      dup ARRchoices @ ARRAY_appenditem ARRchoices !
      dup dup Number? IF
         atoi
      THEN
      ARRchoices_sort @ ARRAY_appenditem ARRchoices_sort !
      DICToption @ DICTrun @ 3 pick ARRAY_setitem DICTrun !
      DICToption @ "Type" ARRAY_getitem M_TYPE_NODISPLAY = IF
         pop CONTINUE
      THEN
      prog PROP-ChoiceLen getpropval neon_right "^PURPLE^) ^CYAN^"
      strcat ( over strcat )
      DICToption @ "PreStr" ARRAY_getitem swap strcat "^YELLOW^"
      swap strcat
      DICToption @ "Caption" ARRAY_getitem
      DICToption @ "Type" ARRAY_getitem M_TYPE_NULL = IF
         strcat DICToption @ "ListNum" ARRAY_getitem
         { rot "" }list swap DICTdisplay @ swap
         ARRAY_setitem DICTdisplay !
         CONTINUE
      THEN
      "^AQUA^" strcat
      DICToption @ "SepChar" ARRAY_getitem strcat
      DICToption @ "Justify" ARRAY_getitem dup IF
         dup 1 = IF
            pop prog PROP-MaxLen getpropval
         THEN
         dup 0 < IF
            -1 * neon_right
         ELSE
            neon_left
         THEN
      ELSE
         pop
      THEN
      strcat
      DICToption @ "Default" ARRAY_getitem
      DICToption @ "Object" ARRAY_getitem dup Dbref? IF
         DICToption @ "Type" ARRAY_getitem M_TYPE_TOGGLABLE = IF
            DICToption @ "Property" ARRAY_getitem
            getprop dup IF
               ToSTR
            ELSE
               pop dup
            THEN
            dup "{%d|%t}"
            DICToption @ "Toggle" ARRAY_getitem "%t" subst
            4 pick "%d" subst smatch not IF
               pop
            ELSE
               swap pop 1 escape_ansi
            THEN
            TOupper
         ELSE
            DICToption @ "Property" ARRAY_getitem
            DICToption @ "Type" ARRAY_getitem dup M_TYPE_LINE =
            swap M_TYPE_SMATCH_LINE = or IF
               DICToption @ "PropType" ARRAY_getitem CONV-getprop
               DICToption @ "Convert" ARRAY_getitem dup Address? IF
                  EXECUTE
               ELSE
                  pop CONV-ToStr
               THEN
            ELSE
               getprop ToSTR
            THEN
            dup IF
               swap pop 1 escape_ansi
            ELSE
               pop
            THEN
         THEN
      ELSE
         pop
         0 DICTreturn @ STRtitle @ ARRAY_setitem DICTreturn !
      THEN
      swap { }list ARRAY_appenditem ARRAY_appenditem
      DICToption @ "ListNum" ARRAY_getitem
      DICTdisplay @ swap ARRAY_setitem DICTdisplay !
   REPEAT
   DICTdisplay @ DICTreturn @ DICToption @ DICTrun @
   ARRchoices @ ARRchoices_sort @
;
 
: MENU-run[ arr:ARRheader arr:ARRfooter dict:M_menu
                -- dict:DICTreturn str:STRexit_cmd ]
   VAR DICTdisplay VAR DICTrun         VAR DICTreturn VAR DICToption
   VAR ARRchoices  VAR ARRchoices_sort
   VAR STRtitle    VAR STRchoice
   VAR temp1       VAR temp2
  0 TRY
   M_menu @ MENU-init ARRchoices_sort ! ARRchoices ! DICTrun ! DICToption ! DICTreturn ! DICTdisplay !
   ARRheader @ ARRAY_count not IF
      {
         "^CYAN^Menu Options"
         "^PURPLE^~~~~~~~~~~~~~"
      }list ARRheader !
   THEN
   ARRfooter @ ARRAY_count not IF
      {
         " "
         ARRchoices_sort @ SORTTYPE_NOCASE_ASCEND ARRAY_sort "," ARRAY_join 1 escape_ansi
         "^YELLOW^,^BROWN^" "," subst
         "^YELLOW^Enter your choice below [^BROWN^%s^YELLOW^]:" swap
         "%s" subst
      }list ARRfooter !
   THEN
   BEGIN
      ARRheader @
      { me @ }list ARRAY_ansi_notify
      DICTdisplay @
      FOREACH
         swap pop
         ARRAY_vals pop 
         dup Array? IF
            { me @ }list ARRAY_ansi_notify pop
         ELSE
            strcat me @ swap ansi_notify
         THEN
      REPEAT
      ARRfooter @ { me @ }list ARRAY_ansi_notify 0
      BEGIN
         pop READ strip ARRchoices @ over dup STRchoice ! ARRAY_findval not WHILE
         me @ "^CFAIL^Invalid choice." ansi_notify
         ARRfooter @ { me @ }list ARRAY_ansi_notify
      REPEAT
      { DICTrun @ ARRAY_keys }list over ARRAY_findval not IF
         pop me @ "^CFAIL^ERROR: ^BROWN^Could not find option."
         ansi_notify CONTINUE
      THEN
      DICTrun @ swap ARRAY_getitem DICToption !
      DICToption @ "Message" ARRAY_getitem dup Array? IF
         { me @ }list ARRAY_ansi_notify
      ELSE
         pop
      THEN
      DICToption @ "Type" ARRAY_getitem
      (t) CASE
         M_TYPE_LINE = WHEN
            DICToption @ "Ask" ARRAY_getitem
            DICToption @ "PropType" ARRAY_getitem M_PROP_PROPLIST = IF
               DICToption @ "Object" ARRAY_getitem dup Dbref? IF
                  DICToption @ "Property" ARRAY_getitem
                  over over EDITORprop
                  ARRAY_get_proplist
                  DICToption @ "Convert" ARRAY_getitem dup Address? IF
                     EXECUTE
                  ELSE
                     pop CONV-ToSTR
                  THEN
                  1 escape_ansi dup not IF
                     pop DICToption @ "Default" ARRAY_getitem CONV-ToSTR
                  THEN
                  temp1 !
               ELSE
                  pop DICToption @ "Title" ARRAY_getitem
                  DICTreturn @ over ARRAY_getitem dup Array? not IF
                     pop { }list
                  THEN
                  ArrayEDITOR "abort" stringcmp not IF
                     pop DICTreturn @ 3 pick ARRAY_getitem
                     dup Array? not IF
                        pop DICToption @ "Default" ARRAY_getitem
                        dup Array? not IF
                           dup String? not IF
                              pop "^NORMAL^(Unset)"
                           THEN
                        ELSE
                           CONV-ToSTR
                        THEN
                     ELSE
                        DICToption @ "Convert" ARRAY_getitem dup Address? IF
                           EXECUTE
                        ELSE
                           pop CONV-ToSTR 1 escape_ansi
                        THEN
                     THEN
                  ELSE
                     dup
                     DICToption @ "Convert" ARRAY_getitem dup Address? IF
                        EXECUTE
                     ELSE
                        pop CONV-ToSTR
                     THEN
                     1 escape_ansi
                     swap DICTreturn @ 4 pick ARRAY_setitem DICTreturn !
                  THEN
                  dup not IF
                     pop DICToption @ "Default" ARRAY_getitem CONV-ToSTR
                  THEN
                  temp1 ! pop
               THEN
               DICToption @ "ListNum" ARRAY_getitem
               DICTdisplay @ over ARRAY_getitem
               ARRAY_vals pop pop temp1 @ 2 ARRAY_make
               DICTdisplay @ rot ARRAY_setitem DICTdisplay !
            ELSE
               me @ swap ansi_notify
               READ
               dup strip IF
                  dup "." strcmp not IF
                     pop me @ "^CINFO^Left as is." ansi_notify
                  ELSE
                     1 temp2 !
                     DICToption @ "Object" ARRAY_getitem dup Dbref? IF
                        DICToption @ "Property" ARRAY_getitem
                        over over 5 rotate
                        DICToption @ "PropType" ARRAY_getitem
                        CONV-setprop temp2 !
                        DICToption @ "PropType" ARRAY_getitem CONV-getprop
                        DICToption @ "Convert" ARRAY_getitem dup Address? IF
                           EXECUTE
                        ELSE
                           pop CONV-ToStr
                        THEN
                        1 escape_ansi dup not IF
                           pop DICToption @ "Default" ARRAY_getitem CONV-ToStr
                        THEN
                        temp1 !
                     ELSE
                        pop DICTreturn @ DICToption @ "Title"
                        ARRAY_getitem ARRAY_getitem
                        swap over DICToption @ "PropType"
                        ARRAY_getitem CONV-combine temp2 ! dup
 
                        DICToption @ "Convert" ARRAY_getitem dup Address? IF
                           EXECUTE
                        ELSE
                           pop CONV-ToStr 
                        THEN
                        1 escape_ansi dup not IF
                           pop pop 0 DICToption @ "Default" ARRAY_getitem CONV-ToStr
                        THEN
                        temp1 !
                        DICTreturn @ rot ARRAY_setitem DICTreturn !
                     THEN
                     temp2 @ IF
                        me @ "^CSUCC^Set." ansi_notify
                        DICToption @ "ListNum" ARRAY_getitem
                        DICTdisplay @ over ARRAY_getitem
                        ARRAY_vals pop pop temp1 @ 2 ARRAY_make
                        DICTdisplay @ rot ARRAY_setitem DICTdisplay !
                     THEN
                  THEN
               ELSE
                  pop DICToption @ "Object" ARRAY_getitem dup Dbref? IF
                     DICToption @ "Property" ARRAY_getitem
                     DICToption @ "PropType" ARRAY_getitem
                     CONV-remove_prop
                  ELSE
                     0 DICTreturn @ DICToption @ "Title" ARRAY_getitem
                     ARRAY_setitem DICTreturn !
                  THEN
                  me @ "^CSUCC^Cleared." ansi_notify
                  DICToption @ "Default" ARRAY_getitem CONV-ToSTR temp1 !
                  DICToption @ "ListNum" ARRAY_getitem
                  DICTdisplay @ over ARRAY_getitem
                  ARRAY_vals pop pop temp1 @ 2 ARRAY_make
                  DICTdisplay @ rot ARRAY_setitem DICTdisplay !
               THEN
            THEN
         END
         M_TYPE_SMATCH_LINE = WHEN
            DICToption @ "Ask" ARRAY_getitem
            me @ swap ansi_notify
            READ
            dup strip IF
               dup "." strcmp not IF
                  pop me @ "^CINFO^Left as is." ansi_notify
               ELSE
                  dup DICToption @ "Smatch" ARRAY_getitem smatch IF
                     1 temp2 !
                     DICToption @ "Object" ARRAY_getitem dup Dbref? IF
                        DICToption @ "Property" ARRAY_getitem
                        over over 5 rotate
                        DICToption @ "PropType" ARRAY_getitem
                        CONV-setprop temp2 !
                        DICToption @ "PropType" ARRAY_getitem CONV-getprop
                        DICToption @ "Convert" ARRAY_getitem dup Address? IF
                           EXECUTE
                        ELSE
                           pop CONV-ToStr 
                        THEN
                        1 escape_ansi dup not IF
                           pop DICToption @ "Default" ARRAY_getitem CONV-ToStr
                        THEN
                        temp1 !
                     ELSE
                        pop DICTreturn @ DICToption @ "Title"
                        ARRAY_getitem ARRAY_getitem
                        swap over DICToption @ "PropType" ARRAY_getitem
                        CONV-combine temp2 ! dup
                        DICToption @ "Convert" ARRAY_getitem dup Address? IF
                           EXECUTE
                        ELSE
                           pop CONV-ToStr 
                        THEN
                        1 escape_ansi dup not IF
                           pop DICToption @ "Default" ARRAY_getitem CONV-ToStr
                        THEN
                        temp1 !
                        DICTreturn @ rot ARRAY_setitem DICTreturn !
                     THEN
                     temp2 @ IF
                        me @ "^CSUCC^Set." ansi_notify
                        DICToption @ "ListNum" ARRAY_getitem
                        DICTdisplay @ over ARRAY_getitem
                        ARRAY_vals pop pop temp1 @ 2 ARRAY_make
                        DICTdisplay @ rot ARRAY_setitem DICTdisplay !
                     THEN
                  ELSE
                     pop me @ "^CFAIL^Invalid setting." ansi_notify
                  THEN
               THEN
            ELSE
               pop DICToption @ "Object" ARRAY_getitem dup Dbref? IF
                  DICToption @ "Property" ARRAY_getitem
                  DICToption @ "PropType" ARRAY_getitem
                  CONV-remove_prop
               ELSE
                  pop 0 DICTreturn @ DICToption @ "Title" ARRAY_getitem
                  ARRAY_setitem DICTreturn !
               THEN
               me @ "^CSUCC^Cleared." ansi_notify
               DICToption @ "Default" ARRAY_getitem CONV-ToSTR temp1 !
               DICToption @ "ListNum" ARRAY_getitem
               DICTdisplay @ over ARRAY_getitem
               ARRAY_vals pop pop temp1 @ 2 ARRAY_make DICTdisplay @
               rot ARRAY_setitem DICTdisplay !
            THEN
         END
         M_TYPE_TOGGLABLE = WHEN
            DICToption @ "Object" ARRAY_getitem dup Dbref? IF
               DICToption @ "Property" ARRAY_getitem over over
               getprop ToSTR
               DICToption @ "Toggle" ARRAY_getitem ToSTR stringcmp
               not IF
                  remove_prop
                  DICToption @ "default" ARRAY_getitem CONV-ToSTR
                  toupper temp1 !
               ELSE
                  DICToption @ "Toggle" ARRAY_getitem dup CONV-ToSTR
                  toupper 1 escape_ansi temp1 ! setprop
               THEN
            ELSE
               DICToption @ "Title" ARRAY_getitem
               DICTreturn @ over ARRAY_getitem CONV-ToSTR
               DICToption @ "Toggle" ARRAY_getitem CONV-ToSTR
               ToSTR stringcmp not IF
                  0 DICTreturn @ rot ARRAY_setitem
                  DICToption @ "default" ARRAY_getitem
                  ToSTR toupper temp1 !
               ELSE
                  DICToption @ "Toggle" ARRAY_getitem DICTreturn @ rot
                  dup CONV-ToSTR toupper 1 escape_ansi temp1 ! ARRAY_setitem
               THEN
            THEN
            me @ "^CSUCC^Toggled." ansi_notify
            DICToption @ "ListNum" ARRAY_getitem
            DICTdisplay @ over ARRAY_getitem
            ARRAY_vals pop pop temp1 @ 2 ARRAY_make
            DICTdisplay @ rot ARRAY_setitem DICTdisplay !
         END
         M_TYPE_NULL = WHEN
         END
         M_TYPE_NODISPLAY = WHEN
         END
         DEFAULT
            pop me @ "^CFAIL^ERROR: ^BROWN^Not a valid option type."
            ansi_notify
         END
      ENDCASE
      DICToption @ "Address" ARRAY_getitem dup Address? IF
         temp1 !
         DICToption @ "Object" ARRAY_getitem dup Dbref? IF
            DICToption @ "Property" ARRAY_getitem
         ELSE
            pop #-1 ""
         THEN
         DICTreturn @
         { 4 rotate 4 rotate 4 rotate DICToption @ DICTdisplay @ rot
         5 TRY
            temp1 @ "" temp1 ! EXECUTE rot rot temp1 ! DICTreturn ! swap DICTdisplay !
            IF
               M_menu @ MENU-init ARRchoices_sort ! ARRchoices ! DICTrun ! pop pop DICTdisplay !
            THEN
         CATCH
             } popn prog PROP-main remove_prop abort
         ENDCATCH
         } popn
         temp1 @ DICToption @ "Type" ARRAY_getitem
         dup M_TYPE_NODISPLAY = over M_TYPE_NULL = or
         swap M_TYPE_STRING = or not and IF
            DICToption @ "ListNum" ARRAY_getitem
            DICTdisplay @ over ARRAY_getitem
            ARRAY_vals pop pop temp1 @ 2 ARRAY_make DICTdisplay @
            rot ARRAY_setitem DICTdisplay !
         THEN
      ELSE
         pop
      THEN
      DICToption @ "Exit" ARRAY_getitem M_BOL_TRUE = IF
          BREAK
      THEN
   REPEAT
    prog PROP-main remove_prop
   DICTreturn @ STRchoice @
  CATCH
     prog PROP-main remove_prop
     abort
  ENDCATCH
;
PUBLIC MENU-run
 
$pubdef }M_option }dict over swap "$Lib/Menu" match "MENU-check_option" CALL
$pubdef }M_run    }dict "$Lib/Menu" match "MENU-run" CALL
