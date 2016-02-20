(*
  Con-FailAnnounce v1.1 - by Moose
  v1.1 by Akari
  - Formatted to 80 colums and added new directives and notes.
  Install: Just set LINK_OK and call from the _connect/ propqueue on #0.
  Con-FailAnnounce reports any failed login attempts on your character by
      reading from a prop automatically set by ProtoMUCK when an invalid
      password is used for your character under "@/failed" on the character.
      Reports the time and host of the last failed attempt, and the total
      number of attempts since your last login.
*)
 
$author Moose
$version 1.1
 
: main ( s -- )
   pop
   me @ "@/failed/host" getpropstr strip if
      me @ "^YELLOW^## ^CRIMSON^Last failed connect on ^RED^"
      me @ "@/failed/time" getpropval
      "%A %B %e, %Y ^CRIMSON^at^RED^ %I:%M:%S %p" swap timefmt strcat
      " ^CRIMSON^from^RED^ " strcat
      me @ "@/failed/host" getpropstr strip "^^" "^" subst strcat
      "^CRIMSON^." strcat ansi_notify
      me @ "@/failed/time" remove_prop
      me @ "@/failed/host" remove_prop
      me @ "@/failed/count" getpropval dup 0 > if
         me @ "^YELLOW^## ^CRIMSON^There has been ^RED^%n ^CRIMSON^failed connections since your last login."
         over "@/failed/count" getpropval intostr "%n" subst ansi_notify
         me @ "@/failed/count" remove_prop
      then
   then
   me @ "^GREEN^## ^FOREST^You last connected from ^AQUA^" me @ "@/host"
   getpropstr strip "^^" "^" subst strcat ansi_notify
   me @ "@/host" getpropstr strip me @ "@/lasthost" rot setprop
   me @ "@/host" over descriptors
   begin dup 1 > while
       swap pop 1 -
   repeat
   pop descrcon conhost setprop
;
