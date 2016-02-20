(*
   MPI-staff.MUF
   by Moose
 
   Type the following, replacing <this program>
   with this programs dbref:
 
   @register <this program>=MPI/Staff
   @set #0=/_MsgMacs/staff?:{muf:$mpi/staff,staff\,{:0}}
   @set #0=/_MsgMacs/!staff?:{muf:$mpi/staff,!staff\,{:0}}
   @set #0=/_MsgMacs/wiz?:{muf:$mpi/staff,wiz\,{:0}}
   @set #0=/_MsgMacs/!wiz?:{muf:$mpi/staff,!wiz\,{:0}}
   @set #0=/_MsgMacs/!arch?:{muf:$mpi/staff,!arch\,{:0}}
   @set #0=/_MsgMacs/!boy?:{muf:$mpi/staff,!boy\,{:0}}
 
   MPI Functions:
      {staff?:<dbref>}
        This checks if someone has the STAFF power or is a W1 or higher.
      {!staff?:<dbref>}
        This checks if someone has the STAFF power, only.
      {wiz?:<dbref>}
        This checks if someone is a W1 or higher.
      {!wiz?:<dbref>}
        This checks if someone is a W2 or higher.
      {!arch?:<dbref>}
        This checks if someone is a W3 or higher.
      {!boy?:<dbref>}
        This checks if someone is a W4.
 *)
 
$author  Moose
$version 1.0
 
$def isit? stringcmp not
 
: MPI-staff
   "," split
   dup "me" isit? IF
      dup stod dup Ok? not IF
         pop pmatch
      ELSE
         swap pop
      THEN
   ELSE
      pop me @
   THEN
   dup Ok? not IF
      swap pop
      #-2 dbcmp IF
         "I don't know which player you mean!" abort
      ELSE
         "I cannot find that player." abort
      THEN
   THEN
   swap CASE
      "STAFF" isit? WHEN
         dup "STAFF" Power?
         swap "W1" Flag? or
      END
      "!STAFF" isit? WHEN
         "STAFF" Power?
      END
      "WIZ" isit? WHEN
         "W1" Flag?
      END
      "!WIZ" isit? WHEN
         "W2" Flag?
      END
      "!ARCH" isit? WHEN
         "W3" Flag?
      END
      "!BOY" isit? WHEN
         "BOY" Flag?
      END
      DEFAULT
         "{" swap strcat "?:} is not a proper MPI function.  Please notify the admin" strcat abort
      END
   ENDCASE
   IF
      "yes"
   ELSE
      "no"
   THEN
;
