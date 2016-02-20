( Alynna's MUF function library v6.0 )
( With new goobers for FB6 )
( Last updated August 31, 2003 )
$author Alynna
$version 6.0
 
$pubdef :
 
( prim '..' for checking if a number is in range                               )
$def .. 3 pick >= -3 rotate swap <= and
$pubdef .. 3 pick >= -3 rotate swap <= and
 
$ifdef __fuzzball__
( }cat is probably the most important thing to import but first we need some
  other basic things.                                                          )
 
( 0. Need: }array )
$def }array } array_make
$pubdef }array } array_make
$def [] array_getitem
$pubdef [] array_getitem
$def ->[] array_setitem
$pubdef ->[] array_setitem
 
( 1. Emulate Proto's internal CASE )
$def case    begin dup
$def when    if pop
$def end     break then dup
$def default pop 1 if
$def endcase pop pop 1 until
$pubdef case    begin dup
$pubdef when    if pop
$pubdef end     break then dup
$pubdef default pop 1 if
$pubdef endcase pop pop 1 until
 
( 3. Proto Prim 'ftostrc' for accurate, truncuated rounded numbers, getting
     around FB6's broken floats, and outputting sane floats.                   )  
: ftostrc[ flt:yerf -- str:result ]
yerf @ "%.15g" fmtstring
; PUBLIC ftostrc
$libdef ftostrc
 
( Some basic stuff for later, like emulation of Proto's 'array_interpret' 
  primitive, foxy goodness added to proto by me, but we can mostly emulate it by
  using array_join and dealing with exceptions, now that we have some other 
  basic functionality...                                                       )
: array_interpret[ arr:coolstuff -- str:result ]
var operator
{
coolstuff @ foreach swap pop operator !
operator @ case 
 dbref? when operator @ name end
 float? when operator @ ftostrc end
 default pop operator @ end
 endcase
repeat
}join
; PUBLIC array_interpret
$libdef array_interpret
 
( Now give us '}cat', and we have scored BIG                                   )
$def }cat } array_make array_interpret
$pubdef }cat } array_make array_interpret
 
( We need some basic proto ANSI interpretation
  Since FB6 color is very primitive, but they DO have itoc, we will simply
  inject color directly into strings.                                          )
$def ANSITAG 27 itoc "[" strcat
 
( For simplicity's sake we are only supporting Proto Color types 0 and 1
  And unlike Proto, since the notify routines on FB6 wont process our color
  tags by default, we will make -1 handle all color.
)
 
: parse_ansi[ str:operator int:standard -- str:result ]
standard @ -1 = standard @ 0 = or if
 ( Convert FB6 style tags to actual ANSI )
 operator @ 
  ANSITAG "\[[" subst
 operator !
