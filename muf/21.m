(*
   Lib-File 1.1
   Author: Chris Brine [Moose/Van]
   v1.1: [Akari] 09/04/2001
   - Notes on use added
   - New directives added
   Note: All calls are W4 only.
         This program must have W4 permissions in order to run.
         Register as $lib/file.
   array_get_file(str<fileName>  -- array<file>)
       Given a file name it will return an array
       where each element of the array is one line
       of the file.
   array_put_file(str<fileName> array<file> -- )
       Given a file name and an array of strings, writes
       out the contents of the array to the given file.
   array_get_index_file(str<fileName> -- dict<file>)
       Used for reading in index type files, such as help.txt or
       man.txt. The file is loaded into a directionary where each
       index value is the 'keywords' for that entry in the file
       and the value is a list array of strings representing the
       actual contents of that entry.
   array_put_index_file(str<fileName> dict<file> -- )
       Used for writing out files as mentioned above. The dictionary
       must conform to the specifications mentioned in array_get_index_file.
       That is, each index value is the entry keyword(s) and each element
       value is a list array of strings.
 *)
$author Moose
$lib-version 1.1
$pubdef :
$pubdef array_get_file "$Lib/File" match "array_get_file" call
$pubdef array_get_index_file "$Lib/File" match "array_get_index_file" call
$pubdef array_put_file "$Lib/File" match "array_put_file" call
$pubdef array_put_index_file "$Lib/File" match "array_put_index_file" call
( other stuff here )
: array_get_file[ str:file -- arr:file' ]
   0 VAR! offset
   file @ Fname-OK? not if
      "Invalid filename or shortcut." abort
   then
   { }list
   BEGIN
      file @ offset @ "\r" FREADTO swap offset ! dup if
         swap array_appenditem
      else
         pop BREAK
      then
   REPEAT
;
: array_put_file[ str:file arr:ARRfile -- ]
   0 VAR! idx
     VAR  curidx
   0 VAR! idx
   file @ Fname-OK? not if
      "Invalid filename or shortcut." abort
   then
   ARRfile @ dup array_count curidx !
   FOREACH
      swap pop idx ++ idx @ curidx @ = not if
          "\r" strcat
      then
      file @ idx @ if
         fappend pop
      else
         0 fwrite pop idx ++
      then
   REPEAT
;
: array_get_index_file[ str:file -- dict:file' ]
   1 VAR! curname
   1 VAR! inname
   0 VAR! offset
   file @ Fname-OK? not if
      "Invalid filename or shortcut." abort
   then
   { }dict
   BEGIN
      file @ offset @ "\r" FREADTO swap offset ! dup not if
         pop BREAK
      then
      dup "~" instr 1 = if
         pop 0 inname ! CONTINUE
      then
      inname @ not if
         curname ! 1 inname ! CONTINUE
      then
      over array_keys array_make curname @ array_findval array_count if
         over curname @ array_getitem
      else
         { }list
      then
      array_appenditem swap curname @ array_setitem
   REPEAT
;
: array_put_index_file[ str:file dict:DICTfile -- ]
   0 VAR! idx
   file @ Fname-OK? not if
      "Invalid filename or shortcut." abort
   then
   DICTfile @ 1 array_getitem DICTfile @ 1 array_delitem DICTfile !
   FOREACH
      swap pop "\r" strcat file @ idx @ if
         fappend pop
      else
         0 fwrite pop idx ++
      then
   REPEAT
   DICTfile @
   FOREACH
      swap "\r" strcat "~~\r" swap strcat file @ fappend pop
      FOREACH
         swap pop "\r" strcat file @ fappend pop
      REPEAT
   REPEAT
;
BOYCALL array_get_file
BOYCALL array_put_file
BOYCALL array_get_index_file
BOYCALL array_put_index_file
