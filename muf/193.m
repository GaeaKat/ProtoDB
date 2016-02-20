$include $lib/stackrng
 
: noisy_match (s -- d)
  dup if match else pop #-1 then
  dup not if
    me @ "I don't see that here!" notify exit
  then
  dup #-2 dbcmp if
    me @ "I don't know which one you mean!" notify exit
  then
;
 
 
: noisy_pmatch ( s -- d )
  .pmatch dup not if
    me @ "I don't recognize anyone by that name." notify
  then
;
 
: match_controlled (s -- d)
  noisy_match dup ok? if
    me @ over controls not if
      pop #-1 me @ "Permission denied." notify
    then
  then
;
 
: table_compare ( possible tomatch -- match? )
  dup strlen strncmp not
;
 
: table_loop
  dup 4 >
  if
    dup rotate over rotate
    over 7 pick 7 pick execute
    if
      0 4 pick - rotate 0 3 pick - rotate
      swap
      if
        popn
        swap pop "" swap exit
      else
        1 swap
      then
    else
      pop pop
    then
    2 - table_loop
  else
    pop
    if
      pop pop rot pop rot pop
    else
      pop pop pop "" swap
    then
  then
;
 
: table_match
  0 4 rotate 2 * 4 + table_loop
;
 
: std_table_match
  'table_compare table_match
;
 
: multi_rmatch-loop (i s d -- dn .. d1 n)
  dup not if pop pop exit then
  over over name swap
  "&" explode dup 2 + rotate
  begin
    over not if pop pop 0 break then
    swap 1 - swap dup 4 rotate strip
    dup not if pop pop continue then
    dup "all" stringcmp not if pop "*" then
    "*" swap strcat "*" strcat
    smatch if
      pop begin
        dup while
        1 - swap pop
      repeat
      pop 1 break
    then
  repeat
  if rot 1 + rot 3 pick then
  next multi_rmatch-loop
;
 
: multi_rmatch (d s -- dn .. d1 n)
  over over rmatch dup int 0 >= if
    dup thing? over program? or if
      rot rot pop pop 1 exit
    then
  then
  pop
  0 swap rot contents
  multi_rmatch-loop
;
 
PUBLIC noisy_match
PUBLIC noisy_pmatch
PUBLIC match_controlled
PUBLIC table_match
PUBLIC std_table_match
PUBLIC multi_rmatch