then
standard @ -1 = standard @ 1 = or if
 ( Convert neon style tags to actual ANSI )
 operator @
  { ANSITAG "0m"    }join "^NORMAL^" subst
  { ANSITAG "4m"    }join "^UNDERLINE^" subst
  { ANSITAG "5m"    }join "^BLINK^" subst
  { ANSITAG "7m"    }join "^REVERSE^" subst
  { ANSITAG "0;30m" }join "^BLACK^" subst
  { ANSITAG "0;31m" }join "^CRIMSON^" subst
  { ANSITAG "0;32m" }join "^FOREST^" subst
  { ANSITAG "0;33m" }join "^BROWN^" subst
  { ANSITAG "0;34m" }join "^NAVY^" subst
  { ANSITAG "0;35m" }join "^VIOLET^" subst
  { ANSITAG "0;36m" }join "^AQUA^" subst
  { ANSITAG "0;37m" }join "^GRAY^" subst
  { ANSITAG "1;30m" }join "^CBLACK^" subst
  { ANSITAG "0;31m" }join "^CRED^" subst
  { ANSITAG "0;32m" }join "^CGREEN^" subst
  { ANSITAG "0;33m" }join "^CYELLOW^" subst
  { ANSITAG "0;34m" }join "^CBLUE^" subst 
  { ANSITAG "0;35m" }join "^CPURPLE^" subst
  { ANSITAG "0;36m" }join "^CCYAN^" subst
  { ANSITAG "0;37m" }join "^CWHITE^" subst
  { ANSITAG "1;30m" }join "^GLOOM^" subst
  { ANSITAG "1;31m" }join "^RED^" subst
  { ANSITAG "1;32m" }join "^GREEN^" subst
  { ANSITAG "1;33m" }join "^YELLOW^" subst
  { ANSITAG "1;34m" }join "^BLUE^" subst
  { ANSITAG "1;35m" }join "^PURPLE^" subst
  { ANSITAG "1;36m" }join "^CYAN^" subst
  { ANSITAG "1;37m" }join "^WHITE^" subst
  { ANSITAG "0;40m" }join "^BBLACK^" subst
  { ANSITAG "0;41m" }join "^BCRIMSON^" subst
  { ANSITAG "0;42m" }join "^BFOREST^" subst
  { ANSITAG "0;43m" }join "^BBROWN^" subst
  { ANSITAG "0;44m" }join "^BNAVY^" subst
  { ANSITAG "0;45m" }join "^BVIOLET^" subst
  { ANSITAG "0;46m" }join "^BAQUA^" subst
  { ANSITAG "0;47m" }join "^BGRAY^" subst
  { ANSITAG "1;40m" }join "^BGLOOM^" subst
  { ANSITAG "1;41m" }join "^BRED^" subst
  { ANSITAG "1;42m" }join "^BGREEN^" subst
  { ANSITAG "1;43m" }join "^BYELLOW^" subst
  { ANSITAG "1;44m" }join "^BBLUE^" subst
  { ANSITAG "1;45m" }join "^BPURPLE^" subst
  { ANSITAG "1;46m" }join "^BCYAN^" subst
  { ANSITAG "1;47m" }join "^BWHITE^" subst
  { ANSITAG "0m"    }join "^ ^" subst
 operator !
then
 operator @
; PUBLIC parse_ansi
$libdef parse_ansi
 
( Give us ansi_notify that acts like Proto                                     )
$def ansi_notify -1 parse_ansi \notify
$def ansi_notify_except -1 parse_ansi \notify_except
$def ansi_notify_exclude -1 parse_ansi \notify_exclude
$pubdef ansi_notify -1 parse_ansi \notify
$pubdef ansi_notify_except -1 parse_ansi \notify_except
$pubdef ansi_notify_exclude -1 parse_ansi \notify_exclude
 
: array_ansi_notify[ arr:lines arr:targets -- ]
{
lines @ foreach swap pop -1 parse_ansi repeat
}array targets @ \array_notify
;
 
( Make a clone of parsempi                                                     )
: parsempi[ d s1 s2 i -- s3 ]
var foxie 
{ d @ s1 @ s2 @ i @ }array foxie ! 
foxie @ 0 [] "mpi-exec" foxie @ 1 [] setprop 
foxie @ 0 [] "mpi-exec" foxie @ 2 [] foxie @ 3 [] parseprop 
foxie @ 0 [] "mpi-exec" 0 setprop
; PUBLIC parsempi
$libdef parsempi
$endif
 
( Proto compatibility section )
$ifdef __proto
( Glowmuck color compatibility -- dont even ATTEMPT this on FB6, its using our
  color handlers anyway                                                        )
$def specialparse 1 parse_ansi 3 parse_ansi dup strlen 4 - strcut pop
$def ansi_strcut swap specialparse swap \ansi_strcut
$def ansi_strlen specialparse \ansi_strlen
$endif
 
( *** ENHANCEMENTS COMMON TO FUZZBALL AND PROTOMUCK *** )
( Redirect }tell, }otell and }atell                                            )
$def }tell }cat me @ swap ansi_notify
$pubdef }tell }cat me @ swap ansi_notify
$def }otell }cat me @ location me @ rot ansi_notify_except
$pubdef }otell }cat me @ location me @ rot ansi_notify_except
$def }atell }cat me @ location #-1 rot ansi_notify_except
$pubdef }atell }cat me @ location #-1 rot ansi_notify_except
 
