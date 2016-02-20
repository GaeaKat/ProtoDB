( Lib-CGI v2.2 - Assembled by Akari                                )
( v2.2: [Akari] Shortened the instruction count for a number of    )
(               functions using the new CGI parsing prims by       )
(               Hinoserm.                                          )
(               Functions affected: PARSECGI, HEXCONVERT, encodeURL)
(                                   b16_to_b10                     )
( v2.1: [Akari] Fixed ENCODEURL function to correctly handle %     )
( v2.0: [Akari] Added URLENCODE and POST-DECODE                    )
( v1.7: [Moose] Added a striptail after HTML2TEXT                  )
( v1.6: Moved rgb.txt to a dictionary for better <font> colours    )
( v1.5: array_nukecgi, HTMLfix, TEXT2HTML, and HTML2TEXT [by Moose])
(                                                                  )
( This is a library of functions designed to help with HTMuf       )
( project without having to use global _defs/ to accomplish most   )
( of the things you would want to get done.                        )
( Also containes a variety of string formatting routines needed for)
( dealing with MUF CGI.                                            )
(                                                                  )
( Install and register as $lib/cgi. Include this program in older  )
(   NeonMUCK Web programs to replace the $defs that used to be on  )
(   #0 in NeonMUCK.                                                )
( Requires $lib/strings version 1.5 or newer.                      )
( b16_to_b10 and hexconvert functions by Cutey_Honey@Phoenix       )
( parsecgi, nukecgi, readcgi by Loki                               )
( To make your HTMuf writing life easier, always create global     )
( variables 'descr' 'host' 'user' 'params'                         )
( Have 'parseweb' run on the initial arguement on the stack to     )
( place everything in its appropriate variable.                    )
( 'descr' is the descriptor you are to write the HTML out to using )
( 'notify_descriptor'                                              )
( 'host' is a string with the host name in it.                     )
( 'user' is a string with just the user id of the connection       )
( 'params' is a string containing all of the CGI arguements that   )
(          would appear in the URL after the ? mark. Example:      )
(          http://tnt.maison-otaku.net:1863/dolookup?user=akari    )
(          parms would end up with 'user=akari' as its contents.   )
(          Seperate input fields are seperated by & marks. Example:)
(          user=akari&series=last+blade                            )
(                                                                  )
( b16_to_b10 converts part of a hex number to decimal <s -- i >    )
( hexconvert converts a full hex number to decimal < s -- i >      )
( parsecgi cleans up and parses all the cgi in a string < s -- s > )
( nukecgi breaks the full cgi string into seperate fields <s -- s >)
( array_nukecgi and arrnukecgi grabs all CGI statements and places )
(         the name and return string in a dictionary < s -- dict > )
( readcgi will return the arguement of a field defined by the s2   )
(         passed to it. < s1 s2 -- s3 > For example:               )
(    "user=akari&series=last+blade" "series" readcgi would return  )
(    "last blade"                                                  )
( HTMLfix fixes the formating of a string by replacing the spaces  )
(         with &#32; and \r with <BR>.   < s1 -- s2 >              )
( TEXT2HTML converts a normal text string to being displayable in  )
(           HTML code. < s1 -- s2 >                                )
( HTML2TEXT converts an html string to being displayable in an     )
(           ansi string using ^COLOR^ ansi codes. < s1 -- s2 >     )
( ENCODEURL Converts a regular string to a legitimately encoded URL)
(           <s1 -- s2>                                             )
( POST-DECODE Accepts an array of strings read in from a post      )
(           method and breaks them into an array of CGI decoded    )
(           strings. <arr1 -- arr2>                                )
 
 
$author Akari Moose Cutey_Honey Nodaitsu
$version 2.2
$lib-version 2.1
$include $lib/strings (* Requires v1.5+ --Proto version *)
 
 
: b16_to_b10 ( s<4-Bit Unsigned Hex> -- i<4-Bit Unsigned Integer> )
    htoi
;
 
 
: hexconvert ( str:hex -- int:num )
    htoi
; 
 
 
: parsecgi ( s -- s' )
    unescape_url
;
 
 
: nukecgi ( cgistring -- s1 .. sn n )
  "&MUFSPLIT&" "&" subst
  parsecgi
  "&MUFSPLIT&" explode
;
: array_nukecgi ( str:cgistring -- dict:DICTcgistrings )
   { }dict swap "&" explode_array
   FOREACH
      swap pop dup not if
         pop CONTINUE
      then
      "=" split parsecgi rot rot parsecgi array_setitem
   REPEAT
;
: readcgi (cgistring property -- result)
  "=" strcat over over instring
  dup not if pop pop pop "" exit then
  1 - swap pop strcut swap pop
  "&" explode
  lreverse 1 - popn
  dup "=" instr strcut swap pop
  parsecgi
;
: HTMLfixline ( str:HTML -- str:HTML' )
   0 VAR! idx
   "" swap
   BEGIN
      idx ++ dup " " instr WHILE
      " " split rot rot strcat " " strcat swap
      dup " " instr 1 = if
         1 strcut swap pop swap "&#32;" strcat swap
      then
   REPEAT
   strcat
;
: HTMLfix ( str:HTML -- str:HTML' )
   "" swap
   BEGIN
      dup "<" instr if
         "<" split rot rot strcat "<" strcat swap dup ">" instr if
            ">" split rot rot strcat ">" strcat swap dup "<" instr if
               "<" split rot rot HTMLfixline strcat "<" rot strcat
            else
               HTMLfixline strcat BREAK
            then
         else
            strcat ">" strcat BREAK
         then
      else
         HTMLfixline strcat BREAK
      then
   REPEAT
;
VAR ARRlastcolor
VAR ARRjustify
VAR INcode?
VAR DICTcolorlist
                 ( RRR GGG BBB )
$def RGB-GLOOM      80  80  80
$def RGB-CRIMSON    80   0   0
$def RGB-FOREST      0  80   0
$def RGB-BROWN      80  80   0
$def RGB-NAVY        0   0  80
$def RGB-VIOLET     80   0  80
$def RGB-AQUA        0  80  80
$def RGB-GRAY      192 192 192
$def RGB-BLACK       0   0   0
$def RGB-RED       256   0   0
$def RGB-GREEN       0 256   0
$def RGB-YELLOW    256 256   0
$def RGB-BLUE        0   0 256
$def RGB-PURPLE    256   0 256
$def RGB-CYAN        0 256 256
$def RGB-WHITE     256 256 256
: LoadColorList[ -- ]
   { }dict
   { 255 250 250 }list "snow" rot swap array_setitem
   { 248 248 255 }list "ghost white" rot swap array_setitem
   { 248 248 255 }list "GhostWhite" rot swap array_setitem
   { 245 245 245 }list "white smoke" rot swap array_setitem
   { 245 245 245 }list "WhiteSmoke" rot swap array_setitem
   { 220 220 220 }list "gainsboro" rot swap array_setitem
   { 255 250 240 }list "floral white" rot swap array_setitem
   { 255 250 240 }list "FloralWhite" rot swap array_setitem
   { 253 245 230 }list "old lace" rot swap array_setitem
   { 253 245 230 }list "OldLace" rot swap array_setitem
   { 250 240 230 }list "linen" rot swap array_setitem
   { 250 235 215 }list "antique white" rot swap array_setitem
   { 250 235 215 }list "AntiqueWhite" rot swap array_setitem
   { 255 239 213 }list "papaya whip" rot swap array_setitem
   { 255 239 213 }list "PapayaWhip" rot swap array_setitem
   { 255 235 205 }list "blanched almond" rot swap array_setitem
   { 255 235 205 }list "BlanchedAlmond" rot swap array_setitem
   { 255 228 196 }list "bisque" rot swap array_setitem
   { 255 218 185 }list "peach puff" rot swap array_setitem
   { 255 218 185 }list "PeachPuff" rot swap array_setitem
   { 255 222 173 }list "navajo white" rot swap array_setitem
   { 255 222 173 }list "NavajoWhite" rot swap array_setitem
   { 255 228 181 }list "moccasin" rot swap array_setitem
   { 255 248 220 }list "cornsilk" rot swap array_setitem
   { 255 255 240 }list "ivory" rot swap array_setitem
   { 255 250 205 }list "lemon chiffon" rot swap array_setitem
   { 255 250 205 }list "LemonChiffon" rot swap array_setitem
   { 255 245 238 }list "seashell" rot swap array_setitem
   { 240 255 240 }list "honeydew" rot swap array_setitem
   { 245 255 250 }list "mint cream" rot swap array_setitem
   { 245 255 250 }list "MintCream" rot swap array_setitem
   { 240 255 255 }list "azure" rot swap array_setitem
   { 240 248 255 }list "alice blue" rot swap array_setitem
   { 240 248 255 }list "AliceBlue" rot swap array_setitem
   { 230 230 250 }list "lavender" rot swap array_setitem
   { 255 240 245 }list "lavender blush" rot swap array_setitem
   { 255 240 245 }list "LavenderBlush" rot swap array_setitem
   { 255 228 225 }list "misty rose" rot swap array_setitem
   { 255 228 225 }list "MistyRose" rot swap array_setitem
   { 255 255 255 }list "white" rot swap array_setitem
   { 0 0 0 }list "black" rot swap array_setitem
   { 47 79 79 }list "dark slate gray" rot swap array_setitem
   { 47 79 79 }list "DarkSlateGray" rot swap array_setitem
   { 47 79 79 }list "dark slate grey" rot swap array_setitem
   { 47 79 79 }list "DarkSlateGrey" rot swap array_setitem
   { 105 105 105 }list "dim gray" rot swap array_setitem
   { 105 105 105 }list "DimGray" rot swap array_setitem
   { 105 105 105 }list "dim grey" rot swap array_setitem
   { 105 105 105 }list "DimGrey" rot swap array_setitem
   { 112 128 144 }list "slate gray" rot swap array_setitem
   { 112 128 144 }list "SlateGray" rot swap array_setitem
   { 112 128 144 }list "slate grey" rot swap array_setitem
   { 112 128 144 }list "SlateGrey" rot swap array_setitem
   { 119 136 153 }list "light slate gray" rot swap array_setitem
   { 119 136 153 }list "LightSlateGray" rot swap array_setitem
   { 119 136 153 }list "light slate grey" rot swap array_setitem
   { 119 136 153 }list "LightSlateGrey" rot swap array_setitem
   { 190 190 190 }list "gray" rot swap array_setitem
   { 190 190 190 }list "grey" rot swap array_setitem
   { 211 211 211 }list "light grey" rot swap array_setitem
   { 211 211 211 }list "LightGrey" rot swap array_setitem
   { 211 211 211 }list "light gray" rot swap array_setitem
   { 211 211 211 }list "LightGray" rot swap array_setitem
   { 25 25 112 }list "midnight blue" rot swap array_setitem
   { 25 25 112 }list "MidnightBlue" rot swap array_setitem
   { 0 0 128 }list "navy" rot swap array_setitem
   { 0 0 128 }list "navy blue" rot swap array_setitem
   { 0 0 128 }list "NavyBlue" rot swap array_setitem
   { 100 149 237 }list "cornflower blue" rot swap array_setitem
   { 100 149 237 }list "CornflowerBlue" rot swap array_setitem
   { 72 61 139 }list "dark slate blue" rot swap array_setitem
   { 72 61 139 }list "DarkSlateBlue" rot swap array_setitem
   { 106 90 205 }list "slate blue" rot swap array_setitem
   { 106 90 205 }list "SlateBlue" rot swap array_setitem
   { 123 104 238 }list "medium slate blue" rot swap array_setitem
   { 123 104 238 }list "MediumSlateBlue" rot swap array_setitem
   { 132 112 255 }list "light slate blue" rot swap array_setitem
   { 132 112 255 }list "LightSlateBlue" rot swap array_setitem
   { 0 0 205 }list "medium blue" rot swap array_setitem
   { 0 0 205 }list "MediumBlue" rot swap array_setitem
   { 65 105 225 }list "royal blue" rot swap array_setitem
   { 65 105 225 }list "RoyalBlue" rot swap array_setitem
   { 0 0 255 }list "blue" rot swap array_setitem
   { 30 144 255 }list "dodger blue" rot swap array_setitem
   { 30 144 255 }list "DodgerBlue" rot swap array_setitem
   { 0 191 255 }list "deep sky blue" rot swap array_setitem
   { 0 191 255 }list "DeepSkyBlue" rot swap array_setitem
   { 135 206 235 }list "sky blue" rot swap array_setitem
   { 135 206 235 }list "SkyBlue" rot swap array_setitem
   { 135 206 250 }list "light sky blue" rot swap array_setitem
   { 135 206 250 }list "LightSkyBlue" rot swap array_setitem
   { 70 130 180 }list "steel blue" rot swap array_setitem
   { 70 130 180 }list "SteelBlue" rot swap array_setitem
   { 176 196 222 }list "light steel blue" rot swap array_setitem
   { 176 196 222 }list "LightSteelBlue" rot swap array_setitem
   { 173 216 230 }list "light blue" rot swap array_setitem
   { 173 216 230 }list "LightBlue" rot swap array_setitem
   { 176 224 230 }list "powder blue" rot swap array_setitem
   { 176 224 230 }list "PowderBlue" rot swap array_setitem
   { 175 238 238 }list "pale turquoise" rot swap array_setitem
   { 175 238 238 }list "PaleTurquoise" rot swap array_setitem
   { 0 206 209 }list "dark turquoise" rot swap array_setitem
   { 0 206 209 }list "DarkTurquoise" rot swap array_setitem
   { 72 209 204 }list "medium turquoise" rot swap array_setitem
   { 72 209 204 }list "MediumTurquoise" rot swap array_setitem
   { 64 224 208 }list "turquoise" rot swap array_setitem
   { 0 255 255 }list "cyan" rot swap array_setitem
   { 224 255 255 }list "light cyan" rot swap array_setitem
   { 224 255 255 }list "LightCyan" rot swap array_setitem
   { 95 158 160 }list "cadet blue" rot swap array_setitem
   { 95 158 160 }list "CadetBlue" rot swap array_setitem
   { 102 205 170 }list "medium aquamarine" rot swap array_setitem
   { 102 205 170 }list "MediumAquamarine" rot swap array_setitem
   { 127 255 212 }list "aquamarine" rot swap array_setitem
   { 0 100 0 }list "dark green" rot swap array_setitem
   { 0 100 0 }list "DarkGreen" rot swap array_setitem
   { 85 107 47 }list "dark olive green" rot swap array_setitem
   { 85 107 47 }list "DarkOliveGreen" rot swap array_setitem
   { 143 188 143 }list "dark sea green" rot swap array_setitem
   { 143 188 143 }list "DarkSeaGreen" rot swap array_setitem
   { 46 139 87 }list "sea green" rot swap array_setitem
   { 46 139 87 }list "SeaGreen" rot swap array_setitem
   { 60 179 113 }list "medium sea green" rot swap array_setitem
   { 60 179 113 }list "MediumSeaGreen" rot swap array_setitem
   { 32 178 170 }list "light sea green" rot swap array_setitem
   { 32 178 170 }list "LightSeaGreen" rot swap array_setitem
   { 152 251 152 }list "pale green" rot swap array_setitem
   { 152 251 152 }list "PaleGreen" rot swap array_setitem
   { 0 255 127 }list "spring green" rot swap array_setitem
   { 0 255 127 }list "SpringGreen" rot swap array_setitem
   { 124 252 0 }list "lawn green" rot swap array_setitem
   { 124 252 0 }list "LawnGreen" rot swap array_setitem
   { 0 255 0 }list "green" rot swap array_setitem
   { 127 255 0 }list "chartreuse" rot swap array_setitem
   { 0 250 154 }list "medium spring green" rot swap array_setitem
   { 0 250 154 }list "MediumSpringGreen" rot swap array_setitem
   { 173 255 47 }list "green yellow" rot swap array_setitem
   { 173 255 47 }list "GreenYellow" rot swap array_setitem
   { 50 205 50 }list "lime green" rot swap array_setitem
   { 50 205 50 }list "LimeGreen" rot swap array_setitem
   { 154 205 50 }list "yellow green" rot swap array_setitem
   { 154 205 50 }list "YellowGreen" rot swap array_setitem
   { 34 139 34 }list "forest green" rot swap array_setitem
   { 34 139 34 }list "ForestGreen" rot swap array_setitem
   { 107 142 35 }list "olive drab" rot swap array_setitem
   { 107 142 35 }list "OliveDrab" rot swap array_setitem
   { 189 183 107 }list "dark khaki" rot swap array_setitem
   { 189 183 107 }list "DarkKhaki" rot swap array_setitem
   { 240 230 140 }list "khaki" rot swap array_setitem
   { 238 232 170 }list "pale goldenrod" rot swap array_setitem
   { 238 232 170 }list "PaleGoldenrod" rot swap array_setitem
   { 250 250 210 }list "light goldenrod yellow" rot swap array_setitem
   { 250 250 210 }list "LightGoldenrodYellow" rot swap array_setitem
   { 255 255 224 }list "light yellow" rot swap array_setitem
   { 255 255 224 }list "LightYellow" rot swap array_setitem
   { 255 255 0 }list "yellow" rot swap array_setitem
   { 255 215 0 }list "gold" rot swap array_setitem
   { 238 221 130 }list "light goldenrod" rot swap array_setitem
   { 238 221 130 }list "LightGoldenrod" rot swap array_setitem
   { 218 165 32 }list "goldenrod" rot swap array_setitem
   { 184 134 11 }list "dark goldenrod" rot swap array_setitem
   { 184 134 11 }list "DarkGoldenrod" rot swap array_setitem
   { 188 143 143 }list "rosy brown" rot swap array_setitem
   { 188 143 143 }list "RosyBrown" rot swap array_setitem
   { 205 92 92 }list "indian red" rot swap array_setitem
   { 205 92 92 }list "IndianRed" rot swap array_setitem
   { 139 69 19 }list "saddle brown" rot swap array_setitem
   { 139 69 19 }list "SaddleBrown" rot swap array_setitem
   { 160 82 45 }list "sienna" rot swap array_setitem
   { 205 133 63 }list "peru" rot swap array_setitem
   { 222 184 135 }list "burlywood" rot swap array_setitem
   { 245 245 220 }list "beige" rot swap array_setitem
   { 245 222 179 }list "wheat" rot swap array_setitem
   { 244 164 96 }list "sandy brown" rot swap array_setitem
   { 244 164 96 }list "SandyBrown" rot swap array_setitem
   { 210 180 140 }list "tan" rot swap array_setitem
   { 210 105 30 }list "chocolate" rot swap array_setitem
   { 178 34 34 }list "firebrick" rot swap array_setitem
   { 165 42 42 }list "brown" rot swap array_setitem
   { 233 150 122 }list "dark salmon" rot swap array_setitem
   { 233 150 122 }list "DarkSalmon" rot swap array_setitem
   { 250 128 114 }list "salmon" rot swap array_setitem
   { 255 160 122 }list "light salmon" rot swap array_setitem
   { 255 160 122 }list "LightSalmon" rot swap array_setitem
   { 255 165 0 }list "orange" rot swap array_setitem
   { 255 140 0 }list "dark orange" rot swap array_setitem
   { 255 140 0 }list "DarkOrange" rot swap array_setitem
   { 255 127 80 }list "coral" rot swap array_setitem
   { 240 128 128 }list "light coral" rot swap array_setitem
   { 240 128 128 }list "LightCoral" rot swap array_setitem
   { 255 99 71 }list "tomato" rot swap array_setitem
   { 255 69 0 }list "orange red" rot swap array_setitem
   { 255 69 0 }list "OrangeRed" rot swap array_setitem
   { 255 0 0 }list "red" rot swap array_setitem
   { 255 105 180 }list "hot pink" rot swap array_setitem
   { 255 105 180 }list "HotPink" rot swap array_setitem
   { 255 20 147 }list "deep pink" rot swap array_setitem
   { 255 20 147 }list "DeepPink" rot swap array_setitem
   { 255 192 203 }list "pink" rot swap array_setitem
   { 255 182 193 }list "light pink" rot swap array_setitem
   { 255 182 193 }list "LightPink" rot swap array_setitem
   { 219 112 147 }list "pale violet red" rot swap array_setitem
   { 219 112 147 }list "PaleVioletRed" rot swap array_setitem
   { 176 48 96 }list "maroon" rot swap array_setitem
   { 199 21 133 }list "medium violet red" rot swap array_setitem
   { 199 21 133 }list "MediumVioletRed" rot swap array_setitem
   { 208 32 144 }list "violet red" rot swap array_setitem
   { 208 32 144 }list "VioletRed" rot swap array_setitem
   { 255 0 255 }list "magenta" rot swap array_setitem
   { 238 130 238 }list "violet" rot swap array_setitem
   { 221 160 221 }list "plum" rot swap array_setitem
   { 218 112 214 }list "orchid" rot swap array_setitem
   { 186 85 211 }list "medium orchid" rot swap array_setitem
   { 186 85 211 }list "MediumOrchid" rot swap array_setitem
   { 153 50 204 }list "dark orchid" rot swap array_setitem
   { 153 50 204 }list "DarkOrchid" rot swap array_setitem
   { 148 0 211 }list "dark violet" rot swap array_setitem
   { 148 0 211 }list "DarkViolet" rot swap array_setitem
   { 138 43 226 }list "blue violet" rot swap array_setitem
   { 138 43 226 }list "BlueViolet" rot swap array_setitem
   { 160 32 240 }list "purple" rot swap array_setitem
   { 147 112 219 }list "medium purple" rot swap array_setitem
   { 147 112 219 }list "MediumPurple" rot swap array_setitem
   { 216 191 216 }list "thistle" rot swap array_setitem
   { 255 250 250 }list "snow1" rot swap array_setitem
   { 238 233 233 }list "snow2" rot swap array_setitem
   { 205 201 201 }list "snow3" rot swap array_setitem
   { 139 137 137 }list "snow4" rot swap array_setitem
   { 255 245 238 }list "seashell1" rot swap array_setitem
   { 238 229 222 }list "seashell2" rot swap array_setitem
   { 205 197 191 }list "seashell3" rot swap array_setitem
   { 139 134 130 }list "seashell4" rot swap array_setitem
   { 255 239 219 }list "AntiqueWhite1" rot swap array_setitem
   { 238 223 204 }list "AntiqueWhite2" rot swap array_setitem
   { 205 192 176 }list "AntiqueWhite3" rot swap array_setitem
   { 139 131 120 }list "AntiqueWhite4" rot swap array_setitem
   { 255 228 196 }list "bisque1" rot swap array_setitem
   { 238 213 183 }list "bisque2" rot swap array_setitem
   { 205 183 158 }list "bisque3" rot swap array_setitem
   { 139 125 107 }list "bisque4" rot swap array_setitem
   { 255 218 185 }list "PeachPuff1" rot swap array_setitem
   { 238 203 173 }list "PeachPuff2" rot swap array_setitem
   { 205 175 149 }list "PeachPuff3" rot swap array_setitem
   { 139 119 101 }list "PeachPuff4" rot swap array_setitem
   { 255 222 173 }list "NavajoWhite1" rot swap array_setitem
   { 238 207 161 }list "NavajoWhite2" rot swap array_setitem
   { 205 179 139 }list "NavajoWhite3" rot swap array_setitem
   { 139 121 94 }list "NavajoWhite4" rot swap array_setitem
   { 255 250 205 }list "LemonChiffon1" rot swap array_setitem
   { 238 233 191 }list "LemonChiffon2" rot swap array_setitem
   { 205 201 165 }list "LemonChiffon3" rot swap array_setitem
   { 139 137 112 }list "LemonChiffon4" rot swap array_setitem
   { 255 248 220 }list "cornsilk1" rot swap array_setitem
   { 238 232 205 }list "cornsilk2" rot swap array_setitem
   { 205 200 177 }list "cornsilk3" rot swap array_setitem
   { 139 136 120 }list "cornsilk4" rot swap array_setitem
   { 255 255 240 }list "ivory1" rot swap array_setitem
   { 238 238 224 }list "ivory2" rot swap array_setitem
   { 205 205 193 }list "ivory3" rot swap array_setitem
   { 139 139 131 }list "ivory4" rot swap array_setitem
   { 240 255 240 }list "honeydew1" rot swap array_setitem
   { 224 238 224 }list "honeydew2" rot swap array_setitem
   { 193 205 193 }list "honeydew3" rot swap array_setitem
   { 131 139 131 }list "honeydew4" rot swap array_setitem
   { 255 240 245 }list "LavenderBlush1" rot swap array_setitem
   { 238 224 229 }list "LavenderBlush2" rot swap array_setitem
   { 205 193 197 }list "LavenderBlush3" rot swap array_setitem
   { 139 131 134 }list "LavenderBlush4" rot swap array_setitem
   { 255 228 225 }list "MistyRose1" rot swap array_setitem
   { 238 213 210 }list "MistyRose2" rot swap array_setitem
   { 205 183 181 }list "MistyRose3" rot swap array_setitem
   { 139 125 123 }list "MistyRose4" rot swap array_setitem
   { 240 255 255 }list "azure1" rot swap array_setitem
   { 224 238 238 }list "azure2" rot swap array_setitem
   { 193 205 205 }list "azure3" rot swap array_setitem
   { 131 139 139 }list "azure4" rot swap array_setitem
   { 131 111 255 }list "SlateBlue1" rot swap array_setitem
   { 122 103 238 }list "SlateBlue2" rot swap array_setitem
   { 105 89 205 }list "SlateBlue3" rot swap array_setitem
   { 71 60 139 }list "SlateBlue4" rot swap array_setitem
   { 72 118 255 }list "RoyalBlue1" rot swap array_setitem
   { 67 110 238 }list "RoyalBlue2" rot swap array_setitem
   { 58 95 205 }list "RoyalBlue3" rot swap array_setitem
   { 39 64 139 }list "RoyalBlue4" rot swap array_setitem
   { 0 0 255 }list "blue1" rot swap array_setitem
   { 0 0 238 }list "blue2" rot swap array_setitem
   { 0 0 205 }list "blue3" rot swap array_setitem
   { 0 0 139 }list "blue4" rot swap array_setitem
   { 30 144 255 }list "DodgerBlue1" rot swap array_setitem
   { 28 134 238 }list "DodgerBlue2" rot swap array_setitem
   { 24 116 205 }list "DodgerBlue3" rot swap array_setitem
 
   { 16 78 139 }list "DodgerBlue4" rot swap array_setitem
   { 99 184 255 }list "SteelBlue1" rot swap array_setitem
   { 92 172 238 }list "SteelBlue2" rot swap array_setitem
   { 79 148 205 }list "SteelBlue3" rot swap array_setitem
   { 54 100 139 }list "SteelBlue4" rot swap array_setitem
 
   { 0 191 255 }list "DeepSkyBlue1" rot swap array_setitem
   { 0 178 238 }list "DeepSkyBlue2" rot swap array_setitem
   { 0 154 205 }list "DeepSkyBlue3" rot swap array_setitem
   { 0 104 139 }list "DeepSkyBlue4" rot swap array_setitem
   { 135 206 255 }list "SkyBlue1" rot swap array_setitem
   { 126 192 238 }list "SkyBlue2" rot swap array_setitem
   { 108 166 205 }list "SkyBlue3" rot swap array_setitem
   { 74 112 139 }list "SkyBlue4" rot swap array_setitem
   { 176 226 255 }list "LightSkyBlue1" rot swap array_setitem
   { 164 211 238 }list "LightSkyBlue2" rot swap array_setitem
   { 141 182 205 }list "LightSkyBlue3" rot swap array_setitem
   { 96 123 139 }list "LightSkyBlue4" rot swap array_setitem
   { 198 226 255 }list "SlateGray1" rot swap array_setitem
   { 185 211 238 }list "SlateGray2" rot swap array_setitem
   { 159 182 205 }list "SlateGray3" rot swap array_setitem
   { 108 123 139 }list "SlateGray4" rot swap array_setitem
   { 202 225 255 }list "LightSteelBlue1" rot swap array_setitem
   { 188 210 238 }list "LightSteelBlue2" rot swap array_setitem
   { 162 181 205 }list "LightSteelBlue3" rot swap array_setitem
   { 110 123 139 }list "LightSteelBlue4" rot swap array_setitem
   { 191 239 255 }list "LightBlue1" rot swap array_setitem
   { 178 223 238 }list "LightBlue2" rot swap array_setitem
   { 154 192 205 }list "LightBlue3" rot swap array_setitem
   { 104 131 139 }list "LightBlue4" rot swap array_setitem
   { 224 255 255 }list "LightCyan1" rot swap array_setitem
   { 209 238 238 }list "LightCyan2" rot swap array_setitem
   { 180 205 205 }list "LightCyan3" rot swap array_setitem
   { 122 139 139 }list "LightCyan4" rot swap array_setitem
   { 187 255 255 }list "PaleTurquoise1" rot swap array_setitem
   { 174 238 238 }list "PaleTurquoise2" rot swap array_setitem
   { 150 205 205 }list "PaleTurquoise3" rot swap array_setitem
   { 102 139 139 }list "PaleTurquoise4" rot swap array_setitem
   { 152 245 255 }list "CadetBlue1" rot swap array_setitem
   { 142 229 238 }list "CadetBlue2" rot swap array_setitem
   { 122 197 205 }list "CadetBlue3" rot swap array_setitem
 
   { 83 134 139 }list "CadetBlue4" rot swap array_setitem
   { 0 245 255 }list "turquoise1" rot swap array_setitem
   { 0 229 238 }list "turquoise2" rot swap array_setitem
   { 0 197 205 }list "turquoise3" rot swap array_setitem
   { 0 134 139 }list "turquoise4" rot swap array_setitem
   { 0 255 255 }list "cyan1" rot swap array_setitem
   { 0 238 238 }list "cyan2" rot swap array_setitem
   { 0 205 205 }list "cyan3" rot swap array_setitem
   { 0 139 139 }list "cyan4" rot swap array_setitem
   { 151 255 255 }list "DarkSlateGray1" rot swap array_setitem
   { 141 238 238 }list "DarkSlateGray2" rot swap array_setitem
   { 121 205 205 }list "DarkSlateGray3" rot swap array_setitem
   { 82 139 139 }list "DarkSlateGray4" rot swap array_setitem
   { 127 255 212 }list "aquamarine1" rot swap array_setitem
   { 118 238 198 }list "aquamarine2" rot swap array_setitem
   { 102 205 170 }list "aquamarine3" rot swap array_setitem
   { 69 139 116 }list "aquamarine4" rot swap array_setitem
   { 193 255 193 }list "DarkSeaGreen1" rot swap array_setitem
   { 180 238 180 }list "DarkSeaGreen2" rot swap array_setitem
   { 155 205 155 }list "DarkSeaGreen3" rot swap array_setitem
   { 105 139 105 }list "DarkSeaGreen4" rot swap array_setitem
   { 84 255 159 }list "SeaGreen1" rot swap array_setitem
   { 78 238 148 }list "SeaGreen2" rot swap array_setitem
   { 67 205 128 }list "SeaGreen3" rot swap array_setitem
   { 46 139 87 }list "SeaGreen4" rot swap array_setitem
   { 154 255 154 }list "PaleGreen1" rot swap array_setitem
   { 144 238 144 }list "PaleGreen2" rot swap array_setitem
   { 124 205 124 }list "PaleGreen3" rot swap array_setitem
   { 84 139 84 }list "PaleGreen4" rot swap array_setitem
   { 0 255 127 }list "SpringGreen1" rot swap array_setitem
   { 0 238 118 }list "SpringGreen2" rot swap array_setitem
   { 0 205 102 }list "SpringGreen3" rot swap array_setitem
   { 0 139 69 }list "SpringGreen4" rot swap array_setitem
   { 0 255 0 }list "green1" rot swap array_setitem
   { 0 238 0 }list "green2" rot swap array_setitem
   { 0 205 0 }list "green3" rot swap array_setitem
   { 0 139 0 }list "green4" rot swap array_setitem
   { 127 255 0 }list "chartreuse1" rot swap array_setitem
   { 118 238 0 }list "chartreuse2" rot swap array_setitem
   { 102 205 0 }list "chartreuse3" rot swap array_setitem
   { 69 139 0 }list "chartreuse4" rot swap array_setitem
   { 192 255 62 }list "OliveDrab1" rot swap array_setitem
   { 179 238 58 }list "OliveDrab2" rot swap array_setitem
   { 154 205 50 }list "OliveDrab3" rot swap array_setitem
   { 105 139 34 }list "OliveDrab4" rot swap array_setitem
   { 202 255 112 }list "DarkOliveGreen1" rot swap array_setitem
   { 188 238 104 }list "DarkOliveGreen2" rot swap array_setitem
   { 162 205 90 }list "DarkOliveGreen3" rot swap array_setitem
   { 110 139 61 }list "DarkOliveGreen4" rot swap array_setitem
   { 255 246 143 }list "khaki1" rot swap array_setitem
   { 238 230 133 }list "khaki2" rot swap array_setitem
   { 205 198 115 }list "khaki3" rot swap array_setitem
   { 139 134 78 }list "khaki4" rot swap array_setitem
   { 255 236 139 }list "LightGoldenrod1" rot swap array_setitem
   { 238 220 130 }list "LightGoldenrod2" rot swap array_setitem
   { 205 190 112 }list "LightGoldenrod3" rot swap array_setitem
   { 139 129 76 }list "LightGoldenrod4" rot swap array_setitem
   { 255 255 224 }list "LightYellow1" rot swap array_setitem
   { 238 238 209 }list "LightYellow2" rot swap array_setitem
   { 205 205 180 }list "LightYellow3" rot swap array_setitem
   { 139 139 122 }list "LightYellow4" rot swap array_setitem
   { 255 255 0 }list "yellow1" rot swap array_setitem
   { 238 238 0 }list "yellow2" rot swap array_setitem
   { 205 205 0 }list "yellow3" rot swap array_setitem
   { 139 139 0 }list "yellow4" rot swap array_setitem
   { 255 215 0 }list "gold1" rot swap array_setitem
   { 238 201 0 }list "gold2" rot swap array_setitem
   { 205 173 0 }list "gold3" rot swap array_setitem
   { 139 117 0 }list "gold4" rot swap array_setitem
   { 255 193 37 }list "goldenrod1" rot swap array_setitem
   { 238 180 34 }list "goldenrod2" rot swap array_setitem
   { 205 155 29 }list "goldenrod3" rot swap array_setitem
   { 139 105 20 }list "goldenrod4" rot swap array_setitem
   { 255 185 15 }list "DarkGoldenrod1" rot swap array_setitem
   { 238 173 14 }list "DarkGoldenrod2" rot swap array_setitem
   { 205 149 12 }list "DarkGoldenrod3" rot swap array_setitem
   { 139 101 8 }list "DarkGoldenrod4" rot swap array_setitem
   { 255 193 193 }list "RosyBrown1" rot swap array_setitem
   { 238 180 180 }list "RosyBrown2" rot swap array_setitem
   { 205 155 155 }list "RosyBrown3" rot swap array_setitem
   { 139 105 105 }list "RosyBrown4" rot swap array_setitem
   { 255 106 106 }list "IndianRed1" rot swap array_setitem
   { 238 99 99 }list "IndianRed2" rot swap array_setitem
   { 205 85 85 }list "IndianRed3" rot swap array_setitem
   { 139 58 58 }list "IndianRed4" rot swap array_setitem
   { 255 130 71 }list "sienna1" rot swap array_setitem
   { 238 121 66 }list "sienna2" rot swap array_setitem
   { 205 104 57 }list "sienna3" rot swap array_setitem
   { 139 71 38 }list "sienna4" rot swap array_setitem
   { 255 211 155 }list "burlywood1" rot swap array_setitem
   { 238 197 145 }list "burlywood2" rot swap array_setitem
   { 205 170 125 }list "burlywood3" rot swap array_setitem
   { 139 115 85 }list "burlywood4" rot swap array_setitem
   { 255 231 186 }list "wheat1" rot swap array_setitem
   { 238 216 174 }list "wheat2" rot swap array_setitem
   { 205 186 150 }list "wheat3" rot swap array_setitem
   { 139 126 102 }list "wheat4" rot swap array_setitem
   { 255 165 79 }list "tan1" rot swap array_setitem
   { 238 154 73 }list "tan2" rot swap array_setitem
   { 205 133 63 }list "tan3" rot swap array_setitem
   { 139 90 43 }list "tan4" rot swap array_setitem
   { 255 127 36 }list "chocolate1" rot swap array_setitem
   { 238 118 33 }list "chocolate2" rot swap array_setitem
   { 205 102 29 }list "chocolate3" rot swap array_setitem
   { 139 69 19 }list "chocolate4" rot swap array_setitem
   { 255 48 48 }list "firebrick1" rot swap array_setitem
   { 238 44 44 }list "firebrick2" rot swap array_setitem
   { 205 38 38 }list "firebrick3" rot swap array_setitem
   { 139 26 26 }list "firebrick4" rot swap array_setitem
   { 255 64 64 }list "brown1" rot swap array_setitem
   { 238 59 59 }list "brown2" rot swap array_setitem
   { 205 51 51 }list "brown3" rot swap array_setitem
   { 139 35 35 }list "brown4" rot swap array_setitem
   { 255 140 105 }list "salmon1" rot swap array_setitem
   { 238 130 98 }list "salmon2" rot swap array_setitem
   { 205 112 84 }list "salmon3" rot swap array_setitem
   { 139 76 57 }list "salmon4" rot swap array_setitem
   { 255 160 122 }list "LightSalmon1" rot swap array_setitem
   { 238 149 114 }list "LightSalmon2" rot swap array_setitem
   { 205 129 98 }list "LightSalmon3" rot swap array_setitem
   { 139 87 66 }list "LightSalmon4" rot swap array_setitem
   { 255 165 0 }list "orange1" rot swap array_setitem
   { 238 154 0 }list "orange2" rot swap array_setitem
   { 205 133 0 }list "orange3" rot swap array_setitem
   { 139 90 0 }list "orange4" rot swap array_setitem
   { 255 127 0 }list "DarkOrange1" rot swap array_setitem
   { 238 118 0 }list "DarkOrange2" rot swap array_setitem
   { 205 102 0 }list "DarkOrange3" rot swap array_setitem
   { 139 69 0 }list "DarkOrange4" rot swap array_setitem
   { 255 114 86 }list "coral1" rot swap array_setitem
   { 238 106 80 }list "coral2" rot swap array_setitem
   { 205 91 69 }list "coral3" rot swap array_setitem
   { 139 62 47 }list "coral4" rot swap array_setitem
   { 255 99 71 }list "tomato1" rot swap array_setitem
   { 238 92 66 }list "tomato2" rot swap array_setitem
   { 205 79 57 }list "tomato3" rot swap array_setitem
   { 139 54 38 }list "tomato4" rot swap array_setitem
   { 255 69 0 }list "OrangeRed1" rot swap array_setitem
   { 238 64 0 }list "OrangeRed2" rot swap array_setitem
   { 205 55 0 }list "OrangeRed3" rot swap array_setitem
   { 139 37 0 }list "OrangeRed4" rot swap array_setitem
   { 255 0 0 }list "red1" rot swap array_setitem
   { 238 0 0 }list "red2" rot swap array_setitem
   { 205 0 0 }list "red3" rot swap array_setitem
   { 139 0 0 }list "red4" rot swap array_setitem
   { 255 20 147 }list "DeepPink1" rot swap array_setitem
   { 238 18 137 }list "DeepPink2" rot swap array_setitem
   { 205 16 118 }list "DeepPink3" rot swap array_setitem
   { 139 10 80 }list "DeepPink4" rot swap array_setitem
   { 255 110 180 }list "HotPink1" rot swap array_setitem
   { 238 106 167 }list "HotPink2" rot swap array_setitem
   { 205 96 144 }list "HotPink3" rot swap array_setitem
   { 139 58 98 }list "HotPink4" rot swap array_setitem
   { 255 181 197 }list "pink1" rot swap array_setitem
   { 238 169 184 }list "pink2" rot swap array_setitem
   { 205 145 158 }list "pink3" rot swap array_setitem
   { 139 99 108 }list "pink4" rot swap array_setitem
   { 255 174 185 }list "LightPink1" rot swap array_setitem
   { 238 162 173 }list "LightPink2" rot swap array_setitem
   { 205 140 149 }list "LightPink3" rot swap array_setitem
   { 139 95 101 }list "LightPink4" rot swap array_setitem
   { 255 130 171 }list "PaleVioletRed1" rot swap array_setitem
   { 238 121 159 }list "PaleVioletRed2" rot swap array_setitem
   { 205 104 137 }list "PaleVioletRed3" rot swap array_setitem
   { 139 71 93 }list "PaleVioletRed4" rot swap array_setitem
   { 255 52 179 }list "maroon1" rot swap array_setitem
   { 238 48 167 }list "maroon2" rot swap array_setitem
 
   { 205 41 144 }list "maroon3" rot swap array_setitem
   { 139 28 98 }list "maroon4" rot swap array_setitem
   { 255 62 150 }list "VioletRed1" rot swap array_setitem
   { 238 58 140 }list "VioletRed2" rot swap array_setitem
   { 205 50 120 }list "VioletRed3" rot swap array_setitem
   { 139 34 82 }list "VioletRed4" rot swap array_setitem
   { 255 0 255 }list "magenta1" rot swap array_setitem
   { 238 0 238 }list "magenta2" rot swap array_setitem
   { 205 0 205 }list "magenta3" rot swap array_setitem
   { 139 0 139 }list "magenta4" rot swap array_setitem
   { 255 131 250 }list "orchid1" rot swap array_setitem
   { 238 122 233 }list "orchid2" rot swap array_setitem
   { 205 105 201 }list "orchid3" rot swap array_setitem
   { 139 71 137 }list "orchid4" rot swap array_setitem
   { 255 187 255 }list "plum1" rot swap array_setitem
   { 238 174 238 }list "plum2" rot swap array_setitem
   { 205 150 205 }list "plum3" rot swap array_setitem
   { 139 102 139 }list "plum4" rot swap array_setitem
   { 224 102 255 }list "MediumOrchid1" rot swap array_setitem
   { 209 95 238 }list "MediumOrchid2" rot swap array_setitem
   { 180 82 205 }list "MediumOrchid3" rot swap array_setitem
   { 122 55 139 }list "MediumOrchid4" rot swap array_setitem
   { 191 62 255 }list "DarkOrchid1" rot swap array_setitem
   { 178 58 238 }list "DarkOrchid2" rot swap array_setitem
   { 154 50 205 }list "DarkOrchid3" rot swap array_setitem
   { 104 34 139 }list "DarkOrchid4" rot swap array_setitem
   { 155 48 255 }list "purple1" rot swap array_setitem
   { 145 44 238 }list "purple2" rot swap array_setitem
   { 125 38 205 }list "purple3" rot swap array_setitem
   { 85 26 139 }list "purple4" rot swap array_setitem
   { 171 130 255 }list "MediumPurple1" rot swap array_setitem
   { 159 121 238 }list "MediumPurple2" rot swap array_setitem
   { 137 104 205 }list "MediumPurple3" rot swap array_setitem
   { 93 71 139 }list "MediumPurple4" rot swap array_setitem
   { 255 225 255 }list "thistle1" rot swap array_setitem
   { 238 210 238 }list "thistle2" rot swap array_setitem
   { 205 181 205 }list "thistle3" rot swap array_setitem
   { 139 123 139 }list "thistle4" rot swap array_setitem
   { 0 0 0 }list "gray0" rot swap array_setitem
   { 0 0 0 }list "grey0" rot swap array_setitem
   { 3 3 3 }list "gray1" rot swap array_setitem
   { 3 3 3 }list "grey1" rot swap array_setitem
   { 5 5 5 }list "gray2" rot swap array_setitem
   { 5 5 5 }list "grey2" rot swap array_setitem
   { 8 8 8 }list "gray3" rot swap array_setitem
   { 8 8 8 }list "grey3" rot swap array_setitem
   { 10 10 10 }list "gray4" rot swap array_setitem
   { 10 10 10 }list "grey4" rot swap array_setitem
 
   { 13 13 13 }list "gray5" rot swap array_setitem
   { 13 13 13 }list "grey5" rot swap array_setitem
   { 15 15 15 }list "gray6" rot swap array_setitem
   { 15 15 15 }list "grey6" rot swap array_setitem
   { 18 18 18 }list "gray7" rot swap array_setitem
   { 18 18 18 }list "grey7" rot swap array_setitem
   { 20 20 20 }list "gray8" rot swap array_setitem
   { 20 20 20 }list "grey8" rot swap array_setitem
   { 23 23 23 }list "gray9" rot swap array_setitem
   { 23 23 23 }list "grey9" rot swap array_setitem
   { 26 26 26 }list "gray10" rot swap array_setitem
   { 26 26 26 }list "grey10" rot swap array_setitem
   { 28 28 28 }list "gray11" rot swap array_setitem
   { 28 28 28 }list "grey11" rot swap array_setitem
   { 31 31 31 }list "gray12" rot swap array_setitem
   { 31 31 31 }list "grey12" rot swap array_setitem
   { 33 33 33 }list "gray13" rot swap array_setitem
   { 33 33 33 }list "grey13" rot swap array_setitem
   { 36 36 36 }list "gray14" rot swap array_setitem
   { 36 36 36 }list "grey14" rot swap array_setitem
   { 38 38 38 }list "gray15" rot swap array_setitem
   { 38 38 38 }list "grey15" rot swap array_setitem
   { 41 41 41 }list "gray16" rot swap array_setitem
   { 41 41 41 }list "grey16" rot swap array_setitem
   { 43 43 43 }list "gray17" rot swap array_setitem
   { 43 43 43 }list "grey17" rot swap array_setitem
   { 46 46 46 }list "gray18" rot swap array_setitem
   { 46 46 46 }list "grey18" rot swap array_setitem
   { 48 48 48 }list "gray19" rot swap array_setitem
   { 48 48 48 }list "grey19" rot swap array_setitem
   { 51 51 51 }list "gray20" rot swap array_setitem
   { 51 51 51 }list "grey20" rot swap array_setitem
   { 54 54 54 }list "gray21" rot swap array_setitem
   { 54 54 54 }list "grey21" rot swap array_setitem
   { 56 56 56 }list "gray22" rot swap array_setitem
   { 56 56 56 }list "grey22" rot swap array_setitem
   { 59 59 59 }list "gray23" rot swap array_setitem
   { 59 59 59 }list "grey23" rot swap array_setitem
   { 61 61 61 }list "gray24" rot swap array_setitem
   { 61 61 61 }list "grey24" rot swap array_setitem
   { 64 64 64 }list "gray25" rot swap array_setitem
   { 64 64 64 }list "grey25" rot swap array_setitem
   { 66 66 66 }list "gray26" rot swap array_setitem
   { 66 66 66 }list "grey26" rot swap array_setitem
   { 69 69 69 }list "gray27" rot swap array_setitem
   { 69 69 69 }list "grey27" rot swap array_setitem
   { 71 71 71 }list "gray28" rot swap array_setitem
   { 71 71 71 }list "grey28" rot swap array_setitem
   { 74 74 74 }list "gray29" rot swap array_setitem
   { 74 74 74 }list "grey29" rot swap array_setitem
   { 77 77 77 }list "gray30" rot swap array_setitem
   { 77 77 77 }list "grey30" rot swap array_setitem
   { 79 79 79 }list "gray31" rot swap array_setitem
   { 79 79 79 }list "grey31" rot swap array_setitem
   { 82 82 82 }list "gray32" rot swap array_setitem
   { 82 82 82 }list "grey32" rot swap array_setitem
   { 84 84 84 }list "gray33" rot swap array_setitem
   { 84 84 84 }list "grey33" rot swap array_setitem
   { 87 87 87 }list "gray34" rot swap array_setitem
   { 87 87 87 }list "grey34" rot swap array_setitem
   { 89 89 89 }list "gray35" rot swap array_setitem
   { 89 89 89 }list "grey35" rot swap array_setitem
   { 92 92 92 }list "gray36" rot swap array_setitem
   { 92 92 92 }list "grey36" rot swap array_setitem
   { 94 94 94 }list "gray37" rot swap array_setitem
   { 94 94 94 }list "grey37" rot swap array_setitem
   { 97 97 97 }list "gray38" rot swap array_setitem
   { 97 97 97 }list "grey38" rot swap array_setitem
   { 99 99 99 }list "gray39" rot swap array_setitem
   { 99 99 99 }list "grey39" rot swap array_setitem
   { 102 102 102 }list "gray40" rot swap array_setitem
   { 102 102 102 }list "grey40" rot swap array_setitem
   { 105 105 105 }list "gray41" rot swap array_setitem
   { 105 105 105 }list "grey41" rot swap array_setitem
   { 107 107 107 }list "gray42" rot swap array_setitem
   { 107 107 107 }list "grey42" rot swap array_setitem
   { 110 110 110 }list "gray43" rot swap array_setitem
   { 110 110 110 }list "grey43" rot swap array_setitem
   { 112 112 112 }list "gray44" rot swap array_setitem
   { 112 112 112 }list "grey44" rot swap array_setitem
   { 115 115 115 }list "gray45" rot swap array_setitem
   { 115 115 115 }list "grey45" rot swap array_setitem
   { 117 117 117 }list "gray46" rot swap array_setitem
   { 117 117 117 }list "grey46" rot swap array_setitem
   { 120 120 120 }list "gray47" rot swap array_setitem
   { 120 120 120 }list "grey47" rot swap array_setitem
   { 122 122 122 }list "gray48" rot swap array_setitem
   { 122 122 122 }list "grey48" rot swap array_setitem
   { 125 125 125 }list "gray49" rot swap array_setitem
   { 125 125 125 }list "grey49" rot swap array_setitem
   { 127 127 127 }list "gray50" rot swap array_setitem
   { 127 127 127 }list "grey50" rot swap array_setitem
   { 130 130 130 }list "gray51" rot swap array_setitem
   { 130 130 130 }list "grey51" rot swap array_setitem
   { 133 133 133 }list "gray52" rot swap array_setitem
   { 133 133 133 }list "grey52" rot swap array_setitem
   { 135 135 135 }list "gray53" rot swap array_setitem
   { 135 135 135 }list "grey53" rot swap array_setitem
   { 138 138 138 }list "gray54" rot swap array_setitem
   { 138 138 138 }list "grey54" rot swap array_setitem
   { 140 140 140 }list "gray55" rot swap array_setitem
   { 140 140 140 }list "grey55" rot swap array_setitem
   { 143 143 143 }list "gray56" rot swap array_setitem
   { 143 143 143 }list "grey56" rot swap array_setitem
   { 145 145 145 }list "gray57" rot swap array_setitem
   { 145 145 145 }list "grey57" rot swap array_setitem
   { 148 148 148 }list "gray58" rot swap array_setitem
   { 148 148 148 }list "grey58" rot swap array_setitem
   { 150 150 150 }list "gray59" rot swap array_setitem
   { 150 150 150 }list "grey59" rot swap array_setitem
   { 153 153 153 }list "gray60" rot swap array_setitem
   { 153 153 153 }list "grey60" rot swap array_setitem
   { 156 156 156 }list "gray61" rot swap array_setitem
   { 156 156 156 }list "grey61" rot swap array_setitem
   { 158 158 158 }list "gray62" rot swap array_setitem
   { 158 158 158 }list "grey62" rot swap array_setitem
   { 161 161 161 }list "gray63" rot swap array_setitem
   { 161 161 161 }list "grey63" rot swap array_setitem
   { 163 163 163 }list "gray64" rot swap array_setitem
   { 163 163 163 }list "grey64" rot swap array_setitem
   { 166 166 166 }list "gray65" rot swap array_setitem
   { 166 166 166 }list "grey65" rot swap array_setitem
   { 168 168 168 }list "gray66" rot swap array_setitem
   { 168 168 168 }list "grey66" rot swap array_setitem
   { 171 171 171 }list "gray67" rot swap array_setitem
   { 171 171 171 }list "grey67" rot swap array_setitem
   { 173 173 173 }list "gray68" rot swap array_setitem
   { 173 173 173 }list "grey68" rot swap array_setitem
   { 176 176 176 }list "gray69" rot swap array_setitem
   { 176 176 176 }list "grey69" rot swap array_setitem
   { 179 179 179 }list "gray70" rot swap array_setitem
   { 179 179 179 }list "grey70" rot swap array_setitem
   { 181 181 181 }list "gray71" rot swap array_setitem
   { 181 181 181 }list "grey71" rot swap array_setitem
   { 184 184 184 }list "gray72" rot swap array_setitem
   { 184 184 184 }list "grey72" rot swap array_setitem
   { 186 186 186 }list "gray73" rot swap array_setitem
   { 186 186 186 }list "grey73" rot swap array_setitem
   { 189 189 189 }list "gray74" rot swap array_setitem
   { 189 189 189 }list "grey74" rot swap array_setitem
   { 191 191 191 }list "gray75" rot swap array_setitem
   { 191 191 191 }list "grey75" rot swap array_setitem
   { 194 194 194 }list "gray76" rot swap array_setitem
   { 194 194 194 }list "grey76" rot swap array_setitem
   { 196 196 196 }list "gray77" rot swap array_setitem
   { 196 196 196 }list "grey77" rot swap array_setitem
   { 199 199 199 }list "gray78" rot swap array_setitem
   { 199 199 199 }list "grey78" rot swap array_setitem
   { 201 201 201 }list "gray79" rot swap array_setitem
   { 201 201 201 }list "grey79" rot swap array_setitem
   { 204 204 204 }list "gray80" rot swap array_setitem
   { 204 204 204 }list "grey80" rot swap array_setitem
   { 207 207 207 }list "gray81" rot swap array_setitem
   { 207 207 207 }list "grey81" rot swap array_setitem
   { 209 209 209 }list "gray82" rot swap array_setitem
   { 209 209 209 }list "grey82" rot swap array_setitem
   { 212 212 212 }list "gray83" rot swap array_setitem
   { 212 212 212 }list "grey83" rot swap array_setitem
   { 214 214 214 }list "gray84" rot swap array_setitem
   { 214 214 214 }list "grey84" rot swap array_setitem
   { 217 217 217 }list "gray85" rot swap array_setitem
   { 217 217 217 }list "grey85" rot swap array_setitem
   { 219 219 219 }list "gray86" rot swap array_setitem
   { 219 219 219 }list "grey86" rot swap array_setitem
   { 222 222 222 }list "gray87" rot swap array_setitem
   { 222 222 222 }list "grey87" rot swap array_setitem
   { 224 224 224 }list "gray88" rot swap array_setitem
   { 224 224 224 }list "grey88" rot swap array_setitem
   { 227 227 227 }list "gray89" rot swap array_setitem
   { 227 227 227 }list "grey89" rot swap array_setitem
   { 229 229 229 }list "gray90" rot swap array_setitem
   { 229 229 229 }list "grey90" rot swap array_setitem
   { 232 232 232 }list "gray91" rot swap array_setitem
   { 232 232 232 }list "grey91" rot swap array_setitem
   { 235 235 235 }list "gray92" rot swap array_setitem
 
   { 235 235 235 }list "grey92" rot swap array_setitem
   { 237 237 237 }list "gray93" rot swap array_setitem
   { 237 237 237 }list "grey93" rot swap array_setitem
   { 240 240 240 }list "gray94" rot swap array_setitem
   { 240 240 240 }list "grey94" rot swap array_setitem
   { 242 242 242 }list "gray95" rot swap array_setitem
   { 242 242 242 }list "grey95" rot swap array_setitem
   { 245 245 245 }list "gray96" rot swap array_setitem
   { 245 245 245 }list "grey96" rot swap array_setitem
   { 247 247 247 }list "gray97" rot swap array_setitem
   { 247 247 247 }list "grey97" rot swap array_setitem
   { 250 250 250 }list "gray98" rot swap array_setitem
   { 250 250 250 }list "grey98" rot swap array_setitem
   { 252 252 252 }list "gray99" rot swap array_setitem
   { 252 252 252 }list "grey99" rot swap array_setitem
   { 255 255 255 }list "gray100" rot swap array_setitem
   { 255 255 255 }list "grey100" rot swap array_setitem
   { 169 169 169 }list "dark grey" rot swap array_setitem
   { 169 169 169 }list "DarkGrey" rot swap array_setitem
   { 169 169 169 }list "dark gray" rot swap array_setitem
   { 169 169 169 }list "DarkGray" rot swap array_setitem
   { 0 0 139 }list "dark blue" rot swap array_setitem
   { 0 0 139 }list "DarkBlue" rot swap array_setitem
   { 0 139 139 }list "dark cyan" rot swap array_setitem
   { 0 139 139 }list "DarkCyan" rot swap array_setitem
   { 139 0 139 }list "dark magenta" rot swap array_setitem
   { 139 0 139 }list "DarkMagenta" rot swap array_setitem
   { 139 0 0 }list "dark red" rot swap array_setitem
   { 139 0 0 }list "DarkRed" rot swap array_setitem
   { 144 238 144 }list "light green" rot swap array_setitem
   { 144 238 144 }list "LightGreen" rot swap array_setitem
   DICTcolorlist !
;
: LastColor ( -- str:STRcolor )
   ARRlastcolor @ array_count if
      ARRlastcolor @ dup array_count 1 - array_getitem
   else
      "^NORMAL^"
   then
;
: LastJustify ( -- int:INTjustify )
   ARRjustify @ array_count if
      ARRjustify @ dup array_count 1 - array_getitem
   else
      1
   then
;
: ReturnColor[ str:HEXcode -- str:STRcolor ]
   VAR RGBred VAR RGBgreen VAR RGBblue -1 VAR! RGBcurpos 0 VAR! RGBcurval VAR RGBcolors
   HEXcode @ strip dup HEXcode ! "#" instr 1 = if
      HEXcode @ 1 strcut swap pop 2 strcut 2 strcut 2 strcut pop
      HEXCONVERT RGBblue ! HEXCONVERT RGBgreen ! HEXCONVERT RGBred !
   else
      DICTcolorlist @ dictionary? not if
         LoadColorList
      then
      DICTcolorlist @ HEXcode @ array_getitem dup array? if
         array_vals pop RGBblue ! RGBgreen ! RGBred !
      else
         pop "^NORMAL^" exit
      then
   then
   RGB-GLOOM   RGBblue @ 4 rotate - dup * RGBgreen @ 4 rotate - dup * RGBred @ 4 rotate - dup * + + sqrt "GLOOM"   2 array_make
   RGB-CRIMSON RGBblue @ 4 rotate - dup * RGBgreen @ 4 rotate - dup * RGBred @ 4 rotate - dup * + + sqrt "CRIMSON" 2 array_make
   RGB-FOREST  RGBblue @ 4 rotate - dup * RGBgreen @ 4 rotate - dup * RGBred @ 4 rotate - dup * + + sqrt "FOREST"  2 array_make
   RGB-BROWN   RGBblue @ 4 rotate - dup * RGBgreen @ 4 rotate - dup * RGBred @ 4 rotate - dup * + + sqrt "BROWN"   2 array_make
   RGB-NAVY    RGBblue @ 4 rotate - dup * RGBgreen @ 4 rotate - dup * RGBred @ 4 rotate - dup * + + sqrt "NAVY"    2 array_make
   RGB-VIOLET  RGBblue @ 4 rotate - dup * RGBgreen @ 4 rotate - dup * RGBred @ 4 rotate - dup * + + sqrt "VIOLET"  2 array_make
   RGB-AQUA    RGBblue @ 4 rotate - dup * RGBgreen @ 4 rotate - dup * RGBred @ 4 rotate - dup * + + sqrt "AQUA"    2 array_make
   RGB-GRAY    RGBblue @ 4 rotate - dup * RGBgreen @ 4 rotate - dup * RGBred @ 4 rotate - dup * + + sqrt "GRAY"    2 array_make
   RGB-BLACK   RGBblue @ 4 rotate - dup * RGBgreen @ 4 rotate - dup * RGBred @ 4 rotate - dup * + + sqrt "BLACK"   2 array_make
   RGB-RED     RGBblue @ 4 rotate - dup * RGBgreen @ 4 rotate - dup * RGBred @ 4 rotate - dup * + + sqrt "RED"     2 array_make
   RGB-GREEN   RGBblue @ 4 rotate - dup * RGBgreen @ 4 rotate - dup * RGBred @ 4 rotate - dup * + + sqrt "GREEN"   2 array_make
   RGB-YELLOW  RGBblue @ 4 rotate - dup * RGBgreen @ 4 rotate - dup * RGBred @ 4 rotate - dup * + + sqrt "YELLOW"  2 array_make
   RGB-BLUE    RGBblue @ 4 rotate - dup * RGBgreen @ 4 rotate - dup * RGBred @ 4 rotate - dup * + + sqrt "BLUE"    2 array_make
   RGB-PURPLE  RGBblue @ 4 rotate - dup * RGBgreen @ 4 rotate - dup * RGBred @ 4 rotate - dup * + + sqrt "PURPLE"  2 array_make
   RGB-CYAN    RGBblue @ 4 rotate - dup * RGBgreen @ 4 rotate - dup * RGBred @ 4 rotate - dup * + + sqrt "CYAN"    2 array_make
   RGB-WHITE   RGBblue @ 4 rotate - dup * RGBgreen @ 4 rotate - dup * RGBred @ 4 rotate - dup * + + sqrt "WHITE"   2 array_make
   16 array_make dup RGBcolors !
   FOREACH
      RGBcurpos @ -1 = if
         0 array_getitem RGBcurval ! RGBcurpos !
      else
         0 array_getitem dup RGBcurval @ < if
            RGBcurval ! RGBcurpos !
         else
            pop pop
         then
 
      then
   REPEAT
   RGBcurpos @ -1 = not if
      RGBcolors @ RGBcurpos @ array_getitem 1 array_getitem "^" swap over strcat strcat
   then
;
: HTML2TEXT-DO ( str:HTMLcode -- str:STRtext )
   VAR Args
   strip " " split strip Args ! strip
   dup "code" stringcmp not over "pre" stringcmp not or over "pre" stringcmp not or
   over "plaintext" stringcmp not or over "xmp" stringcmp not or if
      pop 1 INcode? ! "" exit
   then
   dup "/code" stringcmp not over "/pre" stringcmp not or over "/samp" stringcmp not or
   over "/plaintext" stringcmp not or over "/xmp" stringcmp not or if
      pop 0 INcode? ! "" exit
   then
   dup "li" stringcmp not if
      pop "* " exit
   then
   dup "br" stringcmp not if
      pop "\r" exit
   then
   dup "font" stringcmp not if
      pop Args @ "color=" instring not if
         "" exit
      then
      Args @ "color=" split swap pop strip dup "\"" instr 1 = if
         1 strcut swap pop dup "\"" instr if
            "\"" split pop
         then
      else
         " " split pop
      then
      strip ReturnColor dup ARRlastcolor @ array_appenditem ARRlastcolor ! exit
   then
   dup "/font" stringcmp not if
      pop ARRlastcolor @ array_count if
         ARRlastcolor @ dup array_count 1 - array_delitem ARRlastcolor !
      then
      LastColor exit
   then
   dup "p" stringcmp not if
      pop "     " exit
   then
   dup "left" stringcmp not over "l" stringcmp not or if
      pop 1 ARRjustify @ array_appenditem ARRjustify ! "\[1" exit
   then
   dup "/left" stringcmp not over "/l" stringcmp not or if
      pop swap LastJustify "\[" swap intostr strcat split 77 STRaleft strcat
      ARRjustify @ array_count if
         ARRjustify @ dup array_count 1 - array_delitem ARRjustify !
      then
      swap "" exit
   then
   dup "right" stringcmp not over "r" stringcmp not or if
      pop 2 ARRjustify @ array_appenditem ARRjustify ! "\[2" exit
   then
   dup "/right" stringcmp not over "/r" stringcmp not or if
      pop swap LastJustify "\[" swap intostr strcat split 77 STRaright strcat
      ARRjustify @ array_count if
         ARRjustify @ dup array_count 1 - array_delitem ARRjustify !
      then
      swap "" exit
   then
   dup "center" stringcmp not over "c" stringcmp not or if
      pop 3 ARRjustify @ array_appenditem ARRjustify ! "\[3" exit
   then
   dup "/center" stringcmp not over "/c" stringcmp not or if
      pop swap LastJustify "\[" swap intostr strcat split 77 STRacenter strcat
      ARRjustify @ array_count if
         ARRjustify @ dup array_count 1 - array_delitem ARRjustify !
      then
      swap "" exit
   then
   dup "b" stringcmp not over "bold" stringcmp not or over "strong" stringcmp not or if
      pop "^BOLD^" exit
   then
   dup "/b" stringcmp not over "/bold" stringcmp not or over "strong" stringcmp not or if
      pop "^NORMAL^" LastColor strcat exit
   then
   dup "u" stringcmp not over "underline" stringcmp not or over "a" stringcmp not or if
      pop "^UNDERLINE^" exit
   then
   dup "/u" stringcmp not over "/underline" stringcmp not or over "/a" stringcmp not or if
      pop "^NORMAL^" LastColor strcat exit
   then
   pop ""
;
: CHAR2TEXT ( str:STRchar -- str:STRtext )
   strip dup "#" instr 1 = if
      1 strcut swap pop strip atoi dup number? if
         atoi itoc
      else
         pop ""
      then
   else
      dup "lt" stringcmp not if
         pop "<"
      else
         dup "gt" stringcmp not if
            pop ">"
         else
            dup "quot" stringcmp not if
               pop "\""
            else
               dup "amp" stringcmp not if
                  pop "&"
               else
                  pop ""
               then
            then
         then
      then
   then
;
: HTML2TEXT ( str:STRhtml -- str:STRtext )
   0 VAR! TEMPidx
   "^^" "^" subst
(   me @ over notify ) (Debugging purposes)
   ARRlastcolor @ array? not if { }list ARRlastcolor ! then
   ARRjustify   @ array? not if { }list ARRjustify   ! then
   LastColor swap
   BEGIN
      dup "<" instr WHILE
      "<" split rot rot strcat swap ">" split swap HTML2TEXT-DO rot swap strcat swap InCode? @ not if
         0 TEMPidx !
         dup "<" instr if
            "<" split swap TEMPidx ++
         then
         "" "\r" subst stripspaces
         TEMPidx @ if
            "<" strcat swap strcat
         then
      then
   REPEAT
   strcat "" swap
   BEGIN
      dup "&" instr WHILE
      "&" split rot rot strcat swap ";" split swap CHAR2TEXT rot swap strcat swap
   REPEAT
   strcat 1 parse_ansi
   dup "" "\r" subst ansi_strip strip if
      LastJustify 1 = if
         77 STRaleft
      else
         LastJustify 2 = if
            77 STRaright
         else
            77 STRacenter
        then
      then
    then
    striptail dup ansi_strip not if
       pop " "
    then
(   me @ over 0 escape_ansi notify ) (Debugging purposes)
;
: TEXT2HTML ( str:TEXT -- str:HTML )
   "&amp;"  "&"  subst
   "&quot;" "\"" subst
   "&lt;"   "<"  subst
   "&gt;"   ">"  subst
   HTMLfixline
;
 
 
: encodeURL ( str:url -- str:url' )
    escape_url
;
 
 
$def atell me @ swap ansi_notify
: break-CGI[ arr:theMesg -- arr:newData ]
  (* Breaks the CGI up along newline markers. *)
  0 array_make var! newData 
  "" var! buffer 
    theMesg @ foreach swap pop
        begin           
 
            "%0D%0A" split buffer @ if ( stuff left from previous line )
                swap buffer @ swap strcat
                newData @ array_appenditem newData !
                "" buffer ! continue ( remainder of str on stack now )
            then
            dup not if ( end of current line )
                pop buffer ! break ( buffer it for next loop )
            then
            swap newData @ array_appenditem newData ! 
        repeat
    repeat
    ( restore the array, tack on any trailing buffer )
    newData @ buffer @ dup if swap array_appenditem else pop then
;
 
: parse-postCGI[ arr:theMesg -- dict:postData ]
  (* Breaks up POST data into a dictionary of arrays *)
  0 array_make_dict var! postData ( the dict that will be built )
  var curPos ( current position in the message array )
  var curField ( current field being worked on )
  var curData ( current field data )
  "" var! buffer ( temp string data )
 
    {  ( put a MARK on the stack to protect the stack )
    theMesg @ break-CGI theMesg ! 
    ( Now all the lines are broken up by where the newlines were.)
    begin 
        buffer @ if
            buffer @ "" buffer !
        else 
            theMesg @ curPos @ array_getItem dup not if pop break then
        then
        "=" split swap parsecgi curField ! ( catch current field )
        0 array_make curData ! ( initialize data array )
        begin ( now loop for all of that field's data )
            dup string? not if 
                theMesg @ curPos @ array_getitem curPos ++ 
            then
            dup string? not if pop 0 break then ( done with all the strings )
            dup not if pop "\r" then ( empty newlines )
            dup "&" instr if ( end of a field )
                "&" split swap parseCGI curData @ array_appenditem curData !
                buffer ! 1 break
            then
            parseCGI curData @ array_appenditem curData !
        repeat ( field-data loop )
        ( now add new field to the final dictionary )
        curData @ postData @ curField @ array_setitem postData ! 
        not 
    until ( main loop, repeats until 0 is returned from inner loop )
   ( "^RED^PRINTING NOW" atell
    postData @ foreach swap "^GREEN^CURRENT FIELD: " swap strcat atell
        foreach swap pop .tell repeat
    repeat
    "Done." abort
    )
    postData @ swap pop ( pop the MARK off )
;
 
$pubdef :
$libdef parsecgi 
$libdef nukecgi 
$libdef array_nukecgi 
$pubdef arrnukecgi "$lib/cgi" match "array_nukecgi" call
$libdef readcgi
$libdef grabcgi "$lib/cgi" match "readcgi" call
$pubdef parseweb "|" explode pop atoi descr ! host ! user ! params !
$libdef HTMLfix 
$libdef HTML2TEXT 
$libdef TEXT2HTML 
$libdef encodeurl 
$libdef parse-postCGI
 
PUBLIC encodeurl
PUBLIC parsecgi
PUBLIC nukecgi
PUBLIC readcgi
PUBLIC array_nukecgi
PUBLIC TEXT2HTML
PUBLIC HTMLfix
PUBLIC HTML2TEXT
PUBLIC parse-postCGI
