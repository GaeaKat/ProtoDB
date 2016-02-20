(*
   CMD-@floaters.MUF v3.0
   by Moose
   * Based on Ruffin and Akari's work
 
   - Recoded using proto code to speed up and add ANSI.
 *)
 
$author Moose
$version 3.0
 
$include $lib/strings
 
$def FLOAT_ALL      0
$def FLOAT_NODESCS  1
$def FLOAT_NOLINKS  2
$def FLOAT_CHART    3
 
$def PARENT_DEFAULT 0
$def PARENT_ALL     1
$def PARENT_WIZALL  2
 
$def atell me @ swap ansi_notify
 
: NEXT_LINK_ENTRANCE[ ref:ref ref:REFstart -- ref:ref ]
   ref @ REFstart @ NEXTENTRANCE dup ok? IF
      dup Exit? NOT IF
         ref @ swap NEXT_LINK_ENTRANCE
      THEN
   THEN
;
 
: PARSE-all[ ref:ref -- int:INTreturn_type int:INTshow? ]
   0
   ref @ #-1 NEXT_LINK_ENTRANCE ok? not IF
      ref @ contents ok? not IF
         ref @ desc strip ref @ ansidesc strip ref @ htmldesc strip or or not
      ELSE
         0
      THEN
   ELSE
      0
   THEN
;
 
: PARSE-nodescs[ ref:ref -- int:INTreturn_type int:INTshow? ]
   0
   ref @ contents ok? not IF
      ref @ desc strip ref @ ansidesc strip ref @ htmldesc strip or or not
   ELSE
      0
   THEN
;
 
: PARSE-nolinks[ ref:ref -- int:INTreturn_type int:INTshow? ]
   0
   ref @ #-1 NEXT_LINK_ENTRANCE ok? not
;
 
: PARSE-chart[ ref:ref -- int:INTreturn_type int:INTshow? ]
   1
   ref @ contents ok? not IF
      ref @ desc strip ref @ ansidesc strip ref @ htmldesc strip or or not dup IF
         EXIT
      ELSE
         pop
      THEN
   THEN
   pop 2
   ref @ #-1 NEXT_LINK_ENTRANCE ok? not
;
 
: FLOAT-search[ ref:REFowner int:INTtype -- ]
   0 VAR! INTcount
     VAR  ADDRparse
     VAR  STRsubst
     VAR  ref
   INTtype @ CASE
      FLOAT_ALL = WHEN
         'PARSE-all ADDRparse !
         "^CINFO^Rooms without descriptions, contents, nor links to it:" atell
         "has no ^WHITE^description^NORMAL^, ^WHITE^contents^NORMAL^, nor ^WHITE^entrances^NORMAL^" STRsubst !
      END
      FLOAT_NODESCS = WHEN
         'PARSE-nodescs ADDRparse !
         "^CINFO^Rooms without descriptions nor contents:" atell
         "has no ^WHITE^description ^NORMAL^nor ^WHITE^contents^NORMAL^" STRsubst !
      END
      FLOAT_NOLINKS = WHEN
         'PARSE-nolinks ADDRparse !
         "^CINFO^Rooms without any links to it:" atell
         "has no ^WHITE^entrances^NORMAL^" STRsubst !
      END
      FLOAT_CHART = WHEN
         'PARSE-chart ADDRparse !
         "|--------|-------------------------------------------|----------------|---|---|" atell
         "|^WHITE^DBREF ##^NORMAL^|^WHITE^NAME                                       ^NORMAL^|^WHITE^OWNER           ^NORMAL^|^WHITE^NL?^NORMAL^|^WHITE^ND?^NORMAL^|" atell
         "|--------|-------------------------------------------|----------------|---|---|" atell
      END
   ENDCASE
   #-1 REFowner @ "" "R" FIND_ARRAY
   FOREACH
      swap pop
      dup ref ! ADDRparse @ EXECUTE IF
         dup IF
            "|^YELLOW^" ref @ dtos 8 STRright strcat "^NORMAL^|^CYAN^" strcat
            ref @ name 43 STRleft dup strlen 43 > IF 43 strcut pop THEN 1 escape_ansi strcat "|^GREEN^" strcat
            ref @ owner name 16 STRleft dup strlen 16 > IF 16 strcut pop THEN 1 escape_ansi strcat
            swap -- IF
               "^NORMAL^|^WHITE^Yes^NORMAL^|No |"
            ELSE
               "^NORMAL^|No |^WHITE^Yes^NORMAL^|"
            THEN
            strcat
         ELSE
            pop
            ref @ unparseobj 1 escape_ansi "(#" rsplit "^YELLOW^(#" swap strcat strcat
            "^CYAN^" swap strcat " ^NORMAL^%d and is owned by " STRsubst @ "%d" subst strcat
            ref @ owner unparseobj 1 escape_ansi "(#" rsplit "^YELLOW^(#" swap strcat strcat
            "^GREEN^" swap strcat strcat "^NORMAL^." strcat
         THEN
         atell INTcount ++
      ELSE
         pop
      THEN
   REPEAT
   INTtype @ FLOAT_CHART = IF
      "|--------|-------------------------------------------|----------------|---|---|" atell
   ELSE
      "^CINFO^Done." atell
   THEN
