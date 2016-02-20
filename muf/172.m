( Executes MUF from the command line
  [C] 2003 Alynna Trypnotk
  Release Terms: GNU GPL v2, http://www.gnu.org/licenses/gpl.html
  Use anywhere, dont remove credits, return improvements to 
   alynna@animaltracks.net
  
  Installation: 
  1. Upload program
  2. Give program LINK_OK bit, give to W4 wiz 
  3. Execute once.  Error message is normal.  Will say:
     "First time setup, MPI macro created." before error, indicating
     a successful install.
 
  Usage:
  {meval:<muf code>}
  Escape all { } and , with \
  
  Permissions req'd [W4]:
  1. COMPILE
  2. RECYCLE program given to WIZARD
  3. NEWPROGRAM, and program editing prims
 
  Possible errors:
  1. Permission denied.  Trigger player or objet is not at least M1.
  2. Error in MUF code.  The MUF didnt compile
)
$ifdef __fuzzball__
$include $lib/alynna
$endif
 
$def }tell }cat me @ swap ansi_notify
$author Alynna
$version 1.1
$note Executes MUF inside an MPI statement.
lvar param
 
$def MPISTR "{muf:#" prog int intostr ",{:1}}" strcat strcat 
 
: main
var permissions
var program
var error
 
param !
 
( dont even bother if I cant find at least an M1 someplace )
$ifdef __fuzzball__
me @ "W" flag? not trig "W" flag? not and if "Permission denied." abort then
$else
me @ mlevel 2 < trig mlevel 2 < and if "Permission denied." abort then
$endif
 
( make a temporary program )
"muf-temp.muf" newprogram dup program ! 1
{
( Import some functionality if its around, to use in evaluations )
 
$iflib $lib/alynna        ( Do we have $lib/alynna? )
"$include $lib/alynna"
$endif
$iflib $lib/rp            ( Do we have a protected RPsystem library? )
"$include $lib/rp"
$endif
$iflib $lib/tcpip         ( Do we have a simulated internet? )
"$include $lib/tcpip"
$endif
$iflib $muf/inline        ( Do we have inline MUF? )
"$include $muf/inline"
$endif
$iflib $lib/pokedex       ( Is this APA2? )
"$include $lib/rps"
"$include $lib/rps2"
"$include $lib/pokedex"
$endif
 
( Include me, I export meval )
"$include #" prog int intostr strcat
": main"
"0 try"
command @ "@qmuf" smatch if "debug_on" then
param @
command @ "@qmuf" smatch if "debug_off" then
"depth not if \"OK\" then"
"catch_detailed"
command @ "@qmuf" smatch if "debug_off" then
"#-14002838"
"endcatch"
"0 sleep"
"; PUBLIC main"
} array_make 
$ifdef __fuzzball__
 swap pop program_setlines
$else
 program_insertlines pop
$endif
 
 
( For gods sake set this thing N!  Something as simple as integer divide
  by zero can make the MUCK segfault during optimization! )
$ifndef __fuzzball__
program @ "NO_COMMAND" set
$endif
 
( Chown to me so I dont run at higher than my permissions )
program @ me @ setown
 
( Compile the evaluator, it'll include me ) 
program @ 0 compile pop
 
( Call the evaluator )
0 try
 program @ "main" call
catch_detailed error ! ( Catch compile error )
 { command @ " (" param @ "), " 
   "program " error @ "program" [] ", "
   "line " error @ "line" [] ", "
   error @ "instr" [] ": " error @ "error" [] }tell
 program @ recycle
 exit
endcatch
 
dup dbref? if dup #-14002838 dbcmp if pop error ! then then
error @ if
 { command @ " (" param @ "), " 
   "program " error @ "program" [] ", "
   "line " error @ "line" [] ", "
   error @ "instr" [] ": " error @ "error" [] }tell
 program @ recycle
 exit
then
 
( Destroy the program )
program @ recycle
 
( Make sure the output is a string for MPI )
{ "Result: " rot
dup case
 string? when end
 int? when { "Integer: " rot intostr }cat end
 lock? when { "Lock: " rot parselock }cat end
 float? when { "Float: " rot ftostrc }cat end
 dbref? when { "DBRef: " rot int "#" swap intostr }cat end
 array? when { "Array(" rot dup array_count "): " rot "; " array_join }cat end
 default pop "<Unrepresentable result>" end
endcase
}cat me @ swap ansi_notify
;
