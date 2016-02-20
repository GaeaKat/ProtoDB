(*
   Con-Multiguest
   Author: Chris Brine [Moose/Van]
 
   This program requires ProtoMUCK v1.50 and Comsys v2.0.0 to run properly.
 
   To do:
     * Add in an IP history method for security
     * Make sure that comsys is optional
     * Make sure that two guests cannot run the process at the same time, to secure from extreme cases
 
   Features:
     * You can have different guest names by setting them in the listprop _Names on the guest room.
     * Allows any amount of guests to login since it creates and toads them.
     * If a guest character was not removed properly, due to a crash, it will allow guests to take
       over the name.
     * It will only work for guests with the GUEST flag set, but without the M1 flag [or higher] or
       BUILDER flags being set.
     * Allows you to change the name for the main guest and the holder character.
     * Allows a note/connect splash to be shown to guests on connect: _Note listprop on guest room.
     * Gets a random password for guests so there is no "standard password" and no bad logins.
     * It makes sure that only the main guest can run the connection procedure.
     * Allows you to change the guest room.
     * Removes the DARK flag from the new guest, if it is set on the main guest.
 *)
 
$author Moose
$version 2.01
 
$include $lib/comsys
$include $lib/standard
 
VAR doSTRadd
VAR GUESTcount
 
: GUEST_COUNT ( int:StartCount -- int:INTcount )
   BEGIN
      prog "/@GuestChars/" 3 pick 1 + intostr strcat getprop
      dup dbref? not if
         pop EXIT
      then
      dup ok? not if
         pop EXIT
      then
      dup player? not if
         pop EXIT
      then
      dup "G" Flag? not over "B" Flag? or over "M1" Flag? or if
         pop EXIT
      then
      dup "/@/Precious" getpropstr "yes" stringcmp not if
         pop EXIT
      then
      dup Awake? not if
         GUEST-holder_char_db swap TOADplayer
      then
      pop 1 +
   REPEAT
;
 
: Get-Name[ str:STRadd -- str:STRname ]
  GUEST-addcount? if
   GUEST-addon? if
      GUEST-addon? 1 -
   else
      0
   then
   GUESTcount @ 1 + intostr dup STRadd !
   prog GUEST-names_list array_get_proplist
   GUEST-main_guest_db GUEST-names_list array_get_proplist array_union
   GUEST-room GUEST-names_list array_get_proplist array_union SORTTYPE_SHUFFLE \array_sort dup array_count if
      0 array_getitem
   else
      pop GUEST-main_guest
   then
   GUEST-prepend_addon? if
      GUEST-str_addon swap strcat strcat
   else
      GUEST-str_addon strcat swap strcat
   then
   STRadd @ doSTRadd !
  else
   STRadd @ not if
      GUEST-addon? if
         GUEST-addon? intostr STRadd !
      then
   then
   prog GUEST-names_list array_get_proplist
   GUEST-main_guest_db GUEST-names_list array_get_proplist array_union
   GUEST-room GUEST-names_list array_get_proplist array_union SORTTYPE_SHUFFLE \array_sort dup array_count if
      FOREACH
         swap pop strip dup not if
            pop CONTINUE
         then
         GUEST-prepend_addon? if
            GUEST-str_addon swap strcat STRadd @ swap strcat
         else
            GUEST-str_addon strcat STRadd @ strcat
         then
         "*" over strcat match dup ok? if awake? not else pop 1 then if
            "*" over strcat match ok? if
               "*" over strcat match dup "GUEST" flag? over "M1" flag? not and swap "BUILDER" flag? not and if
                  GUEST-holder_char_db "*" 3 pick strcat match ToadPlayer exit
               else
                  pop CONTINUE
               then
            else
               exit
            then
         else
            pop
         then
      REPEAT
   else
      pop GUEST-main_guest
      GUEST-prepend_addon? if
         GUEST-str_addon swap strcat STRadd @ swap strcat
      else
         GUEST-str_addon strcat STRadd @ strcat
      then
      "*" over strcat match dup ok? if awake? not else pop 1 then if
         "*" over strcat match ok? if
            "*" over strcat match dup "GUEST" flag? over "M1" flag? not and swap "BUILDER" flag? not and if
               GUEST-holder_char_db "*" 3 pick strcat match ToadPlayer exit
            else
               pop
            then
         else
            exit
         then
      else
         pop
      then
   then
   STRadd @ if
      STRadd @ atoi 1 + intostr
   else
      "1"
   then
   Get-Name
  then
;
 
: abs ( i -- i )
   dup 0 < if -1 * then
;
 
: Get-Pass[ -- str:STRpass ]
   systime intostr dup dup dup strcat strcat strcat 32 strcut pop setseed
   srand abs intostr srand abs intostr srand abs intostr srand abs intostr strcat strcat strcat
;
 
: Do-Connect[ ref:REF -- ]
   VAR STRname VAR STRpass
   GUEST-max_guests 0 = IF
      me @ "^CFAIL^Sorry, but guest logins are off right now." ansi_NOTIFY EXIT
   THEN
   #-1 "*" "PG" find_array array_count 1 - dup GUESTcount ! dup
   GUEST-max_guests dup -1 = IF pop swap pop 0 ELSE > THEN IF
      pop me @ "^CFAIL^Sorry, but there are too many guests logged in right now.  Please try again later." ansi_NOTIFY EXIT
   THEN
   "" Get-Name STRname !
   Get-Pass STRpass !
   me @ 1 USER-clearcom
   REF @ STRname @ STRpass @ CopyPlayer REF !
   prog "/@GuestChars/" doSTRadd @ strcat REF @ setprop
   REF @ "/@GuestNum" doSTRadd @ atoi setprop
   descr REF @ STRpass @ DESCR_SetUser not if
      pop me @ "^CFAIL^GUEST: Failed to login." ansi_notify exit
   then
   REF @ "DARK" flag? if
      REF @ "!DARK" set
   then
   REF @ me !
   REF @ "@Connect" remove_prop
   REF @ "~Connect" remove_prop
   REF @ "_Connect" remove_prop
   REF @ location GUEST-room dbcmp not if
      REF @ GUEST-room moveto
   then
   REF @ location loc !
   1 sleep
   REF @ GUEST-channel GUEST-channel_alias 1 1 USER-addcom pop
   GUEST-room "_Note" array_get_proplist dup array_count if
      FOREACH
         swap pop me @ swap "(@$MultiGuest)" 1 parsempi me @ swap notify
      REPEAT
   then
   REF @ "@Disconnect/MultiGuest" prog setprop
;
 
: Do-Disconnect[ ref:REF -- ]
   REF @ GUEST-channel 1 USER-delcom pop
   REF @ "/@GuestNum" getpropval
   REF @ "/@GuestChars/" rot intostr strcat remove_prop
   GUEST-holder_char_db REF @
   REF @ ok? if
      ToadPlayer
   else
      pop pop
   then
   REF @ ok? if REF @ Recycle then
;
 
: main ( str:Args -- )
   me @ "GUEST" flag? not me @ "M1" flag? or me @ "BUILDER" flag? or if
      exit (* Only do this to GUEST players without BUILDER or M1 [or higher] flags set *)
   then
   "Connect" stringcmp not if
      me @ GUEST-main_guest_db dbcmp not if
         exit (* Only run the connection routine for the main guest character *)
      then
      me @ Do-Connect
   else
      me @ GUEST-main_guest_db dbcmp if
         exit (* We don't *want* the main guest character to run this *)
      then
      me @ Do-Disconnect
   then
;
