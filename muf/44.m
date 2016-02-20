(*
   AutoDesc v2.4
   Author: Chris Brine [Moose/Van]
 
   * Rewritten from scratch, but based on the older version done by unknown author.
 
   v2.4: Whoops.  Neon ansi codes shouldn't work in autodesc.  Fixed.
   v2.3: Fixed a few bugs where blank lines showed up and <font> parsings screwed up.
   v2.2: Fixed a bug where just doing @$autodesc on its own didn't work
   v2.1: The HTML parsing and fixing routines were moved to $Lib/CGI
 *)
 
$author Moose
$version 2.4
 
$include $Lib/CGI (* Requires v1.5+ *)
 
: doTEXTdesc ( arr:ARRlist -- )
   FOREACH
      swap pop trigger @ swap "(@desc)" 1 parsempi "^^" "^" subst HTML2TEXT dup ansi_strip "" "\r" subst if
         me @ swap ansi_notify
      else
         pop
      then
   REPEAT
;
 
: doHTMLdesc ( arr:ARRlist -- )
   { }list swap
   FOREACH
      swap pop trigger @ swap "(@desc)" 1 parsempi HTMLfix dup ansi_strip "" "\r" subst if
         swap array_appenditem
      else
         pop
      then
   REPEAT
   "<p>" swap " " ARRAY_join strcat stripspaces me @ swap notify_html
;
 
: Main[ str:STRproplist -- ]
   trigger @ STRproplist @ dup strip not if pop "desc" then array_get_proplist
   me @ "PUEBLO" flag? if
      doHTMLdesc
   else
      doTEXTdesc
   then
;