( Backwards compatibility for stuff that used my str .. cat stuff from before
  there was { }cat                                                             )
$def str {
$def cat } array_make array_interpret
$pubdef str {
$pubdef cat } array_make array_interpret
 
: parents_array[ ref:target -- arr:parents ]
{ target @ begin dup location dup not until pop }list
;
$libdef parents_array
PUBLIC parents_array
 
: array_env_propvals[ ref:target str:prop -- dict:envvals ]
{ target @ parents_array foreach swap pop prop @ array_get_propvals foreach repeat repeat } 2 / array_make_dict
;
$libdef array_env_propvals
PUBLIC array_env_propvals
 
: array_env_propdirs[ ref:target str:prop -- dict:envvals ]
{ target @ parents_array foreach swap pop prop @ array_get_propdirs foreach swap pop repeat repeat } array_make
;
$libdef array_env_propdirs
PUBLIC array_env_propdirs
 
$libdef toint 
: toint[ data -- int:newdata ] ( Unconditional convert to int )
data @ 1 array_make "" array_join "" "#" subst atoi
; PUBLIC toint
 
$libdef tostr
: tostr[ data -- str:newdata ] ( Unconditional convert to str )
data @
$ifdef __fuzzball__
dup float? if ftostrc else pop then
$endif
1 array_make "" array_join
; PUBLIC tostr
 
$libdef tofloat 
: tofloat[ data -- float:newdata ] ( Unconditional convert to float )
data @ 1 array_make "" array_join "" "#" subst strtof
; PUBLIC tofloat
 
$libdef todbref 
: todbref[ data -- dbref:newdata ] ( Unconditional convert to dbref )
data @ 1 array_make "" array_join "" "#" subst stod
; PUBLIC todbref
 
$libdef resolve
: resolve[ str:target -- dbref:object ] ( match player, than object )
var tmp 
target @ tmp ! 
tmp @ pmatch target ! 
target @ #-1 dbcmp if 
tmp @ match target !
then
target @
; PUBLIC resolve
 
$libdef astrcat 
: astrcat[ arr:stringlist -- str:string ] ( Take everything in an array and convert it to a string )
stringlist @ "" var! temp
array_reverse foreach temp @ swap tostr strcat temp ! repeat temp @
; PUBLIC astrcat
 
$libdef atellme 
: atellme[ arr:stringlist -- ] ( Tell me everything in the array, which must all be strings )
stringlist @ { me @ } array_make array_ansi_notify
; PUBLIC atellme
 
$libdef atellhere
: atellhere[ arr:stringlist -- ] ( Tell me everything in the array, which must all be strings )
stringlist @ me @ location contents_array array_ansi_notify
; PUBLIC atellhere
 
$libdef capitalize 
: capitalize[ str:string -- str:string2 ] ( Capitalise this string, making the first character uppercase )
string @ 1 strcut swap toupper swap strcat
; PUBLIC capitalize
 
$libdef tellhere
: tellhere[ str:string -- ] ( tell here the string )
me @ location #-1 1 string @ 
$ifdef __fuzzball__
 -1 parse_ansi
$else
 0 parse_ansi 1 parse_ansi 2 parse_ansi 3 parse_ansi
$endif
notify_exclude
; PUBLIC tellhere
 
$libdef tellme 
: tellme[ str:string -- ] ( tell me the string )
$ifdef __fuzzball__
 me @ string @ ansi_notify
$else
 me @ string @ \ansi_notify
$endif
; PUBLIC tellme
 
$libdef mpime 
: mpime[ str:string -- ] ( Parse the MPI string based on me )
string @ me @ dup ok? not if pop "guest" pmatch then swap "(MPI)" 0 parsempi
; PUBLIC mpime
 
$libdef mpi 
: mpi[ dbref:target str:string -- ] ( Parse the MPI string based on the specified object )
target @ string @ "(MPI)" 0 parsempi
; PUBLIC mpi
 
$ifndef here
$libdef here 
: here[ -- dbref:location ] ( return my location )
me @ location
; PUBLIC here   
$else
$pubdef here
$endif
 
