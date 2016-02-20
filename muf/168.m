( wizmatch.MAC  --  3/9/93  by Squirrelly )
 
 
: wizmatch  ( s -- d )
    dup "#[-0-9]*" smatch if
        1 strcut swap pop atoi dbref
        exit
    then
    dup "\\*?*" smatch if
        1 strcut swap pop .pmatch
        exit
    then
    dup not if pop "here" then
    match
;
