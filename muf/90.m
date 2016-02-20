(*
   Cmd-@IdxEdit v1.2
   Edits index files.
   v1.2 by Moose
    - Added @fileedit
   v1.1 by Akari 09/05/2001
    - Cleaned up the code to 80 colums, added new directives and notes.
 
   Install - Requires W4 permissions to make calls to $lib/file
           - $lib/file
           - $lib/editor 2.0 or newer
   Use:
       @FileEdit can be used to edit entire files such as welcome.txt
       @IdxEdit can be used to edit index style text files, such as man.txt,
       help.txt, mpihelp.txt, etc.
       @idxedit <fileName> will load the top entry of the index file into the
           editor.
 
   In the editor itself:
       .idx = <new index keyword(s)> This will add the contents of the editor
                 to a new index as long as the index does not already exist.
       .idx - This will set the contents of the editor to the top entry of
                 the index file.
       .oldidx - This will set the index back to what it was when originally
                 loaded into the editor.
 *)
 
$author  Moose
$version 1.2
 
$include $Lib/Editor
$include $Lib/File
 
$def atell me @ swap ansi_notify
 
VAR DICTfile
 
: EDIT_INDEX[ arr:ARRlist OUTidx -- arr:ARRlist' OUTidx int:BOLsave? ]
(***
   .idx =<new index>  This will try to set it to a new index value.
                      If the index already exists it will give an error.
   .idx               This will set the index to the main index value.
   .oldidx            This will set the index back to what it was originaly.
 ***)
   1                              VAR! INTpos
   { "oldidx" "idx" "lhelp" }list VAR! ARRmask
   ".i $"                         VAR! STRcmd
   OUTidx                         VAR! IDXorig
                                  VAR  ARRargs
                                  VAR  STRexitcmd
   EDITORheader
   BEGIN
      ARRlist @ ARRmask @ INTpos @ STRcmd @ 0 ArrayEDITORloop STRexitcmd !
      ARRargs ! INTpos ! ARRmask ! ARRlist !
      STRexitcmd @ "end" STRingcmp not if
         "^CYAN^< ^CSUCC^Finished editing.  Attempting to save the changes. ^CYAN^>"
         atell
         ARRlist @ OUTidx @ 1 EXIT
      then
      STRexitcmd @ "abort" STRingcmp not if
         "^CYAN^< ^CFAIL^Aborting the editor.  Not saving the changes. ^CYAN^>"
         atell
         ARRlist @ OUTidx @ 0 EXIT
      then
      STRexitcmd @ "lhelp" STRingcmp not if
         me @ "^YELLOW^--^WHITE^LOCAL HELP^YELLOW^---------------------------------------------------------------"  ANSI_notify
         me @ " ^WHITE^.idx =<index name>        ^NORMAL^Set a new index value. Blank for the main index."          ANSI_notify
         me @ " ^WHITE^.oldidx                   ^NORMAL^Restore the original index name."                          ANSI_notify
         me @ "^CYAN^CURRENT INDEX: ^AQUA^" OUTidx @ dup Int? if pop "^BLUE^[MAIN]" else 1 escape_ansi then strcat  ANSI_notify
         me @ "   ^CYAN^OLDX INDEX: ^AQUA^" IDXorig @ dup Int? if pop "^BLUE^[MAIN]" else 1 escape_ansi then strcat ANSI_notify
         me @ "^CINFO^Done." ANSI_notify
         CONTINUE
      then
      STRexitcmd @ "idx" STRingcmp not if
         ARRargs @ 2 array_getitem dup String? not if pop "" then
         strip dup not if
         else
            dup dup String? not if pop "" then
            OUTidx @ dup String? not if pop "" then
            stringcmp not if pop
               me @ "^CYAN^< ^CFAIL^The index name is the same as previously. ^CYAN^>" ANSI_notify
            else
               DICTfile @ over ARRAY_getitem Array? over dup String? not
               if pop "" then
               IDXorig @ dup String? not
               if pop "" then
               stringcmp not not and if
                  pop
                  "^CYAN^< ^CFAIL^That inex name already exists. ^CYAN^>" atell
               else
                  dup not if pop 1 then OUTidx !
                  me @ "^CYAN^< ^CSUCC^New index name set. ^CYAN^>" ANSI_notify
               then
            then
         then
         CONTINUE
      then
      STRexitcmd @ "oldidx" STRingcmp not if
         IDXorig @ OUTidx !
         me @ "^CYAN^< ^CSUCC^Original index name restored. ^CYAN^>" ANSI_notify
         CONTINUE
      then
   REPEAT
;
 
: main[ str:Args -- ]
   VAR STRname VAR IDXname VAR OUTidx VAR IDXdata
   me @ "ARCHWIZARD" Flag? not if
      me @ "^CFAIL^" "noperm_mesg" SYSparm 1 escape_ANSI ANSI_notify EXIT
   then
   Args @ strip dup not if
      pop me @ "^CYAN^Syntax: ^AQUA^@idxedit  <filename>=<entry> ^NORMAL^Edit a specific entry." ANSI_notify
          me @       "        ^AQUA^@idxedit  <filename>         ^NORMAL^Edit the main index screen." ANSI_notify
          me @       "        ^AQUA^@fileedit <filename>         ^NORMAL^Edits an entire file." ANSI_notify
          me @ "^CINFO^NOTE: ^BROWN^See 'man shortcuts' to see the shortcuts for filenames." ANSI_notify
      EXIT
   then
   command @ "f" instring IF
      dup Fname-Ok? not IF
         pop pop me @ "^CFAIL^Invalid file name." ANSI_notify EXIT
      THEN
      dup STRname ! ARRAY_get_file ARRAY_editor "abort" stringcmp not IF
         pop me @ "^CFAIL^Aborted." ansi_notify
      ELSE
         STRname @ swap ARRAY_put_file
         me @ "^CSUCC^Finished and saved file changes." ansi_notify
      THEN
      EXIT
   THEN
   "=" split strip swap strip dup Fname-Ok? not if
      pop pop me @ "^CFAIL^Invalid file name." ansi_notify EXIT
   then
   STRname ! dup not if
      pop 1
   then
   IDXname !
   me @ "^CINFO^Grabbing the file... this may take awhile." ANSI_notify
   STRname @ ARRAY_get_index_file DICTfile !
   "^CSUCC^Successfully received the file.  Trying to find the entry." atell
   DICTfile @ IDXname @ ARRAY_getitem dup Array? not if
      pop
      IDXname @ String? if
         DICTfile @ IDXname @ "|*" strcat
         ARRAY_matchkey dup array_count not if
            DICTfile @ "*|" IDXname @ strcat ARRAY_matchkey
            dup array_count not if
               DICTfile @ "*|" IDXname @ strcat "|*" strcat ARRAY_matchkey
               dup array_count not if
                  pop me @ "^CFAIL^That entry cannot be found.  Attempting to create a new one." ANSI_notify
                  { }list
               else
                  dup ARRAY_first pop dup IDXname ! ARRAY_getitem
                  me @ "^CSUCC^Entry found." ANSI_notify
               then
            else
               dup ARRAY_first pop dup IDXname ! ARRAY_getitem
               me @ "^CSUCC^Entry found." ANSI_notify
            then
         else
            dup ARRAY_first pop dup IDXname ! ARRAY_getitem
            me @ "^CSUCC^Entry found." ANSI_notify
         then
      else
         "^CFAIL^That entry cannot be found.  Attempting to create a new one."
         atell
         { }list 1 IDXname !
      then
   then
   IDXdata ! IDXname @ OUTidx !
   me @ "^CINFO^Entering the editor for entry: ^NORMAL^"
   STRname @ 1 escape_ansi strcat
   "=" strcat IDXname @ dup Int? if
      pop "^WHITE^<MAIN>"
   else 1 escape_ansi
   then
   strcat ANSI_notify
   IDXdata @ OUTidx @ EDIT_INDEX rot rot OUTidx ! IDXdata ! if
      DICTfile @ dup IDXname @ ARRAY_getitem Array? if
         IDXname @ ARRAY_delitem
      then
      IDXdata @ swap OUTidx @ ARRAY_setitem DICTfile !
      "^CINFO^Writing out the index file.  This may take awhile." atell
      STRname @ DICTfile @ ARRAY_put_index_file
      me @ "^CINFO^Done." ANSI_notify
   else
      me @ "^CFAIL^Aborted." ANSI_notify
   then
;
