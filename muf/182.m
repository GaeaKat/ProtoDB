$note Implements colorized splash screen
( 
  (C) 2003 Alynna Trypnotk
  Release Terms: GNU GPL v2, http://www.gnu.org/licenses/gpl.html
  Use anywhere, dont remove credits, return improvements to 
   alynna@animaltracks.net
   
  1. Log into your shell, archive and remove any existing welcome files
     and then 'touch welcome.txt'.
  
  2. @propset #0=d:/@login/_splash:splash.muf
  
  3. lsedit #0=splashscreen 
     to edit your splash screen.  
     Color codes and MPI supported.
)
$author Alynna
$version 1.00
: main
var line
0 sleep
descr GETDESCRINFO "conport" [] "wwwport" sysparm atoi = if exit then
descr "DF_COLOR" descr_set
#0 "splashscreen#" array_get_proplist foreach line ! pop
descr 
( #0 line @ "(@login/_splash)" 0 parsempi )
line @ 1 parse_ansi
notify_descriptor
repeat
descr 
online_array array_count intostr 
" players on right now.  Log on and become another one!" strcat
ansi_notify_descriptor
;
