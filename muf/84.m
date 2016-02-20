(*
   Lib-Standard v1.01
   by Moose
 
 
   All you have to do is edit this program, and ignore all the rest.
   If you have the versions that support $lib/standard anyway.
 
 
   Works with:
     - Moose's Finger v2.0
     - Moose's +BBoard v3.22
     - Moose's Con-MultiGuest v2.01
     - Moose's Con-Announce v3.14
     - Moose's Lib-ObjEditors v2.11
     - Moose's Lib-IC v1.24
     - Moose's Look v2.10
     - Moose's @Doing v1.01
     - Moose's PutPull v1.0
     - Moose's Whisper v1.23
     - Akari's PlayerEditor v2.30
     - Akari's Find v2.37
     - Akari's Userlist v1.30
     - Akari's Say v2.44
 *)
 
 
$author      Moose
$lib-version 1.01
 
( Player Information: )
 
(**IC FINGER SETTINGS, THEY ARE WHAT THEY SAY**)
$pubdef PROPS-class            "/_Info/IC/Class"
$pubdef PROPS-series           "/_Info/IC/Series"
$pubdef PROPS-shortdesc        "/_Info/IC/Sdesc"
$pubdef PROPS-misc             "/_Info/IC/Misc"
$pubdef PROPS-species          "Species"
$pubdef PROPS-align            "/_Info/IC/Align"
$pubdef PROPS-age              "/_Info/IC/Age"
$pubdef PROPS-birthday         "/_Info/IC/Birthday"
$pubdef PROPS-picture_url      "/_Info/IC/PictureURL"
$pubdef PROPS-full_name        "/_Info/IC/FullName"
$pubdef PROPS-height           "/_Info/IC/Height"
$pubdef PROPS-weight           "/_Info/IC/Weight"
$pubdef PROPS-gender           "sex" (Don't change this! Some MUF prims need it as this!)
 
( Aly's additions.  - Pokemon X)
$pubdef PROPS-morphology       "@rp/pokemorph"
$pubdef PROPS-ICSpeciesNumeric "@rp/pokemon"
 
( Final Fantasy: Dark ages )
$pubdef PROPS-Race             "@rp/race"
$pubdef PROPS-Class            "@rp/class"
$pubdef PROPS-AllpastClasses   "@rp/ProfessionList"
 
 
(**OOC FINGER SETTINGS, THEY ARE WHAT THEY SAY AS WELL**)
$pubdef PROPS-icq_id           "/_Info/Net/ICQ"
$pubdef PROPS-yahoo_id         "/_Info/Net/Yahoo"
$pubdef PROPS-email            "/_Info/Net/Email"
$pubdef PROPS-webpage          "/_Info/Net/URL"
$pubdef PROPS-ooc_full_name    "/_Info/OOC/FullName"
$pubdef PROPS-ooc_elsemu       "/_Info/OOC/ElseMU"
$pubdef PROPS-ooc_gender       "/_Info/OOC/Sex"
$pubdef PROPS-ooc_job          "/_Info/OOC/Job"
$pubdef PROPS-ooc_location     "/_Info/OOC/Location"
$pubdef PROPS-ooc_shortdesc    "/_Info/OOC/ShortDesc"
$pubdef PROPS-ooc_misc         "/_Info/OOC/Misc"
$pubdef PROPS-ooc_age          "/_Info/OOC/Age"
$pubdef PROPS-ooc_birthday     "/_Info/OOC/Birthday"
$pubdef PROPS-ooc_height       "/_Info/OOC/Height"
$pubdef PROPS-ooc_weight       "/_Info/OOC/Weight"
$pubdef PROPS-web_shortinfo    "/_Info/Net/ShortInfo"
$pubdef PROPS-web_icon         "/_Info/Net/Icon"
$pubdef PROPS-web_gallery_pic  "/_Info/Net/Gallery"
 
 
( Player Settings: )
 
 
(**FINGER SETTINGS**)
$pubdef FINGER-type            0 ( 0 = For the new format, 1 = Old format, 2 = Old Format 2)
$pubdef FINGER-sort_type       1 ( 0 = For the new format, 1 = Old format, 2 = Old Format 2)
$pubdef SETTING-block_ooc_info? "/_Prefs/OOC/Block?" (Set to 'yes' to block OOC finger)
(**WATCHFOR SETTINGS**)
$pubdef SETTING-announce_grace 30 (seconds)(Time until show WF on conn)
$pubdef SETTING-announce       "/_Prefs/Con_Announce?"
$pubdef SETTING-announce_fmt   "/_Prefs/Con_Announce_Fmt"
$pubdef SETTING-announce_list  "/_Prefs/Con_Announce_List"
$pubdef SETTING-announce_once  "/_Prefs/Con_Announce_Once"
$pubdef SETTING-announce_hide  "/_Prefs/Con_Announce_Hide"
$pubdef SETTING-announce_allow "/_Prefs/Con_Announce_Allow"
$pubdef SETTING-announce_time  "/@/AnnLITime" (Temp prop for conn time)
(**LOOK SETTINGS**)
$pubdef SETTING-look_notify    "/_Desc_Notify_Looked"
$pubdef SETTING-looker_notify  "/_Desc_Notify_Looker"
$pubdef SETTING-tattle_notify  "/_Desc_Notify_Tattle"
$pubdef SETTING-exit_notify    "/_Exit_Look_notify"
$pubdef SETTING-exit_lookthru  "/_Exit_LookThru"
$pubdef SETTING-exit_shown     "/_Show"
$pubdef SETTING-look_terse     "/_Prefs/Terse?"
$pubdef SETTING-look_lock      "/_/LookLok"
$pubdef SETTING-desc_lock      "/_/DeLok"
$pubdef SETTING-exits_listing  "/_/Ex"
$pubdef SETTING-contents_list  "/_/Co"
$pubdef DefLook                    1 (1 = ProtoLook, 2 = NeonLook, 3 = StandardLook, 4 = Custom Look )
$pubdef DefLookFmt                 "lndsec" (Custom, default format for if any are blank below)
$pubdef DefLookFmt_Thing           "ndec"   (Custom for thing objects)
$pubdef DefLookFmt_Player          "ndc"    (Custom for player objects)
$pubdef DefLookFmt_Program         "nd"     (Custom for program objects)
$pubdef DefLookFmt_Room            "lndsec" (Custom for room objects)
$pubdef DefLookFmt_Exit            "nd"     (Custom for exit objects)
$pubdef DefLookFmt_Fake            "nds"    (Custom for fake objects)
$pubdef LOOK-pref_look_stnd?       "/_Prefs/LookStandard"
$pubdef LOOK-pref_look_stnd_me?    "/_Prefs/LookStandard/Def"
$pubdef LOOK-pref_force_fmt?       "/_Prefs/LookFmt/Def/ForceFmt?"
$pubdef LOOK-pref_look_fmt         "/_Prefs/LookFmt"
$pubdef LOOK-pref_look_thing_fmt   "/_Prefs/LookFmt/Thing"
$pubdef LOOK-pref_look_player_fmt  "/_Prefs/LookFmt/Player"
$pubdef LOOK-pref_look_program_fmt "/_Prefs/LookFmt/Program"
$pubdef LOOK-pref_look_room_fmt    "/_Prefs/LookFmt/Room"
$pubdef LOOK-pref_look_exit_fmt    "/_Prefs/LookFmt/Exit"
$pubdef LOOK-pref_look_fake_fmt    "/_Prefs/LookFmt/Fake"
$pubdef LOOK-pref_look_fmt_me      "/_Prefs/LookFmt/Def/Def"
$pubdef LOOK-pref_look_thing_fmt_me "/_Prefs/LookFmt/Def/Thing"
$pubdef LOOK-pref_look_player_fmt_me "/_Prefs/LookFmt/Def/Player"
$pubdef LOOK-pref_look_program_fmt_me "/_Prefs/LookFmt/Def/Program"
$pubdef LOOK-pref_look_room_fmt_me "/_Prefs/LookFmt/Def/Room"
$pubdef LOOK-pref_look_exit_fmt_me "/_Prefs/LookFmt/Def/Exit"
$pubdef LOOK-pref_look_fake_fmt_me "/_Prefs/LookFmt/Def/Fake"
$pubdef LOOK-pref_parse_exclude    "/_Prefs/ParseExclude"
$pubdef LOOK-pref_dark_sleepers?   "/_Prefs/Dark_Sleepers?"
$pubdef LOOK-pref_internal_exits? "/_InternalExits?"
$pubdef LOOK-pref_contents?       "/_Contents?"
$pubdef LOOK-propqueue            "/_LookQ"
(**@DOING PROP FOR HEAVYROTATION**)
$pubdef PROPS-heavyrotation    "/@/Do"
 
 
( IC/OOC Settings: )
 
 
$pubdef PROPS-icooc            "~status" (Prop for IC/OOC/AFK setting)
$pubdef ICOOC-ICvalue          "IC"  (Set to for IC)
$pubdef ICOOC-OOCvalue         "OOC"   (Set to for OOC)
$pubdef ICOOC-AFKvalue         "AFK"  (Set to for AFK)
$pubdef ICOOC-nullvalue?       0 ( 1 = IC, 0 = OOC, -1 = AFK )
$pubdef ICOOC-defvalue?        0 ( 1 = IC, 0 = OOC, -1 = AFK )
$pubdef ICOOC-envicoocprop?    0 ( 1 = If prop found, is IC. 0 = Don't use envprop )
$pubdef ICOOC-room-ic          #206 ( Room to go to when going IC, #-1 for none )
$pubdef ICOOC-room-ooc         #42 ( Room to go to when going OOC, #-1 for none )
$pubdef ICOOC-prop-ic          "/@rp/lasticloc"  ( Last room in from when IC, blank for none )
$pubdef ICOOC-prop-ooc         "/@rp/lastoocloc"  ( Last room in from when OOC, blank for none )
$pubdef ICOOC-forceicprop      "/~prefs/RoomIC?" (Force players IC/OOC/AFK in rooms or down environment)
$pubdef ICOOC-forceoocprop     "/~prefs/OOC" (Force players OOC down environment if set 'yes')
$pubdef ICOOC-approveprop      "/@rp/valid?" (The prop used for if ICapprove is on, 'yes' if allowed for IC)
$def    ICOOC-MultiCmd         ($undef this if you don't want players to be able to run IC when IC, etc)
$def    ICOOC-ICapprove        ($def this is you want players to be approved before going IC)
 
 
( Object Settings: )
 
 
$pubdef PROPS-publicroom?      "/_Prefs/Public?"
$pubdef PROPS-privateroom?     "/_Prefs/Private?"
 
 
( Container Settings: )
 
 
$pubdef PROPS-container?       "/_Container?"
$pubdef PROPS-container_db     "/_Prefs/Container" (Points to another ref for the container)
$pubdef PROPS-pull             "/Pull" (oprop for pull messages)
$pubdef PROPS-put              "/Put"  (oprop for put messages)
$pubdef MESG-pull              "You pull %t from %c."
$pubdef MESG-opull             "pulls %t from %c."
$pubdef MESG-put               "You put %t into %c"
$pubdef MESG-oput              "puts %t into %c."
$undef  Hold-Container? (def this if you want the player holding that container before using it)
 
 
( Communication Settings: )
 
 
$pubdef SAY-fmt_say            "^%1^%n says, ^%3^\"^%2^%m"
$pubdef SAY-fmt_ask            "^%1^%n asks, ^%3^\"^%2^%m"
$pubdef SAY-fmt_exclaim        "^%1^%n exclaims, ^%3^\"^%2^%m"
$pubdef SAY-fmt_break          "^%3^\"^%2^%m1^%3^\" ^%1^says %n, ^%3^\"^%2^%m^%3^\""
$pubdef SAY-fmt_ponder         "^%1^%n ^%3^. o O ( ^%2^%m ^%3^)"
$pubdef SAY-fmt_sing           "^%1^%n sings o/~ ^%2^%m ^%1^o/~"
$pubdef SAY-fmt_sayto          "[to %X] "
$pubdef PROPS-say_filter       "/_Prefs/SayFilter"
$pubdef SAY-color_pose1        "CYAN"
$pubdef SAY-color_pose2        "GREEN"
$pubdef SAY-color_say1         "YELLOW"
$pubdef SAY-color_say2         "WHITE"
$pubdef SAY-color_quotes1      "PURPLE"
$pubdef SAY-color_quotes2      "YELLOW"
$pubdef PAGE-maildir           "/_Page/@Mail#"
$pubdef FIND-colors_room       "WHITE"
$pubdef FIND-colors_frame      "BLUE"
$pubdef FIND-colors_player     "WHITE"
$pubdef FIND-colors_parents    "WHITE"
$pubdef FIND-colors_time       "WHITE"
$pubdef MUMBLE-blockchance     64 (% chance of blocking char)
 
 
( Guest Settings: )
 
 
  (*\/ This is the name for the newbie/guest channel \/*)
$pubdef GUEST-channel          "Public"
  (*\/This is the alias listing for the channel \/*)
$pubdef GUEST-channel_alias    "pub;]"
  (*\/ This is the name of the holder character for objects when ToadPlayer is used \/*)
$pubdef GUEST-holder_character "Builder_Wiz"
  (*\/ This is the name for the main guest character \/*)
$pubdef GUEST-main_guest       "Guest"
  (*\/ Add this before the number. Can be blank. \/*)
$pubdef GUEST-str_addon        ""
  (*\/ 0 = no start, or another number to start there \/*)
$pubdef GUEST-addon?           1
  (*\/ 1 = Prepend str-addon, or 0 = to append it \/*)
$pubdef GUEST-prepend_addon?   0
  (*\/ 0 = no add count for each guest, 1 = to count number of guests \/*)
$pubdef GUEST-addcount?        1
$pubdef GUEST-holder_char_db   "*" GUEST-holder_character strcat match
$pubdef GUEST-main_guest_db    "*" GUEST-main_guest strcat match
  (*\/ This is the dbref for the main guest room \/*)
$pubdef GUEST-room             GUEST-main_guest_db getlink
$pubdef GUEST-names_list       "_Names"
$pubdef GUEST-max_guests       -1
 
 
( +BBoard Settings: )
 
 
  (* Miscellaneous Definitions *)
$pubdef DEF-CheckWait            1 (* Seconds b/f +bbscan  *)
$pubdef DEF-AutoTimeoutWait  86400 (* Time til autotimeout *)
  (* DEFAULT PROPERTIES *)
  (-- Base Board --)
$pubdef BB-Board       "$Cmd/+BBoard" match (* +BBoard info obj     *)
$pubdef BB-BoardDir    "@Boards/Num/%n/"  (* Board dir %n=bbnum   *)
$pubdef BB-NamePath    "@Boards/Names/"   (* Board names dir      *)
$pubdef BB-Count       "@Boards"          (* Number of boards     *)
$pubdef BB-Unread?     "@Boards/UnRead?"  (* Scan unread msgs     *)
$pubdef BB-DefTimeout  "@Boards/DefTM?"   (* Default timeout days *)
$pubdef BB-PCreate?    "@Boards/PCreate"  (* Player create bboard *)
$pubdef BB-AutoDel?    "@Boards/AutoDel"  (* Autotimeout delete   *)
$pubdef BB-LastTimeout "@Boards/LTimeOT"  (* Last autotimeout ran *)
  (-- Off Of Board Directory --)
$pubdef BB-Exist?      "Exist?"           (* Board exist yes/no   *)
$pubdef BB-LastPost    "LastPost"         (* Last post date       *)
$pubdef BB-Name        "Name"             (* Board name           *)
$pubdef BB-BoardNum    "Num"              (* Board number         *)
$pubdef BB-NumMsgs     "NumMsgs"          (* Number of real msgs  *)
$pubdef BB-Owner       "Owner"            (* Dbref of bb owner    *)
$pubdef BB-ReadOnly?   "ReadOnly?"        (* Read only yes/no     *)
$pubdef BB-Restricted? "Restricted?"      (* Restricted yes/no    *)
$pubdef BB-Timeout     "Timeout"          (* Msg timeout in days  *)
$pubdef BB-WWWRead     "WWWRead?"         (* WWW Read yes/no      *)
$pubdef BB-GuestPost?  "GuestPost?"       (* Guests post? yes/no  *)
$pubdef BB-MsgNums     "Mesgs/"           (* Message num dir      *)
$pubdef BB-FakeNumMsgs "Mesgs"            (* Number of msgs       *)
$pubdef BB-RealMsgDir  "Msgs/%n/"         (* Real msg dir %n=mnum *)
$pubdef BB-ChownOk?    "ChownOk?"         (* Set to player dbrefok*)
$pubdef BB-NoCatchUp?  "NoCatchUp?"       (* No catchup/bbnotify  *)
$pubdef BB-UserDir     "User"             (* User dir -/          *)
$pubdef BB-Allow       "Allow"            (* Allowed users dir-/  *)
$pubdef BB-AllowMPI    "AllowMPI"         (* Allowed MPI lock     *)
$pubdef BB-AllowProp   "AllowProp"        (* Prop for allows      *)
$pubdef BB-AllowPost   "AllowPost"        (* Allow posters dir-/  *)
$pubdef BB-AllowPostMPI "AllowPostMPI"    (* Allow posters MPI    *)
$pubdef BB-PosterProp  "AllowPostProp"    (* Allow posters prop   *)
$pubdef BB-AutoSub?    "AutoSubscribe?"   (* Autosubscribe bol    *)
$pubdef BB-Notify      "BBNotify/"        (* BB-Notify dir        *)
$pubdef BB-GuestRead?  "GuestUnRead?"     (* Show Guest Posts     *)
$pubdef BB-Anonymous   "Poster"           (* Anonymous postername *)
  (-- Off Of Real Message Directory --)
$pubdef BBM-Exist?     "Exist?"           (* Message exist yes/no *)
$pubdef BBM-MsgNum     "Num"              (* Message number       *)
$pubdef BBM-Poster     "PostedBy"         (* Message posted by    *)
$pubdef BBM-Date       "PostedOn"         (* Message posted on    *)
$pubdef BBM-Subject    "Subject"          (* Message subject      *)
$pubdef BBM-Msg        "Msg"              (* Message list dir-#/  *)
$pubdef BBM-UserDir    "User/"            (* User dir +/          *)
$pubdef BBM-TimeOut    "Timeout"          (* Message timeout      *)
$pubdef BBM-Protected? "Protect?"         (* Message protect bol? *)
$pubdef BBM-Urgent?    "Urgent?"          (* Message is urgent?   *)
  (-- Off Of Player --)
$pubdef BBP-Signature  "BB_SIG"           (* Message Signature    *)
$pubdef BBP-PauseLines "_Prefs/TRange"    (* Num lines for pause  *)
  (-- Off Of Trigger/Action --)
$pubdef BBT-Object     "_BBoard"          (* Points To BBoard Obj *)
 (--> Default = BB-Board )
$pubdef BBT-MsgGrp     "_Group"           (* Only use group #     *)
 (--> Default = 0       [if it is 0 or blank, then it allows all groups]  )
  (* Default Settings *)
  (-- For Webserver --)
$pubdef BBW-LookUpLoc "/DoLookUp"    (* Location of the user lookup command *)
$pubdef BBW-BBoardLoc "/BBoard"      (* Location of the +BBoard command     *)
$pubdef BBW-Body "<BODY BGCOLOR=\"#000000\" TEXT=\"#FFFFFF\" link=\"#0000FF\" vlink=\"#0000FF\" alink=\"#008080\">"
 
 
( Other Settings: )
 
 
$pubdef WWW_support?           1
( ** Change the following value to 0 if you do not want to allow    )
( \/ players to @paste remotely to rooms they do not own. **     \/ )
$pubdef PASTE_allow_remote?    1
 
 
(*** DO NOT CHANGE THE BELOW STUFF ***)
 
 
$ifdef ICOOC-MultiCmd
   $pubdef ICOOC-MultiCmd 1
$else
   $pubdef ICOOC-MultiCmd
$endif
$ifdef ICOOC-ICapprove
   $pubdef ICOOC-ICapprove 1
$else
   $pubdef ICOOC-ICapprove
$endif
 
 
$ifdef Hold-Container?
   $pubdef Hold-Container? 1
$else
   $pubdef Hold-Container?
$endif
 
 
$pubdef PROPS-shortinfo_list   PROPS-web_shortinfo
 
 
( Null Function: )
 
 
: nofunc
   0 pop
;
