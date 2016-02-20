lvar param
 
: main
param !
{ "^SAY/POSE^" me @ param @ "'*" smatch not if " " then param @ strip "^NORMAL^" }cat 1 array_make
me @ location contents_array array_ansi_notify
;