$libdef nstrcat 
: nstrcat[ int:nstrcount -- str:string ] ( si .. s1 n -- s ) ( strcat a stackrange )
nstrcount --
begin strcat nstrcount -- 1 < until
; PUBLIC nstrcat
 
$libdef strcatall 
: strcatall ( si .. s1 -- s ) ( cats all strings till a non-string datatype is reached )
begin over string? if strcat else exit then depth 0 = until
; PUBLIC strcatall
 
$ifdef __fuzzball__
$else
$libdef notify_descriptor_nocr 
: notify_descriptor_nocr ( i s -- )
     1 over strlen 1 for over swap 1 midstr ctoi 3 pick swap notify_descriptor_char repeat pop
; PUBLIC notify_descriptor_nocr
 
$libdef notify_descr_literal
: notify_descr_literal[ int:de items -- ]
items @ case   
   int? when
     de @ swap notify_descriptor_char
   end
   array? when foreach swap pop
     de @ swap notify_descr_literal
   repeat end
   default { swap }cat notify_descriptor_nocr end
endcase
; PUBLIC notify_descr_literal
$endif
 
$libdef fchop
: fchop[ value int:decimalplaces -- s ] ( rounds and chops a float to i decimal places )
value @ decimalplaces @
swap tofloat swap
over  inf = if pop pop "inf" exit then
$ifdef __fuzzball__
$else
over -inf = if pop pop "-inf" exit then
over  nan = if pop pop "nan" exit then
$endif
swap tofloat over round ftostr swap over "." instr swap + strcut pop
; PUBLIC fchop
 
 
$libdef statbar 
: statbar[ int:fill int:length -- s:string ] ( outputs a statbar ===*--- i1 = length i2 = filled )
me @  { "{right:{if:" fill @ ",*,}," fill @ ",=}{left:,{subt:" length @ "," fill @ "},-}" }cat mpi
; PUBLIC statbar
 
$libdef fstatbar 
: fstatbar[ int:fill int:length -- s:string ] ( outputs a statbar 4 |===*---| i1 = length i2 = filled )
me @  { fill @ " |{right:{if:" fill @ ",*,}," fill @ ",=}{left:,{subt:" length @ "," fill @ "},-}|" }cat mpi
; PUBLIC fstatbar
 
$libdef wrap78
: wrap78[ str:wrapme -- arr:wrapped ] 
var curstr
wrapme @ capitalize wrapme ! 
{
begin
wrapme @ ansi_strlen 78 <= if wrapme @ break then
wrapme @ 78 ansi_strcut pop " " rsplit pop curstr !
wrapme @ curstr @ ansi_strlen ansi_strcut swap pop wrapme !
curstr @
repeat
} array_make
; PUBLIC wrap78
 
$libdef wrap74
: wrap74[ str:wrapme -- arr:wrapped ] 
var curstr
wrapme @ capitalize wrapme ! 
{
begin
wrapme @ strlen 74 <= if 
 { wrapme @ "          " "          " "          " "          "
            "          " "          " "          " "          "
            "          " "          " "          " "          "
            "          " "          " "          " "          " }cat
 74 strcut pop { "| " rot " |" }cat break then
wrapme @ 74 strcut pop " " rsplit pop curstr !
wrapme @ curstr @ strlen strcut swap pop wrapme !
{ "| "
{ curstr @ "          " "          " "          " "          "
           "          " "          " "          " "          " 
           "          " "          " "          " "          "
           "          " "          " "          " "          "}cat 74 strcut pop
 " |" }cat
repeat
} array_make
; PUBLIC wrap74
  
$libdef prop?
: prop?[ dbref:target str:prop -- int:exists ] ( returns true if the prop exists, and false if not )    
target @ prop @
 getprop dup int? if     
  0 = if     
    0 exit     
   else    
    1 exit    
   then     
  else    
   pop 1 exit    
  then    
; PUBLIC prop?
 
