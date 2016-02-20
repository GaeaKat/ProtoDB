(** Someday... maybe... someday this will be recoded with Proto code **)
$lib-version 1.1
: oproploc ( dbref -- dbref' )
    dup "_proploc" getprop
    dup if
      dup string? if
        dup "#" 1 strncmp not if
            1 strcut swap pop
        then
        atoi dbref
      then
        dup ok? if
            dup owner 3 pick
            dbcmp if swap then
        else swap
        then pop
    else pop
    then
;
: myproploc ( -- dbref)
    me @ oproploc
;
: ignored? ( playerdbref -- i )
  oproploc "_page/@ignore" me @ REFLIST_find
;
: ignoring? ( playerdbref -- i )
  oproploc me @ "_page/@ignore" rot REFLIST_find
;
: priority? ( playerdbref -- bool )
  oproploc "_page/@priority" me @ REFLIST_find
;
public oproploc
public myproploc
public ignored?
public ignoring?
public priority?
$pubdef oproploc "$lib/page" match "oproploc" call
$pubdef myproploc "$lib/page" match "myproploc" call
$pubdef ignored? "$lib/page" match "ignored?" call
$pubdef ignoring? "$lib/page" match "ignoring?" call
$pubdef priority? "$lib/page" match "priority?" call