;
 
: PARENTS-list[ ref:ref int:INTafter? -- ]
   0 VAR! INTcount
   INTafter? @ not IF
      "^CYAN^" ref @ unparseobj 1 escape_ansi
      "(#" rsplit "^YELLOW^(#" swap strcat strcat
      " ^NORMAL^owned by ^GREEN^" strcat strcat
      ref @ owner
      me @ over controls IF
         unparseobj 1 escape_ansi "(#" rsplit
         "^YELLOW^(#" swap strcat strcat
      ELSE
         name
      THEN
      strcat atell
   THEN
   ref @ CONTENTS_ARRAY SORTTYPE_NOCASE_ASCEND ARRAY_SORT
   FOREACH
      swap pop
      dup Room? IF
         INTcount @ 0 = IF
            INTafter? @ IF
               "^CYAN^" ref @ unparseobj 1 escape_ansi
               "(#" rsplit "^YELLOW^(#" swap strcat strcat
               " ^NORMAL^owned by ^GREEN^" strcat strcat
               ref @ owner
               me @ over controls IF
                  unparseobj 1 escape_ansi "(#" rsplit
                  "^YELLOW^(#" swap strcat strcat
               ELSE
                  name
               THEN
               strcat atell
            THEN
         THEN
         INTcount ++
         "   ^CYAN^" over unparseobj 1 escape_ansi
         "(#" rsplit "^YELLOW^(#" swap strcat strcat
         " ^NORMAL^owned by ^GREEN^" strcat strcat swap owner
         me @ over controls IF
            unparseobj 1 escape_ansi "(#" rsplit
            "^YELLOW^(#" swap strcat strcat
         ELSE
            name
         THEN
         strcat atell
      ELSE
         pop
      THEN
   REPEAT
   INTafter? @ not INTcount @ or IF
      "^YELLOW^" INTcount @ intostr strcat " ^NORMAL^room(s) listed." strcat atell
   THEN
;
 
: PARENTS-cmd[ ref:ref int:INTtype -- ]
   "^CINFO^Searching:" atell
   INTtype @ PARENT_DEFAULT = IF
      ref @ 0 PARENTS-list
   ELSE
      INTtype @ PARENT_WIZALL = IF
         #-1
      ELSE (*PARENT_ALL*)
         me @
      THEN
      "" "R" FIND_ARRAY SORTTYPE_NOCASE_ASCEND ARRAY_SORT
      FOREACH
         swap pop
         1 PARENTS-list
      REPEAT
   THEN
   "^CINFO^Done." atell
;
 
