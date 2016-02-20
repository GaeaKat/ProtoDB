$include $lib/alynna
lvar param
 
: do-alias
var value
var count
param @ "|" explode dup count ! array_make foreach value ! pop
 me @ value @ mpime force
repeat
;
 
: alias-conv
var target
var item
var value
var newvalue
me @ target !
 
str "Alias conversion for " target @ unparseobj cat header tellme
target @ "/@/alias/" array_get_propvals foreach value ! item !
value @ "{&arg}" "$*" subst newvalue !
target @ "/_alias/" item @ strcat newvalue @ setprop
str
"^GREEN^" item @ 10 lj 
"^YELLOW^" value @ 34 lj
"^CYAN^" newvalue @ 34 lj
"^NORMAL^"
cat tellme
repeat
"Alias v1.0" footer tellme
;
 
: alias-view
var target
var item
var value
command @ "@galias" smatch if #0 target ! else me @ target ! then
 
str "Aliases defined on " target @ unparseobj cat header tellme
target @ "_alias/" array_get_propvals foreach value ! item !
str
"^GREEN^" item @ 10 lj 
"^YELLOW^" value @
cat tellme
repeat
"Alias v1.0" footer tellme
;
 
: alias-del
var target
command @ "@gunalias" smatch if #0 target ! else me @ target ! then
 
param @ not if
 str "Format: " command @ " <alias>" cat "Alias" pretty tellme exit
then
 
target @ "_alias/" param @ strcat 0 setprop
target @ "@command/" param @ strcat 0 setprop
str "Alias '" param @ "' on " target @ unparseobj " has been deleted." cat "Alias" pretty tellme
;
 
: alias-set
var target
var alias-name
var alias-code
 
command @ "@galias" smatch if #0 target ! else me @ target ! then
 
param @ not if
 str "Format: " command @ " <command>=<mpi statement>" cat "Alias" pretty tellme exit
then
 
param @ "=" explode case
 2 >= when
  alias-name ! param @ "" alias-name @ "=" strcat subst alias-code ! end
 default
  str "Format: " command @ " <command>=<mpi statement>" cat "Alias" pretty tellme exit end
endcase
 
target @ "_alias/" alias-name @ strcat alias-code @ setprop
target @ "@command/" alias-name @ strcat 
 str "&{null:{muf:#" prog int "," alias-code @ "}}" cat setprop
str "Alias '" alias-name @ "' on " target @ unparseobj " has been set." cat "Alias" pretty tellme
;
 
: alias-help
{
"Aliases for ProtoMUCK (C) 2001 Alynna Trypnotk"
" "
" Formats:"
"  @alias #help                        See this help screen"
"  @alias                              Show me my aliases"
"  @alias <command>=<statement>        Make an alias"
"  @unalias <command>                  Remove the alias"
"  @convalias                          Convert Glow aliases to Proto aliases"
me @ mlevel 5 >= if
"  @galias / @gunalias                 <WIZ> Same as above, on #0"
then
" "
" Statements:"
"  Can be any MPI statement that will be executed as if it were you.  Use"
"  {&arg} to specify the arguments given when you use the alias."
"  You can specify multiple commands by seperating them with a bar (|)."
"  Delays will be introduced to space the commands 1 second apart."
" "
" Examples:"
"  @alias ]=. chat {&arg}"
"  @alias mul100=say 100 times {&arg} equals {mult:{&arg},100}!!"
} array_make atellme 
;
 
: main
param !
command @ tolower case
 "{@alias|@galias}" smatch when
  command @ "@galias" smatch me @ mlevel 4 <= and if
   "^RED^Permission denied.^NORMAL^" tellme exit
  then
  param @ tolower case
   "#h*" smatch when alias-help exit end
   not when alias-view exit end
   default alias-set exit end
 endcase end
 "{@unalias|@gunalias}" smatch when 
   command @ "@galias" smatch me @ mlevel 4 <= and if
   "^RED^Permission denied.^NORMAL^" tellme exit
  then
  alias-del exit end
 "{@convalias}" smatch when alias-conv exit end
endcase
do-alias 
;