$libdef wassup? 
: wassup?[ query -- int:trueness ] ( returns false if the argument is 0, "", or #-1, and true otherwise )    
query @ dup string? if
 "" stringcmp 0 = if 0 exit then
then
dup int? if
 0 = if 0 exit then
then
dup dbref? if
 #-1 dbcmp if 0 exit then
then
1
; PUBLIC wassup?    
 
$libdef lj 
: lj[ str:string int:chars -- s ] ( format to x characters left justified )    
string @ chars @
swap    
"                                                                              "    
strcat swap ansi_strcut pop    
; PUBLIC lj    
 
$libdef rj 
: rj[ str:string int:chars -- s ] ( format to x characters right justified )    
string @ chars @
swap     
"                                                                              "    
swap strcat dup ansi_strlen 3 pick - ansi_strcut swap pop swap pop    
; PUBLIC rj
 
$libdef ulj 
: ulj[ str:string int:chars -- s ] ( format to x characters left justified )    
string @ chars @
swap    
"______________________________________________________________________________"    
strcat swap ansi_strcut pop    
; PUBLIC ulj
 
$libdef urj     
: urj[ str:string int:chars -- s ] ( format to x characters right justified )    
string @ chars @
swap     
"______________________________________________________________________________"    
swap strcat dup ansi_strlen 3 pick - ansi_strcut swap pop swap pop    
; PUBLIC urj 
 
: wrap_items_fixed[ arr:items int:perline -- arr:formatted ]
{ }array var! formatted
var item
var count
var linestore
var idx
var idxperline
var itemsize
-1 count ! "" linestore !
perline @ case
 7 >= when 7 11 end
 6  = when 6 13 end
 5  = when 5 15 end
 4  = when 4 19 end
 3  = when 3 26 end
 default 2 39 end
endcase
itemsize ! idxperline !
items @ foreach item ! pop count ++ 
{
 linestore @ item @ tostr itemsize @ lj
}cat linestore !
count @ idxperline @ % idxperline @ -- = if linestore @ formatted @ array_appenditem formatted ! "" linestore ! then
repeat
count @ idxperline @ % idxperline @ -- < if linestore @ formatted @ array_appenditem formatted ! "" linestore ! then
formatted @
;
 
: maxstrlen[ arr:strings -- int:result ]
var item
var value
0 var! result
strings @ foreach value ! item !
 value @ strlen result @ > if value @ strlen result ! then
repeat
result @
; PUBLIC maxstrlen
$libdef maxstrlen
 
: wrap_items_variable[ arr:items -- arr:formatted ]
{ }array var! formatted
var item
var count
var linestore
var idx
var idxperline
var itemsize
-1 count ! "" linestore !
items @ maxstrlen case
 10 <= when 7 11 end
 12 <= when 6 13 end
 14 <= when 5 15 end
 18 <= when 4 19 end
 25 <= when 3 26 end
 default 2 39 end
endcase
itemsize ! idxperline !
items @ foreach item ! pop count ++
{
 linestore @ item @ tostr itemsize @ lj
}cat linestore !
count @ idxperline @ % idxperline @ -- = if linestore @ formatted @ array_appenditem formatted ! "" linestore ! then
repeat
count @ idxperline @ % idxperline @ -- < if linestore @ formatted @ array_appenditem formatted ! "" linestore ! then
formatted @
; PUBLIC wrap_items_variable 
$libdef wrap_items_variable
 
$libdef ematch 
: ematch[ str:source str:explodearg str:matchstring -- s ] ( Explode match ) ( Depreciated, use arrays )
( s3 = "Source string S"   s2 = "Explode argument E" s1 = "Match string X" -- "Match found" )  
( Very complex function that matches an stack for the characters in s )  
( Returns s with a match or null, leaves the stack without exploded arguments ) 
var emS  var emE  var emX  var emI  var emT    
source @ explodearg @ matchstring @ emX ! emE ! emS !  ( Store it all )  
emS @ emE @ explode emI ! ( explode on stack, save the count )  
emI @ 0 = if "" exit then ( n = 0 ? nothing to explode.  Leave. )  
begin ( should have string on the stack )  
dup emX @ stringpfx if ( Does this string have the first same chars as our search string? )  
  emS ! emI @ 1 - popn emS @ exit ( if so, return it )  
 else   
  pop ( remove it from the stack )  
 then  
emI @ 1 - emI ! ( decrement emI )  
emI @ 0 = until ( until 0 )  
"" ( Didnt match, return null, and book it )  
; PUBLIC ematch  
 
$libdef eselect 
: eselect[ str:explodestr str:explodesep int:number -- s ] ( Selects i in explode ) ( Depreciated, use arrays )
( s1 = explode seperator  s2 = explode string  i = number in list to return )
var emS  var emE  var emX  var emI  var emT    
explodesep @ explodestr @ number @ emX ! emE ! emS !  ( Store it all )  
emS @ emE @ explode emI ! ( explode on stack, save the count ) 
1 emT ! ( initialize emX )
emI @ 1 < if "" exit then ( n < 1 ? nothing to explode.  Leave. )  
begin ( should have string on the stack )  
emT @ emX @ = if ( does emT = emX? )  
  emS ! emI @ emT @ - popn emS @ exit ( if so, return it )  
 else   
  pop ( remove it from the stack )  
 then  
emT @ 1 + emT ! ( increment emI )  
emT @ emI @ > until ( until > emT )  
"" ( Didnt match, return null, and book it )  
; PUBLIC eselect
 
$libdef erand 
: erand[ str:explodestr str:explodesep -- s ] ( Selects a random member of the explode ) ( depreciated, use arrays )
( s1 = explode seperator  s2 = explode string )
var emS  var emE  var emX  var emI  var emT    
explodesep @ explodestr @ emE ! emS ! ( Store it all )  
emS @ emE @ explode emI ! ( explode on stack, save the count ) 
random emI @ % 1 + emX ! ( Select a random member of the list )
1 emT ! ( initialize emT )
emI @ 1 < if "" exit then ( n < 1 ? nothing to explode.  Leave. )  
begin ( should have string on the stack )  
emT @ emX @ = if ( does emT = emX? )  
  emS ! emI @ emT @ - popn emS @ exit ( if so, return it )  
 else   
  pop ( remove it from the stack )  
 then  
emT @ 1 + emT ! ( increment emI )  
emT @ emI @ > until ( until > emT )  
; PUBLIC erand
 
$libdef ecount  
: ecount[ str:explodestr str:explodesep -- i  ] ( Returns number of items in the explode ) ( depreciated, use arrays )
var emS  var emE  var emX  var emI  var emT    
( s1 = explode seperator   s2 = explode string )
explodesep @ explodestr @ emE ! emS ! ( Store it all )  
emS @ emE @ explode emI ! ( explode on stack, save the count ) 
emI @ popn emI @ exit ( clear the stack, return the count and leave )
; PUBLIC ecount
 
$libdef invprop
: invprop[ dbref:target str:prop value -- s ] ( search propdir s on d for value ?, returns prop s, or "" if not found )
var ipD var ipS var ipO
target @ prop @ value @ ipO ! ipS ! ipD !
ipD @ ipS @ nextprop ipS !
begin
ipS @ "" stringcmp if
ipD @ ipS @ getprop dup
dup string? if ipO @ stringcmp not if pop ipS @ exit then then
dup int? if ipO @ = if pop ipS @ exit then then
dup dbref? if ipO @ dbcmp if pop ipS @ exit then then
pop 
then
ipD @ ipS @ nextprop ipS !
ipS @ "" stringcmp not until
""
; PUBLIC invprop
 
$libdef header 
: header[ str:string -- s ] ( Place string into a header block ) ( Alynna's UI toolkit 1.0 )
string @
"^WHITE^-^BLUE^[ ^YELLOW^" swap strcat
"^BLUE^ ]^WHITE^----------------------------------------------------------------------------^NORMAL^" strcat
112 strcut pop
; PUBLIC header
 
$libdef footer 
: footer[ str:string -- s ] ( Place string into a footer block ) ( Alynna's UI toolkit 1.0 )
string @
"^WHITE^-----------------------------------------------------------------------------^BLUE^[ ^YELLOW^" swap strcat
"^BLUE^ ]^WHITE^-^NORMAL^" strcat
dup strlen 113 - strcut swap pop
; PUBLIC footer
 
$libdef pretty  
: pretty[ str:string str:mutex -- s ] ( Prefix string with colorized, official prefix ) ( Alynna's UI toolkit 1.0 )
string @ mutex @
 { swap "^BLUE^<^YELLOW^" swap "^BLUE^>^NORMAL^ " }cat
swap strcat
; PUBLIC pretty
 
$libdef timex 
: timex[ int:seconds -- s ] ( translate i seconds to long time string )
var temp
seconds @ fabs int temp !
str
 temp @ 31536000 >= if temp @ 31536000 / 999 % tostr " years, " then
 temp @    86400 >= if temp @    86400 / 365 % tostr " days, " then
 temp @     3600 >= if temp @     3600 /  24 % tostr " hours, " then
 temp @       60 >= if temp @       60 /  60 % tostr " minutes, " then
                       temp @             60 % tostr " seconds"
cat
; PUBLIC timex
 
$libdef dhm 
: dhm[ int:minute -- s ] ( translate i minutes into xxd mm:ss )
minute @
  dup 60 % swap 60 / dup 24 % swap 24 /
  dup
  if
    intostr "d " strcat
  else
    pop ""
  then
  swap intostr dup strlen 1 =
  if
    "0" swap strcat
  then
  ":" strcat strcat swap intostr dup strlen 1 =
  if
    "0" swap strcat
  then
  strcat
; PUBLIC dhm
 
$libdef stimestr 
: stimestr[ int:seconds -- s ] ( return short time string for x seconds )
seconds @ me @ swap { swap "{stimestr:" swap "}" }cat "(STimeStr.MUF)" 0 parsempi
; PUBLIC stimestr
 
$libdef idletime 
: idletime[ dbref:target -- i ] ( return object d's lowest idle time )
target @ descrleastidle descridle
; PUBLIC idletime
 
$libdef onlinetime
: onlinetime[ dbref:target -- i ] ( return object d's highest connect time )
var temp1
var oltime
-1 oltime !
target @ descriptors temp1 !
begin
descrtime dup oltime @ > if oltime ! else pop then
temp1 @ 1 - temp1 !
temp1 @ not until
oltime @
; PUBLIC onlinetime
 
$libdef numplayers 
: numplayers[ dbref:location -- i ] ( return the number of players at the current location )
location @
  0 swap contents
  begin
    dup ok? while
    dup player?
    if
      dup awake?
      if
        swap 1 + swap
      then
    then
    next
  repeat
  pop
; PUBLIC numplayers
 
$libdef debug 
: debug[ str:debugstr -- ] ( Send a debug command to logs/status )
debugstr @ "[DBUG]: " swap strcat 
$ifdef __fuzzball__
userlog
$else
logstatus
$endif
; PUBLIC debug
 
$libdef array_commas ( Turn array of strings to item, item, item and item )
: array_commas[ arr:items -- s ]
var value 
var count
var item 
items @ array_count count !
count @ 1 = if
 items @ array_vals pop tostr exit
then
count @ 2 = if
 items @ " and " array_join exit
then
items @ foreach value ! item !
item @ case
  0 = when value @ tostr ", " strcat end
  count @ 1 - = when "and " value @ tostr strcat strcat end
  count @ 2 - = when value @ tostr " " strcat strcat end
  0 > when value @ tostr ", " strcat strcat end
endcase
repeat
; PUBLIC array_commas
 
$libdef array_random ( Select a random member of an array )
: array_random[ a:items -- x ]
items @ random over array_count % []
; PUBLIC array_random
 
$libdef limit ( Return a value within set limits )
: limit[ value low high -- result ]
value @  low @ < if  low @ value ! then
value @ high @ > if high @ value ! then
value @
; PUBLIC limit
 
: main ( -- ) ( installer )
pop "The installer function is obsolete.  Please read the directions from the compile." tellme
;
