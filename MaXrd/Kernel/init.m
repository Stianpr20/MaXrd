(* Mathematica Init File *)
 
(*---* Load definitions *---*)
Get["MaXrd`Core`Definitions`"]

(*---* Auto completion *---*)
(* Does not currently work on startup.         *)
(* The version check below is to avoid a bug.  *)
(* You may load AutoComplete.m manually in     *)
(* the front end, also for version 10.3        *)
If[$Notebooks && ($VersionNumber >= 11.2), Get["MaXrd`Core`AutoComplete`"]]