: FLOAT-help ( -- )
   {
      "^GREEN^@Floaters v3.0 - by Moose [Based on Akari's and Ruffin's work]"
      "^PURPLE^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      " ^WHITE^@Float #checkall ^NORMAL^- Prints out a list of your rooms      "
      "                    missing a description, contents,  "
      "                    and any links to it. That means   "
      "                    that if a room has any of the     "
      "                    above, it will not be listed.     "
      " ^WHITE^@Float #nodescs  ^NORMAL^- Prints a list of of all your rooms   "
      "                    that don't have a description and "
      "                    also don't have any contents.     "
      " ^WHITE^@Float #nolinks  ^NORMAL^- Prints a list of all rooms that have "
      "                    have no links to them.            "
      " ^WHITE^@Float #chart    ^NORMAL^- List #nodesc and #nolinks together in"
      "                    a chart form.                     "
      me @ "WIZARD" Flag? IF
         " ^WHITE^@Floaters        ^NORMAL^- Works like @float but lists all rooms"
         "                    and also uses #checkall, #nodescs,"
         "                    #nolinks too                      "
      THEN
      " ^WHITE^Parents          ^NORMAL^- Prints out the list for all of the   "
      "                    rooms under the one you are in.   "
      " ^WHITE^Parents <dbref>  ^NORMAL^- Prints out the list for all of the   "
      "                    rooms under a room dbref given.   "
      " ^WHITE^Parents #all     ^NORMAL^- Will last all of your parent rooms   "
      "                    and the rooms within them.        "
      me @ "WIZARD" Flag? IF
         " ^WHITE^Parents #wiz     ^NORMAL^- Will list all parent rooms and the   "
         "                    rooms within them.                "
      THEN
      "^CINFO^Done."
   }list
   { me @ }list ARRAY_ansi_notify
;
 
: main ( str:Args -- )
   VAR ref
   strip dup "#help" stringcmp not IF
      pop FLOAT-help EXIT
   THEN
   command @ "Queued Event." stringcmp not IF
      me @ FLOAT_ALL FLOAT-search EXIT
   THEN
   command @ "P" instring 1 = IF
      dup not IF
         pop "here"
      THEN
      (args) CASE
         "#all" stringcmp NOT WHEN
           #-1 PARENT_ALL
         END
        me @ "WIZARD" Flag? IF
         "#wiz" stringcmp NOT WHEN
           #-1 PARENT_WIZALL
         END
        THEN
         DEFAULT
            match
            dup #-2 dbcmp IF
               pop me @ "^CINFO^I don't know which one you mean!" ansi_notify EXIT
            THEN
            dup Ok? not IF
               pop me @ "^CINFO^I cannot find that!" ansi_notify EXIT
            THEN
            me @ over controls not IF
               pop me @ "^CFAIL^" "noperm_mesg" sysparm 1 escape_ansi strcat ansi_notify EXIT
            THEN
            dup Room? not IF
               pop me @ "^CFAIL^Not a room!" ansi_notify EXIT
            THEN
            PARENT_DEFAULT
         END
      ENDCASE
      PARENTS-cmd EXIT
   THEN
   dup not IF
      pop FLOAT-help EXIT
   THEN
   me @ "WIZARD" Flag? IF
      command @ "@floaters" stringcmp not IF
         #-1  ref !
      ELSE
         me @ ref !
      THEN
   ELSE
      me @ ref !
   THEN
   (args) CASE
      "#checkall" stringcmp NOT WHEN
         ref @ FLOAT_ALL     FLOAT-search
      END
      "#nodescs" stringcmp NOT WHEN
         ref @ FLOAT_NODESCS FLOAT-search
      END
      "#nolinks" stringcmp NOT WHEN
         ref @ FLOAT_NOLINKS FLOAT-search
      END
      "#chart" stringcmp NOT WHEN
         ref @ FLOAT_CHART   FLOAT-search
      END
      DEFAULT pop
         FLOAT-help
      END
   ENDCASE
;
